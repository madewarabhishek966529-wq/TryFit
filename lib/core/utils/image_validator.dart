import 'dart:typed_data';

import '../constants/app_constants.dart';

class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final String? detectedFormat;

  const ValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.detectedFormat,
  });

  factory ValidationResult.success(String format) =>
      ValidationResult._(isValid: true, detectedFormat: format);

  factory ValidationResult.failure(String message) =>
      ValidationResult._(isValid: false, errorMessage: message);
}

/// Image validator enforcing FR-010, FR-011, and FR-012.
/// Inspects raw magic bytes to verify genuine JPEG, PNG, and WebP formats
/// rather than relying solely on file extensions or untrusted headers.
class ImageValidator {
  ImageValidator._();

  /// Validates raw byte content for size, non-emptiness, and valid binary signatures.
  static ValidationResult validateImageBytes(Uint8List bytes) {
    if (bytes.isEmpty) {
      return ValidationResult.failure(
        'Image file is empty. Please select a valid photo.',
      );
    }

    if (bytes.lengthInBytes < AppConstants.minImageBytes) {
      return ValidationResult.failure(
        'Image is too small (${(bytes.lengthInBytes / 1024).toStringAsFixed(1)} KB). Minimum allowed size is 10 KB for high fidelity.',
      );
    }

    if (bytes.lengthInBytes > AppConstants.maxImageBytes) {
      final mb = (bytes.lengthInBytes / (1024 * 1024)).toStringAsFixed(1);
      return ValidationResult.failure(
        'Image file is too large ($mb MB). Please select an image under 15 MB.',
      );
    }

    // Inspect binary signatures
    final format = detectImageFormat(bytes);
    if (format == null) {
      return ValidationResult.failure(
        'Unsupported or corrupted image format. Please supply a valid JPEG, PNG, or WebP image.',
      );
    }

    return ValidationResult.success(format);
  }

  /// Detects image format from binary magic bytes.
  static String? detectImageFormat(Uint8List bytes) {
    if (bytes.length < 12) return null;

    // JPEG signature: FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'image/jpeg';
    }

    // PNG signature: 89 50 4E 47 0D 0A 1A 0A
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return 'image/png';
    }

    // WebP signature: "RIFF" .... "WEBP"
    if (bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }

    return null;
  }
}
