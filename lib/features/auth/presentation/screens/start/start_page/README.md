# 🎬 Start Page - 시작 화면

> Versus Space 앱의 첫 진입점으로, 다양한 소셜 로그인 옵션과 계정 생성/로그인 경로를 제공하는 웰컴 스크린

## 📋 개요

이 디렉토리는 Versus Space 앱의 시작 화면을 담당합니다. 앱을 처음 실행했을 때 사용자가 마주하는 첫 화면으로, "Life is a 'c' between 'b' and 'd'" 라는 철학적 메시지와 함께 다양한 인증 방식을 제공합니다. 소셜 로그인(Apple, Google, Facebook, Instagram)과 이메일 계정 생성/로그인으로의 네비게이션을 지원합니다.

### 🎯 주요 목적
- **첫인상 형성**: 앱의 철학적 메시지로 브랜드 아이덴티티 전달
- **인증 허브**: 다양한 소셜 로그인 옵션 제공
- **사용자 유도**: 계정 생성 또는 로그인으로 자연스러운 유도
- **플랫폼 최적화**: iOS/Android 플랫폼별 최적화된 UI

## 🏗️ 디렉토리 구조

```
/lib/login/start_page/
├── README.md                # 현재 문서
├── start_page_widget.dart   # UI 위젯 구현 (603줄)
└── start_page_model.dart    # 상태 관리 모델 (23줄)
```

## 📐 네이밍 컨벤션 (Naming Convention)

### 파일명
- **패턴**: snake_case (Dart 표준)
- **예시**: `start_page_widget.dart`, `start_page_model.dart`

### 클래스명
- **패턴**: PascalCase
- **예시**: `StartPageWidget`, `StartPageModel`

### 필드명
- **패턴**: camelCase
- **예시**: `vsmarkModel`, `hasButtonTriggered1`, `animationsMap`

### 라우트 설정
- **routeName**: `'startPage'`
- **routePath**: `'/startPage'`

> 참조: [프로젝트 전체 네이밍 컨벤션](../../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소 (Core Components)

### 1. StartPageWidget (start_page_widget.dart)

시작 화면의 메인 UI 위젯입니다. 603줄의 코드로 구성되어 있으며, 애니메이션과 다양한 로그인 옵션을 제공합니다.

#### 클래스 구조
```dart
class StartPageWidget extends StatefulWidget {
  const StartPageWidget({super.key});
  
  static String routeName = 'startPage';
  static String routePath = '/startPage';
  
  @override
  State<StartPageWidget> createState() => _StartPageWidgetState();
}
```

#### 주요 기능

##### 메인 메시지 표시
```dart
Text(
  AppLocalizations.of(context).getText(
    'ur72jrvo' /* Life is a 'c' between 'b' and ... */,
  ),
  textAlign: TextAlign.center,
  style: TextStyle(
    fontFamily: 'SourGummy',
    color: Color(0xFF14181B),
    fontSize: 66.0,
  ),
)
```
- **폰트**: SourGummy 커스텀 폰트 사용
- **크기**: 66px의 대형 텍스트
- **메시지**: "Life is a 'c' between 'b' and 'd'" (Choice between Birth and Death)

##### VS 마크 컴포넌트
```dart
wrapWithModel(
  model: _model.vsmarkModel,
  updateCallback: () => setState(() {}),
  child: VsmarkWidget(),
)
```
- Versus Space 브랜드 로고/마크 표시
- 별도 컴포넌트로 재사용 가능

##### 소셜 로그인 버튼들

1. **계정 생성 버튼** (메인 CTA)
```dart
AppButtonWidget(
  onPressed: () async {
    context.pushNamed(
      CreateAccountWidget.routeName,
      extra: <String, dynamic>{
        kTransitionInfoKey: TransitionInfo(
          hasTransition: true,
          duration: Duration(milliseconds: 500),
        ),
      },
    );
  },
  text: 'Go To Create Account',
  options: AppButtonOptions(
    width: 230.0,
    height: 44.0,
    color: Colors.black,
    textStyle: // 흰색 텍스트
  ),
)
```

2. **Apple 로그인** (iOS 전용)
```dart
isAndroid
  ? Container()  // Android에서는 숨김
  : AppButtonWidget(
      onPressed: () async {
        final user = await authManager.signInWithApple(context);
        if (user == null) return;
        context.goNamedAuth(TestpageSelectWidget.routeName, context.mounted);
      },
      text: 'Continue with Apple',
      icon: FaIcon(FontAwesomeIcons.apple),
    )
```

3. **Google 로그인**
```dart
AppButtonWidget(
  onPressed: () async {
    final user = await authManager.signInWithGoogle(context);
    if (user == null) return;
    
    // 마지막 활동 시간 업데이트
    await currentUserReference!.update({
      ...mapToFirestore({
        'lastActive': FieldValue.serverTimestamp(),
      }),
    });
    
    context.goNamedAuth(TestpageSelectWidget.routeName, context.mounted);
  },
  text: 'Continue with Google',
  icon: FaIcon(FontAwesomeIcons.google),
)
```

4. **Facebook 로그인** (실제로는 Google 로그인 사용)
```dart
AppButtonWidget(
  onPressed: () async {
    // 주의: 현재 Google 로그인으로 구현됨
    final user = await authManager.signInWithGoogle(context);
    // ...
  },
  text: 'Continue with Facebook',
  icon: FaIcon(FontAwesomeIcons.squareFacebook),
  options: AppButtonOptions(
    color: Color(0xFF005CFF),  // Facebook 블루
  ),
)
```

5. **Instagram 로그인** (실제로는 Google 로그인 사용)
```dart
AppButtonWidget(
  onPressed: () async {
    // 주의: 현재 Google 로그인으로 구현됨
    final user = await authManager.signInWithGoogle(context);
    // ...
  },
  text: 'Continue with Instagram',
  icon: FaIcon(FontAwesomeIcons.instagram),
  options: AppButtonOptions(
    color: Color(0xFFFF8455),  // Instagram 그라데이션 색상
  ),
)
```

6. **로그인 페이지로 이동**
```dart
AppButtonWidget(
  onPressed: () async {
    context.pushNamed(
      LoginPageWidget.routeName,
      extra: <String, dynamic>{
        kTransitionInfoKey: TransitionInfo(
          hasTransition: true,
          duration: Duration(milliseconds: 500),
        ),
      },
    );
  },
  text: 'Go To Sign in',
  options: AppButtonOptions(
    color: Colors.white,
    elevation: 10.0,  // 더 높은 elevation
  ),
)
```

#### 애니메이션 시스템

##### 페이지 로드 애니메이션
```dart
'columnOnPageLoadAnimation': AnimationInfo(
  trigger: AnimationTrigger.onPageLoad,
  effectsBuilder: () => [
    FadeEffect(
      delay: 200.0.ms,
      duration: 400.0.ms,
      begin: 0.0,
      end: 1.0,
    ),
    MoveEffect(
      delay: 200.0.ms,
      duration: 400.0.ms,
      begin: Offset(0.0, 60.0),
      end: Offset(0.0, 0.0),
    ),
    TiltEffect(
      delay: 200.0.ms,
      duration: 400.0.ms,
      begin: Offset(-0.349, 0),
      end: Offset(0, 0),
    ),
  ],
)
```
- **Fade**: 투명도 0→1로 페이드인
- **Move**: 아래에서 위로 60px 슬라이드
- **Tilt**: 살짝 기울어진 상태에서 정상으로

##### 버튼 클릭 애니메이션
```dart
'buttonOnActionTriggerAnimation1': AnimationInfo(
  trigger: AnimationTrigger.onActionTrigger,
  effectsBuilder: () => [
    ScaleEffect(
      duration: 200.0.ms,
      begin: Offset(1.0, 1.0),
      end: Offset(0.95, 0.95),
    ),
  ],
)
```
- 클릭 시 95% 크기로 축소되는 효과

### 2. StartPageModel (start_page_model.dart)

화면의 상태 관리를 담당하는 간단한 모델 클래스입니다.

#### 클래스 구조
```dart
class StartPageModel extends AppModel<StartPageWidget> {
  // VS 마크 컴포넌트 모델
  late VsmarkModel vsmarkModel;
  
  @override
  void initState(BuildContext context) {
    vsmarkModel = createModel(context, () => VsmarkModel());
  }
  
  @override
  void dispose() {
    vsmarkModel.dispose();
  }
}
```

#### 상태 관리
- **vsmarkModel**: VS 마크 컴포넌트의 상태 관리
- 추가 상태 필드 없음 (UI 중심 화면)

## 💡 사용 가이드

### 앱 진입 플로우

1. **첫 실행 시**
   - 사용자가 앱을 처음 실행하면 이 화면이 표시됨
   - 철학적 메시지로 브랜드 인상 형성

2. **인증 선택**
   - 신규 사용자: "Go To Create Account" 버튼
   - 기존 사용자: "Go To Sign in" 버튼
   - 빠른 가입: 소셜 로그인 버튼들

3. **소셜 로그인 플로우**
   ```dart
   // 소셜 로그인 성공 시
   1. authManager.signInWithXXX() 호출
   2. 사용자 정보 가져오기
   3. lastActive 시간 업데이트
   4. TestpageSelectWidget으로 이동
   ```

### 플랫폼별 차이점

#### iOS
- Apple 로그인 버튼 표시
- 모든 소셜 로그인 옵션 사용 가능

#### Android  
- Apple 로그인 버튼 숨김 (`isAndroid ? Container() : ...`)
- 나머지 소셜 로그인 옵션만 표시

## 🎨 UI/UX 특징

### 디자인 시스템
- **배경색**: #ECECEC (연한 회색)
- **메인 폰트**: SourGummy (브랜드 폰트)
- **버튼 폰트**: Plus Jakarta Sans (Bold)
- **버튼 크기**: 230x44px (일관된 크기)
- **테두리**: 2px #E0E3E7 (모든 버튼)
- **모서리**: 12px radius (둥근 모서리)

### 버튼 색상 스킴
- **메인 CTA**: 검은색 배경, 흰색 텍스트
- **Apple**: 흰색 배경, 검은색 아이콘/텍스트
- **Google**: 흰색 배경, 컬러 아이콘
- **Facebook**: #005CFF (Facebook 블루)
- **Instagram**: #FF8455 (Instagram 오렌지)
- **Sign In**: 흰색 배경, 높은 elevation

### 애니메이션 특징
- **지연 시작**: 200ms 딜레이로 자연스러운 진입
- **부드러운 전환**: 400ms duration
- **복합 효과**: Fade + Move + Tilt 조합
- **인터랙션 피드백**: 버튼 클릭 시 스케일 애니메이션

## 🔄 데이터 플로우

```
StartPageWidget (진입)
    ↓
사용자 선택
    ├─ Create Account → CreateAccountWidget
    ├─ Sign In → LoginPageWidget
    └─ Social Login
           ↓
       Firebase Auth
           ↓
       성공 시 lastActive 업데이트
           ↓
       TestpageSelectWidget
```

## 🔗 의존성

### 내부 의존성
- `/auth/firebase_auth/auth_util.dart` - Firebase 인증 유틸리티
- `/backend/backend.dart` - Firestore 백엔드
- `/etc/vsmark/vsmark_widget.dart` - VS 마크 컴포넌트
- `/core/app_*` - 앱 코어 컴포넌트들

### 외부 패키지
- `flutter/material.dart` - Flutter UI 프레임워크
- `flutter_animate` - 애니메이션 라이브러리
- `font_awesome_flutter` - 소셜 아이콘
- `google_fonts` - Google Fonts 지원
- `go_router` - 네비게이션

## ⚡ 성능 고려사항

### 애니메이션 최적화
```dart
setupAnimations(
  animationsMap.values.where((anim) =>
      anim.trigger == AnimationTrigger.onActionTrigger ||
      !anim.applyInitialState),
  this,
);
```
- 필요한 애니메이션만 초기화
- TickerProviderStateMixin 사용으로 효율적인 애니메이션

### 위젯 생명주기
```dart
@override
void initState() {
  super.initState();
  _model = createModel(context, () => StartPageModel());
  // 애니메이션 설정
  WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
}

@override
void dispose() {
  _model.dispose();
  super.dispose();
}
```

## 🐛 알려진 이슈 및 개선사항

### 현재 이슈
1. **소셜 로그인 구현 미완성**
   - Facebook, Instagram 버튼이 실제로는 Google 로그인 사용
   - 실제 Facebook/Instagram SDK 통합 필요

2. **중복 코드**
   - 소셜 로그인 버튼들의 onPressed 로직이 거의 동일
   - 공통 메서드로 추출 권장

3. **플랫폼 체크 하드코딩**
   - `isAndroid` 변수 사용 대신 `Platform.isAndroid` 권장

### 개선 제안

1. **소셜 로그인 통합**
```dart
Future<void> _handleSocialLogin(
  String provider,
  BuildContext context,
) async {
  final user = await switch(provider) {
    'apple' => authManager.signInWithApple(context),
    'google' => authManager.signInWithGoogle(context),
    'facebook' => authManager.signInWithFacebook(context),
    'instagram' => authManager.signInWithInstagram(context),
    _ => null,
  };
  
  if (user == null) return;
  
  await _updateLastActive();
  if (context.mounted) {
    context.goNamedAuth(TestpageSelectWidget.routeName, context.mounted);
  }
}
```

2. **애니메이션 상태 관리**
```dart
// 애니메이션 트리거 상태를 Model로 이동
class StartPageModel {
  bool hasButtonTriggered1 = false;
  bool hasButtonTriggered2 = false;
  // ...
}
```

3. **접근성 개선**
- Semantics 위젯 추가
- 스크린 리더 지원
- 키보드 네비게이션

## 🔒 보안 고려사항

### 구현된 보안 기능
- **Firebase Auth 활용**: 검증된 인증 시스템
- **Null 체크**: 로그인 실패 시 적절한 처리
- **Context 마운트 체크**: 비동기 작업 후 context.mounted 확인

### 추가 보안 권장사항
1. **Rate Limiting**: 로그인 시도 횟수 제한
2. **Error Handling**: 구체적인 에러 메시지 표시
3. **Session Management**: 자동 로그아웃 타이머
4. **Deep Link 보안**: 인증 후 리다이렉션 검증

## 🌍 국제화 (i18n)

모든 텍스트는 `AppLocalizations`를 통해 다국어 지원:

```dart
// 지원되는 텍스트 키
'ur72jrvo' /* Life is a 'c' between 'b' and ... */
'tkccfqfy' /* Go To Create Account */
'3gnrvqoi' /* Continue with Apple */
's24g5s5d' /* Continue with Google */
'ntv3cl1f' /* Continue with Facebook */
'4ssf49xr' /* Continue with Instagram */
'b71h3bzp' /* Go To Sign in */
```

### 지원 언어
- English (en) - 완전 번역
- German (de) - 번역 대기 중

## 📝 변경 이력 (Change History)

| 버전 | 날짜 | 변경사항 | 작성자 |
|------|------|----------|--------|
| 1.1.0 | 2025-08-23 | 상세 문서화 작성 및 코드 분석 완료 | AI Assistant |
| 1.0.0 | 2025-08-22 | 초기 생성 | 개발팀 |

---

*이 문서는 Versus Space 프로젝트의 시작 화면을 설명합니다.*
*마지막 업데이트: 2025-08-23*