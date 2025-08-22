# 📢 알림 시스템 (Notification System)

> Versus Space 앱의 통합 알림 시스템으로, 일반 알림과 투표 알림을 모두 지원합니다.

## 📋 개요

알림 시스템은 사용자에게 실시간 정보를 전달하고 상호작용을 유도하는 핵심 컴포넌트입니다. 일반 알림, 투표 요청 알림, 알림 뱃지 등 다양한 형태의 알림을 제공합니다.

### 주요 특징
- 🔔 **일반 알림**: 슬라이드 애니메이션과 자동 사라짐 기능
- 🗳️ **투표 알림**: A/B 선택형 인터랙티브 알림
- 🔴 **알림 뱃지**: 읽지 않은 알림 개수 실시간 표시
- 📱 **멀티이미지 지원**: 각 옵션에 여러 이미지 표시 가능
- 🎨 **스마트 레이아웃**: 이미지 비율에 따른 자동 레이아웃
- ⚡ **실시간 동기화**: Firebase와 연동된 실시간 업데이트

## 🏗️ 아키텍처

```
lib/components/notifications/
│
├── 📱 메인 컴포넌트
│   ├── in_app_notification_dialog.dart      # 일반 알림 다이얼로그
│   ├── notification_overlay.dart            # 통합 알림 오버레이 시스템
│   ├── voting_notification_dialog.dart      # 투표 알림 다이얼로그
│   └── voting_overlay.dart                  # 투표 전용 오버레이 (레거시)
│
├── 🔴 뱃지 시스템
│   ├── notification_badge.dart              # 알림 뱃지 UI 컴포넌트
│   ├── notification_badge_provider.dart     # Firebase 연동 실시간 제공자
│   └── notification_badge_example.dart      # 사용 예제 모음
│
└── 📁 하위 모듈
    ├── constants/                            # 상수 및 제약 조건
    │   └── voting_notification_constraints.dart
    ├── models/                               # 데이터 모델
    │   └── versus_box_size_data.dart
    ├── utils/                                # 유틸리티
    │   └── adaptive_text_size.dart
    └── widgets/                              # UI 위젯
        ├── notification_image_viewer.dart
        └── versus_notification_box.dart
```

## 네이밍 컨벤션

### 파일명
- ✅ **snake_case 사용**: `notification_badge.dart`, `voting_overlay.dart`
- ✅ **기능별 접미사**: `_dialog`, `_overlay`, `_provider`, `_example`

### 클래스명
- ✅ **PascalCase 사용**: `NotificationBadge`, `VotingNotificationDialog`
- ✅ **Widget 접미사 생략**: 모든 UI 컴포넌트는 기본적으로 위젯

### 필드 및 메서드
- ✅ **camelCase 사용**: `showVoting()`, `hasVoted`, `votePercentageA`
- ✅ **private 필드**: `_currentEntry`, `_autoCloseTimer`
- ✅ **boolean 접두사**: `hasVoted`, `showResults`, `enableImageTap`

## 주요 구성요소

### 1. NotificationOverlay (통합 알림 시스템)

**역할**: 모든 알림 표시를 관리하는 중앙 시스템

```dart
class NotificationOverlay {
  // 일반 알림 표시
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onTap,
    String buttonText = '참여하기',
  })

  // 투표 알림 표시 (스마트 레이아웃 지원)
  static void showVoting(
    BuildContext context, {
    required String question,
    required String optionA,
    required String optionB,
    String? imageUrlA,
    String? imageUrlB,
    List<String>? imageUrlsA,       // 멀티이미지
    List<String>? imageUrlsB,       // 멀티이미지
    double? aspectRatioA,            // 스마트 레이아웃
    double? aspectRatioB,            // 스마트 레이아웃
    String? layoutType,              // horizontal/vertical/single
    required Function(String) onVote,
    // ... 추가 옵션들
  })

  // 알림 숨기기
  static void hide()
}
```

**특징**:
- 싱글톤 패턴으로 중복 알림 방지
- 모달 다이얼로그 사용 (92% 화면 너비)
- 검은색 반투명 배경으로 몰입도 향상
- 배경 터치 방지 (barrierDismissible: false)

### 2. InAppNotificationDialog (일반 알림)

**역할**: 앱 내 일반 알림 표시

```dart
class InAppNotificationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;
}
```

**특징**:
- 슬라이드 + 페이드 애니메이션
- 5초 자동 사라짐
- 그라디언트 배경
- 아이콘 + 텍스트 + 버튼 구성

### 3. VotingNotificationDialog (투표 알림)

**역할**: A/B 선택형 투표 알림

```dart
class VotingNotificationDialog extends StatefulWidget {
  // 기본 정보
  final String question;
  final String optionA;
  final String optionB;
  
  // 이미지 (싱글/멀티)
  final String? imageUrlA;
  final String? imageUrlB;
  final List<String>? imageUrlsA;
  final List<String>? imageUrlsB;
  
  // 스마트 레이아웃
  final double? aspectRatioA;
  final double? aspectRatioB;
  final VersusBoxSizeData? sizeData;
  
  // 투표 결과
  final bool showResults;
  final double? votePercentageA;
  final double? votePercentageB;
  
  // 콜백
  final Function(String option) onVote;
  final Function(bool hasVoted)? onDismiss;
}
```

**특징**:
- 10분 자동 닫기 타이머
- 멀티이미지 지원 (PageView)
- 스마트 레이아웃 시스템
- 투표 결과 실시간 표시
- 프로필 이미지 + Pikle 아이콘

### 4. NotificationBadge (알림 뱃지)

**역할**: 읽지 않은 알림 개수 표시

```dart
class NotificationBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final Color? badgeColor;
  final Color? textColor;
  final double? size;
  final bool showZero;
}
```

**특징**:
- 99+ 표시 (100개 이상)
- 커스터마이징 가능한 색상/크기
- Stack 기반 오버레이
- 0개일 때 자동 숨김

### 5. NotificationBadgeProvider (실시간 제공자)

**역할**: Firebase와 연동된 실시간 알림 개수 관리

```dart
class NotificationBadgeProvider extends StatelessWidget {
  final Widget Function(BuildContext context, int count) builder;
}
```

**특징**:
- NotificationService와 연동
- StreamBuilder 기반 실시간 업데이트
- 로그인 상태 자동 체크
- Provider 패턴 사용

## 💻 사용 예시

### 1. 일반 알림 표시

```dart
// 기본 알림
NotificationOverlay.show(
  context,
  title: '새로운 메시지',
  message: '친구가 메시지를 보냈습니다',
  onTap: () {
    // 메시지 페이지로 이동
    context.pushNamed('messages');
  },
);

// 커스텀 버튼 텍스트
NotificationOverlay.show(
  context,
  title: '이벤트 알림',
  message: '새로운 이벤트가 시작되었습니다',
  buttonText: '지금 참여',
  onTap: () => joinEvent(),
);
```

### 2. 투표 알림 표시

```dart
// 기본 투표 알림
NotificationOverlay.showVoting(
  context,
  question: '어떤 디자인이 더 좋나요?',
  optionA: '모던한 스타일',
  optionB: '클래식한 스타일',
  imageUrlA: 'https://example.com/modern.jpg',
  imageUrlB: 'https://example.com/classic.jpg',
  onVote: (option) {
    print('선택: $option');
    // 투표 처리
  },
);

// 멀티이미지 + 스마트 레이아웃
NotificationOverlay.showVoting(
  context,
  question: '어떤 스타일이 더 좋나요?',
  optionA: '스타일 A',
  optionB: '스타일 B',
  imageUrlsA: [
    'https://example.com/a1.jpg',
    'https://example.com/a2.jpg',
    'https://example.com/a3.jpg',
  ],
  imageUrlsB: [
    'https://example.com/b1.jpg',
    'https://example.com/b2.jpg',
  ],
  aspectRatioA: 1.5,  // 가로형
  aspectRatioB: 0.75, // 세로형
  layoutType: 'vertical', // 세로 배치
  authorName: '홍길동',
  onVote: (option) async {
    await submitVote(option);
  },
);

// 투표 결과 표시
NotificationOverlay.showVoting(
  context,
  question: '투표가 완료되었습니다',
  optionA: '옵션 A',
  optionB: '옵션 B',
  showResults: true,
  votePercentageA: 0.65,
  votePercentageB: 0.35,
  voteCountA: 13,
  voteCountB: 7,
  onVote: (_) {}, // 결과 모드에서는 투표 불가
);
```

### 3. 알림 뱃지 사용

```dart
// 기본 사용
NotificationBadge(
  count: 5,
  child: Icon(Icons.notifications),
);

// AppBar에서 사용
AppBar(
  title: Text('Versus Space'),
  actions: [
    NotificationAppBarAction(
      onPressed: () {
        context.pushNamed('notificationsList');
      },
    ),
  ],
);

// 실시간 업데이트
NotificationBadgeProvider(
  builder: (context, count) {
    return IconButton(
      icon: NotificationBadge(
        count: count,
        child: Icon(Icons.notifications),
      ),
      onPressed: () => openNotifications(),
    );
  },
);

// BottomNavigationBar에서 사용
NotificationBadgeProvider(
  builder: (context, count) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon: NotificationBadge(
            count: count,
            child: Icon(Icons.notifications),
          ),
          label: '알림',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: '프로필',
        ),
      ],
    );
  },
);
```

## 🎨 커스터마이징

### 알림 스타일 커스터마이징

```dart
// 커스텀 뱃지 색상
NotificationBadge(
  count: 10,
  badgeColor: Colors.green,
  textColor: Colors.white,
  size: 20.0,
  child: Icon(Icons.email),
);

// 디버그 모드 활성화
NotificationOverlay.showVoting(
  context,
  // ... 기본 파라미터
  showDebugInfo: true, // 박스 크기 정보 표시
);
```

### 애니메이션 커스터마이징

```dart
// InAppNotificationDialog 애니메이션 수정
// in_app_notification_dialog.dart 파일에서:
_controller = AnimationController(
  duration: const Duration(milliseconds: 500), // 애니메이션 시간
  vsync: this,
);

// 자동 사라짐 시간 변경
Future.delayed(const Duration(seconds: 5), () { // 5초 → 원하는 시간
  if (mounted) _dismiss();
});
```

## 🔧 고급 기능

### 1. 멀티이미지 뷰어

```dart
// NotificationImageViewer 직접 사용
NotificationImageViewer.show(
  context,
  question: '질문',
  optionA: '옵션 A',
  optionB: '옵션 B',
  imageUrlsA: imageListA,
  imageUrlsB: imageListB,
  initialBox: 'A',
  initialIndex: 0,
);
```

### 2. 스마트 레이아웃 시스템

```dart
// AspectRatio 기반 자동 레이아웃
// 이미지 비율 분석 → 최적 레이아웃 결정
if (aspectRatioA > 1.0 && aspectRatioB > 1.0) {
  // 둘 다 가로형 → 세로 배치
  layoutType = LayoutType.vertical;
} else if (aspectRatioA < 1.0 && aspectRatioB < 1.0) {
  // 둘 다 세로형 → 가로 배치
  layoutType = LayoutType.horizontal;
}
```

### 3. 사이즈 데이터 바인딩

```dart
// 질문 작성 시 크기 캡처
final sizeData = VersusBoxSizeCalculator.captureCurrentSizes(
  context, 
  appState, 
  model
);

// 알림 표시 시 동일 크기 적용
NotificationOverlay.showVoting(
  context,
  sizeData: sizeData,
  // ... 기타 파라미터
);
```

## 🐛 트러블슈팅

### 자주 발생하는 문제

#### 1. 알림이 표시되지 않음
```dart
// 원인: BuildContext가 올바르지 않음
// 해결: Navigator context 사용
final navigatorContext = Navigator.of(context).context;
NotificationOverlay.show(navigatorContext, ...);
```

#### 2. 뱃지 개수가 업데이트되지 않음
```dart
// 원인: NotificationService가 초기화되지 않음
// 해결: main.dart에서 Provider 설정 확인
runApp(
  MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => NotificationService()),
    ],
    child: MyApp(),
  ),
);
```

#### 3. 투표 알림 레이아웃이 깨짐
```dart
// 원인: aspectRatio 정보가 전달되지 않음
// 해결: Firestore 저장 시 aspectRatio 포함
await FirebaseFirestore.instance.collection('posts').add({
  'optionA': {
    'title': titleA,
    'imageUrl': imageUrlA,
    'aspectRatio': aspectRatioA, // 필수
  },
  'optionB': {
    'title': titleB,
    'imageUrl': imageUrlB,
    'aspectRatio': aspectRatioB, // 필수
  },
  'layoutType': layoutType, // 필수
});
```

#### 4. 멀티이미지가 표시되지 않음
```dart
// 원인: imageUrls 파라미터 누락
// 해결: effectiveImageUrls 사용
imageUrls: widget.effectiveImageUrlsA, // imageUrlsA ?? [imageUrlA]
```

## 📊 성능 최적화

### 1. 이미지 캐싱
```dart
// CachedNetworkImage 사용
CachedNetworkImage(
  imageUrl: imageUrl,
  memCacheWidth: 800, // 메모리 캐시 크기 제한
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
);
```

### 2. 메모리 관리
```dart
// 타이머와 컨트롤러 정리
@override
void dispose() {
  _autoCloseTimer?.cancel();
  _controller.dispose();
  super.dispose();
}
```

### 3. 스트림 최적화
```dart
// 불필요한 리빌드 방지
StreamBuilder<int>(
  stream: notificationService.getUnreadNotificationCount(userId),
  initialData: 0, // 초기값 설정
  builder: (context, snapshot) {
    if (!snapshot.hasData) return SizedBox.shrink();
    return NotificationBadge(count: snapshot.data!);
  },
);
```

## 🧪 테스팅

### 단위 테스트
```dart
testWidgets('NotificationBadge 표시 테스트', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: NotificationBadge(
        count: 5,
        child: Icon(Icons.notifications),
      ),
    ),
  );
  
  expect(find.text('5'), findsOneWidget);
  expect(find.byIcon(Icons.notifications), findsOneWidget);
});
```

### 통합 테스트
```dart
testWidgets('투표 알림 플로우 테스트', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // 알림 표시
  NotificationOverlay.showVoting(
    tester.element(find.byType(MyApp)),
    question: '테스트 질문',
    optionA: 'A',
    optionB: 'B',
    onVote: (option) => selectedOption = option,
  );
  await tester.pump();
  
  // A 선택
  await tester.tap(find.text('A 선택'));
  await tester.pump();
  
  expect(selectedOption, 'A');
});
```

## 📈 성능 지표

### 목표 성능
- **알림 표시 시간**: <100ms
- **애니메이션 프레임**: 60fps 유지
- **메모리 사용량**: <5MB (이미지 제외)
- **Firebase 동기화**: <500ms

### 모니터링
```dart
// 성능 측정
final stopwatch = Stopwatch()..start();
NotificationOverlay.show(context, ...);
print('알림 표시 시간: ${stopwatch.elapsedMilliseconds}ms');

// 메모리 사용량
if (kDebugMode) {
  final usage = ProcessInfo.currentRss / 1024 / 1024;
  print('메모리 사용량: ${usage.toStringAsFixed(1)}MB');
}
```

## 변경 이력

### v2.0.0 (2025-08-22)
- 전체 알림 시스템 통합 문서화
- 메인 디렉토리 아키텍처 문서 작성
- 하위 모듈 통합 및 연계 설명

### v1.3.0 (2025-08-04)
- 스마트 레이아웃 시스템 통합
- AspectRatio 데이터 전달 체인 구축
- 레이아웃 타입 자동 결정

### v1.2.0 (2025-07-25)
- 단일 이미지 모드 개선
- 멀티이미지 뷰어 수정
- 텍스트 크기 조정

### v1.1.0 (2025-07-23)
- 멀티이미지 지원
- 박스 크기 평균화
- 모달 UI 개선

### v1.0.0 (2025-07-20)
- 초기 릴리스
- 기본 알림 시스템 구현
- 투표 알림 기능

---

**문서 버전**: 2.0.0  
**최종 업데이트**: 2025-08-22  
**관리**: Versus Space 개발팀