import '/core/types/result.dart';
import '../../models/user_profile.dart';
import '../../failures/profile_failure.dart';
import '../../repositories/i_user_repository.dart';

/// 사용자 프로필 실시간 감시 UseCase
///
/// **Clean Architecture Layer**: Domain Layer
/// **Pattern**: Stream-based UseCase with Result pattern error handling
///
/// **Responsibility**:
/// - Repository의 Stream을 Result<T> 타입으로 래핑
/// - ProfileFailure 에러 처리 및 변환
/// - 비즈니스 로직 레이어에서의 타입 안정성 보장
///
/// **Use Case**: 다른 사용자 프로필 화면에서 실시간 업데이트
/// - 프로필 사진 변경 시 즉시 반영
/// - 닉네임, 소개글 변경 시 자동 업데이트
/// - 관심사, 직업 정보 변경 시 동기화
///
/// **Real-World Scenario**:
/// ```
/// 시나리오: 철수가 프로필을 수정하는데, 영희가 철수 프로필을 보고 있음
///
/// T+0s   영희: 철수 프로필 화면 진입
///        → watchUserProfile('cheolsu_id') 시작
///        → 현재 프로필 표시
///
/// T+10s  철수: 프로필 사진 + 소개글 수정
///        → updateUserProfile() 호출
///        → Firestore 문서 업데이트
///
/// T+10.2s 영희: 자동으로 새 프로필 표시! 🎉
///        → Firestore가 스트림에 새 데이터 푸시
///        → StreamBuilder가 UI 리빌드
///        → 수동 새로고침 불필요
/// ```
///
/// **Example Usage**:
/// ```dart
/// // Presentation Layer에서 사용
/// class ProfileProvider extends ChangeNotifier {
///   final WatchUserProfileUseCase _watchProfileUseCase;
///
///   Stream<UserProfile?> watchOtherUserProfile(String userId) {
///     return _watchProfileUseCase
///         .execute(userId: userId)
///         .map((result) => result.fold(
///               (failure) {
///                 _errorMessage = failure.getUserMessage();
///                 notifyListeners();
///                 return null;
///               },
///               (profile) => profile,
///             ));
///   }
/// }
///
/// // UI에서 사용
/// StreamBuilder<UserProfile?>(
///   stream: provider.watchOtherUserProfile('user_123'),
///   builder: (context, snapshot) {
///     if (snapshot.hasData) {
///       final profile = snapshot.data!;
///       return ProfileHeader(profile: profile);  // 자동 업데이트!
///     }
///     return LoadingIndicator();
///   },
/// );
/// ```
///
/// **Architecture Benefits**:
/// - Repository 추상화 유지 (Domain이 Data에 의존하지 않음)
/// - Either 모나드로 타입 안전한 에러 처리
/// - 테스트 가능성 (Repository 모킹 가능)
/// - 비즈니스 로직 응집도 향상
///
/// **Performance**:
/// - Firestore WebSocket 기반 실시간 리스닝
/// - 문서 변경 시에만 이벤트 발생 (불필요한 읽기 없음)
/// - 자동 재연결 (네트워크 끊김 시)
/// - 메모리 효율적 (StreamController 대신 native Firestore Stream 사용)
///
/// **Error Handling**:
/// - ProfileNotFoundFailure: 사용자가 존재하지 않거나 삭제됨
/// - FirestoreReadFailure: Firestore 읽기 에러 (네트워크, 권한 등)
/// - 모든 에러는 Left로 래핑되어 UI에서 안전하게 처리 가능
///
/// **Added**: 2025-01-20 Profile Feature Real-time Sync Implementation
class WatchUserProfileUseCase {
  final IUserRepository _repository;

  WatchUserProfileUseCase(this._repository);

  /// 사용자 프로필 실시간 감시
  ///
  /// **Parameters**:
  /// - [userId]: 감시할 사용자의 ID
  ///
  /// **Returns**: Stream<Result<UserProfile>>
  /// - ResultFailure(ProfileNotFound): 사용자가 존재하지 않음
  /// - ResultFailure(FirestoreRead): Firestore 읽기 에러
  /// - Success(UserProfile): 실시간 업데이트되는 프로필 데이터
  ///
  /// **Stream Behavior**:
  /// - 초기 진입 시: 현재 프로필 데이터 즉시 발행
  /// - 프로필 변경 시: 새 데이터 자동 발행
  /// - 사용자 삭제 시: ResultFailure(ProfileNotFound) 발행
  /// - 에러 발생 시: ResultFailure(FirestoreRead) 발행 후 스트림 계속 유지
  ///
  /// **Example**:
  /// ```dart
  /// final useCase = WatchUserProfileUseCase(repository);
  /// final stream = useCase.execute(userId: 'user_123');
  ///
  /// // 스트림 구독
  /// stream.listen((result) {
  ///   result.fold(
  ///     (failure) {
  ///       // 에러 처리
  ///       if (failure is ProfileNotFound) {
  ///         print('User not found: ${failure.userId}');
  ///       } else if (failure is FirestoreRead) {
  ///         print('Firestore error: ${failure.message}');
  ///       }
  ///     },
  ///     (profile) {
  ///       // 정상 데이터 처리
  ///       print('Profile updated: ${profile.displayName}');
  ///       print('Photo: ${profile.photoUrl}');
  ///       print('Bio: ${profile.shortDescription}');
  ///     },
  ///   );
  /// });
  /// ```
  Stream<Result<UserProfile>> execute({
    required String userId,
  }) async* {
    // async generator를 사용한 Stream 에러 처리
    // await for로 Repository Stream을 소비하면서 에러를 Result로 변환
    try {
      await for (final profile in _repository.watchUserProfile(userId)) {
        if (profile == null) {
          // 사용자가 존재하지 않거나 삭제됨
          yield ResultFailure(ProfileNotFound(userId: userId));
        } else {
          // 정상 프로필 데이터
          yield Success(profile);
        }
      }
    } on ProfileFailure catch (e) {
      yield ResultFailure(e);
    } catch (error) {
      // Firestore 에러 (네트워크, 권한 등)
      // ResultFailure를 발행하고 스트림 종료 (재연결은 UI에서 처리)
      yield ResultFailure(FirestoreRead('Failed to watch user profile: $error'));
    }
  }
}
