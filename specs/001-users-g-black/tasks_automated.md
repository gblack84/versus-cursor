# Tasks (Automated): Auth Feature Sub-Agent Orchestration

**Branch**: `001-users-g-black` | **Date**: 2025-01-20 | **Type**: Sub-Agent Automated Workflow

> 이 문서는 SUBAGENTS_MANUAL.md의 자동화 도구를 활용한 auth 피처 마이그레이션 워크플로우입니다.

## 🤖 Sub-Agent 실행 전략

### 핵심 원칙
- **모든 명령은 레포 루트에서 실행**
- **dry-run → review → apply 사이클 엄수**
- **각 단계별 산출물 확인**: `reports/`, `patches/`, `logs/`
- **`--bridge false` 필수**: Direct Migration v4.0 (Facade 생성 방지)

### 자동화 vs 수동 작업 분류

| 작업 유형 | 자동화 가능 | Sub-Agent | 수동 필요 이유 |
|----------|------------|-----------|--------------|
| 레거시 코드 탐색 | ✅ | Inventory Scout | - |
| 파일 구조 이동 | ✅ | RepoMover | - |
| 대형 파일 분해 | ✅ | StructWeaver | - |
| DI 설정 | ✅ | DIBinder | - |
| Import 수정 | ✅ | ImportGuardian | - |
| 빌드/테스트 검증 | ✅ | BuildSentinel | - |
| Mock 작성 | ❌ | - | 도메인 특화 로직 |
| Unit Test 작성 | ❌ | - | TDD 시나리오 정의 |
| UseCase 구현 | ❌ | - | 비즈니스 로직 |

---

## Phase 0: Discovery & Analysis 🔍

### Command 1: 전체 인벤토리 스캔
```bash
/spawn inventory-scout "--feature auth --depth 5 --scope lib/ --line-threshold 300"
```

**Expected Output**:
- `reports/inventory_auth.json` - auth 관련 파일 전체 맵
- `reports/tree_lib.txt` - 디렉토리 구조
- `reports/candidates_decompose.txt` - 분해 대상 파일 (>300줄)
- `reports/violations.txt` - Clean Architecture 위반 사항
- `reports/00_inventory.yml` - 마이그레이션 베이스라인

**Manual Tasks 대체**: T0.5 (Legacy Code Search)

**검증 체크포인트**:
```bash
cat reports/candidates_decompose.txt | grep auth_util.dart
# Expected: lib/backend/auth/auth_util.dart (1378 lines)
```

---

## Phase 1: Repository Migration 📦

### Command 2: Auth 레포지토리 이동 계획
```bash
/spawn repo-mover "--feature auth --mode dry-run --include repositories,adapters,firebase,api"
```

**Expected Output**:
- `reports/plan_auth.md` - 이동 계획서
- 예상 이동:
  - `lib/backend/auth/` → `lib/features/auth/data/`
  - `lib/backend/firebase/firebase_auth_manager.dart` → `lib/features/auth/data/adapters/`

**Review Point**:
```bash
cat reports/plan_auth.md
# 이동 계획 확인 후 진행 여부 결정
```

### Command 3: Auth 레포지토리 실제 이동
```bash
/spawn repo-mover "--feature auth --mode apply --include repositories,adapters,firebase,api"
```

**Expected Output**:
- `logs/move_auth.log` - 이동 작업 로그
- Git history 보존된 파일 이동 완료

**Manual Tasks 대체**: T004 (DataSource Structure 일부)

**검증 체크포인트**:
```bash
git status | grep "renamed:"
ls -la lib/features/auth/data/
```

---

## Phase 2: Structure Decomposition 🔨

### Command 4: 대형 파일 분해 분석
```bash
/spawn struct-weaver "--task mapper --mode detect --bridge false --source lib/backend/auth/auth_util.dart"
```

**Expected Output**:
- `patches/struct_weaver_auth_util.diff` - 분해 패치
- `reports/struct_weaver_auth_util.yml` - 분해 계획
  - 예상: 25개 UseCase 파일 생성
  - 각 UseCase 30-80줄

**Review Point**:
```bash
cat reports/struct_weaver_auth_util.yml | grep "usecases:"
# 생성될 UseCase 목록 확인
```

### Command 5: 대형 파일 분해 적용
```bash
/spawn struct-weaver "--task mapper --mode apply --bridge false"
```

**Expected Output**:
- `lib/features/auth/domain/usecases/` 디렉토리에 25개 UseCase 파일
- 원본 파일에 @Deprecated 태그 추가

**Manual Tasks 대체**: auth_util.dart 수동 분해 작업

**검증 체크포인트**:
```bash
ls -la lib/features/auth/domain/usecases/*.dart | wc -l
# Expected: 25
```

---

## Phase 3: Dependency Injection Setup 💉

### Command 6: DI 모듈 생성 분석
```bash
/spawn di-binder "--feature auth --pattern voting --mode detect"
```

**Expected Output**:
- `reports/di_auth_analysis.yml` - DI 구조 분석
- voting 피처 패턴과 비교

### Command 7: DI 모듈 생성 적용
```bash
/spawn di-binder "--feature auth --pattern voting --mode apply"
```

**Expected Output**:
- `lib/features/auth/di/auth_di_module.dart` - DI 설정 파일
- `app/di.dart` 업데이트 - registerAuthModule() 추가

**Manual Tasks 대체**: T000 (DI Module Creation)

**검증 체크포인트**:
```bash
grep "registerAuthModule" app/di.dart
# Expected: AuthDIModule.configureDependencies(getIt);
```

---

## Phase 4: Import Cleanup 🧹

### Command 8: Import 위반 감지
```bash
/spawn import-guardian "--scope auth --mode detect"
```

**Expected Output**:
- `reports/import_violations_auth.txt` - 금지된 import 목록
- 예상: 36개 외부 파일이 레거시 auth import 사용

### Command 9: Import 자동 수정 패치 생성
```bash
/spawn import-guardian "--scope auth --mode fix --apply false"
```

**Expected Output**:
- `patches/import_guardian_fix.diff` - import 수정 패치
- 모든 레거시 import를 새 경로로 변경

### Command 10: Import 패치 적용
```bash
git apply patches/import_guardian_fix.diff
```

**Manual Tasks 대체**: T042 (Update External Imports)

**검증 체크포인트**:
```bash
/spawn import-guardian "--scope auth --mode detect"
# Expected: 0 violations
```

---

## Phase 5: Build & Test Validation ✅

### Command 11: 빠른 검증
```bash
/spawn build-sentinel "quick --feature auth"
```

**Expected Output**:
- `reports/build_quick_auth.txt` - 빠른 검증 결과
- flutter analyze 통과
- 기본 테스트 통과

### Command 12: 전체 검증
```bash
/spawn build-sentinel "full --feature auth --isolated"
```

**Expected Output**:
- `reports/build_full_auth.txt` - 전체 검증 결과
- 테스트 커버리지 리포트
- 격리 테스트 결과

**Manual Tasks 대체**: T039-T040 (Testing & Analysis)

**검증 체크포인트**:
```bash
cat reports/build_full_auth.txt | grep "Coverage:"
# Expected: 80%+
```

---

## 수동 작업 영역 (Sub-Agent로 자동화 불가) ✍️

### Phase A: Mock Infrastructure (T005-T012)
```dart
// 도메인 특화 Mock 작성 필요
class MockAuthRepository extends Mock implements IAuthRepository {
  // 비즈니스 로직에 맞는 Mock 동작 정의
}
```

### Phase B: TDD Test Writing (T013-T025)
```dart
// 시나리오 기반 테스트 케이스 작성
test('should return user when credentials are valid', () async {
  // Given-When-Then 패턴으로 테스트 시나리오 정의
});
```

### Phase C: UseCase Implementation (T026-T038)
```dart
// 비즈니스 로직 구현
class SignInWithEmailUseCase {
  // 도메인 규칙과 검증 로직 구현
}
```

---

## 실행 체크리스트 📋

### Pre-flight Checks
- [ ] Git branch 생성: `feature/auth-clean-architecture`
- [ ] 백업 생성: `git stash` 또는 commit
- [ ] SUBAGENTS_MANUAL.md 숙지

### Phase Execution
- [ ] Phase 0: Inventory Scout 실행 및 리포트 검토
- [ ] Phase 1: RepoMover dry-run → review → apply
- [ ] Phase 2: StructWeaver detect → review → apply
- [ ] Phase 3: DIBinder detect → apply
- [ ] Phase 4: ImportGuardian detect → fix → apply
- [ ] Phase 5: BuildSentinel quick → full

### Manual Work
- [ ] Mock 작성 (5-8 파일)
- [ ] Unit Test 작성 (25 파일)
- [ ] UseCase 구현 (25 파일)

### Post-flight Validation
- [ ] 테스트 커버리지 80%+ 달성
- [ ] Import 위반 0건
- [ ] flutter analyze 통과
- [ ] Git commit with atomic strategy

---

## 시간 추정 ⏱️

### 자동화 작업 (Sub-Agents)
- Phase 0-5: **2-3일** (기존 10-12일 작업)

### 수동 작업
- Mock 작성: 1일
- Test 작성: 2-3일
- UseCase 구현: 2-3일

### 총 예상 시간
- **7-10일** (기존 15-20일에서 단축)
- **생산성 향상**: 50-65%

---

## 트러블슈팅 🔧

### Issue 1: StructWeaver가 파일을 제대로 분해하지 못함
```bash
# 수동으로 소스 파일 경로 지정
/spawn struct-weaver "--task mapper --mode detect --bridge false --source lib/features/auth/data/adapters/auth_util.dart"
```

### Issue 2: ImportGuardian 패치 실패
```bash
# 패치 충돌 시 수동 해결
git apply --3way patches/import_guardian_fix.diff
```

### Issue 3: BuildSentinel 테스트 실패
```bash
# 격리 모드로 재시도
/spawn build-sentinel "full --feature auth --isolated --verbose"
```

---

*이 문서는 SUBAGENTS_MANUAL.md 기반으로 작성된 자동화 워크플로우입니다.*