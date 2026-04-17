import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../utils/theme.dart';
import '../../utils/helpers.dart';

class SyncStatusScreen extends StatelessWidget {
  const SyncStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sync = Provider.of<SyncProvider>(context);
    final connectivity = Provider.of<ConnectivityProvider>(context);

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
              Text('Sync Status', style: AppTheme.headingLarge),
              const SizedBox(height: 4),
              Text('Manage offline data sync', style: AppTheme.bodyMedium),
              const SizedBox(height: 28),

              // Connection status card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glassCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Connection', style: AppTheme.headingSmall),
                    const SizedBox(height: 16),
                    _connectionRow(
                      'Internet',
                      connectivity.isOnline,
                      Icons.cloud_rounded,
                    ),
                    const SizedBox(height: 12),
                    _connectionRow(
                      'Raspberry Pi',
                      connectivity.isPiReachable,
                      Icons.router_rounded,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => connectivity.refresh(),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Refresh Connection'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.accentTeal,
                          side: const BorderSide(color: AppTheme.accentTeal),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sync info card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glassCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data Sync', style: AppTheme.headingSmall),
                    const SizedBox(height: 16),

                    _infoRow('Pending records', '${sync.pendingCount}',
                        sync.hasPending ? AppTheme.warningYellow : AppTheme.successGreen),
                    const SizedBox(height: 10),
                    _infoRow(
                      'Last sync',
                      sync.lastSyncTime != null
                          ? Helpers.formatDateTime(sync.lastSyncTime!)
                          : 'Never',
                      AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 10),
                    _infoRow(
                      'Last synced',
                      '${sync.lastSyncCount} record(s)',
                      AppTheme.textSecondary,
                    ),

                    if (sync.message.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _syncStatusColor(sync.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          sync.message,
                          style: AppTheme.bodyMedium.copyWith(
                            color: _syncStatusColor(sync.status),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Sync button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: sync.status == SyncStatus.syncing
                            ? null
                            : () => sync.syncNow(),
                        icon: sync.status == SyncStatus.syncing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.cloud_upload_rounded),
                        label: Text(
                          sync.status == SyncStatus.syncing
                              ? 'Syncing...'
                              : 'Sync Now',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Auto-sync info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.accentTeal.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_mode_rounded,
                        color: AppTheme.accentTeal, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Auto-sync runs every 2 minutes when internet is available.',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.accentTeal,
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

  Widget _connectionRow(String label, bool connected, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (connected ? AppTheme.successGreen : AppTheme.errorRed)
                .withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: connected ? AppTheme.successGreen : AppTheme.errorRed,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTheme.bodyLarge)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: (connected ? AppTheme.successGreen : AppTheme.errorRed)
                .withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            connected ? 'Connected' : 'Disconnected',
            style: AppTheme.labelStyle.copyWith(
              color: connected ? AppTheme.successGreen : AppTheme.errorRed,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.bodyMedium),
        Text(
          value,
          style: AppTheme.bodyLarge.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _syncStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return AppTheme.accentTeal;
      case SyncStatus.success:
        return AppTheme.successGreen;
      case SyncStatus.error:
        return AppTheme.errorRed;
      default:
        return AppTheme.textSecondary;
    }
  }
}
