# 🌐 Core Localization 레이어

> 최종 업데이트: 2025-08-28 | 버전: 1.0.0

## 📋 개요

Core Localization은 Versus Space 애플리케이션의 다국어 지원을 담당하는 레이어입니다.
현재 영어(en)와 독일어(de)를 지원하며, Flutter의 내장 localization 시스템을 활용합니다.

## 🏗️ 현재 디렉토리 구조

```
lib/core/localization/
├── app_localizations.dart     # 1,281줄 - 번역 시스템 핵심
└── app_language_selector.dart # 608줄 - 언어 선택 UI 위젯

총 2개 파일, 1,889줄
```

## 🔍 현재 코드 분석

### 1. app_localizations.dart (1,281줄)

#### 핵심 구성요소

**AppLocalizations 클래스**:
```dart
class AppLocalizations {
  static List<String> languages() => ['en', 'de'];
  
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();
      
  String getText(String key) =>
      (kTranslationsMap[key] ?? {})[locale.toString()] ?? '';
}
```

**주요 기능**:
- SharedPreferences로 언어 설정 저장
- 키-값 방식의 번역 시스템
- Material/Cupertino 위젯 지원
- Fallback delegate 구현

**번역 데이터 구조**:
```dart
final kTranslationsMap = <Map<String, Map<String, String>>>[
  // 각 화면별 번역
  {
    'b6l0k8k2': {  // 번역 키
      'en': 'Email',
      'de': '',  // 독일어 번역 비어있음
    },
  }
];
```

**현재 번역 상태**:
- **페이지**: 30개 화면/컴포넌트
- **번역 키**: 약 250개
- **영어**: 100% 완료
- **독일어**: 0% (빈 문자열)

### 2. app_language_selector.dart (608줄)

#### 구성요소

**AppLanguageSelector 위젯**:
- 언어 선택 드롭다운 UI
- 국기 이모지 표시 기능
- 200개 이상의 언어 정보 (실제 사용은 2개)
- emoji_flag_converter 패키지 활용

**문제점**:
- UI 컴포넌트가 Core에 위치 (Feature 독립성 위반)
- 과도한 언어 데이터 (200개 vs 실사용 2개)
- 직접적인 네트워크 이미지 로드 (보안 이슈)

## ⚠️ 현재 문제점 종합

### 1. 구조적 문제
- **Feature 독립성 위반**: UI 위젯이 Core에 포함
- **하드코딩된 번역**: 번역 추가/수정이 어려움
- **확장성 부족**: 새 언어 추가 시 대규모 수정 필요

### 2. 유지보수 문제
- **독일어 번역 미완성**: 모든 독일어 번역이 빈 문자열
- **번역 키 관리**: 의미 없는 키 이름 (예: 'b6l0k8k2')
- **테스트 부재**: 번역 누락 검증 없음

### 3. 성능 문제
- **과도한 데이터**: 사용하지 않는 198개 언어 정보
- **번역 데이터 크기**: 1,281줄의 단일 파일
- **런타임 검색**: 키 기반 검색으로 성능 저하 가능

## 🎯 Feature-First Architecture 적용 방안

### 1. 올바른 계층 구조

```
lib/
├── core/
│   └── localization/
│       ├── services/           # 번역 서비스
│       │   ├── localization_service.dart
│       │   └── translation_loader.dart
│       └── translations/       # 번역 데이터
│           ├── en/
│           │   └── app_en.json
│           └── de/
│               └── app_de.json
│
├── shared/
│   └── widgets/
│       └── language/          # UI 컴포넌트 이동
│           └── language_selector.dart
│
└── features/
    └── settings/
        └── presentation/
            └── widgets/       # 설정 화면 언어 선택
                └── language_settings.dart
```

### 2. 번역 시스템 개선

```dart
// 현재 (하드코딩)
final kTranslationsMap = {...}; // 1,200줄

// 개선 (JSON 기반)
class TranslationService {
  Future<Map<String, String>> loadTranslations(String languageCode) async {
    final jsonString = await rootBundle.loadString(
      'assets/translations/$languageCode.json'
    );
    return json.decode(jsonString);
  }
}
```

### 3. 타입 안전 번역 키

```dart
// 현재 (문자열 키)
getText('b6l0k8k2') // "Email"

// 개선 (타입 안전 enum)
enum AppTranslations {
  loginEmail,
  loginPassword,
  // ...
}

getText(AppTranslations.loginEmail) // "Email"
```

## 📊 리팩토링 우선순위

| 작업 | 우선순위 | 예상 시간 | 난이도 | 영향도 |
|------|----------|----------|--------|--------|
| 독일어 번역 완성 | 🔴 매우 높음 | 3일 | 낮음 | 매우 높음 |
| JSON 기반 전환 | 🔴 매우 높음 | 2일 | 중간 | 높음 |
| UI 위젯 이동 | 🟡 중간 | 1일 | 낮음 | 중간 |
| 타입 안전 키 | 🟡 중간 | 2일 | 중간 | 중간 |
| 번역 테스트 | 🟢 낮음 | 1일 | 낮음 | 중간 |

## 🚀 구현 로드맵

### Phase 1: 번역 데이터 분리 (즉시)
- JSON 파일로 번역 데이터 추출
- 언어별 폴더 구조 생성
- 번역 로더 서비스 구현

### Phase 2: 구조 재편성 (1주일)
- AppLanguageSelector를 shared/widgets로 이동
- Core에는 번역 서비스만 유지
- Feature별 번역 파일 분리

### Phase 3: 품질 개선 (2주일)
- 독일어 번역 완성
- 번역 누락 검증 테스트
- 타입 안전 번역 시스템

## 💡 주요 개선 제안

### 1. 번역 관리 도구
```dart
class TranslationManager {
  // 번역 누락 검사
  List<String> findMissingTranslations(String language) {
    // ...
  }
  
  // 번역 통계
  TranslationStats getStatistics() {
    // ...
  }
}
```

### 2. 동적 언어 로딩
```dart
class DynamicLocalizationService {
  // 필요한 언어만 로드
  Future<void> loadLanguage(String code) async {
    if (!_loadedLanguages.contains(code)) {
      await _loadTranslationFile(code);
      _loadedLanguages.add(code);
    }
  }
}
```

### 3. 번역 캐싱
```dart
class TranslationCache {
  final _cache = <String, Map<String, String>>{};
  
  Future<String> getTranslation(String key, String language) async {
    if (!_cache.containsKey(language)) {
      await _loadLanguage(language);
    }
    return _cache[language]?[key] ?? key;
  }
}
```

## 🔗 연관 파일 및 의존성

### 현재 사용처 (50+ 파일)
- **인증 화면**: login, signup, password_reset
- **온보딩**: user_info, expertise, hobbies
- **메인 화면**: home, posts, profile
- **설정**: settings, language_settings

### 의존 관계
- `shared_preferences`: 언어 설정 저장
- `emoji_flag_converter`: 국기 이모지 변환
- Material/Cupertino: 플랫폼별 위젯 지원

## ⚡ 성능 고려사항

1. **Lazy Loading**: 사용하는 언어만 로드
2. **번역 캐싱**: 메모리 캐싱으로 성능 향상
3. **코드 분할**: 언어별 번역 파일 분리

## 🚨 주의사항

1. **Breaking Changes**: 번역 시스템 변경 시 전체 앱 영향
2. **독일어 지원**: 출시 전 반드시 완성 필요
3. **RTL 언어**: 향후 아랍어 등 지원 시 레이아웃 고려

## 📋 체크리스트

### 즉시 수정 필요
- [ ] 독일어 번역 완성
- [ ] JSON 기반으로 전환
- [ ] UI 위젯 shared로 이동

### 단기 목표 (1주일)
- [ ] 번역 서비스 구현
- [ ] 번역 로더 최적화
- [ ] 번역 테스트 작성

### 장기 목표 (1개월)
- [ ] 타입 안전 번역 시스템
- [ ] 번역 관리 도구 구축
- [ ] 추가 언어 지원 준비

## 사용 예시

### 현재 사용법
```dart
// 번역 텍스트 가져오기
AppLocalizations.of(context).getText('b6l0k8k2'); // "Email"

// 언어 변경
await AppLocalizations.storeLocale('de');

// 언어 선택 UI
AppLanguageSelector(
  currentLanguage: 'en',
  languages: ['en', 'de'],
  onChanged: (lang) => setState(() {}),
)
```

### 개선된 사용법 (제안)
```dart
// 타입 안전 번역
context.translations.loginEmail; // "Email"

// 동적 언어 로딩
await localizationService.setLanguage('de');

// 번역 누락 체크
final missing = translationManager.findMissingKeys('de');
```

---

*이 문서는 Core Localization 레이어의 현재 상태와 개선 방안을 담고 있습니다.*
*다국어 지원은 글로벌 서비스의 필수 요소입니다.*