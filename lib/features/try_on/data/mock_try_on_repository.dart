import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import '../../../core/models/asset.dart';
import '../../../core/models/garment_category.dart';
import '../../../core/models/job_status.dart';
import '../../../core/utils/image_validator.dart';
import '../domain/try_on_models.dart';
import '../domain/try_on_repository.dart';
import 'mock_data_fixtures.dart';

/// In-memory deterministic mock repository implementing TryOnRepository.
/// Designed for reliable testing and zero-cost guest demonstration (ADR-002).
class MockTryOnRepository implements TryOnRepository {
  static final MockTryOnRepository _instance = MockTryOnRepository._internal();
  factory MockTryOnRepository() => _instance;

  final _uuid = const Uuid();
  final Map<String, TryOnJob> _jobs = {};
  final Map<String, Asset> _assets = {};
  final Map<String, String> _idempotencyIndex = {};

  MockTryOnRepository._internal() {
    _seedInitialHistory();
  }

  void _seedInitialHistory() {
    final defaultModel = MockDataFixtures.sampleModels[0];
    final defaultGarment = MockDataFixtures.sampleGarments[1]; // Emerald dress

    final personAsset = defaultModel.toAsset();
    final garmentAsset = defaultGarment.toAsset();
    final resultAsset = Asset(
      id: 'res-seed-1',
      purpose: AssetPurpose.result,
      uri: MockDataFixtures.fallbackResultImage,
      fileName: 'tryon_simulation_demo.jpg',
      mimeType: 'image/jpeg',
      byteSize: 1024 * 420,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    );

    final seedJob = TryOnJob(
      id: 'job-seed-001',
      personAsset: personAsset,
      garmentAsset: garmentAsset,
      category: GarmentCategory.dresses,
      status: JobStatus.succeeded,
      progressMessage: 'Deterministic demo simulation complete',
      resultAsset: resultAsset,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      completedAt: DateTime.now().subtract(
        const Duration(hours: 2, seconds: -8),
      ),
      modelVersion: 'TryFit-MockEngine-v1.0 (DEMO)',
      isDemo: true,
    );

    _assets[personAsset.id] = personAsset;
    _assets[garmentAsset.id] = garmentAsset;
    _assets[resultAsset.id] = resultAsset;
    _jobs[seedJob.id] = seedJob;
  }

  @override
  Future<Asset> uploadPersonImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final validation = ImageValidator.validateImageBytes(bytes);
    if (!validation.isValid) {
      throw ArgumentError(validation.errorMessage);
    }

    final id = _uuid.v4();
    final asset = Asset(
      id: id,
      purpose: AssetPurpose.person,
      uri: 'memory://$id',
      bytes: bytes,
      fileName: fileName,
      mimeType: validation.detectedFormat ?? 'image/jpeg',
      byteSize: bytes.lengthInBytes,
      createdAt: DateTime.now(),
    );

    _assets[id] = asset;
    return asset;
  }

  @override
  Future<Asset> uploadGarmentImage({
    required Uint8List bytes,
    required String fileName,
    required GarmentCategory category,
  }) async {
    final validation = ImageValidator.validateImageBytes(bytes);
    if (!validation.isValid) {
      throw ArgumentError(validation.errorMessage);
    }

    final id = _uuid.v4();
    final asset = Asset(
      id: id,
      purpose: AssetPurpose.garment,
      uri: 'memory://$id',
      bytes: bytes,
      fileName: fileName,
      mimeType: validation.detectedFormat ?? 'image/jpeg',
      byteSize: bytes.lengthInBytes,
      createdAt: DateTime.now(),
    );

    _assets[id] = asset;
    return asset;
  }

  @override
  Future<TryOnJob> createJob({
    required Asset personAsset,
    required Asset garmentAsset,
    required GarmentCategory category,
    String? idempotencyKey,
  }) async {
    // Idempotency check (FR-025)
    if (idempotencyKey != null &&
        _idempotencyIndex.containsKey(idempotencyKey)) {
      final existingJobId = _idempotencyIndex[idempotencyKey]!;
      return _jobs[existingJobId]!;
    }

    final jobId = _uuid.v4();
    final job = TryOnJob(
      id: jobId,
      idempotencyKey: idempotencyKey,
      personAsset: personAsset,
      garmentAsset: garmentAsset,
      category: category,
      status: JobStatus.queued,
      progressMessage: 'Job queued for demo simulation...',
      createdAt: DateTime.now(),
      modelVersion: 'TryFit-MockEngine-v1.0 (DEMO)',
      isDemo: true,
    );

    _jobs[jobId] = job;
    if (idempotencyKey != null) {
      _idempotencyIndex[idempotencyKey] = jobId;
    }

    return job;
  }

  @override
  Future<TryOnJob> getJob(String jobId) async {
    final job = _jobs[jobId];
    if (job == null) {
      throw StateError('Job $jobId not found');
    }

    // Progress simulation states if still active
    if (job.status == JobStatus.queued) {
      final updated = job.copyWith(
        status: JobStatus.validating,
        progressMessage: 'Analyzing pose landmarks & garment mask...',
      );
      _jobs[jobId] = updated;
      return updated;
    } else if (job.status == JobStatus.validating) {
      final updated = job.copyWith(
        status: JobStatus.processing,
        progressMessage: 'Blending warp deformation & texture synthesis...',
      );
      _jobs[jobId] = updated;
      return updated;
    } else if (job.status == JobStatus.processing) {
      final resultAsset = Asset(
        id: _uuid.v4(),
        purpose: AssetPurpose.result,
        uri: MockDataFixtures.fallbackResultImage,
        fileName: 'simulation_${job.id}.jpg',
        mimeType: 'image/jpeg',
        byteSize: 1024 * 410,
        createdAt: DateTime.now(),
      );
      _assets[resultAsset.id] = resultAsset;

      final updated = job.copyWith(
        status: JobStatus.succeeded,
        progressMessage: 'Completed demo simulation',
        resultAsset: resultAsset,
        completedAt: DateTime.now(),
      );
      _jobs[jobId] = updated;
      return updated;
    }

    return job;
  }

  @override
  Future<TryOnJob> cancelJob(String jobId) async {
    final job = _jobs[jobId];
    if (job == null) {
      throw StateError('Job $jobId not found');
    }

    if (job.status.isTerminal) {
      return job;
    }

    final cancelled = job.copyWith(
      status: JobStatus.cancelled,
      progressMessage: 'Simulation was cancelled by user.',
      completedAt: DateTime.now(),
    );
    _jobs[jobId] = cancelled;
    return cancelled;
  }

  @override
  Future<List<TryOnJob>> getHistory({int limit = 20, String? cursor}) async {
    final list = _jobs.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.take(limit).toList();
  }

  @override
  Future<void> deleteAsset(String assetId) async {
    _assets.remove(assetId);
  }

  @override
  Future<void> deleteResult(String resultId) async {
    _jobs.removeWhere(
      (id, job) => job.id == resultId || job.resultAsset?.id == resultId,
    );
    _assets.remove(resultId);
  }

  @override
  Future<void> clearAllData() async {
    _jobs.clear();
    _assets.clear();
    _idempotencyIndex.clear();
  }
}
