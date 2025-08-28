# 🔄 Core Actions 마이그레이션 계획 Part 3

> Core Actions 레이어 리팩토링 및 Feature-First Architecture 적용  
> 작성일: 2025-08-28 | 예상 기간: 1주

## 📌 Executive Summary

**현재 상황**: 14줄의 최소 구현 vs 250줄의 상세한 문서 (구현율 11%)  
**목표**: 완전한 액션 시스템 구축 및 올바른 의존성 방향 설정  
**방법**: 인터페이스 기반 설계와 DI를 통한 점진적 마이그레이션

## 🎯 마이그레이션 목표

### Before (현재)
```
lib/core/actions/
├── README.md                 # 250줄 - 계획만 상세
└── global_actions.dart       # 14줄 - 언어 선택만 구현
```

### After (목표)
```
lib/
├── core/
│   └── actions/
│       ├── interfaces/       # 액션 인터페이스
│       │   ├── i_app_action.dart
│       │   ├── i_url_action.dart
│       │   ├── i_share_action.dart
│       │   └── ...
│       ├── models/           # 액션 모델
│       │   ├── action_result.dart
│       │   ├── action_context.dart
│       │   └── action_exception.dart
│       └── constants/        # 액션 상수
│           └── action_types.dart
│
├── services/
│   └── actions/             # 실제 구현
│       ├── app_actions_service.dart
│       ├── url_actions_service.dart
│       ├── share_actions_service.dart
│       ├── clipboard_actions_service.dart
│       ├── file_actions_service.dart
│       ├── permission_actions_service.dart
│       ├── error_actions_service.dart
│       ├── analytics_actions_service.dart
│       └── notification_actions_service.dart
│
└── features/
    └── [각 feature]/
        └── actions/         # Feature 전용 액션
```

## 📊 현재 문제점 분석

### 1. 계층 위반 심각도: 🔴 매우 높음
```dart
// 현재 global_actions.dart
import '/features/auth/data/services/auth_util.dart';  // ❌ Core가 Feature에 의존
```

**영향 분석**:
- 순환 의존성 위험
- 테스트 불가능
- 재사용성 제로
- Feature 변경 시 Core 깨짐

### 2. 구현 부재 심각도: 🔴 매우 높음
```
계획된 액션: 9개
구현된 액션: 1개 (부분적)
미구현율: 89%
```

### 3. 에러 처리 부재 심각도: 🟡 중간
```dart
await currentUserReference!.update(...);  // ! 강제 언래핑
// try-catch 없음
// null check 없음
// 실패 시 처리 없음
```

## 📝 상세 마이그레이션 단계

### Step 1: 인터페이스 정의 (Day 1)

#### 1.1 액션 인터페이스 생성
```dart
// core/actions/interfaces/i_app_action.dart
abstract class IAppAction {
  Future<ActionResult> setLanguage(String language);
  Future<ActionResult> setTheme(ThemeMode theme);
  Future<ActionResult> setOrientation(List<DeviceOrientation> orientations);
  Future<void> hapticFeedback(HapticFeedbackType type);
  Future<void> hideKeyboard();
}

// core/actions/interfaces/i_url_action.dart
abstract class IUrlAction {
  Future<ActionResult> openUrl(String url);
  Future<ActionResult> openInBrowser(String url);
  Future<ActionResult> sendEmail({
    required String to,
    String? subject,
    String? body,
  });
  Future<ActionResult> makePhoneCall(String phoneNumber);
  Future<ActionResult> sendSms(String phoneNumber, String? body);
}
```

#### 1.2 모델 정의
```dart
// core/actions/models/action_result.dart
class ActionResult<T> {
  final bool success;
  final T? data;
  final String? error;
  final ActionError? errorDetails;
  
  const ActionResult._({
    required this.success,
    this.data,
    this.error,
    this.errorDetails,
  });
  
  factory ActionResult.success([T? data]) => ActionResult._(
    success: true,
    data: data,
  );
  
  factory ActionResult.failure(String error, [ActionError? details]) => ActionResult._(
    success: false,
    error: error,
    errorDetails: details,
  );
}

// core/actions/models/action_exception.dart
class ActionException implements Exception {
  final String message;
  final ActionErrorType type;
  final dynamic originalError;
  
  ActionException({
    required this.message,
    required this.type,
    this.originalError,
  });
}

enum ActionErrorType {
  network,
  permission,
  notSupported,
  invalidInput,
  unknown,
}
```

### Step 2: 서비스 구현 (Day 2-3)

#### 2.1 App Actions 구현
```dart
// services/actions/app_actions_service.dart
@LazySingleton(as: IAppAction)
class AppActionsService implements IAppAction {
  final IUserRepository _userRepository;
  final IPreferencesService _preferencesService;
  
  AppActionsService(this._userRepository, this._preferencesService);
  
  @override
  Future<ActionResult> setLanguage(String language) async {
    try {
      // 유효성 검사
      if (!['en', 'de'].contains(language)) {
        return ActionResult.failure('Unsupported language: $language');
      }
      
      // 로컬 저장
      await _preferencesService.setLanguage(language);
      
      // 서버 동기화
      if (_userRepository.isLoggedIn) {
        await _userRepository.updateLanguage(language);
      }
      
      // 앱 로케일 업데이트
      Get.updateLocale(Locale(language));
      
      return ActionResult.success();
    } catch (e) {
      return ActionResult.failure(
        'Failed to set language',
        ActionError(type: ActionErrorType.unknown, details: e.toString()),
      );
    }
  }
  
  @override
  Future<void> hapticFeedback(HapticFeedbackType type) async {
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
    }
  }
}
```

#### 2.2 URL Actions 구현
```dart
// services/actions/url_actions_service.dart
@LazySingleton(as: IUrlAction)
class UrlActionsService implements IUrlAction {
  @override
  Future<ActionResult> openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await canLaunchUrl(uri)) {
        return ActionResult.failure('Cannot open URL: $url');
      }
      
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      return ActionResult.success();
    } catch (e) {
      return ActionResult.failure('Failed to open URL', e);
    }
  }
  
  @override
  Future<ActionResult> sendEmail({
    required String to,
    String? subject,
    String? body,
  }) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: to,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );
    
    return openUrl(emailUri.toString());
  }
}
```

### Step 3: DI 통합 (Day 4)

#### 3.1 Module 설정
```dart
// app/di/modules/action_module.dart
@module
abstract class ActionModule {
  @lazySingleton
  IAppAction provideAppAction(
    IUserRepository userRepo,
    IPreferencesService prefs,
  ) => AppActionsService(userRepo, prefs);
  
  @lazySingleton
  IUrlAction provideUrlAction() => UrlActionsService();
  
  @lazySingleton
  IShareAction provideShareAction() => ShareActionsService();
  
  @lazySingleton
  IClipboardAction provideClipboardAction() => ClipboardActionsService();
  
  @lazySingleton
  IFileAction provideFileAction() => FileActionsService();
  
  @lazySingleton
  IPermissionAction providePermissionAction() => PermissionActionsService();
  
  @lazySingleton
  IErrorAction provideErrorAction() => ErrorActionsService();
  
  @lazySingleton
  IAnalyticsAction provideAnalyticsAction() => AnalyticsActionsService();
  
  @lazySingleton
  INotificationAction provideNotificationAction() => NotificationActionsService();
}
```

### Step 4: 기존 코드 마이그레이션 (Day 5)

#### 4.1 global_actions.dart 리팩토링
```dart
// 임시 하위 호환성 유지
@Deprecated('Use getIt<IAppAction>().setLanguage() instead')
Future selectedLanguage(
  BuildContext context, {
  String? language,
}) async {
  final lang = language ?? 'en';
  await getIt<IAppAction>().setLanguage(lang);
}
```

#### 4.2 사용처 업데이트
```dart
// Before
await selectedLanguage(context, language: 'de');

// After
final result = await getIt<IAppAction>().setLanguage('de');
if (!result.success) {
  showErrorToast(result.error);
}
```

### Step 5: 테스트 작성 (Day 6-7)

#### 5.1 단위 테스트
```dart
// test/services/actions/app_actions_service_test.dart
@GenerateMocks([IUserRepository, IPreferencesService])
void main() {
  late AppActionsService service;
  late MockIUserRepository mockUserRepo;
  late MockIPreferencesService mockPrefs;
  
  setUp(() {
    mockUserRepo = MockIUserRepository();
    mockPrefs = MockIPreferencesService();
    service = AppActionsService(mockUserRepo, mockPrefs);
  });
  
  group('setLanguage', () {
    test('should save language locally and sync with server', () async {
      // Given
      when(mockUserRepo.isLoggedIn).thenReturn(true);
      when(mockPrefs.setLanguage(any)).thenAnswer((_) async {});
      when(mockUserRepo.updateLanguage(any)).thenAnswer((_) async {});
      
      // When
      final result = await service.setLanguage('en');
      
      // Then
      expect(result.success, true);
      verify(mockPrefs.setLanguage('en')).called(1);
      verify(mockUserRepo.updateLanguage('en')).called(1);
    });
    
    test('should reject invalid language', () async {
      // When
      final result = await service.setLanguage('invalid');
      
      // Then
      expect(result.success, false);
      expect(result.error, contains('Unsupported language'));
    });
  });
}
```

#### 5.2 통합 테스트
```dart
// test/integration/actions_integration_test.dart
void main() {
  testWidgets('Language change should update UI', (tester) async {
    // Given
    await tester.pumpWidget(MyApp());
    
    // When
    await getIt<IAppAction>().setLanguage('de');
    await tester.pumpAndSettle();
    
    // Then
    expect(find.text('Einstellungen'), findsOneWidget); // German text
  });
}
```

## 🚀 실행 계획

### Week 1: 기초 구축
- [ ] Day 1: 인터페이스 및 모델 정의
- [ ] Day 2-3: 핵심 서비스 구현 (App, URL, Error, Notification)
- [ ] Day 4: DI 통합
- [ ] Day 5: 마이그레이션 및 하위 호환성

### Week 2: 확장 및 테스트
- [ ] Day 6-7: 테스트 작성
- [ ] Day 8-9: 추가 서비스 구현
- [ ] Day 10: 문서 업데이트

## 📈 성공 지표

### 정량적 지표
- ✅ 구현율: 11% → 100%
- ✅ 테스트 커버리지: 0% → 80%+
- ✅ 의존성 위반: 1개 → 0개
- ✅ 에러 처리: 0% → 100%

### 정성적 지표
- ✅ 올바른 계층 구조
- ✅ 테스트 가능한 코드
- ✅ 재사용 가능한 액션
- ✅ 문서와 코드 일치

## ⚠️ 리스크 및 대응 방안

### Risk 1: Breaking Change
**문제**: 기존 코드가 global_actions.dart 사용  
**대응**: 
- Deprecated 어노테이션으로 점진적 마이그레이션
- 임시 Facade 패턴 적용
- 2주간 하위 호환성 유지

### Risk 2: Feature 팀 영향
**문제**: 모든 Feature가 액션 사용 시 영향받음  
**대응**: 
- Feature별 마이그레이션 가이드 제공
- 단계별 적용 (Critical → High → Low)

### Risk 3: 테스트 복잡도
**문제**: 외부 시스템과 상호작용하는 액션 테스트 어려움  
**대응**: 
- Mock 객체 활용
- 통합 테스트는 실제 디바이스에서만
- CI/CD 파이프라인에 디바이스 팜 통합

## 🔄 롤백 계획

### 즉시 롤백 시나리오
```dart
// 긴급 롤백 플래그
class FeatureFlags {
  static bool useNewActions = false; // 문제 발생 시 false로
}

// 사용처
if (FeatureFlags.useNewActions) {
  await getIt<IAppAction>().setLanguage('en');
} else {
  await selectedLanguage(context, language: 'en');
}
```

## 📚 참고 자료

- [Flutter url_launcher](https://pub.dev/packages/url_launcher)
- [Flutter share_plus](https://pub.dev/packages/share_plus)
- [GetIt DI](https://pub.dev/packages/get_it)
- [Injectable](https://pub.dev/packages/injectable)

## 🏁 체크리스트

### 마이그레이션 전
- [ ] 현재 사용처 파악
- [ ] 영향 범위 분석
- [ ] 테스트 환경 준비

### 마이그레이션 중
- [ ] 인터페이스 정의
- [ ] 서비스 구현
- [ ] DI 통합
- [ ] 테스트 작성

### 마이그레이션 후
- [ ] 모든 테스트 통과
- [ ] 문서 업데이트
- [ ] 팀 공유

---

*이 문서는 Core Actions 레이어의 구체적인 마이그레이션 계획입니다.*  
*1주간의 집중 개발로 완전한 액션 시스템을 구축합니다.*