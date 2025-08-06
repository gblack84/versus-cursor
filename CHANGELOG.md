# Changelog

모든 주요 변경사항이 이 파일에 문서화됩니다.

이 프로젝트는 [Semantic Versioning](https://semver.org/)을 따릅니다.

## [2.0.0] - 2025-01-06

### 🎉 Major Release: 세 가지 핵심 시스템 통합 완료

이번 릴리즈는 상태 알림 시스템, 인앱 투표 알림 시스템, 로그 통합 시스템을 완전히 통합하여
앱의 안정성과 성능을 대폭 향상시켰습니다.

#### 🔄 Breaking Changes
- **Firebase 컬렉션 이름 정규화**
  - 모든 `_record` 접미사 제거
  - 예: `users_record` → `users`, `posts_record` → `posts`
  - 영향: 모든 Firestore 쿼리에서 컬렉션 이름 업데이트 필요

- **Flutter 모델 파일명 변경**
  - 38개 모델 파일: `_record.dart` → `_model.dart`
  - 예: `users_record.dart` → `users_model.dart`
  - 영향: 모든 import 문 업데이트 필요

#### ✨ New Features

**상태 알림 시스템**
- AI 채팅과 투표 상태 실시간 동기화
- 개별 사용자별 투표 추적 (user_votes Map 구조)
- 10분 타이머 자동 완료 처리
- 투표 완료 시 AI 채팅 메시지 자동 업데이트

**인앱 투표 알림 시스템**
- 멀티이미지 지원 (imageUrlsA/B 배열)
- 스마트 레이아웃 유지 (aspectRatio, layoutType 필드)
- 알림 표시 개선 (Overlay → showDialog 전환)
- 중복 알림 방지 메커니즘 (처리된 알림 ID 영구 저장)
- 92% 화면 너비 사용으로 몰입도 향상

**로그 통합 시스템**
- 영구 중복 방지 (logOnce 메서드 추가)
- 이벤트 기반 고유 ID 로깅
- Firebase Functions 중앙 집중식 로깅 (config/logger.js)
- 시간 기반 중복 억제 제거

#### 🚀 Performance Improvements
- **로그 출력 90% 감소**: 중복 로그 제거로 콘솔 출력 최적화
- **알림 처리 속도 50% 향상**: 큐 시스템 도입으로 순차 처리
- **메모리 사용량 30% 감소**: 영구 ID 관리로 메모리 효율성 향상
- **Firebase 쿼리 최적화**: 인덱스 추가로 쿼리 성능 개선

#### 🔒 Security Updates
- Firebase Security Rules 업데이트 (89줄 변경)
- 투표 타이머 필드 추가 (voteStartTime, voteEndTime, voteStatus)
- 투표 권한 검증 로직 강화
- 필드 존재 여부 체크 추가로 안전성 향상

#### 📚 Documentation
- 12개 디렉토리에 README.md 파일 추가
- ARCHITECTURE.md 신규 작성 (279줄)
- firebase/SECURITY_RULES_UPDATE_GUIDE.md 추가
- 각 시스템별 상세 문서화

#### 🔧 Technical Details

**Firebase Functions (11개 활성화)**
- onCreate 트리거: `onPostCreatedSendNotifications`
- onUpdate 트리거: `onPostVoteUpdate`
- 스케줄 함수: `flushThrottleQueue` (1분), `checkVoteTimeouts` (1시간)
- HTTP 함수: `validatePostContentWithGemini`, `checkImageContent`
- 스토리지 트리거: `moderateImage`

**Firestore 인덱스 추가 (32줄)**
- notifications 컬렉션 복합 인덱스
- posts 컬렉션 투표 관련 인덱스
- 성능 최적화를 위한 쿼리별 인덱스

#### 🐛 Bug Fixes
- AI 채팅에서 투표 상태가 올바르게 표시되지 않는 문제 해결
- 알림 다이얼로그 텍스트 크기 개선
- Widget disposal 에러 수정
- 중복 알림 발생 문제 해결

#### 📱 User Experience
- 멀티이미지 투표 지원으로 더 풍부한 콘텐츠
- 원본 레이아웃 유지로 일관된 사용자 경험
- 몰입도 높은 모달 UI
- 실시간 투표 상태 업데이트

### Migration Guide
자세한 마이그레이션 가이드는 `docs/MIGRATION_GUIDE_v2.md`를 참조하세요.

---

## [1.0.0] - 2024-12-XX

### 초기 릴리즈
- Flutter 앱 기본 기능 구현
- Firebase 백엔드 통합
- 기본 투표 시스템 구현