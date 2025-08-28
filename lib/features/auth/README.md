# 🔐 Auth Feature

> Feature-First Architecture 기반 인증 모듈

## 📋 개요

Auth Feature는 Versus Space의 사용자 인증 및 계정 관리를 담당합니다.
다양한 인증 방법을 지원하며, 안전한 사용자 관리 기능을 제공합니다.

## 🏗️ 아키텍처

```
auth/
├── data/                  # 데이터 레이어
│   ├── datasources/      # Firebase Auth 연동
│   ├── repositories/     # AuthRepository 구현
│   └── services/         # 인증 서비스
│
├── domain/               # 도메인 레이어
│   ├── models/          # User, AuthCredential 모델
│   ├── repositories/    # AuthRepository 인터페이스
│   └── usecases/        # 로그인, 회원가입, 로그아웃
│
└── presentation/         # 프레젠테이션 레이어
    ├── screens/         # 로그인, 회원가입 화면
    ├── widgets/         # 인증 관련 위젯
    └── providers/       # AuthProvider 상태 관리
```

## 🎯 주요 기능

### 인증 방법
- **이메일/비밀번호**: 기본 인증 방법
- **소셜 로그인**: Google, Apple, GitHub
- **전화번호 인증**: SMS OTP 방식
- **익명 로그인**: 임시 사용자 지원

### 계정 관리
- 회원가입 플로우 (다단계)
- 이메일 인증
- 비밀번호 재설정
- 계정 삭제

### 보안 기능
- 비밀번호 강도 검증
- OTP 재전송 제한 (3회)
- 세션 관리
- 자동 로그아웃

## 📦 의존성

### 전역 레이어 사용
- `core/utils`: 유틸리티 함수
- `core/widgets`: 공통 UI 컴포넌트
- `backend/firebase`: Firebase 설정
- `services/validators`: 입력 검증

### Firebase 서비스
```yaml
firebase_auth: ^5.3.3
google_sign_in: ^6.1.5
sign_in_with_apple: ^5.0.0
```

## 🔄 상태 관리

### AuthProvider
```dart
// 인증 상태 관리
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  AuthStatus _status = AuthStatus.unauthenticated;
  
  // 로그인 상태
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  
  // 사용자 정보
  User? get currentUser => _currentUser;
}
```

## 🔀 다른 Feature와의 통신

### 이벤트 버스
```dart
// 로그인 성공 이벤트
eventBus.fire(UserLoggedInEvent(userId));

// 로그아웃 이벤트
eventBus.fire(UserLoggedOutEvent());
```

### 라우팅
```dart
// 로그인 후 홈으로 이동
context.go('/home');

// 인증 필요 시 로그인으로 리다이렉트
context.push('/auth/login');
```

## 📋 API 레퍼런스

### UseCases
- `LoginUseCase`: 로그인 처리
- `SignUpUseCase`: 회원가입 처리
- `LogoutUseCase`: 로그아웃 처리
- `ResetPasswordUseCase`: 비밀번호 재설정
- `VerifyEmailUseCase`: 이메일 인증

### Models
- `UserModel`: 사용자 정보
- `AuthCredential`: 인증 자격 증명
- `AuthState`: 인증 상태

## 🧪 테스트

```bash
# 유닛 테스트
flutter test test/features/auth/domain/

# 통합 테스트
flutter test test/features/auth/integration/
```

## 📝 변경 이력

### v1.0.0 (2025-08-27)
- Feature-First Architecture 마이그레이션 완료
- Clean Architecture 레이어 구조 적용
- 전역 레이어 분리