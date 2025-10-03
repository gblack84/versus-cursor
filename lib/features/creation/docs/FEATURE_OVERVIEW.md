# Creation Feature - 기능 개요서

## 📱 개요
Versus Space 앱의 콘텐츠 생성(Creation) 기능은 사용자가 A vs B 형식의 비교 질문을 작성하고 미디어를 업로드하며, AI 기반 검열과 타겟 오디언스 설정을 통해 안전하고 효과적인 콘텐츠를 발행하는 핵심 모듈입니다. Clean Architecture v4.0과 Phase 5 MediaStateCoordinator를 적용하여 확장 가능하고 유지보수가 용이한 구조로 설계되었습니다.

## 🎯 주요 기능

### 1. 포스트 생성 (A vs B 형식)
- **텍스트 입력**: 제목, 설명, A/B 옵션 텍스트 입력
- **유효성 검증**: 실시간 필드 검증 및 에러 메시지 표시
- **스마트 레이아웃**: 이미지 비율에 따른 자동 레이아웃 전환 (가로/세로)
- **B박스 토글**: A 옵션만 필요한 경우 B박스 숨기기 기능

### 2. 미디어 업로드 및 편집
- **멀티 이미지 지원**: 최대 4개 이미지 업로드 (wechat_assets_picker)
- **이미지 편집**: ProImageEditor 통합 (필터, 자르기, 그리기, 텍스트)
- **이미지 재배치**: 드래그 앤 드롭으로 이미지 순서 변경
- **썸네일 생성**: 자동 썸네일 및 display 이미지 생성 (150px, 800px)
- **비율 계산**: 자동 aspect ratio 계산 및 저장

### 3. AI 콘텐츠 검열 시스템
- **Perspective API**: 텍스트 유해성 검사 (욕설, 혐오 표현)
- **Gemini AI**: 이미지 내용 분석 및 로직 검증
- **Cloud Vision API**: 이미지 안전성 검사 (성인 콘텐츠, 폭력)
- **다단계 검증**: 텍스트 → 이미지 → AI 로직 순차 검증
- **동적 거부 메시지**: 검열 결과에 따른 구체적 피드백

### 4. 타겟 오디언스 설정
- **Quick Collection (AI)**: AI 기반 최적 사용자 추천
- **Public (랜덤)**: 활성 사용자에게 무작위 배포
- **Custom (조건)**: 관심사, 연령, 성별 필터링
- **Test (개발)**: Admin/Tester 역할 전용 테스트 모드

### 5. 동적 레이아웃 시스템
- **자동 레이아웃 결정**: AspectRatioAnalyzer로 최적 배치 계산
- **동적 박스 크기**: DynamicBoxCalculator로 화면 공간 최적화
- **레이아웃 타입**: horizontal, vertical, single 자동 전환
- **실시간 업데이트**: 이미지 추가/삭제 시 즉시 레이아웃 재계산

### 6. 실시간 유효성 검증
- **필드별 검증**: 제목, 설명, A/B 옵션 개별 검증
- **통합 검증**: ValidatePostUseCase로 전체 폼 검증
- **에러 표시**: 인라인 에러 메시지 및 흔들림 애니메이션
- **제출 제어**: canSubmit 상태로 다음 버튼 활성화 관리

## 🔐 보안 특징

### AI 검열 시스템
- **3단계 검증**: Perspective API (텍스트) → Cloud Vision (이미지) → Gemini AI (로직)
- **얼굴 평가 BLOCK**: 얼굴 평가 관련 콘텐츠 자동 차단
- **거부 이유 추적**: detectedCategories로 구체적 거부 사유 제공
- **재시도 플로우**: 거부된 이미지만 재선택 유도

### 이미지 처리 보안
- **3단계 리사이징**: original, display (800px), thumbnail (150px)
- **JPEG 압축**: 85% 품질로 최적화
- **Firebase Storage 보안**: 사용자별 경로 분리 (`user_uploads/{userId}/`)
- **URL 만료 처리**: Firestore에 영구 URL 저장

### 타겟 오디언스 보안
- **역할 검증**: Admin/Tester 역할 확인 (Test 모드)
- **중복 알림 방지**: NotificationManager 큐 시스템
- **AI 매칭 안전성**: Gemini AI로 부적절한 타게팅 차단

## 📊 사용자 플로우

### 질문 작성 플로우
```
CreatePostScreen 진입 → 텍스트 입력 → 이미지 선택 → 편집 (선택) →
타겟 오디언스 설정 → AI 검열 → Firestore 저장 → 알림 발송 → 완료
```

### 이미지 선택 및 편집 플로우
```
A박스 클릭 → 미디어 타입 선택 (이미지/비디오) → wechat_assets_picker →
썸네일 선택 → ProImageEditor 편집 (선택) → Firebase 업로드 → 박스에 표시
```

### AI 검열 플로우
```
다음 버튼 클릭 → 이미지 업로드 → Perspective API (텍스트) →
Cloud Vision API (이미지) → Gemini AI (로직) → 결과 표시 →
통과 시 타겟 오디언스 다이얼로그 / 실패 시 재시도 유도
```

## 🎨 UI 화면 구성

### 주요 화면
1. **CreatePostScreen**: 질문 작성 메인 화면
2. **ProImageEditorPage**: 이미지 편집 화면
3. **TargetAudienceDialog**: 타겟 오디언스 설정 모달
4. **MediaSelectionFlowWidget**: 이미지 선택 플로우
5. **FullImageViewerPage**: 전체화면 이미지 뷰어

### 핵심 컴포넌트
- **TextInputWidget**: 텍스트 입력 섹션 (제목, 설명, A/B 옵션)
- **ImageSelectionWidget**: 이미지 선택 및 표시 섹션
- **MediaSelectionBox**: 개별 미디어 박스 (A/B)
- **NextButton**: 제출 버튼 (canSubmit 상태 기반)
- **SimpleValidatedField**: 유효성 검증 포함 입력 필드
- **LayoutDebugInfo**: 개발 모드 레이아웃 디버그 정보

## 🔄 상태 관리

### CreatePostProviderV2 (Singleton)
- **중앙 집중식 상태 관리**: 모든 포스트 생성 상태 통합
- **GetIt DI**: CreationModule을 통한 의존성 주입
- **MediaStateCoordinator 통합**: Phase 5 미디어 상태 관리
- **실시간 상태 업데이트**: ChangeNotifier 패턴 사용

### 상태 종류
- `canSubmit`: 제출 가능 여부 (모든 필드 유효성 + 이미지 업로드 완료)
- `errorMessage`: 에러 메시지
- `titleA/titleB`: A/B 제목
- `descriptionA/descriptionB`: A/B 설명
- `uploadImageA/uploadImageB`: 업로드된 이미지 URL 리스트
- `uploadImageAspectRatioA/uploadImageAspectRatioB`: 이미지 비율 리스트

### MediaSelectionProvider
- **파일 관리**: selectedFilesA/B, localPathsA/B
- **비율 관리**: aspectRatiosA/B
- **AssetEntity 관리**: assetEntityIdsA/B (피커 선택 상태)
- **업로드 URL 관리**: uploadedUrlsA/B

### MediaValidationProvider
- **검증 상태**: validationResults, isValidating
- **에러 추적**: validationErrors Map

## 🌐 다국어 지원
- **한국어**: 기본 언어
- **영어**: 국제 사용자 지원
- **독일어**: 유럽 시장 대응 (예정)

## 📈 성능 최적화
- **병렬 업로드**: Future.wait으로 멀티 이미지 동시 업로드 (30-50% 시간 단축)
- **이미지 프리캐싱**: 업로드 직후 memCacheWidth 적용 프리캐싱
- **지연 로딩**: ProImageEditor, wechat_assets_picker 필요 시 로드
- **스마트 레이아웃 캐싱**: AspectRatioAnalyzer 결과 캐싱
- **디버그 조건부 컴파일**: kDebugMode로 프로덕션 성능 최적화

## 🔧 기술 스택
- **Flutter**: 크로스 플랫폼 프레임워크
- **Firebase**: Firestore, Storage, Functions
- **GetIt**: 의존성 주입
- **wechat_assets_picker**: 이미지 피커 (v9.5.1)
- **ProImageEditor**: 이미지 편집 (v5.4.2)
- **Clean Architecture v4.0**: 아키텍처 패턴
- **Google Genkit**: AI 통합 프레임워크
- **Perspective API**: 텍스트 검열
- **Cloud Vision API**: 이미지 안전성 검사
- **Gemini AI**: 로직 검증 및 사용자 매칭

## 📱 지원 플랫폼
- iOS (13.0+)
- Android (API 24+)
- Web
- macOS

## 🚀 향후 계획
- [ ] 비디오 업로드 및 편집 기능
- [ ] YouTube 링크 통합
- [ ] 드래프트 자동 저장
- [ ] 템플릿 시스템
- [ ] 협업 작성 기능
- [ ] 실시간 미리보기
- [ ] AI 자동 완성 제안
- [ ] 다국어 콘텐츠 번역 지원
