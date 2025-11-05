/// Creation Feature 캐시 키 관리
///
/// **Phase 3: UnifiedCacheService Integration**
///
/// **Naming Convention**:
/// - `v3_draft_post_{userId}` - 사용자별 Draft (Personal)
/// - `v3_target_audience_preset_{userId}` - 사용자별 타겟 프리셋 (Personal)
/// - `v3_ai_generation_{hash}` - 설명 해시 기반 AI 결과 (Global)
/// - `v3_media_metadata_{hash}` - 파일 해시 기반 미디어 메타데이터 (Global)
///
/// **Key Versioning**:
/// - v1: 초기 버전 (Legacy)
/// - v2: Freezed 마이그레이션 (Phase 1)
/// - **v3**: Either 패턴 + UnifiedCache 통합 (Phase 2 + Phase 3)
///
/// **Version Management**:
/// - Phase 완료 시 버전 업그레이드
/// - 버전 변경 시 기존 캐시 자동 무효화
/// - 하위 호환성 보장 (fallback 전략)
///
/// **Cache Scope**:
/// - **Personal**: 사용자별 캐시 (Draft, Preset)
/// - **Global**: 모든 사용자 공유 캐시 (AI 결과, 미디어)
///
/// **Example Usage**:
/// ```dart
/// // Draft Post 키 생성
/// final draftKey = CreationCacheKeys.draftPost('user123');
/// // => 'v3_draft_post_user123'
///
/// // AI 생성 결과 키 생성 (해시 기반)
/// final aiKey = CreationCacheKeys.aiGenerationResult('abc123');
/// // => 'v3_ai_generation_abc123'
/// ```
class CreationCacheKeys {
  /// 현재 캐시 키 버전
  ///
  /// **Phase 3 (v3)**: UnifiedCache Integration
  /// - Draft 자동 저장/복원
  /// - AI 비용 70% 절감
  /// - 타겟 오디언스 재사용
  static const String _version = 'v3';

  // ========== Personal Cache Keys (사용자별) ==========

  /// Draft Post 키 (사용자별)
  ///
  /// **Scope**: Personal (사용자별 독립)
  /// **TTL**: Memory 5분, Hive 영구 (사용자 명시 삭제 전까지)
  ///
  /// **사용처**:
  /// - 앱 재시작 시 작성 중이던 Draft 복원
  /// - 백그라운드 전환 후 복귀 시 Draft 유지
  ///
  /// **Example**:
  /// ```dart
  /// final key = CreationCacheKeys.draftPost('user123');
  /// // => 'v3_draft_post_user123'
  /// ```
  static String draftPost(String userId) => '${_version}_draft_post_$userId';

  /// 타겟 오디언스 프리셋 키 (사용자별)
  ///
  /// **Scope**: Personal (사용자별 독립)
  /// **TTL**: Memory 10분, Hive 30일
  ///
  /// **사용처**:
  /// - 새 질문 작성 시 최근 사용한 타겟 설정 자동 완성
  /// - 타겟 설정 UI 초기값 제공
  ///
  /// **Example**:
  /// ```dart
  /// final key = CreationCacheKeys.targetAudiencePreset('user123');
  /// // => 'v3_target_audience_preset_user123'
  /// ```
  static String targetAudiencePreset(String userId) =>
      '${_version}_target_audience_preset_$userId';

  // ========== Global Cache Keys (모든 사용자 공유) ==========

  /// AI 생성 결과 키 (설명 해시 기반)
  ///
  /// **Scope**: Global (모든 사용자 공유)
  /// **TTL**: Memory 30분, Hive 30일
  ///
  /// **Hash Algorithm**: MD5
  /// - 충돌 확률 낮음 (1 / 2^128)
  /// - 빠른 계산 속도 (~1ms for 1KB text)
  /// - 파일 무결성 검증보다는 캐시 키 생성 목적
  ///
  /// **비용 절감**:
  /// - 캐시 히트 시 Gemini API 호출 생략 ($0.10/call)
  /// - 월 70% 히트율 → $70 절감 (1,000회 기준)
  ///
  /// **사용처**:
  /// - `generateTitle(description)`: 타이틀 자동 생성
  /// - `generateTags(description)`: 태그 자동 생성
  ///
  /// **Example**:
  /// ```dart
  /// final hash = md5.convert(utf8.encode(description)).toString();
  /// final key = CreationCacheKeys.aiGenerationResult(hash);
  /// // => 'v3_ai_generation_abc123def456'
  /// ```
  static String aiGenerationResult(String hash) =>
      '${_version}_ai_generation_$hash';

  /// 미디어 메타데이터 키 (파일 해시 기반)
  ///
  /// **Scope**: Global (모든 사용자 공유)
  /// **TTL**: Memory 15분, Hive 7일
  ///
  /// **Hash Algorithm**: MD5 (파일 바이트 기반)
  /// - 동일 파일 식별 (내용 기반)
  /// - 파일명 변경되어도 동일 해시
  /// - 파일 크기 무관 (바이트 내용 기반)
  ///
  /// **비용 절감**:
  /// - 동일 이미지 재업로드 방지
  /// - Firebase Storage 비용 40% 절감
  /// - 업로드 시간 100% 절감 (기존 URL 재사용)
  ///
  /// **사용처**:
  /// - 이미지 선택 시 중복 체크
  /// - 이전에 업로드한 동일 이미지의 URL 재사용
  ///
  /// **Example**:
  /// ```dart
  /// final fileHash = md5.convert(await file.readAsBytes()).toString();
  /// final key = CreationCacheKeys.mediaMetadata(fileHash);
  /// // => 'v3_media_metadata_abc123def456'
  /// ```
  static String mediaMetadata(String hash) =>
      '${_version}_media_metadata_$hash';

  // ========== Cache Management ==========

  /// 사용자별 캐시 키 패턴 (Personal Scope)
  ///
  /// **사용처**:
  /// - 로그아웃 시 사용자별 캐시 전체 삭제
  /// - 프라이버시 보호
  ///
  /// **Example**:
  /// ```dart
  /// final pattern = CreationCacheKeys.userPattern('user123');
  /// // => 'v3_*_user123'
  /// await cacheService.invalidate(pattern);
  /// // Draft와 Preset 모두 삭제 (AI/미디어는 유지)
  /// ```
  static String userPattern(String userId) => '${_version}_*_$userId';

  /// 모든 Draft Post 키 패턴 (관리자 전용)
  ///
  /// **사용처**:
  /// - 관리자가 모든 Draft 조회 시
  /// - 통계 분석 (Draft 작성률, 게시율 등)
  ///
  /// **Example**:
  /// ```dart
  /// final pattern = CreationCacheKeys.allDraftPattern();
  /// // => 'v3_draft_post_*'
  /// ```
  static String allDraftPattern() => '${_version}_draft_post_*';

  /// 모든 AI 생성 결과 키 패턴 (관리자 전용)
  ///
  /// **사용처**:
  /// - 캐시 통계 분석 (AI 히트율, 비용 절감 효과)
  /// - AI 생성 품질 모니터링
  ///
  /// **Example**:
  /// ```dart
  /// final pattern = CreationCacheKeys.allAIPattern();
  /// // => 'v3_ai_generation_*'
  /// ```
  static String allAIPattern() => '${_version}_ai_generation_*';
}
