# Navigation Components - 앱 네비게이션 시스템

Versus Space 앱의 듀얼 모드 하단 네비게이션 바 시스템을 관리하는 컴포넌트입니다.

## 📋 개요

이 디렉토리는 앱의 주요 네비게이션 인터페이스를 담당하는 컴포넌트들을 포함합니다. 특별히 설계된 듀얼 모드 네비게이션 시스템을 통해 사용자의 컨텍스트(메인/채팅)에 따라 다른 네비게이션 아이템을 표시하며, GoRouter와 완벽하게 통합되어 부드러운 페이지 전환을 제공합니다.

### 주요 특징
- **듀얼 모드 시스템**: 메인 모드(5개 탭)와 채팅 모드(4개 탭) 자동 전환
- **컨텍스트 인식**: 사용자 행동에 따른 스마트 모드 전환
- **애니메이션 전환**: 300ms 부드러운 전환 효과
- **GoRouter 통합**: ShellRoute를 통한 네비게이션 바 유지
- **Provider 패턴**: NavigationProvider를 통한 상태 관리
- **디자인 시스템 통합**: VersusColors, VersusTextStyles 일관된 사용

## 🎯 네이밍 컨벤션

### 파일명
- **Dart 파일**: snake_case (`main_navigation_shell.dart`)
- **README**: 대문자 확장자 (`README.md`)

### 코드 내 명명 규칙
- **클래스명**: PascalCase (`MainNavigationShell`, `NavigationItemWidget`)
- **변수/메서드**: camelCase (`currentIndex`, `onItemTapped()`)
- **상수**: camelCase 또는 SCREAMING_SNAKE_CASE
- **Enum**: PascalCase (`NavigationMode`)

참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 🔧 주요 구성요소

### 1. MainNavigationShell
**파일**: `main_navigation_shell.dart`  
**용도**: 앱의 메인 네비게이션 쉘로, 하단 네비게이션 바와 페이지 콘텐츠를 관리

#### 주요 속성
| 속성 | 타입 | 설명 |
|------|------|------|
| `child` | Widget | GoRouter에서 제공하는 현재 페이지 콘텐츠 |

#### 핵심 기능
```dart
class MainNavigationShell extends StatelessWidget {
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, _) {
        return Scaffold(
          body: child,  // 현재 라우트의 페이지
          bottomNavigationBar: _buildBottomNavigationBar(context, navigationProvider),
        );
      },
    );
  }
}
```

#### 듀얼 모드 네비게이션
- **메인 모드**: 일반 사용 시 표시되는 5개 탭
- **채팅 모드**: 채팅 섹션 진입 시 표시되는 4개 탭

### 2. NavigationItemWidget (옵션)
**파일**: `main_navigation_shell.dart`  
**용도**: 커스텀 네비게이션 아이템 위젯 (현재 미사용, 향후 확장용)

#### 주요 속성
| 속성 | 타입 | 설명 |
|------|------|------|
| `item` | NavigationItem | 네비게이션 아이템 데이터 |
| `isSelected` | bool | 선택 상태 |
| `onTap` | VoidCallback | 탭 이벤트 핸들러 |

## 🗺️ 네비게이션 구조

### 메인 모드 (NavigationMode.main)
```dart
// 5개 탭 구성
1. 홈        - Icons.home_outlined / home        → '/home'
2. 검색      - Icons.search_outlined / search     → '/search'  
3. 질문작성  - Icons.add_circle_outline / add_circle → '/inPutPostImage'
4. 채팅      - Icons.chat_bubble_outline / chat_bubble → '/chat/list'
5. 프로필    - Icons.person_outline / person      → '/profile'
```

### 채팅 모드 (NavigationMode.chat)
```dart
// 4개 탭 구성
1. 채팅목록  - Icons.chat_bubble_outline / chat_bubble → '/chat/list'
2. 친구목록  - Icons.people_outline / people       → '/chat/friends'
3. 채팅검색  - Icons.search_outlined / search      → '/chat/search'
4. 홈       - Icons.home_outlined / home          → '/home'
```

## 💡 사용 예시

### GoRouter 설정
```dart
final GoRouter _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainNavigationShell(
        child: child,  // 현재 라우트의 페이지
      ),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => HomePage(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => SearchPage(),
        ),
        GoRoute(
          path: '/inPutPostImage',
          builder: (context, state) => InPutPostImagePage(),
        ),
        GoRoute(
          path: '/chat/list',
          builder: (context, state) => ChatListPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => ProfilePage(),
        ),
        // 채팅 모드 추가 라우트
        GoRoute(
          path: '/chat/friends',
          builder: (context, state) => FriendsListPage(),
        ),
        GoRoute(
          path: '/chat/search',
          builder: (context, state) => ChatSearchPage(),
        ),
      ],
    ),
  ],
);
```

### NavigationProvider 설정
```dart
// main.dart 또는 앱 초기화 부분
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => NavigationProvider()),
    // 다른 Provider들...
  ],
  child: MyApp(),
)
```

## 🔄 모드 전환 로직

### 자동 모드 전환
```dart
void _onItemTapped(BuildContext context, NavigationProvider provider, int index) {
  final items = provider.currentItems;
  final selectedItem = items[index];
  
  // 메인 모드에서 채팅 탭(인덱스 3) 선택 시
  if (provider.mode == NavigationMode.main && index == 3) {
    provider.switchToChatMode();  // 채팅 모드로 전환
    context.go('/chat/list');
  } 
  // 채팅 모드에서 홈 탭(인덱스 3) 선택 시
  else if (provider.mode == NavigationMode.chat && index == 3) {
    provider.switchToMainMode();  // 메인 모드로 복귀
    context.go('/home');
  } 
  // 일반적인 탭 선택
  else {
    provider.setTabIndex(index);
    context.go(selectedItem.route);
  }
}
```

### 프로그래매틱 모드 전환
```dart
// 코드에서 직접 모드 전환
final navigationProvider = context.read<NavigationProvider>();

// 채팅 모드로 전환
navigationProvider.switchToChatMode();

// 메인 모드로 전환
navigationProvider.switchToMainMode();

// 특정 탭으로 이동
navigationProvider.setTabIndex(2);
```

## 🎨 디자인 시스템

### 색상 체계
- **선택된 아이템**: `VersusColors.primary` (빨간색 계열)
- **미선택 아이템**: `VersusColors.textSecondary` (회색 계열)
- **배경**: `Colors.white` (흰색)
- **그림자**: `Colors.black.withOpacity(0.1)` (연한 검은색)

### 타이포그래피
- **선택된 레이블**: `VersusTextStyles.labelSmall` + `FontWeight.w600`
- **미선택 레이블**: `VersusTextStyles.labelSmall` + `FontWeight.normal`

### 애니메이션
```dart
// 컨테이너 애니메이션
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeInOut,
  // ...
)

// 아이콘 전환 애니메이션
AnimatedSwitcher(
  duration: const Duration(milliseconds: 200),
  child: Icon(
    isSelected ? item.activeIcon : item.icon,
    key: ValueKey(isSelected),  // 애니메이션 트리거
  ),
)
```

### 그림자 효과
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 10,
  offset: const Offset(0, -5),  // 위쪽에서 내려오는 그림자
)
```

## ⚡ 성능 최적화

### Consumer 패턴 사용
```dart
// 필요한 부분만 리빌드
Consumer<NavigationProvider>(
  builder: (context, navigationProvider, _) {
    // navigationProvider 변경 시에만 리빌드
    return _buildBottomNavigationBar(context, navigationProvider);
  },
)
```

### AnimatedSwitcher 키 사용
```dart
// ValueKey로 애니메이션 최적화
Icon(
  isSelected ? item.activeIcon : item.icon,
  key: ValueKey(isSelected),  // 상태 변경 시에만 애니메이션
)
```

### BottomNavigationBar 타입 최적화
```dart
// fixed 타입으로 일관된 레이아웃 유지
type: BottomNavigationBarType.fixed,
```

## 🔗 관련 파일

### Provider
- `/lib/providers/navigation_provider.dart` - 네비게이션 상태 관리

### 페이지
- `/lib/pages/home/` - 홈 페이지
- `/lib/pages/search/` - 검색 페이지
- `/lib/posts/in_put_post_image/` - 질문 작성 페이지
- `/lib/pages/chat/chat_list/` - 채팅 목록 페이지
- `/lib/pages/profile/` - 프로필 페이지
- `/lib/pages/chat/friends_list/` - 친구 목록 페이지
- `/lib/pages/chat/chat_search/` - 채팅 검색 페이지

### 라우팅
- `/lib/core/nav/nav.dart` - GoRouter 설정

### 디자인 시스템
- `/lib/design_system/design_system.dart` - 통합 디자인 시스템

## 📊 아키텍처 다이어그램

```
MainNavigationShell
    ├── NavigationProvider (상태 관리)
    │   ├── NavigationMode (main/chat)
    │   ├── currentItems (현재 탭 리스트)
    │   └── currentTabIndex (선택된 탭)
    ├── BottomNavigationBar (UI)
    │   ├── 메인 모드 (5개 탭)
    │   └── 채팅 모드 (4개 탭)
    └── GoRouter (라우팅)
        ├── ShellRoute (네비게이션 바 유지)
        └── child (현재 페이지 콘텐츠)
```

## 🐛 문제 해결

### 네비게이션 바가 사라지는 문제
```dart
// 문제: 특정 페이지에서 네비게이션 바가 사라짐
// 원인: ShellRoute 외부에 라우트 정의

// 해결책: 모든 네비게이션 바가 필요한 라우트를 ShellRoute 내부에 정의
ShellRoute(
  builder: (context, state, child) => MainNavigationShell(child: child),
  routes: [
    // 여기에 모든 네비게이션 바가 필요한 라우트 정의
  ],
)
```

### 탭 선택 상태가 유지되지 않는 문제
```dart
// 문제: 페이지 이동 후 탭 선택 상태가 초기화됨
// 원인: NavigationProvider 상태 관리 누락

// 해결책: NavigationProvider의 setTabIndex 호출
provider.setTabIndex(index);
context.go(selectedItem.route);
```

### 애니메이션이 작동하지 않는 문제
```dart
// 문제: 아이콘 전환 애니메이션이 보이지 않음
// 원인: AnimatedSwitcher에 key가 없음

// 해결책: ValueKey 추가
AnimatedSwitcher(
  child: Icon(
    icon,
    key: ValueKey(isSelected),  // 필수!
  ),
)
```

## 📝 변경 이력

- **2025-08-22**: 문서 전체 개정 및 상세 설명 추가
- **2025-07-25**: 듀얼 모드 네비게이션 시스템 구현
- **2025-07-25**: 디자인 시스템 적용 완료
- **2025-07-20**: 초기 네비게이션 컴포넌트 생성

---

*이 문서는 `/lib/components/navigation` 디렉토리의 앱 네비게이션 시스템을 설명합니다.*