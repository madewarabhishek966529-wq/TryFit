/// Try-on asynchronous job lifecycle states as defined in API_CONTRACT.md.
enum JobStatus {
  queued('queued', 'Queued in processing line'),
  validating('validating', 'Validating images & geometry'),
  processing('processing', 'Synthesizing garment simulation'),
  succeeded('succeeded', 'Simulation generated successfully'),
  failed('failed', 'Processing failed safely'),
  cancelled('cancelled', 'Job cancelled by user');

  final String id;
  final String displayLabel;

  const JobStatus(this.id, this.displayLabel);

  static JobStatus fromId(String id) {
    return JobStatus.values.firstWhere(
      (s) => s.id == id,
      orElse: () => JobStatus.queued,
    );
  }

  bool get isTerminal =>
      this == JobStatus.succeeded ||
      this == JobStatus.failed ||
      this == JobStatus.cancelled;
  bool get isActive => !isTerminal;

  /// Validates whether a state transition is legal according to API_CONTRACT.md.
  bool canTransitionTo(JobStatus next) {
    if (this == next) return true;
    switch (this) {
      case JobStatus.queued:
        return next == JobStatus.validating ||
            next == JobStatus.cancelled ||
            next == JobStatus.failed;
      case JobStatus.validating:
        return next == JobStatus.processing ||
            next == JobStatus.cancelled ||
            next == JobStatus.failed;
      case JobStatus.processing:
        return next == JobStatus.succeeded ||
            next == JobStatus.cancelled ||
            next == JobStatus.failed;
      case JobStatus.succeeded:
      case JobStatus.failed:
      case JobStatus.cancelled:
        return false; // Terminal states cannot transition
    }
  }
}
