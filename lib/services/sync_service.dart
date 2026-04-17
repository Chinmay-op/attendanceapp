import '../models/attendance_model.dart';
import 'local_storage_service.dart';
import 'firestore_service.dart';

class SyncService {
  final LocalStorageService _localStorage;
  final FirestoreService _firestoreService;

  SyncService(this._localStorage, this._firestoreService);

  /// Sync all unsynced local records to Firestore
  Future<int> syncToCloud() async {
    final unsyncedRecords = _localStorage.getUnsyncedRecords();
    if (unsyncedRecords.isEmpty) return 0;

    try {
      const batchSize = 450;
      int synced = 0;

      for (var i = 0; i < unsyncedRecords.length; i += batchSize) {
        final end = (i + batchSize > unsyncedRecords.length)
            ? unsyncedRecords.length
            : i + batchSize;
        final batch = unsyncedRecords.sublist(i, end);

        await _firestoreService.batchUploadAttendance(batch);

        final keys = batch.map((r) => r.key).toList();
        await _localStorage.markMultipleAsSynced(keys);
        synced += batch.length;
      }

      return synced;
    } catch (e) {
      print('Sync error: $e');
      rethrow;
    }
  }

  /// Pull attendance data from Firestore to local storage
  Future<int> pullFromCloud(String classId, String date) async {
    try {
      final records =
          await _firestoreService.getAttendanceByDate(classId, date);
      int newRecords = 0;

      for (final record in records) {
        if (!_localStorage.hasRecord(classId, date, record.uid)) {
          final synced = AttendanceRecord(
            uid: record.uid,
            name: record.name,
            classId: record.classId,
            date: record.date,
            timestamp: record.timestamp,
            status: record.status,
            markedVia: record.markedVia,
            isSynced: true,
          );
          await _localStorage.saveAttendance(synced);
          newRecords++;
        }
      }
      return newRecords;
    } catch (e) {
      print('Pull error: $e');
      rethrow;
    }
  }

  int get pendingSyncCount => _localStorage.unsyncedCount;
  bool get hasPendingSync => _localStorage.unsyncedCount > 0;
}
