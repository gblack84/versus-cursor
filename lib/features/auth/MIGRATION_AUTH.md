# 📦 /lib/features/auth 디렉토리 마이그레이션 가이드

> Feature-First Architecture - Auth Feature 완전 통합
> 최종 업데이트: 2025-08-25

## 🎯 목적

인증 관련 모든 기능을 `/lib/features/auth` 폴더로 통합하여 독립적이고 재사용 가능한 인증 모듈을 구성합니다.

## ⚠️ 전제조건

Auth 마이그레이션은 다음 Feature들이 완료된 후 진행되어야 합니다:

1. **Core 마이그레이션** (Phase 0) - FlutterFlow 레거시 정리
2. **Common Feature** - 공통 위젯 및 유틸리티
3. **App Feature** - 라우팅 및 상태 관리

의존성: `Core → Common/App → Auth`

## 🔄 Core/App 마이그레이션 의존성

### FlutterFlow → Native Flutter 변환
이 기능은 다음 Core/App 마이그레이션 항목들과 의존성이 있습니다:

| 변경 사항 | 영향받는 컴포넌트 | 필요 작업 |
|----------|----------------|----------|
| **FFAppState → AppState** | 로그인 상태 관리 | `Provider<AppState>` 사용 |
| **flutter_flow/ → core/** | 인증 유틸리티 | Import 경로 변경 |
| **FF 접두사 제거** | 로그인 폼 위젯 | `FFButtonWidget` → `AppButton` |
| **AppTheme 통합** | 인증 화면 테마 | `AppTheme.of(context)` 사용 |

### Import 변경 예시
```dart
// Before (FlutterFlow)
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_util.dart';

// After (Native Flutter)
import '/core/app_theme.dart';
import '/core/widgets/app_button.dart';
import '/core/utils/app_utils.dart';
```

## 📋 현재 상태 분석 (전체 하위 디렉토리 포함)

### 인증 관련 전체 파일 목록
| 디렉토리 | 파일명 | 설명 | 대상 위치 |
|----------|--------|------|----------|
| **`/lib/auth/`** (11개) | | | |
| └─ | auth_manager.dart | 인증 관리자 | data/services/ |
| └─ | base_auth_user_provider.dart | 기본 인증 프로바이더 | presentation/providers/ |
| └─ firebase_auth/ | firebase_auth_manager.dart | Firebase 인증 관리 | data/services/ |
| └─ | firebase_user_provider.dart | Firebase 사용자 프로바이더 | presentation/providers/ |
| └─ | auth_util.dart | 인증 유틸리티 | data/services/ |
| └─ | email_auth.dart | 이메일 인증 | data/services/ |
| └─ | google_auth.dart | Google OAuth | data/services/ |
| └─ | apple_auth.dart | Apple Sign In | data/services/ |
| └─ | github_auth.dart | GitHub OAuth | data/services/ |
| └─ | anonymous_auth.dart | 익명 인증 | data/services/ |
| └─ | jwt_token_auth.dart | JWT 토큰 관리 | data/services/ |
| **`/lib/login/`** (6개) | | | |
| └─ start_page/ | start_page_widget.dart | 시작 화면 위젯 | presentation/screens/start/ |
| └─ | start_page_model.dart | 시작 화면 모델 | presentation/screens/start/ |
| └─ login_page/ | login_page_widget.dart | 로그인 화면 위젯 | presentation/screens/login/ |
| └─ | login_page_model.dart | 로그인 화면 모델 | presentation/screens/login/ |
| └─ forgot_password/ | forgot_password_widget.dart | 비밀번호 찾기 위젯 | presentation/screens/forgot_password/ |
| └─ | forgot_password_model.dart | 비밀번호 찾기 모델 | presentation/screens/forgot_password/ |
| **`/lib/createaccount/`** (10개) | | | |
| └─ create_account/ | create_account_widget.dart | 계정 생성 위젯 | presentation/screens/signup/ |
| └─ | create_account_model.dart | 계정 생성 모델 | presentation/screens/signup/ |
| └─ phoneauth/phone_creat_account/ | phone_create_account_widget.dart | 전화 계정 생성 위젯 | presentation/screens/phone_auth/ |
| └─ | phone_create_account_model.dart | 전화 계정 생성 모델 | presentation/screens/phone_auth/ |
| └─ phoneauth/phonelogeinpincode/ | phonelogeinpincode_widget.dart | 전화 PIN 코드 위젯 | presentation/screens/phone_auth/ |
| └─ | phonelogeinpincode_model.dart | 전화 PIN 코드 모델 | presentation/screens/phone_auth/ |
| └─ phonemaximum/ | phonemaximum_widget.dart | 전화 최대 시도 위젯 | presentation/screens/phone_auth/ |
| └─ | phonemaximum_model.dart | 전화 최대 시도 모델 | presentation/screens/phone_auth/ |
| └─ popup_timer_email/ | popup_timer_email_widget.dart | 이메일 타이머 위젯 | presentation/screens/email_verification/ |
| └─ | popup_timer_email_model.dart | 이메일 타이머 모델 | presentation/screens/email_verification/ |
| **`/lib/backend/schema/`** (User 관련) | | | |
| └─ | users_model.dart | 사용자 모델 | domain/models/ |
| └─ | premium_users_model.dart | 프리미엄 사용자 모델 | domain/models/ |
| └─ | user_contents_model.dart | 사용자 콘텐츠 모델 | domain/models/ |
| **총합** | **30개 파일** | **전체 인증 관련 파일** | **Feature-First 구조로 재배치** |

## 🏗️ Feature-First 구조 매핑 (상세)

```
/lib/features/auth/
├── data/
│   ├── repositories/
│   │   ├── auth_repository.dart          # 인증 데이터 접근 추상화 (새로 생성)
│   │   ├── auth_repository_impl.dart     # Repository 구현체 (새로 생성)
│   │   └── user_repository.dart          # 사용자 데이터 관리 (새로 생성)
│   │
│   ├── datasources/
│   │   ├── remote/
│   │   │   ├── firebase_auth_datasource.dart  # Firebase Auth API
│   │   │   └── firestore_user_datasource.dart # Firestore 사용자 데이터
│   │   └── local/
│   │       └── auth_local_datasource.dart     # 로컬 인증 캐시
│   │
│   └── services/
│       ├── firebase_auth_service.dart    # Firebase Auth 통합
│       ├── email_auth_service.dart       # 이메일 인증
│       ├── google_auth_service.dart      # Google OAuth
│       ├── apple_auth_service.dart       # Apple Sign In
│       ├── github_auth_service.dart      # GitHub OAuth
│       ├── anonymous_auth_service.dart   # 익명 인증
│       ├── phone_auth_service.dart       # 전화번호 인증
│       ├── auth_util.dart                # 인증 유틸리티
│       └── jwt_token_service.dart        # JWT 토큰 관리
│
├── domain/
│   ├── models/
│   │   ├── user_model.dart              # 사용자 데이터 모델
│   │   ├── auth_credential_model.dart   # 인증 자격증명
│   │   ├── premium_user_model.dart      # 프리미엄 사용자
│   │   ├── user_settings_model.dart     # 사용자 설정 모델
│   │   ├── user_contents_model.dart     # 사용자 콘텐츠 모델
│   │   └── value_objects/               # 값 객체
│   │       ├── email_address.dart       # 이메일 값 객체
│   │       ├── password.dart           # 비밀번호 값 객체
│   │       └── phone_number.dart       # 전화번호 값 객체
│   │
│   └── usecases/
│       ├── sign_in/                     # 로그인 관련 UseCase
│       │   ├── sign_in_with_email_usecase.dart
│       │   ├── sign_in_with_google_usecase.dart
│       │   ├── sign_in_with_apple_usecase.dart
│       │   ├── sign_in_with_github_usecase.dart
│       │   ├── sign_in_with_phone_usecase.dart
│       │   └── sign_in_anonymously_usecase.dart
│       ├── sign_up/                     # 회원가입 관련 UseCase
│       │   ├── sign_up_with_email_usecase.dart
│       │   └── verify_age_usecase.dart
│       ├── password/                    # 비밀번호 관련 UseCase
│       │   ├── reset_password_usecase.dart
│       │   ├── update_password_usecase.dart
│       │   └── check_password_strength_usecase.dart
│       ├── session/                     # 세션 관련 UseCase
│       │   ├── sign_out_usecase.dart
│       │   ├── refresh_token_usecase.dart
│       │   └── check_auth_status_usecase.dart
│       └── validation/                  # 검증 관련 UseCase
│           ├── verify_email_usecase.dart
│           ├── verify_phone_usecase.dart
│           └── validate_credentials_usecase.dart
│
└── presentation/
    ├── screens/
    │   ├── start/                       # 시작 화면
    │   │   ├── start_page_widget.dart
    │   │   └── start_page_model.dart
    │   │
    │   ├── login/                       # 로그인 화면
    │   │   ├── login_page_widget.dart
    │   │   └── login_page_model.dart
    │   │
    │   ├── signup/                      # 회원가입 화면
    │   │   ├── create_account_widget.dart
    │   │   └── create_account_model.dart
    │   │
    │   ├── forgot_password/             # 비밀번호 찾기
    │   │   ├── forgot_password_widget.dart
    │   │   └── forgot_password_model.dart
    │   │
    │   ├── phone_auth/                  # 전화번호 인증
    │   │   ├── phone_create_account_widget.dart
    │   │   ├── phone_create_account_model.dart
    │   │   ├── phone_login_pincode_widget.dart
    │   │   └── phone_login_pincode_model.dart
    │   │
    │   └── email_verification/          # 이메일 인증
    │       ├── popup_timer_email_widget.dart
    │       └── popup_timer_email_model.dart
    │
    ├── widgets/
    │   ├── auth_text_field.dart         # 공통 텍스트 입력 필드
    │   ├── password_field.dart          # 비밀번호 입력 필드
    │   ├── email_field.dart             # 이메일 입력 필드
    │   ├── phone_input_field.dart       # 전화번호 입력 필드
    │   ├── pin_code_field.dart          # PIN 코드 입력 필드
    │   ├── auth_button.dart             # 기본 인증 버튼
    │   ├── social_login_button.dart     # 개별 소셜 로그인 버튼
    │   ├── social_login_group.dart      # 소셜 로그인 버튼 그룹
    │   ├── gradient_button.dart         # 그라데이션 버튼
    │   ├── auth_dialog.dart             # 공통 다이얼로그
    │   ├── error_dialog.dart            # 에러 다이얼로그
    │   ├── loading_overlay.dart         # 로딩 오버레이
    │   ├── email_verification_modal.dart # 이메일 인증 모달
    │   ├── auth_progress_indicator.dart # 진행 표시기
    │   ├── password_strength_meter.dart # 비밀번호 강도 측정
    │   ├── biometric_auth_button.dart   # 생체 인증 버튼
    │   └── terms_checkbox.dart          # 약관 동의 체크박스
    │
    └── providers/
        ├── auth_provider.dart            # 인증 상태 관리
        └── firebase_user_provider.dart   # Firebase 사용자 상태
```

## 🎯 마이그레이션 전략

### 백업 및 브랜치 전략
```bash
# 0. 의존성 확인
# Core, Common, App 마이그레이션이 완료되었는지 확인

# 1. 현재 상태 백업
git add .
git commit -m "chore: backup before auth migration"
git push origin flutterflow

# 2. 마이그레이션 브랜치 생성
git checkout -b feature/auth-migration

# 3. 각 Phase별 커밋
# Phase 완료 시마다 커밋하여 롤백 포인트 생성
```

## 📁 상세 파일 이동 계획

### Phase 1: 디렉토리 생성 및 Services 이동 (data/services/)

```bash
# 디렉토리 구조 생성
mkdir -p lib/features/auth/data/repositories
mkdir -p lib/features/auth/data/datasources/remote
mkdir -p lib/features/auth/data/datasources/local
mkdir -p lib/features/auth/data/services
mkdir -p lib/features/auth/domain/models
mkdir -p lib/features/auth/domain/usecases
mkdir -p lib/features/auth/presentation/screens/start
mkdir -p lib/features/auth/presentation/screens/login
mkdir -p lib/features/auth/presentation/screens/signup
mkdir -p lib/features/auth/presentation/screens/forgot_password
mkdir -p lib/features/auth/presentation/screens/phone_auth
mkdir -p lib/features/auth/presentation/screens/email_verification
mkdir -p lib/features/auth/presentation/widgets
mkdir -p lib/features/auth/presentation/providers

```bash
# Firebase Auth 서비스들
git mv lib/auth/firebase_auth/firebase_auth_manager.dart lib/features/auth/data/services/firebase_auth_service.dart
git mv lib/auth/firebase_auth/email_auth.dart lib/features/auth/data/services/email_auth_service.dart
git mv lib/auth/firebase_auth/google_auth.dart lib/features/auth/data/services/google_auth_service.dart
git mv lib/auth/firebase_auth/apple_auth.dart lib/features/auth/data/services/apple_auth_service.dart
git mv lib/auth/firebase_auth/github_auth.dart lib/features/auth/data/services/github_auth_service.dart
git mv lib/auth/firebase_auth/anonymous_auth.dart lib/features/auth/data/services/anonymous_auth_service.dart

# Auth 유틸리티
git mv lib/auth/firebase_auth/auth_util.dart lib/features/auth/data/services/auth_util.dart
git mv lib/auth/firebase_auth/jwt_token_auth.dart lib/features/auth/data/services/jwt_token_service.dart
```

### Phase 2: Models 이동 (domain/models/)

```bash
# 사용자 모델
git mv lib/backend/schema/users_model.dart lib/features/auth/domain/models/user_model.dart
git mv lib/backend/schema/premium_users_model.dart lib/features/auth/domain/models/premium_user_model.dart
git mv lib/backend/schema/user_contents_model.dart lib/features/auth/domain/models/user_contents_model.dart
```

### Phase 3: Screens 이동 (presentation/screens/)

```bash
# 시작 화면
git mv lib/login/start_page lib/features/auth/presentation/screens/start

# 로그인 화면
git mv lib/login/login_page lib/features/auth/presentation/screens/login

# 비밀번호 찾기
git mv lib/login/forgot_password lib/features/auth/presentation/screens/forgot_password

# 회원가입 화면
git mv lib/createaccount/create_account lib/features/auth/presentation/screens/signup

# 전화번호 인증
git mv lib/createaccount/phoneauth/phone_creat_account lib/features/auth/presentation/screens/phone_auth
git mv lib/createaccount/phoneauth/phonelogeinpincode/* lib/features/auth/presentation/screens/phone_auth/

# 이메일 인증
git mv lib/createaccount/popup_timer_email lib/features/auth/presentation/screens/email_verification

# 전화번호 최대 시도
git mv lib/createaccount/phonemaximum lib/features/auth/presentation/screens/phone_auth/max_attempts
```

### Phase 4: Providers 이동 (presentation/providers/)

```bash
# Provider 파일들
git mv lib/auth/firebase_auth/firebase_user_provider.dart lib/features/auth/presentation/providers/
git mv lib/auth/auth_manager.dart lib/features/auth/presentation/providers/auth_provider.dart
git mv lib/auth/base_auth_user_provider.dart lib/features/auth/presentation/providers/base_auth_provider.dart
```

### Phase 5: Repository 생성 (data/repositories/)

```dart
// auth_repository.dart - 인터페이스 정의
abstract class AuthRepository {
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> signInWithGoogle();
  Future<User?> signInWithApple();
  Future<User?> signInWithGithub();
  Future<User?> signInWithPhone(String phoneNumber);
  Future<User?> signInAnonymously();
  Future<User?> signUp(String email, String password);
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<void> verifyEmail();
  Stream<User?> authStateChanges();
}

// auth_repository_impl.dart - 구현체
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _firebaseAuth;
  final EmailAuthService _emailAuth;
  final GoogleAuthService _googleAuth;
  final AppleAuthService _appleAuth;
  final GithubAuthService _githubAuth;
  final PhoneAuthService _phoneAuth;
  final AnonymousAuthService _anonymousAuth;
  
  // 모든 서비스를 조합하여 통합된 인터페이스 제공
}

// user_repository.dart - 사용자 데이터 관리
class UserRepository {
  final FirestoreUserDatasource _firestoreDS;
  final AuthLocalDatasource _localDS;
  
  Future<UserModel> getUserProfile(String uid);
  Future<void> updateUserProfile(UserModel user);
  Future<void> createUserProfile(UserModel user);
  Future<void> deleteUserProfile(String uid);
}
```

### Phase 6: UseCases 생성 (domain/usecases/)

```dart
// 새로 생성할 비즈니스 로직 파일들
// sign_in_usecase.dart
// sign_up_usecase.dart
// sign_out_usecase.dart
// reset_password_usecase.dart
// verify_email_usecase.dart
```

## 📝 Import 경로 업데이트

### 영향받는 주요 파일들

| 파일 | 현재 Import 수 | 설명 |
|------|---------------|------|
| `main.dart` | 3개 | Firebase Auth 초기화 |
| `app_state.dart` | 2개 | 사용자 상태 관리 |
| 각종 페이지 파일 | 50개+ | 인증 체크 로직 |

### Import 변경 예시

```dart
// Before
import '/auth/firebase_auth/auth_util.dart';
import '/auth/firebase_auth/firebase_user_provider.dart';
import '/backend/schema/users_model.dart';

// After
import '/features/auth/data/services/auth_util.dart';
import '/features/auth/presentation/providers/firebase_user_provider.dart';
import '/features/auth/domain/models/user_model.dart';
```

## ✅ 검증 체크리스트

### 기능별 테스트

#### 1. 로그인 기능
- [ ] 이메일 로그인
- [ ] Google 로그인
- [ ] Apple 로그인
- [ ] GitHub 로그인
- [ ] 익명 로그인
- [ ] 전화번호 로그인

#### 2. 회원가입 기능
- [ ] 이메일 회원가입
- [ ] 이메일 인증
- [ ] 프로필 설정
- [ ] 약관 동의

#### 3. 비밀번호 관리
- [ ] 비밀번호 재설정
- [ ] 비밀번호 변경

#### 4. 세션 관리
- [ ] 자동 로그인
- [ ] 로그아웃
- [ ] 세션 만료 처리

## 🔧 Repository 레이어 상세 구현

### data/repositories 디렉토리 구성

#### 1. auth_repository.dart (인터페이스)
- 모든 인증 메서드의 추상 인터페이스 정의
- Clean Architecture의 Domain 레이어와 Data 레이어 분리
- 테스트 가능한 구조 제공

#### 2. auth_repository_impl.dart (구현체)
- 실제 Firebase 서비스들과 연동
- 에러 처리 및 예외 변환
- 캐싱 전략 구현
- 재시도 로직 포함

#### 3. user_repository.dart
- Firestore 사용자 데이터 CRUD
- 프로필 이미지 업로드 관리
- 사용자 설정 저장/로드
- 프리미엄 사용자 상태 관리

### data/datasources 디렉토리 구성

#### remote/ (원격 데이터소스)
- firebase_auth_datasource.dart: Firebase Auth SDK 직접 접근
- firestore_user_datasource.dart: Firestore 사용자 컬렉션 접근

#### local/ (로컬 데이터소스)
- auth_local_datasource.dart: SharedPreferences 또는 Hive를 사용한 로컬 캐싱

## ⚠️ 주의사항

### 1. Firebase 설정
- Firebase 프로젝트 설정 파일 경로 유지
- SHA 인증서 설정 확인 (Android)
- Bundle ID 설정 확인 (iOS)

### 2. 보안 고려사항
- API 키 노출 방지
- 민감한 사용자 정보 암호화
- 토큰 관리 보안

### 3. 마이그레이션 순서
1. **백업 필수**: 현재 브랜치 백업
2. **단계별 진행**: Phase별로 테스트
3. **Import 자동화**: VS Code 자동 수정 활용
4. **통합 테스트**: 전체 인증 플로우 검증

## 📊 예상 영향도

| 구분 | 영향도 | 파일 수 | 설명 |
|------|--------|---------|------|
| **Services** | 높음 | 11개 | 핵심 인증 로직 |
| **Models** | 중간 | 3개 | 데이터 구조 |
| **Screens** | 높음 | 10개 | UI/UX 영향 |
| **Providers** | 높음 | 3개 | 상태 관리 |
| **총 영향** | **매우 높음** | **50개+** | 앱 전체 영향 |

## 🔄 롤백 계획

```bash
# 문제 발생 시 롤백
git reset --hard HEAD~1
git checkout main

# 또는 백업 브랜치로 복귀
git checkout backup/before-auth-migration
```

## 📅 예상 소요 시간 (상세)

| Phase | 작업 내용 | 소요 시간 | 난이도 | 체크포인트 |
|-------|-----------|----------|--------|------------|
| Phase 0: 준비 | 백업 및 브랜치 생성 | 10분 | ⭐ | 브랜치 생성 확인 |
| Phase 1: Services | 11개 서비스 파일 이동 | 1시간 | ⭐⭐⭐ | Import 에러 없음 |
| Phase 2: Models | 3개 모델 파일 이동 | 30분 | ⭐⭐ | 모델 타입 체크 |
| Phase 3: Screens | 10개 화면 파일 이동 | 2시간 | ⭐⭐⭐⭐ | UI 렌더링 정상 |
| Phase 4: Providers | 3개 프로바이더 이동 | 30분 | ⭐⭐ | 상태 관리 동작 |
| Phase 5: Repository | Repository 패턴 구현 | 1시간 | ⭐⭐⭐⭐ | 단위 테스트 통과 |
| Phase 6: UseCases | 비즈니스 로직 분리 | 1시간 | ⭐⭐⭐ | 통합 테스트 통과 |
| Phase 7: Import 수정 | 전체 Import 경로 수정 | 30분 | ⭐⭐ | 컴파일 성공 |
| Phase 8: 테스트 | 통합 테스트 및 검증 | 1시간 | ⭐⭐⭐ | 모든 인증 플로우 동작 |
| **총 소요 시간** | **전체 마이그레이션** | **7시간 10분** | ⭐⭐⭐⭐ | 프로덕션 준비 완료 |

## 🚀 실행 가이드

### 1단계: 준비 작업
```bash
# 현재 상태 저장
git add .
git commit -m "chore: save current state before auth migration"

# 마이그레이션 브랜치 생성
git checkout -b feature/architecture-refactor

# 디렉토리 구조 생성
bash << 'EOF'
mkdir -p lib/features/auth/{data/{repositories,datasources/{remote,local},services},domain/{models,usecases},presentation/{screens/{start,login,signup,forgot_password,phone_auth,email_verification},widgets,providers}}
EOF
```

### 2단계: Phase별 실행 명령어

#### Phase 1: Services (11개 파일)
```bash
# Firebase Auth 서비스 이동
git mv lib/auth/firebase_auth/firebase_auth_manager.dart lib/features/auth/data/services/
git mv lib/auth/firebase_auth/auth_util.dart lib/features/auth/data/services/
git mv lib/auth/firebase_auth/email_auth.dart lib/features/auth/data/services/
git mv lib/auth/firebase_auth/google_auth.dart lib/features/auth/data/services/
git mv lib/auth/firebase_auth/apple_auth.dart lib/features/auth/data/services/
git mv lib/auth/firebase_auth/github_auth.dart lib/features/auth/data/services/
git mv lib/auth/firebase_auth/anonymous_auth.dart lib/features/auth/data/services/
git mv lib/auth/firebase_auth/jwt_token_auth.dart lib/features/auth/data/services/jwt_token_service.dart
git mv lib/auth/auth_manager.dart lib/features/auth/data/services/

# 커밋
git add .
git commit -m "refactor(auth): migrate auth services to feature-first structure"
```

#### Phase 2: Models (3개 파일)
```bash
# 모델 파일 이동
git mv lib/backend/schema/users_model.dart lib/features/auth/domain/models/user_model.dart
git mv lib/backend/schema/premium_users_model.dart lib/features/auth/domain/models/premium_user_model.dart
git mv lib/backend/schema/user_contents_model.dart lib/features/auth/domain/models/user_contents_model.dart

# 커밋
git add .
git commit -m "refactor(auth): migrate user models to domain layer"
```

#### Phase 3: Screens (10개 파일)
```bash
# 로그인 관련 화면 이동
git mv lib/login/start_page/* lib/features/auth/presentation/screens/start/
git mv lib/login/login_page/* lib/features/auth/presentation/screens/login/
git mv lib/login/forgot_password/* lib/features/auth/presentation/screens/forgot_password/

# 회원가입 관련 화면 이동
git mv lib/createaccount/create_account/* lib/features/auth/presentation/screens/signup/
git mv lib/createaccount/phoneauth/phone_creat_account/* lib/features/auth/presentation/screens/phone_auth/
git mv lib/createaccount/phoneauth/phonelogeinpincode/* lib/features/auth/presentation/screens/phone_auth/
git mv lib/createaccount/phonemaximum/* lib/features/auth/presentation/screens/phone_auth/
git mv lib/createaccount/popup_timer_email/* lib/features/auth/presentation/screens/email_verification/

# 커밋
git add .
git commit -m "refactor(auth): migrate auth screens to presentation layer"
```

#### Phase 4: Providers (2개 파일)
```bash
# Provider 파일 이동
git mv lib/auth/firebase_auth/firebase_user_provider.dart lib/features/auth/presentation/providers/
git mv lib/auth/base_auth_user_provider.dart lib/features/auth/presentation/providers/

# 커밋
git add .
git commit -m "refactor(auth): migrate auth providers"
```

### 3단계: 새 파일 생성
```bash
# Repository 인터페이스 생성
cat > lib/features/auth/data/repositories/auth_repository.dart << 'EOF'
abstract class AuthRepository {
  // 인터페이스 정의
}
EOF

# Repository 구현체 생성
cat > lib/features/auth/data/repositories/auth_repository_impl.dart << 'EOF'
class AuthRepositoryImpl implements AuthRepository {
  // 구현 코드
}
EOF

# 커밋
git add .
git commit -m "feat(auth): create repository pattern implementation"
```

### 4단계: Import 경로 일괄 수정
```bash
# VS Code의 경우
# 1. Cmd+Shift+F (전체 찾기/바꾸기)
# 2. 정규식 모드 활성화
# 3. 다음 패턴으로 일괄 변경:

# 찾기: import '/?auth/
# 바꾸기: import '/features/auth/data/services/

# 찾기: import '/?login/
# 바꾸기: import '/features/auth/presentation/screens/

# 찾기: import '/?createaccount/
# 바꾸기: import '/features/auth/presentation/screens/

# 찾기: import '/?backend/schema/users
# 바꾸기: import '/features/auth/domain/models/user
```

### 5단계: 검증 및 테스트
```bash
# 빌드 테스트
flutter clean
flutter pub get
flutter build ios --debug

# 단위 테스트 실행
flutter test test/auth/

# 통합 테스트
flutter drive --target=test_driver/auth_test.dart
```

### 6단계: 최종 커밋 및 PR
```bash
# 최종 커밋
git add .
git commit -m "refactor(auth): complete feature-first architecture migration"

# PR 생성
git push origin feature/architecture-refactor
# GitHub에서 PR 생성 및 리뷰 요청
```

## 📊 마이그레이션 체크리스트

### Pre-Migration
- [ ] Core 마이그레이션 완료 확인
- [ ] Common Feature 마이그레이션 완료 확인
- [ ] App Feature 마이그레이션 완료 확인
- [ ] 현재 코드 백업 완료
- [ ] feature/auth-migration 브랜치 생성
- [ ] 팀원들에게 마이그레이션 공지
- [ ] CI/CD 파이프라인 일시 중지

### Migration Progress
- [ ] Phase 0: 준비 작업 완료 (10분)
- [ ] Phase 1: Services 이동 완료 (1시간)
- [ ] Phase 2: Models 이동 완료 (30분)
- [ ] Phase 3: Screens 이동 완료 (2시간)
- [ ] Phase 4: Providers 이동 완료 (30분)
- [ ] Phase 5: Repository 생성 완료 (1시간)
- [ ] Phase 6: UseCases 생성 완료 (1시간)
- [ ] Phase 7: Import 경로 수정 완료 (30분)
- [ ] Phase 8: 테스트 통과 (1시간)

### Post-Migration
- [ ] 모든 인증 플로우 수동 테스트
- [ ] 성능 벤치마크 실행
- [ ] 문서 업데이트
- [ ] PR 리뷰 및 머지
- [ ] 프로덕션 배포
- [ ] 모니터링 및 롤백 준비

---

*이 문서는 Feature-First Architecture 마이그레이션의 Auth Feature 상세 통합 가이드입니다.*
*작성일: 2025-08-24*
*버전: 2.0 (모든 하위 디렉토리 포함)*
*예상 작업 시간: 7시간 10분*