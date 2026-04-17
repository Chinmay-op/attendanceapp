import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AttendanceCard extends StatelessWidget {
  final String name;
  final String status;
  final String time;
  final String? subtitle;
  final VoidCallback? onTap;

  const AttendanceCard({
    super.key,
    required this.name,
    required this.status,
    required this.time,
    this.subtitle,
    this.onTap,
  });

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'present':
        return AppTheme.successGreen;
      case 'absent':
        return AppTheme.errorRed;
      case 'holiday':
        return AppTheme.warningYellow;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'present':
        return Icons.check_circle_rounded;
      case 'absent':
        return Icons.cancel_rounded;
      case 'holiday':
        return Icons.event_rounded;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.glassCard,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(statusIcon, color: statusColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppTheme.labelStyle),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: AppTheme.statusBadge(statusColor),
                  child: Text(
                    status.toUpperCase(),
                    style: AppTheme.labelStyle.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(time, style: AppTheme.labelStyle.copyWith(fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
