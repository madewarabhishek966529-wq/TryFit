import 'package:flutter_test/flutter_test.dart';
import 'package:tryfit/core/models/job_status.dart';

void main() {
  group('JobStatus State Transitions (API_CONTRACT.md)', () {
    test('queued can transition to validating or cancelled or failed', () {
      expect(JobStatus.queued.canTransitionTo(JobStatus.validating), isTrue);
      expect(JobStatus.queued.canTransitionTo(JobStatus.cancelled), isTrue);
      expect(JobStatus.queued.canTransitionTo(JobStatus.failed), isTrue);
      expect(JobStatus.queued.canTransitionTo(JobStatus.succeeded), isFalse);
    });

    test('validating can transition to processing or cancelled or failed', () {
      expect(
        JobStatus.validating.canTransitionTo(JobStatus.processing),
        isTrue,
      );
      expect(JobStatus.validating.canTransitionTo(JobStatus.cancelled), isTrue);
      expect(JobStatus.validating.canTransitionTo(JobStatus.failed), isTrue);
      expect(
        JobStatus.validating.canTransitionTo(JobStatus.succeeded),
        isFalse,
      );
    });

    test('processing can transition to succeeded or cancelled or failed', () {
      expect(JobStatus.processing.canTransitionTo(JobStatus.succeeded), isTrue);
      expect(JobStatus.processing.canTransitionTo(JobStatus.cancelled), isTrue);
      expect(JobStatus.processing.canTransitionTo(JobStatus.failed), isTrue);
      expect(
        JobStatus.processing.canTransitionTo(JobStatus.validating),
        isFalse,
      );
    });

    test('terminal states (succeeded, failed, cancelled) cannot transition further', () {
      expect(JobStatus.succeeded.isTerminal, isTrue);
      expect(JobStatus.failed.isTerminal, isTrue);
      expect(JobStatus.cancelled.isTerminal, isTrue);

      expect(
        JobStatus.succeeded.canTransitionTo(JobStatus.processing),
        isFalse,
      );
      expect(JobStatus.failed.canTransitionTo(JobStatus.queued), isFalse);
      expect(
        JobStatus.cancelled.canTransitionTo(JobStatus.validating),
        isFalse,
      );
    });
  });
}
