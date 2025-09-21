# 서브에이전트 사용 명세서 v2.0 (Feature-First + Claude-centric Architecture)

> **위치**: `docs/SUBAGENTS_MANUAL.md`
> **실행 원칙**: 모든 명령은 레포 루트에서 실행. 산출물은 `reports/`, `patches/`, `logs/`에 남김.
> **통신 방식**: 모든 에이전트는 Claude-centric JSON으로 응답 (`--output stdout` 지원)

## 📡 Claude-centric JSON 통신 시스템

### 표준 JSON 스키마
모든 에이전트는 다음 구조의 JSON을 반환합니다:

```json
{
  "agent": "agent-name",           // 에이전트 이름
  "version": "1.0.0",              // 버전
  "timestamp": "2025-09-21T12:00:00Z",  // ISO 8601 타임스탬프
  "status": "success|fail|warning|partial",  // 실행 상태
  "data": {                        // 실제 결과 데이터
    // 에이전트별 데이터
  },
  "next_action": {                 // [선택] 다음 추천 액션
    "recommended_agent": "next-agent",
    "params": {},
    "priority": "critical|high|medium|low",
    "reason": "추천 이유"
  },
  "decision_hints": {              // [선택] 의사결정 힌트
    "key": "value"
  }
}
```

### 출력 모드 (`--output` 파라미터)
- **file** (기본값): `reports/` 디렉토리에 JSON 파일 저장
- **stdout**: JSON을 stdout으로 출력 (Claude 직접 소비)
- **both**: 파일 저장과 stdout 출력 동시 수행

### 자동 체이닝 메커니즘
`next_action` 필드를 통해 에이전트가 다음 에이전트를 자동으로 추천:

```python
# Claude의 체이닝 로직
response = run_agent("code-surgeon", {"mode": "detect"})
if response["status"] == "success":
    next_agent = response["next_action"]["recommended_agent"]
    next_params = response["next_action"]["params"]
    # 자동으로 다음 에이전트 실행
    run_agent(next_agent, next_params)
```

### 에러 복구 전략
에러 발생 시 `status`와 `next_action`을 통한 자동 복구:

```json
{
  "status": "partial",
  "data": {
    "error": "Symbol not found",
    "partial_matches": ["_sendVerificationEmail"]
  },
  "next_action": {
    "recommended_agent": "inventory-scout",
    "params": {"search": "email.*verif"},
    "reason": "정확한 심볼 위치 탐색 필요"
  }
}
```

## 0) 공통 원칙

- **작업 단위**: "한 피처(Feature) = 한 루프" → 항상 빌드 가능한 상태 유지
- **모드 규칙**: `detect/dry-run` → 패치 리뷰 → `apply`(선택)
- **예외 규칙**: `app/di.dart`만 `features/*/data` import 허용
- **기본 제외(ignore)**: `test/`, `mocks/`, `*.g.dart`, `*.freezed.dart`, `build/`, `.dart_tool/`, `coverage/`

### 🚨 패치 적용 핵심 원칙
1. **백업 필수**: 패치 적용 전 항상 원본 파일 백업
2. **중간 수정 금지**: 패치 생성과 적용 사이에 파일 수정 절대 금지
3. **원본 기준**: 패치는 원본 파일 기준으로만 작동
4. **실패 시 복원**: 패치 실패 시 백업에서 복원 후 재시도
5. **3-way merge**: `git apply --3way` 옵션으로 충돌 해결 시도

## 1) 에이전트 간 의존 관계 & 호출 순서

### A. 전체 파이프라인 (1회, 베이스라인)
```
Inventory Scout → 인벤토리/위반 베이스라인
Import Guardian (detect) → 현재 위반 리포트만
```

### B. 피처 루프 (반복: auth → profile → posts → … 권장)
```
RepoMover → /backend → /features/<f>/data/... 이동
StructWeaver (mapper) → 전역 어댑터를 피처 매퍼로 분해  
DIBinder → <Port ↔ Impl> DI 등록
Import Guardian (fix) → 금지 임포트 자동 패치 생성(적용은 수동)
BuildSentinel (quick) → analyze/test 확인 (통과 못하면 롤백)
```

### C. 마무리 (전역 1회)
```
RouterSplitter → 라우트를 피처 플러그인화 + app 조립
StructWeaver (state) → 전역 AppState → 피처 Provider 분리
Import Guardian (detect) → 최종 위반 0 확인
BuildSentinel (full) → 최종 게이트
```

## 2) 에이전트별 트리거 · 입력 · 출력 · 성공조건

### 2.1 Inventory Scout
**언제**: 시작 전/중간 상태 점검, 큰 파일/복합 책임/금지 임포트 사전 파악

**입력**:
- `--depth`: 디렉토리 깊이
- `--line-threshold`: 큰 파일 기준선 (레이어별 차별 적용)
  - Domain Layer: 비즈니스 트랜잭션 단위 (UseCase 50-500줄 참고), 150줄 (기타)
  - Data Layer: 300줄
  - Presentation Layer: 800줄
- `--scope`: 스캔 범위
- `--ignore`: 제외 패턴
- `--layer-aware`: true (레이어별 차별 기준 자동 적용)
- `--output`: file|stdout|both (기본: file)

**출력**: 
- `reports/inventory.json`
- `tree_lib.txt`
- `candidates_decompose.txt`
- `violations.txt`
- `00_inventory.yml`

**성공**: 리포트 생성 + 큰 파일/혼합책임/위반 카운트 확인

**호출 예**:
```bash
# 레이어 인식 스캔 (권장)
/spawn inventory-scout "depth 5로 전체 스캔, --layer-aware true로 Domain 비즈니스 트랜잭션 단위, Data 300줄, Presentation 800줄 기준 적용"

# 레거시 방식 (비권장)
# /spawn inventory-scout "depth 5로 전체 스캔, 300줄 이상 큰 파일과 복합 책임 찾아줘"
```

### 2.2 RepoMover
**언제**: `/backend` 레거시 구현을 피처의 `data/`로 이동할 때

**입력**:
- `--feature <name>`: 대상 피처명
- `--mode dry-run|apply`: 실행 모드
- `--include`: repositories,mappers,firebase,api,exceptions
- `--output`: file|stdout|both (기본: file)

**출력**:
- `reports/plan_<feature>.md`
- `logs/move_<feature>.log`

**성공**: 드라이런 계획 검토 후 apply에서 파일 이동 완료(히스토리 유지)

**호출 예**:
```bash
/spawn repo-mover "--feature posts --mode dry-run --include repositories,mappers,firebase,api"
```

### 2.3 StructWeaver
**언제**:
- (A) 전역 매퍼 분해
- (B) 전역 상태 → 피처 Provider로 분리

**⚠️ Direct Migration v4.0 설정**:
- `--bridge false` 필수 (재내보내기/Facade 생성 방지)
- @Deprecated 브릿지 생성하지 않음
- 즉시 완전 전환 지원

**입력**:
- `--task mapper|state`
- `--bridge false` (v4.0 필수)
- mapper: `--source <model_adapter.dart>`
- state: `--map "Sym->lib/features/...;Sym2->..."`
- `--output`: file|stdout|both (기본: file)

**출력**:
- `patches/struct_weaver_*.diff`
- `reports/struct_weaver_*.yml`
- (옵션) 파일 생성

**성공**: 스텁/패치 생성, 리뷰 후 필요 시 apply로 파일 생성

**호출 예**:
```bash
# v4.0 Direct Migration (권장)
/spawn struct-weaver "--task mapper --mode detect --bridge false --source lib/backend/models/migration/model_adapter.dart"

# 상태 분리 (v4.0)
/spawn struct-weaver "--task state --mode detect --bridge false --map 'MediaUploadProvider->lib/features/upload/presentation/providers/media_upload_provider.dart'"

# 레거시 방식 (비권장)
# /spawn struct-weaver "--task mapper --mode detect --bridge true --source ..."
```

### 2.4 DIBinder
**언제**: RepoMover/StructWeaver 이후 DI 결선 작업

**입력**:
- `--feature <name>`: 피처명
- `--port`: 인터페이스 경로
- `--adapter`: 구현체 경로
- `--deps`: firestore,dio 등 의존성
- `--mode`: detect|apply
- `--output`: file|stdout|both (기본: file)

**출력**:
- `patches/di_<feature>.diff`
- `reports/di_binder_<feature>.yml`

**성공**: `app/di`에 `<Port ↔ Impl>` 안전히 추가(마커 블록 사이)

**호출 예**:
```bash
/spawn di-binder "--feature posts --port 'package:.../features/posts/domain/repositories/post_repository.dart' --adapter 'package:.../features/posts/data/repositories/post_repository_impl.dart' --deps firestore,dio --mode detect"
```

### 2.5 Import Guardian
**언제**: 각 루프 끝, 최종 점검. 금지 임포트 탐지/패치 생성

**입력**:
- `--scope`: all|posts,chat
- `--mode`: detect|fix
- `--apply`: false|true
- `--output`: file|stdout|both (기본: file)

**출력**:
- `reports/violations.txt`
- `reports/import_guardian_<scope>.yml`
- `patches/import_guardian_fix.diff`

**성공**: 위반 0 또는 패치로 해결 가능 상태

**호출 예**:
```bash
/spawn import-guardian "--scope posts --mode fix --apply false"
```

### 2.6 RouterSplitter
**언제**: 모든 피처 데이터/DI 안정화 후, 라우트 플러그인화

**입력**:
- `--features`: posts,auth,chat
- `--mode`: detect|apply
- `--output`: file|stdout|both (기본: file)

**출력**:
- `patches/router_split_all.diff`
- `reports/router_splitter_all.yml`

**성공**: `features/<f>/presentation/routes/<f>_routes.dart` 생성 + app/router는 조립만

**호출 예**:
```bash
/spawn router-splitter "--features posts,auth,chat --mode detect"
```

### 2.7 BuildSentinel
**언제**: ImportGuardian 후 즉시, 루프 종료 시, 최종 릴리즈 전

**입력**:
- `quick|full`: 테스트 레벨
- `platform`: none|web|android|ios

**출력**:
- `reports/analyze.txt`
- `reports/test.txt`
- `reports/build_<platform>.txt`
- `build_sentinel.yml`

**성공**: analyze/test/build 결과 green

**호출 예**:
```bash
/spawn build-sentinel "quick"
```

### 2.8 CodeSurgeon
**언제**: 300줄 이상 대규모 파일 분해, 복합 책임 분리

**입력**:
- `--file <path>`: 분해할 파일
- `--map`: 심볼 매핑 (예: "createAccount->lib/features/auth/domain/usecases/create_account.dart")
- `--strategy`: 레이어별 전략
  - `extract-usecases`: Domain Layer (UseCase 추출)
  - `extract-datasources`: Data Layer (DataSource 분리)
  - `extract-components`: Presentation Layer (컴포넌트 추출)
  - `extract-business-logic`: UI에서 비즈니스 로직만 추출
  - `split-by-responsibility`: 책임별 분할 (자동 감지)
- `--max-lines`: 레이어별 최대 라인 수
  - Domain: 비즈니스 트랜잭션 단위 (50-500줄 참고)
  - Data: 300줄
  - Presentation: 800줄
- `--ignore-style-lines`: true (UI 스타일 코드 제외)
- `--layer`: domain|data|presentation (자동 감지 가능)
- `--mode`: detect|apply (기본: detect)
- `--output`: file|stdout|both (기본: file)

**출력**:
- `patches/code_surgeon_*.diff`
- `reports/decomposition_*.yml`
- 새 UseCase/Service 파일들 (패치 적용 시)

**성공**: 단일 파일 → 여러 작은 UseCase/Service로 분해

**🚨 중요: 패치 적용 워크플로우**
```bash
# 1. 백업 생성 (필수!)
cp target_file.dart target_file.dart.backup

# 2. 패치 생성 (dry-run 모드)
/spawn code-surgeon "--file target_file.dart --strategy extract-usecases --mode dry-run"

# 3. 패치 검토
cat patches/code_surgeon_*.diff

# 4. 패치 적용 (파일 수정 없이!)
git apply patches/code_surgeon_*.diff

# 5. 실패 시 복원 후 재시도
cp target_file.dart.backup target_file.dart
git apply --3way patches/code_surgeon_*.diff  # 3-way merge 시도
```

**⚠️ 패치 적용 실패 원인**:
- 패치 생성과 적용 사이에 파일 수정 ❌
- 파일의 줄 번호나 컨텍스트 변경 ❌
- 수동으로 import 추가하거나 코드 편집 ❌

**호출 예**:
```bash
# Presentation Layer (800줄 LoginPageWidget)
/spawn code-surgeon "--file lib/features/auth/presentation/screens/login/login_page/login_page_widget.dart --strategy extract-business-logic --max-lines 800 --ignore-style-lines --mode dry-run"

# Domain Layer (비즈니스 트랜잭션 단위로 분할 필요 시)
/spawn code-surgeon "--file lib/features/auth/domain/usecases/complex_auth_use_case.dart --strategy split-by-responsibility --mode dry-run"

# Data Layer (300줄 초과 Repository)
/spawn code-surgeon "--file lib/features/auth/data/repositories/auth_repository_impl.dart --strategy extract-datasources --max-lines 300 --mode dry-run"

# 패치 적용
git apply patches/code_surgeon_*.diff
```

### 2.9 OrchestratorPipeline
**언제**: 복잡한 파이프라인 실행, 다중 에이전트 오케스트레이션

**입력**:
- `pipeline`: 파이프라인 타입 (c7|quality|feature|safe)
- `--feature`: 피처명 (feature 파이프라인에 필수)
- `--quality`: 품질 체크 활성화
- `--safe`: 안전 모드 (에러 시 중단)
- `--seq`: 순차 실행 + 체크포인트
- `--c7`: 전체 C7 마이그레이션

**파이프라인 타입**:
1. **c7**: 완전한 마이그레이션 파이프라인
   - inventory-scout → struct-weaver → repo-mover → di-binder → import-guardian → router-splitter → build-sentinel
2. **quality**: 품질 검증 파이프라인
   - inventory-scout (layer_aware) → import-guardian (detect) → build-sentinel
3. **feature**: 피처별 마이그레이션
   - inventory-scout → repo-mover → di-binder → import-guardian → build-sentinel
4. **safe**: 안전 모드 파이프라인
   - inventory-scout → build-sentinel (pre) → import-guardian → build-sentinel (post)

**출력**:
- `reports/orchestrator_pipeline.json`
- stdout으로 Claude-centric JSON 출력

**JSON 출력 구조**:
```json
{
  "agent": "orchestrator-pipeline",
  "version": "1.0.0",
  "status": "success|fail",
  "data": {
    "pipeline_type": "c7",
    "steps_total": 7,
    "steps_completed": 7,
    "execution_time_seconds": 45.2,
    "flags": ["quality", "safe"],
    "results": [...]
  },
  "metrics": {
    "success_rate": 1.0,
    "execution_time_ms": 45200
  },
  "next_action": {
    "recommended_agent": "build-sentinel",
    "params": {"mode": "quick"},
    "reason": "Final validation after pipeline"
  }
}
```

**호출 예**:
```bash
# C7 완전 마이그레이션
python3 orchestrator_pipeline.py c7 --feature auth --quality --safe

# 품질 검증만
python3 orchestrator_pipeline.py quality

# 피처 마이그레이션 (순차 + 체크포인트)
python3 orchestrator_pipeline.py feature --feature posts --seq

# 안전 모드
python3 orchestrator_pipeline.py safe --feature auth
```

## 3) 표준 실행 시나리오

### 3.1 시작 전 (베이스라인)
```bash
# 레이어별 차별 기준으로 스캔
/spawn inventory-scout "depth 5로 전체 스캔, --layer-aware true로 Domain 비즈니스 트랜잭션 단위, Data 300줄, Presentation 800줄 기준 적용"
/spawn import-guardian "--scope all --mode detect"
```

### 3.2 피처 루프 (예: auth)
```bash
# 대형 파일 분해 (CodeSurgeon 사용)
# 1. 백업 생성
cp lib/features/auth/presentation/screens/login/login_page/login_page_widget.dart \
   lib/features/auth/presentation/screens/login/login_page/login_page_widget.dart.backup

# 2. 패치 생성 (Presentation Layer - 800줄 기준, 스타일 제외)
/spawn code-surgeon "--file lib/features/auth/presentation/screens/login/login_page/login_page_widget.dart --strategy extract-business-logic --max-lines 800 --ignore-style-lines --mode dry-run"

# 3. 패치 검토
cat patches/code_surgeon_login_page.diff

# 4. 패치 적용 (파일 수정 없이!)
git apply patches/code_surgeon_login_page.diff

# 5. 실패 시 복원 후 재시도
# cp login_page_widget.dart.backup login_page_widget.dart
# git apply --3way patches/code_surgeon_login_page.diff

# Repository 이동
/spawn repo-mover "--feature auth --mode dry-run --include repositories,mappers,firebase,api"
/spawn repo-mover "--feature auth --mode apply --include repositories,mappers"

# 매퍼 분해 (v4.0: bridge false 필수)
/spawn struct-weaver "--task mapper --mode detect --bridge false --source lib/backend/models/migration/model_adapter.dart"

# DI 결선
/spawn di-binder "--feature auth --port 'package:.../auth/domain/repositories/auth_repository.dart' --adapter 'package:.../auth/data/repositories/auth_repository_impl.dart' --deps firestore,firebase_auth --mode detect"
git apply patches/di_auth.diff

# 금지 임포트 패치 생성 → 검토 후 적용
/spawn import-guardian "--scope auth --mode fix --apply false"
git apply patches/import_guardian_fix.diff

# 빠른 품질 게이트
/spawn build-sentinel "quick"
```

### 3.3 라우팅/전역 상태 (모든 피처 완료 후)
```bash
# 라우트 분리
/spawn router-splitter "--features posts,auth,chat,profile,search,notifications --mode detect"
# 리뷰 후 apply

# 상태 분리 (v4.0: bridge false 필수)
/spawn struct-weaver "--task state --mode detect --bridge false --map 'MediaUploadProvider->lib/features/upload/presentation/providers/media_upload_provider.dart;ContentCreationProvider->lib/features/posts/presentation/providers/content_creation_provider.dart'"

# 최종 점검
/spawn import-guardian "--scope all --mode detect"
/spawn build-sentinel "full web"
```

## 4) 게이트(통과 조건) & 롤백

### 피처 루프 게이트 (다음 피처로 넘어가기 전)
- ✅ 해당 피처 관련 `/backend` 참조 0
- ✅ DIBinder 바인딩 등록 확인
- ✅ ImportGuardian 위반 0 (또는 패치로 해결)
- ✅ BuildSentinel green

### 롤백 방법
**적용 전**: 패치 리뷰(필수)

**적용 후 문제**:
```bash
git apply -R <patch>
# 또는
git restore -S .
```

## 5) 의사결정 트리

| 질문 | 사용 에이전트 |
|------|-------------|
| "대상이 /backend에 있다?" | → RepoMover |
| "전역 매퍼/DTO가 섞여있다?" | → StructWeaver(task=mapper) |
| "전역 AppState 비대하다?" | → StructWeaver(task=state) |
| "바인딩이 필요하다?" | → DIBinder |
| "임포트 규칙 위반이 의심된다?" | → ImportGuardian |
| "지금 상태가 빌드 가능한가?" | → BuildSentinel |
| "크고 섞인 파일이 많다?" | → Inventory Scout (+ 옵션 CodeSurgeon) |

## 6) CreateAccountWidget 리팩토링 실제 시나리오

### 시나리오 개요
883줄의 거대한 `CreateAccountWidget`을 Clean Architecture에 맞게 분해하는 실제 작업 시나리오입니다.

### Step-by-Step 실행

#### 1. 코드 분석 (code-surgeon)
```bash
# 심볼 매핑과 함께 분석 모드로 실행
python3 code_surgeon.py \
  --file lib/features/auth/presentation/screens/create_account_widget.dart \
  --map "createAccountWithEmail->lib/features/auth/domain/usecases/create_account_usecase.dart" \
  --mode detect \
  --output stdout
```

**성공 응답**:
```json
{
  "agent": "code-surgeon",
  "status": "success",
  "data": {
    "extracted_symbols": ["createAccountWithEmail"],
    "patch_file": "patches/code_surgeon_create_account.diff"
  },
  "next_action": {
    "recommended_agent": "code-surgeon",
    "params": {"mode": "apply"}
  }
}
```

#### 2. 에러 처리 예시: 심볼 못 찾음
```json
{
  "agent": "code-surgeon",
  "status": "partial",
  "data": {
    "error": "Symbol 'sendEmailVerification' not found",
    "partial_matches": ["_sendVerificationEmail"]
  },
  "next_action": {
    "recommended_agent": "inventory-scout",
    "params": {"search": "email.*verif"}
  }
}
```

**복구 액션**:
```bash
# inventory-scout으로 정확한 심볼 위치 탐색
python3 inventory_scout.py --search "email.*verif" --scope auth --output stdout

# 올바른 심볼명으로 재시도
python3 code_surgeon.py \
  --map "_sendVerificationEmail->lib/features/auth/domain/usecases/email_verification.dart" \
  --mode apply \
  --output stdout
```

#### 3. 아키텍처 검증
```bash
python3 import_guardian.py --scope auth --mode detect --output stdout
```

**위반 발견 시 자동 수정**:
```json
{
  "agent": "import-guardian",
  "status": "warning",
  "data": {
    "violations_found": 3,
    "auto_fix_available": true
  },
  "next_action": {
    "recommended_agent": "import-guardian",
    "params": {"mode": "fix"}
  }
}
```

#### 4. 빌드 검증
```bash
bash build_sentinel.sh quick
```

**빌드 실패 시 복구**:
```json
{
  "agent": "build-sentinel",
  "status": "fail",
  "data": {
    "errors": ["Undefined name 'AuthRepository'"]
  },
  "next_action": {
    "recommended_agent": "di-binder",
    "params": {
      "feature": "auth",
      "port": "lib/features/auth/domain/repositories/auth_repository.dart"
    }
  }
}
```

### 에러별 복구 전략

| 에러 타입 | 자동 추천 에이전트 | 복구 액션 |
|---------|-----------------|---------|
| Symbol not found | inventory-scout | 심볼 검색 → 재매핑 |
| Patch conflict | struct-weaver | 고급 분해 시도 |
| Import violation | import-guardian --fix | 자동 수정 적용 |
| Build error | di-binder | 의존성 등록 |
| Circular dependency | router-splitter | 라우트 분리 |

## 7) 자주 하는 질문(FAQ)

**Q. 에이전트가 자동으로 다음 에이전트를 이어서 호출하나?**
A. 설명에 연쇄 사용을 명시하면 자동 체인도 가능하지만, 재현성/안전성을 위해 단계마다 명시 호출을 권장합니다.

**Q. 스크립트 없이도 되나?**
A. 일부 에이전트는 인라인 Bash로 대체 가능하지만, 유지보수/재현성을 위해 `tools/` 스크립트 사용을 추천합니다.

**Q. RouterSplitter는 언제?**
A. 가장 마지막. 데이터/DI/임포트가 안정화된 뒤에 분리합니다.

**Q. CodeSurgeon 패치가 적용되지 않아요. 왜죠?**
A. 패치 생성과 적용 사이에 파일을 수정했을 가능성이 큽니다. 패치는 원본 파일 기준으로만 작동합니다. 백업에서 복원 후 재시도하세요.

**Q. git apply가 실패하면 어떻게 하나요?**
A. 1) 백업에서 원본 복원 2) `git apply --3way` 옵션 사용 3) `--reject` 옵션으로 부분 적용 후 수동 해결

**Q. 패치 파일을 수동으로 편집해도 되나요?**
A. 권장하지 않습니다. 패치 파일 형식이 깨질 수 있습니다. 대신 적용 후 코드를 수정하세요.

**Q. LoginPageWidget이 800줄인데 분할해야 하나요?**
A. Presentation Layer는 800줄까지 허용됩니다. 비즈니스 로직만 UseCase로 추출하면 됩니다.

**Q. UseCase가 150줄이면 어떻게 하나요?**
A. Domain Layer는 비즈니스 트랜잭션 단위로 판단합니다. 하나의 완전한 비즈니스 트랜잭션이라면 300-500줄도 허용됩니다. 다른 Actor나 다른 시점에 호출되는 로직이 섞여있다면 분할하세요.

**Q. 레이어를 어떻게 자동 감지하나요?**
A. 경로(/domain/, /data/, /presentation/) 또는 파일명 패턴(*_use_case.dart, *_widget.dart)으로 자동 감지합니다.

## 7) 한 줄 매크로 (예: posts 루프 전용)

```bash
# 전체 posts 피처 마이그레이션 체인
/spawn repo-mover "--feature posts --mode dry-run --include repositories,mappers"
/spawn repo-mover "--feature posts --mode apply --include repositories,mappers"
/spawn struct-weaver "--task mapper --mode detect --source lib/backend/models/migration/model_adapter.dart"
/spawn di-binder "--feature posts --port 'package:.../posts/domain/repositories/post_repository.dart' --adapter 'package:.../posts/data/repositories/post_repository_impl.dart' --deps firestore,dio --mode apply"
/spawn import-guardian "--scope posts --mode fix --apply false"
/spawn build-sentinel "quick"
```

## 8) 에이전트별 상세 매트릭스

| 에이전트 | 주요 역할 | 입력 | 출력 | 전/후 에이전트 |
|---------|---------|------|------|--------------|
| **Inventory Scout** | 코드베이스 스캔 | --depth, --scope, --layer-aware | reports/inventory.json | 시작점 → ImportGuardian |
| **RepoMover** | 파일 이동 | --feature, --mode | patches/move_*.diff | InventoryScout → StructWeaver |
| **StructWeaver** | 구조 분해 | --task, --source | patches/struct_*.diff | RepoMover → DIBinder |
| **DIBinder** | DI 등록 | --port, --adapter | patches/di_*.diff | StructWeaver → ImportGuardian |
| **Import Guardian** | 임포트 검증 | --scope, --mode | reports/violations.txt | DIBinder → BuildSentinel |
| **RouterSplitter** | 라우트 분리 | --features | patches/router_*.diff | 모든 피처 후 → BuildSentinel |
| **BuildSentinel** | 품질 검증 | quick\|full | reports/build_*.txt | ImportGuardian → 완료/롤백 |

## 9) 실행 로그 예시

```yaml
# reports/migration_log.yml
session: "2025-01-05T10:00:00Z"
feature: "posts"
steps:
  - agent: "inventory-scout"
    status: "success"
    violations: 45
    large_files: 12
  - agent: "repo-mover"
    status: "success"
    moved_files: 8
  - agent: "struct-weaver"
    status: "success"
    decomposed: 3
  - agent: "di-binder"
    status: "success"
    bindings_added: 5
  - agent: "import-guardian"
    status: "success"
    violations_fixed: 45
  - agent: "build-sentinel"
    status: "success"
    analyze: "passed"
    test: "passed"
```

---

## 변경 이력

### v2.0.0 (2025-09-21)
- **Claude-centric JSON 통신 시스템 추가**: 표준 JSON 스키마 및 자동 체이닝 메커니즘
- **OrchestratorPipeline 에이전트 추가**: 복잡한 파이프라인 오케스트레이션 지원
- **--output 파라미터 추가**: 모든 에이전트에 file|stdout|both 옵션 지원
- **실제 시나리오 추가**: CreateAccountWidget 리팩토링 예제 및 에러 복구 전략
- **에이전트 체이닝 개선**: next_action 기반 자동 에이전트 추천 및 복구

### v1.0.0 (2025-01-05)
- 초기 버전: Feature-First 마이그레이션 에이전트 8개 문서화
- 기본 실행 시나리오 및 FAQ 작성

---

**마지막 업데이트**: 2025-09-21
**버전**: 2.0.0
**관리자**: Feature-First Architecture Migration Team