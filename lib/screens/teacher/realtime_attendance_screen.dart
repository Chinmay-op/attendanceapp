import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/student_tile.dart';

class RealtimeAttendanceScreen extends StatefulWidget {
  const RealtimeAttendanceScreen({super.key});

  @override
  State<RealtimeAttendanceScreen> createState() =>
      _RealtimeAttendanceScreenState();
}

class _RealtimeAttendanceScreenState extends State<RealtimeAttendanceScreen> {
  Timer? _timer;
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _isPolling = true;
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchData();
    });
  }

  void _fetchData() {
    final attendance =
        Provider.of<AttendanceProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    attendance.fetchPiAttendanceList();
    if (auth.user != null) {
      attendance.loadTodayRecords(auth.user!.classId);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final attendance = Provider.of<AttendanceProvider>(context);
    final piList = attendance.piAttendanceList;
    final localList = attendance.todayRecords;

    // Merge both lists, prefer Pi data
    final Map<String, Map<String, dynamic>> merged = {};
    for (final r in localList) {
      merged[r.uid] = {
        'name': r.name,
        'uid': r.uid,
        'status': r.status,
        'timestamp': r.timestamp,
        'source': 'local',
      };
    }
    for (final r in piList) {
      final uid = r['uid'] ?? '';
      merged[uid] = {
        'name': r['name'] ?? 'Unknown',
        'uid': uid,
        'status': 'present',
        'timestamp': r['timestamp'] ?? '',
        'source': 'pi',
      };
    }

    final students = merged.values.toList();

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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Real-time View',
                            style: AppTheme.headingLarge),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _isPolling
                                    ? AppTheme.successGreen
                                    : AppTheme.errorRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isPolling
                                  ? 'Polling every 5s'
                                  : 'Paused',
                              style: AppTheme.labelStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentPurple.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${students.length} students',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.accentPurple,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _fetchData,
                          icon: const Icon(Icons.refresh_rounded,
                              color: AppTheme.accentTeal),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white10),

              // Student list
              Expanded(
                child: students.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline_rounded,
                                size: 56,
                                color: AppTheme.textSecondary
                                    .withOpacity(0.4)),
                            const SizedBox(height: 12),
                            Text(
                              'Waiting for students...',
                              style: AppTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Attendance will appear here in real-time',
                              style: AppTheme.labelStyle,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final s = students[index];
                          return StudentTile(
                            name: s['name'],
                            status: s['status'],
                            time: Helpers.formatTimestamp(
                                s['timestamp'] ?? ''),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
