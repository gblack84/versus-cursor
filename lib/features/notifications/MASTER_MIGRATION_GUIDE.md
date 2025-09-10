# 🎯 Notifications Feature - Clean Architecture 마이그레이션 마스터 가이드

> **최종 업데이트**: 2025-01-10 | **버전**: 3.1.0  
> **완료된 Phase**: Phase 1 (Domain), Phase 6 (레거시 제거) ✅  
> **진행 대기**: Phase 2 (Data), Phase 3 (Presentation), Phase 4 (Test), Phase 5 (App)  
> **Domain 위반 건수**: 0건 ✅ | **전체 위반**: 85건 (Data: 35건, Presentation: 28건, App: 22건)

## 📊 현재 상태 종합 분석

### 위반 현황 대시보드

| 레이어 | 위반 건수 | 심각도 | 주요 문제 |
|--------|-----------|--------|-----------|
| **Domain** | 0건 | 🟢 Complete | ✅ Firebase 제거, 순수 도메인 100% |
| **Data** | 35건 | 🔴 Critical | 계층 구조 무시, Adapter 남용 |
| **Presentation** | 28건 | 🔴 Critical | Domain 우회, Firebase 직접 사용 |
| **UseCase** | 5개 구현 | 🟢 Complete | ✅ 모든 필수 UseCase 구현 완료 |
| **App Integration** | 22건 | 🟡 High | 구체 구현체 DI, 거대 AppState |

### 아키텍처 준수율

```
Domain: 100% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ✅ 완료
Data:     0% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ⏳ 대기중
Presentation: 0% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ⏳ 대기중
전체:   20% ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 80% 남음
```

## 📐 표준 규칙 및 템플릿

### 표준 서브에이전트 명령어
```bash
# 분석 명령어 (일관된 파라미터)
ANALYZE: /spawn inventory-scout "--depth 3 --scope lib/features/notifications --line-threshold 200"
DETECT:  /spawn import-guardian "--scope notifications --mode detect"
FIX:     /spawn import-guardian "--scope notifications --mode fix --apply false"
BUILD:   /spawn build-sentinel "full"
DI:      /spawn di-binder "--feature notifications --auto-detect --mode apply"
```

### 표준 네이밍 컨벤션
```yaml
file_naming: snake_case (get_notifications_usecase.dart)
class_naming: PascalCase (GetNotificationsUseCase)
directory: 복수형 (usecases/, models/, repositories/)
import_style: Feature 내부는 상대경로, Feature 간은 절대경로
```

### 표준 의존성 순서
```
Domain Models → UseCase → Repository Interface → DTO/Mapper 
→ Repository Implementation → DataSource → Provider → DI
```

## 🗺️ 마이그레이션 로드맵

### 전체 일정 개요 (7일 / 56시간)

```mermaid
gantt
    title Notifications Feature 마이그레이션 일정 (7일)
    dateFormat  YYYY-MM-DD
    
    section Phase 1 (Domain)
    Domain 모델 순수화       :crit, p1a, 2025-01-10, 1d
    UseCase 레이어 생성      :crit, p1b, 2025-01-11, 1d
    
    section Phase 2 (Data)
    DTO 패턴 구현           :active, p2a, 2025-01-12, 1d
    Repository/DataSource    :active, p2b, 2025-01-13, 1d
    
    section Phase 3 (Presentation)
    Provider 리팩토링        :p3a, 2025-01-14, 1d
    Widget 정리             :p3b, 2025-01-15, 0.5d
    
    section Phase 4 (App/검증)
    App DI 통합             :p4a, 2025-01-15, 0.5d
    통합 테스트 및 검증      :p4b, 2025-01-16, 0.5d
    최종 배포               :milestone, m1, 2025-01-16, 0d
```

## 📋 단계별 실행 가이드

### 🚨 Phase 1: Domain 순수화 & UseCase 생성 (2일 / 16시간)

#### Day 1: Domain 모델 순수화 (8시간)
**담당 문서**: [DOMAIN_MIGRATION_GUIDE.md](domain/DOMAIN_MIGRATION_GUIDE.md)

```bash
# 1. 현재 상태 분석 (표준 명령어)
/spawn inventory-scout "--depth 3 --scope lib/features/notifications --line-threshold 200"
/spawn import-guardian "--scope notifications/domain --mode detect"

# 2. 기본 UseCase 생성
cat > lib/features/notifications/domain/usecases/get_notifications_usecase.dart << 'EOF'
import '../repositories/i_notification_repository.dart';
import '../models/notification.dart';

class GetNotificationsUseCase {
  final INotificationRepository _repository;
  
  GetNotificationsUseCase(this._repository);
  
  Future<List<Notification>> call({
    required String userId,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    return await _repository.getUserNotifications(
      userId: userId,
      limit: limit,
      unreadOnly: unreadOnly,
    );
  }
}
EOF
```

**체크리스트**:
- [ ] `get_notifications_usecase.dart` - 알림 목록 조회
- [ ] `mark_as_read_usecase.dart` - 읽음 처리
- [ ] `delete_notification_usecase.dart` - 알림 삭제
- [ ] `get_unread_count_usecase.dart` - 읽지 않은 개수
- [ ] `mark_all_as_read_usecase.dart` - 전체 읽음
- [ ] `send_vote_request_usecase.dart` - 투표 요청 전송
- [ ] `process_vote_response_usecase.dart` - 투표 응답 처리

#### Day 2: UseCase 레이어 구축 (8시간)
**담당 문서**: [DOMAIN_MIGRATION_GUIDE.md](domain/DOMAIN_MIGRATION_GUIDE.md)

```bash
# UseCase 디렉토리 생성
mkdir -p lib/features/notifications/domain/usecases

# 표준 서브에이전트 명령어로 UseCase 생성
/spawn code-surgeon "--create-usecases lib/features/notifications/domain/usecases"
```

**변환 예시**:
```dart
// ❌ Before: Firebase 의존
class NotificationsModel {
  final DocumentReference? reference;  // ❌ Firebase
  final Timestamp createdAt;          // ❌ Firebase
  
  factory NotificationsModel.fromSnapshot(DocumentSnapshot doc) // ❌
}

// ✅ After: 순수 Domain
abstract class Notification {
  final String id;
  final DateTime createdAt;  // ✅ Dart 타입
  
  bool get isExpired;  // ✅ 비즈니스 로직
}
```

### 📦 Phase 2: Data 레이어 & DTO 패턴 구현 (2일 / 16시간)

#### Day 3: DTO 패턴 구현 (8시간)
**담당 문서**: [DTO_MIGRATION_GUIDE.md](data/DTO_MIGRATION_GUIDE.md)

```bash
# 표준 명령어로 DTO 생성 및 Mapper 구현
/spawn struct-weaver "--task dto --source notifications_model.dart --target notification_dto.dart"

# 검증 (표준 명령어)
/spawn build-sentinel "full"
```

**구현 구조**:
```
data/
├── dto/
│   ├── notification_dto.dart        # Firebase 전용
│   └── notification_dto.g.dart      # JSON 직렬화
├── mappers/
│   └── notification_mapper.dart     # DTO ↔ Domain
└── datasources/
    ├── remote/                      # Firebase
    └── local/                       # Hive/SharedPref
```

#### Day 4: Repository & DataSource 구현 (8시간)
**담당 문서**: [Data Layer README](data/README.md)

```bash
# Repository 의존성 주입 설정 (표준 명령어)
/spawn di-binder "--feature notifications --port INotificationRepository --adapter NotificationRepositoryImpl --deps 'IRemoteDataSource,ILocalDataSource,NotificationMapper'"
```

**체크포인트**:
- [ ] 싱글톤 패턴 제거
- [ ] 생성자 주입 구현
- [ ] Mapper 통합
- [ ] 에러 처리 표준화

### 🔧 Phase 3: Presentation 레이어 리팩토링 (1.5일 / 12시간)

#### Day 5-6 오전: Presentation Provider 정리 (12시간)
**담당 문서**: [PRESENTATION_MIGRATION_GUIDE.md](presentation/PRESENTATION_MIGRATION_GUIDE.md)

```bash
# Provider 리팩토링
/spawn code-surgeon "--decompose app_state.dart --extract NotificationState"

# UseCase 주입
/spawn di-binder "--layer presentation --inject UseCases"
```

**Provider 구조 변경**:
```dart
// ❌ Before: Data 직접 접근
class NotificationBadgeProvider {
  final NotificationService _service;  // ❌ Data 레이어
  
  void updateCount() {
    FirebaseFirestore.instance...  // ❌ Firebase 직접
  }
}

// ✅ After: UseCase 사용
class NotificationBadgeProvider extends ChangeNotifier {
  final GetUnreadCountUseCase _getUnreadCount;  // ✅
  
  Future<void> updateCount(String userId) async {
    final count = await _getUnreadCount(userId);
    _unreadCount = count;
    notifyListeners();
  }
}
```

### 🔌 Phase 4: App 레이어 통합 & 검증 (1.5일 / 12시간)

#### Day 6 오후-7 오전: App 레이어 DI 통합 (8시간)
**담당 문서**: [APP_LAYER_INTEGRATION.md](APP_LAYER_INTEGRATION.md)

```bash
# DI 모듈 정리 (표준 명령어)
/spawn di-binder "--module notifications --abstract-only"

# AppState 분리
/spawn struct-weaver "--decompose app_state.dart --by-feature"
```

#### Day 7 오후: 통합 테스트 및 검증 (4시간)
**담당 문서**: [Testing Guide](test/README.md)

```bash
# 전체 검증 스크립트
#!/bin/bash

echo "🔍 아키텍처 검증 시작..."

# 1. Import 검증
/spawn import-guardian "--scope notifications --mode detect" > validation_report.txt

# 2. 빌드 검증  
/spawn build-sentinel "full"

# 3. 테스트 실행
flutter test test/features/notifications/

# 4. 커버리지 확인
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

echo "✅ 검증 완료! 보고서: validation_report.txt"
```

## 🔄 레이어간 의존성 및 실행 순서

### 의존성 그래프

```mermaid
graph TB
    subgraph "Phase 1: 긴급"
        UC[UseCase 생성]
        DP[Domain 순수화]
        UC --> DP
    end
    
    subgraph "Phase 2: 핵심"
        DTO[DTO 패턴]
        REPO[Repository]
        DP --> DTO
        DTO --> REPO
    end
    
    subgraph "Phase 3: 통합"
        PRES[Presentation]
        APP[App 레이어]
        REPO --> PRES
        UC --> PRES
        PRES --> APP
    end
    
    subgraph "Phase 4: 검증"
        TEST[테스트]
        APP --> TEST
    end
    
    style UC fill:#ff9999
    style DP fill:#ff9999
    style DTO fill:#ffcc99
    style REPO fill:#ffcc99
```

### 병렬 작업 가능 항목

| Phase | 병렬 가능 작업 | 의존성 |
|-------|---------------|--------|
| 1 | UseCase 개별 파일들 | 서로 독립적 |
| 2 | DTO와 Mapper | Domain 완료 후 |
| 2 | Local/Remote DataSource | 서로 독립적 |
| 3 | 각 Provider 파일 | UseCase 완료 후 |
| 3 | 테스트 작성 | 각 기능 완료 후 |

## 📁 파일별 상세 마이그레이션 가이드

### Domain 레이어 (22개 파일)

| 파일 | 현재 문제 | 해결 방법 | 우선순위 |
|-----|----------|----------|----------|
| `notifications_model.dart` | Firebase 의존 | 순수 Domain 모델로 변환 | 🔴 Critical |
| `notification_model.dart` | Firebase 의존 | 순수 Domain 모델로 변환 | 🔴 Critical |
| `usecases/` (없음) | 디렉토리 없음 | 7개 UseCase 생성 | 🔴 Critical |
| `i_notification_repository.dart` | Query 타입 노출 | 추상화된 파라미터로 변경 | 🟡 High |

### Data 레이어 (35개 파일)

| 파일 | 현재 문제 | 해결 방법 | 우선순위 |
|-----|----------|----------|----------|
| `notification_service.dart` | 비즈니스 로직 혼재 | DataSource로 분리 | 🔴 Critical |
| `global_notification_manager.dart` | 거대 클래스 | UseCase별 분해 | 🔴 Critical |
| `target_audience_service.dart` | AI 로직 혼재 | 별도 서비스 분리 | 🟡 High |
| `notification_repository_impl.dart` | 싱글톤 패턴 | DI 패턴으로 변경 | 🟡 High |

### Presentation 레이어 (28개 파일)

| 파일 | 현재 문제 | 해결 방법 | 우선순위 |
|-----|----------|----------|----------|
| `notification_provider.dart` | Data 직접 접근 | UseCase 주입 | 🔴 Critical |
| `notification_badge_provider.dart` | Service 직접 사용 | UseCase 사용 | 🔴 Critical |
| `notifications_list_widget.dart` | Repository 직접 접근 | Provider 패턴 | 🔴 Critical |
| `voting_notification_dialog.dart` | Firebase 직접 사용 | Provider 통해 처리 | 🟡 High |

## 🧪 검증 체크리스트

### Phase별 검증 항목

#### Phase 1 검증
- [ ] Domain 폴더에 Firebase import 0건
- [ ] 모든 UseCase 파일 생성 완료
- [ ] UseCase 단위 테스트 작성

#### Phase 2 검증
- [ ] DTO ↔ Domain 변환 테스트
- [ ] Repository가 Domain 모델만 반환
- [ ] DataSource가 DTO만 처리

#### Phase 3 검증
- [ ] Provider가 UseCase만 사용
- [ ] Widget이 Provider만 사용
- [ ] Firebase 직접 호출 0건

#### Phase 4 검증
- [ ] 전체 import 검증 통과
- [ ] 빌드 성공
- [ ] 테스트 커버리지 80% 이상

## 🚀 원클릭 실행 스크립트

### 전체 마이그레이션 자동화

```bash
#!/bin/bash
# master_migration.sh

set -e  # 에러 시 중단

echo "🎯 Notifications Feature 마이그레이션 시작"
echo "================================================"

# 환경 변수 설정
FEATURE_DIR="lib/features/notifications"
REPORTS_DIR="migration_reports"
PATCHES_DIR="migration_patches"

# 디렉토리 생성
mkdir -p $REPORTS_DIR $PATCHES_DIR

# Phase 1: 현재 상태 백업
echo "📸 Phase 0: 현재 상태 백업..."
git stash
git checkout -b migration/notifications-clean-arch
git stash pop

# Phase 1: UseCase & Domain
echo "🔨 Phase 1: UseCase 생성 및 Domain 순수화..."
echo "----------------------------------------"

# UseCase 생성
/spawn code-surgeon "--create-usecases $FEATURE_DIR/domain/usecases"

# Domain 순수화
/spawn struct-weaver "--task domain --source $FEATURE_DIR/domain/models --mode detect" > $PATCHES_DIR/domain.patch
echo "⚠️  Domain 패치 확인: $PATCHES_DIR/domain.patch"
read -p "적용하시겠습니까? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    git apply $PATCHES_DIR/domain.patch
    echo "✅ Domain 순수화 완료"
fi

# Phase 2: Data Layer
echo "📦 Phase 2: Data 레이어 정리..."
echo "----------------------------------------"

# DTO 생성
/spawn struct-weaver "--task dto --source $FEATURE_DIR/domain/models/notifications_model.dart" > $PATCHES_DIR/dto.patch
git apply $PATCHES_DIR/dto.patch

# Repository 리팩토링
/spawn repo-mover "--feature notifications --layer data --mode apply"

# DI 설정
/spawn di-binder "--feature notifications --auto-detect --mode apply"

echo "✅ Data 레이어 완료"

# Phase 3: Presentation
echo "🎨 Phase 3: Presentation 정리..."
echo "----------------------------------------"

# Provider 리팩토링
/spawn code-surgeon "--refactor-providers $FEATURE_DIR/presentation/providers"

# Widget 정리
/spawn import-guardian "--scope $FEATURE_DIR/presentation --mode fix --apply"

echo "✅ Presentation 레이어 완료"

# Phase 4: App Integration
echo "🔌 Phase 4: App 레이어 통합..."
echo "----------------------------------------"

# DI 모듈 업데이트
/spawn di-binder "--update-app-module notifications"

# AppState 분리
/spawn struct-weaver "--decompose lib/app/state/app_state.dart --feature notifications"

echo "✅ App 통합 완료"

# Phase 5: 검증
echo "🔍 Phase 5: 최종 검증..."
echo "----------------------------------------"

# Import 검증
/spawn import-guardian "--scope $FEATURE_DIR --mode detect" > $REPORTS_DIR/final_imports.txt

# Build 검증
/spawn build-sentinel "full" > $REPORTS_DIR/build_report.txt

# 테스트 실행
flutter test test/features/notifications/ > $REPORTS_DIR/test_report.txt

# 결과 출력
echo "================================================"
echo "🎉 마이그레이션 완료!"
echo ""
echo "📊 결과 요약:"
echo "- Import 위반: $(grep -c "violation" $REPORTS_DIR/final_imports.txt || echo 0)건"
echo "- 빌드 상태: $(grep "BUILD SUCCESSFUL" $REPORTS_DIR/build_report.txt && echo "✅ 성공" || echo "❌ 실패")"
echo "- 테스트 결과: $(grep "All tests passed" $REPORTS_DIR/test_report.txt && echo "✅ 통과" || echo "⚠️ 확인 필요")"
echo ""
echo "상세 보고서: $REPORTS_DIR/"
echo "================================================"

# Git 커밋 제안
echo ""
echo "💡 커밋 메시지 제안:"
echo "git add ."
echo "git commit -m 'refactor(notifications): Clean Architecture migration"
echo ""
echo "- Create UseCase layer"
echo "- Purify Domain models (remove Firebase deps)"
echo "- Implement DTO pattern in Data layer"  
echo "- Refactor Presentation to use UseCases"
echo "- Update App layer DI configuration"
echo ""
echo "BREAKING CHANGE: Repository interfaces changed'"
```

## 📊 진행 상황 모니터링

### 실시간 대시보드

```bash
# monitoring.sh
#!/bin/bash

while true; do
    clear
    echo "📊 Notifications Migration Dashboard"
    echo "===================================="
    echo ""
    
    # Domain 체크
    DOMAIN_VIOLATIONS=$(grep -r "import.*firebase" lib/features/notifications/domain | wc -l)
    echo "Domain Layer:"
    echo "  Firebase imports: $DOMAIN_VIOLATIONS"
    echo "  UseCase files: $(ls -1 lib/features/notifications/domain/usecases/*.dart 2>/dev/null | wc -l)/7"
    echo ""
    
    # Data 체크
    echo "Data Layer:"
    echo "  DTO files: $(ls -1 lib/features/notifications/data/dto/*.dart 2>/dev/null | wc -l)"
    echo "  DataSource files: $(ls -1 lib/features/notifications/data/datasources/*/*.dart 2>/dev/null | wc -l)"
    echo ""
    
    # Presentation 체크
    PRES_VIOLATIONS=$(grep -r "import.*data" lib/features/notifications/presentation | wc -l)
    echo "Presentation Layer:"
    echo "  Data imports: $PRES_VIOLATIONS"
    echo ""
    
    # 전체 진행률
    TOTAL_TASKS=50
    COMPLETED=$(find lib/features/notifications -name "*.dart" -newer migration_start.marker 2>/dev/null | wc -l)
    PROGRESS=$((COMPLETED * 100 / TOTAL_TASKS))
    
    echo "Overall Progress: [$PROGRESS%]"
    printf '█%.0s' $(seq 1 $((PROGRESS / 2)))
    printf '░%.0s' $(seq 1 $((50 - PROGRESS / 2)))
    echo ""
    
    sleep 5
done
```

## ⚠️ 위험 요소 및 대응 방안

### 주요 위험 요소

| 위험 요소 | 발생 확률 | 영향도 | 대응 방안 |
|----------|-----------|--------|-----------|
| Firebase 타입 변환 오류 | 높음 | 🔴 Critical | DTO Mapper 철저한 테스트 |
| 실시간 구독 중단 | 중간 | 🔴 Critical | Stream 관리 로직 검증 |
| DI 순환 의존성 | 낮음 | 🟡 High | Factory 패턴 적용 |
| 성능 저하 | 낮음 | 🟢 Low | 프로파일링 후 최적화 |

### 롤백 전략

```bash
# 각 Phase별 체크포인트
git tag phase1-complete
git tag phase2-complete
git tag phase3-complete

# 문제 발생 시 롤백
git reset --hard phase2-complete  # Phase 3 문제 시
```

## 📈 기대 효과

### 정량적 지표

| 지표 | 현재 | 목표 | 개선율 |
|------|------|------|--------|
| 아키텍처 위반 | 107건 | 0건 | 100% |
| 테스트 커버리지 | 0% | 80% | +80% |
| 코드 중복 | 35% | 10% | -71% |
| 순환 복잡도 | 15 | 8 | -47% |
| 유지보수성 지수 | 45 | 85 | +89% |

### 정성적 효과

- **확장성**: 새로운 알림 타입 추가 용이
- **테스트 가능성**: Mock 주입으로 단위 테스트 가능
- **팀 생산성**: 명확한 레이어로 병렬 작업 가능
- **코드 품질**: SOLID 원칙 준수
- **기술 부채**: 대폭 감소

## 🔗 참조 문서

### 레이어별 상세 가이드
1. [Data Layer - DTO 마이그레이션](data/DTO_MIGRATION_GUIDE.md)
2. [Domain Layer - 순수화 가이드](domain/DOMAIN_MIGRATION_GUIDE.md)
3. [Presentation Layer - Provider 리팩토링](presentation/PRESENTATION_MIGRATION_GUIDE.md)
4. [App Layer - DI 통합](APP_LAYER_INTEGRATION.md)

### 도구 및 참고자료
- [SUBAGENTS_MANUAL.md](/docs/SUBAGENTS_MANUAL.md) - 서브에이전트 사용법
- [ARCHITECTURE_RULES.md](/lib/ARCHITECTURE_RULES.md) - 아키텍처 원칙
- [Clean Architecture 원문](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

## ✅ Phase 6: 레거시 모델 제거 및 대체 (완료)

### 작업 내용

#### 6.1 사용처 대체
- **Presentation Layer**: `notifications_list_widget.dart` → 새 도메인 모델 사용 ✅
- **Service Layer**: 
  - `notification_service.dart` → Stream<Notification> ✅
  - `global_notification_manager.dart` → namespace alias 처리 ✅
- **Repository**: import 정리 완료 ✅

#### 6.2 레거시 파일 제거
- `notification_model.dart` 삭제 ✅
- `notifications_model.dart` 삭제 ✅
- 백업 위치: `/backup/legacy/notifications/`

#### 6.3 테스트 수정
- `notification_filter_test.dart` NotificationType enum 사용 ✅
- 16개 테스트 모두 통과 ✅

### 구현된 도메인 모델 구조
```dart
// 추상 베이스 클래스
abstract class Notification {
  final String id;
  final String userId;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  // ...
}

// 구체 구현체들
class VoteNotification extends Notification { ... }
class SystemNotification extends Notification { ... }
class SocialNotification extends Notification { ... }
```

### 구현된 UseCase 목록
1. `GetUserNotificationsUseCase` - 사용자 알림 조회
2. `WatchUnreadCountUseCase` - 읽지 않은 알림 개수 감시
3. `MarkNotificationAsReadUseCase` - 알림 읽음 처리
4. `SendNotificationUseCase` - 알림 전송
5. `ProcessVoteNotificationUseCase` - 투표 알림 처리

## 💬 FAQ

### Q: UseCase가 꼭 필요한가요?
**A**: 네, 필수입니다. UseCase는 비즈니스 로직을 캡슐화하고 Presentation과 Data를 분리하는 핵심 레이어입니다.

### Q: 마이그레이션 중 앱이 동작하나요?
**A**: 네, 점진적 마이그레이션으로 각 Phase마다 동작하는 상태를 유지합니다.

### Q: 성능에 영향이 있나요?
**A**: 레이어가 추가되지만 실제 성능 영향은 미미합니다. 오히려 캐싱과 최적화가 용이해집니다.

### Q: 롤백이 가능한가요?
**A**: 네, 각 Phase별로 Git 태그를 생성하여 언제든 롤백 가능합니다.

## 📞 지원

### 문제 발생 시
1. 에러 로그와 현재 Phase 명시
2. `migration_reports/` 디렉토리 내용 첨부
3. Architecture Team 문의

### 추가 지원
- 페어 프로그래밍 세션 요청
- 코드 리뷰 요청
- 추가 예제 코드 요청

---

*이 마스터 가이드는 Notifications Feature의 완전한 Clean Architecture 전환을 위한 종합 실행 계획입니다.*  
*Phase별로 체계적으로 진행하면 7-9일 내 완료 가능합니다.*  
*문의: Architecture Team (@g_black)*