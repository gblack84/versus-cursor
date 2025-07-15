# AI Moderation System

## 개요
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

### 2. 이미지 검열 (향후 구현)
- **Vision API**: 부적절한 이미지 감지
- **OCR**: 이미지 내 텍스트 추출 및 검증

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
4. **결과 통합**: 종합 판단 및 피드백

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

## 향후 계획
1. Vision API 통합
2. 캐싱 시스템 구현
3. 배치 처리 최적화
4. 다국어 지원 확대