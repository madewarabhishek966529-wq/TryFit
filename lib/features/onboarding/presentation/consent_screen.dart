import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/primary_button.dart';

class ConsentScreen extends StatefulWidget {
  final VoidCallback onConsentGranted;
  final VoidCallback onGuestModeSelected;

  const ConsentScreen({
    super.key,
    required this.onConsentGranted,
    required this.onGuestModeSelected,
  });

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _agreedToSimulation = true;
  bool _agreedToPhotoRights = true;
  bool _optInDiagnostics = false;

  bool get _canProceed => _agreedToSimulation && _agreedToPhotoRights;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & Consent'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: AppTheme.primaryAccent.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.shield_outlined,
                      color: AppTheme.primaryAccent,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your privacy and transparent image processing are our foundational commitment.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'How TryFit Handles Your Images',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),
              _buildPolicyItem(
                icon: Icons.hide_image_outlined,
                title: 'EXIF Metadata Stripping',
                body: 'All device location, camera specs, and EXIF tags are permanently scrubbed before transmission.',
              ),
              const SizedBox(height: 14),
              _buildPolicyItem(
                icon: Icons.lock_outline,
                title: 'Private & Scoped Storage',
                body: 'Your images are never exposed to public buckets or unauthorized users. They are encrypted in transit and at rest.',
              ),
              const SizedBox(height: 14),
              _buildPolicyItem(
                icon: Icons.no_accounts_outlined,
                title: 'No Model Training On Private Photos',
                body: 'Default policy prohibits using your personal photos to train generative AI foundation models.',
              ),
              const SizedBox(height: 14),
              _buildPolicyItem(
                icon: Icons.delete_outline,
                title: 'Right to Complete Deletion',
                body: 'You retain total control. You can delete individual photos, simulation results, or purge your entire account at any moment.',
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Required Confirmations',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _agreedToSimulation,
                activeColor: AppTheme.primaryAccent,
                title: const Text(
                  'I understand that generated try-ons are AI visual simulations and do not guarantee size, fabric drape, or physical fit.',
                  style: TextStyle(fontSize: 13, height: 1.3),
                ),
                onChanged: (val) =>
                    setState(() => _agreedToSimulation = val ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _agreedToPhotoRights,
                activeColor: AppTheme.primaryAccent,
                title: const Text(
                  'I confirm that I own or have permission to upload the photos I use.',
                  style: TextStyle(fontSize: 13, height: 1.3),
                ),
                onChanged: (val) =>
                    setState(() => _agreedToPhotoRights = val ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _optInDiagnostics,
                activeColor: AppTheme.primaryAccent,
                title: const Text(
                  'Optional: Allow anonymous performance diagnostics to improve app stability.',
                  style: TextStyle(fontSize: 13, height: 1.3),
                ),
                onChanged: (val) =>
                    setState(() => _optInDiagnostics = val ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Accept & Enter Studio',
                  onPressed: _canProceed ? widget.onConsentGranted : null,
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Explore as Guest (Bundled Demo Assets)',
                  onPressed: widget.onGuestModeSelected,
                  isSecondary: true,
                  icon: Icons.explore_outlined,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyItem({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.darkSurfaceElevated,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(icon, size: 20, color: AppTheme.primaryGold),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
