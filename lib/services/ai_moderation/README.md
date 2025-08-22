# AI Moderation System

## 개요

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **필드명**: camelCase
- 참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)
통합 AI 검열 시스템으로 텍스트와 이미지 콘텐츠의 안전성과 적절성을 검증합니다.

## 구조

```
ai_moderation/
├── ai_moderation_service.dart    # 메인 통합 서비스
├── text_moderation/
│   ├── perspective_service.dart  # (향후 이동 예정)
│   └── gemini_service.dart      # Gemini AI 검증
├── image_moderation/
│   └── vision_service.dart      # (향후 구현)
├── models/
│   └── moderation_result.dart   # 결과 모델들
└── constants/
    └── moderation_config.dart   # 설정 및 상수
```

## 주요 기능

### 1. 텍스트 검열
- **Perspective API**: 유해성, 욕설, 위협 등 감지
- **Gemini AI**: A vs B 비교 논리성 검증

### 2. 이미지 검열 (구현 완료)
- **Google Cloud Vision API**: 부적절한 이미지 감지
  - 성인 콘텐츠 (ADULT)
  - 폭력적 콘텐츠 (VIOLENCE)
  - 의료 콘텐츠 (MEDICAL)
  - 선정적 콘텐츠 (RACY)
  - 얼굴 평가 차단 (Face annotations)
- **멀티 이미지 지원**: 최대 4개 이미지 동시 검열
- **부분 거부**: 일부 이미지만 거부하고 나머지는 승인

### 3. 통합 검증
- 단계별 검증 (텍스트 → AI 논리성)
- 실시간 진행 상태 업데이트
- 심각도 기반 처리 (pass/warning/error)

## 사용 방법

### 기본 사용
```dart
final request = ModerationRequest(
  questionTitle: "어떤게 더 좋아?",
  titleA: "커피",
  titleB: "차",
  userId: currentUser.id,
);

final result = await AIModerationService.moderatePostContent(
  request: request,
  onProgressUpdate: (message) {
    print(message);
  },
);

if (result.isValid) {
  // 검증 통과
} else {
  // 검증 실패
  print(result.violations);
}
```

### 옵션 설정
```dart
final result = await AIModerationService.moderatePostContent(
  request: request,
  options: ModerationOptions(
    enablePerspectiveAPI: true,
    enableGeminiAI: true,
    enableVisionAPI: false, // 이미지 검열 비활성화
  ),
);
```

## 설정

### 환경 변수
- `PERSPECTIVE_API_KEY`: Google Perspective API 키
- `GEMINI_API_KEY`: Google Gemini AI API 키

### 임계값 조정
`moderation_config.dart`에서 각 카테고리별 임계값을 조정할 수 있습니다:
```dart
static const double toxicityThreshold = 0.6;
static const double profanityThreshold = 0.5;
```

## 검증 플로우

1. **빈 필드 체크**: 필수 필드 확인
2. **텍스트 유해성 검사**: Perspective API
3. **AI 논리성 검증**: Gemini AI (텍스트 통과 시)
4. **이미지 안전성 검사**: Cloud Vision API (이미지가 있는 경우)
5. **결과 통합**: 종합 판단 및 피드백

### 이미지 검열 세부 사항

#### 검사 기준
- **VERY_LIKELY**, **LIKELY** 등급: 거부
- **POSSIBLE**, **UNLIKELY**, **VERY_UNLIKELY**: 승인
- 얼굴 감지 시 평가 관련 키워드 차단

#### 거부 메시지 예시
- 단일 이미지: "선정적 콘텐츠"
- 멀티 이미지 일부 거부: "선정적 콘텐츠: 2,3\n폭력적 콘텐츠: 4"
- 전체 거부: 피커로 돌아가 재선택 유도

## 결과 처리

### 심각도 레벨
- **pass**: 모든 검증 통과
- **warning**: 개선 권고 (진행 가능)
- **error**: 차단 (수정 필요)

### 다이얼로그 표시
```dart
await AIModerationService.showModerationDialog(context, result);
```

## 에러 처리
- API 실패 시 기본 통과 (서비스 중단 방지)
- 타임아웃 설정 (30초)
- 재시도 정책 (최대 3회)

## 테스트 모드 지원

### 관리자/테스터 전용 기능
- **역할 확인**: `role: 'admin'` 또는 `role: 'tester'`
- **검열 우회**: 테스트 모드에서는 일부 검열 규칙 완화
- **디버그 정보**: 상세한 검열 결과 로그 제공

```dart
// 테스트 모드 활성화
if (currentUser.role == 'admin' || currentUser.role == 'tester') {
  // 테스트 모드 UI 표시
  // 검열 결과 상세 정보 제공
}
```

## 향후 계획
1. ~~Vision API 통합~~ ✅ 완료
2. 캐싱 시스템 구현
3. 배치 처리 최적화
4. 다국어 지원 확대
5. 비디오 콘텐츠 검열
6. 실시간 스트리밍 검열
7. 커스텀 필터 규칙