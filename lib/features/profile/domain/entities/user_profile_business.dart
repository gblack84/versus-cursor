import 'user_profile.dart';

/// UserProfile 비즈니스 로직 Extension
///
/// **관심사**: Domain Layer 비즈니스 로직
/// - Role 접근자 및 권한 체크
/// - 프로필 계산 로직
/// - 사용자 상태 판단
///
/// **참고**: Firestore 직렬화는 `user_profile_extensions.dart` 참조
///
/// **Phase C-1**: App Layer 아키텍처 정리
/// - AuthGuard의 Firestore 직접 접근 제거
/// - 비즈니스 로직을 Domain Layer Extension으로 캡슐화
/// - SRP 준수 (Serialization과 Business Logic 분리)
extension UserRoleExtension on UserProfile {
  /// 사용자 역할 조회
  ///
  /// **반환값**:
  /// - `'admin'`: 관리자
  /// - `'tester'`: 테스터
  /// - `'user'`: 일반 사용자 (기본값)
  ///
  /// **Usage**:
  /// ```dart
  /// final profile = await getUserProfileUseCase(userId);
  /// profile.fold(
  ///   (failure) => ProfileLogger.profileError(
  ///     errorType: 'fetchFailed',
  ///     message: '조회 실패',
  ///   ),
  ///   (profile) {
  ///     final role = profile.getRole();  // 'user', 'admin', 'tester'
  ///     Logger.info('User role: $role', tag: 'Profile');
  ///   },
  /// );
  /// ```
  String getRole() => role ?? 'user';

  /// 관리자 여부 확인
  ///
  /// **용도**: 관리자 전용 기능 접근 제어
  ///
  /// **Usage**:
  /// ```dart
  /// if (profile.isAdmin()) {
  ///   // 관리자 전용 UI 표시
  ///   showAdminPanel();
  /// }
  /// ```
  bool isAdmin() => role == 'admin';

  /// 테스터 여부 확인
  ///
  /// **용도**: 베타 기능 접근 제어
  ///
  /// **Usage**:
  /// ```dart
  /// if (profile.isTester()) {
  ///   // 베타 기능 활성화
  ///   enableBetaFeatures();
  /// }
  /// ```
  bool isTester() => role == 'tester';

  /// VIP 여부 확인 (Premium 또는 Admin)
  ///
  /// **용도**: VIP 전용 혜택 제공
  ///
  /// **Usage**:
  /// ```dart
  /// if (profile.isVIP()) {
  ///   // VIP 전용 컨텐츠 표시
  ///   showVIPContent();
  /// }
  /// ```
  bool isVIP() => isPremiumUser || isAdmin();

  /// 프로필 완성도 계산 (0.0 ~ 1.0)
  ///
  /// **기준**:
  /// - 기본 정보: displayName, photoUrl (20%)
  /// - 위치 정보: location, country (20%)
  /// - 관심사: interests, expertise (30%)
  /// - 직업 정보: jobCategory, jobName (20%)
  /// - 추가 정보: shortDescription, dateOfBirth (10%)
  ///
  /// **Usage**:
  /// ```dart
  /// final completeness = profile.calculateCompleteness();
  /// Logger.info('프로필 완성도: ${(completeness * 100).toStringAsFixed(1)}%', tag: 'Profile');
  /// ```
  double calculateCompleteness() {
    double score = 0.0;

    // 기본 정보 (20%)
    if (displayName != null && displayName!.isNotEmpty) score += 0.1;
    if (photoUrl != null && photoUrl!.isNotEmpty) score += 0.1;

    // 위치 정보 (20%)
    if (location != null) score += 0.1;
    if (country != null) score += 0.1;

    // 관심사 (30%)
    if (interests.isNotEmpty) score += 0.15;
    if (expertise.isNotEmpty) score += 0.15;

    // 직업 정보 (20%)
    if (jobCategory != null) score += 0.1;
    if (jobName != null) score += 0.1;

    // 추가 정보 (10%)
    if (shortDescription != null && shortDescription!.isNotEmpty) score += 0.05;
    if (dateOfBirth != null) score += 0.05;

    return score;
  }
}
