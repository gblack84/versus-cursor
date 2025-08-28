# 📝 Content Service 레이어

> 애플리케이션 전역 콘텐츠 필터링 서비스
> 최종 업데이트: 2025-08-28 | 버전: 2.0.0

## 📋 개요

Content Service는 Versus Space 애플리케이션의 **전역 인프라 서비스**로서, 모든 Feature에서 사용하는 콘텐츠 필터링과 검증 기능을 제공합니다. Feature-First Architecture의 Services Layer에 위치하며, 절대 Feature 모듈로 이동하지 않습니다.

## 🏗️ 현재 디렉토리 구조

```
lib/services/content/
├── content_filter.dart        # 180줄 - 콘텐츠 필터링 엔진
├── README.md                   # 현재 문서
├── MIGRATION_Part3.md         # 마이그레이션 계획
└── TEST.md                    # 테스트 전략
```

## 🔍 현재 코드 분석

### content_filter.dart (180줄)

#### 핵심 구성요소

**1. ContentFilter 클래스 (싱글톤 패턴)**
```dart
class ContentFilter {
  static Map<String, dynamic>? _filterData;
  static bool _isInitialized = false;
  
  // JSON 기반 금지어 사전 로드
  static Future<void> initialize() async { }
  
  // 텍스트 필터링 메인 함수
  static FilterResult filterText(String text) { }
  
  // TextFormField 검증
  static String? validateText(String? value) { }
}
```

**2. FilterResult 모델**
```dart
class FilterResult {
  final bool isBlocked;
  final String filteredText;
  final String? blockedWord;
  final String? category;
  final String severity;
}
```

#### 주요 특징

1. **한국어 특화 처리**: 자음/모음 분리 패턴 감지
2. **JSON 기반 설정**: `assets/data/blocked_words.json` 로드
3. **카테고리별 분류**: 심각도와 카테고리별 금지어 관리
4. **정규화 처리**: 특수문자, 공백, 숫자 제거
5. **변형 패턴 감지**: ㅅㅣㅂㅏㄹ → 시발 변환

## 💡 주요 기능

### 1. 텍스트 필터링 플로우

```
입력 텍스트 → 정규화 → 금지어 매칭 → 변형 패턴 검사 → 결과 반환
     ↓           ↓            ↓              ↓            ↓
  원본 보존   소문자화    카테고리별    자음모음    FilterResult
            특수문자제거     검사      분리 검사
```

### 2. 필터링 레벨

```dart
// 심각도 레벨
severity: 'none' | 'low' | 'medium' | 'high' | 'critical'

// 카테고리 (JSON 정의)
categories: 욕설, 성적표현, 폭력, 차별, 기타
```

### 3. 사용 패턴

```dart
// 초기화 (앱 시작 시 1회)
await ContentFilter.initialize();

// 게시물 검증
FilterResult result = ContentFilter.filterText(postContent);
if (result.isBlocked) {
  // 차단 처리
}

// TextFormField 통합
TextFormField(
  validator: ContentFilter.validateText,
)
```

## 🔄 사용 시나리오

### 1. 게시물 작성
```dart
// posts feature에서 사용
final result = ContentFilter.filterText(content);
if (result.isBlocked) {
  showError("${result.category}: 부적절한 표현");
}
```

### 2. 채팅 메시지
```dart
// chat feature에서 사용
final filtered = ContentFilter.filterText(message);
sendMessage(filtered.filteredText); // 마스킹된 텍스트
```

### 3. 프로필 정보
```dart
// profile feature에서 사용
final nameCheck = ContentFilter.validateText(displayName);
if (nameCheck != null) {
  showError(nameCheck);
}
```

## 🚨 현재 문제점

### 1. 정적 싱글톤 패턴
- **문제**: static 메서드로 테스트 어려움
- **영향**: Mock 주입 불가, 단위 테스트 제약
- **해결**: 의존성 주입(DI) 패턴 적용

### 2. 동기적 처리
- **문제**: 긴 텍스트 처리 시 UI 블로킹
- **영향**: 프레임 드롭, UX 저하
- **해결**: Isolate 기반 비동기 처리

### 3. 하드코딩된 JSON 경로
- **문제**: 실시간 업데이트 불가
- **영향**: 새로운 금지어 패턴 대응 지연
- **해결**: Firebase Remote Config 통합

### 4. 단순 패턴 매칭
- **문제**: 문맥 파악 불가
- **영향**: 오탐지(false positive) 발생
- **해결**: AI 기반 컨텍스트 분석 통합

## 📊 메트릭스

### 현재 성능
- 처리 속도: <1ms (100자 기준)
- 정확도: ~85%
- 메모리 사용: ~500KB
- 변형 감지: 기본 자음/모음 분리만

### 개선 목표
- 처리 속도: <0.5ms (Isolate)
- 정확도: >95% (AI 지원)
- 메모리: <300KB (최적화)
- 실시간 업데이트 지원

## 🔗 연관 시스템

### 사용처 (Features)
- **posts**: 게시물 제목, 본문, 옵션 검증
- **chat**: 메시지 필터링 및 마스킹
- **profile**: 사용자 정보 검증
- **comments**: 댓글 내용 필터링
- **search**: 검색어 필터링

### 의존성 (Services/Backend)
- `flutter/services`: 애셋 로드
- `assets/data/blocked_words.json`: 금지어 사전

### 통합 대상
- **moderation service**: 이미지 검열과 통합
- **Perspective API**: 고급 텍스트 분석
- **Gemini AI**: 컨텍스트 기반 검증

## 🎯 Services Layer 유지 필요성

### 왜 Services Layer에 있어야 하는가?

1. **전역 서비스 특성**
   - 모든 Feature에서 공통으로 사용
   - 중앙 집중식 필터링 정책 관리
   - 일관된 콘텐츠 검증 보장

2. **인프라 레벨 기능**
   - 애플리케이션 보안의 핵심 요소
   - Feature 독립성 보장
   - 비즈니스 로직과 분리된 기술적 관심사

3. **크로스커팅 관심사**
   - 여러 Feature에 걸친 공통 기능
   - 단일 책임 원칙 준수
   - 중복 코드 방지

### Feature-First Architecture 준수

```
✅ 올바른 의존성:
Features (posts, chat, profile...)
    ↓ 사용
Services (content, cache, logger...)
    ↓ 사용
Backend (firebase, models...)

❌ 잘못된 접근:
- Content를 Feature로 이동
- Feature별 필터링 중복 구현
- Services가 Feature 모델 직접 import
```

## 📝 다음 단계

### Phase 1: 의존성 주입 (1주)
```dart
// DI 패턴 적용
class ContentFilterService {
  final BlockedWordsRepository _repository;
  
  ContentFilterService(this._repository);
  
  Future<FilterResult> filterText(String text) async { }
}

// GetIt 등록
getIt.registerSingleton<ContentFilterService>(
  ContentFilterService(getIt())
);
```

### Phase 2: 비동기 처리 (1주)
```dart
// Isolate 기반 처리
Future<FilterResult> filterTextAsync(String text) {
  return compute(_filterInIsolate, text);
}
```

### Phase 3: 실시간 업데이트 (2주)
```dart
// Remote Config 통합
class RemoteFilterConfig {
  Stream<Map<String, dynamic>> get filterUpdates { }
  
  Future<void> syncWithRemote() async { }
}
```

### Phase 4: AI 통합 (2주)
```dart
// Perspective API 통합
class AIContentAnalyzer {
  Future<double> analyzeToxicity(String text) async { }
  
  Future<Map<String, double>> analyzeAttributes() async { }
}
```

## 🔄 버전 이력

### v2.0.0 (2025-08-28)
- Services Layer 구조 명확화
- Feature-First Architecture 준수
- 의존성 방향 재정립

### v1.0.0 (2025-08)
- 초기 구현
- 한국어 필터링 지원
- JSON 기반 금지어 사전

## ⚠️ 주의사항

1. **Services Layer 유지**: Feature로 이동하지 말 것
2. **초기화 필수**: 앱 시작 시 `ContentFilter.initialize()` 호출
3. **JSON 경로**: `assets/data/blocked_words.json` 확인
4. **메모리 관리**: 대량 텍스트 처리 시 모니터링

## 🏆 품질 목표

### 코드 품질
- 테스트 커버리지: 85% 이상
- 정적 분석 경고: 0개
- 문서화: 모든 public API

### 성능 목표
- 응답 시간: P95 < 2ms
- 메모리: < 1MB
- CPU: < 5% (idle)

### 신뢰성 목표
- 가용성: 99.9%
- 오탐율: < 5%
- 미탐율: < 1%

## 📚 참고 자료

- [Feature-First Architecture](/ARCHITECTURE.md)
- [Clean Architecture in Services](/GLOBAL_LAYERS.md)
- [Perspective API](https://perspectiveapi.com)
- [Flutter Isolates](https://flutter.dev/docs/cookbook/networking/background-parsing)

---

*이 문서는 Versus Space Content Service의 구조와 사용법을 설명합니다.*
*Services Layer는 전역 인프라로 유지되어야 합니다.*