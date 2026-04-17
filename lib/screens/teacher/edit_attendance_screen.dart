import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/local_storage_service.dart';
import '../../services/firestore_service.dart';
import '../../models/attendance_model.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';
import '../../utils/constants.dart';
import '../../widgets/student_tile.dart';

class EditAttendanceScreen extends StatefulWidget {
  final String classId;
  final String date;

  const EditAttendanceScreen({
    super.key,
    required this.classId,
    required this.date,
  });

  @override
  State<EditAttendanceScreen> createState() => _EditAttendanceScreenState();
}

class _EditAttendanceScreenState extends State<EditAttendanceScreen> {
  List<AttendanceRecord> _records = [];
  final Map<String, String> _editedStatuses = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    final localStorage =
        Provider.of<LocalStorageService>(context, listen: false);
    setState(() {
      _records = localStorage.getRecordsByDate(widget.classId, widget.date);
      for (final r in _records) {
        _editedStatuses[r.uid] = r.status;
      }
    });
  }

  void _toggleStatus(String uid) {
    setState(() {
      _editedStatuses[uid] = _editedStatuses[uid] == AppConstants.statusPresent
          ? AppConstants.statusAbsent
          : AppConstants.statusPresent;
    });
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    final localStorage =
        Provider.of<LocalStorageService>(context, listen: false);
    final firestoreService = FirestoreService();

    try {
      for (final record in _records) {
        final newStatus = _editedStatuses[record.uid]!;
        if (newStatus != record.status) {
          // Create updated record
          final updated = AttendanceRecord(
            uid: record.uid,
            name: record.name,
            classId: record.classId,
            date: record.date,
            timestamp: record.timestamp,
            status: newStatus,
            markedVia: AppConstants.markManual,
            isSynced: false,
          );

          // Save to local
          await localStorage.saveAttendance(updated);

          // Try to update Firestore
          try {
            await firestoreService.updateAttendanceStatus(
              record.classId,
              record.date,
              record.uid,
              newStatus,
            );
            await localStorage.markAsSynced(updated.key);
          } catch (e) {
            print('Firestore update failed, will sync later: $e');
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Attendance updated successfully!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final hasChanges = _records.any(
        (r) => _editedStatuses[r.uid] != r.status);

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
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: AppTheme.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Edit Attendance',
                              style: AppTheme.headingSmall),
                          Text(
                            '${widget.classId} • ${Helpers.formatDisplayDate(DateTime.parse(widget.date))}',
                            style: AppTheme.labelStyle,
                          ),
                        ],
                      ),
                    ),
                    if (hasChanges)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.warningYellow.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Unsaved',
                          style: AppTheme.labelStyle.copyWith(
                            color: AppTheme.warningYellow,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.accentTeal.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppTheme.accentTeal, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Tap on P/A to toggle attendance status',
                          style: AppTheme.labelStyle.copyWith(
                            color: AppTheme.accentTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: Colors.white10),

              // Student list
              Expanded(
                child: _records.isEmpty
                    ? Center(
                        child: Text('No records to edit',
                            style: AppTheme.bodyMedium),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _records.length,
                        itemBuilder: (context, index) {
                          final r = _records[index];
                          final status = _editedStatuses[r.uid] ?? r.status;
                          return StudentTile(
                            name: r.name,
                            uid: r.uid,
                            status: status,
                            time: Helpers.formatTimestamp(r.timestamp),
                            showActions: true,
                            onToggle: () => _toggleStatus(r.uid),
                          );
                        },
                      ),
              ),

              // Save button
              if (_records.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          hasChanges && !_isSaving ? _saveChanges : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentPurple,
                        disabledBackgroundColor:
                            AppTheme.accentPurple.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
