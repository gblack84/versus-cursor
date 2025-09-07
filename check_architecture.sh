#!/bin/bash
# Feature-First Architecture 검증 스크립트
# 작성일: 2025-01-06
# 버전: 1.0.0

echo "🔍 Feature-First Architecture 검증 시작..."
echo "======================================"

VIOLATIONS=0
WARNINGS=0

# 색상 코드 정의
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# 1. Core → Features import 체크
echo -e "\n📌 Checking Core → Features dependencies..."
CORE_VIOLATIONS=$(grep -r "import.*'/features/\|import.*'package:versus_space/features/" lib/core/ 2>/dev/null | grep -v "^Binary" | grep -v ".g.dart" || true)
if [ ! -z "$CORE_VIOLATIONS" ]; then
  echo -e "${RED}❌ Core가 Features를 import하고 있습니다!${NC}"
  echo "$CORE_VIOLATIONS" | head -5
  VIOLATIONS=$((VIOLATIONS + 1))
else
  echo -e "${GREEN}✅ Core → Features: 위반 없음${NC}"
fi

# 2. Cross-feature import 체크
echo -e "\n📌 Checking cross-feature imports..."
CROSS_FEATURE_FOUND=false
for feature_dir in lib/features/*/; do
  if [ -d "$feature_dir" ]; then
    feature_name=$(basename "$feature_dir")
    CROSS_IMPORTS=$(grep -r "import.*'/features/" "$feature_dir" 2>/dev/null | grep -v "$feature_name" | grep -v "^Binary" | grep -v ".g.dart" || true)
    if [ ! -z "$CROSS_IMPORTS" ]; then
      if [ "$CROSS_FEATURE_FOUND" = false ]; then
        echo -e "${RED}❌ Cross-feature imports 발견!${NC}"
        CROSS_FEATURE_FOUND=true
        VIOLATIONS=$((VIOLATIONS + 1))
      fi
      echo -e "${YELLOW}  $feature_name이 다른 Feature를 import:${NC}"
      echo "$CROSS_IMPORTS" | head -3
    fi
  fi
done
if [ "$CROSS_FEATURE_FOUND" = false ]; then
  echo -e "${GREEN}✅ Cross-feature imports: 위반 없음${NC}"
fi

# 3. Feature → Backend import 체크
echo -e "\n📌 Checking Feature → Backend dependencies..."
BACKEND_IMPORTS=$(grep -r "import.*'/backend/\|import.*'package:versus_space/backend/" lib/features/ 2>/dev/null | grep -v "^Binary" | grep -v ".g.dart" || true)
if [ ! -z "$BACKEND_IMPORTS" ]; then
  echo -e "${RED}❌ Feature가 Backend를 직접 import하고 있습니다!${NC}"
  echo "$BACKEND_IMPORTS" | head -5
  IMPORT_COUNT=$(echo "$BACKEND_IMPORTS" | wc -l)
  echo -e "${YELLOW}  총 $IMPORT_COUNT개 위반${NC}"
  VIOLATIONS=$((VIOLATIONS + 1))
else
  echo -e "${GREEN}✅ Feature → Backend: 위반 없음${NC}"
fi

# 4. Feature → Services 구현체 import 체크
echo -e "\n📌 Checking Feature → Service implementation imports..."
SERVICE_IMPORTS=$(grep -r "import.*'/services/\|import.*'package:versus_space/services/" lib/features/ 2>/dev/null | grep -v "^Binary" | grep -v ".g.dart" || true)
if [ ! -z "$SERVICE_IMPORTS" ]; then
  echo -e "${RED}❌ Feature가 Service 구현체를 직접 import하고 있습니다!${NC}"
  echo "$SERVICE_IMPORTS" | head -5
  IMPORT_COUNT=$(echo "$SERVICE_IMPORTS" | wc -l)
  echo -e "${YELLOW}  총 $IMPORT_COUNT개 위반${NC}"
  VIOLATIONS=$((VIOLATIONS + 1))
else
  echo -e "${GREEN}✅ Feature → Services: 위반 없음${NC}"
fi

# 5. Domain 레이어 순수성 체크
echo -e "\n📌 Checking Domain layer purity..."
DOMAIN_VIOLATIONS=$(grep -r "@JsonSerializable\|fromJson\|toJson\|DocumentReference\|Timestamp" lib/features/*/domain/ 2>/dev/null | grep -v "^Binary" | grep -v ".g.dart" || true)
if [ ! -z "$DOMAIN_VIOLATIONS" ]; then
  echo -e "${RED}❌ Domain 레이어에 직렬화/Firebase 코드가 있습니다!${NC}"
  echo "$DOMAIN_VIOLATIONS" | head -5
  VIOLATIONS=$((VIOLATIONS + 1))
else
  echo -e "${GREEN}✅ Domain layer purity: 위반 없음${NC}"
fi

# 6. Public API 체크
echo -e "\n📌 Checking Feature public APIs..."
PUBLIC_API_MISSING=false
for feature_dir in lib/features/*/; do
  if [ -d "$feature_dir" ]; then
    if [ ! -f "$feature_dir/public.dart" ]; then
      if [ "$PUBLIC_API_MISSING" = false ]; then
        echo -e "${YELLOW}⚠️  일부 Feature에 public.dart가 없습니다:${NC}"
        PUBLIC_API_MISSING=true
        WARNINGS=$((WARNINGS + 1))
      fi
      feature_name=$(basename "$feature_dir")
      echo "    - $feature_name"
    fi
  fi
done
if [ "$PUBLIC_API_MISSING" = false ]; then
  echo -e "${GREEN}✅ 모든 Feature에 public.dart 존재${NC}"
fi

# 7. 파일 크기 체크
echo -e "\n📌 Checking file sizes..."
LARGE_FILES=$(find lib -name "*.dart" -type f -exec wc -l {} + 2>/dev/null | awk '$1 > 400 {print $1 " " $2}' | sort -rn | head -10)
if [ ! -z "$LARGE_FILES" ]; then
  echo -e "${YELLOW}⚠️  400줄을 초과하는 파일들:${NC}"
  echo "$LARGE_FILES" | while read lines file; do
    echo "    $file ($lines줄)"
  done
  WARNINGS=$((WARNINGS + 1))
else
  echo -e "${GREEN}✅ 모든 파일이 400줄 이하${NC}"
fi

# 8. Backend 디렉토리 존재 체크
echo -e "\n📌 Checking for monolithic backend directory..."
if [ -d "lib/backend" ]; then
  FILE_COUNT=$(find lib/backend -name "*.dart" -type f | wc -l)
  echo -e "${RED}❌ Monolithic backend 디렉토리가 존재합니다!${NC}"
  echo -e "${YELLOW}  파일 수: $FILE_COUNT개${NC}"
  VIOLATIONS=$((VIOLATIONS + 1))
else
  echo -e "${GREEN}✅ Backend 디렉토리 없음 (좋음!)${NC}"
fi

# 9. Services 디렉토리 체크
echo -e "\n📌 Checking for global services directory..."
if [ -d "lib/services" ]; then
  FILE_COUNT=$(find lib/services -name "*.dart" -type f | wc -l)
  echo -e "${YELLOW}⚠️  전역 Services 디렉토리가 존재합니다${NC}"
  echo -e "${YELLOW}  파일 수: $FILE_COUNT개 (인터페이스와 구현체 분리 필요)${NC}"
  WARNINGS=$((WARNINGS + 1))
else
  echo -e "${GREEN}✅ Services 디렉토리 없음${NC}"
fi

# 결과 요약
echo -e "\n======================================"
echo -e "📊 검증 결과 요약"
echo -e "======================================"

if [ $VIOLATIONS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo -e "${GREEN}🎉 완벽합니다! 모든 Feature-First Architecture 규칙이 준수되고 있습니다!${NC}"
  exit 0
else
  if [ $VIOLATIONS -gt 0 ]; then
    echo -e "${RED}❌ 위반 사항: $VIOLATIONS개${NC}"
  fi
  if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}⚠️  경고 사항: $WARNINGS개${NC}"
  fi
  
  echo -e "\n📝 다음 단계:"
  if [ $VIOLATIONS -gt 0 ]; then
    echo -e "  1. 위반 사항을 우선적으로 수정해주세요"
    echo -e "  2. Backend/Services → Features로 코드 이동이 필요합니다"
    echo -e "  3. Cross-feature 의존성은 Event Bus로 교체하세요"
  fi
  if [ $WARNINGS -gt 0 ]; then
    echo -e "  - 큰 파일들을 분할하는 것을 고려해보세요"
    echo -e "  - 각 Feature에 public.dart를 추가하세요"
  fi
  
  if [ $VIOLATIONS -gt 0 ]; then
    exit 1
  else
    exit 0
  fi
fi