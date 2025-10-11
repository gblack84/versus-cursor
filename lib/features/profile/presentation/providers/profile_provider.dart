import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/usecases/profile/get_user_profile_usecase.dart';
import '../../domain/usecases/profile/update_user_profile_usecase.dart';
import '../../domain/usecases/profile/upload_profile_image_usecase.dart';
import '../../domain/models/user_profile.dart';

/// 프로필 Provider (하이브리드 버전 - Phase 4.5)
///
/// **책임**:
/// - 프로필 상태 관리
/// - UseCase를 통한 비즈니스 로직 실행 (신규)
/// - Legacy StreamBuilder 지원 (하이브리드)
/// - UI 상태 업데이트 (로딩, 에러)
///
/// **마이그레이션 전략** (Section 1.4, Phase 4.5):
/// 1. `watchProfileLegacy()` - Legacy StreamBuilder용 (Week 1-2)
/// 2. `loadProfile()` - 신규 UseCase 방식 (Week 3+)
/// 3. Week 7: Legacy 메서드 제거, 완전 전환
class ProfileProvider extends ChangeNotifier {
  final GetUserProfileUseCase _getProfileUseCase;
  final UpdateUserProfileUseCase _updateProfileUseCase;
  final UploadProfileImageUseCase _uploadImageUseCase;

  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileProvider({
    required GetUserProfileUseCase getProfileUseCase,
    required UpdateUserProfileUseCase updateProfileUseCase,
    required UploadProfileImageUseCase uploadImageUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _uploadImageUseCase = uploadImageUseCase;

  // Getters
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 프로필 로드
  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getProfileUseCase.execute(userId: userId);

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
        _profile = null;
      },
      (profile) {
        _profile = profile;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// 프로필 이미지 업로드
  Future<void> uploadProfileImage(String userId, File imageFile) async {
    _isLoading = true;
    notifyListeners();

    final result = await _uploadImageUseCase.execute(
      userId: userId,
      imageFile: imageFile,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
      },
      (imageUrl) async {
        // UserProfile은 immutable이므로 Firestore에 직접 업데이트
        if (_profile != null) {
          await _profile!.reference.update({'photoUrl': imageUrl});
          // 업데이트 후 다시 로드하여 최신 상태 반영
          await loadProfile(userId);
        }
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  // ========== 하이브리드 메서드 (Phase 4.5 - Week 1-7) ==========

  /// Legacy StreamBuilder 지원 메서드
  ///
  /// **사용 시기**: Week 1-2 하이브리드 운영 기간
  /// **제거 예정**: Week 7 (완전 전환 후)
  ///
  /// **목적**:
  /// - 기존 StreamBuilder<UsersModel> 코드와 호환
  /// - DocumentReference 기반 실시간 스트림 제공
  /// - UserProfile 도메인 모델 직접 사용
  ///
  /// **사용 예시**:
  /// ```dart
  /// StreamBuilder<UserProfile>(
  ///   stream: provider.watchProfileLegacy(currentUserReference!),
  ///   builder: (context, snapshot) {
  ///     if (!snapshot.hasData) return CircularProgressIndicator();
  ///     final profile = snapshot.data!;
  ///     return Text(profile.displayName);
  ///   },
  /// )
  /// ```
  @Deprecated('Phase 4.5 하이브리드 전용. Week 7에 제거 예정.')
  Stream<UserProfile> watchProfileLegacy(DocumentReference userRef) {
    // UserProfile.getDocument는 이미 UserProfile 스트림을 반환
    // UsersModel은 UserProfile의 별칭이므로 변환 불필요
    return UserProfile.getDocument(userRef);
  }

  // ========== Expertise 하이브리드 메서드 (Week 3) ==========

  /// Expertise 추가 (Legacy Firestore 직접 쓰기 방식)
  ///
  /// **사용 시기**: Week 3-6 expertise_select_widget 하이브리드 운영
  /// **제거 예정**: Week 7 (완전 전환 후)
  ///
  /// **목적**:
  /// - 기존 FieldValue.arrayUnion 패턴과 호환
  /// - 즉시 Firestore 업데이트 + AuthUserStreamWidget 실시간 반영
  ///
  /// **사용 예시**:
  /// ```dart
  /// await _profileProvider.addExpertiseLegacy(
  ///   currentUserReference!,
  ///   expertiseText,
  /// );
  /// ```
  @Deprecated('Phase 4.5 하이브리드 전용. Week 7에 제거 예정.')
  Future<bool> addExpertiseLegacy(
    DocumentReference userRef,
    String expertise,
  ) async {
    try {
      await userRef.update({
        'expertise': FieldValue.arrayUnion([expertise]),
      });
      return true;
    } catch (e) {
      _errorMessage = '전문 분야 추가 실패: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Expertise 삭제 (Legacy Firestore 직접 쓰기 방식)
  ///
  /// **사용 시기**: Week 3-6 expertise_select_widget 하이브리드 운영
  /// **제거 예정**: Week 7 (완전 전환 후)
  @Deprecated('Phase 4.5 하이브리드 전용. Week 7에 제거 예정.')
  Future<bool> removeExpertiseLegacy(
    DocumentReference userRef,
    String expertise,
  ) async {
    try {
      await userRef.update({
        'expertise': FieldValue.arrayRemove([expertise]),
      });
      return true;
    } catch (e) {
      _errorMessage = '전문 분야 삭제 실패: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // ========== Interests/Hobbies 하이브리드 메서드 (Week 4) ==========

  /// Interests(Hobbies) 추가 (Legacy Firestore 직접 쓰기 방식)
  ///
  /// **사용 시기**: Week 4-6 hobbies_select_widget 하이브리드 운영
  /// **제거 예정**: Week 7 (완전 전환 후)
  ///
  /// **목적**:
  /// - 기존 FieldValue.arrayUnion 패턴과 호환
  /// - 즉시 Firestore 업데이트 + AuthUserStreamWidget 실시간 반영
  ///
  /// **사용 예시**:
  /// ```dart
  /// await _profileProvider.addInterestLegacy(
  ///   currentUserReference!,
  ///   hobbyText,
  /// );
  /// ```
  @Deprecated('Phase 4.5 하이브리드 전용. Week 7에 제거 예정.')
  Future<bool> addInterestLegacy(
    DocumentReference userRef,
    String interest,
  ) async {
    try {
      await userRef.update({
        'interests': FieldValue.arrayUnion([interest]),
      });
      return true;
    } catch (e) {
      _errorMessage = '관심사 추가 실패: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Interests(Hobbies) 삭제 (Legacy Firestore 직접 쓰기 방식)
  ///
  /// **사용 시기**: Week 4-6 hobbies_select_widget 하이브리드 운영
  /// **제거 예정**: Week 7 (완전 전환 후)
  @Deprecated('Phase 4.5 하이브리드 전용. Week 7에 제거 예정.')
  Future<bool> removeInterestLegacy(
    DocumentReference userRef,
    String interest,
  ) async {
    try {
      await userRef.update({
        'interests': FieldValue.arrayRemove([interest]),
      });
      return true;
    } catch (e) {
      _errorMessage = '관심사 삭제 실패: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // ========== 병렬 테스트 메서드 (Week 1-2) ==========

  /// 하이브리드 운영 중 데이터 일관성 검증
  ///
  /// **목적**: Legacy와 New 시스템 출력 비교
  /// **사용**: kDebugMode에서만 활성화
  ///
  /// **검증 항목**:
  /// - displayName 일치 여부
  /// - pointsA/pointsQ 일치 여부
  /// - 기타 핵심 필드 일치 여부
  @visibleForTesting
  Future<bool> validateHybridConsistency(String userId) async {
    if (!kDebugMode) return true; // 프로덕션에서는 건너뜀

    // Legacy 방식으로 데이터 가져오기
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final legacyProfile = await UserProfile.getDocumentOnce(userRef);

    // New 방식으로 데이터 가져오기
    final result = await _getProfileUseCase.execute(userId: userId);

    return result.fold(
      (failure) {
        debugPrint('❌ [Hybrid Validation] New system failed: ${failure.getUserMessage()}');
        return false;
      },
      (newProfile) {
        // 핵심 필드 비교
        final isConsistent = legacyProfile.displayName == newProfile.displayName &&
            legacyProfile.pointsA == newProfile.pointsA &&
            legacyProfile.pointsQ == newProfile.pointsQ &&
            legacyProfile.email == newProfile.email;

        if (!isConsistent) {
          debugPrint('⚠️ [Hybrid Validation] Data mismatch detected:');
          debugPrint('  displayName: ${legacyProfile.displayName} vs ${newProfile.displayName}');
          debugPrint('  pointsA: ${legacyProfile.pointsA} vs ${newProfile.pointsA}');
          debugPrint('  pointsQ: ${legacyProfile.pointsQ} vs ${newProfile.pointsQ}');
        } else {
          debugPrint('✅ [Hybrid Validation] Data consistent');
        }

        return isConsistent;
      },
    );
  }
}
