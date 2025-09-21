# 🔐 Auth Feature - Clean Architecture 마이그레이션 마스터 가이드

> **최종 업데이트**: 2025-01-20 | **버전**: 2.0.0 (Claude-centric JSON 아키텍처)
> **진행 상태**: 🔄 마이그레이션 진행 중
> **Domain**: 70% 🟡 | **Data**: 60% 🟡 | **Presentation**: 40% 🔴 | **Integration**: 0% 🔴
> **Clean Architecture 위반**: 7건 | **대형 파일**: 9개 | **UseCase 필요**: 20+개
> **참조 모델**: Voting Feature (100% 완료) ✅
> **예상 소요시간**: ~~19시간~~ → **6-8시간** (Claude-centric JSON 자동화)

## 📊 현재 상태 분석 보고 (Inventory Scout 결과)

### 🔴 마이그레이션 대시보드

| 레이어 | 파일 수 | 위반 사항 | 긴급도 | 상태 |
|--------|---------|-----------|--------|------|
| **Domain** | 4개 | UseCase 부족 (1개만 존재) | 🔴 Critical | 개선 필요 |
| **Data** | 15개 | 부분 마이그레이션 완료 | 🟡 High | 진행 중 |
| **Presentation** | 12개 | Data 직접 의존 (7건) | 🔴 Critical | 개선 필요 |
| **Integration** | 0개 | DI 미설정 | 🔴 Critical | 미시작 |

### 🎯 주요 문제점 상세 분석

#### 1. Critical 위반: Presentation → Data 직접 임포트 (7건)
```dart
// ❌ 발견된 위반 사항들
login_page_widget.dart:2 → import '/features/auth/data/adapters/auth_util.dart';
create_account_widget.dart:3 → import '/features/auth/data/adapters/auth_util.dart';
phonelogeinpincode_widget.dart:2 → import '/features/auth/data/adapters/auth_util.dart';
start_page_widget.dart:4 → import '/features/auth/data/adapters/auth_util.dart';
phone_creat_account_widget.dart:2 → import '/features/auth/data/adapters/auth_util.dart';
popup_timer_email_widget.dart:3 → import '/features/auth/data/adapters/auth_util.dart';
forgot_password_widget.dart:2 → import '/features/auth/data/adapters/auth_util.dart';
```

#### 2. 대형 파일 분석 (9개)

| 파일명 | 라인 수 | 복합 책임 | 분해 전략 |
|--------|---------|-----------|----------|
| login_page_widget.dart | 1,378 | UI + 인증 + 라우팅 + 애니메이션 | 5개 UseCase + 3개 위젯 |
| create_account_widget.dart | 883 | UI + 회원가입 + 검증 + 프로필 | 4개 UseCase + 2개 위젯 |
| phonelogeinpincode_widget.dart | 701 | UI + SMS + 타이머 + 검증 | 3개 UseCase + 2개 위젯 |
| start_page_widget.dart | 586 | UI + 네비게이션 + 애니메이션 | 2개 UseCase + 2개 위젯 |
| phone_creat_account_widget.dart | 500 | UI + Phone Auth + 프로필 | 3개 UseCase + 2개 위젯 |
| popup_timer_email_widget.dart | 432 | UI + 타이머 + 이메일 | 2개 UseCase + 1개 위젯 |
| firebase_auth_manager.dart | 364 | 다중 인증 관리 | 6개 UseCase |
| forgot_password_widget.dart | 355 | UI + 비밀번호 재설정 | 1개 UseCase + 1개 위젯 |
| auth_util.dart | 77 | 유틸리티 함수들 | 4개 UseCase |

**총 필요 UseCase: 30개 | 총 필요 위젯 분리: 15개**

## 🚀 Claude-centric JSON 기반 자동 마이그레이션 전략

### 🤖 JSON 에이전트 체이닝 아키텍처
모든 에이전트가 JSON으로 소통하며 자동으로 다음 단계를 결정합니다:
- `next_action`: 다음 에이전트 자동 실행
- `decision_hints`: Claude의 지능적 의사결정
- `recovery_strategy`: 에러 시 자동 복구

### 🏗️ 6-Phase 마이그레이션 로드맵

```mermaid
graph LR
    A[Phase 1: 분석] --> B[Phase 2: UseCase]
    B --> C[Phase 3: Repository]
    C --> D[Phase 4: DI]
    D --> E[Phase 5: Import]
    E --> F[Phase 6: 검증]

    style A fill:#4caf50
    style B fill:#ff9800
    style C fill:#ff9800
    style D fill:#ff9800
    style E fill:#ff9800
    style F fill:#ff9800
```

## 📋 Phase 1: 현재 상태 분석 ✅ 완료

### 실행된 서브에이전트
```bash
# Claude-centric JSON 방식
python3 inventory_scout.py --scope auth --depth 5 --output stdout

# JSON 응답으로 자동 체이닝
# {
#   "agent": "inventory-scout",
#   "status": "success",
#   "data": {"large_files": 9, "violations": 7},
#   "next_action": {
#     "recommended_agent": "code-surgeon",
#     "params": {"file": "login_page_widget.dart"},
#     "priority": "high"
#   }
# }
```

### 산출물
- ✅ `reports/inventory_auth.json` - 전체 파일 맵핑
- ✅ `reports/violations_auth.txt` - 7개 Critical 위반
- ✅ `reports/candidates_decompose_auth.txt` - 9개 대형 파일
- ✅ 현재 문서 작성

## 📋 Phase 2: UseCase 레이어 구축 (예상: ~~8시간~~ → 3시간)

### 2.1 대형 파일 분해 (자동 체이닝)
```bash
# LoginPageWidget 분해 (1,378줄 → 5개 UseCase)
python3 code_surgeon.py \
  --file lib/features/auth/presentation/screens/login_page_widget.dart \
  --map "SignInLogic->lib/features/auth/domain/usecases/sign_in_usecase.dart" \
  --mode dry-run \
  --output stdout

# JSON 응답의 next_action에 따라 자동으로 apply 모드 실행
# {
#   "next_action": {
#     "recommended_agent": "code-surgeon",
#     "params": {"mode": "apply"},
#     "priority": "high"
#   }
# }

# CreateAccountWidget 분해 (883줄 → 4개 UseCase)
python3 code_surgeon.py \
  --file lib/features/auth/presentation/screens/create_account_widget.dart \
  --map "CreateAccountLogic->lib/features/auth/domain/usecases/create_account_usecase.dart" \
  --mode dry-run \
  --output stdout

# FirebaseAuthManager 분해 (364줄 → 6개 UseCase)
python3 code_surgeon.py \
  --file lib/features/auth/data/adapters/firebase_auth_manager.dart \
  --map "FirebaseDataSource->lib/features/auth/data/datasources/firebase_auth_datasource.dart" \
  --mode dry-run \
  --output stdout
```

### 2.2 UseCase 생성 목록
```yaml
domain/usecases/:
  # 인증 기본
  - sign_in_with_email_use_case.dart
  - sign_in_with_google_use_case.dart
  - sign_in_with_apple_use_case.dart
  - sign_in_with_github_use_case.dart
  - sign_in_with_phone_use_case.dart
  - sign_in_anonymously_use_case.dart
  - sign_out_use_case.dart

  # 계정 관리
  - create_account_with_email_use_case.dart
  - create_phone_account_use_case.dart
  - verify_email_use_case.dart
  - verify_phone_otp_use_case.dart
  - reset_password_use_case.dart
  - update_password_use_case.dart
  - delete_account_use_case.dart

  # 사용자 정보
  - get_current_user_use_case.dart
  - get_current_user_email_use_case.dart
  - get_current_user_uid_use_case.dart
  - is_authenticated_use_case.dart
  - is_email_verified_use_case.dart
  - update_user_email_use_case.dart

  # 토큰 관리
  - get_jwt_token_use_case.dart
  - refresh_token_use_case.dart

  # Phone Auth
  - send_sms_otp_use_case.dart
  - resend_sms_otp_use_case.dart
  - verify_sms_otp_use_case.dart

  # 세션 관리
  - check_auth_state_use_case.dart
  - stream_auth_state_use_case.dart
  - handle_auth_redirect_use_case.dart
```

### 2.3 Mapper 생성 목록

#### ⚠️ Firebase 1:1 매칭 원칙
```dart
// ✅ CRITICAL: Firebase 필드명과 정확히 1:1 매칭 필수!
// Firestore 필드명은 모두 camelCase 사용 (프로젝트 컨벤션)

// Firestore Document 예시:
{
  "uid": "abc123",
  "email": "user@example.com",
  "displayName": "John Doe",        // camelCase
  "photoUrl": "https://...",        // camelCase
  "isEmailVerified": true,          // camelCase
  "authProvider": "google",         // camelCase
  "createdAt": Timestamp,            // camelCase
  "lastLoginAt": Timestamp           // camelCase
}

// DTO는 Firebase 필드명 그대로 유지
class AuthUserDto {
  final String uid;
  final String? email;
  final String? displayName;      // Firebase 필드명 그대로
  final String? photoUrl;         // Firebase 필드명 그대로
  final bool isEmailVerified;     // Firebase 필드명 그대로
  final String authProvider;      // Firebase 필드명 그대로

  // toJson/fromJson은 Firebase 필드명 그대로 사용
  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,    // 절대 변경 금지
    'photoUrl': photoUrl,          // 절대 변경 금지
    'isEmailVerified': isEmailVerified,
    'authProvider': authProvider,
  };
}
```

```yaml
data/models/:
  # Data Transfer Objects - Firebase 필드명과 1:1 매칭
  - auth_user_dto.dart            # User DTO (Firebase 필드명 유지)
  - auth_token_dto.dart           # Token DTO (Firebase 필드명 유지)
  - auth_session_dto.dart         # Session DTO (Firebase 필드명 유지)
  - auth_provider_dto.dart        # Provider DTO (Firebase 필드명 유지)

data/mappers/:
  # Domain ↔ DTO 변환 (비즈니스 로직 처리)
  - auth_user_mapper.dart         # AuthUser ↔ AuthUserDto
  - auth_token_mapper.dart        # AuthToken ↔ AuthTokenDto
  - auth_session_mapper.dart      # AuthSession ↔ AuthSessionDto

  # Firebase ↔ DTO 변환 (필드명 그대로 매핑)
  - firebase_user_mapper.dart     # Firebase User → AuthUserDto
  - firebase_auth_mapper.dart     # Firebase Auth 상태 매핑
  - firestore_user_mapper.dart   # Firestore Document ↔ AuthUserDto
```

### 2.4 Mapper 생성 명령어
```bash
# StructWeaver로 Mapper 자동 생성
python3 struct_weaver.py \
  --task mapper \
  --mode detect \
  --output stdout

# JSON 응답에 따라 자동으로 apply 모드 진행
# {
#   "decision_hints": {
#     "mappers_needed": 6,
#     "auto_generate": true
#   },
#   "next_action": {
#     "recommended_agent": "struct-weaver",
#     "params": {"mode": "apply"},
#     "priority": "high"
#   }
# }
```

### 2.5 예상 산출물
- 30개 UseCase 파일 (각 30-50줄)
- 7개 DTO 모델 파일
- 6개 Mapper 파일
- `patches/code_surgeon_auth_*.diff` - 분해 패치
- `reports/decomposition_auth.yml` - 분해 결과

## 📋 Phase 3: Repository 패턴 완성 (예상: ~~4시간~~ → 1.5시간)

### 3.1 Repository 이동 (자동 실행)
```bash
# RepoMover로 자동 이동
python3 repo_mover.py \
  --feature auth \
  --mode dry-run \
  --include repositories,adapters,firebase \
  --output stdout

# JSON 응답에 따라 자동 apply
# {
#   "decision_hints": {
#     "files_to_move": 15,
#     "ready_to_apply": true
#   },
#   "next_action": {
#     "recommended_agent": "repo-mover",
#     "params": {"mode": "apply"},
#     "priority": "high"
#   }
# }
```

### 3.2 DataSource 생성
```bash
# DataSource 인터페이스 자동 생성
python3 code_surgeon.py \
  --file lib/features/auth/data/adapters/firebase_auth_manager.dart \
  --map "FirebaseDataSource->lib/features/auth/data/datasources/firebase_auth_datasource.dart" \
  --mode dry-run \
  --output stdout
```

### 3.3 Repository에서 Mapper 활용

#### Firebase 1:1 매핑 구현 예시
```dart
// data/mappers/firestore_user_mapper.dart
class FirestoreUserMapper {
  // Firestore → DTO (필드명 1:1 매칭)
  static AuthUserDto fromFirestore(Map<String, dynamic> data) {
    return AuthUserDto(
      uid: data['uid'] as String,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,    // Firestore 필드명 그대로
      photoUrl: data['photoUrl'] as String?,          // Firestore 필드명 그대로
      isEmailVerified: data['isEmailVerified'] ?? false,
      authProvider: data['authProvider'] ?? 'email',
      createdAt: data['createdAt'],                   // Timestamp 그대로
      lastLoginAt: data['lastLoginAt'],               // Timestamp 그대로
    );
  }

  // DTO → Firestore (필드명 1:1 매칭)
  static Map<String, dynamic> toFirestore(AuthUserDto dto) {
    return {
      'uid': dto.uid,
      'email': dto.email,
      'displayName': dto.displayName,    // 필드명 변경 금지
      'photoUrl': dto.photoUrl,          // 필드명 변경 금지
      'isEmailVerified': dto.isEmailVerified,
      'authProvider': dto.authProvider,
      'createdAt': dto.createdAt ?? FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    };
  }
}

// data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource remoteDataSource;
  final IAuthLocalDataSource localDataSource;

  @override
  Future<AuthUser> getCurrentUser() async {
    try {
      // Firestore에서 사용자 데이터 가져오기
      final firebaseUser = await remoteDataSource.getCurrentFirebaseUser();
      final firestoreData = await remoteDataSource.getUserDocument(firebaseUser.uid);

      // Firestore Document → DTO (1:1 매핑)
      final dto = FirestoreUserMapper.fromFirestore(firestoreData);

      // DTO → Domain Model (비즈니스 로직 변환)
      final domainUser = AuthUserMapper.toDomain(dto);

      // 로컬 캐시 업데이트
      await localDataSource.cacheUser(dto);

      return domainUser;
    } catch (e) {
      // 오프라인 시 로컬에서 가져오기
      final cachedDto = await localDataSource.getCachedUser();
      if (cachedDto != null) {
        return AuthUserMapper.toDomain(cachedDto);
      }
      throw e;
    }
  }

  @override
  Future<AuthUser> signInWithEmail(String email, String password) async {
    // Firebase 인증
    final credential = await remoteDataSource.signInWithEmail(email, password);

    // Firebase User → DTO
    final dto = FirebaseUserMapper.fromFirebaseUser(credential.user!);

    // Firestore에 사용자 정보 저장 (1:1 매핑)
    final firestoreData = FirestoreUserMapper.toFirestore(dto);
    await remoteDataSource.saveUserDocument(credential.user!.uid, firestoreData);

    // DTO → Domain Model
    return AuthUserMapper.toDomain(dto);
  }
}
```

### 3.4 예상 구조
```yaml
data/:
  models/:                        # DTO 모델들
    - auth_user_dto.dart
    - auth_token_dto.dart
    - auth_session_dto.dart

  mappers/:                       # 변환 로직
    - auth_user_mapper.dart
    - firebase_user_mapper.dart
    - firestore_user_mapper.dart

  datasources/:
    remote/:
      firebase/:
        - firebase_auth_datasource.dart
        - firebase_user_datasource.dart
    local/:
      - auth_local_datasource.dart
      - token_cache_datasource.dart

  repositories/:
    - auth_repository_impl.dart  # Mapper 활용하여 구현
```

## 📋 Phase 4: DI 설정 (예상: ~~2시간~~ → 30분)

### 4.1 DI 모듈 생성 (완전 자동화)
```bash
# DIBinder로 DI 모듈 자동 생성
python3 di_binder.py \
  --feature auth \
  --port lib/features/auth/domain/repositories/i_auth_repository.dart \
  --adapter lib/features/auth/data/repositories/auth_repository_impl.dart \
  --mode detect \
  --output stdout

# JSON 응답으로 자동 적용
# {
#   "data": {
#     "usecases_found": 30,
#     "mappers_found": 6,
#     "datasources_found": 2
#   },
#   "next_action": {
#     "recommended_agent": "di-binder",
#     "params": {"mode": "apply"},
#     "priority": "high"
#   }
# }
```

### 4.2 예상 DI 구조
```dart
// lib/features/auth/di/auth_di_module.dart
class AuthDIModule {
  static void configureDependencies(GetIt getIt) {
    // DataSources
    getIt.registerLazySingleton<IAuthRemoteDataSource>(
      () => FirebaseAuthDataSource(),
    );

    // Repositories
    getIt.registerLazySingleton<IAuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: getIt(),
        localDataSource: getIt(),
      ),
    );

    // UseCases (30개)
    getIt.registerFactory(() => SignInWithEmailUseCase(getIt()));
    // ... 29개 더
  }
}
```

## 📋 Phase 5: Import 수정 (예상: ~~2시간~~ → 30분)

### 5.1 위반 탐지 및 자동 수정
```bash
# ImportGuardian으로 위반 감지 및 자동 수정
python3 import_guardian.py \
  --scope auth \
  --mode detect \
  --output stdout

# JSON 응답으로 자동 fix
# {
#   "data": {
#     "violations": 7,
#     "auto_fixable": 7
#   },
#   "decision_hints": {
#     "needs_fix": true,
#     "auto_fixable": true
#   },
#   "next_action": {
#     "recommended_agent": "import-guardian",
#     "params": {"mode": "fix"},
#     "priority": "high"
#   }
# }
```

### 5.3 예상 수정 사항
```dart
// ❌ Before
import '/features/auth/data/adapters/auth_util.dart';

// ✅ After
import '/features/auth/domain/usecases/get_current_user_use_case.dart';
import '/features/auth/domain/usecases/sign_in_with_email_use_case.dart';
```

## 📋 Phase 6: 최종 검증 (예상: ~~1시간~~ → 30분)

### 6.1 품질 게이트 (자동 검증)
```bash
# BuildSentinel로 최종 검증
bash build_sentinel.sh quick

# JSON 기반 자동 평가
python3 build_sentinel_json.py \
  --status "success" \
  --errors 0 \
  --warnings 0 \
  --failures 0 \
  --mode "quick"

# 실패 시 자동 복구 제안
# {
#   "status": "fail",
#   "data": {
#     "errors": 2,
#     "error_details": ["Import violation", "Compile error"]
#   },
#   "next_action": {
#     "recommended_agent": "import-guardian",
#     "params": {"mode": "fix", "scope": "auth"},
#     "priority": "high"
#   }
# }
```

### 6.2 성공 기준
- ✅ 0 Architecture 위반
- ✅ 0 대형 파일 (>300줄)
- ✅ 30개 UseCase 구현
- ✅ 100% DI 통합
- ✅ 80%+ 테스트 커버리지

## 📊 예상 타임라인 (Claude-centric JSON 자동화)

| Phase | 기존 시간 | **자동화 시간** | 서브에이전트 | JSON 자동화 효과 |
|-------|----------|----------------|-------------|-----------------|
| Phase 1 | ✅ 완료 | ✅ 완료 | inventory-scout | 분석 완료 |
| Phase 2 | ~~10시간~~ | **3시간** | code-surgeon, struct-weaver | 70% 단축 |
| Phase 3 | ~~4시간~~ | **1.5시간** | repo-mover, code-surgeon | 63% 단축 |
| Phase 4 | ~~2시간~~ | **30분** | di-binder | 75% 단축 |
| Phase 5 | ~~2시간~~ | **30분** | import-guardian | 75% 단축 |
| Phase 6 | ~~1시간~~ | **30분** | build-sentinel | 50% 단축 |
| **총계** | **~~19시간~~** | **6시간** | **7개 에이전트** | **68% 시간 절감** |

### 🚀 OrchestratorPipeline으로 한 번에 실행
```bash
# 전체 마이그레이션을 한 번에 실행
python3 orchestrator_pipeline.py \
  --feature auth \
  --pipeline c7 \
  --output stdout

# 6시간 내 자동 완료!
```

## 🎯 Risk Management

### 주요 리스크
1. **대형 파일 분해 복잡도** - CodeSurgeon 반복 실행 필요
2. **기존 코드 호환성** - 점진적 마이그레이션 전략
3. **테스트 깨짐** - 각 Phase 후 BuildSentinel 실행

### 완화 전략
- 각 Phase 후 git commit (롤백 가능)
- Dry-run 모드 활용
- 단위 테스트 우선 작성

## ✅ 체크리스트

### Phase별 완료 조건
- [ ] Phase 1: Inventory 분석 완료 ✅
- [ ] Phase 2: 30개 UseCase 생성
- [ ] Phase 3: Repository 패턴 완성
- [ ] Phase 4: DI 모듈 통합
- [ ] Phase 5: 0 Import 위반
- [ ] Phase 6: 모든 테스트 통과

## 📚 참고 자료

- [Voting Feature 마이그레이션 성공 사례](../voting/MASTER_MIGRATION_GUIDE.md)
- [Architecture Rules v4.0](/lib/ARCHITECTURE_RULES.md)
- [서브에이전트 사용 명세서](/docs/SUBAGENTS_MANUAL.md)

## 🤖 JSON 기반 에러 복구 전략

### 자동 복구 시나리오
```json
{
  "error_scenarios": [
    {
      "type": "patch_conflict",
      "recovery": ["restore_backup", "3-way_merge", "manual_fix"],
      "next_agent": "code-surgeon"
    },
    {
      "type": "import_violation",
      "recovery": ["auto_fix"],
      "next_agent": "import-guardian"
    },
    {
      "type": "compile_error",
      "recovery": ["analyze", "fix_imports", "rebuild"],
      "next_agent": "build-sentinel"
    }
  ]
}
```

---

**이 문서는 Auth Feature의 완전한 Clean Architecture 마이그레이션을 위한 마스터 가이드입니다.**
**Claude-centric JSON 자동화로 ~~19시간~~ → **6시간** 내 완료 예정입니다.**
**모든 에이전트가 JSON으로 소통하며 자동으로 다음 단계를 결정합니다.**