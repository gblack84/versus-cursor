/// 투표 관련 실패를 나타내는 클래스
abstract class VotingFailure {
  const VotingFailure();
  
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
    if (this is Unexpected) return unexpected((this as Unexpected).message);
    throw UnimplementedError();
  }
}

class ServerError extends VotingFailure {
  const ServerError();
}

class NetworkError extends VotingFailure {
  const NetworkError();
}

class NotFound extends VotingFailure {
  const NotFound();
}

class Unauthorized extends VotingFailure {
  const Unauthorized();
}

class AlreadyVoted extends VotingFailure {
  const AlreadyVoted();
}

class VotingClosed extends VotingFailure {
  const VotingClosed();
}

class InvalidData extends VotingFailure {
  const InvalidData();
}

class CacheError extends VotingFailure {
  const CacheError();
}

class Unexpected extends VotingFailure {
  final String? message;
  const Unexpected([this.message]);
}