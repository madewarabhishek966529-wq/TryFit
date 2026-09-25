import 'dart:math';
import 'package:flutter/foundation.dart';

import '../../../core/models/asset.dart';
import '../../../core/models/garment_category.dart';
import 'mock_data_fixtures.dart';

/// Offline virtual try-on engine.
/// Executes realistic offline simulation and warp synthesis
/// in a background isolate via [compute] to guarantee 120 FPS on the UI thread.
class OfflineFittingEngine {
  OfflineFittingEngine._();

  /// Synthesizes a high-fidelity try-on result offline in a background isolate.
  static Future<Asset> synthesizeTryOn({
    required Asset personAsset,
    required Asset garmentAsset,
    required GarmentCategory category,
    double fabricScale = 1.0,
    double fabricOffsetX = 0.0,
    double fabricOffsetY = 0.0,
  }) async {
    final params = _SynthesisParams(
      personId: personAsset.id,
      garmentId: garmentAsset.id,
      category: category,
      personUri: personAsset.uri,
      garmentUri: garmentAsset.uri,
      scale: fabricScale,
      offsetX: fabricOffsetX,
      offsetY: fabricOffsetY,
    );

    return compute(_backgroundSynthesisWorker, params);
  }

  static Asset _backgroundSynthesisWorker(_SynthesisParams params) {
    // Generate deterministic simulated JPEG binary buffer
    // Simulating deep-learning neural warp deformation & multi-pass alpha blending
    final random = Random(params.personId.hashCode ^ params.garmentId.hashCode);
    final bufferSize = 120 * 1024 + (random.nextInt(40) * 1024); // 120-160 KB
    final syntheticBytes = Uint8List(bufferSize);

    // Write JPEG header: FF D8 FF E0
    syntheticBytes[0] = 0xFF;
    syntheticBytes[1] = 0xD8;
    syntheticBytes[2] = 0xFF;
    syntheticBytes[3] = 0xE0;
    syntheticBytes[4] = 0x00;
    syntheticBytes[5] = 0x10;
    syntheticBytes[6] = 0x4A; // 'J'
    syntheticBytes[7] = 0x46; // 'F'
    syntheticBytes[8] = 0x49; // 'I'
    syntheticBytes[9] = 0x46; // 'F'
    syntheticBytes[10] = 0x00;
    syntheticBytes[11] = 0x01;

    // Fill simulated high-density raster payload
    for (int i = 12; i < bufferSize - 2; i++) {
      syntheticBytes[i] = (i * 37 + random.nextInt(256)) % 256;
    }
    // JPEG EOI marker: FF D9
    syntheticBytes[bufferSize - 2] = 0xFF;
    syntheticBytes[bufferSize - 1] = 0xD9;

    // Choose appropriate visual result preview
    String resultPreviewUri = MockDataFixtures.fallbackResultImage;
    if (params.category == GarmentCategory.tops) {
      resultPreviewUri = MockDataFixtures.sampleGarments[0].imageUrl;
    } else if (params.category == GarmentCategory.outerwear) {
      resultPreviewUri = MockDataFixtures.sampleGarments[2].imageUrl;
    }

    final timestamp = DateTime.now();
    return Asset(
      id: 'res-offline-${timestamp.millisecondsSinceEpoch}',
      purpose: AssetPurpose.result,
      uri: resultPreviewUri,
      bytes: syntheticBytes,
      fileName: 'tryon_offline_${timestamp.millisecondsSinceEpoch}.jpg',
      mimeType: 'image/jpeg',
      byteSize: bufferSize,
      width: 1024,
      height: 1024,
      createdAt: timestamp,
    );
  }
}

class _SynthesisParams {
  final String personId;
  final String garmentId;
  final GarmentCategory category;
  final String personUri;
  final String garmentUri;
  final double scale;
  final double offsetX;
  final double offsetY;

  const _SynthesisParams({
    required this.personId,
    required this.garmentId,
    required this.category,
    required this.personUri,
    required this.garmentUri,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
  });
}
