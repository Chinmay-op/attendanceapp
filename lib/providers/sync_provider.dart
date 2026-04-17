import 'dart:async';
import 'package:flutter/material.dart';
import '../services/sync_service.dart';
import 'connectivity_provider.dart';

enum SyncStatus { idle, syncing, success, error }

class SyncProvider extends ChangeNotifier {
  final SyncService _syncService;
  final ConnectivityProvider _connectivityProvider;

  SyncStatus _status = SyncStatus.idle;
  String _message = '';
  int _lastSyncCount = 0;
  DateTime? _lastSyncTime;
  Timer? _autoSyncTimer;

  SyncStatus get status => _status;
  String get message => _message;
  int get pendingCount => _syncService.pendingSyncCount;
  bool get hasPending => _syncService.hasPendingSync;
  int get lastSyncCount => _lastSyncCount;
  DateTime? get lastSyncTime => _lastSyncTime;

  SyncProvider(this._syncService, this._connectivityProvider) {
    // Start auto-sync timer
    _autoSyncTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      _autoSync();
    });
  }

  Future<void> _autoSync() async {
    if (_connectivityProvider.isOnline && _syncService.hasPendingSync) {
      await syncNow();
    }
  }

  Future<void> syncNow() async {
    if (_status == SyncStatus.syncing) return;
    if (!_connectivityProvider.isOnline) {
      _status = SyncStatus.error;
      _message = 'No internet connection. Cannot sync.';
      notifyListeners();
      return;
    }

    _status = SyncStatus.syncing;
    _message = 'Syncing...';
    notifyListeners();

    try {
      final count = await _syncService.syncToCloud();
      _lastSyncCount = count;
      _lastSyncTime = DateTime.now();
      _status = SyncStatus.success;
      _message = count > 0
          ? 'Synced $count record(s) successfully.'
          : 'Everything is up to date.';
    } catch (e) {
      _status = SyncStatus.error;
      _message = 'Sync failed: $e';
    }

    notifyListeners();
  }

  Future<void> pullData(String classId, String date) async {
    if (!_connectivityProvider.isOnline) return;

    try {
      final count = await _syncService.pullFromCloud(classId, date);
      if (count > 0) {
        _message = 'Pulled $count new record(s).';
        notifyListeners();
      }
    } catch (e) {
      print('Pull failed: $e');
    }
  }

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    super.dispose();
  }
}
