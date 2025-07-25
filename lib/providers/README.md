# Providers

## 개요

Provider 패턴을 사용한 상태 관리 디렉토리입니다. 현재 NavigationProvider가 구현되어 있으며, 앱의 네비게이션 상태를 중앙에서 관리합니다.

## NavigationProvider

### 목적
앱의 하단 네비게이션 바 상태를 관리하고, 듀얼 모드 네비게이션 시스템을 구현합니다.

### 주요 기능

#### 1. 네비게이션 모드 관리
```dart
enum NavigationMode {
  main, // 기본 모드: 홈/검색/질문작성/채팅/유저
  chat, // 채팅 모드: 채팅/친구/검색/홈
}
```

#### 2. 탭 인덱스 관리
- `mainTabIndex`: 메인 모드에서의 선택된 탭
- `chatTabIndex`: 채팅 모드에서의 선택된 탭
- 각 모드별로 독립적인 탭 상태 유지

#### 3. 네비게이션 아이템 정의
- `mainItems`: 메인 모드 5개 아이템
- `chatItems`: 채팅 모드 4개 아이템
- 각 아이템은 label, icon, activeIcon, route 포함

### 주요 메서드

#### setMode(NavigationMode mode)
네비게이션 모드를 변경합니다.
```dart
provider.setMode(NavigationMode.chat);
```

#### switchToMainMode() / switchToChatMode()
편의 메서드로 특정 모드로 전환합니다.

#### setTabIndex(int index)
현재 모드에서 탭을 선택합니다. 특별한 로직:
- 메인 모드에서 채팅(3번) 선택 → 채팅 모드로 전환
- 채팅 모드에서 홈(3번) 선택 → 메인 모드로 전환

#### navigateToRoute(String route)
라우트에 따라 적절한 모드와 탭을 자동으로 설정합니다.

### 사용 예시

#### Provider 등록 (main.dart)
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => NavigationProvider()),
    // ... other providers
  ],
  child: MyApp(),
)
```

#### Consumer 사용
```dart
Consumer<NavigationProvider>(
  builder: (context, navigationProvider, child) {
    // navigationProvider의 상태 사용
    final currentMode = navigationProvider.mode;
    final currentIndex = navigationProvider.currentTabIndex;
    return YourWidget();
  },
)
```

#### 직접 접근
```dart
final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
navigationProvider.switchToChatMode();
```

### 상태 흐름

1. **초기 상태**: main 모드, 0번 탭 (홈)
2. **채팅 진입**: 
   - 메인 모드 → 채팅 탭 클릭
   - 채팅 모드로 전환
   - 채팅 리스트 표시
3. **홈 복귀**:
   - 채팅 모드 → 홈 탭 클릭
   - 메인 모드로 전환
   - 홈 피드 표시

### 라우트 매핑

#### 메인 모드 라우트
- `/home` → 0번 탭
- `/search` → 1번 탭
- `/inPutPostImage` → 2번 탭
- `/profile` → 4번 탭

#### 채팅 모드 라우트
- `/chat/list` → 0번 탭
- `/chat/friends` → 1번 탭
- `/chat/search` → 2번 탭

## 향후 확장 가능성

1. **UserProvider**: 사용자 정보 및 인증 상태 관리
2. **PostProvider**: 게시물 목록 및 상태 관리
3. **NotificationProvider**: 알림 상태 관리
4. **ThemeProvider**: 테마 설정 관리

## 파일 위치
- `/lib/providers/navigation_provider.dart`

## 업데이트 이력
- 2025-07-25: NavigationProvider 구현
- 2025-07-25: 듀얼 모드 네비게이션 시스템 완성