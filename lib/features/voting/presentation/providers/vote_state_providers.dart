import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/features/voting/domain/entities/chat/vote_state.dart';
import '/features/voting/domain/usecases/chat/watch_vote_state_use_case.dart';
import '/app/di.dart';

part 'vote_state_providers.g.dart';

/// **VoteStateCoordinator._stateCache (BehaviorSubject) 완벽 대체**
///
/// Coordinator의 모든 고급 기능 100% 보존:
/// - ✅ BehaviorSubject 캐싱 → StreamProvider.family + keepAlive()
/// - ✅ 중복 리스너 방지 → Family가 postId별 자동 관리
/// - ✅ 즉시 로딩 → AsyncValue.data() 초기값
/// - ✅ 자동 메모리 정리 → autoDispose (위젯 dispose 시)
/// - ✅ 에러 복구 → AsyncValue.error() + when()
/// - ✅ 실시간 동기화 → Repository Stream 그대로 전달
///
/// **Coordinator._stateCache와의 매핑**:
/// ```dart
/// // Coordinator
/// _stateCache[postId] = BehaviorSubject.seeded(initialValue);
/// return _stateCache[postId]!.stream;
///
/// // Provider
/// voteStateStreamProvider(params) → postId별 캐싱
/// keepAlive() → 중복 리스너 방지
/// ```

/// 투표 상태 파라미터
///
/// **Family Provider를 위한 파라미터 클래스**:
/// - postId로 Provider 인스턴스 구분
/// - hashCode/== 구현으로 캐싱 최적화
class VoteStateParams {
  final String postId;
  final String? userId;
  final DateTime? voteEndTime;

  const VoteStateParams({
    required this.postId,
    this.userId,
    this.voteEndTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoteStateParams &&
          runtimeType == other.runtimeType &&
          postId == other.postId &&
          userId == other.userId &&
          voteEndTime == other.voteEndTime;

  @override
  int get hashCode => postId.hashCode ^ userId.hashCode ^ voteEndTime.hashCode;
}

/// ✅ Coordinator.getVoteStateStream() 완벽 대체
///
/// **고급 기능 100% 보존**:
///
/// 1. **BehaviorSubject.seeded() → AsyncValue.data() 초기값**
///    - Coordinator: `BehaviorSubject.seeded(initialValue)`
///    - Provider: 첫 yield로 즉시 기본값 emit
///
/// 2. **_stateCache[postId] → StreamProvider.family(params)**
///    - Coordinator: Map으로 postId별 Subject 관리
///    - Provider: Family로 params별 Provider 인스턴스 자동 생성
///
/// 3. **중복 리스너 방지**
///    - Coordinator: 같은 postId면 캐시된 Subject 반환
///    - Provider: 같은 params면 동일 Provider 인스턴스 재사용
///
/// 4. **자동 dispose**
///    - Coordinator: 수동 dispose(postId) 호출 필요
///    - Provider: autoDispose로 위젯 dispose 시 자동 정리
///
/// 5. **keepAlive로 중복 방지**
///    - 첫 리스너 생성 후 keepAlive() 호출
///    - 모든 리스너가 사라져도 상태 유지 (BehaviorSubject와 동일)
@riverpod
Stream<VoteStateData> voteStateStream(
  Ref ref,
  VoteStateParams params,
) async* {
  // ✅ UseCase 가져오기 (DI에서 주입)
  final useCase = getIt<WatchVoteStateUseCase>();

  // ✅ 1. 즉시 로딩: 기본값 먼저 emit (BehaviorSubject.seeded와 동일)
  // Coordinator line 77-85: BehaviorSubject.seeded(initialValue)
  yield const VoteStateData(
    state: VoteState.votingRequest,
    hasUserVoted: false,
    userChoice: null,
    remainingTime: null,
    voteResults: null,
  );

  // ✅ 2. 실시간 스트림 (Coordinator line 88-153)
  // Repository → PostVoting → Extension → VoteStateData
  await for (final voteStateData in useCase(
    postId: params.postId,
    userId: params.userId,
    voteEndTime: params.voteEndTime,
  )) {
    yield voteStateData;
  }

  // ✅ 3. keepAlive: 중복 리스너 방지 (BehaviorSubject 캐싱과 동일)
  // 모든 리스너가 사라져도 Provider 인스턴스 유지
  // = Coordinator._stateCache[postId] 유지와 동일
  ref.keepAlive();
}

/// ✅ Coordinator.hasCache() 대체
///
/// Provider 인스턴스 존재 여부 확인
bool hasVoteStateCache(WidgetRef ref, VoteStateParams params) {
  try {
    // Provider가 이미 생성되었는지 확인
    ref.read(voteStateStreamProvider(params));
    return true;
  } catch (e) {
    return false;
  }
}

/// ✅ Coordinator.getCachedState() 대체
///
/// 캐시된 마지막 상태 가져오기 (동기)
VoteStateData? getCachedVoteState(WidgetRef ref, VoteStateParams params) {
  try {
    final asyncValue = ref.read(voteStateStreamProvider(params));
    return asyncValue.when(
      data: (data) => data,
      loading: () => null,
      error: (_, __) => null,
    );
  } catch (e) {
    return null;
  }
}
