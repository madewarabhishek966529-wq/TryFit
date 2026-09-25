/// Base class for all handled failures in TryFit.
abstract class Failure {
  final String message;
  final String? code;
  final dynamic details;

  const Failure(this.message, {this.code, this.details});

  @override
  String toString() => '$runtimeType: $message (code: $code)';
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, super.details});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.details});
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, super.details});
}

class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.code, super.details});
}

class CancellationFailure extends Failure {
  const CancellationFailure(super.message, {super.code, super.details});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.details});
}
