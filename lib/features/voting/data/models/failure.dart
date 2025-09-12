/// Simple failure class for error handling
class Failure {
  final String message;
  final int? code;
  
  const Failure({
    required this.message,
    this.code,
  });
  
  @override
  String toString() => 'Failure(message: $message, code: $code)';
}