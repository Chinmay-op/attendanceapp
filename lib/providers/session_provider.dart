import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/session_model.dart';
import '../services/firestore_service.dart';
import '../services/pi_api_service.dart';
import '../utils/helpers.dart';

class SessionProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final PiApiService _piApi;

  SessionModel? _activeSession;
  bool _isLoading = false;
  String _error = '';
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  SessionModel? get activeSession => _activeSession;
  bool get isLoading => _isLoading;
  bool get hasActiveSession => _activeSession != null && !_activeSession!.isExpired;
  String get error => _error;
  Duration get remaining => _remaining;
  String get remainingText => Helpers.durationText(_remaining);

  SessionProvider(this._firestoreService, this._piApi);

  /// Start a new attendance session
  Future<bool> startSession({
    required String classId,
    required String teacherUid,
    required int durationMinutes,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final now = DateTime.now();
      final sessionId = const Uuid().v4();

      final session = SessionModel(
        sessionId: sessionId,
        classId: classId,
        teacherUid: teacherUid,
        startTime: now,
        endTime: now.add(Duration(minutes: durationMinutes)),
        isActive: true,
        date: Helpers.todayDate(),
      );

      // Try to start on Pi
      try {
        await _piApi.startSession(
          classId: classId,
          durationMinutes: durationMinutes,
        );
      } catch (e) {
        print('Pi session start failed: $e');
      }

      // Save to Firestore
      try {
        await _firestoreService.createSession(session);
      } catch (e) {
        print('Firestore session save failed: $e');
      }

      _activeSession = session;
      _startCountdown();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Stop the active session
  Future<void> stopSession() async {
    if (_activeSession == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      try {
        await _piApi.stopSession();
      } catch (e) {
        print('Pi session stop failed: $e');
      }

      try {
        await _firestoreService.stopSession(_activeSession!.sessionId);
      } catch (e) {
        print('Firestore session stop failed: $e');
      }

      _countdownTimer?.cancel();
      _activeSession = null;
      _remaining = Duration.zero;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Check for any active session
  Future<void> checkActiveSession(String classId) async {
    try {
      _activeSession = await _firestoreService.getActiveSession(classId);
      if (_activeSession != null && !_activeSession!.isExpired) {
        _startCountdown();
      } else {
        _activeSession = null;
      }
      notifyListeners();
    } catch (e) {
      print('Check active session failed: $e');
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_activeSession == null || _activeSession!.isExpired) {
        timer.cancel();
        _activeSession = null;
        _remaining = Duration.zero;
        notifyListeners();
        return;
      }
      _remaining = _activeSession!.remainingTime;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
