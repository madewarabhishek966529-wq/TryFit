import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tryfit/core/utils/image_validator.dart';

void main() {
  group('ImageValidator (FR-010, FR-011, FR-012)', () {
    test('validates valid JPEG binary signature', () {
      final validJpeg = Uint8List.fromList([
        0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
        ...List.filled(15 * 1024, 0x00), // 15 KB
      ]);

      final result = ImageValidator.validateImageBytes(validJpeg);
      expect(result.isValid, isTrue);
      expect(result.detectedFormat, equals('image/jpeg'));
    });

    test('validates valid PNG binary signature', () {
      final validPng = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        ...List.filled(15 * 1024, 0x00), // 15 KB
      ]);

      final result = ImageValidator.validateImageBytes(validPng);
      expect(result.isValid, isTrue);
      expect(result.detectedFormat, equals('image/png'));
    });

    test('validates valid WebP binary signature', () {
      final validWebp = Uint8List.fromList([
        0x52, 0x49, 0x46, 0x46, 0x00, 0x00, 0x00, 0x00,
        0x57, 0x45, 0x42, 0x50, 0x00, 0x00,
        ...List.filled(15 * 1024, 0x00), // 15 KB
      ]);

      final result = ImageValidator.validateImageBytes(validWebp);
      expect(result.isValid, isTrue);
      expect(result.detectedFormat, equals('image/webp'));
    });

    test('rejects empty byte array', () {
      final empty = Uint8List(0);
      final result = ImageValidator.validateImageBytes(empty);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('empty'));
    });

    test('rejects file smaller than minimum required bytes (10 KB)', () {
      final tooSmall = Uint8List.fromList([
        0xFF,
        0xD8,
        0xFF,
        0xE0,
        0x00,
        0x10,
        ...List.filled(500, 0x00),
      ]);

      final result = ImageValidator.validateImageBytes(tooSmall);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('too small'));
    });

    test('rejects corrupted / unsupported binary signature', () {
      final fakeExecutable = Uint8List.fromList([
        0x4D,
        0x5A,
        0x90,
        0x00,
        0x03,
        0x00,
        0x00,
        0x00,
        ...List.filled(20 * 1024, 0x00),
      ]);

      final result = ImageValidator.validateImageBytes(fakeExecutable);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('Unsupported or corrupted'));
    });
  });
}
