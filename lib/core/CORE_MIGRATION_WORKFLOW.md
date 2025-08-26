# 🚀 Core 마이그레이션 안전 워크플로우

> MIGRATION_ORDER.md와 MIGRATION_SAFETY.md 기반 상세 실행 가이드
> 작성일: 2025-08-26
> 예상 시간: 3시간 20분

## 📋 Phase 0: Pre-Migration (사전 준비) - 20분

### 1. 백업 및 브랜치 생성 ✅
```bash
# 현재 브랜치 확인 및 백업
git status
git branch backup/before-core-migration

# 마이그레이션 브랜치 생성 (이미 생성됨: feature/core-migration)
git checkout feature/core-migration
```

### 2. 현재 상태 검증 ✅
```bash
# Core 디렉토리 파일 목록 확인
ls -la lib/core/

# Core imports 수량 확인 (중요!)
echo "Core imports 수: $(grep -r "package:versus_space/core/" lib/ | wc -l)"

# 의존성 분석
flutter pub deps > deps_before_migration.txt
```

### 3. 품질 베이스라인 설정 ✅
```bash
# 현재 상태에서 빌드 가능 확인
flutter clean
flutter pub get
flutter analyze > analyze_before.txt
flutter test > test_before.txt
flutter build apk --debug # 성공 확인
```

### 4. Pre-Migration 체크리스트 ✅
```yaml
pre_migration_checklist:
  - [ ] 백업 브랜치 생성 완료
  - [ ] flutter analyze: 현재 warning 수 기록
  - [ ] flutter test: 현재 통과 테스트 수 기록
  - [ ] flutter build apk --debug: 성공
  - [ ] Core imports 수: ___ 개 (기록)
  - [ ] 작업 시작 시간: ___
```

---

## 🔧 Phase 1: Bridge File Creation (브리지 파일 생성) - 30분

### 1. Core 파일 목록 수집 🔄
```bash
# Core 디렉토리 구조 파악
find lib/core -name "*.dart" | sort > core_files.txt
cat core_files.txt
```

### 2. core_exports.dart 브리지 파일 생성 🔄
```dart
// lib/core_exports.dart
// ============================================
// Temporary bridge file for gradual Core migration
// Created: 2025-08-26
// TODO: Remove after all migrations complete
// ============================================

// Navigation
export 'core/nav/nav.dart';
export 'core/nav/routes.g.dart';

// Theme & Styling  
export 'core/app_theme.dart';
export 'core/app_theme_colors.dart';
export 'core/app_constants.dart';
export 'core/app_icon_button.dart';
export 'core/app_expanded_image_view.dart';
export 'core/app_video_player.dart';

// Utils
export 'core/app_utils.dart';
export 'core/app_localizations.dart';
export 'core/app_animations.dart';
export 'core/app_timer.dart';
export 'core/app_model.dart';
export 'core/app_choice_chips.dart';
export 'core/app_data_table_2.dart';
export 'core/app_drop_down.dart';
export 'core/app_language_selector.dart';
export 'core/app_media_display.dart';
export 'core/app_place_picker.dart';
export 'core/app_radio_button.dart';
export 'core/app_toggle_icon.dart';
export 'core/app_uploaded_file.dart';
export 'core/app_widgets.dart';

// Add any custom functions if exists
// export 'core/custom_functions.dart';

// Platform specific
export 'core/app_lat_lng.dart';
export 'core/app_place.dart';
```

### 3. 브리지 파일 검증 🔄
```bash
# 브리지 파일로 컴파일 테스트
flutter analyze lib/core_exports.dart

# 누락된 export 확인
for file in $(find lib/core -name "*.dart"); do
  basename=$(basename $file)
  if ! grep -q "$basename" lib/core_exports.dart; then
    echo "Missing: $file"
  fi
done
```

---

## 🔄 Phase 2: Import Path Replacement (경로 교체) - 1시간

### 1. Import 경로 일괄 변경 (자동) ⏳
```bash
# 백업 생성
cp -r lib lib_backup_$(date +%Y%m%d_%H%M%S)

# Core imports를 core_exports로 변경
find lib -name "*.dart" -type f | while read file; do
  # Skip core directory itself and core_exports.dart
  if [[ ! "$file" == *"/core/"* ]] && [[ ! "$file" == *"core_exports.dart" ]]; then
    # Replace imports
    sed -i '' 's|package:versus_space/core/|package:versus_space/core_exports.dart#|g' "$file"
    sed -i '' 's|\.dart#|#|g' "$file"
    sed -i '' 's|#|;///MIGRATED|g' "$file"
  fi
done
```

### 2. 단계별 검증 ⏳
```bash
# 변경된 파일 수 확인
echo "변경된 파일: $(grep -r "///MIGRATED" lib/ | wc -l)"

# 컴파일 테스트
flutter analyze

# 남은 core imports 확인
echo "남은 core imports: $(grep -r "package:versus_space/core/" lib/ | grep -v "/core/" | grep -v "core_exports" | wc -l)"
```

### 3. 문제 파일 수동 처리 ⏳
```dart
// 문제가 있는 파일들 개별 처리
// 예시: 특수한 import 패턴이 있는 경우

// Before:
import 'package:versus_space/core/app_theme.dart' as theme;
import 'package:versus_space/core/app_utils.dart' show formatDate;

// After:
import 'package:versus_space/core_exports.dart' as core_exports;
// Use: core_exports.AppTheme, core_exports.formatDate
```

---

## 🗂️ Phase 3: Core File Distribution (파일 분산) - 1시간 20분

### 1. 파일 분류 및 이동 계획 📝
```yaml
file_distribution_plan:
  to_common:
    - app_theme.dart → /lib/features/common/presentation/theme/
    - app_theme_colors.dart → /lib/features/common/presentation/theme/
    - app_constants.dart → /lib/features/common/constants/
    - app_localizations.dart → /lib/features/common/localization/
    - app_utils.dart → /lib/features/common/utils/
    - app_animations.dart → /lib/features/common/presentation/animations/
    - app_widgets.dart → /lib/features/common/presentation/widgets/
    - app_timer.dart → /lib/features/common/utils/
    - app_model.dart → /lib/features/common/domain/models/

  to_app:
    - nav/ → /lib/app/router/navigation/
    - routes.g.dart → /lib/app/router/
    - app_lat_lng.dart → /lib/app/models/
    - app_place.dart → /lib/app/models/

  ui_components_to_common:
    - app_choice_chips.dart → /lib/features/common/presentation/widgets/
    - app_data_table_2.dart → /lib/features/common/presentation/widgets/
    - app_drop_down.dart → /lib/features/common/presentation/widgets/
    - app_expanded_image_view.dart → /lib/features/common/presentation/widgets/
    - app_icon_button.dart → /lib/features/common/presentation/widgets/
    - app_language_selector.dart → /lib/features/common/presentation/widgets/
    - app_media_display.dart → /lib/features/common/presentation/widgets/
    - app_place_picker.dart → /lib/features/common/presentation/widgets/
    - app_radio_button.dart → /lib/features/common/presentation/widgets/
    - app_toggle_icon.dart → /lib/features/common/presentation/widgets/
    - app_uploaded_file.dart → /lib/features/common/presentation/widgets/
    - app_video_player.dart → /lib/features/common/presentation/widgets/
```

### 2. 디렉토리 구조 생성 📁
```bash
# Common 디렉토리 구조
mkdir -p lib/features/common/{presentation/{theme,widgets,animations},utils,constants,localization,domain/models}

# App 디렉토리 구조  
mkdir -p lib/app/{router/navigation,models}
```

### 3. 파일 이동 실행 (점진적) 🚀
```bash
# Step 1: Theme 파일들 이동
cp lib/core/app_theme.dart lib/features/common/presentation/theme/
cp lib/core/app_theme_colors.dart lib/features/common/presentation/theme/

# Step 2: Utils 파일들 이동
cp lib/core/app_utils.dart lib/features/common/utils/
cp lib/core/app_timer.dart lib/features/common/utils/

# Step 3: Navigation 파일들 이동
cp -r lib/core/nav/* lib/app/router/navigation/
cp lib/core/routes.g.dart lib/app/router/

# ... (계속)

# 각 단계마다 검증
flutter analyze
```

### 4. core_exports.dart 업데이트 🔄
```dart
// lib/core_exports.dart 수정
// 이동된 파일들의 새 경로로 export 업데이트

// Theme - Common으로 이동
export 'features/common/presentation/theme/app_theme.dart';
export 'features/common/presentation/theme/app_theme_colors.dart';

// Navigation - App으로 이동  
export 'app/router/navigation/nav.dart';
export 'app/router/routes.g.dart';

// ... (모든 이동된 파일 업데이트)
```

---

## ✅ Phase 4: Validation & Testing (검증) - 30분

### 1. 컴파일 검증 ✔️
```bash
# Clean build
flutter clean
flutter pub get

# Analyze
flutter analyze --fatal-infos --fatal-warnings

# 결과 기록
echo "Warnings: $(flutter analyze | grep -c warning)"
echo "Errors: $(flutter analyze | grep -c error)"
```

### 2. Import 검증 ✔️
```bash
# Core imports 완전 제거 확인
if grep -r "package:versus_space/core/" lib/ --exclude-dir=core --exclude="core_exports.dart"; then
  echo "❌ Core imports still exist!"
  exit 1
else
  echo "✅ All core imports migrated!"
fi
```

### 3. 테스트 실행 ✔️
```bash
# Unit tests
flutter test

# Build test
flutter build apk --debug
flutter build ios --debug --no-codesign
```

### 4. 성능 메트릭 확인 ✔️
```bash
# Build time
time flutter build apk --debug

# App size
du -sh build/app/outputs/flutter-apk/app-debug.apk

# Analyze time
time flutter analyze
```

---

## 🎯 Phase 5: Core Directory Removal (최종 정리) - 10분

### 1. Core 디렉토리 제거 준비 🗑️
```bash
# 최종 확인
ls -la lib/core/

# 백업 확인
ls -la lib_backup_*/core/

# Git 상태 확인
git status
```

### 2. Core 디렉토리 삭제 🗑️
```bash
# Git에서 추적 제거
git rm -r lib/core/

# 물리적 삭제 확인
ls lib/core/ 2>/dev/null || echo "✅ Core directory removed"
```

### 3. 최종 검증 ✅
```bash
# Final build test
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

---

## 📊 Post-Migration Checklist

### Quality Gates 통과 확인
```yaml
quality_gates:
  code_quality:
    - [ ] flutter analyze: 0 errors
    - [ ] dart format: 100% formatted
    - [ ] No core imports remaining
  
  tests:
    - [ ] All existing tests pass
    - [ ] Build successful (APK)
    - [ ] Build successful (iOS)
  
  performance:
    - [ ] Build time: < 5 minutes
    - [ ] App size: < 150MB
    - [ ] No performance regression
```

### 메트릭 비교
```yaml
metrics_comparison:
  before_migration:
    warnings: ___
    build_time: ___
    app_size: ___
    core_imports: ___
  
  after_migration:
    warnings: ___
    build_time: ___
    app_size: ___
    core_imports: 0
```

### Git Commit
```bash
# 단계별 커밋
git add .
git commit -m "refactor(core): Phase 1 - Create bridge file core_exports.dart"

git add .
git commit -m "refactor(core): Phase 2 - Replace all core imports with bridge"

git add .
git commit -m "refactor(core): Phase 3 - Distribute core files to features"

git add .
git commit -m "refactor(core): Phase 4 - Validate and test migration"

git add .
git commit -m "refactor(core): Phase 5 - Remove core directory ✨"
```

---

## 🚨 Rollback Plan (문제 발생 시)

### Level 1: 부분 롤백
```bash
# 특정 커밋으로 롤백
git reset --hard HEAD~1
flutter clean && flutter pub get
```

### Level 2: 브랜치 롤백
```bash
# 백업 브랜치로 복원
git checkout backup/before-core-migration
git checkout -b feature/core-migration-retry
```

### Level 3: 전체 롤백
```bash
# 파일 시스템 백업 복원
rm -rf lib
cp -r lib_backup_[timestamp] lib
flutter clean && flutter pub get
```

---

## 📈 Success Criteria

### 필수 달성 목표
- ✅ Core 디렉토리 완전 제거
- ✅ 모든 import 경로 마이그레이션 완료
- ✅ 빌드 성공 (Android & iOS)
- ✅ 기존 테스트 모두 통과
- ✅ 성능 저하 없음

### 예상 결과
- 🎯 코드 구조 개선
- 🎯 의존성 명확화
- 🎯 Common/App Feature 마이그레이션 준비 완료
- 🎯 향후 유지보수 용이성 향상

---

## 🕐 Timeline Summary

| Phase | 작업 내용 | 예상 시간 | 실제 시간 |
|-------|----------|-----------|-----------|
| 0 | Pre-Migration | 20분 | ___ |
| 1 | Bridge File | 30분 | ___ |
| 2 | Import Replacement | 1시간 | ___ |
| 3 | File Distribution | 1시간 20분 | ___ |
| 4 | Validation | 30분 | ___ |
| 5 | Cleanup | 10분 | ___ |
| **Total** | **Core Migration** | **3시간 20분** | ___ |

---

## 📝 Notes & Observations

작업 중 발견한 이슈나 개선사항을 여기에 기록:

```
[ 작업 날짜: ___ ]
- 
- 
- 
```

---

*이 워크플로우는 MIGRATION_ORDER.md와 MIGRATION_SAFETY.md를 기반으로 작성되었습니다.*
*안전하고 체계적인 마이그레이션을 보장합니다.*