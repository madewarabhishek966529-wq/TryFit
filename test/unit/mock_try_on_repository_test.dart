import 'package:flutter_test/flutter_test.dart';
import 'package:tryfit/core/models/garment_category.dart';
import 'package:tryfit/core/models/job_status.dart';
import 'package:tryfit/features/try_on/data/mock_data_fixtures.dart';
import 'package:tryfit/features/try_on/data/mock_try_on_repository.dart';

void main() {
  group('MockTryOnRepository', () {
    late MockTryOnRepository repository;

    setUp(() {
      repository = MockTryOnRepository();
    });

    test('creates job in queued status for real-world simulation', () async {
      final personAsset = MockDataFixtures.sampleModels[0].toAsset();
      final garmentAsset = MockDataFixtures.sampleGarments[0].toAsset();

      final job = await repository.createJob(
        personAsset: personAsset,
        garmentAsset: garmentAsset,
        category: GarmentCategory.outerwear,
      );

      expect(job.id, isNotEmpty);
      expect(job.status, equals(JobStatus.queued));
      expect(job.isDemo, isFalse);
      expect(job.category, equals(GarmentCategory.outerwear));
    });

    test('enforces idempotency on duplicate key submissions', () async {
      final personAsset = MockDataFixtures.sampleModels[0].toAsset();
      final garmentAsset = MockDataFixtures.sampleGarments[0].toAsset();

      const key = 'test-idempotency-key-123';
      final job1 = await repository.createJob(
        personAsset: personAsset,
        garmentAsset: garmentAsset,
        category: GarmentCategory.outerwear,
        idempotencyKey: key,
      );

      final job2 = await repository.createJob(
        personAsset: personAsset,
        garmentAsset: garmentAsset,
        category: GarmentCategory.outerwear,
        idempotencyKey: key,
      );

      expect(job1.id, equals(job2.id));
    });

    test('advances job through lifecycle to succeeded', () async {
      final personAsset = MockDataFixtures.sampleModels[0].toAsset();
      final garmentAsset = MockDataFixtures.sampleGarments[0].toAsset();

      final initial = await repository.createJob(
        personAsset: personAsset,
        garmentAsset: garmentAsset,
        category: GarmentCategory.outerwear,
      );

      // Step 1: validates
      final step1 = await repository.getJob(initial.id);
      expect(step1.status, equals(JobStatus.validating));

      // Step 2: processes
      final step2 = await repository.getJob(initial.id);
      expect(step2.status, equals(JobStatus.processing));

      // Step 3: succeeds with output asset
      final step3 = await repository.getJob(initial.id);
      expect(step3.status, equals(JobStatus.succeeded));
      expect(step3.resultAsset, isNotNull);
    });

    test('cancels active job upon user request', () async {
      final personAsset = MockDataFixtures.sampleModels[0].toAsset();
      final garmentAsset = MockDataFixtures.sampleGarments[0].toAsset();

      final job = await repository.createJob(
        personAsset: personAsset,
        garmentAsset: garmentAsset,
        category: GarmentCategory.outerwear,
      );

      final cancelled = await repository.cancelJob(job.id);
      expect(cancelled.status, equals(JobStatus.cancelled));
    });

    test('retrieves history and clears all data', () async {
      final history = await repository.getHistory();
      expect(history, isNotEmpty);

      await repository.clearAllData();
      final cleared = await repository.getHistory();
      expect(cleared, isEmpty);
    });
  });
}
