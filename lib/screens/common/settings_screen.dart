import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../services/local_storage_service.dart';
import '../../services/pi_api_service.dart';
import '../../utils/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _piUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final localStorage =
        Provider.of<LocalStorageService>(context, listen: false);
    _piUrlController.text = localStorage.getPiBaseUrl();
  }

  @override
  void dispose() {
    _piUrlController.dispose();
    super.dispose();
  }

  Future<void> _savePiUrl() async {
    final url = _piUrlController.text.trim();
    if (url.isEmpty) return;

    final localStorage =
        Provider.of<LocalStorageService>(context, listen: false);
    final piApi = Provider.of<PiApiService>(context, listen: false);

    await localStorage.setPiBaseUrl(url);
    piApi.setBaseUrl(url);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pi URL updated!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }

    // Recheck connection
    Provider.of<ConnectivityProvider>(context, listen: false)
        .checkPiConnection();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Provider.of<AuthProvider>(context, listen: false).signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

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
              Text('Settings', style: AppTheme.headingLarge),
              const SizedBox(height: 24),

              // Profile card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glassCard,
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          user?.name.isNotEmpty == true
                              ? user!.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'User',
                            style: AppTheme.headingSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(user?.email ?? '', style: AppTheme.bodyMedium),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.accentPurple.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  (user?.role ?? 'student').toUpperCase(),
                                  style: AppTheme.labelStyle.copyWith(
                                    color: AppTheme.accentPurple,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentTeal.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  user?.classId ?? '',
                                  style: AppTheme.labelStyle.copyWith(
                                    color: AppTheme.accentTeal,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Pi Configuration
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glassCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.router_rounded,
                            color: AppTheme.accentTeal, size: 22),
                        const SizedBox(width: 10),
                        Text('Raspberry Pi Config',
                            style: AppTheme.headingSmall),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _piUrlController,
                      style: AppTheme.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Pi Server URL',
                        hintText: 'http://192.168.4.1:5000',
                        prefixIcon: Icon(Icons.link_rounded,
                            color: AppTheme.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _savePiUrl,
                        child: const Text('Save URL'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sync status link
              _settingsTile(
                icon: Icons.sync_rounded,
                title: 'Sync Status',
                subtitle: 'View and manage data sync',
                color: AppTheme.accentPurple,
                onTap: () => Navigator.pushNamed(context, '/sync_status'),
              ),
              const SizedBox(height: 10),

              // About
              _settingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About',
                subtitle: 'AttendEase v1.0.0',
                color: AppTheme.accentTeal,
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'AttendEase',
                    applicationVersion: '1.0.0',
                    applicationLegalese:
                        '© 2026 Offline Biometric Attendance System',
                  );
                },
              ),
              const SizedBox(height: 24),

              // Logout
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.errorRed,
                    side: const BorderSide(color: AppTheme.errorRed),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.glassCard,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTheme.bodyLarge
                          .copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: AppTheme.labelStyle),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
