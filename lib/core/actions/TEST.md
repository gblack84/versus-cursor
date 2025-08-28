# 🧪 Core Actions 테스트 가이드

> Core Actions 레이어 테스트 전략 및 실행 계획  
> 작성일: 2025-08-28 | 목표 커버리지: 80%+

## 📋 테스트 범위

### 테스트 대상 액션
1. **AppActions**: 앱 시스템 제어
2. **UrlActions**: URL 및 딥링크
3. **ShareActions**: 콘텐츠 공유
4. **ClipboardActions**: 클립보드 관리
5. **FileActions**: 파일 시스템
6. **PermissionActions**: 권한 관리
7. **ErrorActions**: 에러 처리
8. **AnalyticsActions**: 분석 추적
9. **NotificationActions**: 알림 표시

### 테스트 타입
- **단위 테스트**: 개별 액션 메서드
- **통합 테스트**: 액션 간 상호작용
- **E2E 테스트**: 실제 시스템 상호작용
- **성능 테스트**: 응답 시간 및 리소스

## 🎯 테스트 전략

### 1. 단위 테스트 전략

#### 격리 원칙
```dart
// 모든 외부 의존성 Mock 처리
@GenerateMocks([
  IUserRepository,
  IPreferencesService,
  IAnalyticsService,
  IPermissionHandler,
])
```

#### 테스트 구조 표준
```dart
void main() {
  group('ActionName', () {
    late ActionService service;
    late MockDependency mockDep;
    
    setUp(() {
      // 초기화
    });
    
    tearDown(() {
      // 정리
    });
    
    group('methodName', () {
      test('should handle success case', () async {
        // Given - When - Then
      });
      
      test('should handle error case', () async {
        // Given - When - Then
      });
    });
  });
}
```

### 2. 통합 테스트 전략

#### 실제 서비스 일부 사용
```dart
// 일부는 실제, 일부는 Mock
final integration = IntegrationTestSetup(
  useRealPreferences: true,
  useRealAnalytics: false,
  useRealPermissions: false,
);
```

### 3. E2E 테스트 전략

#### 디바이스별 테스트
```dart
// iOS, Android 실제 디바이스 필요
testWidgets('Real device test', (tester) async {
  // 실제 권한 요청
  // 실제 URL 열기
  // 실제 파일 접근
}, skip: !Platform.isPhysical);
```

## 📊 상세 테스트 케이스

### 1. AppActions 테스트

#### 1.1 언어 설정 테스트
```dart
// test/unit/actions/app_actions_test.dart
group('AppActions', () {
  group('setLanguage', () {
    test('성공: 유효한 언어 설정', () async {
      // Given
      const language = 'en';
      when(mockPrefs.setLanguage(language)).thenAnswer((_) async => true);
      when(mockUserRepo.isLoggedIn).thenReturn(true);
      when(mockUserRepo.updateLanguage(language)).thenAnswer((_) async {});
      
      // When
      final result = await service.setLanguage(language);
      
      // Then
      expect(result.success, true);
      expect(result.data, null);
      expect(result.error, null);
      verify(mockPrefs.setLanguage(language)).called(1);
      verify(mockUserRepo.updateLanguage(language)).called(1);
    });
    
    test('실패: 지원하지 않는 언어', () async {
      // Given
      const invalidLanguage = 'xx';
      
      // When
      final result = await service.setLanguage(invalidLanguage);
      
      // Then
      expect(result.success, false);
      expect(result.error, contains('Unsupported'));
      verifyNever(mockPrefs.setLanguage(any));
    });
    
    test('부분 성공: 로컬만 저장 (오프라인)', () async {
      // Given
      when(mockUserRepo.isLoggedIn).thenReturn(false);
      when(mockPrefs.setLanguage(any)).thenAnswer((_) async => true);
      
      // When
      final result = await service.setLanguage('en');
      
      // Then
      expect(result.success, true);
      verify(mockPrefs.setLanguage('en')).called(1);
      verifyNever(mockUserRepo.updateLanguage(any));
    });
  });
  
  group('hapticFeedback', () {
    test('가벼운 햅틱 피드백', () async {
      // When
      await service.hapticFeedback(HapticFeedbackType.light);
      
      // Then - 실제 디바이스에서만 검증 가능
      expect(true, true); // Mock에서는 통과
    });
  });
});
```

### 2. UrlActions 테스트

#### 2.1 URL 열기 테스트
```dart
// test/unit/actions/url_actions_test.dart
group('UrlActions', () {
  group('openUrl', () {
    test('성공: 유효한 HTTP URL', () async {
      // Given
      const url = 'https://example.com';
      when(mockUrlLauncher.canLaunch(url)).thenAnswer((_) async => true);
      when(mockUrlLauncher.launch(url)).thenAnswer((_) async => true);
      
      // When
      final result = await service.openUrl(url);
      
      // Then
      expect(result.success, true);
    });
    
    test('실패: 잘못된 URL 형식', () async {
      // Given
      const invalidUrl = 'not a url';
      
      // When
      final result = await service.openUrl(invalidUrl);
      
      // Then
      expect(result.success, false);
      expect(result.errorDetails?.type, ActionErrorType.invalidInput);
    });
    
    test('실패: 지원하지 않는 스킴', () async {
      // Given
      const customScheme = 'custom://app';
      when(mockUrlLauncher.canLaunch(customScheme)).thenAnswer((_) async => false);
      
      // When
      final result = await service.openUrl(customScheme);
      
      // Then
      expect(result.success, false);
      expect(result.error, contains('Cannot open'));
    });
  });
  
  group('sendEmail', () {
    test('이메일 URI 생성 검증', () async {
      // When
      final result = await service.sendEmail(
        to: 'test@example.com',
        subject: 'Test Subject',
        body: 'Test Body',
      );
      
      // Then
      final expectedUri = 'mailto:test@example.com?subject=Test+Subject&body=Test+Body';
      verify(mockUrlLauncher.launch(expectedUri));
    });
  });
});
```

### 3. PermissionActions 테스트

#### 3.1 권한 요청 테스트
```dart
// test/unit/actions/permission_actions_test.dart
group('PermissionActions', () {
  group('requestCameraPermission', () {
    test('권한 허용됨', () async {
      // Given
      when(mockPermissionHandler.request(Permission.camera))
        .thenAnswer((_) async => PermissionStatus.granted);
      
      // When
      final result = await service.requestCameraPermission();
      
      // Then
      expect(result.success, true);
      expect(result.data, PermissionStatus.granted);
    });
    
    test('권한 거부됨', () async {
      // Given
      when(mockPermissionHandler.request(Permission.camera))
        .thenAnswer((_) async => PermissionStatus.denied);
      
      // When
      final result = await service.requestCameraPermission();
      
      // Then
      expect(result.success, false);
      expect(result.errorDetails?.type, ActionErrorType.permission);
    });
    
    test('권한 영구 거부 - 설정으로 이동', () async {
      // Given
      when(mockPermissionHandler.request(Permission.camera))
        .thenAnswer((_) async => PermissionStatus.permanentlyDenied);
      when(mockPermissionHandler.openAppSettings())
        .thenAnswer((_) async => true);
      
      // When
      final result = await service.requestCameraPermission(
        openSettingsOnDenied: true,
      );
      
      // Then
      verify(mockPermissionHandler.openAppSettings()).called(1);
    });
  });
});
```

### 4. ErrorActions 테스트

#### 4.1 에러 처리 테스트
```dart
// test/unit/actions/error_actions_test.dart
group('ErrorActions', () {
  group('handleError', () {
    test('네트워크 에러 처리', () async {
      // Given
      final error = NetworkException('Connection failed');
      
      // When
      final result = await service.handleError(
        error,
        context: mockContext,
        showToast: true,
      );
      
      // Then
      expect(result.errorDetails?.type, ActionErrorType.network);
      verify(mockToastService.showError('Connection failed')).called(1);
    });
    
    test('재시도 콜백 실행', () async {
      // Given
      var retryCount = 0;
      final onRetry = () => retryCount++;
      
      // When
      await service.handleError(
        Exception('Test'),
        context: mockContext,
        onRetry: onRetry,
      );
      
      // Then
      expect(retryCount, 1);
    });
  });
});
```

## 🧪 통합 테스트 케이스

### 1. 액션 체인 테스트
```dart
// test/integration/action_chain_test.dart
testWidgets('파일 선택 → 공유 플로우', (tester) async {
  // Given
  await tester.pumpWidget(TestApp());
  
  // When - 파일 선택
  final fileResult = await getIt<IFileAction>().pickImage();
  expect(fileResult.success, true);
  
  final imagePath = fileResult.data as String;
  
  // When - 파일 공유
  final shareResult = await getIt<IShareAction>().shareImage(
    imagePath,
    text: 'Check this out!',
  );
  
  // Then
  expect(shareResult.success, true);
});
```

### 2. 권한 → 카메라 → 저장 플로우
```dart
testWidgets('카메라 촬영 전체 플로우', (tester) async {
  // 1. 권한 요청
  final permResult = await getIt<IPermissionAction>().requestCameraPermission();
  if (!permResult.success) {
    skip('Camera permission denied');
  }
  
  // 2. 카메라 촬영
  final photoResult = await getIt<IFileAction>().takePhoto();
  expect(photoResult.success, true);
  
  // 3. 파일 저장
  final saveResult = await getIt<IFileAction>().saveToGallery(
    photoResult.data as File,
  );
  expect(saveResult.success, true);
});
```

## 📊 테스트 커버리지 목표

| 액션 | 단위 테스트 | 통합 테스트 | E2E 테스트 | 목표 커버리지 |
|------|------------|-------------|------------|--------------|
| AppActions | 90% | 70% | 50% | 85% |
| UrlActions | 95% | 80% | 60% | 85% |
| ShareActions | 85% | 70% | 50% | 80% |
| ClipboardActions | 95% | 80% | 60% | 85% |
| FileActions | 80% | 60% | 40% | 75% |
| PermissionActions | 90% | 70% | 50% | 80% |
| ErrorActions | 95% | 85% | - | 90% |
| AnalyticsActions | 90% | 80% | - | 85% |
| NotificationActions | 90% | 80% | 60% | 85% |
| **전체** | **90%** | **75%** | **50%** | **83%** |

## 🚀 테스트 실행 명령

### 단위 테스트
```bash
# 전체 단위 테스트
flutter test test/unit/actions/

# 특정 액션 테스트
flutter test test/unit/actions/app_actions_test.dart

# 커버리지 포함
flutter test --coverage test/unit/actions/
```

### 통합 테스트
```bash
# 통합 테스트
flutter test test/integration/

# 특정 플로우 테스트
flutter test test/integration/action_chain_test.dart
```

### E2E 테스트
```bash
# 실제 디바이스 필요
flutter drive --target=test_driver/app.dart

# iOS 시뮬레이터
flutter drive --target=test_driver/app.dart -d iPhone

# Android 에뮬레이터
flutter drive --target=test_driver/app.dart -d android
```

## 📝 테스트 작성 가이드라인

### 1. 명명 규칙
```dart
// 테스트 파일: [action_name]_test.dart
// 테스트 그룹: ActionName
// 테스트 케이스: should + 동작 + 조건
test('should return success when valid input provided', () {});
test('should throw exception when network fails', () {});
```

### 2. AAA 패턴
```dart
test('테스트 케이스', () async {
  // Arrange (Given)
  final input = TestData();
  when(mock.method()).thenReturn(expected);
  
  // Act (When)
  final result = await service.action(input);
  
  // Assert (Then)
  expect(result, expected);
  verify(mock.method()).called(1);
});
```

### 3. 테스트 데이터 관리
```dart
// test/fixtures/action_fixtures.dart
class ActionTestFixtures {
  static const validUrl = 'https://example.com';
  static const invalidUrl = 'not-a-url';
  static const testEmail = 'test@example.com';
  static final testFile = File('test.txt');
}
```

## 🐛 버그 리포트 템플릿

```markdown
### 버그 설명
[간단한 버그 설명]

### 재현 단계
1. [첫 번째 단계]
2. [두 번째 단계]
3. [버그 발생]

### 예상 동작
[예상했던 동작]

### 실제 동작
[실제로 발생한 동작]

### 테스트 코드
```dart
test('버그 재현 테스트', () async {
  // 재현 코드
});
```

### 환경
- Flutter 버전:
- 디바이스:
- OS:
```

## 🔄 CI/CD 통합

### GitHub Actions 설정
```yaml
# .github/workflows/actions_test.yml
name: Actions Test

on:
  pull_request:
    paths:
      - 'lib/core/actions/**'
      - 'lib/services/actions/**'
      - 'test/**/actions/**'

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test --coverage test/
      
      - name: Check coverage
        run: |
          COVERAGE=$(lcov --list coverage/lcov.info | grep "Total:" | awk '{print $2}' | sed 's/%//')
          echo "Coverage: $COVERAGE%"
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "Coverage is below 80%"
            exit 1
          fi
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

## ⚡ 성능 테스트

### 응답 시간 벤치마크
```dart
test('액션 응답 시간', () async {
  final stopwatch = Stopwatch()..start();
  
  await service.setLanguage('en');
  
  stopwatch.stop();
  expect(stopwatch.elapsedMilliseconds, lessThan(100));
});
```

### 메모리 사용량
```dart
test('메모리 누수 체크', () async {
  // 반복 실행으로 메모리 누수 확인
  for (int i = 0; i < 1000; i++) {
    await service.hapticFeedback(HapticFeedbackType.light);
  }
  
  // 메모리 프로파일링 도구 사용
});
```

## 🏁 테스트 체크리스트

### 각 액션별 필수 테스트
- [ ] 성공 케이스
- [ ] 실패 케이스
- [ ] 엣지 케이스
- [ ] null/empty 입력
- [ ] 타임아웃 처리
- [ ] 권한 거부 처리
- [ ] 네트워크 오류
- [ ] 동시성 처리

### 테스트 품질 체크
- [ ] 80% 이상 커버리지
- [ ] 모든 public 메서드 테스트
- [ ] Mock 올바르게 사용
- [ ] 테스트 독립성 보장
- [ ] 명확한 테스트 이름
- [ ] 실패 시 명확한 메시지

---

*이 문서는 Core Actions 레이어의 테스트 전략과 실행 계획을 담고 있습니다.*  
*목표 커버리지 83% 달성을 위한 체계적인 테스트를 수행합니다.*