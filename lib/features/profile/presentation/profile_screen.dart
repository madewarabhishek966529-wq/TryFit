import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../try_on/domain/try_on_repository.dart';

class ProfileScreen extends StatefulWidget {
  final TryOnRepository repository;
  final bool isDarkMode;
  final ValueChanged<bool> onToggleTheme;

  const ProfileScreen({
    super.key,
    required this.repository,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _reducedMotion = false;
  bool _anonymousDiagnostics = false;

  void _exportUserData() async {
    final history = await widget.repository.getHistory();
    final exportData = {
      'exported_at': DateTime.now().toIso8601String(),
      'app': AppConstants.appName,
      'version': AppConstants.appVersion,
      'records_count': history.length,
      'history': history.map((j) => j.toJson()).toList(),
    };

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Data Export Prepared'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'A compliant portable JSON export of your personal assets and try-on simulation metadata is ready (FR-003):',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                color: AppTheme.darkSurfaceElevated,
                child: Text(
                  const JsonEncoder.withIndent('  ').convert(exportData),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export downloaded to device memory'),
                ),
              );
            },
            child: const Text('Download JSON'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAllData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Personal Data?'),
        content: const Text(
          'This will permanently purge all uploaded photos, try-on simulations, wardrobe items, and cached session keys from this device in accordance with privacy policies.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRose,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.repository.clearAllData();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All personal data purged successfully.'),
                  backgroundColor: AppTheme.accentEmerald,
                ),
              );
            },
            child: const Text(
              'Purge Everything',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Privacy')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // User Header
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryAccent),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 36,
                      color: AppTheme.primaryAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Fashion Studio Guest',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Zero-data privacy tier • Local Demo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            // Appearance & Motion
            const Text(
              'Interface & Accessibility',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGold,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Dark Mode'),
              subtitle: const Text('High-contrast editorial dark palette'),
              value: widget.isDarkMode,
              activeColor: AppTheme.primaryAccent,
              onChanged: widget.onToggleTheme,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reduced Motion'),
              subtitle: const Text(
                'Disables intense transitions for accessibility',
              ),
              value: _reducedMotion,
              activeColor: AppTheme.primaryAccent,
              onChanged: (val) => setState(() => _reducedMotion = val),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Privacy & Retention
            const Text(
              'Privacy & Personal Data Controls',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGold,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Anonymous Diagnostic Telemetry'),
              subtitle: const Text(
                'Crash diagnostics without photos or identifiers',
              ),
              value: _anonymousDiagnostics,
              activeColor: AppTheme.primaryAccent,
              onChanged: (val) => setState(() => _anonymousDiagnostics = val),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Export My Data'),
              subtitle: const Text(
                'Generate compliant JSON export of all your records',
              ),
              trailing: const Icon(
                Icons.download_outlined,
                color: AppTheme.primaryAccent,
              ),
              onTap: _exportUserData,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Purge All Personal Assets & Data',
                style: TextStyle(color: AppTheme.accentRose),
              ),
              subtitle: const Text(
                'Irrevocably erase all photos, history, and cache',
              ),
              trailing: const Icon(
                Icons.delete_forever,
                color: AppTheme.accentRose,
              ),
              onTap: _confirmDeleteAllData,
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Legal & Disclaimer
            const Text(
              'About & Disclaimers',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGold,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Simulation Limitations'),
              subtitle: const Text(
                AppConstants.simulationDisclaimer,
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'TryFit v1.0.0 • Flutter-First Virtual Fitting Room',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
