import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/sync_provider.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/sync_indicator.dart';
import '../../widgets/attendance_card.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final attendance = Provider.of<AttendanceProvider>(context, listen: false);
    if (auth.user != null) {
      attendance.loadTodayRecords(auth.user!.classId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final attendance = Provider.of<AttendanceProvider>(context);
    final user = auth.user;

    if (user == null) return const SizedBox.shrink();

    final percentage = attendance.getStudentPercentage(user.uid, user.classId);
    final now = DateTime.now();
    final monthStats =
        attendance.getMonthlyStats(user.uid, user.classId, now.year, now.month);
    final todayMarked = attendance.isTodayMarked(user.uid, user.classId);
    final records = attendance.getStudentRecords(user.uid);
    final recentRecords = records.length > 5 ? records.sublist(records.length - 5) : records;

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
          child: RefreshIndicator(
            onRefresh: () async => _loadData(),
            color: AppTheme.accentPurple,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Helpers.greetingMessage(),
                          style: AppTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.name,
                          style: AppTheme.headingLarge,
                        ),
                      ],
                    ),
                    const SyncIndicator(),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${user.classId} • ${Helpers.formatDisplayDate(DateTime.now())}',
                  style: AppTheme.labelStyle,
                ),
                const SizedBox(height: 24),

                // Attendance percentage hero card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.headerGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentPurple.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Circular percentage
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 90,
                              height: 90,
                              child: CircularProgressIndicator(
                                value: percentage / 100,
                                strokeWidth: 8,
                                backgroundColor: Colors.white.withOpacity(0.15),
                                valueColor: AlwaysStoppedAnimation(
                                  percentage >= 75
                                      ? AppTheme.successGreen
                                      : percentage >= 50
                                          ? AppTheme.warningYellow
                                          : AppTheme.errorRed,
                                ),
                              ),
                            ),
                            Text(
                              Helpers.percentageText(percentage),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Overall Attendance',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              todayMarked
                                  ? '✅ Marked Today'
                                  : '⚠️ Not Marked Yet',
                              style: TextStyle(
                                color: todayMarked
                                    ? AppTheme.successGreen
                                    : AppTheme.warningYellow,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${records.length} total records',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Present',
                        value: '${monthStats['present'] ?? 0}',
                        icon: Icons.check_circle_rounded,
                        color: AppTheme.successGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'Absent',
                        value: '${monthStats['absent'] ?? 0}',
                        icon: Icons.cancel_rounded,
                        color: AppTheme.errorRed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'This Month',
                        value: '${monthStats['total'] ?? 0}',
                        icon: Icons.calendar_today_rounded,
                        color: AppTheme.accentTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Recent records
                Text('Recent Activity', style: AppTheme.headingSmall),
                const SizedBox(height: 12),

                if (recentRecords.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: AppTheme.glassCard,
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.history_rounded,
                              size: 48, color: AppTheme.textSecondary.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          Text('No records yet', style: AppTheme.bodyMedium),
                        ],
                      ),
                    ),
                  )
                else
                  ...recentRecords.reversed.map((r) => AttendanceCard(
                        name: Helpers.formatDisplayDate(DateTime.parse(r.date)),
                        status: r.status,
                        time: Helpers.formatTimestamp(r.timestamp),
                        subtitle: r.markedVia,
                      )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
