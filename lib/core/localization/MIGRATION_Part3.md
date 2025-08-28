# 📋 Core Localization 마이그레이션 계획 (Part 3)

> 작성일: 2025-08-28 | 대상: Core Localization 레이어 | 예상 기간: 2주

## 🎯 마이그레이션 목표

Core Localization을 Feature-First Architecture에 맞게 재구조화하여:
- ✅ JSON 기반 번역 시스템 구축
- ✅ UI 컴포넌트를 Shared로 분리
- ✅ 타입 안전 번역 키 시스템
- ✅ 동적 언어 로딩 및 캐싱
- ✅ 100% 번역 커버리지 달성

## 📊 현재 상태 분석

### 📁 현재 구조
```
lib/core/localization/
├── app_localizations.dart     # 1,281줄 - 하드코딩된 번역
└── app_language_selector.dart # 608줄 - UI 위젯 (이동 필요)
```

### 🔍 식별된 문제점
1. **구조적 문제** - UI 컴포넌트가 Core에 포함
2. **번역 관리** - 하드코딩된 번역 데이터
3. **독일어 미완성** - 모든 독일어 번역 비어있음
4. **확장성 부족** - 새 언어 추가 어려움
5. **타입 안전성 없음** - 문자열 키 사용

## 📈 마이그레이션 전략

### 🏗️ 목표 구조
```
lib/
├── core/
│   └── localization/
│       ├── services/
│       │   ├── localization_service.dart      # 번역 서비스
│       │   ├── translation_loader.dart        # JSON 로더
│       │   └── translation_cache.dart         # 캐싱 시스템
│       ├── models/
│       │   ├── language_model.dart           # 언어 모델
│       │   └── translation_keys.dart         # 타입 안전 키
│       └── index.dart
│
├── shared/
│   └── widgets/
│       └── language/
│           ├── language_selector.dart        # 언어 선택 UI
│           └── language_flag.dart           # 국기 표시 위젯
│
└── assets/
    └── translations/
        ├── en.json                          # 영어 번역
        ├── de.json                          # 독일어 번역
        └── ko.json                          # 한국어 번역 (추가)
```

## 🔄 마이그레이션 단계

### Phase 1: JSON 번역 시스템 구축 (Day 1-2)

#### 1.1 번역 데이터 추출
```dart
// assets/translations/en.json
{
  "login": {
    "email": "Email",
    "password": "Password",
    "loginButton": "Log in",
    "forgotPassword": "Forgot Password",
    "phoneLogin": "Phone Log in"
  },
  "signup": {
    "welcome": "Welcome to Versus Space",
    "createAccount": "Create an account",
    "confirmPassword": "Confirm Password"
  }
}
```

#### 1.2 Translation Loader 구현
```dart
// lib/core/localization/services/translation_loader.dart
class TranslationLoader {
  static final _cache = <String, Map<String, dynamic>>{};
  
  static Future<Map<String, dynamic>> load(String languageCode) async {
    if (_cache.containsKey(languageCode)) {
      return _cache[languageCode]!;
    }
    
    final jsonString = await rootBundle.loadString(
      'assets/translations/$languageCode.json'
    );
    final translations = json.decode(jsonString) as Map<String, dynamic>;
    _cache[languageCode] = translations;
    return translations;
  }
}
```

#### 1.3 Localization Service 재구현
```dart
// lib/core/localization/services/localization_service.dart
class LocalizationService extends ChangeNotifier {
  Locale _locale = const Locale('en');
  Map<String, dynamic> _translations = {};
  
  Locale get locale => _locale;
  
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    _translations = await TranslationLoader.load(locale.languageCode);
    await _saveLocalePreference(locale.languageCode);
    notifyListeners();
  }
  
  String translate(String key) {
    final keys = key.split('.');
    dynamic value = _translations;
    
    for (final k in keys) {
      value = value[k];
      if (value == null) return key;
    }
    
    return value.toString();
  }
}
```

### Phase 2: 타입 안전 번역 키 (Day 3-4)

#### 2.1 번역 키 생성
```dart
// lib/core/localization/models/translation_keys.dart
class TranslationKeys {
  // Login
  static const String loginEmail = 'login.email';
  static const String loginPassword = 'login.password';
  static const String loginButton = 'login.loginButton';
  
  // Signup
  static const String signupWelcome = 'signup.welcome';
  static const String signupCreateAccount = 'signup.createAccount';
  
  // 자동 생성 스크립트로 관리
}
```

#### 2.2 Extension Method 추가
```dart
// lib/core/localization/extensions/localization_extension.dart
extension LocalizationExtension on BuildContext {
  LocalizationService get l10n => Provider.of<LocalizationService>(this);
  
  String tr(String key) => l10n.translate(key);
}

// 사용 예시
Text(context.tr(TranslationKeys.loginEmail))
```

### Phase 3: UI 컴포넌트 이동 (Day 5-6)

#### 3.1 디렉토리 생성
```bash
mkdir -p lib/shared/widgets/language
```

#### 3.2 컴포넌트 이동 및 리팩토링
- [ ] AppLanguageSelector → shared/widgets/language/language_selector.dart
- [ ] 국기 표시 로직 분리 → language_flag.dart
- [ ] 언어 목록 최적화 (200개 → 실사용 언어만)

#### 3.3 의존성 업데이트
```dart
// 기존
import '/core/localization/app_language_selector.dart';

// 변경
import '/shared/widgets/language/language_selector.dart';
```

### Phase 4: 독일어 번역 완성 (Day 7-9)

#### 4.1 번역 작업
- [ ] 250개 번역 키 독일어 번역
- [ ] 번역 검증 (네이티브 스피커)
- [ ] 컨텍스트 확인 및 조정

#### 4.2 번역 도구 구현
```dart
// lib/core/localization/tools/translation_validator.dart
class TranslationValidator {
  static List<String> findMissingKeys(String languageCode) {
    final baseKeys = _extractKeys('en');
    final targetKeys = _extractKeys(languageCode);
    return baseKeys.where((key) => !targetKeys.contains(key)).toList();
  }
  
  static Map<String, int> getStatistics() {
    return {
      'total': _extractKeys('en').length,
      'translated_de': _extractKeys('de').length,
      'coverage_de': (_extractKeys('de').length / _extractKeys('en').length * 100).round(),
    };
  }
}
```

### Phase 5: 캐싱 및 성능 최적화 (Day 10-11)

#### 5.1 Translation Cache 구현
```dart
// lib/core/localization/services/translation_cache.dart
class TranslationCache {
  static const _maxCacheSize = 1000;
  final _cache = <String, String>{};
  final _lru = <String>[];
  
  String? get(String key, String language) {
    final cacheKey = '$language:$key';
    if (_cache.containsKey(cacheKey)) {
      _updateLRU(cacheKey);
      return _cache[cacheKey];
    }
    return null;
  }
  
  void set(String key, String language, String value) {
    final cacheKey = '$language:$key';
    _cache[cacheKey] = value;
    _updateLRU(cacheKey);
    _evictIfNeeded();
  }
}
```

#### 5.2 Lazy Loading 구현
```dart
class LazyTranslationLoader {
  static final _loadedLanguages = <String>{};
  
  static Future<void> ensureLoaded(String languageCode) async {
    if (!_loadedLanguages.contains(languageCode)) {
      await TranslationLoader.load(languageCode);
      _loadedLanguages.add(languageCode);
    }
  }
}
```

### Phase 6: 테스트 및 검증 (Day 12-13)

#### 6.1 단위 테스트
- [ ] TranslationLoader 테스트
- [ ] LocalizationService 테스트
- [ ] TranslationCache 테스트
- [ ] TranslationValidator 테스트

#### 6.2 통합 테스트
- [ ] 언어 전환 테스트
- [ ] 번역 표시 테스트
- [ ] 캐싱 성능 테스트

### Phase 7: 배포 및 모니터링 (Day 14)

#### 7.1 점진적 마이그레이션
- [ ] Feature별 순차 적용
- [ ] 호환성 레이어 유지
- [ ] 성능 모니터링

#### 7.2 정리 작업
- [ ] 구 번역 시스템 제거
- [ ] 문서 업데이트
- [ ] 릴리즈 노트 작성

## 📋 체크리스트

### 🔴 즉시 작업 (Day 1-2)
- [ ] JSON 번역 파일 생성
- [ ] TranslationLoader 구현
- [ ] LocalizationService 재구현
- [ ] 기존 번역 데이터 마이그레이션

### 🟡 단기 작업 (Day 3-6)
- [ ] 타입 안전 번역 키 생성
- [ ] Extension method 구현
- [ ] UI 컴포넌트 이동
- [ ] 의존성 업데이트

### 🟢 중기 작업 (Day 7-11)
- [ ] 독일어 번역 완성
- [ ] 번역 검증 도구 구현
- [ ] 캐싱 시스템 구축
- [ ] 성능 최적화

### 🔵 장기 작업 (Day 12-14)
- [ ] 테스트 작성
- [ ] 문서화
- [ ] 배포 및 모니터링

## 🚀 실행 계획

### Week 1: 기반 구축
```bash
# Day 1-2: JSON 시스템
mkdir -p assets/translations
touch assets/translations/{en,de,ko}.json

# Day 3-4: 타입 안전성
dart run build_runner build # 번역 키 자동 생성

# Day 5-6: 구조 이동
mkdir -p lib/shared/widgets/language
git mv lib/core/localization/app_language_selector.dart lib/shared/widgets/language/
```

### Week 2: 완성 및 배포
```bash
# Day 7-9: 번역 완성
flutter pub run translation_validator

# Day 10-11: 성능 최적화
flutter analyze lib/core/localization

# Day 12-14: 테스트 및 배포
flutter test test/core/localization
```

## ⚠️ 위험 요소 및 대응 방안

### 위험 1: 번역 누락
- **위험도**: 높음
- **영향**: 사용자 경험 저하
- **대응**: 
  - 자동 검증 도구 구현
  - Fallback 언어 설정
  - 실시간 모니터링

### 위험 2: 성능 저하
- **위험도**: 중간
- **영향**: 앱 반응성
- **대응**:
  - 효율적인 캐싱
  - Lazy loading
  - 번역 파일 최적화

### 위험 3: Breaking Changes
- **위험도**: 높음
- **영향**: 전체 앱
- **대응**:
  - 호환성 레이어 제공
  - 점진적 마이그레이션
  - 충분한 테스트

## 📊 예상 효과

### 정량적 효과
- 번역 관리 시간 50% 감소
- 새 언어 추가 시간 80% 감소
- 번역 파일 크기 30% 감소
- 메모리 사용량 20% 감소

### 정성적 효과
- 번역 품질 향상
- 개발자 경험 개선
- 유지보수성 향상
- 확장성 확보

## 📝 참고 자료

- [Flutter Internationalization](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)
- [JSON-based i18n](https://pub.dev/packages/easy_localization)
- [Type-safe i18n](https://pub.dev/packages/slang)
- [Flutter Localization Best Practices](https://medium.com/flutter-community/flutter-internationalization-the-easy-way-using-provider-and-json-files)

---

*이 문서는 Core Localization의 Feature-First Architecture 마이그레이션 계획입니다.*
*체계적인 번역 시스템으로 글로벌 서비스를 준비합니다.*