# ✅ Phase 1 마이그레이션 체크포인트 가이드

> **작성일**: 2025-01-09  
> **목적**: Phase 1 각 작업의 완료 여부를 검증하는 체크포인트 문서  
> **사용법**: 각 작업 완료 후 해당 체크포인트를 실행하여 검증

---

## 🎯 Phase 1 전체 진행상황 추적

```bash
#!/bin/bash
# phase1_progress_tracker.sh

echo "======================================"
echo "   Phase 1 Migration Progress        "
echo "======================================"
echo ""

# 전체 진행률 계산
TOTAL_TASKS=12  # 세부 작업 총 개수
COMPLETED=0

# 각 체크포인트 확인 함수
check_task() {
    local task_name=$1
    local check_command=$2
    local expected=$3
    local actual=$(eval $check_command)
    
    if [ "$actual" == "$expected" ]; then
        echo "✅ $task_name"
        return 1
    else
        echo "❌ $task_name (Expected: $expected, Got: $actual)"
        return 0
    fi
}

# 체크포인트 실행
echo "📋 Task 1.1: 빈 디렉토리 삭제"
check_task "1.1.1 theme/ 삭제" "[ -d lib/features/theme ] && echo 'exists' || echo 'removed'" "removed"
COMPLETED=$((COMPLETED + $?))
check_task "1.1.2 upload/ 삭제" "[ -d lib/features/upload ] && echo 'exists' || echo 'removed'" "removed"
COMPLETED=$((COMPLETED + $?))

echo ""
echo "📋 Task 1.2: Services → Adapters"
check_task "1.2.1 services 폴더 제거" "find lib/features -type d -name 'services' | grep -v backup | wc -l | tr -d ' '" "0"
COMPLETED=$((COMPLETED + $?))
check_task "1.2.2 adapters 폴더 생성" "find lib/features -type d -name 'adapters' | wc -l | tr -d ' '" "7"
COMPLETED=$((COMPLETED + $?))

echo ""
echo "📋 Task 1.3: 레거시 의존성"
check_task "1.3.1 core/repositories 제거" "grep -r '/core/repositories/' lib/features | grep -v backup | wc -l | tr -d ' '" "0"
COMPLETED=$((COMPLETED + $?))

# 진행률 표시
PERCENTAGE=$((COMPLETED * 100 / TOTAL_TASKS))
echo ""
echo "======================================"
echo "진행률: $COMPLETED/$TOTAL_TASKS ($PERCENTAGE%)"
echo "======================================"
```

---

## 📅 Day 1: 기계적 정리 작업 체크포인트

## ✅ Task 1.1: 빈 디렉토리 삭제 체크포인트

### 체크포인트 1.1.1: 사전 상태 확인
```bash
# CP-1.1.1: 삭제 대상 디렉토리 확인
echo "=== Checkpoint 1.1.1: 사전 상태 확인 ==="
echo ""

# 검증 항목
echo "1. theme/ 디렉토리 상태:"
if [ -d "lib/features/theme" ]; then
    FILE_COUNT=$(find lib/features/theme -type f 2>/dev/null | wc -l)
    echo "   ⚠️  EXISTS - Files: $FILE_COUNT"
    if [ $FILE_COUNT -gt 0 ]; then
        echo "   ❌ FAIL: 디렉토리에 파일이 있습니다. 확인 필요!"
        find lib/features/theme -type f | head -5
    else
        echo "   ✅ PASS: 빈 디렉토리, 삭제 가능"
    fi
else
    echo "   ✅ ALREADY REMOVED"
fi

echo ""
echo "2. upload/ 디렉토리 상태:"
if [ -d "lib/features/upload" ]; then
    FILE_COUNT=$(find lib/features/upload -type f 2>/dev/null | wc -l)
    echo "   ⚠️  EXISTS - Files: $FILE_COUNT"
    if [ $FILE_COUNT -gt 0 ]; then
        echo "   ❌ FAIL: 디렉토리에 파일이 있습니다. 확인 필요!"
        find lib/features/upload -type f | head -5
    else
        echo "   ✅ PASS: 빈 디렉토리, 삭제 가능"
    fi
else
    echo "   ✅ ALREADY REMOVED"
fi

# 체크포인트 통과 조건
echo ""
echo "🎯 통과 기준:"
echo "  - 두 디렉토리가 비어있거나 이미 삭제됨"
echo "  - 중요 파일이 없음 확인"
```

### 체크포인트 1.1.2: 백업 생성 확인
```bash
# CP-1.1.2: 백업 파일 존재 확인
echo "=== Checkpoint 1.1.2: 백업 생성 확인 ==="
echo ""

BACKUP_FILES=$(ls -la backup_empty_dirs_*.tar.gz 2>/dev/null | wc -l)

if [ $BACKUP_FILES -gt 0 ]; then
    echo "✅ PASS: 백업 파일 발견 ($BACKUP_FILES 개)"
    ls -lh backup_empty_dirs_*.tar.gz | tail -1
    
    # 백업 내용 확인
    echo ""
    echo "백업 파일 내용:"
    tar -tzf $(ls -t backup_empty_dirs_*.tar.gz | head -1) 2>/dev/null | head -10
else
    echo "⚠️  WARNING: 백업 파일 없음"
    echo "   디렉토리가 이미 삭제되었거나 백업 생성 실패"
fi

# 체크포인트 통과 조건
echo ""
echo "🎯 통과 기준:"
echo "  - 백업 파일이 존재하거나"
echo "  - 디렉토리가 이미 삭제되어 백업 불필요"
```

### 체크포인트 1.1.3: 삭제 완료 확인
```bash
# CP-1.1.3: 디렉토리 삭제 검증
echo "=== Checkpoint 1.1.3: 삭제 완료 확인 ==="
echo ""

PASS_COUNT=0
FAIL_COUNT=0

# theme/ 확인
if [ ! -d "lib/features/theme" ]; then
    echo "✅ PASS: theme/ 디렉토리 삭제됨"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "❌ FAIL: theme/ 디렉토리 여전히 존재"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# upload/ 확인
if [ ! -d "lib/features/upload" ]; then
    echo "✅ PASS: upload/ 디렉토리 삭제됨"
    PASS_COUNT=$((PASS_COUNT + 1))
else
    echo "❌ FAIL: upload/ 디렉토리 여전히 존재"
    FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Feature 디렉토리 개수 확인
FEATURE_COUNT=$(ls -d lib/features/*/ 2>/dev/null | grep -v "\.md" | wc -l)
echo ""
echo "현재 Feature 디렉토리 수: $FEATURE_COUNT"

if [ $FEATURE_COUNT -eq 7 ]; then
    echo "✅ PASS: 정확히 7개 Feature 존재"
    ls -1 lib/features/ | grep -v "\.md$"
else
    echo "⚠️  WARNING: Feature 수가 7개가 아님 ($FEATURE_COUNT)"
fi

# 최종 결과
echo ""
echo "======================================"
if [ $FAIL_COUNT -eq 0 ]; then
    echo "✅ Task 1.1 체크포인트 통과"
else
    echo "❌ Task 1.1 체크포인트 실패 ($FAIL_COUNT 항목)"
fi
echo "======================================"
```

---

## ✅ Task 1.2: Services → Adapters 체크포인트

### 체크포인트 1.2.1: 사전 분석 완료
```bash
# CP-1.2.1: Services 디렉토리 현황 파악
echo "=== Checkpoint 1.2.1: 사전 분석 ==="
echo ""

# Services 디렉토리 카운트
SERVICES_DIRS=$(find lib/features -type d -name "services" | grep -v backup | wc -l)
ADAPTERS_DIRS=$(find lib/features -type d -name "adapters" | wc -l)

echo "현재 상태:"
echo "  Services 디렉토리: $SERVICES_DIRS 개"
echo "  Adapters 디렉토리: $ADAPTERS_DIRS 개"
echo ""

# Feature별 상세 현황
for feature in auth chat notifications posts profile search voting; do
    echo -n "$feature: "
    
    if [ -d "lib/features/$feature/data/services" ]; then
        COUNT=$(ls -1 lib/features/$feature/data/services/*.dart 2>/dev/null | wc -l)
        echo "services ($COUNT files)"
    elif [ -d "lib/features/$feature/data/adapters" ]; then
        COUNT=$(ls -1 lib/features/$feature/data/adapters/*.dart 2>/dev/null | wc -l)
        echo "adapters ✅ ($COUNT files)"
    else
        echo "❓ no services or adapters"
    fi
done

# Import 패턴 분석
echo ""
echo "Import 패턴:"
SERVICES_IMPORTS=$(grep -r "/data/services/" lib/features 2>/dev/null | grep -v backup | wc -l)
ADAPTERS_IMPORTS=$(grep -r "/data/adapters/" lib/features 2>/dev/null | wc -l)
echo "  /data/services/ imports: $SERVICES_IMPORTS"
echo "  /data/adapters/ imports: $ADAPTERS_IMPORTS"

# 체크포인트 판정
echo ""
echo "🎯 마이그레이션 필요 여부:"
if [ $SERVICES_DIRS -gt 0 ]; then
    echo "  ⚠️  마이그레이션 필요 ($SERVICES_DIRS services 디렉토리)"
elif [ $ADAPTERS_DIRS -eq 7 ]; then
    echo "  ✅ 이미 마이그레이션 완료"
else
    echo "  ❓ 상태 확인 필요"
fi
```

### 체크포인트 1.2.2: 마이그레이션 실행 검증
```bash
# CP-1.2.2: 디렉토리 변경 확인
echo "=== Checkpoint 1.2.2: 마이그레이션 검증 ==="
echo ""

PASS_COUNT=0
FAIL_COUNT=0
FEATURES=(auth chat notifications posts profile search voting)

# 각 Feature 검증
for feature in "${FEATURES[@]}"; do
    echo "📁 $feature:"
    
    # services 디렉토리 없어야 함
    if [ ! -d "lib/features/$feature/data/services" ]; then
        echo "  ✅ services 디렉토리 없음"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "  ❌ services 디렉토리 여전히 존재!"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
    
    # adapters 디렉토리 있어야 함
    if [ -d "lib/features/$feature/data/adapters" ]; then
        FILE_COUNT=$(ls -1 lib/features/$feature/data/adapters/*.dart 2>/dev/null | wc -l)
        echo "  ✅ adapters 디렉토리 존재 ($FILE_COUNT files)"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        # data 디렉토리 자체가 없을 수도 있음
        if [ ! -d "lib/features/$feature/data" ]; then
            echo "  ℹ️  data 디렉토리 없음 (정상)"
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            echo "  ⚠️  adapters 디렉토리 없음"
        fi
    fi
done

# 백업 파일 확인
echo ""
echo "백업 파일:"
BACKUP_COUNT=$(find lib/features -name "*.backup" -type d | wc -l)
echo "  발견된 백업: $BACKUP_COUNT 개"

# 결과 요약
echo ""
echo "======================================"
echo "디렉토리 마이그레이션 결과:"
echo "  성공: $PASS_COUNT"
echo "  실패: $FAIL_COUNT"
if [ $FAIL_COUNT -eq 0 ]; then
    echo "✅ 디렉토리 구조 변경 완료"
else
    echo "❌ 일부 디렉토리 마이그레이션 실패"
fi
echo "======================================"
```

### 체크포인트 1.2.3: Import 문 수정 검증
```bash
# CP-1.2.3: Import 변경 확인
echo "=== Checkpoint 1.2.3: Import 수정 검증 ==="
echo ""

# Import 패턴 검사
echo "1. Services import 잔존 확인:"
SERVICES_IMPORTS=$(grep -r "/data/services/" lib/features 2>/dev/null | grep -v backup | grep -v "\.md")

if [ -z "$SERVICES_IMPORTS" ]; then
    echo "   ✅ PASS: services import 없음"
else
    COUNT=$(echo "$SERVICES_IMPORTS" | wc -l)
    echo "   ❌ FAIL: $COUNT 개 services import 발견"
    echo "$SERVICES_IMPORTS" | head -5
fi

echo ""
echo "2. Adapters import 확인:"
ADAPTERS_COUNT=$(grep -r "/data/adapters/" lib/features 2>/dev/null | wc -l)
echo "   Adapters import 수: $ADAPTERS_COUNT"

if [ $ADAPTERS_COUNT -gt 0 ]; then
    echo "   ✅ PASS: adapters import 사용 중"
else
    echo "   ⚠️  WARNING: adapters import 없음"
fi

echo ""
echo "3. 상대 경로 import 확인:"
RELATIVE_SERVICES=$(grep -r "'services/" lib/features 2>/dev/null | grep -v backup | wc -l)
RELATIVE_ADAPTERS=$(grep -r "'adapters/" lib/features 2>/dev/null | wc -l)

echo "   'services/' 패턴: $RELATIVE_SERVICES"
echo "   'adapters/' 패턴: $RELATIVE_ADAPTERS"

# 최종 판정
echo ""
echo "======================================"
if [ $RELATIVE_SERVICES -eq 0 ]; then
    echo "✅ Task 1.2 Import 수정 완료"
else
    echo "❌ Task 1.2 Import 수정 필요"
fi
echo "======================================"
```

---

## ✅ Task 1.3: 레거시 의존성 체크포인트

### 체크포인트 1.3.1: 대상 파일 확인
```bash
# CP-1.3.1: 레거시 의존성 파일 식별
echo "=== Checkpoint 1.3.1: 대상 파일 확인 ==="
echo ""

TARGET_FILES=(
    "lib/features/chat/data/repositories/chat_repository_impl.dart"
    "lib/features/notifications/data/repositories/notification_repository_impl.dart"
    "lib/features/notifications/data/adapters/notification_service.dart"
    "lib/features/search/data/repositories/search_repository_impl.dart"
    "lib/features/voting/data/repositories/voting_repository_impl.dart"
)

echo "레거시 의존성 검사 대상:"
for file in "${TARGET_FILES[@]}"; do
    if [ -f "$file" ]; then
        LEGACY=$(grep -c "/core/repositories/" "$file" 2>/dev/null || echo "0")
        if [ $LEGACY -gt 0 ]; then
            echo "  ❌ $file ($LEGACY legacy imports)"
        else
            echo "  ✅ $file (clean)"
        fi
    else
        # adapters로 이동했을 가능성 확인
        alt_file="${file/\/services\//\/adapters\/}"
        if [ -f "$alt_file" ]; then
            LEGACY=$(grep -c "/core/repositories/" "$alt_file" 2>/dev/null || echo "0")
            if [ $LEGACY -gt 0 ]; then
                echo "  ❌ $alt_file ($LEGACY legacy imports)"
            else
                echo "  ✅ $alt_file (clean)"
            fi
        else
            echo "  ❓ $file (not found)"
        fi
    fi
done

# 전체 스캔
echo ""
echo "전체 Features 스캔:"
TOTAL_LEGACY=$(grep -r "/core/repositories/" lib/features 2>/dev/null | grep -v backup | grep -v "\.md" | wc -l)
echo "  총 레거시 import: $TOTAL_LEGACY 개"

if [ $TOTAL_LEGACY -eq 0 ]; then
    echo "  ✅ 모든 레거시 의존성 제거됨"
else
    echo "  ❌ 레거시 의존성 남아있음"
fi
```

### 체크포인트 1.3.2: Import 수정 검증
```bash
# CP-1.3.2: Domain repositories 사용 확인
echo "=== Checkpoint 1.3.2: Domain Import 검증 ==="
echo ""

# Feature별 domain/repositories import 확인
for feature in chat notifications search voting; do
    echo "📁 $feature:"
    
    # Repository 구현 파일 찾기
    IMPL_FILE="lib/features/$feature/data/repositories/${feature}_repository_impl.dart"
    
    if [ -f "$IMPL_FILE" ]; then
        # domain/repositories import 확인
        DOMAIN_IMPORT=$(grep "domain/repositories" "$IMPL_FILE" | head -1)
        if [ ! -z "$DOMAIN_IMPORT" ]; then
            echo "  ✅ Domain import 사용"
            echo "     $DOMAIN_IMPORT"
        else
            echo "  ❌ Domain import 없음"
        fi
        
        # core/repositories import 확인
        CORE_IMPORT=$(grep "/core/repositories/" "$IMPL_FILE" | head -1)
        if [ ! -z "$CORE_IMPORT" ]; then
            echo "  ❌ 여전히 core import 사용!"
            echo "     $CORE_IMPORT"
        fi
    else
        echo "  ❓ Repository 구현 파일 없음"
    fi
done

echo ""
echo "======================================"
echo "✅ Task 1.3 체크포인트 완료 조건:"
echo "  1. core/repositories import 0개"
echo "  2. 모든 repository가 domain import 사용"
echo "======================================"
```

---

## 📅 Day 2: 검증 체크포인트

## ✅ Task 2.1: 아키텍처 위반 검사 체크포인트

### 체크포인트 2.1.1: 위반 보고서 생성 확인
```bash
# CP-2.1.1: 보고서 파일 존재 확인
echo "=== Checkpoint 2.1.1: 보고서 생성 ==="
echo ""

REPORTS=(
    "presentation_data_violations.txt"
    "data_presentation_violations.txt"
    "cross_feature_dependencies.txt"
    "architecture_violations_report.md"
)

FOUND=0
MISSING=0

for report in "${REPORTS[@]}"; do
    if [ -f "$report" ]; then
        SIZE=$(ls -lh "$report" | awk '{print $5}')
        LINES=$(wc -l < "$report")
        echo "✅ $report (${SIZE}, ${LINES} lines)"
        FOUND=$((FOUND + 1))
    else
        echo "❌ $report (missing)"
        MISSING=$((MISSING + 1))
    fi
done

echo ""
echo "보고서 상태: $FOUND/$((FOUND + MISSING)) 생성됨"

# 위반 사항 요약
if [ -f "architecture_violations_report.md" ]; then
    echo ""
    echo "📊 위반 사항 요약:"
    grep "| Presentation → Data" architecture_violations_report.md
    grep "| Data → Presentation" architecture_violations_report.md
    grep "| Cross-Feature" architecture_violations_report.md
fi
```

### 체크포인트 2.1.2: 위반 통계 검증
```bash
# CP-2.1.2: 실제 위반 수 확인
echo "=== Checkpoint 2.1.2: 위반 통계 ==="
echo ""

echo "실시간 위반 검사:"
echo ""

# Presentation → Data
P2D=$(grep -r "import.*\/data\/" lib/features/*/presentation 2>/dev/null | grep -v "\.md" | wc -l)
echo "1. Presentation → Data: $P2D violations"

# Data → Presentation  
D2P=$(grep -r "import.*\/presentation\/" lib/features/*/data 2>/dev/null | wc -l)
echo "2. Data → Presentation: $D2P violations"

# Cross-feature
CROSS=0
for source in auth chat notifications posts profile search voting; do
    for target in auth chat notifications posts profile search voting; do
        if [ "$source" != "$target" ]; then
            COUNT=$(grep -r "import.*\/features\/$target\/" lib/features/$source 2>/dev/null | wc -l)
            CROSS=$((CROSS + COUNT))
        fi
    done
done
echo "3. Cross-Feature Dependencies: $CROSS violations"

# Legacy
LEGACY=$(grep -r "/core/repositories/" lib/features 2>/dev/null | grep -v backup | wc -l)
echo "4. Legacy core/repositories: $LEGACY violations"

TOTAL=$((P2D + D2P + CROSS + LEGACY))
echo ""
echo "======================================"
echo "총 위반 사항: $TOTAL"
echo "======================================"
```

---

## ✅ Task 2.2: Repository 인터페이스 체크포인트

### 체크포인트 2.2.1: 인터페이스 현황
```bash
# CP-2.2.1: Repository 인터페이스 존재 확인
echo "=== Checkpoint 2.2.1: Repository 인터페이스 ==="
echo ""

FEATURES=(auth chat notifications posts profile search voting)
INTERFACE_COUNT=0
IMPL_COUNT=0

for feature in "${FEATURES[@]}"; do
    echo "$feature:"
    
    # Interface 확인
    INTERFACE_FOUND=false
    if [ -f "lib/features/$feature/domain/repositories/i_${feature}_repository.dart" ]; then
        echo "  ✅ Interface: i_${feature}_repository.dart"
        INTERFACE_COUNT=$((INTERFACE_COUNT + 1))
        INTERFACE_FOUND=true
    elif [ -f "lib/features/$feature/domain/repositories/${feature}_repository.dart" ]; then
        echo "  ⚠️  Interface: ${feature}_repository.dart (non-standard naming)"
        INTERFACE_COUNT=$((INTERFACE_COUNT + 1))
        INTERFACE_FOUND=true
    else
        echo "  ❌ Interface: MISSING"
    fi
    
    # Implementation 확인
    if [ -f "lib/features/$feature/data/repositories/${feature}_repository_impl.dart" ]; then
        echo "  ✅ Implementation: ${feature}_repository_impl.dart"
        IMPL_COUNT=$((IMPL_COUNT + 1))
    else
        echo "  ❌ Implementation: MISSING"
    fi
    
    echo ""
done

echo "======================================"
echo "요약:"
echo "  Interfaces: $INTERFACE_COUNT/7"
echo "  Implementations: $IMPL_COUNT/7"
if [ $INTERFACE_COUNT -eq 7 ] && [ $IMPL_COUNT -eq 7 ]; then
    echo "✅ 모든 Repository 완비"
else
    echo "⚠️  일부 Repository 누락"
fi
echo "======================================"
```

### 체크포인트 2.2.2: 템플릿 생성 확인
```bash
# CP-2.2.2: 템플릿 파일 확인
echo "=== Checkpoint 2.2.2: 템플릿 생성 ==="
echo ""

# Repository 인터페이스 템플릿
if [ -d "repository_interface_templates" ]; then
    echo "✅ Repository 템플릿 디렉토리 존재"
    TEMPLATE_COUNT=$(ls -1 repository_interface_templates/*.dart 2>/dev/null | wc -l)
    echo "   템플릿 파일: $TEMPLATE_COUNT 개"
    ls -1 repository_interface_templates/*.dart 2>/dev/null | head -5
else
    echo "❌ Repository 템플릿 디렉토리 없음"
fi

echo ""

# DI 모듈 템플릿
if [ -d "di_module_templates" ]; then
    echo "✅ DI 모듈 템플릿 디렉토리 존재"
    MODULE_COUNT=$(ls -1 di_module_templates/*_module.dart 2>/dev/null | wc -l)
    echo "   모듈 파일: $MODULE_COUNT 개"
    ls -1 di_module_templates/*_module.dart 2>/dev/null | head -5
else
    echo "❌ DI 모듈 템플릿 디렉토리 없음"
fi

echo ""
echo "======================================"
echo "✅ Task 2.2 준비 상태 확인 완료"
echo "======================================"
```

---

## 🎯 Phase 1 최종 검증 스크립트

```bash
#!/bin/bash
# phase1_final_validation.sh

echo "========================================"
echo "     Phase 1 Final Validation           "
echo "========================================"
echo ""
echo "실행 시간: $(date)"
echo ""

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 점수 계산
TOTAL_SCORE=0
MAX_SCORE=100

# 1. 디렉토리 구조 (20점)
echo "1️⃣  디렉토리 구조 검증 (20점)"
if [ ! -d "lib/features/theme" ] && [ ! -d "lib/features/upload" ]; then
    echo -e "  ${GREEN}✅ 빈 디렉토리 삭제됨${NC} (+10)"
    TOTAL_SCORE=$((TOTAL_SCORE + 10))
else
    echo -e "  ${RED}❌ 빈 디렉토리 남아있음${NC} (+0)"
fi

SERVICES_COUNT=$(find lib/features -type d -name "services" | grep -v backup | wc -l)
if [ $SERVICES_COUNT -eq 0 ]; then
    echo -e "  ${GREEN}✅ Services 폴더 모두 제거됨${NC} (+10)"
    TOTAL_SCORE=$((TOTAL_SCORE + 10))
else
    echo -e "  ${RED}❌ Services 폴더 $SERVICES_COUNT 개 남음${NC} (+0)"
fi

# 2. Import 정리 (30점)
echo ""
echo "2️⃣  Import 정리 검증 (30점)"
LEGACY_IMPORTS=$(grep -r "/core/repositories/" lib/features | grep -v backup | grep -v "\.md" | wc -l)
if [ $LEGACY_IMPORTS -eq 0 ]; then
    echo -e "  ${GREEN}✅ 레거시 import 제거됨${NC} (+15)"
    TOTAL_SCORE=$((TOTAL_SCORE + 15))
else
    echo -e "  ${RED}❌ 레거시 import $LEGACY_IMPORTS 개 남음${NC} (+0)"
fi

SERVICE_IMPORTS=$(grep -r "/data/services/" lib/features | grep -v backup | grep -v "\.md" | wc -l)
if [ $SERVICE_IMPORTS -eq 0 ]; then
    echo -e "  ${GREEN}✅ Service import 모두 수정됨${NC} (+15)"
    TOTAL_SCORE=$((TOTAL_SCORE + 15))
else
    echo -e "  ${YELLOW}⚠️  Service import $SERVICE_IMPORTS 개 남음${NC} (+7)"
    TOTAL_SCORE=$((TOTAL_SCORE + 7))
fi

# 3. 빌드 테스트 (30점)
echo ""
echo "3️⃣  빌드 테스트 (30점)"
flutter analyze --no-fatal-infos --no-fatal-warnings 2>&1 | grep -E "error" > /tmp/analyze_errors.txt
ERROR_COUNT=$(wc -l < /tmp/analyze_errors.txt)

if [ $ERROR_COUNT -eq 0 ]; then
    echo -e "  ${GREEN}✅ 빌드 에러 없음${NC} (+30)"
    TOTAL_SCORE=$((TOTAL_SCORE + 30))
elif [ $ERROR_COUNT -lt 10 ]; then
    echo -e "  ${YELLOW}⚠️  빌드 에러 $ERROR_COUNT 개${NC} (+15)"
    TOTAL_SCORE=$((TOTAL_SCORE + 15))
else
    echo -e "  ${RED}❌ 빌드 에러 $ERROR_COUNT 개${NC} (+0)"
fi

# 4. 문서화 (20점)
echo ""
echo "4️⃣  문서화 검증 (20점)"
if [ -f "architecture_violations_report.md" ]; then
    echo -e "  ${GREEN}✅ 위반 보고서 생성됨${NC} (+10)"
    TOTAL_SCORE=$((TOTAL_SCORE + 10))
else
    echo -e "  ${RED}❌ 위반 보고서 없음${NC} (+0)"
fi

if [ -f "repository_interfaces_status.md" ]; then
    echo -e "  ${GREEN}✅ Repository 현황 문서 생성됨${NC} (+10)"
    TOTAL_SCORE=$((TOTAL_SCORE + 10))
else
    echo -e "  ${RED}❌ Repository 현황 문서 없음${NC} (+0)"
fi

# 최종 점수
echo ""
echo "========================================"
echo -e "최종 점수: ${TOTAL_SCORE}/${MAX_SCORE}"

if [ $TOTAL_SCORE -ge 90 ]; then
    echo -e "${GREEN}🎉 Phase 1 완료! Phase 2로 진행 가능${NC}"
elif [ $TOTAL_SCORE -ge 70 ]; then
    echo -e "${YELLOW}⚠️  일부 작업 확인 필요${NC}"
else
    echo -e "${RED}❌ 추가 작업 필요${NC}"
fi
echo "========================================"

# 상세 로그 생성
echo ""
echo "상세 로그를 phase1_validation_log.txt에 저장합니다..."
{
    echo "Phase 1 Validation Log"
    echo "Generated: $(date)"
    echo ""
    echo "Score: $TOTAL_SCORE/$MAX_SCORE"
    echo ""
    echo "Directory Structure:"
    ls -la lib/features/ | grep -E "^d"
    echo ""
    echo "Import Issues:"
    grep -r "/core/repositories/" lib/features | grep -v backup | head -10
    echo ""
    echo "Build Errors:"
    cat /tmp/analyze_errors.txt
} > phase1_validation_log.txt

echo "✅ 로그 저장 완료"
```

---

## 📊 체크포인트 요약 대시보드

```bash
#!/bin/bash
# phase1_dashboard.sh

clear
echo "╔══════════════════════════════════════════╗"
echo "║     Phase 1 Migration Dashboard          ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# 함수: 진행 바 그리기
draw_progress_bar() {
    local progress=$1
    local total=$2
    local percentage=$((progress * 100 / total))
    local filled=$((percentage / 5))  # 20칸 진행바
    
    printf "["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=filled; i<20; i++)); do printf "░"; done
    printf "] %3d%%" $percentage
}

# Task 1.1 체크
TASK11_DONE=0
[ ! -d "lib/features/theme" ] && TASK11_DONE=$((TASK11_DONE + 1))
[ ! -d "lib/features/upload" ] && TASK11_DONE=$((TASK11_DONE + 1))
echo "📁 Task 1.1: 빈 디렉토리 삭제"
draw_progress_bar $TASK11_DONE 2
echo " [$TASK11_DONE/2]"
echo ""

# Task 1.2 체크
TASK12_DONE=0
TASK12_TOTAL=7
for feature in auth chat notifications posts profile search voting; do
    [ -d "lib/features/$feature/data/adapters" ] && TASK12_DONE=$((TASK12_DONE + 1))
done
echo "🔄 Task 1.2: Services → Adapters"
draw_progress_bar $TASK12_DONE $TASK12_TOTAL
echo " [$TASK12_DONE/$TASK12_TOTAL]"
echo ""

# Task 1.3 체크
LEGACY_COUNT=$(grep -r "/core/repositories/" lib/features 2>/dev/null | grep -v backup | wc -l)
TASK13_DONE=0
[ $LEGACY_COUNT -eq 0 ] && TASK13_DONE=5
echo "🔧 Task 1.3: 레거시 의존성 제거"
draw_progress_bar $TASK13_DONE 5
echo " [남은 import: $LEGACY_COUNT]"
echo ""

# Task 2.1 체크
TASK21_DONE=0
[ -f "architecture_violations_report.md" ] && TASK21_DONE=$((TASK21_DONE + 1))
[ -f "presentation_data_violations.txt" ] && TASK21_DONE=$((TASK21_DONE + 1))
[ -f "data_presentation_violations.txt" ] && TASK21_DONE=$((TASK21_DONE + 1))
[ -f "cross_feature_dependencies.txt" ] && TASK21_DONE=$((TASK21_DONE + 1))
echo "📊 Task 2.1: 아키텍처 위반 검사"
draw_progress_bar $TASK21_DONE 4
echo " [$TASK21_DONE/4 reports]"
echo ""

# Task 2.2 체크
TASK22_DONE=0
[ -f "repository_interfaces_status.md" ] && TASK22_DONE=$((TASK22_DONE + 1))
[ -d "repository_interface_templates" ] && TASK22_DONE=$((TASK22_DONE + 1))
[ -d "di_module_templates" ] && TASK22_DONE=$((TASK22_DONE + 1))
echo "📝 Task 2.2: Repository 인터페이스"
draw_progress_bar $TASK22_DONE 3
echo " [$TASK22_DONE/3]"
echo ""

# 전체 진행률
TOTAL_DONE=$((TASK11_DONE + TASK12_DONE + TASK13_DONE/5*5 + TASK21_DONE + TASK22_DONE))
TOTAL_MAX=$((2 + 7 + 5 + 4 + 3))
echo "═══════════════════════════════════════════"
echo "📈 전체 진행률:"
draw_progress_bar $TOTAL_DONE $TOTAL_MAX
echo ""
echo ""

# 다음 단계 안내
if [ $TOTAL_DONE -eq $TOTAL_MAX ]; then
    echo "✅ Phase 1 완료! Phase 2로 진행하세요."
else
    echo "⏳ Phase 1 진행 중..."
    echo "   남은 작업 확인: ./phase1_final_validation.sh"
fi
```

---

**작성자**: SuperClaude with Refactorer & Analyzer Personas  
**체크포인트 버전**: 1.0  
**다음 업데이트**: Phase 2 체크포인트 문서