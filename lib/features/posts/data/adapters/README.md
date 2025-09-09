# 📦 Posts Data Services

> Posts Feature의 비즈니스 서비스 레이어 - 데이터 처리 및 통합 관리

## 📋 개요

이 디렉토리는 Posts Feature의 비즈니스 서비스를 포함합니다. 복잡한 비즈니스 로직, 외부 API 통합, 캐싱 전략, 미디어 처리 등을 담당합니다.

## 🏗️ 디렉토리 구조

```
data/services/
├── media/                       # 미디어 처리 서비스
│   ├── asset_picker_service.dart
│   ├── image_download_service.dart
│   ├── image_editor_callback_handler.dart
│   ├── image_reorder_service.dart
│   ├── image_upload_orchestrator.dart
│   ├── media_selection_service.dart
│   ├── media_upload_service.dart
│   └── selection_result_processor.dart
├── vote/                        # 투표 관리 서비스
│   ├── vote_timer_service.dart
│   ├── vote_status_service.dart
│   └── vote_state_coordinator.dart
├── moderation/                  # 콘텐츠 검열 서비스
│   ├── ai_moderation_service.dart
│   ├── perspective_api_service.dart
│   └── gemini_validation_service.dart
├── audience/                    # 타겟 오디언스 서비스
│   └── target_audience_service.dart
├── storage/                     # 스토리지 서비스
│   └── storage_service.dart
├── cache/                       # 캐싱 서비스
│   ├── post_cache_service.dart
│   ├── media_cache_service.dart
│   └── image_cache_helper.dart
└── error/                       # 에러 처리 서비스
    └── error_handler.dart
```

## 📝 주요 서비스 상세

### 1. MediaUploadService

**책임**: 이미지 업로드 오케스트레이션 및 3단계 이미지 처리

**주요 메서드**:
- `uploadImages(images, userId, postId, option)`: 병렬 이미지 업로드
- `_processAndUploadImage()`: 개별 이미지 처리 및 업로드
- `_resizeImage()`: 이미지 리사이징 (원본, 800px, 150px)
- `_validateImage()`: 파일 크기 및 형식 검증
- `_preloadCache()`: 업로드된 이미지 캐시 프리로딩

**이미지 처리 단계**:
1. Original: 원본 이미지 저장
2. Display: 최대 800px 리사이즈 (JPEG 85% 품질)
3. Thumbnail: 150px 썸네일 (JPEG 80% 품질)

**의존성**:
- FirebaseStorage
- ImageCacheHelper
- image 패키지

### 2. VoteStateCoordinator

**책임**: 투표 상태 중앙 관리 및 실시간 업데이트 조정

**주요 메서드**:
- `startVote(postId, endTime)`: 투표 시작 및 타이머 설정
- `recordVote(postId, userId, option)`: 투표 기록 및 중복 방지
- `canUserVote(postId, userId)`: 투표 가능 여부 확인
- `updateVoteStatus(update)`: 외부 투표 상태 동기화
- `_completeVote(postId)`: 투표 완료 처리
- `_checkVoteCompletion()`: 조기 완료 조건 체크 (100표 도달 시)

**상태 관리**:
- VoteState: 투표 상태 정보 (status, votes, votedUserIds, times)
- VoteStatus: active, completed, timeout
- VoteUpdate: 실시간 업데이트 스트림 데이터

**타이머 시스템**:
- 10분 기본 타이머
- 1초마다 남은 시간 업데이트
- 조기 완료 조건 지원

**의존성**:
- RxDart (BehaviorSubject)
- Firebase Functions 트리거

### 3. AIModerationService

**책임**: 다단계 AI 기반 콘텐츠 검열 시스템

**주요 메서드**:
- `moderateContent()`: 통합 검열 시스템 (텍스트 + 이미지 + AI 논리)
- `_moderateTexts()`: Perspective API를 통한 텍스트 검열
- `_moderateImages()`: Cloud Vision API를 통한 이미지 검열
- `_validateWithGemini()`: Gemini AI를 통한 논리 검증
- `_getBlockReason()`: 차단 사유 메시지 생성

**검열 단계**:
1. **텍스트 검열** (Perspective API)
   - 독성 (Toxicity) > 0.8
   - 위협 (Threat) > 0.7
   - 성적 노골성 (Sexually Explicit) > 0.8
   - 심각한 독성 (Severe Toxicity) > 0.7

2. **이미지 검열** (Cloud Vision API)
   - 성인물, 폭력, 의료 콘텐츠 감지
   - SafeSearch 레벨 확인

3. **AI 논리 검증** (Gemini)
   - A/B 옵션 논리성
   - 질문 명확성
   - 편향성/선동성 체크
   - 허위 정보 감지

**에러 처리**: Fail-open 전략 (에러 시 통과)

**의존성**:
- Dio (HTTP 클라이언트)
- Perspective API Key
- Gemini API Key

### 4. TargetAudienceService

**책임**: AI 기반 타겟 오디언스 선택 및 알림 발송

**주요 메서드**:
- `getAIRecommendedUsers()`: AI가 추천하는 관련 사용자
- `getPublicTargetUsers()`: 랜덤 사용자 선택
- `getCustomTargetUsers()`: 조건 기반 필터링
- `recordNotificationSent()`: 알림 발송 기록
- `_extractInterests()`: 텍스트에서 관심사 추출
- `_filterActiveUsers()`: 30일 이내 활성 사용자 필터
- `_scoreUsers()`: 사용자 점수 계산

**타겟 모드**:
1. **Quick (AI)**: AI가 콘텐츠 분석 후 최적 사용자 추천
2. **Public**: 랜덤 활성 사용자 선택
3. **Custom**: 조건별 필터링 (관심사, 연령, 성별, 직업)
4. **Test**: 개발/테스트 모드

**점수 시스템**:
- 관심사 매칭: 각 10점
- 최근 활동: 7일(5점), 14일(3점), 30일(1점)
- 투표 참여율: 50+(5점), 20+(3점), 5+(1점)

**의존성**:
- FirebaseFirestore
- Firebase Functions (AI 추천)

## 🔄 마이그레이션 체크리스트

### Phase 1: 미디어 서비스
- [ ] MediaUploadService 마이그레이션
- [ ] ImageProcessingService 구현
- [ ] VideoProcessingService 구현
- [ ] MediaCacheService 구현

### Phase 2: 투표 서비스
- [ ] VoteStateCoordinator 마이그레이션
- [ ] VoteTimerService 마이그레이션
- [ ] VoteStatusService 마이그레이션

### Phase 3: 검열 서비스
- [ ] AIModerationService 마이그레이션
- [ ] PerspectiveApiService 마이그레이션
- [ ] GeminiValidationService 구현

### Phase 4: 타겟 서비스
- [ ] TargetAudienceService 마이그레이션
- [ ] NotificationService 통합

## ⚠️ 주의사항

1. **API 키 관리**: 환경 변수로 안전하게 관리
2. **에러 처리**: Fail-open vs Fail-close 전략 선택
3. **성능 최적화**: 병렬 처리 및 캐싱 활용
4. **모니터링**: 서비스 상태 및 성능 추적

---

*이 문서는 Posts Feature의 Data Services 레이어 구현 가이드입니다.*