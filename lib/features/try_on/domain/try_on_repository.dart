import 'dart:typed_data';

import '../../../core/models/asset.dart';
import '../../../core/models/garment_category.dart';
import 'try_on_models.dart';

/// Contract interface for TryFit Virtual Try-On data access.
abstract class TryOnRepository {
  /// Uploads or registers a validated person photo.
  Future<Asset> uploadPersonImage({
    required Uint8List bytes,
    required String fileName,
  });

  /// Uploads or registers a validated garment photo.
  Future<Asset> uploadGarmentImage({
    required Uint8List bytes,
    required String fileName,
    required GarmentCategory category,
  });

  /// Creates an asynchronous virtual try-on simulation job.
  Future<TryOnJob> createJob({
    required Asset personAsset,
    required Asset garmentAsset,
    required GarmentCategory category,
    String? idempotencyKey,
  });

  /// Fetches the latest job lifecycle state by ID.
  Future<TryOnJob> getJob(String jobId);

  /// Requests graceful cancellation of an active job.
  Future<TryOnJob> cancelJob(String jobId);

  /// Retrieves the history of simulation jobs (paginated).
  Future<List<TryOnJob>> getHistory({int limit = 20, String? cursor});

  /// Deletes a specific asset.
  Future<void> deleteAsset(String assetId);

  /// Deletes a specific try-on result and related job metadata.
  Future<void> deleteResult(String resultId);

  /// Clears all local demo caches, jobs, and history (privacy purge).
  Future<void> clearAllData();
}
