# 📦 State Providers

> Provider 패턴 구현체 모음  
> 최종 업데이트: 2025-08-28 | 버전: 1.0.0

## 📋 개요

State Providers는 Provider 패턴을 사용하여 특정 도메인의 상태를 관리하는 클래스들입니다.
현재는 네비게이션 상태만 분리되어 있으며, 추가 분리가 필요합니다.

## 📁 현재 파일 구조

```
providers/
└── navigation_provider.dart  # 185줄 - 듀얼 모드 네비게이션 상태
```

## 🔍 NavigationProvider 분석

### 핵심 기능
```dart
class NavigationProvider extends ChangeNotifier {
  // 듀얼 모드 네비게이션
  NavigationMode mode;     // main | chat
  int mainTabIndex;        // 메인 모드 탭
  int chatTabIndex;        // 채팅 모드 탭
  
  // 모드별 아이템 정의
  static const mainItems;  // 5개 탭
  static const chatItems;  // 4개 탭
}
```

### 모드 전환 로직
- **메인 모드**: 홈, 검색, 질문작성, 채팅, 유저
- **채팅 모드**: 채팅, 친구, 검색, 홈
- 채팅 탭 선택 시 자동으로 채팅 모드로 전환
- 채팅 모드에서 홈 선택 시 메인 모드로 복귀

### 장점
✅ **단일 책임 원칙 준수**  
✅ **명확한 상태 관리**  
✅ **테스트 가능한 구조**  
✅ **UI와 분리된 로직**

## 🎯 향후 추가될 Provider들

### 1. ContentCreationProvider
```dart
// 콘텐츠 생성 상태 관리
class ContentCreationProvider extends ChangeNotifier {
  ContentBox boxA;
  ContentBox boxB;
  String title;
  String description;
  LayoutType layout;
}
```
**이동 위치**: `/lib/features/posts/presentation/providers/`

### 2. MediaUploadProvider
```dart
// 미디어 업로드 상태
class MediaUploadProvider extends ChangeNotifier {
  Map<String, UploadTask> tasks;
  List<File> tempFiles;
  UploadStatus status;
}
```
**이동 위치**: `/lib/features/media/presentation/providers/`

### 3. UserPreferencesProvider
```dart
// 사용자 설정
class UserPreferencesProvider extends ChangeNotifier {
  String language;
  ThemeMode theme;
  NotificationSettings notifications;
}
```
**유지 위치**: `/lib/app/state/providers/`

### 4. AppConfigProvider
```dart
// 앱 설정
class AppConfigProvider extends ChangeNotifier {
  bool isFirstLaunch;
  String appVersion;
  RemoteConfig config;
}
```
**유지 위치**: `/lib/app/state/providers/`

## 📊 Provider 분류 기준

| Provider 타입 | 위치 | 기준 |
|--------------|------|------|
| **Feature Provider** | `/features/[name]/presentation/providers/` | Feature 전용 상태 |
| **App Provider** | `/app/state/providers/` | 전역 앱 상태 |
| **Service Provider** | `/services/providers/` | 서비스 레이어 상태 |

## 🔧 Provider 작성 가이드

### 기본 구조
```dart
class [Name]Provider extends ChangeNotifier {
  // 1. Private 상태 변수
  Type _state;
  
  // 2. Getter (읽기 전용)
  Type get state => _state;
  
  // 3. 상태 변경 메서드
  void updateState(Type newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }
  
  // 4. 비즈니스 로직
  Future<void> performAction() async {
    // 로직 수행
    notifyListeners();
  }
  
  // 5. Dispose (필요시)
  @override
  void dispose() {
    // 리소스 정리
    super.dispose();
  }
}
```

### Best Practices
1. **불변성 유지**: 상태 객체는 불변으로 관리
2. **최소 리빌드**: 필요한 경우에만 notifyListeners() 호출
3. **테스트 가능**: 비즈니스 로직과 UI 분리
4. **메모리 관리**: dispose()에서 리소스 정리

## 📝 사용 예시

### Provider 등록
```dart
// main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => NavigationProvider()),
    ChangeNotifierProvider(create: (_) => ContentCreationProvider()),
  ],
  child: MyApp(),
)
```

### Provider 사용
```dart
// Consumer 패턴
Consumer<NavigationProvider>(
  builder: (context, nav, child) {
    return BottomNavigationBar(
      currentIndex: nav.currentTabIndex,
      onTap: nav.setTabIndex,
    );
  },
)

// context.watch 패턴
final nav = context.watch<NavigationProvider>();

// context.read 패턴 (리빌드 없음)
context.read<NavigationProvider>().switchToChatMode();
```

## ⚠️ 주의사항

1. **순환 의존성 방지**: Provider 간 직접 참조 금지
2. **과도한 리빌드 방지**: Selector 위젯 활용
3. **메모리 누수 방지**: StreamController 등 정리
4. **테스트 작성**: 모든 Provider에 단위 테스트

## 🔗 연관 문서

- [App State README](../README.md)
- [Navigation System](../../../router/navigation/README.md)
- [Feature Architecture](../../../../FEATURE_ARCHITECTURE.md)

---

*이 디렉토리는 Provider 패턴 구현체들을 관리합니다.*
*Feature별 Provider는 해당 Feature 디렉토리로 이동될 예정입니다.*