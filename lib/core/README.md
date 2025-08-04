# Core Utilities

Versus Space 앱의 핵심 유틸리티 및 공통 기능을 관리하는 디렉토리입니다.

## 📋 개요

이 디렉토리는 원래 FlutterFlow의 `flutter_flow` 디렉토리였으나, 네이티브 Flutter로 마이그레이션하면서 `core`로 이름이 변경되었습니다.

## 디렉토리 구조

```
core/
├── nav/                        # 네비게이션 유틸리티
│   └── nav.dart               # GoRouter 설정 및 헬퍼
├── app_theme.dart             # 앱 테마 설정 (이전 flutter_flow_theme.dart)
├── app_utils.dart             # 유틸리티 함수 (이전 flutter_flow_util.dart)
├── app_widgets.dart           # 공통 위젯 (이전 flutter_flow_widgets.dart)
├── app_icon_button.dart       # 아이콘 버튼 컴포넌트
├── app_animations.dart        # 애니메이션 유틸리티
├── app_timer.dart             # 타이머 관리
├── app_toggle_icon.dart       # 토글 아이콘
├── app_video_player.dart      # 비디오 플레이어 래퍼
├── app_drop_down.dart         # 드롭다운 컴포넌트
├── custom_functions.dart      # 커스텀 함수 모음
├── internationalization.dart  # 다국어 지원
├── lat_lng.dart              # 위치 데이터 모델
├── place.dart                # 장소 데이터 모델
└── uploaded_file.dart        # 업로드 파일 모델
```

## 주요 컴포넌트

### 1. 앱 테마 (app_theme.dart)

앱 전체의 시각적 스타일을 정의합니다.

```dart
class AppTheme {
  // 색상 팔레트
  static const Color primary = Color(0xFFFDCB00);      // 노란색
  static const Color secondary = Color(0xFF000000);    // 검은색
  static const Color tertiary = Color(0xFFFF0040);     // 빨간색
  static const Color alternate = Color(0xFFE0E3E7);    // 회색
  
  // 테마별 색상 세트
  static const ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: Color(0xFFF1F4F8),
    // ...
  );
  
  static const ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: Color(0xFF1A1F24),
    // ...
  );
}

// 텍스트 스타일
extension TextStyling on TextTheme {
  // Display 스타일 (큰 제목)
  TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
    fontSize: 57,
    fontWeight: FontWeight.normal,
  );
  
  // Heading 스타일
  TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.w600,
  );
  
  // Body 스타일
  TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
}
```

### 2. 유틸리티 함수 (app_utils.dart)

앱 전반에서 사용되는 헬퍼 함수들입니다.

```dart
// 날짜 포매팅
String dateTimeFormat(String format, DateTime? dateTime) {
  if (dateTime == null) return '';
  return DateFormat(format, AppLocalizations.of(context)?.languageCode)
    .format(dateTime);
}

// 상대 시간 표시
String timeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  
  if (difference.inDays > 7) {
    return dateTimeFormat('MMM d, y', dateTime);
  } else if (difference.inDays > 0) {
    return '${difference.inDays}일 전';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}시간 전';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}분 전';
  } else {
    return '방금 전';
  }
}

// JSON 안전 파싱
dynamic getJsonField(
  dynamic response,
  String jsonPath, [
  bool isForList = false,
]) {
  try {
    final field = JsonPath(jsonPath).read(response);
    if (field.isEmpty) return null;
    return isForList ? field.map((e) => e.value).toList() : field.first.value;
  } catch (e) {
    return null;
  }
}

// 네비게이션 유틸리티
void showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppTheme.primary,
    ),
  );
}
```

### 3. 공통 위젯 (app_widgets.dart)

재사용 가능한 UI 컴포넌트들입니다.

```dart
// 기본 버튼
class AppButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final double? width;
  final double height;
  
  const AppButtonWidget({
    Key? key,
    required this.text,
    this.onPressed,
    this.color,
    this.width,
    this.height = 50,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(text),
      ),
    );
  }
}

// 아이콘 버튼
class AppIconButton extends StatelessWidget {
  final double? borderRadius;
  final double? buttonSize;
  final Color? fillColor;
  final Icon icon;
  final VoidCallback? onPressed;
  
  // ...
}
```

### 4. 네비게이션 (nav/nav.dart)

GoRouter 기반 네비게이션 설정입니다.

```dart
// 라우트 설정
final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      name: 'HomePage',
      path: '/',
      builder: (context, params) => HomePage(),
    ),
    GoRoute(
      name: 'LoginPage',
      path: '/login',
      builder: (context, params) => LoginPage(),
    ),
    // ... 더 많은 라우트
  ],
);

// 네비게이션 헬퍼
extension NavExtension on BuildContext {
  void navigateTo(String routeName, {Map<String, String>? params}) {
    GoRouter.of(this).pushNamed(routeName, params: params ?? {});
  }
  
  void navigateBack() {
    if (GoRouter.of(this).canPop()) {
      GoRouter.of(this).pop();
    } else {
      GoRouter.of(this).go('/');
    }
  }
}
```

### 5. 다국어 지원 (internationalization.dart)

앱의 다국어 기능을 관리합니다.

```dart
class AppLocalizations {
  final Locale locale;
  
  static const List<String> supportedLanguages = ['en', 'de'];
  
  // 번역 맵
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Versus Space',
      'login': 'Login',
      'signup': 'Sign Up',
      // ...
    },
    'de': {
      'appTitle': 'Versus Space',
      'login': 'Anmelden',
      'signup': 'Registrieren',
      // ...
    },
  };
  
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}
```

### 6. 커스텀 함수 (custom_functions.dart)

비즈니스 로직을 위한 커스텀 함수들입니다.

```dart
// 나이 검증 (13세 이상)
bool isAge13OrAbove(DateTime? birthday) {
  if (birthday == null) return false;
  
  final now = DateTime.now();
  final age = now.year - birthday.year;
  
  if (now.month < birthday.month ||
      (now.month == birthday.month && now.day < birthday.day)) {
    return age - 1 >= 13;
  }
  
  return age >= 13;
}

// 비디오 종횡비 계산
double calculateAspectRatio(double width, double height) {
  if (height == 0) return 1.0;
  return width / height;
}

// 파일 크기 포맷팅
String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
  return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(1)} GB';
}
```

## 마이그레이션 노트

### FlutterFlow → Native Flutter (2025-07-03)
- `FFAppState` → `AppState`
- `FlutterFlowTheme` → `AppTheme`
- `FlutterFlowUtil` → `AppUtils`
- `FlutterFlowWidgets` → `AppWidgets`
- 모든 FF 접두사 제거

### 호환성 유지
```dart
// 이전 버전과의 호환성을 위한 타입 별칭
typedef FFAppState = AppState;
typedef FlutterFlowTheme = AppTheme;
```

## 사용 가이드

### 1. 테마 사용
```dart
// 색상 사용
Container(
  color: AppTheme.of(context).primary,
)

// 텍스트 스타일 사용
Text(
  'Hello',
  style: AppTheme.of(context).titleLarge,
)
```

### 2. 유틸리티 함수 사용
```dart
// 날짜 포맷팅
Text(dateTimeFormat('MMM d, y', post.createdAt))

// 스낵바 표시
showSnackbar(context, '저장되었습니다');
```

### 3. 네비게이션
```dart
// 페이지 이동
context.pushNamed('ProfilePage', params: {'userId': userId});

// 뒤로 가기
context.pop();
```

## 성능 최적화

1. **지연 로딩**: 무거운 컴포넌트는 필요 시 로드
2. **캐싱**: 자주 사용되는 값은 메모리에 캐싱
3. **const 사용**: 가능한 모든 곳에 const 키워드 사용

## 향후 개선 사항

1. **테마 확장**: 더 많은 색상 및 스타일 옵션
2. **유틸리티 추가**: 자주 사용되는 패턴 추가
3. **성능 모니터링**: 유틸리티 함수 성능 추적