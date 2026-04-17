import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/local_storage_service.dart';
import '../../models/attendance_model.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../widgets/attendance_card.dart';
import 'edit_attendance_screen.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  List<AttendanceRecord> _records = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRecords());
  }

  void _loadRecords() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final localStorage =
        Provider.of<LocalStorageService>(context, listen: false);
    if (auth.user != null) {
      setState(() {
        _records = localStorage.getRecordsByDate(
          auth.user!.classId,
          Helpers.formatDate(_selectedDate),
        );
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: AppTheme.darkTheme.copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentPurple,
              surface: AppTheme.cardDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = _records.where((r) => r.status == 'present').length;
    final absentCount = _records.where((r) => r.status == 'absent').length;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Attendance History',
                        style: AppTheme.headingLarge),
                    const SizedBox(height: 16),

                    // Date picker
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: AppTheme.glassCard,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    color: AppTheme.accentPurple, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  Helpers.formatDisplayDate(_selectedDate),
                                  style: AppTheme.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppTheme.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Summary
                    Row(
                      children: [
                        _summaryChip('$presentCount Present',
                            AppTheme.successGreen),
                        const SizedBox(width: 8),
                        _summaryChip('$absentCount Absent',
                            AppTheme.errorRed),
                        const SizedBox(width: 8),
                        _summaryChip('${_records.length} Total',
                            AppTheme.accentPurple),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white10),

              // Records list
              Expanded(
                child: _records.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_rounded,
                                size: 56,
                                color: AppTheme.textSecondary
                                    .withOpacity(0.4)),
                            const SizedBox(height: 12),
                            Text(
                              'No records for this date',
                              style: AppTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _records.length,
                        itemBuilder: (context, index) {
                          final r = _records[index];
                          return AttendanceCard(
                            name: r.name,
                            status: r.status,
                            time: Helpers.formatTimestamp(r.timestamp),
                            subtitle: 'via ${r.markedVia}',
                            onTap: () => _showEditDialog(r),
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

  Widget _summaryChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTheme.labelStyle.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  void _showEditDialog(AttendanceRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAttendanceScreen(
          classId: record.classId,
          date: record.date,
        ),
      ),
    );
  }
}
