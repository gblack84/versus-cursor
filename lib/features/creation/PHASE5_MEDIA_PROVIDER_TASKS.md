# Phase 5: Media Provider 분해 - 실행 태스크 리스트

**시작일**: 2025-01-28
**예상 완료일**: 2025-01-31 (3일)
**우선순위**: High
**의존성**: Phase 1-4 완료 필요

## 📋 Task Breakdown Structure

### 🔵 Phase 5.1: 인터페이스 및 모델 정의 [4시간]

#### Task 5.1.1: 상태 모델 클래스 생성 [1시간]
```dart
// 생성 위치: lib/features/creation/domain/models/media/
□ media_selection_state.dart
  - MediaBox enum (A, B)
  - MediaSelectionMode enum (single, multiple)
  - SelectedMedia class
  - SelectionConstraints class

□ media_upload_state.dart
  - UploadTask model
  - UploadProgress model
  - UploadError model
  - UploadStatus enum

□ media_validation_state.dart
  - ValidationResult model
  - ValidationRequest model
  - RejectionReason model
  - ValidationStatus enum

□ media_coordination_state.dart
  - CoordinationEvent model
  - SyncState model
  - ConflictResolution model
```

#### Task 5.1.2: Provider 인터페이스 정의 [1시간]
```dart
// 생성 위치: lib/features/creation/presentation/providers/media/interfaces/
□ i_media_selection_provider.dart
  - 선택 관련 메서드 시그니처
  - 상태 접근자 정의
  - 이벤트 콜백 정의

□ i_media_upload_provider.dart
  - 업로드 관련 메서드 시그니처
  - 진행률 스트림 인터페이스
  - 에러 처리 인터페이스

□ i_media_validation_provider.dart
  - 검증 메서드 시그니처
  - 결과 접근자 정의
  - 에러 상태 인터페이스

□ i_media_state_coordinator.dart
  - 조정 메서드 시그니처
  - 동기화 인터페이스
  - 충돌 해결 인터페이스
```

#### Task 5.1.3: 이벤트 버스 시스템 설계 [1시간]
```dart
// 생성 위치: lib/features/creation/presentation/providers/media/events/
□ media_event_bus.dart
  - EventBus 싱글톤 클래스
  - Event 기본 클래스
  - EventSubscription 관리

□ media_events.dart
  - MediaSelectedEvent
  - UploadStartedEvent
  - UploadProgressEvent
  - ValidationCompletedEvent
  - StateConflictEvent
```

#### Task 5.1.4: DI 설정 준비 [1시간]
```dart
// 수정 위치: lib/features/creation/presentation/providers/
□ provider_config.dart 분석
  - 기존 Provider 등록 방식 파악
  - GetIt 의존성 주입 패턴 확인
  - Provider 초기화 순서 결정
```

---

### 🔵 Phase 5.2: Provider 구현 [8시간]

#### Task 5.2.1: MediaSelectionProvider 구현 [2시간]
```dart
// 생성 위치: lib/features/creation/presentation/providers/media/
□ media_selection_provider.dart
  기능 구현:
  ✓ 이미지 선택 로직 (CreatePostProviderV2에서 추출)
    - _handleImageSelection() 마이그레이션
    - _validateImageCount() 구현
    - _updateAspectRatios() 통합

  ✓ 비디오 선택 로직 준비
    - _handleVideoSelection() 스켈레톤
    - _validateVideoCount() 구현

  ✓ 재정렬 기능
    - reorderMedia() 구현
    - _updateIndices() 구현

  ✓ 상태 관리
    - notifyListeners() 최적화
    - 메모리 관리 로직

  기존 코드 통합:
  - CreatePostProviderV2.uploadImageA/B → _selectedMediaA/B
  - InPutPostImageModel.currentImageIndexA/B → _currentIndexA/B
  - AppState.uploadImageAspectRatioA/B → _aspectRatiosA/B
```

#### Task 5.2.2: MediaUploadProvider 구현 [2시간]
```dart
□ media_upload_provider.dart
  기능 구현:
  ✓ 업로드 큐 관리
    - _uploadQueue 구현
    - _processQueue() 로직
    - 동시 업로드 제한 (maxConcurrentUploads)

  ✓ 진행률 추적
    - _trackUploadProgress() 구현
    - 실시간 스트림 제공
    - 개별/전체 진행률 계산

  ✓ 에러 처리
    - _handleUploadError() 구현
    - 재시도 로직 (exponential backoff)
    - 에러 리포팅

  ✓ Firebase Storage 통합
    - MediaUploadService 연동
    - 썸네일 생성 통합
    - 메타데이터 관리

  기존 코드 통합:
  - MediaUploadService 재사용
  - Firebase Storage 참조 관리
```

#### Task 5.2.3: MediaValidationProvider 구현 [2시간]
```dart
□ media_validation_provider.dart
  기능 구현:
  ✓ AI 검증 통합
    - ModerateContentUseCase 연동
    - 비동기 검증 큐 관리
    - 타임아웃 처리

  ✓ 검증 결과 관리
    - _cacheValidationResults() 구현
    - 결과 만료 처리
    - 재검증 로직

  ✓ 거부 사유 처리
    - _parseRejectionReasons() 구현
    - 사용자 친화적 메시지 변환
    - 다국어 지원

  ✓ 일괄 검증
    - validateBatch() 구현
    - 병렬 처리 최적화

  기존 코드 통합:
  - ai_moderation_service.dart 활용
  - ModerateContentUseCase 재사용
```

#### Task 5.2.4: MediaStateCoordinator 구현 [2시간]
```dart
□ media_state_coordinator.dart
  기능 구현:
  ✓ Provider 리스너 설정
    - _setupListeners() 구현
    - 이벤트 구독 관리
    - 메모리 누수 방지

  ✓ 상태 동기화
    - _synchronizeSelection() 구현
    - _synchronizeUpload() 구현
    - _synchronizeValidation() 구현

  ✓ 충돌 해결
    - _detectConflicts() 구현
    - _resolveConflicts() 로직
    - 우선순위 기반 해결

  ✓ 통합 플로우
    - processMediaSelection() 구현
    - 단계별 처리 로직
    - 롤백 메커니즘

  Provider 간 조정:
  - 선택 → 업로드 → 검증 플로우
  - 에러 전파 관리
  - 상태 일관성 보장
```

---

### 🔵 Phase 5.3: UI 위젯 마이그레이션 [4시간]

#### Task 5.3.1: 기존 위젯 수정 [2시간]
```dart
□ ImageSelectionWidget 수정
  변경 사항:
  - Consumer<CreatePostProviderV2> → Consumer<MediaSelectionProvider>
  - 직접 상태 접근 → Provider 메서드 호출
  - 이벤트 핸들러 업데이트

□ TextInputWidget 수정
  변경 사항:
  - 미디어 관련 로직 제거
  - MediaStateCoordinator 의존성 추가
```

#### Task 5.3.2: 새 UI 컴포넌트 생성 [2시간]
```dart
// 생성 위치: lib/features/creation/presentation/widgets/media/
□ media_upload_indicator.dart
  구현 내용:
  - 업로드 진행률 바
  - 개별 파일 상태 표시
  - 취소/재시도 버튼
  - 애니메이션 효과

□ media_validation_overlay.dart
  구현 내용:
  - 검증 중 로딩 표시
  - 에러 메시지 오버레이
  - 거부된 미디어 표시
  - 재선택 안내

□ media_selection_grid.dart
  구현 내용:
  - 선택된 미디어 그리드 뷰
  - 드래그 앤 드롭 재정렬
  - 삭제 버튼
  - 썸네일 표시
```

---

### 🔵 Phase 5.4: 통합 및 정리 [2시간]

#### Task 5.4.1: DI 설정 업데이트 [1시간]
```dart
□ provider_config.dart 수정
  추가 등록:
  - MediaSelectionProvider 싱글톤
  - MediaUploadProvider 싱글톤
  - MediaValidationProvider 싱글톤
  - MediaStateCoordinator 팩토리

  초기화 순서:
  1. 기본 Provider들
  2. MediaStateCoordinator
  3. CreatePostProviderV2 (수정된 버전)
```

#### Task 5.4.2: CreatePostScreen 통합 [30분]
```dart
□ CreatePostScreen 수정
  Provider 설정:
  - MultiProvider에 4개 Provider 추가
  - Consumer 위젯 업데이트
  - 이벤트 핸들러 연결

□ CreatePostAdapter 수정
  브릿지 로직:
  - AppState ↔ MediaProviders 연동
  - 레거시 호환성 유지
```

#### Task 5.4.3: 레거시 코드 정리 [30분]
```dart
□ 제거할 코드:
  - CreatePostProviderV2의 미디어 관련 메서드
  - InPutPostImageModel의 중복 상태
  - AppState의 미사용 미디어 필드

□ 리팩토링:
  - import 정리
  - 미사용 변수 제거
  - 코드 포맷팅
```

---

### 🔵 Phase 5.5: 테스트 및 검증 [4시간]

#### Task 5.5.1: 단위 테스트 작성 [2시간]
```dart
// 생성 위치: test/features/creation/providers/media/
□ media_selection_provider_test.dart
  테스트 케이스:
  - 이미지 선택 제한 테스트
  - 재정렬 기능 테스트
  - 상태 초기화 테스트

□ media_upload_provider_test.dart
  테스트 케이스:
  - 업로드 큐 테스트
  - 진행률 계산 테스트
  - 에러 처리 테스트

□ media_validation_provider_test.dart
  테스트 케이스:
  - AI 검증 모킹 테스트
  - 타임아웃 테스트
  - 재검증 테스트

□ media_state_coordinator_test.dart
  테스트 케이스:
  - Provider 동기화 테스트
  - 충돌 해결 테스트
  - 전체 플로우 테스트
```

#### Task 5.5.2: 통합 테스트 [1시간]
```dart
□ 전체 미디어 플로우 테스트
  시나리오:
  1. 이미지 4개 선택
  2. 업로드 시작
  3. AI 검증 (1개 거부)
  4. 재선택 및 재업로드
  5. 게시물 생성 완료
```

#### Task 5.5.3: 수동 테스트 및 버그 수정 [1시간]
```yaml
체크리스트:
  □ 이미지 선택 UI 정상 작동
  □ 업로드 진행률 표시 정확도
  □ AI 검증 에러 메시지 표시
  □ 메모리 누수 없음 확인
  □ 성능 저하 없음 확인
```

---

## 🎯 완료 기준 (Definition of Done)

### 각 Task별 완료 기준
```yaml
코드 작성:
  ✓ 모든 기능 구현 완료
  ✓ 코드 리뷰 통과
  ✓ 린트 에러 없음

테스트:
  ✓ 단위 테스트 작성
  ✓ 테스트 커버리지 80% 이상
  ✓ 통합 테스트 통과

문서화:
  ✓ 코드 주석 작성
  ✓ README 업데이트
  ✓ 마이그레이션 가이드 업데이트

검증:
  ✓ 기능 동작 확인
  ✓ 성능 저하 없음
  ✓ 메모리 누수 없음
```

---

## 📊 진행 상황 추적

### Day 1 Progress (2025-01-28)
```
□ Phase 5.1.1: 상태 모델 클래스 생성
□ Phase 5.1.2: Provider 인터페이스 정의
□ Phase 5.1.3: 이벤트 버스 시스템 설계
□ Phase 5.1.4: DI 설정 준비
□ Phase 5.2.1: MediaSelectionProvider 구현

완료: 0/5 | 진행률: 0%
```

### Day 2 Progress (2025-01-29)
```
□ Phase 5.2.2: MediaUploadProvider 구현
□ Phase 5.2.3: MediaValidationProvider 구현
□ Phase 5.2.4: MediaStateCoordinator 구현
□ Phase 5.3.1: 기존 위젯 수정
□ Phase 5.3.2: 새 UI 컴포넌트 생성

완료: 0/5 | 진행률: 0%
```

### Day 3 Progress (2025-01-30)
```
□ Phase 5.4.1: DI 설정 업데이트
□ Phase 5.4.2: CreatePostScreen 통합
□ Phase 5.4.3: 레거시 코드 정리
□ Phase 5.5.1: 단위 테스트 작성
□ Phase 5.5.2: 통합 테스트
□ Phase 5.5.3: 수동 테스트 및 버그 수정

완료: 0/6 | 진행률: 0%
```

---

## 🚨 위험 요소 및 대응 방안

### 기술적 위험
```yaml
위험 1: Provider 간 순환 의존성
  영향도: High
  확률: Medium
  대응: 이벤트 버스 패턴으로 느슨한 결합

위험 2: 상태 동기화 복잡도
  영향도: High
  확률: High
  대응: MediaStateCoordinator 중앙 집중식 관리

위험 3: 메모리 누수
  영향도: Medium
  확률: Medium
  대응: dispose() 메서드 철저한 구현
```

### 일정 위험
```yaml
위험 1: AI 검증 통합 지연
  영향도: Medium
  확률: Low
  대응: Mock 서비스로 개발 진행

위험 2: 테스트 작성 시간 초과
  영향도: Low
  확률: Medium
  대응: 핵심 기능 위주 테스트 우선
```

---

**작성자**: Architecture Team
**최종 검토**: Pending
**승인**: Required before execution