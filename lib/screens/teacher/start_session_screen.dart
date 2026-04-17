import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../utils/theme.dart';
import '../../utils/constants.dart';
import '../../widgets/student_tile.dart';

class StartSessionScreen extends StatefulWidget {
  const StartSessionScreen({super.key});

  @override
  State<StartSessionScreen> createState() => _StartSessionScreenState();
}

class _StartSessionScreenState extends State<StartSessionScreen> {
  int _selectedDuration = 15;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final session = Provider.of<SessionProvider>(context, listen: false);
      if (auth.user != null) {
        session.checkActiveSession(auth.user!.classId);
      }
    });
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final attendance =
          Provider.of<AttendanceProvider>(context, listen: false);
      attendance.fetchPiAttendanceList();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _startSession() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final session = Provider.of<SessionProvider>(context, listen: false);
    final user = auth.user;
    if (user == null) return;

    final success = await session.startSession(
      classId: user.classId,
      teacherUid: user.uid,
      durationMinutes: _selectedDuration,
    );

    if (success) {
      _startPolling();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session started! Students can now mark attendance.'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    }
  }

  Future<void> _stopSession() async {
    final session = Provider.of<SessionProvider>(context, listen: false);
    await session.stopSession();
    _stopPolling();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session stopped.'),
          backgroundColor: AppTheme.warningYellow,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionProvider>(context);
    final attendance = Provider.of<AttendanceProvider>(context);
    final connectivity = Provider.of<ConnectivityProvider>(context);
    final hasActive = session.hasActiveSession;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0C29), Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Attendance Session', style: AppTheme.headingLarge),
              const SizedBox(height: 4),
              Text(
                hasActive
                    ? 'Session is running'
                    : 'Start a new session',
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Session control card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: hasActive
                      ? LinearGradient(
                          colors: [
                            AppTheme.successGreen.withOpacity(0.15),
                            AppTheme.accentTeal.withOpacity(0.05),
                          ],
                        )
                      : AppTheme.cardGradient,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: hasActive
                        ? AppTheme.successGreen.withOpacity(0.3)
                        : Colors.white.withOpacity(0.06),
                  ),
                ),
                child: Column(
                  children: [
                    // Timer display
                    if (hasActive) ...[
                      const Icon(
                        Icons.timer_rounded,
                        color: AppTheme.successGreen,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        session.remainingText,
                        style: AppTheme.headingLarge.copyWith(
                          fontSize: 36,
                          color: AppTheme.successGreen,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Time Remaining',
                        style: AppTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),

                      // Stop button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: session.isLoading ? null : _stopSession,
                          icon: const Icon(Icons.stop_rounded),
                          label: const Text('Stop Session'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppTheme.accentPurple,
                        size: 56,
                      ),
                      const SizedBox(height: 16),

                      // Duration selector
                      Text('Select Duration', style: AppTheme.headingSmall),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: AppConstants.sessionDurations.map((d) {
                          final isSelected = _selectedDuration == d;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedDuration = d),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                gradient:
                                    isSelected ? AppTheme.primaryGradient : null,
                                color: isSelected ? null : AppTheme.cardDark,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Text(
                                '${d}m',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Pi status warning
                      if (!connectivity.isPiReachable)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.warningYellow.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.warningYellow.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: AppTheme.warningYellow, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Raspberry Pi is not reachable. Session will be saved locally.',
                                  style: AppTheme.labelStyle.copyWith(
                                    color: AppTheme.warningYellow,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Start button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: session.isLoading ? null : _startSession,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(
                            'Start $_selectedDuration min Session',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Live attendance from Pi
              if (hasActive) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Live Attendance', style: AppTheme.headingSmall),
                    TextButton.icon(
                      onPressed: () => attendance.fetchPiAttendanceList(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Refresh'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.accentTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (attendance.piAttendanceList.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: AppTheme.glassCard,
                    child: Center(
                      child: Text(
                        'Waiting for students...',
                        style: AppTheme.bodyMedium,
                      ),
                    ),
                  )
                else
                  ...attendance.piAttendanceList.map((s) => StudentTile(
                        name: s['name'] ?? 'Unknown',
                        status: 'present',
                        time: s['timestamp'] ?? '',
                      )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
