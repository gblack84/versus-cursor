import '/core/errors/failures.dart';

/// 투표 관련 실패를 나타내는 클래스
///
/// Clean Architecture의 Failure 계층을 상속하여
/// domain-specific 에러 정보를 제공합니다.
abstract class VotingFailure extends Failure {
  const VotingFailure({
    String? message,
    String? code,
  }) : super(message: message ?? 'Voting error occurred', code: code);

  /// Domain-specific 패턴 매칭을 위한 when 메서드
  T when<T>({
    required T Function() serverError,
    required T Function() networkError,
    required T Function() notFound,
    required T Function() unauthorized,
    required T Function() alreadyVoted,
    required T Function() votingClosed,
    required T Function() invalidData,
    required T Function() cacheError,
    required T Function(String? message) unexpected,
  }) {
    if (this is ServerError) return serverError();
    if (this is NetworkError) return networkError();
    if (this is NotFound) return notFound();
    if (this is Unauthorized) return unauthorized();
    if (this is AlreadyVoted) return alreadyVoted();
    if (this is VotingClosed) return votingClosed();
    if (this is InvalidData) return invalidData();
    if (this is CacheError) return cacheError();
    if (this is Unexpected) return unexpected((this as Unexpected).customMessage);
    throw UnimplementedError();
  }
}

class ServerError extends VotingFailure {
  const ServerError() : super(message: 'Server error occurred');
}

class NetworkError extends VotingFailure {
  const NetworkError() : super(message: 'Network connection failed');
}

class NotFound extends VotingFailure {
  const NotFound() : super(message: 'Voting data not found');
}

class Unauthorized extends VotingFailure {
  const Unauthorized() : super(message: 'Unauthorized voting access');
}

class AlreadyVoted extends VotingFailure {
  const AlreadyVoted() : super(message: 'User has already voted');
}

class VotingClosed extends VotingFailure {
  const VotingClosed() : super(message: 'Voting session has ended');
}

class InvalidData extends VotingFailure {
  const InvalidData() : super(message: 'Invalid voting data');
}

class CacheError extends VotingFailure {
  const CacheError() : super(message: 'Cache operation failed');
}

class Unexpected extends VotingFailure {
  final String? customMessage;

  const Unexpected([this.customMessage])
      : super(message: customMessage ?? 'Unexpected voting error');
}