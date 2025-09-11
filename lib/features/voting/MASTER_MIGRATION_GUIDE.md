# 🗳️ Voting Feature - Clean Architecture 마이그레이션 마스터 가이드

> **최종 업데이트**: 2025-01-11 | **버전**: 2.0.0  
> **진행 상태**: 🔄 **마이그레이션 시작 전** (서브에이전트 분석 완료)  
> **Domain**: 0% | **Data**: 0% | **Presentation**: 0% | **Integration**: 0%  
> **Clean Architecture 위반**: 13건 🔴 | **Feature 간 의존**: 8건 🔴 | **Services 의존**: 5건 🟡  
> **대형 파일**: 6개 (300줄+) | **빈 디렉토리**: 4개

## 📊 현재 상태 분석 보고

### 🔴 마이그레이션 대시보드

| 레이어 | 파일 수 | 위반 사항 | 긴급도 | 예상 시간 |
|--------|---------|-----------|--------|-----------|
| **Domain** | 13개 | Critical 4건 | 🔴 최우선 | 16시간 |
| **Data** | 4개 | 파일 이동 필요 | 🟡 중요 | 8시간 |
| **Presentation** | 15개 | Services 의존 | 🟡 중요 | 12시간 |
| **Integration** | - | DI 패턴 개선 | 🟢 보통 | 4시간 |

### 아키텍처 준수율

```
Domain:        0% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 🔴 시작 전
Data:          0% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 🔴 시작 전
Presentation:  0% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 🔴 시작 전
Integration:   0% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 🔴 시작 전
전체:          0% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 🔴 시작 전
```

### 주요 문제점 요약

| 문제 유형 | 건수 | 예시 | 심각도 |
|-----------|-----|------|--------|
| Domain → Data 의존 | 4 | `vote_state_coordinator.dart:4,6` → `posts/data/`, `auth/data/` | 🔴 Critical |
| Feature 간 의존 | 5 | `vote_data_extractor.dart:4-6` → `notifications/` | 🔴 Critical |
| Firebase 직접 의존 | 4 | `i_voting_repository.dart:1` → Firebase | 🟡 High |
| Services 의존 | 5 | `voting_box.dart:6-7` → `services/ui/` | 🟡 High |
| GetIt 직접 사용 | 2 | `vote_ui_manager.dart:3`, `vote_data_extractor.dart:2` | 🟡 High |
| 대형 파일 (>300줄) | 6 | `voting_image_viewer.dart` (964줄), `voting_box.dart` (962줄) | 🟢 Medium |
| 빈 디렉토리 | 4 | `domain/usecases/`, `data/datasources/`, `presentation/screens,providers/` | 🟢 Medium |

## 🔬 서브에이전트 분석 결과 (2025-01-11)

### Inventory Scout 분석

#### 대형 파일 발견 (300줄 이상)
| 파일 | 줄 수 | 복합 책임 | 분해 계획 |
|------|-------|-----------|----------|
| `voting_image_viewer.dart` | 964 | UI + 로직 + 상태관리 | 4개 파일로 분할 |
| `voting_box.dart` | 962 | UI + 비즈니스 로직 | 4개 파일로 분할 |
| `voting_dialog.dart` | 738 | UI + 상태관리 | Screen으로 이동 + 3개 분할 |
| `vote_card_widget.dart` | 435 | UI + 투표 로직 | 2개 파일로 분할 |
| `voting_repository_impl.dart` | 410 | 다중 도메인 처리 | UseCase + DataSource로 분해 |
| `adaptive_text_size.dart` | 390 | UI 유틸 + 복잡 로직 | 2개 파일로 분할 |

#### 빈 디렉토리 현황
| 디렉토리 | 용도 | 생성 필요 파일 수 | Phase |
|----------|------|------------------|-------|
| `domain/usecases/` | 비즈니스 로직 | 11개 UseCase | Phase 2 |
| `data/datasources/` | 데이터 소스 | 2개 DataSource | Phase 3 |
| `presentation/screens/` | 화면 위젯 | 3개 Screen | Phase 4 |
| `presentation/providers/` | 상태 관리 | 3개 Provider | Phase 5 |

### Import Guardian 분석

#### 🔴 Critical 위반 (4건)
```dart
// Domain → Data 의존성 (절대 금지!)
vote_state_coordinator.dart:4 → /features/posts/data/adapters/vote/vote_timer_service.dart
vote_state_coordinator.dart:6 → /features/auth/data/adapters/auth_util.dart
vote_data_extractor.dart:2 → GetIt.instance (직접 사용)
vote_service_impl.dart:2 → /features/posts/data/adapters/
```

#### 🟡 High 위반 (5건)
```dart
// Feature 간 직접 의존
vote_data_extractor.dart:4-6 → /features/notifications/
vote_ui_manager.dart:3 → GetIt.instance
voting_box.dart:6-7 → /services/ui/
voting_dialog.dart:6 → /services/ui/
voting_dialog.dart:9 → /features/posts/domain/
```

#### 🟠 Medium 위반 (4건)
```dart
// Firebase 직접 의존
vote_handler_impl.dart:2-4 → /features/notifications/
i_voting_repository.dart:1 → cloud_firestore/cloud_firestore.dart
vote_state_coordinator.dart:3 → firebase_auth/firebase_auth.dart
voting_repository_impl.dart:2 → /core/backend/firebase/
```

## 📐 표준 규칙 및 템플릿

### 표준 서브에이전트 명령어

```bash
# Phase별 서브에이전트 명령어 (SUBAGENTS_MANUAL.md 기반)

# 초기 분석
INVENTORY: /spawn inventory-scout "--depth 5 --scope lib/features/voting --line-threshold 300"
GUARDIAN:  /spawn import-guardian "--scope voting --mode detect --verbose true --show-line-numbers true"

# Phase 1: Critical 수정
INTERFACE: /spawn struct-weaver "--task interface --source vote_state_coordinator.dart --mode detect"
FIX:       /spawn import-guardian "--scope voting --mode fix --apply false"

# Phase 2: UseCase 생성
USECASE:   /spawn struct-weaver "--task usecase --source voting_repository_impl.dart --mode detect"

# Phase 3: DataSource 분리
DATASOURCE: /spawn struct-weaver "--task datasource --source voting_repository_impl.dart --mode apply"

# Phase 4: 대형 파일 분해
SURGEON1:  /spawn code-surgeon "--file voting_box.dart --max-lines 200 --mode detect"
SURGEON2:  /spawn code-surgeon "--file voting_image_viewer.dart --max-lines 200 --mode detect"
SURGEON3:  /spawn code-surgeon "--file voting_dialog.dart --max-lines 200 --mode detect"

# Phase 5: DI 통합
DI:        /spawn di-binder "--feature voting --auto-detect --mode detect"

# Phase 6: 최종 검증
VALIDATE:  /spawn import-guardian "--scope voting --mode detect"
BUILD:     /spawn build-sentinel "full"
```

### 표준 네이밍 컨벤션

```yaml
file_naming: snake_case (vote_timer_service.dart)
class_naming: PascalCase (VoteTimerService)
interface: I로 시작 (IVoteRepository, IVoteService)
directory: 복수형 (services/, models/, usecases/)
import_style: 
  - Feature 내부: 상대경로 (../domain/models/vote.dart)
  - Feature 간: 절대경로 (/core/domain/models/notification_base.dart)
  - Core: 절대경로 (/core/utils/logger.dart)
```

### 표준 의존성 순서

```
Domain Models → Domain Ports → UseCase → Repository Interface 
→ DTO/Mapper → Repository Implementation → DataSource 
→ Service/Adapter → Provider → Widget → DI Module
```

## 🗺️ 마이그레이션 로드맵

### Phase 구조 다이어그램

```mermaid
gantt
    title Voting Feature 마이그레이션 계획 (5-7일)
    dateFormat  YYYY-MM-DD
    
    section Phase 1 (Domain) 🔴
    Domain 의존성 제거        :p1a, 2025-01-11, 1d
    인터페이스 생성           :p1b, after p1a, 0.5d
    UseCase 정리             :p1c, after p1b, 0.5d
    
    section Phase 2 (Services) 🟡
    Posts 서비스 이동         :p2a, after p1c, 1d
    Services 디렉토리 정리    :p2b, after p2a, 0.5d
    
    section Phase 3 (Data) 🟡
    Repository 리팩토링       :p3a, after p2b, 1d
    DataSource 격리          :p3b, after p3a, 0.5d
    
    section Phase 4 (Presentation) 🟢
    대형 파일 분할           :p4a, after p3b, 1d
    Widget 정리             :p4b, after p4a, 0.5d
    
    section Phase 5 (Integration) 🟢
    DI 통합                 :p5a, after p4b, 0.5d
    최종 검증               :p5b, after p5a, 0.5d
```

## 📋 Phase 1: Domain Layer 정리 (Critical 🔴)

### 목표
- Domain → Data 의존성 완전 제거
- Feature 간 직접 의존 제거
- 순수 도메인 모델 확립

### 작업 내역

#### 1.1 Critical 의존성 제거 (4건)

```bash
# Step 1: 현재 위반 사항 정밀 분석
/spawn import-guardian "--scope voting --mode detect --verbose true --show-line-numbers true"

# Step 2: 인터페이스 생성 계획
/spawn struct-weaver "--task interface --source vote_state_coordinator.dart --mode detect"
```

**수정 대상 파일 (줄 번호 포함):**
- `domain/coordinators/vote_state_coordinator.dart`
  - Line 4: ❌ 제거: `import '/features/posts/data/adapters/vote/vote_timer_service.dart';`
  - Line 6: ❌ 제거: `import '/features/auth/data/adapters/auth_util.dart';`
  - ✅ 추가: `import '../ports/i_vote_timer_service.dart';`
  - ✅ 추가: `import '/core/domain/ports/i_auth_service.dart';`

- `domain/services/vote_data_extractor.dart`
  - Line 2: ❌ 제거: `import 'package:get_it/get_it.dart';`
  - Line 4-6: ❌ 제거: notifications feature imports
  - ✅ 추가: Constructor injection 패턴 적용

#### 1.2 인터페이스 생성

```dart
// voting/domain/ports/i_vote_timer_service.dart (새 파일)
abstract class IVoteTimerService {
  Stream<int> getRemainingTime(String postId);
  void startTimer(String postId, DateTime endTime);
  void stopTimer(String postId);
  void dispose();
}

// voting/domain/ports/i_vote_status_service.dart (새 파일)
abstract class IVoteStatusService {
  Future<void> submitVote(String postId, String userId, String option);
  Stream<VoteStatus> getVoteStatus(String postId);
  Future<bool> hasUserVoted(String postId, String userId);
}
```

#### 1.3 자동 패치 생성 및 검증

```bash
# Import Guardian으로 자동 패치 생성
/spawn import-guardian "--scope voting --mode fix --apply false"
# 패치 파일 리뷰: patches/import_guardian_fix.diff

# 패치 적용 후 검증
/spawn import-guardian "--scope voting --mode detect"
# 빌드 테스트
/spawn build-sentinel "quick"
```

### Phase 1 체크리스트

- [ ] Critical 위반 4건 수정
  - [ ] `vote_state_coordinator.dart:4,6` Domain→Data 제거
  - [ ] `vote_data_extractor.dart:2` GetIt 직접 사용 제거
  - [ ] `vote_service_impl.dart:2` Posts Data 의존 제거
- [ ] 인터페이스 생성
  - [ ] `i_vote_timer_service.dart` 생성
  - [ ] `i_vote_status_service.dart` 생성
- [ ] Import Guardian 패치 적용
- [ ] 빌드 검증 (0 violations)

## 📋 Phase 2: Services 이동 및 통합 (High 🟡)

### 목표
- Posts feature에서 voting 서비스 이동
- Services 디렉토리 의존성 제거
- 적절한 위치로 서비스 재배치

### 작업 내역

#### 2.1 UseCase 추출 및 생성

```bash
# Step 1: Repository에서 UseCase 추출 계획
/spawn struct-weaver "--task usecase --source lib/features/voting/data/repositories/voting_repository_impl.dart --mode detect"

# Step 2: UseCase 파일 생성
/spawn struct-weaver "--task usecase --source voting_repository_impl.dart --mode apply"
```

**생성할 UseCase (11개):**
```
domain/usecases/
├── submit_vote_usecase.dart
├── get_vote_status_usecase.dart
├── get_vote_results_usecase.dart
├── check_user_voted_usecase.dart
├── get_vote_timer_usecase.dart
├── start_voting_session_usecase.dart
├── end_voting_session_usecase.dart
├── get_vote_statistics_usecase.dart
├── validate_vote_eligibility_usecase.dart
├── process_vote_completion_usecase.dart
└── get_voting_history_usecase.dart
```

**이동 대상:**
```yaml
from: features/posts/data/adapters/vote/
  - vote_timer_service.dart → features/voting/data/services/
  - vote_status_service.dart → features/voting/data/services/
  - vote_state_coordinator.dart → (이미 voting에 있음, 확인 필요)

to: features/voting/data/services/
  - vote_timer_service_impl.dart (IVoteTimerService 구현)
  - vote_status_service_impl.dart (IVoteStatusService 구현)
```

#### 2.2 Services 디렉토리 정리

```bash
# UI 계산 서비스를 core로 이동
mv lib/services/ui/unified_box_calculator.dart lib/core/infrastructure/ui/
mv lib/services/ui/models/box_sizes.dart lib/core/domain/models/

# 이미지 캐시 서비스를 core로 이동  
mv lib/services/image/unified_image_cache_service.dart lib/core/infrastructure/cache/
```

#### 2.3 Import 경로 업데이트

```bash
# 모든 import 경로 자동 수정
/spawn import-guardian "--scope voting --mode fix --apply false"
# 패치 검토 후 적용
git apply patches/import_guardian_fix.diff
```

### Phase 2 체크리스트

- [ ] UseCase 11개 생성 완료
  - [ ] 투표 관련 UseCase 6개
  - [ ] 세션 관리 UseCase 2개
  - [ ] 통계/검증 UseCase 3개
- [ ] Repository 인터페이스와 연결
- [ ] 비즈니스 로직 분리 확인
- [ ] Import Guardian 검증

## 📋 Phase 3: Data Layer 구현 (Medium 🟡)

### 목표
- Repository 패턴 완전 구현
- DataSource 격리
- DTO/Mapper 패턴 적용

### 작업 내역

#### 3.1 Repository 리팩토링

```dart
// data/repositories/voting_repository_impl.dart (410줄 → 분할)
class VotingRepositoryImpl implements IVotingRepository {
  final VotingRemoteDataSource remoteDataSource;
  final VotingLocalDataSource localDataSource;
  final IVoteTimerService voteTimerService;
  final IVoteStatusService voteStatusService;
  
  VotingRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.voteTimerService,
    required this.voteStatusService,
  });
  
  // UseCase별로 메서드 분리
}
```

#### 3.2 DataSource 생성

```bash
# StructWeaver로 DataSource 분리
/spawn struct-weaver "--task datasource --source voting_repository_impl.dart --mode detect"
```

**생성할 DataSource:**
- `data/datasources/remote/voting_remote_datasource.dart`
- `data/datasources/local/voting_local_datasource.dart`

### Phase 3 체크리스트

- [ ] Repository 인터페이스 정의 완료
- [ ] Repository 구현체 리팩토링 (410줄 → <200줄)
- [ ] RemoteDataSource 생성
- [ ] LocalDataSource 생성
- [ ] DTO/Mapper 구현
- [ ] 캐싱 전략 구현

## 📋 Phase 4: Presentation Layer 정리 (Low 🟢)

### 목표
- 대형 파일 분할 (>400줄)
- GetIt 직접 사용 제거
- Widget 구조 최적화

### 작업 내역

#### 4.1 대형 파일 분할

```bash
# Code Surgeon으로 대형 파일 분해
/spawn code-surgeon "--file voting_image_viewer.dart --max-lines 200 --mode detect"
/spawn code-surgeon "--file voting_box.dart --max-lines 200 --mode detect"
/spawn code-surgeon "--file voting_dialog.dart --max-lines 200 --mode detect"
```

**분할 대상 (>400줄):**
1. `voting_image_viewer.dart` (964줄) → 3-4개 파일로 분할
2. `voting_box.dart` (962줄) → 3-4개 파일로 분할
3. `voting_dialog.dart` (738줄) → 3개 파일로 분할
4. `vote_card_widget.dart` (435줄) → 2개 파일로 분할

#### 4.2 DI 패턴 개선

```dart
// Before: GetIt 직접 사용
class VoteUIManager {
  final userService = GetIt.instance<IUserService>();  // ❌
}

// After: Constructor Injection
class VoteUIManager {
  final IUserService userService;
  
  VoteUIManager({required this.userService});  // ✅
}
```

### Phase 4 체크리스트

- [ ] 대형 파일 5개 분할 완료
- [ ] GetIt 직접 사용 2개 제거
- [ ] Constructor Injection 적용
- [ ] Widget 테스트 작성
- [ ] UI 동작 검증

## 📋 Phase 5: DI 통합 및 최종 검증 (Low 🟢)

### 목표
- App Layer DI 모듈 생성
- 전체 아키텍처 검증
- 문서화 및 테스트

### 작업 내역

#### 5.1 DI Module 생성

```bash
# DI Binder로 자동 생성
/spawn di-binder "--feature voting --auto-detect --mode detect"
/spawn di-binder "--feature voting --auto-detect --mode apply"
```

**app/di/voting_module.dart:**
```dart
class VotingModule {
  static void register(GetIt sl) {
    // Services
    sl.registerLazySingleton<IVoteTimerService>(
      () => VoteTimerServiceImpl(),
    );
    sl.registerLazySingleton<IVoteStatusService>(
      () => VoteStatusServiceImpl(),
    );
    
    // Repository
    sl.registerLazySingleton<IVotingRepository>(
      () => VotingRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        voteTimerService: sl(),
        voteStatusService: sl(),
      ),
    );
    
    // UseCases (11개)
    sl.registerFactory(() => SubmitVoteUseCase(sl()));
    sl.registerFactory(() => GetVoteStatusUseCase(sl()));
    // ... 나머지 UseCase들
  }
}
```

#### 5.2 최종 검증

```bash
# 전체 아키텍처 검증
/spawn import-guardian "--scope voting --mode detect"

# 빌드 검증
/spawn build-sentinel "full"

# 테스트 실행
flutter test lib/features/voting/test/
```

### Phase 5 체크리스트

- [ ] DI Module 생성 완료
- [ ] 모든 서비스 바인딩 확인
- [ ] Import Guardian 최종 검증 (0 violations)
- [ ] 전체 빌드 성공
- [ ] 단위 테스트 통과
- [ ] 통합 테스트 통과

## 📊 예상 결과

### Before → After 비교

| 지표 | Before | After | 개선율 |
|------|--------|-------|--------|
| Architecture 위반 | 11개 | 0개 | 100% ✅ |
| Feature 간 의존 | 8개 | 0개 | 100% ✅ |
| Services 의존 | 5개 | 0개 | 100% ✅ |
| GetIt 직접 사용 | 2개 | 0개 | 100% ✅ |
| 평균 파일 크기 | 387줄 | <200줄 | 48% ↓ |
| 테스트 가능성 | 30% | 95% | 217% ↑ |
| Architecture Score | D+ | A | 최고 등급 |

## ⚠️ 리스크 관리

### 높은 리스크 항목

1. **vote_state_coordinator.dart**
   - 핵심 투표 로직 포함
   - 백업 필수: `git tag backup/vote-coordinator-$(date +%Y%m%d)`
   - 단계별 테스트 필수

2. **voting_repository_impl.dart**
   - 410줄의 대형 파일
   - 점진적 분할 필요
   - 기능별 테스트 작성

### 리스크 완화 전략

```bash
# 각 Phase 시작 전 백업
git checkout -b migration/voting-phase-N
git tag -a backup/voting-phase-N-start -m "Before Phase N"

# 각 Phase 완료 후 체크포인트
git tag -a checkpoint/voting-phase-N-done -m "Phase N completed"

# 롤백 절차
git checkout backup/voting-phase-N-start  # 문제 발생 시
```

## 📝 진행 상황 추적

### Phase별 시간 추정

| Phase | 예상 시간 | 실제 시간 | 완료율 | 담당자 |
|-------|----------|----------|--------|--------|
| Phase 1 | 16시간 | - | 0% | - |
| Phase 2 | 8시간 | - | 0% | - |
| Phase 3 | 8시간 | - | 0% | - |
| Phase 4 | 6시간 | - | 0% | - |
| Phase 5 | 2시간 | - | 0% | - |
| **Total** | **40시간** | - | **0%** | - |

### 일일 진행 로그

```yaml
Day 1 (2025-01-11):
  - [ ] Phase 1 시작
  - [ ] Domain 의존성 제거
  - [ ] 인터페이스 생성
  
Day 2:
  - [ ] Phase 2 시작
  - [ ] Services 이동
  
Day 3:
  - [ ] Phase 3 시작
  - [ ] Repository 리팩토링
  
Day 4:
  - [ ] Phase 4 시작
  - [ ] 대형 파일 분할
  
Day 5:
  - [ ] Phase 5 시작
  - [ ] DI 통합
  - [ ] 최종 검증
```

## 🔗 관련 문서

- [ARCHITECTURE_RULES.md](/lib/ARCHITECTURE_RULES.md) - Clean Architecture 규칙
- [SUBAGENTS_MANUAL.md](/docs/SUBAGENTS_MANUAL.md) - 서브에이전트 사용법
- [APP_LAYER_INTEGRATION.md](./APP_LAYER_INTEGRATION.md) - App 레이어 통합 가이드
- [notifications/MASTER_MIGRATION_GUIDE.md](../notifications/MASTER_MIGRATION_GUIDE.md) - 참조 구현

## 📞 문의 및 지원

- **Architecture 질문**: Clean Architecture 위반 관련
- **서브에이전트 사용**: SUBAGENTS_MANUAL.md 참조
- **긴급 지원**: 크리티컬 이슈 발생 시

---

*이 문서는 Voting Feature의 완전한 Clean Architecture 마이그레이션을 위한 마스터 가이드입니다.*  
*마지막 업데이트: 2025-01-11*  
*다음 리뷰: Phase 1 완료 후*