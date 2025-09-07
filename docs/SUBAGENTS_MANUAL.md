# 서브에이전트 사용 명세서 (Feature-First 마이그레이션 전용)

> **위치**: `docs/SUBAGENTS_MANUAL.md`  
> **실행 원칙**: 모든 명령은 레포 루트에서 실행. 산출물은 `reports/`, `patches/`, `logs/`에 남김.

## 0) 공통 원칙

- **작업 단위**: "한 피처(Feature) = 한 루프" → 항상 빌드 가능한 상태 유지
- **모드 규칙**: `detect/dry-run` → 패치 리뷰 → `apply`(선택)
- **예외 규칙**: `app/di.dart`만 `features/*/data` import 허용
- **기본 제외(ignore)**: `test/`, `mocks/`, `*.g.dart`, `*.freezed.dart`, `build/`, `.dart_tool/`, `coverage/`

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
- `--line-threshold`: 큰 파일 기준선
- `--scope`: 스캔 범위
- `--ignore`: 제외 패턴

**출력**: 
- `reports/inventory.json`
- `tree_lib.txt`
- `candidates_decompose.txt`
- `violations.txt`
- `00_inventory.yml`

**성공**: 리포트 생성 + 큰 파일/혼합책임/위반 카운트 확인

**호출 예**:
```bash
/spawn inventory-scout "depth 5로 전체 스캔, 300줄 이상 큰 파일과 복합 책임 찾아줘"
```

### 2.2 RepoMover
**언제**: `/backend` 레거시 구현을 피처의 `data/`로 이동할 때

**입력**:
- `--feature <name>`: 대상 피처명
- `--mode dry-run|apply`: 실행 모드
- `--include`: repositories,mappers,firebase,api,exceptions

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

**입력**:
- `--task mapper|state`
- mapper: `--source <model_adapter.dart>`
- state: `--map "Sym->lib/features/...;Sym2->..."`

**출력**:
- `patches/struct_weaver_*.diff`
- `reports/struct_weaver_*.yml`
- (옵션) 파일 생성

**성공**: 스텁/패치 생성, 리뷰 후 필요 시 apply로 파일 생성

**호출 예**:
```bash
# 매퍼 분해
/spawn struct-weaver "--task mapper --mode detect --source lib/backend/models/migration/model_adapter.dart"

# 상태 분리
/spawn struct-weaver "--task state --mode detect --map 'MediaUploadProvider->lib/features/upload/presentation/providers/media_upload_provider.dart'"
```

### 2.4 DIBinder
**언제**: RepoMover/StructWeaver 이후 DI 결선 작업

**입력**:
- `--feature <name>`: 피처명
- `--port`: 인터페이스 경로
- `--adapter`: 구현체 경로
- `--deps`: firestore,dio 등 의존성
- `--mode`: detect|apply

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

## 3) 표준 실행 시나리오

### 3.1 시작 전 (베이스라인)
```bash
/spawn inventory-scout "depth 5로 전체 스캔, 300줄 이상 큰 파일과 복합 책임 찾아줘"
/spawn import-guardian "--scope all --mode detect"
```

### 3.2 피처 루프 (예: posts)
```bash
# Repository 이동
/spawn repo-mover "--feature posts --mode dry-run --include repositories,mappers,firebase,api"
/spawn repo-mover "--feature posts --mode apply --include repositories,mappers"

# 매퍼 분해
/spawn struct-weaver "--task mapper --mode detect --source lib/backend/models/migration/model_adapter.dart"

# DI 결선
/spawn di-binder "--feature posts --port 'package:.../posts/domain/repositories/post_repository.dart' --adapter 'package:.../posts/data/repositories/post_repository_impl.dart' --deps firestore,dio --mode detect"
/spawn di-binder "--feature posts --port '...' --adapter '...' --deps firestore,dio --mode apply"

# 금지 임포트 패치 생성 → 검토 후 적용
/spawn import-guardian "--scope posts --mode fix --apply false"
git apply patches/import_guardian_fix.diff

# 빠른 품질 게이트
/spawn build-sentinel "quick"
```

### 3.3 라우팅/전역 상태 (모든 피처 완료 후)
```bash
# 라우트 분리
/spawn router-splitter "--features posts,auth,chat,profile,search,notifications --mode detect"
# 리뷰 후 apply

# 상태 분리
/spawn struct-weaver "--task state --mode detect --map 'MediaUploadProvider->lib/features/upload/presentation/providers/media_upload_provider.dart;ContentCreationProvider->lib/features/posts/presentation/providers/content_creation_provider.dart'"

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

## 6) 자주 하는 질문(FAQ)

**Q. 에이전트가 자동으로 다음 에이전트를 이어서 호출하나?**  
A. 설명에 연쇄 사용을 명시하면 자동 체인도 가능하지만, 재현성/안전성을 위해 단계마다 명시 호출을 권장합니다.

**Q. 스크립트 없이도 되나?**  
A. 일부 에이전트는 인라인 Bash로 대체 가능하지만, 유지보수/재현성을 위해 `tools/` 스크립트 사용을 추천합니다.

**Q. RouterSplitter는 언제?**  
A. 가장 마지막. 데이터/DI/임포트가 안정화된 뒤에 분리합니다.

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
| **Inventory Scout** | 코드베이스 스캔 | --depth, --scope | reports/inventory.json | 시작점 → ImportGuardian |
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

**마지막 업데이트**: 2025-01-05  
**버전**: 1.0.0  
**관리자**: Feature-First Architecture Migration Team