# 🔐 Login Page - 로그인 화면

> Versus Space 앱의 메인 로그인 화면으로, 다양한 인증 방식과 테스트 계정을 지원하는 인증 허브

## 📋 개요

이 디렉토리는 Versus Space 앱의 메인 로그인 화면을 담당합니다. 이메일/비밀번호 로그인, 전화번호 로그인, 비밀번호 재설정, 그리고 개발/테스트용 빠른 로그인 기능을 제공합니다. Firebase Authentication과 통합되어 안전한 사용자 인증을 보장합니다.

### 🎯 주요 목적
- **다양한 인증 방식**: 이메일/비밀번호, 전화번호 로그인 지원
- **테스트 환경 지원**: 개발/테스트용 빠른 로그인 버튼 제공
- **사용자 경험 최적화**: 직관적이고 반응형 로그인 UI
- **보안 강화**: Firebase Auth 통합 및 유효성 검증

## 🏗️ 디렉토리 구조

```
/lib/login/login_page/
├── README.md                 # 현재 문서
├── login_page_widget.dart    # UI 위젯 구현
└── login_page_model.dart     # 상태 관리 모델
```

## 📐 네이밍 컨벤션 (Naming Convention)

### 파일명
- **패턴**: snake_case (Dart 표준)
- **예시**: `login_page_widget.dart`, `login_page_model.dart`

### 클래스명
- **패턴**: PascalCase
- **예시**: `LoginPageWidget`, `LoginPageModel`

### 필드명
- **패턴**: camelCase
- **예시**: `emailAddressLoginTextController`, `passwordLoginVisibility`

### 라우트 설정
- **routeName**: `'Login_page'` (레거시 형식)
- **routePath**: `'/loginPage'` (camelCase)

> 참조: [프로젝트 전체 네이밍 컨벤션](../../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소 (Core Components)

### 1. LoginPageWidget (login_page_widget.dart)

로그인 화면의 메인 UI 위젯입니다. 1,175줄의 코드로 구성되어 있으며, 풍부한 기능을 제공합니다.

#### 클래스 구조
```dart
class LoginPageWidget extends StatefulWidget {
  const LoginPageWidget({super.key});
  
  static String routeName = 'Login_page';
  static String routePath = '/loginPage';
  
  @override
  State<LoginPageWidget> createState() => _LoginPageWidgetState();
}
```

#### 주요 기능

##### 1. UI 구성 요소

###### 헤더 이미지
```dart
Container(
  width: double.infinity,
  height: 350.0,
  decoration: BoxDecoration(
    image: DecorationImage(
      fit: BoxFit.cover,
      image: Image.asset(
        'assets/images/20250402_1128____remix_01jqt58d7tey2bhvkccgczdtsg.png',
      ).image,
    ),
  ),
)
```

###### 이메일 입력 필드
```dart
TextFormField(
  controller: _model.emailAddressLoginTextController,
  focusNode: _model.emailAddressLoginFocusNode,
  autofillHints: [AutofillHints.email],
  keyboardType: TextInputType.emailAddress,
  decoration: InputDecoration(
    labelText: 'Email',
    filled: true,
    fillColor: Colors.white,
    borderRadius: BorderRadius.circular(12.0),
  ),
)
```

###### 비밀번호 입력 필드
```dart
TextFormField(
  controller: _model.passwordLoginTextController,
  focusNode: _model.passwordLoginFocusNode,
  autofillHints: [AutofillHints.password],
  obscureText: !_model.passwordLoginVisibility,
  decoration: InputDecoration(
    labelText: 'Password',
    suffixIcon: InkWell(
      onTap: () => setState(
        () => _model.passwordLoginVisibility = !_model.passwordLoginVisibility,
      ),
      child: Icon(
        _model.passwordLoginVisibility
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
      ),
    ),
  ),
)
```

##### 2. 로그인 로직

###### 이메일/비밀번호 로그인
```dart
AppButtonWidget(
  onPressed: () async {
    GoRouter.of(context).prepareAuthEvent();
    
    final user = await authManager.signInWithEmail(
      context,
      _model.emailAddressLoginTextController.text,
      _model.passwordLoginTextController.text,
    );
    
    if (user == null) {
      return;
    }
    
    // currentUserReference 설정 대기 (최대 10초)
    int attempts = 0;
    while (currentUserReference == null && attempts < 20) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }
    
    // lastActive 업데이트
    if (currentUserReference != null) {
      await currentUserReference!.update({
        ...mapToFirestore({
          'lastActive': FieldValue.serverTimestamp(),
        }),
      });
    }
    
    // 홈 화면으로 이동
    context.pushNamedAuth(
      TestpageSelectWidget.routeName,
      context.mounted,
    );
  },
  text: 'Log in',
)
```

###### 전화번호 로그인
```dart
AppButtonWidget(
  onPressed: () async {
    context.pushNamed(
      PhoneCreatAccountWidget.routeName,
      queryParameters: {
        'phoneNumberParam': serializeParam('', ParamType.String),
      }.withoutNulls,
      extra: <String, dynamic>{
        kTransitionInfoKey: TransitionInfo(
          hasTransition: true,
          duration: Duration(milliseconds: 500),
        ),
      },
    );
  },
  text: 'Phone Log in',
)
```

##### 3. 테스트 계정 시스템 (디버그 모드 전용)

###### 테스트 계정 구조
```dart
// 관리자 계정
email: 'admin@versus.test'
password: 'test1234!'
role: 'admin'

// 플랫폼별 테스터 계정
- iOS: 'tester-ios@versus.test'
- Android: 'tester-android@versus.test'
- macOS: 'tester-macos@versus.test'
- Web: 'tester-web@versus.test'
```

###### 테스트 계정 생성 로직
```dart
if (!kReleaseMode)  // 디버그 모드에서만 표시
  AppButtonWidget(
    onPressed: () async {
      // 1. 먼저 로그인 시도
      var user = await authManager.signInWithEmail(
        context, testEmail, testPassword,
      );
      
      // 2. 계정이 없으면 자동 생성
      if (user == null) {
        user = await authManager.createAccountWithEmail(
          context, testEmail, testPassword,
        );
        
        // 3. Firestore에 사용자 문서 생성
        final usersCreateData = {
          'email': testEmail,
          'displayName': displayName,
          'createdTime': FieldValue.serverTimestamp(),
          'role': role,
          'platform': platform,
          'uid': user.uid,
        };
        await UsersModel.collection.doc(user.uid).set(usersCreateData);
      }
      
      // 4. 홈 화면으로 이동
      context.pushNamedAuth(TestpageSelectWidget.routeName, context.mounted);
    },
  )
```

##### 4. 애니메이션 효과

```dart
animationsMap.addAll({
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
  ),
});
```

### 2. LoginPageModel (login_page_model.dart)

화면의 상태 관리를 담당하는 모델 클래스입니다.

#### 클래스 구조
```dart
class LoginPageModel extends AppModel<LoginPageWidget> {
  final formKey = GlobalKey<FormState>();
  
  // 이메일 필드 상태
  FocusNode? emailAddressLoginFocusNode;
  TextEditingController? emailAddressLoginTextController;
  String? Function(BuildContext, String?)? emailAddressLoginTextControllerValidator;
  
  // 비밀번호 필드 상태
  FocusNode? passwordLoginFocusNode;
  TextEditingController? passwordLoginTextController;
  late bool passwordLoginVisibility;
  String? Function(BuildContext, String?)? passwordLoginTextControllerValidator;
}
```

#### 유효성 검증

##### 이메일 검증
```dart
String? _emailAddressLoginTextControllerValidator(
    BuildContext context, String? val) {
  if (val == null || val.isEmpty) {
    return AppLocalizations.of(context).getText(
      'zodqb7tr' /* Please enter a valid email add... */,
    );
  }

  if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
    return 'Has to be a valid email address.';
  }
  return null;
}
```

##### 비밀번호 검증
```dart
String? _passwordLoginTextControllerValidator(
    BuildContext context, String? val) {
  if (val == null || val.isEmpty) {
    return AppLocalizations.of(context).getText(
      'a3s2kg05' /* Password must be at least 6 ch... */,
    );
  }
  return null;
}
```

## 💡 사용 가이드

### 화면 진입 방법

#### 1. 앱 시작 시 기본 진입
```dart
// 로그인되지 않은 사용자는 자동으로 로그인 페이지로 리다이렉트
if (currentUser == null) {
  context.go('/loginPage');
}
```

#### 2. GoRouter 네비게이션
```dart
context.pushNamed(LoginPageWidget.routeName);
// 또는
context.go('/loginPage');
```

### 로그인 플로우

#### 일반 사용자 로그인
1. **이메일/비밀번호 입력**
   - 이메일 형식 자동 검증
   - 비밀번호 6자 이상 확인
   - 자동완성 지원

2. **로그인 버튼 클릭**
   - Firebase Auth 인증 처리
   - currentUserReference 설정 대기
   - lastActive 타임스탬프 업데이트

3. **성공 시 홈 화면 이동**
   - TestpageSelectWidget으로 자동 이동
   - 페이지 전환 애니메이션 (500ms)

#### 전화번호 로그인
1. **Phone Log in 버튼 클릭**
2. **PhoneCreatAccountWidget으로 이동**
3. **SMS 인증 프로세스 진행**

#### 테스트 계정 로그인 (개발 환경)
1. **테스트 계정 버튼 선택**
   - 관리자 (admin 권한)
   - 플랫폼별 테스터 (iOS, Android, macOS, Web)

2. **자동 계정 생성/로그인**
   - 기존 계정 있으면 로그인
   - 없으면 자동으로 생성 후 로그인

3. **역할 및 플랫폼 정보 저장**
   - role: 'admin' 또는 'tester'
   - platform: 'ios', 'android', 'macos', 'web'

### 에러 처리

```dart
// 로그인 실패 시
if (user == null) {
  // Firebase Auth가 자동으로 에러 메시지 표시
  return;
}

// 계정 생성 실패 시
if (user == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('계정 생성 실패'),
    ),
  );
  return;
}

// currentUserReference 설정 실패 시
if (currentUserReference == null) {
  debugPrint('경고: currentUserReference가 설정되지 않음');
  // 직접 DocumentReference 생성하여 처리
  final directRef = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid);
  await directRef.update({...});
}
```

## 🌍 국제화 (i18n)

모든 텍스트는 `AppLocalizations`를 통해 다국어 지원:

```dart
// 지원되는 텍스트 키
'b6l0k8k2' /* Email */
'6l9ekgal' /* Password */
'4wwn8ov8' /* Log in */
'uk1cwrhu' /* Phone Log in */
'ymtbo8l4' /* Forgot Password */
'e1wsx5w1' /* Or sign up with, goto test */
'zodqb7tr' /* Please enter a valid email add... */
'a3s2kg05' /* Password must be at least 6 ch... */
```

### 지원 언어
- English (en)
- German (de) - 번역 대기 중

## 🎨 UI/UX 특징

### 디자인 시스템
- **폰트**: Google Fonts - Plus Jakarta Sans
- **색상 스킴**:
  - 배경: #ECECEC (연한 회색)
  - 입력 필드: 흰색 배경
  - 포커스 테두리: #4B39EF (보라색)
  - 에러 테두리: #FF5963 (빨간색)
  - 버튼: 검은색 배경, 흰색 텍스트

### 레이아웃 구성
1. **헤더 이미지** (350px 높이)
2. **로그인 폼**
   - 이메일 입력 필드
   - 비밀번호 입력 필드
3. **액션 버튼들**
   - 로그인 버튼
   - 전화번호 로그인 버튼
   - 테스트 계정 버튼들 (디버그 모드)
   - 비밀번호 찾기 버튼
4. **하단 링크**
   - 회원가입/테스트 페이지 링크

### 애니메이션
- **페이지 로드 애니메이션**:
  - Fade In 효과 (0 → 1 opacity)
  - Slide Up 효과 (60px → 0px)
  - Tilt 효과 (경사 애니메이션)
  - 200ms 지연, 400ms 지속

### 접근성
- **키보드 타입 최적화**: 이메일 전용 키보드
- **자동완성 지원**: 이메일, 비밀번호 자동완성
- **포커스 관리**: FocusNode를 통한 명확한 포커스 상태
- **비밀번호 표시/숨기기**: 토글 버튼 제공

## 🔄 데이터 플로우

```
사용자 입력
    ↓
LoginPageWidget (UI)
    ↓
LoginPageModel (상태 관리 & 유효성 검증)
    ↓
Firebase Auth (인증 처리)
    ↓
Firestore 업데이트 (lastActive, 사용자 정보)
    ↓
홈 화면 이동
```

## 🔗 의존성

### 내부 의존성
- `/auth/firebase_auth/auth_util.dart` - Firebase 인증 유틸리티
- `/backend/backend.dart` - Firestore 모델 및 유틸리티
- `/core/app_*` - 앱 코어 컴포넌트들
- `/index.dart` - 전역 exports

### 외부 패키지
- `flutter/material.dart` - Flutter UI 프레임워크
- `flutter/foundation.dart` - kReleaseMode 플래그
- `flutter_animate` - 애니메이션 효과
- `google_fonts` - 커스텀 폰트 지원

### 네비게이션 대상
- `TestpageSelectWidget` - 로그인 성공 후 홈 화면
- `PhoneCreatAccountWidget` - 전화번호 로그인
- `ForgotPasswordWidget` - 비밀번호 재설정

## ⚡ 성능 고려사항

### 메모리 관리
```dart
@override
void dispose() {
  emailAddressLoginFocusNode?.dispose();
  emailAddressLoginTextController?.dispose();
  passwordLoginFocusNode?.dispose();
  passwordLoginTextController?.dispose();
}
```

### 비동기 처리 최적화
```dart
// currentUserReference 설정 대기 (최대 10초)
int attempts = 0;
while (currentUserReference == null && attempts < 20) {
  await Future.delayed(const Duration(milliseconds: 500));
  attempts++;
}
```

### 조건부 렌더링
```dart
// 테스트 계정 버튼은 디버그 모드에서만 렌더링
if (!kReleaseMode)
  // 테스트 계정 UI 표시
```

## 🐛 알려진 이슈 및 개선사항

### 현재 이슈
1. **currentUserReference 지연**: 로그인 후 currentUserReference 설정까지 최대 10초 대기
2. **에러 메시지 부족**: 로그인 실패 시 구체적인 에러 메시지 미표시
3. **로딩 상태 없음**: 로그인 처리 중 로딩 인디케이터 없음

### 개선 제안
1. **소셜 로그인 추가**
   ```dart
   // Google 로그인 버튼
   AppButtonWidget(
     onPressed: () async {
       await authManager.signInWithGoogle(context);
     },
     text: 'Sign in with Google',
   )
   ```

2. **로딩 상태 표시**
   ```dart
   // Model에 로딩 상태 추가
   bool isLoading = false;
   
   // 버튼에 로딩 표시
   isLoading ? CircularProgressIndicator() : Text('Log in')
   ```

3. **구체적인 에러 메시지**
   ```dart
   try {
     final user = await authManager.signInWithEmail(...);
   } catch (e) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('로그인 실패: ${e.message}')),
     );
   }
   ```

## 🔒 보안 고려사항

### 구현된 보안 기능
- **Firebase Auth 활용**: 검증된 인증 시스템 사용
- **비밀번호 마스킹**: obscureText로 비밀번호 숨김
- **HTTPS 통신**: Firebase와 안전한 통신
- **테스트 계정 격리**: kReleaseMode로 프로덕션 환경 보호

### 추가 보안 권장사항
1. **Rate Limiting**: 로그인 시도 횟수 제한
2. **2FA 구현**: 이중 인증 추가
3. **세션 관리**: 자동 로그아웃 및 세션 만료
4. **감사 로그**: 로그인 시도 기록

## 🧪 테스트 가이드

### 테스트 계정 정보
| 역할 | 이메일 | 비밀번호 | 플랫폼 |
|------|--------|----------|--------|
| 관리자 | admin@versus.test | test1234! | - |
| iOS 테스터 | tester-ios@versus.test | test1234! | ios |
| Android 테스터 | tester-android@versus.test | test1234! | android |
| macOS 테스터 | tester-macos@versus.test | test1234! | macos |
| Web 테스터 | tester-web@versus.test | test1234! | web |

### 테스트 시나리오
1. **일반 로그인 테스트**
   - 유효한 이메일/비밀번호로 로그인
   - 잘못된 이메일 형식 입력
   - 잘못된 비밀번호 입력

2. **테스트 계정 테스트**
   - 각 플랫폼별 테스트 계정 로그인
   - 계정 자동 생성 확인
   - 역할 및 플랫폼 정보 저장 확인

3. **네비게이션 테스트**
   - 비밀번호 찾기 페이지 이동
   - 전화번호 로그인 페이지 이동
   - 로그인 성공 후 홈 화면 이동

## 📝 변경 이력 (Change History)

| 버전 | 날짜 | 변경사항 | 작성자 |
|------|------|----------|--------|
| 1.1.0 | 2025-08-23 | 상세 문서화 작성 및 코드 분석 완료 | AI Assistant |
| 1.0.0 | 2025-08-22 | 초기 생성 | 개발팀 |

---

*이 문서는 Versus Space 프로젝트의 로그인 화면 기능을 설명합니다.*
*마지막 업데이트: 2025-08-23*