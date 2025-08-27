# 🎨 Widgets - 커스텀 위젯 라이브러리

## 📋 개요

Versus Space 앱 전반에서 사용되는 재사용 가능한 커스텀 위젯들을 모아놓은 라이브러리입니다. 현재는 독성 콘텐츠 검증 및 하이라이팅 기능을 제공하는 특수 텍스트 필드 위젯을 포함하고 있습니다.

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **클래스명**: PascalCase (`HighlightedTextField`, `ValidatedTextField`)
- **필드명**: camelCase (`isToxic`, `toxicSpans`, `validationResult`)
- **메서드명**: camelCase (`buildHighlightedText`, `getErrorMessage`)
- 참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)

## 🏗️ 구조

```
widgets/
├── highlighted_text_field.dart  # 독성 단어 하이라이팅 텍스트 필드 (343줄)
└── README.md                     # 문서 파일
```

## 🔧 주요 구성요소

### 1. HighlightedTextField (highlighted_text_field.dart)

독성 단어를 실시간으로 빨간색으로 하이라이팅하는 텍스트 필드 위젯입니다.

```dart
// 사용 예제
HighlightedTextField(
  controller: _textController,
  hintText: '내용을 입력하세요',
  validationResult: perspectiveResult,
  showHighlights: true,
  onChanged: (text) async {
    // 텍스트 변경 시 검증
    final result = await PerspectiveApiService.analyzeText(text);
    setState(() {
      perspectiveResult = result;
    });
  },
)
```

**주요 기능:**
- 실시간 독성 단어 하이라이팅
- Google Perspective API 통합
- 에러 메시지 자동 표시
- 독성 구간별 시각적 표시

**Props:**
- `controller`: TextEditingController (선택)
- `focusNode`: FocusNode (선택)
- `hintText`: 힌트 텍스트
- `validationResult`: PerspectiveResult 검증 결과
- `showHighlights`: 하이라이팅 표시 여부 (기본값: false)
- `maxLines`: 최대 줄 수 (기본값: 1)
- `minLines`: 최소 줄 수 (기본값: 1)

### 2. ValidatedTextField

독성 검증 결과와 함께 표시되는 고급 텍스트 필드 래퍼입니다.

```dart
// 사용 예제
ValidatedTextField(
  controller: _controller,
  hintText: '질문을 입력하세요',
  maxLength: 100,
  validationResult: perspectiveResult,
  showValidationResults: true,
  onChanged: (text) {
    // 검증 로직
  },
)
```

**주요 기능:**
- 투명 오버레이를 통한 하이라이팅
- 카테고리별 에러 메시지
- 자동 글자 수 제한
- 스크롤 가능한 하이라이팅

**에러 메시지 카테고리:**
```dart
switch (topCategory) {
  case 'PROFANITY':    // '욕설이 포함되어 있습니다'
  case 'THREAT':       // '위협적인 내용이 포함되어 있습니다'
  case 'INSULT':       // '모욕적인 내용이 포함되어 있습니다'
  case 'TOXICITY':     // '독성 콘텐츠가 감지되었습니다'
  default:             // '부적절한 내용이 감지되었습니다'
}
```

## 💻 코드 분석

### 하이라이팅 알고리즘

```dart
Widget _buildHighlightedText() {
  final text = controller?.text ?? '';
  final toxicSpans = validationResult?.toxicSpans ?? [];
  
  // 1. 독성 구간 정렬
  final sortedSpans = List<ToxicSpan>.from(toxicSpans)
    ..sort((a, b) => a.start.compareTo(b.start));
  
  // 2. TextSpan 생성
  for (final toxicSpan in sortedSpans) {
    // 정상 텍스트
    spans.add(TextSpan(
      text: text.substring(currentIndex, toxicSpan.start),
      style: style,
    ));
    
    // 독성 텍스트 (빨간색 하이라이팅)
    spans.add(TextSpan(
      text: text.substring(toxicSpan.start, toxicSpan.end),
      style: style.copyWith(
        color: Colors.red,
        fontWeight: FontWeight.bold,
        backgroundColor: Colors.red.shade100,
      ),
    ));
  }
  
  return RichText(text: TextSpan(children: spans));
}
```

### UI 구조

1. **기본 모드**: 일반 TextFormField
2. **검증 모드**: Stack 구조
   - 하단: 하이라이팅된 RichText (읽기 전용)
   - 상단: 투명 TextFormField (입력 가능)
   - 하단: 에러 메시지 표시

### 스타일링

```dart
// 하이라이팅 스타일
color: Colors.red,
fontWeight: FontWeight.bold,
backgroundColor: Colors.red.shade100,

// 에러 컨테이너 스타일
color: Colors.red.shade50,
borderRadius: BorderRadius.circular(8),
border: Border.all(color: Colors.red.shade200),
```

## 🚫 문제점

### 코드 품질 이슈

1. **중복 코드**:
   - `_buildHighlightedText()` 메서드가 두 클래스에서 중복
   - 에러 메시지 로직 중복

2. **성능 고려사항**:
   - 매 렌더링마다 TextSpan 재생성
   - 긴 텍스트에서 성능 저하 가능성

3. **접근성 문제**:
   - 스크린 리더 지원 미흡
   - 색맹 사용자를 위한 대안 없음

## 🔄 개선 제안

### 단기 개선
```dart
// 공통 유틸리티 클래스 생성
class TextHighlightHelper {
  static Widget buildHighlightedText(...) { }
  static String getErrorMessage(...) { }
}
```

### 장기 개선
1. **성능 최적화**:
   - TextSpan 캐싱 메커니즘
   - 디바운싱 적용

2. **접근성 개선**:
   - 시맨틱 레이블 추가
   - 색상 외 추가 표시 방법

3. **기능 확장**:
   - 다국어 지원
   - 커스텀 하이라이팅 규칙
   - 실시간 자동 수정 제안

## 📊 통계

- **총 파일 수**: 1개
- **총 코드 줄**: 343줄
- **클래스 수**: 2개 (HighlightedTextField, ValidatedTextField)
- **평균 메서드 크기**: 30줄

## ⚠️ 주의사항

> **경고**: Perspective API 키가 필요합니다.
> 프로덕션 환경에서는 반드시 API 키를 안전하게 관리하세요.

### 사용 시 고려사항
- ✅ API 호출 빈도 제한 적용
- ✅ 디바운싱으로 불필요한 API 호출 방지
- ✅ 오프라인 모드 대비
- ✅ API 응답 캐싱 고려

## 🗑️ 리팩토링 계획

### Phase 1: 코드 정리
- 중복 코드 제거
- 유틸리티 클래스 분리
- 상수 분리

### Phase 2: 성능 최적화
- TextSpan 캐싱
- 비동기 처리 개선
- 메모리 관리

### Phase 3: 기능 확장
- 다양한 검증 서비스 지원
- 커스터마이징 옵션 추가
- 애니메이션 효과

## 📝 변경 이력
- 2025-08-24: 문서화 완료 및 분석
- 2025-08-22: 초기 생성

---

*이 위젯 라이브러리는 앱의 콘텐츠 품질을 보장하는 핵심 UI 컴포넌트를 제공합니다.*
