#!/bin/bash

# check_dir_naming.sh - 특정 디렉토리 네이밍 컨벤션 검사 스크립트
# 
# 사용법: ./scripts/check_dir_naming.sh <디렉토리 경로>
# 예시: ./scripts/check_dir_naming.sh lib/backend/schema/util
# 
# 설명: 지정된 디렉토리의 네이밍 컨벤션 준수 여부를 검사합니다.

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 인자 확인
if [ $# -eq 0 ]; then
    echo "❌ 사용법: $0 <디렉토리 경로>"
    echo "예시: $0 lib/backend/schema/util"
    exit 1
fi

# 디렉토리 경로 설정
TARGET_DIR="$1"
PROJECT_ROOT="$(pwd)"

# 절대 경로로 변환
if [[ "$TARGET_DIR" != /* ]]; then
    TARGET_DIR="$PROJECT_ROOT/$TARGET_DIR"
fi

# 디렉토리 존재 확인
if [ ! -d "$TARGET_DIR" ]; then
    echo "❌ 디렉토리가 존재하지 않습니다: $TARGET_DIR"
    exit 1
fi

ERROR_COUNT=0
WARNING_COUNT=0

echo "🔍 디렉토리 네이밍 컨벤션 검사 시작: $(basename $TARGET_DIR)"
echo "   경로: $TARGET_DIR"
echo "================================"

# 1. Dart 파일명 검사 (snake_case 확인)
echo "📁 Dart 파일명 검사 중..."
DART_FILES_FOUND=false
while IFS= read -r file; do
    DART_FILES_FOUND=true
    filename=$(basename "$file" .dart)
    # snake_case가 아닌 파일 찾기 (대문자 포함 또는 camelCase)
    if [[ "$filename" =~ [A-Z] ]]; then
        echo -e "  ${RED}❌ 파일명 오류: $(basename $file)${NC} (snake_case 사용 필요)"
        ((ERROR_COUNT++))
    else
        echo -e "  ${GREEN}✅ $(basename $file)${NC}"
    fi
done < <(find "$TARGET_DIR" -name "*.dart" -type f 2>/dev/null)

if [ "$DART_FILES_FOUND" = false ]; then
    echo "  ℹ️  Dart 파일이 없습니다"
fi

# 2. 디렉토리 내 Firestore 필드명 검사 (camelCase 확인)
echo ""
echo "📋 코드 내 필드명 검사 중..."
if [ "$DART_FILES_FOUND" = true ]; then
    # snake_case 패턴 찾기 (일반적인 snake_case 필드)
    SNAKE_CASE_FOUND=false
    while IFS= read -r match; do
        if [[ ! "$match" =~ "// legacy" ]] && [[ ! "$match" =~ "// deprecated" ]]; then
            if [ "$SNAKE_CASE_FOUND" = false ]; then
                echo -e "  ${YELLOW}⚠️  snake_case 필드 발견:${NC}"
                SNAKE_CASE_FOUND=true
                ((WARNING_COUNT++))
            fi
            echo "    $(basename $(echo $match | cut -d: -f1)): $(echo $match | cut -d: -f2-)"
        fi
    done < <(grep -n "['\"]\([a-z_]*_[a-z_]*\)['\"]" "$TARGET_DIR"/*.dart 2>/dev/null | head -10)
    
    if [ "$SNAKE_CASE_FOUND" = false ]; then
        echo -e "  ${GREEN}✅ snake_case 필드 없음${NC}"
    fi
else
    echo "  ℹ️  검사할 Dart 파일이 없습니다"
fi

# 3. README.md 파일 검사
echo ""
echo "📚 README.md 검사 중..."
README_PATH="$TARGET_DIR/README.md"
if [ -f "$README_PATH" ]; then
    # 파일 크기 확인
    lines=$(wc -l < "$README_PATH")
    if [ "$lines" -lt 20 ]; then
        echo -e "  ${RED}❌ README.md 내용 부족: $lines 줄 (최소 20줄 필요)${NC}"
        ((ERROR_COUNT++))
    else
        echo -e "  ${GREEN}✅ README.md 크기 적절: $lines 줄${NC}"
    fi
    
    # 네이밍 컨벤션 참조 확인
    if grep -q "NAMING_CONVENTION.md" "$README_PATH" 2>/dev/null; then
        echo -e "  ${GREEN}✅ 네이밍 컨벤션 참조 있음${NC}"
    else
        echo -e "  ${YELLOW}⚠️  네이밍 컨벤션 참조 없음${NC}"
        ((WARNING_COUNT++))
    fi
    
    # 필수 섹션 확인
    if grep -q "## 📋 개요\|## 개요\|## Overview" "$README_PATH" 2>/dev/null; then
        echo -e "  ${GREEN}✅ 개요 섹션 있음${NC}"
    else
        echo -e "  ${YELLOW}⚠️  개요 섹션 없음${NC}"
        ((WARNING_COUNT++))
    fi
    
    if grep -q "## 🎯 네이밍 컨벤션\|## 네이밍 컨벤션" "$README_PATH" 2>/dev/null; then
        echo -e "  ${GREEN}✅ 네이밍 컨벤션 섹션 있음${NC}"
    else
        echo -e "  ${YELLOW}⚠️  네이밍 컨벤션 섹션 없음${NC}"
        ((WARNING_COUNT++))
    fi
else
    echo -e "  ${RED}❌ README.md 파일이 없습니다${NC}"
    ((ERROR_COUNT++))
fi

# 4. TypeScript/JavaScript 파일 검사 (있는 경우)
echo ""
echo "📄 기타 파일 검사 중..."
JS_FILES=$(find "$TARGET_DIR" -name "*.js" -o -name "*.ts" -type f 2>/dev/null | wc -l)
if [ "$JS_FILES" -gt 0 ]; then
    echo "  ℹ️  JavaScript/TypeScript 파일 $JS_FILES개 발견"
    # 필요시 추가 검사 로직
fi

# 결과 요약
echo ""
echo "================================"
echo "📊 검사 결과 요약"
echo "================================"
echo "디렉토리: $(basename $TARGET_DIR)"
echo "경로: $TARGET_DIR"
echo ""

if [ $ERROR_COUNT -eq 0 ] && [ $WARNING_COUNT -eq 0 ]; then
    echo -e "${GREEN}✅ 모든 네이밍 컨벤션 검사 통과!${NC}"
    exit 0
elif [ $ERROR_COUNT -eq 0 ]; then
    echo -e "${YELLOW}⚠️  경고 $WARNING_COUNT개 발견 (오류는 없음)${NC}"
    exit 0
else
    echo -e "${RED}❌ 오류 $ERROR_COUNT개, 경고 $WARNING_COUNT개 발견${NC}"
    echo ""
    echo "권장 조치:"
    echo "1. snake_case 파일명 사용 (Dart 표준)"
    echo "2. README.md에 네이밍 컨벤션 참조 추가"
    echo "3. 필수 섹션 포함 (개요, 네이밍 컨벤션, 주요 구성요소)"
    exit 1
fi