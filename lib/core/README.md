# 📦 핵심 유틸리티 라이브러리 (Core Utilities Library)

> Versus Space 앱의 공통 기능과 유틸리티를 제공하는 중앙 라이브러리

## 개요

`/lib/core` 디렉토리는 앱 전체에서 재사용되는 핵심 유틸리티와 공통 컴포넌트를 모아놓은 중앙 라이브러리입니다. 원래 FlutterFlow의 `flutter_flow` 디렉토리였으나, 2025-07-03 네이티브 Flutter로 마이그레이션하면서 `core`로 이름이 변경되었습니다.

### 주요 특징
- 🎨 **테마 시스템**: Light/Dark 모드 지원하는 통합 테마 관리
- 🚀 **네비게이션**: GoRouter 기반 선언적 라우팅 시스템
- 🌍 **국제화**: 다국어 지원 (영어, 독일어)
- 🔧 **유틸리티**: 날짜 포맷, JSON 파싱, 파일 관리 등 헬퍼 함수
- 🎭 **애니메이션**: Flutter Animate 기반 애니메이션 유틸리티
- 📱 **위젯 라이브러리**: 재사용 가능한 UI 컴포넌트
- 🔄 **상태 관리**: AppModel 기반 컴포넌트 상태 관리

## 네이밍 컨벤션

### 파일명
- ✅ **snake_case 사용**: `app_utils.dart`, `app_theme.dart`, `custom_functions.dart`
- ✅ **app_ 접두사**: FlutterFlow 마이그레이션 후 일관성 유지
- ✅ **기능별 명명**: `uploaded_file.dart`, `place.dart`, `lat_lng.dart`

### 클래스명
- ✅ **PascalCase 사용**: `AppTheme`, `AppModel`, `AppLocalizations`
- ✅ **명확한 역할 표현**: `FormFieldController`, `AppUploadedFile`

### 필드 및 메서드
- ✅ **camelCase 사용**: `primaryColor`, `showSnackbar`, `dateTimeFormat`
- ✅ **private 필드**: `_prefs`, `_isInitialized`, `_context`
- ✅ **boolean 접두사**: `isAge13OrAbove`, `isEmpty`, `hasTransition`

참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)

## 주요 구성요소

### 1. 테마 시스템 (app_theme.dart)

**역할**: 앱 전체의 시각적 스타일과 테마를 중앙에서 관리

```dart
abstract class AppTheme {
  // 색상 팔레트
  late Color primary;        // 주요 색상 (빨간색)
  late Color secondary;       // 보조 색상 (초록색)
  late Color tertiary;        // 제3색상 (베이지)
  late Color alternate;       // 대체 색상 (회색)
  
  // 텍스트 색상
  late Color primaryText;     // 주요 텍스트
  late Color secondaryText;   // 보조 텍스트
  
  // 배경 색상
  late Color primaryBackground;
  late Color secondaryBackground;
  
  // 상태 색상
  late Color success;
  late Color warning;
  late Color error;
  late Color info;
}
```

**테마 모드**:
- Light Mode: 밝은 배경에 어두운 텍스트
- Dark Mode: 어두운 배경에 밝은 텍스트
- System Mode: 시스템 설정 따름

**Typography 시스템**:
- Display (큰 제목): displayLarge, displayMedium, displaySmall
- Headline (제목): headlineLarge, headlineMedium, headlineSmall
- Title (부제목): titleLarge, titleMedium, titleSmall
- Body (본문): bodyLarge, bodyMedium, bodySmall
- Label (레이블): labelLarge, labelMedium, labelSmall

### 2. 유틸리티 함수 (app_utils.dart)

**날짜/시간 포맷팅**:
```dart
String dateTimeFormat(String format, DateTime? dateTime, {String? locale})
// 예: dateTimeFormat('MMM d, y', post.createdAt) → "Jan 15, 2025"
// 예: dateTimeFormat('relative', comment.time) → "3 hours ago"
```

**숫자 포맷팅**:
```dart
String formatNumber(num? value, {
  FormatType formatType,  // decimal, percent, scientific, compact
  DecimalType? decimalType,
  String? currency,
})
```

**JSON 처리**:
```dart
dynamic getJsonField(dynamic response, String jsonPath, [bool isForList])
// JSONPath를 사용한 안전한 데이터 추출
```

**URL 처리**:
```dart
Future launchURL(String url)  // 외부 URL 열기
```

### 3. 네비게이션 시스템 (/nav)

**GoRouter 기반 라우팅** (상세 내용은 [nav/README.md](./nav/README.md) 참조):
- AppStateNotifier: 인증 상태 관리
- AppRoute: 라우트 설정 캡슐화
- ShellRoute: 하단 네비게이션 바 유지
- 파라미터 직렬화: 13가지 타입 지원

### 4. 위젯 라이브러리 (app_widgets.dart)

**AppButtonWidget**:
```dart
AppButtonWidget(
  text: '확인',
  onPressed: () => handleConfirm(),
  color: AppTheme.of(context).primary,
  width: 200,
  height: 50,
)
```

**AppIconButton**:
```dart
AppIconButton(
  icon: Icon(Icons.favorite),
  onPressed: () => toggleFavorite(),
  fillColor: AppTheme.of(context).error,
  borderRadius: 8.0,
)
```

**AppToggleIcon**:
```dart
AppToggleIcon(
  onIcon: Icon(Icons.favorite),
  offIcon: Icon(Icons.favorite_border),
  value: isFavorite,
  onPressed: (value) => setState(() => isFavorite = value),
)
```

### 5. 상태 관리 (app_model.dart)

**AppModel 패턴**:
```dart
abstract class AppModel<W extends Widget> {
  void initState(BuildContext context);
  void dispose();
  void onUpdate();
  
  // 위젯과 컨텍스트 참조
  W? get widget;
  BuildContext? get context;
}
```

**사용 방법**:
```dart
// Model 생성
final model = createModel(context, () => MyWidgetModel());

// Widget 래핑
wrapWithModel(
  model: model,
  child: MyWidget(),
  updateCallback: () => setState(() {}),
)
```

### 6. 국제화 (app_localizations.dart)

**지원 언어**:
- 영어 (en) - 100% 번역
- 독일어 (de) - 키 준비, 번역 진행 중

**사용 방법**:
```dart
Text(AppLocalizations.of(context).getText('login'))  // "Login" 또는 "Anmelden"
```

### 7. 미디어 처리

**AppVideoPlayer** (app_video_player.dart):
- 네트워크/로컬 비디오 재생
- 자동 재생, 반복, 컨트롤 옵션
- 전체화면 지원

**AppMediaDisplay** (app_media_display.dart):
- 이미지/비디오 통합 디스플레이
- 캐싱 및 프리로딩
- 에러 처리

**AppUploadedFile** (uploaded_file.dart):
- 파일 업로드 관리
- Base64 인코딩/디코딩
- 파일 메타데이터 처리

### 8. 폼 처리 (form_field_controller.dart)

```dart
class FormFieldController<T> extends ValueNotifier<T?> {
  // 텍스트 필드, 드롭다운 등 폼 컨트롤러
  void reset() => value = initialValue;
}
```

### 9. 애니메이션 (app_animations.dart)

**Flutter Animate 통합**:
- 페이드, 슬라이드, 스케일 효과
- 커스텀 애니메이션 빌더
- 체인 애니메이션 지원

### 10. 커스텀 함수 (custom_functions.dart)

**비즈니스 로직 함수**:
```dart
// 나이 검증 (13세 이상)
bool isAge13OrAbove(DateTime? birthday)

// 비디오 종횡비 계산
double calculateAspectRatio(double width, double height)

// 파일 크기 포맷팅
String formatFileSize(int bytes)  // "1.5 MB"

// 이메일 유효성 검사
bool isValidEmail(String email)

// 전화번호 포맷팅
String formatPhoneNumber(String phone)
```

### 11. 위치 데이터

**LatLng** (lat_lng.dart):
```dart
class LatLng {
  final double latitude;
  final double longitude;
  
  String serialize() => '$latitude,$longitude';
}
```

**AppPlace** (place.dart):
```dart
class AppPlace {
  final LatLng latLng;
  final String name;
  final String address;
  final String city;
  final String state;
  final String country;
  final String zipCode;
}
```

## 마이그레이션 히스토리

### FlutterFlow → Native Flutter (2025-07-03)

**클래스 이름 변경**:
- `FFAppState` → `AppState`
- `FlutterFlowTheme` → `AppTheme`
- `FlutterFlowUtil` → `AppUtils`
- `FlutterFlowWidgets` → `AppWidgets`
- `FlutterFlowModel` → `AppModel`
- `FlutterFlowIconButton` → `AppIconButton`

**호환성 유지**:
```dart
// 이전 버전과의 호환성을 위한 타입 별칭
typedef FFAppState = AppState;
typedef FlutterFlowTheme = AppTheme;
```

## 사용 예시

### 1. 테마 적용

```dart
// 색상 사용
Container(
  color: AppTheme.of(context).primary,
)

// 텍스트 스타일 사용
Text(
  'Welcome',
  style: AppTheme.of(context).headlineLarge,
)

// 다크모드 체크
final isDark = Theme.of(context).brightness == Brightness.dark;
```

### 2. 날짜 포맷팅

```dart
// 절대 시간
Text(dateTimeFormat('MMM d, y h:mm a', message.timestamp))
// → "Jan 15, 2025 3:30 PM"

// 상대 시간
Text(dateTimeFormat('relative', comment.createdAt))
// → "3 hours ago"
```

### 3. 네비게이션

```dart
// 페이지 이동
context.pushNamed('ProfilePage', params: {'userId': user.id});

// 안전한 뒤로가기
context.safePop();

// 인증 체크 후 이동
context.goNamedAuth('Settings', mounted);
```

### 4. 위젯 사용

```dart
// 버튼
AppButtonWidget(
  text: '저장',
  onPressed: handleSave,
  options: AppButtonOptions(
    width: 200,
    height: 50,
    color: AppTheme.of(context).primary,
  ),
)

// 아이콘 버튼
AppIconButton(
  icon: Icon(Icons.share),
  onPressed: shareContent,
  borderRadius: 12,
)
```

## 성능 최적화

### 1. 테마 캐싱
- SharedPreferences로 테마 모드 저장
- 앱 시작 시 한 번만 로드

### 2. 지연 로딩
- 무거운 컴포넌트는 필요 시 로드
- 이미지/비디오 프리로딩 전략

### 3. const 최적화
- 가능한 모든 위젯에 const 사용
- 색상과 스타일 상수화

## 트러블슈팅

### 자주 발생하는 문제

#### 1. 테마가 적용되지 않음
```dart
// 원인: BuildContext가 테마 위젯 아래 있지 않음
// 해결: MaterialApp 또는 Theme 위젯 아래에서 사용
AppTheme.of(context).primary  // context가 올바른지 확인
```

#### 2. 네비게이션 에러
```dart
// 원인: 라우트 이름 불일치
// 해결: 정확한 라우트 이름 사용
context.pushNamed('HomePage')  // 대소문자 구분
```

#### 3. 날짜 포맷 에러
```dart
// 원인: null DateTime
// 해결: null 체크 추가
dateTimeFormat('MMM d', date ?? DateTime.now())
```

## 테스팅

### 단위 테스트
```dart
testWidgets('AppButton 렌더링 테스트', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AppButtonWidget(
        text: 'Test',
        onPressed: () {},
      ),
    ),
  );
  
  expect(find.text('Test'), findsOneWidget);
});
```

### 통합 테스트
```dart
testWidgets('테마 전환 테스트', (tester) async {
  AppTheme.saveThemeMode(ThemeMode.dark);
  await tester.pumpWidget(MyApp());
  
  expect(Theme.of(context).brightness, Brightness.dark);
});
```

## 성능 지표

### 목표 성능
- **테마 전환**: <100ms
- **네비게이션**: <16ms (60fps)
- **위젯 렌더링**: <16ms
- **JSON 파싱**: <50ms (1MB 데이터)

### 모니터링
```dart
// 성능 측정
final stopwatch = Stopwatch()..start();
dateTimeFormat('relative', date);
print('Format time: ${stopwatch.elapsedMilliseconds}ms');
```

## 변경 이력

### v3.0.0 (2025-08-22)
- 전체 core 디렉토리 통합 문서화
- 20개 유틸리티 파일 상세 분석
- nav 하위 디렉토리 문서 통합

### v2.0.0 (2025-07-03)
- FlutterFlow에서 Native Flutter로 완전 마이그레이션
- 모든 FF 접두사를 App으로 변경
- flutter_flow 디렉토리를 core로 이름 변경

### v1.5.0 (2025-06-15)
- GoRouter 기반 네비게이션 시스템 도입
- ShellRoute 지원 추가

### v1.4.0 (2025-06-01)
- 다크모드 지원 추가
- Typography 시스템 개선

### v1.3.0 (2025-05-15)
- 국제화 지원 추가 (영어, 독일어)
- AppLocalizations 구현

### v1.2.0 (2025-05-01)
- AppModel 상태 관리 패턴 도입
- 컴포넌트 생명주기 관리 개선

### v1.1.0 (2025-04-15)
- 커스텀 함수 라이브러리 확장
- 미디어 처리 유틸리티 추가

### v1.0.0 (2025-04-01)
- 초기 core 라이브러리 구축
- 기본 테마 및 유틸리티 구현

---

**문서 버전**: 3.0.0  
**최종 업데이트**: 2025-08-22  
**관리**: Versus Space 개발팀