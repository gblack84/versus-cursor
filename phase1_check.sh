#!/bin/bash
echo "======================================"
echo "   Phase 1 Migration Progress        "
echo "======================================"
echo ""

# Task 1.1 체크
TASK11_DONE=0
[ ! -d "lib/features/theme" ] && TASK11_DONE=$((TASK11_DONE + 1))
[ ! -d "lib/features/upload" ] && TASK11_DONE=$((TASK11_DONE + 1))
echo "📁 Task 1.1: 빈 디렉토리 삭제 [$TASK11_DONE/2]"
[ ! -d "lib/features/theme" ] && echo "  ✅ theme/ 삭제됨" || echo "  ❌ theme/ 존재"
[ ! -d "lib/features/upload" ] && echo "  ✅ upload/ 삭제됨" || echo "  ❌ upload/ 존재"

echo ""
echo "📋 Task 1.2: Services → Adapters"
SERVICES_COUNT=$(find lib/features -type d -name "services" | grep -v backup | wc -l)
ADAPTERS_COUNT=$(find lib/features -type d -name "adapters" | wc -l)
echo "  Services 디렉토리: $SERVICES_COUNT 개"
echo "  Adapters 디렉토리: $ADAPTERS_COUNT 개"
[ $SERVICES_COUNT -eq 0 ] && echo "  ✅ 모든 services 제거됨" || echo "  ❌ services 남아있음"

echo ""
echo "📋 Task 2.1: 레거시 import 수정"
LEGACY_COUNT=$(grep -r "/core/repositories/" lib/features 2>/dev/null | grep -v backup | wc -l)
echo "  레거시 import: $LEGACY_COUNT 개"
[ $LEGACY_COUNT -eq 0 ] && echo "  ✅ 레거시 import 제거됨" || echo "  ❌ 레거시 import 남아있음"

echo ""
echo "📋 core/repositories 삭제"
[ ! -d "lib/core/repositories" ] && echo "  ✅ core/repositories 삭제됨" || echo "  ❌ core/repositories 존재"

echo ""
echo "📋 빌드 에러"
ERROR_COUNT=$(flutter analyze --no-fatal-infos 2>&1 | grep -c "error")
echo "  빌드 에러: $ERROR_COUNT 개"

echo ""
echo "======================================"
