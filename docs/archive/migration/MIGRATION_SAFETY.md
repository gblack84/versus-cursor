# 🛡️ Migration Safety Guide - 안전한 마이그레이션 가이드

> Feature-First Architecture 마이그레이션 중 발생할 수 있는 위험과 해결 방법
> 작성일: 2025-08-26

## 🚫 마이그레이션 Phase별 제한사항

### Phase 1: 파일 이동만
- ✅ 허용: 파일 위치 변경
- ✅ 허용: 디렉토리 구조 생성
- ❌ 금지: 파일명 변경
- ❌ 금지: 클래스명 변경
- ❌ 금지: Import 경로 외 코드 수정
- ❌ 금지: 함수명 변경
- ❌ 금지: 변수명 변경

### Phase 2: 리팩토링 (이동 완료 후)
- ✅ 허용: Import 경로 정리
- ✅ 허용: 네이밍 컨벤션 적용
- ✅ 허용: 구조 개선
- ✅ 허용: 코드 최적화
- ✅ 허용: 테스트 추가

### ⚠️ 중요 원칙
**"Move First, Refactor Later"** - 이동 먼저, 리팩토링은 나중에

## 🚨 주요 위험 요소

### 1. 순환 의존성 (Circular Dependencies)

#### 위험 상황
```dart
// ❌ 위험: Feature 간 직접 의존
features/posts/ → features/chat/ → features/posts/
```

#### 예방 방법
```dart
// ✅ 안전: Common 인터페이스 통한 의존
features/posts/ → features/common/domain/interfaces/
features/chat/ → features/common/domain/interfaces/
```

#### 감지 도구
```bash
# 순환 의존성 검사 스크립트
./scripts/check-circular-deps.sh

# CI/CD 파이프라인에 통합
flutter pub run dependency_validator
```

### 2. Import 경로 오류

#### 위험 상황
```dart
// ❌ 위험: 이전 경로 사용
import 'package:versus_space/core/app_theme.dart';

// ❌ 위험: 상대 경로 혼용
import '../../../common/widgets/button.dart';
```

#### 안전한 방법
```dart
// ✅ 안전: Feature 경로 사용
import 'package:versus_space/features/common/presentation/theme/app_theme.dart';

// ✅ 안전: 절대 경로 사용
import 'package:versus_space/features/common/presentation/widgets/button.dart';
```

#### 자동 수정 도구
```bash
# Import 경로 자동 수정
dart fix --apply

# Import 정리
flutter pub run import_sorter:main
```

### 3. 빌드 깨짐 (Build Breaks)

#### 위험 신호
- `flutter analyze` 경고/에러
- `flutter build` 실패
- 런타임 에러 증가

#### 예방 체크리스트
```yaml
pre_migration:
  - [ ] 현재 브랜치 백업
  - [ ] flutter clean
  - [ ] flutter pub get
  - [ ] flutter analyze (0 warnings)
  - [ ] flutter test (all passing)
  - [ ] flutter build apk --debug (성공)

during_migration:
  - [ ] 작은 단위로 커밋
  - [ ] 각 커밋마다 빌드 확인
  - [ ] 테스트 실행

post_migration:
  - [ ] 전체 빌드 검증
  - [ ] 통합 테스트 실행
  - [ ] 성능 프로파일링
```

### 4. 상태 관리 충돌

#### 위험 상황
```dart
// ❌ 위험: 여러 곳에서 동일 상태 관리
AppState.uploadImageA // 기존
PostsState.uploadImageA // 새로운
```

#### 안전한 전환
```dart
// ✅ 안전: 점진적 마이그레이션
class AppState {
  // @Deprecated('Use PostsState instead')
  String? get uploadImageA => PostsState.instance.uploadImageA;
}
```

### 5. 데이터 모델 불일치

#### 위험 상황
- Firestore 필드명 변경
- 모델 구조 변경
- 시리얼라이제이션 에러

#### 안전한 방법
```dart
// ✅ 안전: Backward Compatibility 유지
class PostModel {
  final String title;
  
  PostModel.fromJson(Map<String, dynamic> json)
    : title = json['title'] ?? json['title_old'] ?? ''; // 이전 필드 지원
}
```

## 🔧 안전 도구 (Safety Tools)

### 1. 브랜치 전략
```bash
# Feature별 브랜치 생성
git checkout -b feature/[name]-migration

# 백업 브랜치 생성 (필수!)
git branch backup/before-[name]-migration HEAD

# 실패한 시도 브랜치 보관 (문제 발생 시)
git branch backup/[name]-failed-attempt HEAD

# 안전한 머지
git merge --no-ff --no-commit feature/[name]-migration
flutter analyze && flutter test && git commit
```

### 2. 롤백 계획
```bash
#!/bin/bash
# rollback.sh

FEATURE=$1
BACKUP_BRANCH="backup/before-${FEATURE}-migration"

echo "🔄 Rolling back $FEATURE migration..."

# 현재 변경사항 저장
git stash

# 백업 브랜치로 복원
git checkout $BACKUP_BRANCH
git checkout -b rollback/${FEATURE}

# 클린 빌드
flutter clean
flutter pub get
flutter analyze

echo "✅ Rollback complete"
```

### 3. 의존성 검증
```bash
#!/bin/bash
# verify-dependencies.sh

echo "🔍 Checking dependencies..."

# Core imports 검사
if grep -r "package:versus_space/core/" lib/features/; then
  echo "❌ Found legacy core imports in features"
  exit 1
fi

# 순환 의존성 검사
dart run dependency_validator

# Layer violations 검사
if grep -r "features/.*/data/" lib/features/**/presentation; then
  echo "❌ Found layer violations"
  exit 1
fi

echo "✅ All dependency checks passed"
```

### 4. 테스트 커버리지 유지
```yaml
# coverage.yaml
min_coverage:
  overall: 40%
  critical_paths:
    - path: lib/features/auth
      min: 60%
    - path: lib/features/posts
      min: 50%
```

## 📊 위험 수준 매트릭스

| 작업 | 위험도 | 영향 범위 | 롤백 난이도 | 권장 접근법 |
|------|--------|-----------|-------------|------------|
| **Core 마이그레이션** | 🔴 높음 | 전체 | 어려움 | 점진적, 브리지 파일 사용 |
| **Common 생성** | 🟡 중간 | 대부분 | 중간 | 단계별, 테스트 강화 |
| **Feature 분리** | 🟢 낮음 | 개별 | 쉬움 | 병렬 작업 가능 |
| **라우터 통합** | 🟡 중간 | 네비게이션 | 중간 | 인터페이스 기반 |
| **DI 설정** | 🔴 높음 | 전체 | 어려움 | 신중한 순차 작업 |

## 🚦 Go/No-Go 체크리스트

### Phase 시작 전 확인
```yaml
go_criteria:
  build:
    - flutter analyze: 0 errors
    - flutter test: 100% passing
    - flutter build: successful
  
  dependencies:
    - 이전 Phase 완료
    - 의존 Feature 준비
    - 백업 브랜치 생성 확인 (필수!)
  
  resources:
    - 담당자 배정
    - 예상 시간 확보
    - 롤백 계획 수립
  
  phase_rules:
    - Phase 1: 파일 이동만
    - Phase 2: 리팩토링 (별도 커밋)
```

### Phase 완료 확인
```yaml
done_criteria:
  code_quality:
    - No legacy imports
    - No circular dependencies
    - No layer violations
  
  testing:
    - Unit tests passing
    - Integration tests passing
    - E2E critical paths tested
  
  documentation:
    - README updated
    - Migration notes added
    - Known issues documented
```

## 🆘 긴급 대응 절차

### 1. 빌드 실패 시
```bash
# 1. 현재 상태 저장
git stash

# 2. 클린 빌드 시도
flutter clean
rm -rf .dart_tool
flutter pub get
flutter pub upgrade

# 3. 캐시 클리어
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf android/.gradle

# 4. 재빌드
flutter build apk --debug
```

### 2. 런타임 크래시
```dart
// main.dart - 에러 핸들링 강화
void main() {
  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterError(details);
    // 롤백 트리거 로직
  };
  
  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  });
}
```

### 3. 데이터 손실 방지
```dart
// 마이그레이션 전 데이터 백업
class MigrationBackup {
  static Future<void> backupUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
      
      // 로컬 백업
      await SharedPreferences.getInstance()
        .setString('backup_user_data', jsonEncode(userData.data()));
    }
  }
}
```

## 📈 모니터링 지표

### 성능 지표
```yaml
performance_metrics:
  build_time:
    baseline: 5 minutes
    threshold: 6 minutes
    action: Investigate if >10% increase
  
  app_size:
    baseline: 180MB
    threshold: 200MB
    action: Optimize if >10% increase
  
  startup_time:
    baseline: 2 seconds
    threshold: 3 seconds
    action: Profile if >50% increase
```

### 품질 지표
```yaml
quality_metrics:
  crash_rate:
    baseline: 0.1%
    threshold: 0.5%
    action: Rollback if >5x increase
  
  error_rate:
    baseline: 1%
    threshold: 3%
    action: Investigate if >3x increase
  
  test_coverage:
    baseline: 40%
    threshold: 35%
    action: Add tests if <baseline
```

## 🔄 복구 전략

### Level 1: 부분 롤백
- 문제 Feature만 이전 버전으로
- 다른 Feature는 유지
- 1시간 이내 복구

### Level 2: Phase 롤백
- 전체 Phase를 이전 상태로
- 관련 Feature 모두 롤백
- 4시간 이내 복구

### Level 3: 전체 롤백
- flutterflow 브랜치로 복귀
- 모든 마이그레이션 취소
- 24시간 이내 안정화

## 📝 문제 발생 시 체크리스트

```markdown
## 문제 보고서

### 문제 설명
- [ ] 에러 메시지/스택트레이스
- [ ] 재현 단계
- [ ] 영향 범위

### 환경 정보
- [ ] Flutter 버전
- [ ] 브랜치/커밋
- [ ] 디바이스/OS

### 시도한 해결 방법
- [ ] flutter clean
- [ ] 캐시 클리어
- [ ] 의존성 업데이트

### 롤백 필요성
- [ ] 긴급도 (높음/중간/낮음)
- [ ] 영향받는 사용자 수
- [ ] 대체 방안 존재 여부
```

## 🎯 성공 기준

### 마이그레이션 성공 지표
1. **기능 유지**: 모든 기존 기능 정상 작동
2. **성능 개선**: 빌드 시간 40% 단축
3. **품질 향상**: 테스트 커버리지 70% 달성
4. **유지보수성**: 코드 중복 50% 감소
5. **안정성**: 크래시율 0.1% 이하 유지

---

*이 문서는 안전한 마이그레이션을 위한 가이드입니다.*
*위험을 최소화하고 성공적인 전환을 보장합니다.*
*작성일: 2025-08-26*