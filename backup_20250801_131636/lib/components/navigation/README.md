# Navigation Components

## 개요

네비게이션 컴포넌트는 Versus Space 앱의 하단 네비게이션 바를 관리하는 시스템입니다. 특별히 설계된 듀얼 모드 네비게이션을 통해 컨텍스트에 따라 다른 네비게이션 아이템을 표시합니다.

## 주요 컴포넌트

### MainNavigationShell

앱의 메인 네비게이션 쉘로, GoRouter의 ShellRoute와 함께 작동하여 페이지 전환 시에도 하단 네비게이션 바를 유지합니다.

#### 주요 기능

1. **듀얼 모드 지원**
   - **메인 모드**: 홈 / 검색 / 질문작성 / 채팅 / 유저 (5개 탭)
   - **채팅 모드**: 채팅 / 친구 / 검색 / 홈 (4개 탭)

2. **애니메이션 전환**
   - 300ms 지속 시간의 부드러운 전환
   - 아이콘 스위처로 선택/비선택 상태 전환
   - 그림자 효과로 입체감 추가

3. **스마트 라우팅**
   - 메인 모드에서 채팅 탭 선택 → 채팅 모드로 자동 전환
   - 채팅 모드에서 홈 탭 선택 → 메인 모드로 복귀

## 디자인 시스템 적용

### 색상
- **선택된 아이템**: `VersusColors.primary` (빨간색)
- **선택되지 않은 아이템**: `VersusColors.textSecondary`
- **배경**: 흰색 with 그림자 효과

### 텍스트 스타일
- **선택된 레이블**: `VersusTextStyles.labelSmall` + FontWeight.w600
- **선택되지 않은 레이블**: `VersusTextStyles.labelSmall`

### 애니메이션
- **전환 시간**: 300ms (Curves.easeInOut)
- **아이콘 전환**: 200ms (AnimatedSwitcher)

## NavigationProvider 연동

```dart
Consumer<NavigationProvider>(
  builder: (context, navigationProvider, _) {
    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(context, navigationProvider),
    );
  },
)
```

## 네비게이션 아이템 구조

### NavigationItem 클래스
```dart
class NavigationItem {
  final String label;        // 표시 텍스트
  final IconData icon;       // 기본 아이콘
  final IconData activeIcon; // 선택 시 아이콘
  final String route;        // 라우트 경로
}
```

### 메인 모드 아이템
1. 홈 (home_outlined / home) → `/home`
2. 검색 (search_outlined / search) → `/search`
3. 질문작성 (add_circle_outline / add_circle) → `/inPutPostImage`
4. 채팅 (chat_bubble_outline / chat_bubble) → `/chat/list`
5. 유저 (person_outline / person) → `/profile`

### 채팅 모드 아이템
1. 채팅 (chat_bubble_outline / chat_bubble) → `/chat/list`
2. 친구 (people_outline / people) → `/chat/friends`
3. 검색 (search_outlined / search) → `/chat/search`
4. 홈 (home_outlined / home) → `/home`

## 추가 컴포넌트

### NavigationItemWidget (미사용)

커스텀 네비게이션 아이템 위젯으로, 향후 더 복잡한 디자인이 필요할 때 사용할 수 있도록 준비되어 있습니다.

## 파일 위치
- `/lib/components/navigation/main_navigation_shell.dart`

## 사용 방법

GoRouter의 ShellRoute에서 builder로 지정:
```dart
ShellRoute(
  builder: (context, state, child) => MainNavigationShell(child: child),
  routes: [ ... ]
)
```

## 업데이트 이력
- 2025-07-25: 듀얼 모드 네비게이션 시스템 구현
- 2025-07-25: 디자인 시스템 적용 완료