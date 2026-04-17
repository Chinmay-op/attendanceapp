import 'package:flutter/material.dart';
import '../utils/theme.dart';

class StudentTile extends StatelessWidget {
  final String name;
  final String? uid;
  final String status;
  final String time;
  final bool showActions;
  final VoidCallback? onToggle;

  const StudentTile({
    super.key,
    required this.name,
    this.uid,
    required this.status,
    required this.time,
    this.showActions = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isPresent = status.toLowerCase() == 'present';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPresent
              ? AppTheme.successGreen.withOpacity(0.2)
              : AppTheme.errorRed.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info
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
                const SizedBox(height: 2),
                Text(
                  time,
                  style: AppTheme.labelStyle,
                ),
              ],
            ),
          ),

          // Status or action
          if (showActions)
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isPresent
                      ? AppTheme.successGreen.withOpacity(0.15)
                      : AppTheme.errorRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isPresent
                        ? AppTheme.successGreen.withOpacity(0.4)
                        : AppTheme.errorRed.withOpacity(0.4),
                  ),
                ),
                child: Text(
                  isPresent ? 'P' : 'A',
                  style: TextStyle(
                    color: isPresent ? AppTheme.successGreen : AppTheme.errorRed,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            Icon(
              isPresent ? Icons.check_circle : Icons.cancel,
              color: isPresent ? AppTheme.successGreen : AppTheme.errorRed,
              size: 24,
            ),
        ],
      ),
    );
  }
}
