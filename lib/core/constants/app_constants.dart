/// Global constants for the TryFit application.
class AppConstants {
  AppConstants._();

  static const String appName = 'TryFit';
  static const String appTagline =
      'AI Virtual Try-On & Personal Fashion Studio';
  static const String appVersion = '1.0.0';

  /// Truthful simulation disclosure required by PRD and AGENTS.md
  static const String simulationDisclaimer =
      'Generated output is an AI visual simulation. It does not determine exact garment size, real-world fit, fabric drape, or physical comfort.';

  static const String simulationBadgeText = 'AI Fit';
  static const String demoBadgeText = 'AI Studio';

  // Image Upload Constraints
  static const int maxImageBytes = 15 * 1024 * 1024; // 15 MB
  static const int minImageBytes = 10 * 1024; // 10 KB
  static const int minDimensionPixels = 256;
  static const int maxDimensionPixels = 4096;

  static const List<String> supportedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];
  static const List<String> supportedMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
  ];

  // Default Backend URL
  static const String defaultApiBaseUrl = 'http://127.0.0.1:8000/api/v1';
}
