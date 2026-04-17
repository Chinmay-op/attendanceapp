import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/calendar_widget.dart';

class StudentCalendarScreen extends StatefulWidget {
  const StudentCalendarScreen({super.key});

  @override
  State<StudentCalendarScreen> createState() => _StudentCalendarScreenState();
}

class _StudentCalendarScreenState extends State<StudentCalendarScreen> {
  int _currentYear = DateTime.now().year;
  int _currentMonth = DateTime.now().month;
  Map<String, String> _monthlyData = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final attendance = Provider.of<AttendanceProvider>(context, listen: false);
    if (auth.user != null) {
      setState(() {
        _monthlyData = attendance.getMonthlyStatus(
          auth.user!.uid,
          auth.user!.classId,
          _currentYear,
          _currentMonth,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final attendance = Provider.of<AttendanceProvider>(context);
    final user = auth.user;

    if (user == null) return const SizedBox.shrink();

    final stats = attendance.getMonthlyStats(
        user.uid, user.classId, _currentYear, _currentMonth);

    final present = stats['present'] ?? 0;
    final total = stats['total'] ?? 0;
    final monthPct = Helpers.attendancePercentage(present, total);

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
              Text('Attendance Calendar', style: AppTheme.headingLarge),
              const SizedBox(height: 4),
              Text(user.classId, style: AppTheme.bodyMedium),
              const SizedBox(height: 24),

              // Calendar
              CalendarWidget(
                attendanceData: _monthlyData,
                onDayTap: (date) {
                  final dateStr = Helpers.formatDate(date);
                  final status = _monthlyData[dateStr];
                  if (status != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${Helpers.formatDisplayDate(date)}: ${status.toUpperCase()}',
                        ),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),

              // Monthly summary card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glassCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monthly Summary', style: AppTheme.headingSmall),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _summaryItem(
                          'Present',
                          '$present',
                          AppTheme.successGreen,
                        ),
                        _summaryItem(
                          'Absent',
                          '${stats['absent'] ?? 0}',
                          AppTheme.errorRed,
                        ),
                        _summaryItem(
                          'Percentage',
                          Helpers.percentageText(monthPct),
                          monthPct >= 75
                              ? AppTheme.successGreen
                              : AppTheme.warningYellow,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: total > 0 ? present / total : 0,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation(
                          monthPct >= 75
                              ? AppTheme.successGreen
                              : monthPct >= 50
                                  ? AppTheme.warningYellow
                                  : AppTheme.errorRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.headingMedium.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTheme.labelStyle),
        ],
      ),
    );
  }
}
