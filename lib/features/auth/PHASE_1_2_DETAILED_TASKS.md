# 📋 Auth Feature 마이그레이션 Phase 1-2 상세 타스크

> **작성일**: 2025-01-20
> **버전**: 2.0.0 (Claude-centric JSON 아키텍처 반영)
> **참조**: ARCHITECTURE_RULES.md v4.0, SUBAGENTS_MANUAL.md v2.0
> **원칙**: Direct Migration (Facade 없음), 기존 코드 재사용, Claude-centric JSON 에이전트 활용

## 🚨 올바른 마이그레이션 워크플로우

### Claude-centric JSON 에이전트 사용 방법
모든 에이전트는 이제 `--output stdout` 파라미터를 사용하여 Claude가 직접 읽을 수 있는 JSON을 반환합니다.

```bash
# 기존 방식 (사람이 읽는 리포트)
/spawn inventory-scout "auth 스캔"

# 새 방식 (Claude가 읽는 JSON)
python3 inventory_scout.py --scope auth --depth 5 --output stdout
```

### CodeSurgeon 사용 시 필수 순서
1. **파일 백업** - 원본 상태 보존
2. **패치 생성** - CodeSurgeon dry-run 모드 + JSON 출력
3. **에이전트 체이닝** - JSON의 next_action 따라 자동 진행
4. **패치 적용** - git apply (중간 수정 없이!)
5. **검증** - BuildSentinel JSON 기반 자동 검증
6. **다음 파일** - JSON decision_hints 참고하여 진행

**⚠️ 주의사항**:
- 절대 패치 생성과 적용 사이에 파일 수정 금지
- 패치는 원본 파일 기준으로만 작동
- 실패 시 JSON의 recovery_strategy 따라 자동 복구

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
  # Claude-centric JSON 방식
  python3 inventory_scout.py --scope auth --depth 5 --output stdout

  # JSON 응답 예시:
  # {
  #   "agent": "inventory-scout",
  #   "status": "success",
  #   "data": {
  #     "large_files": [...],
  #     "violations": [...]
  #   },
  #   "next_action": {
  #     "recommended_agent": "code-surgeon",
  #     "params": {"file": "...", "mode": "dry-run"},
  #     "priority": "high"
  #   }
  # }
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
  # Claude-centric JSON 방식
  python3 import_guardian.py --scope auth --mode detect --output stdout

  # 자동 에러 복구 예시:
  # JSON 응답의 decision_hints에서 자동으로 fix 모드 권장
  # {
  #   "decision_hints": {
  #     "has_violations": true,
  #     "auto_fixable": true,
  #     "needs_fix": true
  #   }
  # }
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

**현재 상태**: ⚠️ 패치 생성 완료, 적용 실패 (10%만 적용됨)

- [x] 파일 백업 생성 ✅
  ```bash
  cp lib/features/auth/presentation/screens/login/login_page/login_page_widget.dart \
     lib/features/auth/presentation/screens/login/login_page/login_page_widget.dart.backup
  ```

- [x] 비즈니스 로직 추출 대상 식별 ✅
  - [x] Email 로그인 로직 (signInWithEmail 호출 6곳)
  - [ ] ~~Google 로그인 로직~~ (이 파일에 없음)
  - [ ] ~~Apple 로그인 로직~~ (이 파일에 없음)
  - [x] 계정 생성 로직 (createAccountWithEmail 호출 5곳)
  - [x] 테스트 계정 관리 로직 (Admin, iOS, Android, macOS, Web)

- [x] CodeSurgeon 실행 (dry-run) ✅
  ```bash
  # Claude-centric JSON 방식
  python3 code_surgeon.py \
    --file lib/features/auth/presentation/screens/login/login_page/login_page_widget.dart \
    --map "SignInLogic->lib/features/auth/domain/usecases/sign_in_usecase.dart" \
    --mode dry-run \
    --output stdout

  # 에러 발생 시 자동 복구:
  # JSON 응답에서 자동으로 다음 단계 권장
  # {
  #   "status": "partial",
  #   "next_action": {
  #     "recommended_agent": "code-surgeon",
  #     "params": {"mode": "apply", "patch": "3-way"},
  #     "reason": "부분 적용 실패, 3-way merge 필요"
  #   }
  # }
  ```

- [x] 패치 검토 ✅
  - [x] `patches/code_surgeon_login_page.diff` 생성 완료
  - [ ] **⚠️ 패치 적용 실패** (git apply 부분 실패)
  - [ ] 비즈니스 로직 완전 추출 확인 - 10%만 완료

- [ ] **패치 적용** 🔄 (재시도 필요)
  ```bash
  # 백업에서 원본 복원
  cp login_page_widget.dart.backup login_page_widget.dart

  # 패치 재적용 (3-way merge)
  git apply --3way patches/code_surgeon_login_page.diff
  ```

- [ ] **검증**
  - [ ] flutter analyze 통과
  - [ ] 기능 테스트
  - [ ] authManager 직접 호출 제거 확인 (현재 10개 남음)

#### 2.1.2 CreateAccountWidget 분석 (883줄)

**현재 상태**: ⚠️ 패치 생성 완료, 적용 대기 중

- [x] 파일 백업 생성 ✅
  ```bash
  cp lib/features/auth/presentation/screens/signup/create_account/create_account_widget.dart \
     lib/features/auth/presentation/screens/signup/create_account/create_account_widget.dart.backup
  ```
- [x] 비즈니스 로직 추출 대상 식별 ✅
  - [x] 계정 생성 로직 (createAccountWithEmail)
  - [x] 이메일 검증 로직 (sendEmailVerification)
  - [ ] 프로필 설정 로직 (추가 분석 필요)
  - [ ] 폼 검증 로직 (추가 분석 필요)

- [x] CodeSurgeon 실행 (dry-run) ✅
  ```bash
  # Claude-centric JSON 방식
  python3 code_surgeon.py \
    --file lib/features/auth/presentation/screens/signup/create_account/create_account_widget.dart \
    --map "CreateAccountLogic->lib/features/auth/domain/usecases/create_account_usecase.dart" \
    --mode dry-run \
    --output stdout
  ```

- [x] 패치 검토 ✅
  - [x] `patches/code_surgeon_create_account.diff` 생성 완료

- [ ] **패치 적용** 🔄 (대기 중)
  ```bash
  # 백업에서 원본 복원 (만약 수정했다면)
  cp create_account_widget.dart.backup create_account_widget.dart

  # 패치 적용
  git apply patches/code_surgeon_create_account.diff
  ```

- [ ] **검증**
  - [ ] flutter analyze 통과
  - [ ] 기능 테스트

#### 2.1.3 FirebaseAuthManager 분석 (364줄)

**현재 상태**: 🔄 대기 중

- [ ] 파일 백업 생성
  ```bash
  cp lib/features/auth/data/adapters/firebase_auth_manager.dart \
     lib/features/auth/data/adapters/firebase_auth_manager.dart.backup
  ```

- [ ] DataSource 분리 대상 식별
  - [ ] Firebase Auth 직접 호출 (약 200줄)
  - [ ] Firestore 사용자 정보 저장 (약 100줄)
  - [ ] 토큰 관리 로직 (약 64줄)

- [ ] CodeSurgeon 실행 (dry-run)
  ```bash
  # Claude-centric JSON 방식
  python3 code_surgeon.py \
    --file lib/features/auth/data/adapters/firebase_auth_manager.dart \
    --map "FirebaseDataSource->lib/features/auth/data/datasources/firebase_auth_datasource.dart" \
    --mode dry-run \
    --output stdout
  ```

- [ ] 패치 검토

- [ ] **패치 적용**
  ```bash
  git apply patches/code_surgeon_firebase_auth_manager.diff
  ```

- [ ] **검증**

### 2.2 UseCase 생성

**참고**: CodeSurgeon 패치 적용 시 자동으로 생성되는 UseCase와 추가로 생성해야 할 UseCase를 구분

#### 2.2.1 CodeSurgeon으로 생성되는 UseCase (패치 적용 시 자동 생성)
- [x] SignInWithEmailUseCase ✅ (code_surgeon_login_page.diff에 포함)
- [x] CreateTestAccountUseCase ✅ (code_surgeon_login_page.diff에 포함)
- [ ] CreateAccountWithEmailUseCase (code_surgeon_create_account.diff에 포함 예정)
- [ ] VerifyEmailUseCase (code_surgeon_create_account.diff에 포함 예정)

#### 2.2.2 추가로 생성 필요한 UseCase
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
  # Claude-centric JSON 방식
  python3 struct_weaver.py \
    --task mapper \
    --mode detect \
    --output stdout

  # JSON 응답에 따라 자동으로 apply 모드로 진행
  # {
  #   "next_action": {
  #     "recommended_agent": "struct-weaver",
  #     "params": {"mode": "apply"},
  #     "priority": "high",
  #     "reason": "Mapper 파일 생성 준비 완료"
  #   }
  # }
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
  # Claude-centric JSON 방식
  bash build_sentinel.sh quick

  # JSON 출력 포함 (build_sentinel.json)
  python3 build_sentinel_json.py \
    --status "success" \
    --errors 0 \
    --warnings 0 \
    --failures 0 \
    --mode "quick"

  # 실패 시 자동으로 원인 분석
  # {
  #   "next_action": {
  #     "recommended_agent": "import-guardian",
  #     "params": {"mode": "fix", "scope": "auth"},
  #     "reason": "Import 위반으로 인한 컴파일 에러"
  #   }
  # }
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

### Phase 2 완료율: 10% ⚠️
- UseCase 생성: 2/30 (CodeSurgeon 패치로 2개 생성, 10%만 적용)
- Mapper 생성: 0/6
- DTO 모델: 0/4
- DataSource: 0/2
- Repository 수정: 0/1
- **문제**: LoginPageWidget 패치 적용 실패로 진행 중단

### 서브에이전트 사용 현황 (v2.0 Claude-centric JSON)
| 에이전트 | Phase 1 | Phase 2 | JSON 출력 | 자동 체이닝 |
|---------|---------|---------|-----------|------------|
| Inventory Scout | ✅ | - | ✅ | ✅ |
| Import Guardian | ✅ | 🔄 | ✅ | ✅ |
| CodeSurgeon | - | 🔄 | ✅ | ✅ |
| StructWeaver | - | 🔄 | ✅ | ✅ |
| BuildSentinel | - | 🔄 | ✅ | ✅ |
| OrchestratorPipeline | - | - | ✅ | ✅ |

### 다음 단계
1. Phase 2.1: 대형 파일 분해 (CodeSurgeon)
2. Phase 2.2-2.3: UseCase & Mapper 생성
3. Phase 2.6: 품질 검증 (BuildSentinel)
4. Phase 3 준비: Repository 이동 (RepoMover)

---

## 🤖 자동화된 에러 복구 전략

### JSON 기반 자동 복구 플로우
모든 에이전트는 실패 시 자동으로 복구 전략을 제시합니다:

```json
{
  "status": "error",
  "error": {
    "type": "patch_conflict",
    "message": "Patch cannot be applied cleanly"
  },
  "recovery_strategy": {
    "steps": [
      {"action": "restore_from_backup", "file": "login_page_widget.dart.backup"},
      {"action": "re-run", "agent": "code-surgeon", "params": {"mode": "detect"}},
      {"action": "manual_fix", "suggestion": "Use 3-way merge"}
    ]
  },
  "next_action": {
    "recommended_agent": "code-surgeon",
    "params": {"mode": "apply", "patch": "3-way"},
    "priority": "high"
  }
}
```

### 일반적인 에러 시나리오와 자동 복구

1. **패치 충돌**: 백업에서 복원 → 3-way merge 시도
2. **Import 위반**: import-guardian fix 모드 자동 실행
3. **컴파일 에러**: build-sentinel → import-guardian 체인
4. **부분 적용**: 성공한 부분 유지 → 실패 부분만 재시도

---

## 🔄 OrchestratorPipeline 활용

### 복잡한 워크플로우 자동화
```bash
# Phase 2 전체를 한 번에 실행
python3 orchestrator_pipeline.py \
  --feature auth \
  --pipeline c7 \
  --output stdout

# c7 파이프라인 자동 실행 순서:
# 1. inventory-scout (상태 분석)
# 2. code-surgeon (파일 분해)
# 3. struct-weaver (Mapper 생성)
# 4. di-binder (DI 등록)
# 5. import-guardian (위반 수정)
# 6. router-splitter (라우터 분리)
# 7. build-sentinel (최종 검증)
```

### Quality 파이프라인
```bash
# 품질 검증만 실행
python3 orchestrator_pipeline.py \
  --feature auth \
  --pipeline quality \
  --output stdout

# 실행 순서:
# 1. inventory-scout (대형 파일 탐지)
# 2. import-guardian (아키텍처 위반 탐지)
```

---

## 📊 JSON 체이닝 예시

### 성공적인 체이닝 플로우
```python
# 1. Inventory Scout 실행
response1 = inventory_scout(scope="auth")
# response1.next_action = {"recommended_agent": "code-surgeon", ...}

# 2. 자동으로 CodeSurgeon 실행
response2 = code_surgeon(response1.next_action.params)
# response2.next_action = {"recommended_agent": "struct-weaver", ...}

# 3. 자동으로 StructWeaver 실행
response3 = struct_weaver(response2.next_action.params)
# response3.next_action = {"recommended_agent": "build-sentinel", ...}

# 4. 최종 검증
response4 = build_sentinel(response3.next_action.params)
# response4.status = "success"
```

### decision_hints 활용
```json
{
  "decision_hints": {
    "has_large_files": true,      // 대형 파일 존재
    "needs_decomposition": true,   // 분해 필요
    "auto_fixable": true,          // 자동 수정 가능
    "complexity": 0.8,             // 복잡도
    "priority_files": [            // 우선순위 파일
      "login_page_widget.dart",
      "create_account_widget.dart"
    ]
  }
}
```

---

**이 문서는 Auth Feature의 Phase 1-2 상세 실행 계획입니다.**
**Claude-centric JSON 아키텍처를 통해 자동화되고 지능적인 마이그레이션이 가능합니다.**
**모든 체크박스를 완료하면 Clean Architecture 기반이 완성됩니다.**