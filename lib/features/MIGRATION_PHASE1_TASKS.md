# 📋 Features 마이그레이션 Phase 1: 상세 작업 가이드

> **작성일**: 2025-01-09  
> **목적**: Clean Architecture 마이그레이션 Phase 1 상세 작업 문서  
> **예상 소요 시간**: 2일 (16시간)  
> **작업 유형**: 기계적 일괄 작업 (Low Risk, High Volume)

---

## 🎯 Phase 1 목표

### 작업 범위
- **빈 디렉토리 제거**: 2개 (theme/, upload/)
- **폴더명 변경**: 44개 (services → adapters)
- **레거시 import 수정**: 5개 파일
- **아키텍처 검증**: 305개 파일 전체

### 성공 기준
- ✅ 모든 services 폴더가 adapters로 변경됨
- ✅ core/repositories import 0개
- ✅ 빌드 에러 없음
- ✅ 모든 검증 스크립트 통과

---

## 📅 Day 1: 기계적 정리 작업 (8시간)

## Task 1.1: 빈 디렉토리 삭제 [30분]

### 목적
불필요한 빈 Feature 디렉토리를 제거하여 프로젝트 구조를 정리

### 사전 확인
```bash
# 현재 상태 확인
echo "=== 빈 디렉토리 확인 ==="
ls -la lib/features/theme/ 2>/dev/null || echo "theme/ not found"
ls -la lib/features/upload/ 2>/dev/null || echo "upload/ not found"

# 파일 존재 여부 재확인 (안전장치)
find lib/features/theme -type f 2>/dev/null | wc -l
find lib/features/upload -type f 2>/dev/null | wc -l
```

### 작업 실행
```bash
# Task 1.1.1: 백업 생성 (혹시 모를 상황 대비)
tar -czf backup_empty_dirs_$(date +%Y%m%d_%H%M%S).tar.gz \
  lib/features/theme \
  lib/features/upload \
  2>/dev/null || echo "Directories already removed or don't exist"

# Task 1.1.2: 디렉토리 삭제
rm -rf lib/features/theme
rm -rf lib/features/upload

# Task 1.1.3: 삭제 확인
if [ ! -d "lib/features/theme" ] && [ ! -d "lib/features/upload" ]; then
  echo "✅ 빈 디렉토리 삭제 완료"
else
  echo "❌ 디렉토리 삭제 실패"
fi
```

### 검증
```bash
# 남은 Feature 디렉토리 확인
echo "=== 활성 Feature 목록 ==="
ls -1 lib/features/ | grep -v "\.md$"
# Expected: auth, chat, notifications, posts, profile, search, voting
```

### 체크리스트
- [ ] theme/ 디렉토리 존재하지 않음
- [ ] upload/ 디렉토리 존재하지 않음
- [ ] 7개 활성 Feature만 존재
- [ ] 백업 파일 생성됨

---

## Task 1.2: Services → Adapters 일괄 변경 [3시간]

### 목적
ARCHITECTURE_RULES.md에 따라 data/services를 data/adapters로 변경

### 영향 범위
- **총 44개 디렉토리** (7개 Feature × 평균 6개 services)
- **약 150개 import 문** 수정 필요

### Task 1.2.1: 사전 분석 [30분]
```bash
# 현재 services 디렉토리 목록 생성
echo "=== Services 디렉토리 분석 ==="
SERVICES_COUNT=0
for feature in auth chat notifications posts profile search voting; do
  if [ -d "lib/features/$feature/data/services" ]; then
    echo ""
    echo "📁 $feature/data/services:"
    ls -1 lib/features/$feature/data/services/ 2>/dev/null | head -10
    count=$(ls -1 lib/features/$feature/data/services/ 2>/dev/null | wc -l)
    SERVICES_COUNT=$((SERVICES_COUNT + count))
    echo "  → $count 개 서비스"
  fi
done
echo ""
echo "총 서비스 파일: $SERVICES_COUNT 개"

# import 패턴 분석
echo ""
echo "=== Import 패턴 분석 ==="
grep -r "import.*\/data\/services\/" lib/features/ | wc -l
echo "개 import 문 수정 필요"
```

### Task 1.2.2: 마이그레이션 스크립트 실행 [2시간]
```bash
#!/bin/bash
# migrate_services_to_adapters.sh

# 실행 로그 초기화
LOG_FILE="migration_phase1_log_$(date +%Y%m%d_%H%M%S).txt"
echo "Phase 1.2: Services → Adapters Migration" > $LOG_FILE
echo "Started at: $(date)" >> $LOG_FILE
echo "---" >> $LOG_FILE

# Feature 목록
FEATURES=(
  "auth"
  "chat" 
  "notifications"
  "posts"
  "profile"
  "search"
  "voting"
)

# 마이그레이션 카운터
MIGRATED=0
FAILED=0

for feature in "${FEATURES[@]}"; do
  echo "" | tee -a $LOG_FILE
  echo "🔄 Processing $feature..." | tee -a $LOG_FILE
  
  # Task 1.2.2.1: 디렉토리 존재 확인
  if [ -d "lib/features/$feature/data/services" ]; then
    echo "  ✓ Found services directory" | tee -a $LOG_FILE
    
    # Task 1.2.2.2: 백업 생성
    cp -r "lib/features/$feature/data/services" \
          "lib/features/$feature/data/services.backup"
    
    # Task 1.2.2.3: 디렉토리 이름 변경
    mv "lib/features/$feature/data/services" \
       "lib/features/$feature/data/adapters"
    
    if [ $? -eq 0 ]; then
      echo "  ✓ Renamed services → adapters" | tee -a $LOG_FILE
      MIGRATED=$((MIGRATED + 1))
      
      # Task 1.2.2.4: Import 문 수정 - Feature 내부
      echo "  🔍 Updating imports in $feature..." | tee -a $LOG_FILE
      
      # macOS와 Linux 호환성을 위한 sed 사용
      if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        find "lib/features/$feature" -type f -name "*.dart" -exec \
          sed -i '' "s|/data/services/|/data/adapters/|g" {} \;
        find "lib/features/$feature" -type f -name "*.dart" -exec \
          sed -i '' "s|'services/|'adapters/|g" {} \;
        find "lib/features/$feature" -type f -name "*.dart" -exec \
          sed -i '' 's|"services/|"adapters/|g' {} \;
      else
        # Linux
        find "lib/features/$feature" -type f -name "*.dart" -exec \
          sed -i "s|/data/services/|/data/adapters/|g" {} \;
        find "lib/features/$feature" -type f -name "*.dart" -exec \
          sed -i "s|'services/|'adapters/|g" {} \;
        find "lib/features/$feature" -type f -name "*.dart" -exec \
          sed -i 's|"services/|"adapters/|g' {} \;
      fi
      
      # Import 수정 확인
      remaining=$(grep -r "data/services" "lib/features/$feature" | wc -l)
      if [ $remaining -eq 0 ]; then
        echo "  ✅ All imports updated successfully" | tee -a $LOG_FILE
      else
        echo "  ⚠️  Warning: $remaining imports may need manual review" | tee -a $LOG_FILE
      fi
      
    else
      echo "  ❌ Failed to rename directory" | tee -a $LOG_FILE
      FAILED=$((FAILED + 1))
    fi
  else
    echo "  ℹ️  No services directory found (already migrated?)" | tee -a $LOG_FILE
  fi
done

# Task 1.2.2.5: 전역 import 수정 (다른 Feature에서 참조하는 경우)
echo "" | tee -a $LOG_FILE
echo "🔍 Checking for cross-feature service imports..." | tee -a $LOG_FILE
grep -r "import.*\/features\/.*\/data\/services\/" lib/ | while read -r line; do
  file=$(echo $line | cut -d: -f1)
  echo "  Fixing: $file" | tee -a $LOG_FILE
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|/data/services/|/data/adapters/|g" "$file"
  else
    sed -i "s|/data/services/|/data/adapters/|g" "$file"
  fi
done

# 결과 요약
echo "" | tee -a $LOG_FILE
echo "=== Migration Summary ===" | tee -a $LOG_FILE
echo "✅ Migrated: $MIGRATED features" | tee -a $LOG_FILE
echo "❌ Failed: $FAILED features" | tee -a $LOG_FILE
echo "Completed at: $(date)" | tee -a $LOG_FILE
```

### Task 1.2.3: 마이그레이션 검증 [30분]
```bash
# 검증 스크립트
echo "=== Services → Adapters 마이그레이션 검증 ==="

# 1. services 디렉토리가 남아있는지 확인
echo ""
echo "1. Checking for remaining services directories:"
find lib/features -type d -name "services" | grep -v backup
if [ $? -ne 0 ]; then
  echo "  ✅ No services directories found"
else
  echo "  ❌ Services directories still exist!"
fi

# 2. adapters 디렉토리 존재 확인
echo ""
echo "2. Verifying adapters directories:"
for feature in auth chat notifications posts profile search voting; do
  if [ -d "lib/features/$feature/data/adapters" ]; then
    count=$(ls -1 lib/features/$feature/data/adapters/*.dart 2>/dev/null | wc -l)
    echo "  ✅ $feature: $count adapter files"
  else
    echo "  ⚠️  $feature: No adapters directory"
  fi
done

# 3. Import 문 검증
echo ""
echo "3. Checking for remaining service imports:"
SERVICE_IMPORTS=$(grep -r "\/data\/services\/" lib/features/ | grep -v backup | wc -l)
echo "  Remaining service imports: $SERVICE_IMPORTS"
if [ $SERVICE_IMPORTS -eq 0 ]; then
  echo "  ✅ All imports updated successfully"
else
  echo "  ❌ Some imports need manual update:"
  grep -r "\/data\/services\/" lib/features/ | grep -v backup | head -5
fi

# 4. 빌드 테스트
echo ""
echo "4. Running build test:"
flutter analyze --no-fatal-infos --no-fatal-warnings 2>&1 | grep -E "(error|Error)" | head -10
```

### 롤백 절차 (필요시)
```bash
# 백업에서 복원
for feature in auth chat notifications posts profile search voting; do
  if [ -d "lib/features/$feature/data/services.backup" ]; then
    rm -rf "lib/features/$feature/data/adapters"
    mv "lib/features/$feature/data/services.backup" \
       "lib/features/$feature/data/services"
    echo "Rolled back $feature"
  fi
done
```

---

## Task 1.3: 레거시 의존성 수정 [1시간 30분]

### 목적
core/repositories에 대한 레거시 의존성을 제거하고 domain/repositories 사용

### 영향 범위
- **5개 파일** 직접 수정
- **약 15개 import 문** 변경

### Task 1.3.1: 현재 상태 분석 [15분]
```bash
# 레거시 의존성 파일 목록
echo "=== 레거시 core/repositories 의존성 분석 ==="
echo ""

FILES=(
  "lib/features/chat/data/repositories/chat_repository_impl.dart"
  "lib/features/notifications/data/repositories/notification_repository_impl.dart"
  "lib/features/notifications/data/adapters/notification_service.dart"  # services → adapters 변경 후
  "lib/features/search/data/repositories/search_repository_impl.dart"
  "lib/features/voting/data/repositories/voting_repository_impl.dart"
)

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "📄 $file:"
    grep "import.*\/core\/repositories\/" "$file" | head -5
    echo ""
  else
    # services → adapters 마이그레이션 후 경로
    alt_file="${file/\/services\//\/adapters\/}"
    if [ -f "$alt_file" ]; then
      echo "📄 $alt_file (경로 변경됨):"
      grep "import.*\/core\/repositories\/" "$alt_file" | head -5
      echo ""
    fi
  fi
done
```

### Task 1.3.2: Import 문 수정 [45분]
```bash
#!/bin/bash
# fix_legacy_imports.sh

LOG_FILE="legacy_import_fix_$(date +%Y%m%d_%H%M%S).txt"
echo "Task 1.3: Legacy Import Fix" > $LOG_FILE
echo "Started at: $(date)" >> $LOG_FILE

# 수정할 파일 목록 (adapters 경로 포함)
FILES=(
  "lib/features/chat/data/repositories/chat_repository_impl.dart"
  "lib/features/notifications/data/repositories/notification_repository_impl.dart"
  "lib/features/notifications/data/adapters/notification_service.dart"
  "lib/features/search/data/repositories/search_repository_impl.dart"
  "lib/features/voting/data/repositories/voting_repository_impl.dart"
)

# Feature별 매핑 테이블
declare -A FEATURE_MAP
FEATURE_MAP["chat"]="i_chat_repository"
FEATURE_MAP["notifications"]="i_notification_repository"
FEATURE_MAP["search"]="i_search_repository"
FEATURE_MAP["voting"]="i_voting_repository"

for file in "${FILES[@]}"; do
  echo "" | tee -a $LOG_FILE
  echo "🔧 Processing: $file" | tee -a $LOG_FILE
  
  if [ ! -f "$file" ]; then
    echo "  ⚠️  File not found, checking alternate path..." | tee -a $LOG_FILE
    # services → adapters 변경 확인
    alt_file="${file/\/services\//\/adapters\/}"
    if [ -f "$alt_file" ]; then
      file="$alt_file"
      echo "  ✓ Found at: $file" | tee -a $LOG_FILE
    else
      echo "  ❌ File not found!" | tee -a $LOG_FILE
      continue
    fi
  fi
  
  # Task 1.3.2.1: 백업 생성
  cp "$file" "${file}.legacy_backup"
  
  # Task 1.3.2.2: Feature 식별
  feature=$(echo "$file" | sed 's/.*features\/\([^\/]*\)\/.*/\1/')
  echo "  Feature: $feature" | tee -a $LOG_FILE
  
  # Task 1.3.2.3: Import 수정
  # Pattern 1: /core/repositories/xxx_repository.dart
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s|import '/core/repositories/\(.*\)\.dart';|import '../../domain/repositories/i_\1.dart';|g" "$file"
    sed -i '' "s|import '/core/repositories/|import '../../domain/repositories/|g" "$file"
    
    # Pattern 2: package imports
    sed -i '' "s|import 'package:versus_space/core/repositories/|import 'package:versus_space/features/${feature}/domain/repositories/|g" "$file"
  else
    # Linux
    sed -i "s|import '/core/repositories/\(.*\)\.dart';|import '../../domain/repositories/i_\1.dart';|g" "$file"
    sed -i "s|import '/core/repositories/|import '../../domain/repositories/|g" "$file"
    sed -i "s|import 'package:versus_space/core/repositories/|import 'package:versus_space/features/${feature}/domain/repositories/|g" "$file"
  fi
  
  # Task 1.3.2.4: 변경 확인
  remaining=$(grep -c "\/core\/repositories\/" "$file")
  if [ $remaining -eq 0 ]; then
    echo "  ✅ Successfully fixed all imports" | tee -a $LOG_FILE
  else
    echo "  ⚠️  $remaining imports may need manual review" | tee -a $LOG_FILE
    grep "\/core\/repositories\/" "$file" | tee -a $LOG_FILE
  fi
done

echo "" | tee -a $LOG_FILE
echo "Completed at: $(date)" | tee -a $LOG_FILE
```

### Task 1.3.3: 수정 검증 [30분]
```bash
# 검증 스크립트
echo "=== 레거시 Import 수정 검증 ==="

# 1. core/repositories import 확인
echo ""
echo "1. Checking for remaining core/repositories imports:"
LEGACY_COUNT=$(grep -r "\/core\/repositories\/" lib/features/ | grep -v backup | wc -l)
echo "  Found: $LEGACY_COUNT legacy imports"

if [ $LEGACY_COUNT -eq 0 ]; then
  echo "  ✅ All legacy imports removed"
else
  echo "  ❌ Legacy imports still exist:"
  grep -r "\/core\/repositories\/" lib/features/ | grep -v backup
fi

# 2. Domain repositories import 확인
echo ""
echo "2. Verifying domain repository imports:"
for feature in chat notifications search voting; do
  echo "  Checking $feature..."
  grep -h "import.*domain/repositories" lib/features/$feature/data/repositories/*.dart 2>/dev/null | head -2
done

# 3. 컴파일 테스트
echo ""
echo "3. Compilation test:"
flutter analyze lib/features/chat/data/repositories/chat_repository_impl.dart 2>&1 | grep -E "(error|Error)" | head -5
```

---

## 📅 Day 2: 의존성 검증 및 준비 (8시간)

## Task 2.1: 아키텍처 위반 검사 [4시간]

### 목적
현재 아키텍처 위반 사항을 정확히 파악하고 문서화

### Task 2.1.1: Presentation → Data 직접 접근 검사 [1시간 30분]
```bash
#!/bin/bash
# check_presentation_data_violations.sh

OUTPUT_FILE="presentation_data_violations.txt"
echo "=== Presentation → Data Direct Access Violations ===" > $OUTPUT_FILE
echo "Generated: $(date)" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

TOTAL_VIOLATIONS=0

for feature in auth chat notifications posts profile search voting; do
  echo "📁 Feature: $feature" | tee -a $OUTPUT_FILE
  echo "---" >> $OUTPUT_FILE
  
  # Presentation 파일 목록
  PRESENTATION_FILES=$(find lib/features/$feature/presentation -name "*.dart" 2>/dev/null)
  
  for pres_file in $PRESENTATION_FILES; do
    # Data layer import 검사
    violations=$(grep -n "import.*\/data\/" "$pres_file" 2>/dev/null)
    
    if [ ! -z "$violations" ]; then
      echo "  ❌ $(basename $pres_file):" >> $OUTPUT_FILE
      echo "$violations" | while IFS= read -r line; do
        echo "    Line $line" >> $OUTPUT_FILE
        TOTAL_VIOLATIONS=$((TOTAL_VIOLATIONS + 1))
      done
      echo "" >> $OUTPUT_FILE
    fi
  done
  
  # Feature 요약
  feature_count=$(grep -r "import.*\/$feature\/data\/" lib/features/$feature/presentation 2>/dev/null | wc -l)
  echo "  Total violations in $feature: $feature_count" | tee -a $OUTPUT_FILE
  echo "" >> $OUTPUT_FILE
done

echo "=== SUMMARY ===" | tee -a $OUTPUT_FILE
echo "Total Presentation → Data violations: $TOTAL_VIOLATIONS" | tee -a $OUTPUT_FILE

# 위반 파일 목록 생성
echo "" >> $OUTPUT_FILE
echo "=== Files to Fix ===" >> $OUTPUT_FILE
grep -r "import.*\/data\/" lib/features/*/presentation --include="*.dart" | cut -d: -f1 | sort -u >> $OUTPUT_FILE
```

### Task 2.1.2: Data → Presentation 역방향 의존성 검사 [1시간]
```bash
#!/bin/bash
# check_data_presentation_violations.sh

OUTPUT_FILE="data_presentation_violations.txt"
echo "=== Data → Presentation Reverse Dependencies ===" > $OUTPUT_FILE
echo "Generated: $(date)" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

for feature in auth chat notifications posts profile search voting; do
  echo "📁 Feature: $feature" >> $OUTPUT_FILE
  
  # Data 레이어 파일에서 Presentation import 검사
  violations=$(grep -r "import.*\/presentation\/" lib/features/$feature/data 2>/dev/null)
  
  if [ ! -z "$violations" ]; then
    echo "$violations" | while IFS= read -r line; do
      file=$(echo $line | cut -d: -f1)
      import=$(echo $line | cut -d: -f2-)
      echo "  ❌ $(basename $file)" >> $OUTPUT_FILE
      echo "     $import" >> $OUTPUT_FILE
    done
  else
    echo "  ✅ No violations" >> $OUTPUT_FILE
  fi
  echo "" >> $OUTPUT_FILE
done

# 특별 주의 파일
echo "=== High Priority Files ===" >> $OUTPUT_FILE
echo "These files have complex reverse dependencies:" >> $OUTPUT_FILE
echo "  - notifications/data/adapters/global_notification_manager.dart" >> $OUTPUT_FILE
echo "  - chat/data/adapters/chat_scroll_service.dart" >> $OUTPUT_FILE
echo "  - posts/data/adapters/* (9 files with media/validation services)" >> $OUTPUT_FILE
```

### Task 2.1.3: Feature 간 의존성 검사 [1시간]
```bash
#!/bin/bash
# check_cross_feature_dependencies.sh

OUTPUT_FILE="cross_feature_dependencies.txt"
echo "=== Cross-Feature Dependencies Analysis ===" > $OUTPUT_FILE
echo "Generated: $(date)" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

FEATURES=(auth chat notifications posts profile search voting)

for source_feature in "${FEATURES[@]}"; do
  echo "📁 $source_feature dependencies:" >> $OUTPUT_FILE
  
  for target_feature in "${FEATURES[@]}"; do
    if [ "$source_feature" != "$target_feature" ]; then
      # source_feature가 target_feature를 import하는지 검사
      count=$(grep -r "import.*\/features\/$target_feature\/" lib/features/$source_feature 2>/dev/null | wc -l)
      
      if [ $count -gt 0 ]; then
        echo "  ❌ Depends on $target_feature ($count imports)" >> $OUTPUT_FILE
        # 상세 내용 (처음 3개만)
        grep -r "import.*\/features\/$target_feature\/" lib/features/$source_feature 2>/dev/null | head -3 | while IFS= read -r line; do
          file=$(echo $line | cut -d: -f1 | sed "s|lib/features/$source_feature/||")
          echo "     - $file" >> $OUTPUT_FILE
        done
      fi
    fi
  done
  
  # Feature가 독립적인지 확인
  total_deps=$(grep -r "import.*\/features\/[^$source_feature]\/" lib/features/$source_feature 2>/dev/null | wc -l)
  if [ $total_deps -eq 0 ]; then
    echo "  ✅ No cross-feature dependencies" >> $OUTPUT_FILE
  fi
  echo "" >> $OUTPUT_FILE
done

# 요약 통계
echo "=== Summary ===" >> $OUTPUT_FILE
for feature in "${FEATURES[@]}"; do
  deps=$(grep -r "import.*\/features\/[^$feature]\/" lib/features/$feature 2>/dev/null | wc -l)
  echo "$feature: $deps cross-feature imports" >> $OUTPUT_FILE
done
```

### Task 2.1.4: 종합 보고서 생성 [30분]
```bash
#!/bin/bash
# generate_violation_report.sh

REPORT_FILE="architecture_violations_report.md"

echo "# 📊 Architecture Violations Report" > $REPORT_FILE
echo "" >> $REPORT_FILE
echo "Generated: $(date)" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 1. Executive Summary
echo "## Executive Summary" >> $REPORT_FILE
echo "" >> $REPORT_FILE

PRES_DATA=$(grep -r "import.*\/data\/" lib/features/*/presentation 2>/dev/null | wc -l)
DATA_PRES=$(grep -r "import.*\/presentation\/" lib/features/*/data 2>/dev/null | wc -l)
CROSS_FEAT=$(grep -r "import.*\/features\/.*\/" lib/features 2>/dev/null | grep -v "\/domain\/" | wc -l)
LEGACY=$(grep -r "\/core\/repositories\/" lib/features 2>/dev/null | wc -l)

echo "| Violation Type | Count | Severity |" >> $REPORT_FILE
echo "|---------------|-------|----------|" >> $REPORT_FILE
echo "| Presentation → Data | $PRES_DATA | 🔴 High |" >> $REPORT_FILE
echo "| Data → Presentation | $DATA_PRES | 🔴 High |" >> $REPORT_FILE
echo "| Cross-Feature Dependencies | $CROSS_FEAT | 🟡 Medium |" >> $REPORT_FILE
echo "| Legacy core/repositories | $LEGACY | 🔴 High |" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# 2. Feature Breakdown
echo "## Feature Breakdown" >> $REPORT_FILE
echo "" >> $REPORT_FILE

for feature in auth chat notifications posts profile search voting; do
  echo "### $feature" >> $REPORT_FILE
  p_d=$(grep -r "import.*\/data\/" lib/features/$feature/presentation 2>/dev/null | wc -l)
  d_p=$(grep -r "import.*\/presentation\/" lib/features/$feature/data 2>/dev/null | wc -l)
  echo "- Presentation → Data: $p_d violations" >> $REPORT_FILE
  echo "- Data → Presentation: $d_p violations" >> $REPORT_FILE
  echo "" >> $REPORT_FILE
done

# 3. Action Items
echo "## Action Items" >> $REPORT_FILE
echo "" >> $REPORT_FILE
echo "1. **Immediate** (Phase 1 - Current):" >> $REPORT_FILE
echo "   - ✅ Remove empty directories (theme/, upload/)" >> $REPORT_FILE
echo "   - ✅ Rename services → adapters" >> $REPORT_FILE
echo "   - ✅ Fix legacy core/repositories imports" >> $REPORT_FILE
echo "" >> $REPORT_FILE
echo "2. **Next** (Phase 2):" >> $REPORT_FILE
echo "   - Create missing repository interfaces" >> $REPORT_FILE
echo "   - Implement DI for all features" >> $REPORT_FILE
echo "   - Fix Presentation → Data violations" >> $REPORT_FILE
echo "   - Resolve Data → Presentation dependencies" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "Report saved to: $REPORT_FILE"
```

---

## Task 2.2: Repository 인터페이스 검증 [4시간]

### 목적
각 Feature의 Repository 인터페이스 현황을 파악하고 누락된 인터페이스 목록 작성

### Task 2.2.1: Repository 인터페이스 현황 분석 [1시간 30분]
```bash
#!/bin/bash
# analyze_repository_interfaces.sh

OUTPUT_FILE="repository_interfaces_status.md"

echo "# Repository Interfaces Status" > $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
echo "Generated: $(date)" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

echo "## Current Status" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

for feature in auth chat notifications posts profile search voting; do
  echo "### $feature" >> $OUTPUT_FILE
  echo "" >> $OUTPUT_FILE
  
  # Domain repositories 확인
  echo "**Domain Layer (Interfaces):**" >> $OUTPUT_FILE
  if [ -d "lib/features/$feature/domain/repositories" ]; then
    interfaces=$(find lib/features/$feature/domain/repositories -name "*.dart" 2>/dev/null)
    if [ ! -z "$interfaces" ]; then
      echo "$interfaces" | while IFS= read -r file; do
        basename=$(basename "$file")
        # Interface naming convention check
        if [[ $basename == i_* ]] || [[ $basename == *_repository.dart ]]; then
          echo "- ✅ $basename" >> $OUTPUT_FILE
        else
          echo "- ⚠️  $basename (non-standard naming)" >> $OUTPUT_FILE
        fi
      done
    else
      echo "- ❌ No interfaces found" >> $OUTPUT_FILE
    fi
  else
    echo "- ❌ repositories directory missing" >> $OUTPUT_FILE
  fi
  echo "" >> $OUTPUT_FILE
  
  # Data implementations 확인
  echo "**Data Layer (Implementations):**" >> $OUTPUT_FILE
  if [ -d "lib/features/$feature/data/repositories" ]; then
    implementations=$(find lib/features/$feature/data/repositories -name "*_impl.dart" -o -name "*_repository.dart" 2>/dev/null)
    if [ ! -z "$implementations" ]; then
      echo "$implementations" | while IFS= read -r file; do
        echo "- $(basename $file)" >> $OUTPUT_FILE
      done
    else
      echo "- ⚠️  No implementations found" >> $OUTPUT_FILE
    fi
  else
    echo "- ❌ repositories directory missing" >> $OUTPUT_FILE
  fi
  echo "" >> $OUTPUT_FILE
done

# Summary
echo "## Summary" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE
echo "| Feature | Has Interface | Has Implementation | Status |" >> $OUTPUT_FILE
echo "|---------|--------------|-------------------|--------|" >> $OUTPUT_FILE

for feature in auth chat notifications posts profile search voting; do
  has_interface="❌"
  has_impl="❌"
  status="🔴 Missing"
  
  if [ -f "lib/features/$feature/domain/repositories/i_${feature}_repository.dart" ] || \
     [ -f "lib/features/$feature/domain/repositories/${feature}_repository.dart" ]; then
    has_interface="✅"
  fi
  
  if [ -f "lib/features/$feature/data/repositories/${feature}_repository_impl.dart" ]; then
    has_impl="✅"
  fi
  
  if [ "$has_interface" == "✅" ] && [ "$has_impl" == "✅" ]; then
    status="🟢 Complete"
  elif [ "$has_interface" == "✅" ] || [ "$has_impl" == "✅" ]; then
    status="🟡 Partial"
  fi
  
  echo "| $feature | $has_interface | $has_impl | $status |" >> $OUTPUT_FILE
done
```

### Task 2.2.2: 누락 인터페이스 템플릿 생성 [1시간 30분]
```bash
#!/bin/bash
# generate_missing_interfaces.sh

TEMPLATE_DIR="repository_interface_templates"
mkdir -p $TEMPLATE_DIR

# Task 2.2.2.1: notifications interface template
if [ ! -f "lib/features/notifications/domain/repositories/i_notification_repository.dart" ]; then
  cat > "$TEMPLATE_DIR/i_notification_repository.dart" << 'EOF'
import 'package:dartz/dartz.dart';
import '../models/notification_model.dart';
import '../models/notifications_model.dart';

/// Repository interface for notification operations
/// Following Clean Architecture principles - no implementation details
abstract class INotificationRepository {
  /// Get all notifications for a user
  Future<Either<String, List<NotificationModel>>> getNotifications(String userId);
  
  /// Get notifications with pagination
  Future<Either<String, List<NotificationModel>>> getNotificationsPaginated({
    required String userId,
    required int limit,
    DateTime? lastTimestamp,
  });
  
  /// Mark notification as read
  Future<Either<String, void>> markAsRead(String notificationId);
  
  /// Mark all notifications as read
  Future<Either<String, void>> markAllAsRead(String userId);
  
  /// Delete a notification
  Future<Either<String, void>> deleteNotification(String notificationId);
  
  /// Send notification to user(s)
  Future<Either<String, void>> sendNotification({
    required NotificationModel notification,
    required List<String> targetUserIds,
  });
  
  /// Get unread notification count
  Stream<int> getUnreadCount(String userId);
  
  /// Listen to notifications stream
  Stream<List<NotificationModel>> notificationsStream(String userId);
}
EOF
  echo "✅ Generated notifications interface template"
fi

# Task 2.2.2.2: voting interface template
if [ ! -f "lib/features/voting/domain/repositories/i_voting_repository.dart" ]; then
  cat > "$TEMPLATE_DIR/i_voting_repository.dart" << 'EOF'
import 'package:dartz/dartz.dart';
import '../models/votes_model.dart';
import '../models/vote_state.dart';
import '../models/votecounts_model.dart';
import '../models/rankings_model.dart';

/// Repository interface for voting operations
abstract class IVotingRepository {
  /// Submit a vote for a post
  Future<Either<String, void>> submitVote({
    required String postId,
    required String userId,
    required VoteOption option,
  });
  
  /// Get voting statistics for a post
  Future<Either<String, VoteCountsModel>> getVotingStats(String postId);
  
  /// Get user's voting history
  Future<Either<String, List<VotesModel>>> getUserVotes(String userId);
  
  /// Check if user has voted on a post
  Future<Either<String, VoteState?>> getUserVoteState({
    required String postId,
    required String userId,
  });
  
  /// Get ranked posts by votes
  Future<Either<String, List<RankingsModel>>> getRankedPosts({
    required int limit,
    DateTime? since,
  });
  
  /// Listen to voting updates for a post
  Stream<VoteCountsModel> votingUpdatesStream(String postId);
  
  /// Delete a vote
  Future<Either<String, void>> deleteVote({
    required String postId,
    required String userId,
  });
}
EOF
  echo "✅ Generated voting interface template"
fi

# Task 2.2.2.3: Generate interface checker
cat > "$TEMPLATE_DIR/check_interfaces.sh" << 'EOF'
#!/bin/bash
# Check which interfaces need to be created

echo "=== Repository Interfaces Checklist ==="
echo ""

FEATURES=(auth chat notifications posts profile search voting)

for feature in "${FEATURES[@]}"; do
  interface_file="lib/features/$feature/domain/repositories/i_${feature}_repository.dart"
  
  if [ -f "$interface_file" ]; then
    echo "✅ $feature: Interface exists"
  else
    echo "❌ $feature: Interface missing - use template from repository_interface_templates/"
  fi
done
EOF

chmod +x "$TEMPLATE_DIR/check_interfaces.sh"
```

### Task 2.2.3: DI 모듈 준비 [1시간]
```bash
#!/bin/bash
# prepare_di_modules.sh

DI_TEMPLATE_DIR="di_module_templates"
mkdir -p $DI_TEMPLATE_DIR

# Generate DI module template for each feature
for feature in auth chat notifications posts profile search voting; do
  cat > "$DI_TEMPLATE_DIR/${feature}_module.dart" << EOF
import 'package:get_it/get_it.dart';
import 'package:versus_space/features/$feature/domain/repositories/i_${feature}_repository.dart';
import 'package:versus_space/features/$feature/data/repositories/${feature}_repository_impl.dart';

/// Dependency injection module for $feature feature
class ${feature^}Module {
  static void configure(GetIt getIt) {
    // Register repository
    getIt.registerLazySingleton<I${feature^}Repository>(
      () => ${feature^}RepositoryImpl(
        // Add dependencies here
        // remoteDataSource: getIt(),
        // localDataSource: getIt(),
      ),
    );
    
    // Register use cases (if any)
    // getIt.registerFactory(() => Get${feature^}UseCase(getIt()));
    
    // Register providers/controllers (if using Provider or Riverpod)
    // Add provider registrations here
  }
  
  /// Clean up resources if needed
  static void dispose() {
    // Add cleanup logic if necessary
  }
}
EOF
  echo "✅ Generated DI module template for $feature"
done

# Generate main DI configuration
cat > "$DI_TEMPLATE_DIR/injection_config.dart" << 'EOF'
import 'package:get_it/get_it.dart';
import 'auth_module.dart';
import 'chat_module.dart';
import 'notifications_module.dart';
import 'posts_module.dart';
import 'profile_module.dart';
import 'search_module.dart';
import 'voting_module.dart';

final getIt = GetIt.instance;

/// Configure all dependency injection
Future<void> configureDependencies() async {
  // Core services (from app layer)
  // TODO: Register core services
  
  // Feature modules
  AuthModule.configure(getIt);
  ChatModule.configure(getIt);
  NotificationsModule.configure(getIt);
  PostsModule.configure(getIt);
  ProfileModule.configure(getIt);
  SearchModule.configure(getIt);
  VotingModule.configure(getIt);
  
  // Ensure all singletons are created
  await getIt.allReady();
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await getIt.reset();
}
EOF

echo ""
echo "✅ DI module templates generated in $DI_TEMPLATE_DIR/"
```

---

## 🔍 검증 체크리스트

### Phase 1 Day 1 완료 기준
- [ ] theme/, upload/ 디렉토리 삭제 완료
- [ ] 모든 services 폴더가 adapters로 변경됨
- [ ] 모든 service import가 adapter import로 변경됨
- [ ] 레거시 core/repositories import 제거 완료
- [ ] 백업 파일 생성됨
- [ ] 마이그레이션 로그 파일 생성됨

### Phase 1 Day 2 완료 기준
- [ ] 아키텍처 위반 보고서 생성
- [ ] Repository 인터페이스 현황 문서화
- [ ] 누락 인터페이스 템플릿 생성
- [ ] DI 모듈 템플릿 준비
- [ ] Phase 2 작업 목록 확정

### 빌드 및 테스트
```bash
# 최종 검증
echo "=== Phase 1 Final Validation ==="

# 1. 구조 검증
echo "1. Directory structure:"
ls -1 lib/features/ | grep -E "^(auth|chat|notifications|posts|profile|search|voting)$" | wc -l
echo "  Expected: 7 features"

# 2. Services 폴더 확인
echo "2. Services directories:"
find lib/features -type d -name "services" | grep -v backup | wc -l
echo "  Expected: 0"

# 3. Adapters 폴더 확인
echo "3. Adapters directories:"
find lib/features -type d -name "adapters" | wc -l
echo "  Expected: 7+"

# 4. Legacy imports
echo "4. Legacy imports:"
grep -r "\/core\/repositories\/" lib/features | grep -v backup | wc -l
echo "  Expected: 0"

# 5. Build test
echo "5. Build test:"
flutter pub get
flutter analyze --no-fatal-infos
```

---

## 📊 예상 결과

### 작업 완료 후 상태
| 항목 | Before | After |
|------|--------|-------|
| 빈 디렉토리 | 2개 | 0개 |
| services 폴더 | 44개 | 0개 |
| adapters 폴더 | 0개 | 44개 |
| 레거시 import | 5개+ | 0개 |
| 아키텍처 위반 문서화 | 없음 | 완료 |

### 생성된 산출물
1. `migration_phase1_log_*.txt` - 마이그레이션 로그
2. `architecture_violations_report.md` - 위반 사항 보고서
3. `repository_interfaces_status.md` - Repository 현황
4. `repository_interface_templates/` - 인터페이스 템플릿
5. `di_module_templates/` - DI 모듈 템플릿

---

## 🚨 트러블슈팅 가이드

### 문제 1: sed 명령어 오류 (macOS)
```bash
# macOS에서는 -i 옵션 뒤에 ''가 필요
sed -i '' "s/old/new/g" file.txt  # macOS
sed -i "s/old/new/g" file.txt     # Linux
```

### 문제 2: Import 수정 후 빌드 실패
```bash
# 1. 캐시 정리
flutter clean
flutter pub get

# 2. 수동으로 import 확인
find lib/features -name "*.dart" -exec grep -l "data/services" {} \;

# 3. 백업에서 복원 (필요시)
find . -name "*.backup" -exec bash -c 'mv "$0" "${0%.backup}"' {} \;
```

### 문제 3: Repository 인터페이스 누락
```bash
# Phase 2에서 처리 예정이지만 긴급시:
# 1. 템플릿 복사
cp repository_interface_templates/i_*.dart lib/features/*/domain/repositories/

# 2. 수동 수정
# 각 Feature에 맞게 메서드 조정
```

---

**작성자**: SuperClaude with Refactorer & Analyzer Personas  
**Phase 1 예상 완료**: 2일 (16시간)  
**다음 단계**: Phase 2 - Feature별 마이그레이션