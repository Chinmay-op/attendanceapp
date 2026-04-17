import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../services/local_storage_service.dart';
import '../services/pi_api_service.dart';
import '../services/biometric_service.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';

enum MarkingStatus { idle, authenticating, sending, success, error }

class AttendanceProvider extends ChangeNotifier {
  final LocalStorageService _localStorage;
  final PiApiService _piApi;
  final BiometricService _biometricService;

  MarkingStatus _markingStatus = MarkingStatus.idle;
  String _markingMessage = '';
  List<AttendanceRecord> _todayRecords = [];
  List<Map<String, dynamic>> _piAttendanceList = [];

  MarkingStatus get markingStatus => _markingStatus;
  String get markingMessage => _markingMessage;
  List<AttendanceRecord> get todayRecords => _todayRecords;
  List<Map<String, dynamic>> get piAttendanceList => _piAttendanceList;

  AttendanceProvider(this._localStorage, this._piApi, this._biometricService);

  /// Full attendance marking flow: biometric → Pi → local save
  Future<bool> markAttendance({
    required String uid,
    required String name,
    required String classId,
  }) async {
    final today = Helpers.todayDate();

    // Check if already marked
    if (_localStorage.hasRecord(classId, today, uid)) {
      _markingStatus = MarkingStatus.error;
      _markingMessage = 'Attendance already marked for today.';
      notifyListeners();
      return false;
    }

    // Step 1: Biometric auth
    _markingStatus = MarkingStatus.authenticating;
    _markingMessage = 'Authenticating biometrics...';
    notifyListeners();

    try {
      final authenticated = await _biometricService.authenticate();
      if (!authenticated) {
        _markingStatus = MarkingStatus.error;
        _markingMessage = 'Biometric authentication failed.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _markingStatus = MarkingStatus.error;
      _markingMessage = e.toString();
      notifyListeners();
      return false;
    }

    // Step 2: Send to Raspberry Pi
    _markingStatus = MarkingStatus.sending;
    _markingMessage = 'Sending to attendance server...';
    notifyListeners();

    final timestamp = Helpers.currentTimestamp();
    bool piSuccess = false;

    try {
      await _piApi.markAttendance(
        uid: uid,
        name: name,
        timestamp: timestamp,
      );
      piSuccess = true;
    } catch (e) {
      // Continue even if Pi fails — offline-first
      print('Pi API failed: $e');
    }

    // Step 3: Save locally
    final record = AttendanceRecord(
      uid: uid,
      name: name,
      classId: classId,
      date: today,
      timestamp: timestamp,
      status: AppConstants.statusPresent,
      markedVia: AppConstants.markBiometric,
      isSynced: false,
    );

    await _localStorage.saveAttendance(record);

    _markingStatus = MarkingStatus.success;
    _markingMessage = piSuccess
        ? 'Attendance marked successfully!'
        : 'Attendance saved locally (Pi unreachable).';
    notifyListeners();

    await loadTodayRecords(classId);
    return true;
  }

  /// Load today's records for a class from local storage
  Future<void> loadTodayRecords(String classId) async {
    final today = Helpers.todayDate();
    _todayRecords = _localStorage.getRecordsByDate(classId, today);
    notifyListeners();
  }

  /// Get attendance records for a student
  List<AttendanceRecord> getStudentRecords(String uid) {
    return _localStorage.getRecordsForStudent(uid);
  }

  /// Get attendance percentage for a student
  double getStudentPercentage(String uid, String classId) {
    return _localStorage.getAttendancePercentage(uid, classId);
  }

  /// Get monthly status map for calendar
  Map<String, String> getMonthlyStatus(
      String uid, String classId, int year, int month) {
    return _localStorage.getStudentMonthlyStatus(uid, classId, year, month);
  }

  /// Get monthly stats
  Map<String, int> getMonthlyStats(
      String uid, String classId, int year, int month) {
    return _localStorage.getMonthlyStats(uid, classId, year, month);
  }

  /// Poll attendance list from Pi (for teacher)
  Future<void> fetchPiAttendanceList() async {
    try {
      _piAttendanceList = await _piApi.getAttendanceList();
      notifyListeners();
    } catch (e) {
      print('Failed to fetch Pi attendance: $e');
    }
  }

  /// Check if today already marked
  bool isTodayMarked(String uid, String classId) {
    return _localStorage.hasRecord(classId, Helpers.todayDate(), uid);
  }

  void resetStatus() {
    _markingStatus = MarkingStatus.idle;
    _markingMessage = '';
    notifyListeners();
  }
}
