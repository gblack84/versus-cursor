# 🔑 Forgot Password - 비밀번호 재설정

> Firebase Authentication을 활용한 이메일 기반 비밀번호 재설정 기능을 제공하는 모듈

## 📋 개요

이 디렉토리는 Versus Space 앱의 비밀번호 재설정 기능을 담당합니다. 사용자가 비밀번호를 잊어버렸을 때, 등록된 이메일 주소로 재설정 링크를 전송하여 새로운 비밀번호를 설정할 수 있도록 지원합니다.

### 🎯 주요 목적
- **비밀번호 복구**: 잊어버린 비밀번호 재설정 지원
- **이메일 인증**: Firebase Auth를 통한 안전한 이메일 인증
- **사용자 경험**: 간단하고 직관적인 재설정 프로세스
- **보안 강화**: 이메일 검증을 통한 계정 보호

## 🏗️ 디렉토리 구조

```
/lib/login/forgot_password/
├── README.md                   # 현재 문서
├── forgot_password_widget.dart # UI 위젯 구현
└── forgot_password_model.dart  # 상태 관리 모델
```

## 📐 네이밍 컨벤션 (Naming Convention)

### 파일명
- **패턴**: snake_case (Dart 표준)
- **예시**: `forgot_password_widget.dart`, `forgot_password_model.dart`

### 클래스명
- **패턴**: PascalCase
- **예시**: `ForgotPasswordWidget`, `ForgotPasswordModel`

### 필드명
- **패턴**: camelCase
- **예시**: `emailAddressTextController`, `emailAddressFocusNode`

### 라우트 설정
- **routeName**: `'Forgot_Password'` (레거시 형식)
- **routePath**: `'/forgotPassword'` (camelCase)

> 참조: [프로젝트 전체 네이밍 컨벤션](../../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소 (Core Components)

### 1. ForgotPasswordWidget (forgot_password_widget.dart)

비밀번호 재설정 화면의 메인 UI 위젯입니다.

#### 클래스 구조
```dart
class ForgotPasswordWidget extends StatefulWidget {
  const ForgotPasswordWidget({super.key});
  
  static String routeName = 'Forgot_Password';
  static String routePath = '/forgotPassword';
  
  @override
  State<ForgotPasswordWidget> createState() => _ForgotPasswordWidgetState();
}
```

#### 주요 기능

##### 라우팅 설정
```dart
// 정적 라우트 정보
static String routeName = 'Forgot_Password';  // GoRouter 이름
static String routePath = '/forgotPassword';   // URL 경로
```

##### UI 구성 요소
1. **앱바 (AppBar)**
   - 뒤로가기 버튼 (LoginPage로 이동)
   - "Back" 텍스트 표시
   - 흰색 배경, 검은색 텍스트

2. **메인 컨테이너**
   - 최대 너비: 570px (태블릿/데스크톱 대응)
   - 배경색: #ECECEC (연한 회색)

3. **컨텐츠 영역**
   - 제목: "Forgot Password"
   - 설명문: 이메일로 링크 전송 안내
   - 이메일 입력 필드
   - 전송 버튼

##### 반응형 디자인
```dart
// 데스크톱에서 추가 뒤로가기 옵션 표시
if (responsiveVisibility(
  context: context,
  phone: false,
  tablet: false,
))
```

##### 이메일 입력 필드
```dart
TextFormField(
  controller: _model.emailAddressTextController,
  focusNode: _model.emailAddressFocusNode,
  autofillHints: [AutofillHints.email],    // 자동완성 지원
  keyboardType: TextInputType.emailAddress, // 이메일 키보드
  decoration: InputDecoration(
    labelText: 'Your email address...',
    hintText: 'Enter your email...',
    filled: true,
    fillColor: Colors.white,
    borderRadius: BorderRadius.circular(12.0),
  ),
)
```

##### 비밀번호 재설정 로직
```dart
AppButtonWidget(
  onPressed: () async {
    // 빈 이메일 검증
    if (_model.emailAddressTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email required!')),
      );
      return;
    }
    
    // Firebase Auth 재설정 이메일 전송
    await authManager.resetPassword(
      email: _model.emailAddressTextController.text,
      context: context,
    );
  },
  text: 'Send Link',
)
```

### 2. ForgotPasswordModel (forgot_password_model.dart)

화면의 상태 관리를 담당하는 모델 클래스입니다.

#### 클래스 구조
```dart
class ForgotPasswordModel extends AppModel<ForgotPasswordWidget> {
  // 이메일 입력 필드 상태
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;
  
  @override
  void initState(BuildContext context) {}
  
  @override
  void dispose() {
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();
  }
}
```

#### 상태 관리 요소
- **emailAddressTextController**: 이메일 입력값 관리
- **emailAddressFocusNode**: 포커스 상태 관리
- **emailAddressTextControllerValidator**: 이메일 유효성 검증 (선택적)

## 💡 사용 가이드

### 화면 진입 방법

#### 1. 로그인 화면에서 진입
```dart
// LoginPage의 "Forgot Password?" 링크 클릭 시
context.pushNamed(ForgotPasswordWidget.routeName);
```

#### 2. GoRouter 직접 네비게이션
```dart
// URL 직접 접근
context.go('/forgotPassword');
```

### 비밀번호 재설정 플로우

1. **이메일 입력**
   - 사용자가 등록된 이메일 주소 입력
   - 자동완성 지원으로 편리한 입력

2. **유효성 검증**
   - 빈 값 체크
   - 이메일 형식 검증 (선택적)

3. **재설정 링크 전송**
   - Firebase Auth의 `resetPassword` 메서드 호출
   - 이메일로 재설정 링크 자동 발송

4. **이메일 확인**
   - 사용자가 이메일에서 링크 클릭
   - Firebase 호스팅 페이지에서 새 비밀번호 설정

5. **완료 후 로그인**
   - 새 비밀번호로 로그인 가능

### 에러 처리

```dart
// 이메일 미입력 에러
if (_model.emailAddressTextController.text.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Email required!')),
  );
  return;
}

// Firebase Auth 에러 (authManager 내부 처리)
// - 등록되지 않은 이메일
// - 네트워크 오류
// - 너무 많은 요청
```

## 🌍 국제화 (i18n)

모든 텍스트는 `AppLocalizations`를 통해 다국어 지원:

```dart
// 지원되는 텍스트 키
'7sfxx5v9' /* Back */
'6adpvif5' /* Forgot Password */
'otjgw6ev' /* We will send you an email with... */
'8mw92l30' /* Your email address... */
'jabo9c3s' /* Enter your email... */
'4rzuk0hj' /* Send Link */
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
  - 버튼: 검은색 배경, 흰색 텍스트
  - 테두리: 12px radius 둥근 모서리

### 접근성
- **키보드 타입**: 이메일 전용 키보드
- **자동완성**: 이메일 주소 자동완성 지원
- **포커스 관리**: FocusNode를 통한 명확한 포커스 상태

### 반응형 레이아웃
- **모바일**: 전체 화면 너비 사용
- **태블릿/데스크톱**: 최대 570px 너비 제한
- **데스크톱 전용**: 추가 뒤로가기 UI 제공

## 🔄 데이터 플로우

```
사용자 입력
    ↓
ForgotPasswordWidget (UI)
    ↓
ForgotPasswordModel (상태 관리)
    ↓
Firebase Auth (resetPassword)
    ↓
이메일 전송
    ↓
사용자 이메일 확인
    ↓
Firebase 재설정 페이지
    ↓
새 비밀번호 설정
```

## 🔗 의존성

### 내부 의존성
- `/auth/firebase_auth/auth_util.dart` - Firebase 인증 유틸리티
- `/core/app_*` - 앱 코어 컴포넌트들
- `/index.dart` - 전역 exports

### 외부 패키지
- `flutter/material.dart` - Flutter UI 프레임워크
- `google_fonts` - 커스텀 폰트 지원

## ⚡ 성능 고려사항

### 메모리 관리
```dart
@override
void dispose() {
  emailAddressFocusNode?.dispose();      // FocusNode 정리
  emailAddressTextController?.dispose();  // TextController 정리
}
```

### 초기화 최적화
```dart
// 지연 초기화 패턴
late ForgotPasswordModel _model;

// 필요시에만 컨트롤러 생성
_model.emailAddressTextController ??= TextEditingController();
```

## 🐛 알려진 이슈 및 개선사항

### 현재 이슈
1. **이메일 형식 검증 미구현**: validator 함수는 정의되었으나 실제 검증 로직 없음
2. **성공/실패 피드백 부족**: 이메일 전송 후 사용자 피드백 UI 없음
3. **로딩 상태 표시 없음**: 이메일 전송 중 로딩 인디케이터 없음

### 개선 제안
1. **이메일 유효성 검증 강화**
   ```dart
   emailAddressTextControllerValidator: (value) {
     if (value == null || value.isEmpty) {
       return 'Email is required';
     }
     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
       return 'Please enter a valid email';
     }
     return null;
   }
   ```

2. **성공 메시지 표시**
   ```dart
   // 이메일 전송 성공 시
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(
       content: Text('Password reset link sent! Check your email.'),
       backgroundColor: Colors.green,
     ),
   );
   ```

3. **로딩 상태 관리**
   ```dart
   // Model에 로딩 상태 추가
   bool isLoading = false;
   
   // 버튼에 로딩 표시
   isLoading ? CircularProgressIndicator() : Text('Send Link')
   ```

## 🔒 보안 고려사항

### 구현된 보안 기능
- **Firebase Auth 활용**: 검증된 인증 시스템 사용
- **이메일 검증**: 등록된 이메일로만 재설정 링크 전송
- **시간 제한**: Firebase 자체 링크 만료 시간 적용

### 추가 보안 권장사항
1. **Rate Limiting**: 재설정 요청 횟수 제한
2. **CAPTCHA**: 봇 방지를 위한 CAPTCHA 추가
3. **이메일 마스킹**: 일부만 표시 (예: jo**@gmail.com)
4. **보안 로그**: 재설정 시도 로그 기록

## 📝 변경 이력 (Change History)

| 버전 | 날짜 | 변경사항 | 작성자 |
|------|------|----------|--------|
| 1.1.0 | 2025-08-23 | 상세 문서화 작성 및 코드 분석 완료 | AI Assistant |
| 1.0.0 | 2025-08-22 | 초기 생성 | 개발팀 |

---

*이 문서는 Versus Space 프로젝트의 비밀번호 재설정 기능을 설명합니다.*
*마지막 업데이트: 2025-08-23*