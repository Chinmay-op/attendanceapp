import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sync_provider.dart';
import '../providers/connectivity_provider.dart';
import '../utils/theme.dart';

class SyncIndicator extends StatelessWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ConnectivityProvider, SyncProvider>(
      builder: (context, connectivity, sync, _) {
        final isOnline = connectivity.isOnline;
        final isPi = connectivity.isPiReachable;
        final pending = sync.pendingCount;

        Color dotColor;
        String label;

        if (isOnline && isPi) {
          dotColor = AppTheme.successGreen;
          label = 'Online';
        } else if (isPi) {
          dotColor = AppTheme.warningYellow;
          label = 'Pi Only';
        } else if (isOnline) {
          dotColor = AppTheme.accentTeal;
          label = 'Online';
        } else {
          dotColor = AppTheme.errorRed;
          label = 'Offline';
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: dotColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: dotColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated dot
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dotColor.withOpacity(value),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: dotColor.withOpacity(0.4),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTheme.labelStyle.copyWith(
                  color: dotColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (pending > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppTheme.warningYellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$pending',
                    style: AppTheme.labelStyle.copyWith(
                      color: AppTheme.warningYellow,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
