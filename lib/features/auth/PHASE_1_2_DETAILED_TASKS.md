# 📋 Auth Feature 마이그레이션 Phase 1-2 상세 타스크

> **작성일**: 2025-01-20
> **버전**: 1.0.0
> **참조**: ARCHITECTURE_RULES.md v4.0, SUBAGENTS_MANUAL.md
> **원칙**: Direct Migration (Facade 없음), 기존 코드 재사용, 서브에이전트 활용

## 🎯 마이그레이션 원칙 체크리스트

### Clean Architecture v4.0 준수 사항
- [ ] **Decompose & Reorganize**: 레거시 코드를 작은 UseCase로 분해
- [ ] **기존 코드 재사용**: 새로 만들지 않고 이동/변환
- [ ] **3-Layer 준수**: Presentation → Domain → Data
- [ ] **Feature 독립성**: Auth는 다른 Feature 의존 금지
- [ ] **Core 순수성**: Core에 구현체 없음 (인터페이스만)
- [ ] **직접 전환**: Facade/Bridge 패턴 사용 금지

---

## 📊 Phase 1: 현재 상태 분석 [✅ 완료]

### 1.1 Inventory Scout 실행 (베이스라인)

#### 실행 명령
- [x] Inventory Scout 실행 완료
  ```bash
  /spawn inventory-scout "depth 5로 auth 피처 스캔, 300줄 이상 큰 파일과 복합 책임 찾기"
  ```

#### 산출물 검증
- [x] `reports/inventory_auth.json` 생성 확인
- [x] `reports/violations_auth.txt` 생성 확인
- [x] `reports/candidates_decompose_auth.txt` 생성 확인
- [x] `reports/tree_lib.txt` 생성 확인

#### 분석 결과 확인
- [x] 대형 파일 9개 식별
  - [x] login_page_widget.dart (1,378줄)
  - [x] create_account_widget.dart (883줄)
  - [x] phonelogeinpincode_widget.dart (701줄)
  - [x] start_page_widget.dart (586줄)
  - [x] phone_creat_account_widget.dart (500줄)
  - [x] popup_timer_email_widget.dart (432줄)
  - [x] firebase_auth_manager.dart (364줄)
  - [x] forgot_password_widget.dart (355줄)
  - [x] auth_util.dart (77줄)

- [x] Architecture 위반 7건 확인
  - [x] Presentation → Data 직접 임포트 7건

### 1.2 Import Guardian 초기 분석

#### 실행 명령
- [x] Import Guardian detect 모드 실행
  ```bash
  /spawn import-guardian "--scope auth --mode detect"
  ```

#### 산출물 검증
- [x] `reports/import_violations_auth.txt` 생성
- [x] 위반 패턴 분석
  - [x] `/features/auth/data/adapters/auth_util.dart` 직접 임포트 7건
  - [x] Firebase 직접 의존성 확인
  - [x] Cross-feature 의존성 확인 (Profile feature)

---

## 📦 Phase 2: UseCase & Mapper 레이어 구축

### 2.1 대형 파일 분해 준비

#### 2.1.1 LoginPageWidget 분석 (1,378줄)
- [ ] 파일 백업 생성
  ```bash
  cp lib/features/auth/presentation/screens/login_page_widget.dart \
     lib/features/auth/presentation/screens/login_page_widget.dart.backup
  ```

- [ ] 비즈니스 로직 추출 대상 식별
  - [ ] Email 로그인 로직 (약 150줄)
  - [ ] Google 로그인 로직 (약 100줄)
  - [ ] Apple 로그인 로직 (약 100줄)
  - [ ] 폼 검증 로직 (약 80줄)
  - [ ] 네비게이션 로직 (약 50줄)

- [ ] CodeSurgeon 실행 (dry-run)
  ```bash
  /spawn code-surgeon "--file lib/features/auth/presentation/screens/login_page_widget.dart --strategy extract-usecases --max-lines 50 --mode dry-run"
  ```

- [ ] 패치 검토
  - [ ] `patches/code_surgeon_login_page.diff` 검토
  - [ ] UI 로직 남아있는지 확인
  - [ ] 비즈니스 로직 완전 추출 확인

#### 2.1.2 CreateAccountWidget 분석 (883줄)
- [ ] 파일 백업 생성
- [ ] 비즈니스 로직 추출 대상 식별
  - [ ] 계정 생성 로직 (약 120줄)
  - [ ] 이메일 검증 로직 (약 80줄)
  - [ ] 프로필 설정 로직 (약 100줄)
  - [ ] 폼 검증 로직 (약 60줄)

- [ ] CodeSurgeon 실행 (dry-run)
  ```bash
  /spawn code-surgeon "--file lib/features/auth/presentation/screens/create_account_widget.dart --strategy extract-usecases --max-lines 50 --mode dry-run"
  ```

- [ ] 패치 검토

#### 2.1.3 FirebaseAuthManager 분석 (364줄)
- [ ] 파일 백업 생성
- [ ] DataSource 분리 대상 식별
  - [ ] Firebase Auth 직접 호출 (약 200줄)
  - [ ] Firestore 사용자 정보 저장 (약 100줄)
  - [ ] 토큰 관리 로직 (약 64줄)

- [ ] CodeSurgeon 실행 (dry-run)
  ```bash
  /spawn code-surgeon "--file lib/features/auth/data/adapters/firebase_auth_manager.dart --strategy extract-datasources --mode dry-run"
  ```

### 2.2 UseCase 생성

#### 2.2.1 인증 기본 UseCase (7개)
- [ ] SignInWithEmailUseCase 생성
  - [ ] 인터페이스 정의
  - [ ] LoginPageWidget에서 로직 추출
  - [ ] Repository 메서드 호출
  - [ ] 에러 처리 로직 포함

- [ ] SignInWithGoogleUseCase 생성
  - [ ] Google Sign In 로직 추출
  - [ ] Firebase 연동 처리
  - [ ] 사용자 정보 매핑

- [ ] SignInWithAppleUseCase 생성
- [ ] SignInWithGitHubUseCase 생성
- [ ] SignInWithPhoneUseCase 생성
- [ ] SignInAnonymouslyUseCase 생성
- [ ] SignOutUseCase 생성

#### 2.2.2 계정 관리 UseCase (7개)
- [ ] CreateAccountWithEmailUseCase 생성
- [ ] CreatePhoneAccountUseCase 생성
- [ ] VerifyEmailUseCase 생성
- [ ] VerifyPhoneOtpUseCase 생성
- [ ] ResetPasswordUseCase 생성
- [ ] UpdatePasswordUseCase 생성
- [ ] DeleteAccountUseCase 생성

#### 2.2.3 사용자 정보 UseCase (6개)
- [ ] GetCurrentUserUseCase 생성
- [ ] GetCurrentUserEmailUseCase 생성
- [ ] GetCurrentUserUidUseCase 생성
- [ ] IsAuthenticatedUseCase 생성
- [ ] IsEmailVerifiedUseCase 생성
- [ ] UpdateUserEmailUseCase 생성

#### 2.2.4 토큰 관리 UseCase (2개)
- [ ] GetJwtTokenUseCase 생성
- [ ] RefreshTokenUseCase 생성

#### 2.2.5 Phone Auth UseCase (3개)
- [ ] SendSmsOtpUseCase 생성
- [ ] ResendSmsOtpUseCase 생성
- [ ] VerifySmsOtpUseCase 생성

#### 2.2.6 세션 관리 UseCase (5개)
- [ ] CheckAuthStateUseCase 생성
- [ ] StreamAuthStateUseCase 생성
- [ ] HandleAuthRedirectUseCase 생성

### 2.3 Mapper 생성 (Firebase 1:1 매칭)

#### 2.3.1 DTO 모델 생성
- [ ] AuthUserDto 생성
  - [ ] Firebase 필드명 완전 일치 확인
  - [ ] camelCase 규칙 준수
  - [ ] toJson/fromJson 메서드 구현
  ```dart
  // 필드명 체크리스트
  - [ ] uid (String)
  - [ ] email (String?)
  - [ ] displayName (String?) // 절대 변경 금지
  - [ ] photoUrl (String?)     // 절대 변경 금지
  - [ ] isEmailVerified (bool)
  - [ ] authProvider (String)
  - [ ] createdAt (Timestamp?)
  - [ ] lastLoginAt (Timestamp?)
  ```

- [ ] AuthTokenDto 생성
- [ ] AuthSessionDto 생성
- [ ] AuthProviderDto 생성

#### 2.3.2 Mapper 구현
- [ ] FirestoreUserMapper 생성
  - [ ] fromFirestore 메서드 (Map → DTO)
  - [ ] toFirestore 메서드 (DTO → Map)
  - [ ] 필드명 1:1 매칭 검증

- [ ] FirebaseUserMapper 생성
  - [ ] fromFirebaseUser 메서드
  - [ ] Provider 감지 로직

- [ ] AuthUserMapper 생성
  - [ ] toDomain 메서드 (DTO → Domain)
  - [ ] toDto 메서드 (Domain → DTO)

- [ ] StructWeaver로 Mapper 자동 생성
  ```bash
  /spawn struct-weaver "--task mapper --source lib/features/auth/domain/models --target lib/features/auth/data/mappers --mode detect --bridge false"
  ```

- [ ] 생성된 Mapper 검증
  - [ ] Firebase 필드명 변경 없음 확인
  - [ ] 타입 변환 정확성 확인
  - [ ] Null safety 처리 확인

### 2.4 Repository 구현체 수정

#### 2.4.1 AuthRepositoryImpl 리팩토링
- [ ] Mapper 주입 준비
  - [ ] Constructor에 Mapper 추가
  - [ ] Private 필드 선언

- [ ] getCurrentUser 메서드 수정
  - [ ] Firestore Document 가져오기
  - [ ] FirestoreUserMapper.fromFirestore 사용
  - [ ] AuthUserMapper.toDomain 사용
  - [ ] 로컬 캐시 업데이트

- [ ] signInWithEmail 메서드 수정
  - [ ] Firebase Auth 호출
  - [ ] FirebaseUserMapper 사용
  - [ ] Firestore 저장 (toFirestore)
  - [ ] Domain Model 반환

### 2.5 DataSource 인터페이스 정의

#### 2.5.1 Remote DataSource
- [ ] IAuthRemoteDataSource 인터페이스 생성
  ```dart
  abstract class IAuthRemoteDataSource {
    Future<User> getCurrentFirebaseUser();
    Future<Map<String, dynamic>> getUserDocument(String uid);
    Future<void> saveUserDocument(String uid, Map<String, dynamic> data);
    Future<UserCredential> signInWithEmail(String email, String password);
    // ... 기타 메서드
  }
  ```

- [ ] FirebaseAuthDataSource 구현체 생성
  - [ ] Firebase Auth 인스턴스 주입
  - [ ] Firestore 인스턴스 주입
  - [ ] 모든 Firebase 호출 캡슐화

#### 2.5.2 Local DataSource
- [ ] IAuthLocalDataSource 인터페이스 생성
- [ ] AuthLocalDataSource 구현체 생성
  - [ ] SharedPreferences 사용
  - [ ] 사용자 정보 캐싱
  - [ ] 토큰 저장

### 2.6 품질 검증

#### 2.6.1 Architecture Rules 검증
- [ ] Presentation → Domain → Data 의존성 방향 확인
- [ ] Feature 독립성 확인 (Auth ↛ 다른 Feature)
- [ ] Core Layer 순수성 확인 (구현체 없음)
- [ ] 직접 전환 확인 (Facade 없음)

#### 2.6.2 서브에이전트 산출물 검증
- [ ] 모든 패치 파일 생성 확인
- [ ] 모든 리포트 파일 생성 확인
- [ ] Git diff로 변경사항 검토

#### 2.6.3 BuildSentinel Quick 실행
- [ ] BuildSentinel quick 모드 실행
  ```bash
  /spawn build-sentinel "quick --feature auth"
  ```

- [ ] 결과 확인
  - [ ] flutter analyze 통과
  - [ ] 컴파일 에러 없음
  - [ ] Import 위반 감소 확인

---

## 📈 진행 상황 추적

### Phase 1 완료율: 100% ✅
- Inventory Scout: ✅
- Import Guardian (detect): ✅
- 현황 분석 문서: ✅

### Phase 2 완료율: 0% 🔄
- UseCase 생성: 0/30
- Mapper 생성: 0/6
- DTO 모델: 0/4
- DataSource: 0/2
- Repository 수정: 0/1

### 서브에이전트 사용 현황
| 에이전트 | Phase 1 | Phase 2 | 상태 |
|---------|---------|---------|------|
| Inventory Scout | ✅ | - | 완료 |
| Import Guardian | ✅ | 🔄 | 진행예정 |
| CodeSurgeon | - | 🔄 | 준비중 |
| StructWeaver | - | 🔄 | 준비중 |
| BuildSentinel | - | 🔄 | 대기중 |

### 다음 단계
1. Phase 2.1: 대형 파일 분해 (CodeSurgeon)
2. Phase 2.2-2.3: UseCase & Mapper 생성
3. Phase 2.6: 품질 검증 (BuildSentinel)
4. Phase 3 준비: Repository 이동 (RepoMover)

---

**이 문서는 Auth Feature의 Phase 1-2 상세 실행 계획입니다.**
**모든 체크박스를 완료하면 Clean Architecture 기반이 완성됩니다.**