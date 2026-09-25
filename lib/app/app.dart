import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../features/onboarding/presentation/consent_screen.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../features/try_on/data/mock_try_on_repository.dart';
import '../features/try_on/domain/try_on_repository.dart';
import 'shell.dart';

class TryFitApp extends StatefulWidget {
  final TryOnRepository? repository;
  final bool startAtStudio;

  const TryFitApp({super.key, this.repository, this.startAtStudio = false});

  @override
  State<TryFitApp> createState() => _TryFitAppState();
}

class _TryFitAppState extends State<TryFitApp> {
  late final TryOnRepository _repository;
  bool _isDarkMode = true;
  bool _hasCompletedOnboarding = false;
  bool _showingConsent = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? MockTryOnRepository();
    if (widget.startAtStudio) {
      _hasCompletedOnboarding = true;
    }
  }

  void _handleToggleTheme(bool isDark) {
    setState(() => _isDarkMode = isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_hasCompletedOnboarding) {
      return MainShell(
        repository: _repository,
        isDarkMode: _isDarkMode,
        onToggleTheme: _handleToggleTheme,
      );
    }

    if (_showingConsent) {
      return ConsentScreen(
        onConsentGranted: () {
          setState(() {
            _hasCompletedOnboarding = true;
            _showingConsent = false;
          });
        },
        onGuestModeSelected: () {
          setState(() {
            _hasCompletedOnboarding = true;
            _showingConsent = false;
          });
        },
      );
    }

    return OnboardingScreen(
      onGetStarted: () {
        setState(() => _showingConsent = true);
      },
      onSkipToDemo: () {
        setState(() => _hasCompletedOnboarding = true);
      },
    );
  }
}
