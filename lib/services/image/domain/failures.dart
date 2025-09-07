/// Export all failure types
export 'failures/image_cache_failure.dart';

/// Base failure class
abstract class Failure {
  const Failure(this.message);
  final String message;
}