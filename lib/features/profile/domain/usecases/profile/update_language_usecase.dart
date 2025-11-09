import 'package:fpdart/fpdart.dart';
import '../../repositories/i_user_repository.dart';
import '../../entities/user_profile.dart';
import '../../failures/profile_failure.dart';

/// 사용자 언어 설정 업데이트 UseCase (Clean Architecture v4.0)
///
/// **책임**:
/// - 언어 코드 유효성 검증
/// - Repository를 통한 UserProfile.language 업데이트
/// - 에러 처리 및 Failure 변환
///
/// **Phase 5**: AppState.selectedLang 대체
/// - AppState.selectedLang → UserProfile.language로 마이그레이션
/// - Feature-First 아키텍처 준수
///
/// **Usage**:
/// ```dart
/// final result = await updateLanguageUseCase.execute(
///   languageCode: 'ko',  // 한국어
///   eventId: uuid.v4(),  // Optional: Idempotency 지원
/// );
///
/// result.fold(
///   (failure) => // 에러 처리,
///   (updatedProfile) => // 성공 처리,
/// );
/// ```
class UpdateLanguageUseCase {
  final IUserRepository _repository;

  UpdateLanguageUseCase({required IUserRepository repository})
      : _repository = repository;

  /// 언어 설정 업데이트 실행
  ///
  /// **Parameters**:
  /// - `languageCode`: 언어 코드 (예: 'en', 'ko', 'ja', 'zh', etc.)
  /// - `eventId`: (Optional) 중복 방지를 위한 이벤트 ID
  ///
  /// **Returns**:
  /// - `Right(UserProfile)`: 업데이트된 프로필
  /// - `Left(ProfileFailure)`: 업데이트 실패
  ///   - `ProfileFailure.validation`: 언어 코드가 비어있음
  ///   - `ProfileFailure.duplicateOperation`: 이미 처리된 작업 (eventId 중복)
  ///   - `ProfileFailure.unauthenticated`: 인증되지 않은 사용자
  ///   - `ProfileFailure.serverError`: Firestore 에러
  ///   - `ProfileFailure.unknown`: 기타 에러
  ///
  /// **지원 언어 코드**:
  /// - 'en': English
  /// - 'ko': 한국어
  /// - 'ja': 日本語
  /// - 'zh': 中文
  /// - 기타 언어는 AppLocalizations에서 지원하는 언어 코드 사용
  Future<Either<ProfileFailure, UserProfile>> execute({
    required String languageCode,
    String? eventId,
  }) async {
    try {
      // 1. 언어 코드 검증
      if (languageCode.isEmpty) {
        return left(const ProfileFailure.validation('languageCode is empty'));
      }

      // 2. 언어 코드 길이 검증 (ISO 639-1: 2자리, ISO 639-2: 3자리)
      if (languageCode.length < 2 || languageCode.length > 3) {
        return left(const ProfileFailure.validation(
            'languageCode must be 2-3 characters'));
      }

      // 3. Repository를 통한 업데이트 (이미 Either 반환)
      return await _repository.updateLanguage(
        languageCode,
        eventId: eventId,
      );
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
