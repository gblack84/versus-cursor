#!/bin/bash

# validate_dir_docs.sh - 특정 디렉토리 문서 검증 스크립트
# 
# 사용법: ./scripts/validate_dir_docs.sh <디렉토리 경로>
# 예시: ./scripts/validate_dir_docs.sh lib/backend/schema/util
# 
# 설명: 지정된 디렉토리의 문서 완성도와 일관성을 검증합니다.

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
README_PATH="$TARGET_DIR/README.md"

echo "📋 디렉토리 문서 검증 시작: $(basename $TARGET_DIR)"
echo "   경로: $TARGET_DIR"
echo "================================"

# 1. README.md 존재 여부 확인
echo "📄 README.md 파일 확인..."
if [ ! -f "$README_PATH" ]; then
    echo -e "  ${RED}❌ README.md 파일이 없습니다${NC}"
    ((ERROR_COUNT++))
    echo ""
    echo "================================"
    echo -e "${RED}❌ README.md 파일이 없어 검증을 진행할 수 없습니다${NC}"
    echo ""
    echo "권장 조치:"
    echo "1. README.md 파일 생성"
    echo "2. 템플릿 사용: docs/README_TEMPLATE.md"
    exit 1
fi

echo -e "  ${GREEN}✅ README.md 파일 존재${NC}"

# 2. 문서 크기 검사
echo ""
echo "📏 문서 크기 검사..."
lines=$(wc -l < "$README_PATH")
chars=$(wc -c < "$README_PATH")

if [ "$lines" -lt 20 ]; then
    echo -e "  ${RED}❌ 내용 부족: $lines 줄 (최소 20줄 필요)${NC}"
    ((ERROR_COUNT++))
elif [ "$lines" -lt 50 ]; then
    echo -e "  ${YELLOW}⚠️  최소 수준: $lines 줄 (권장 50줄 이상)${NC}"
    ((WARNING_COUNT++))
else
    echo -e "  ${GREEN}✅ 충분한 내용: $lines 줄${NC}"
fi

# 3. 필수 섹션 검사
echo ""
echo "📑 필수 섹션 검사..."

# 필수 섹션 배열
declare -a REQUIRED_SECTIONS=(
    "개요:## 📋 개요\|## 개요\|## Overview"
    "네이밍 컨벤션:## 🎯 네이밍 컨벤션\|## 네이밍 컨벤션"
    "주요 구성요소:## 🔧 주요 구성요소\|## 주요 구성요소"
    "변경 이력:## 📝 변경 이력\|## 변경 이력"
)

for section in "${REQUIRED_SECTIONS[@]}"; do
    section_name="${section%%:*}"
    section_pattern="${section#*:}"
    
    if grep -q "$section_pattern" "$README_PATH" 2>/dev/null; then
        echo -e "  ${GREEN}✅ $section_name 섹션${NC}"
    else
        echo -e "  ${YELLOW}⚠️  $section_name 섹션 없음${NC}"
        ((WARNING_COUNT++))
    fi
done

# 4. 네이밍 컨벤션 참조 확인
echo ""
echo "🔗 참조 링크 검사..."
if grep -q "NAMING_CONVENTION.md" "$README_PATH" 2>/dev/null; then
    echo -e "  ${GREEN}✅ 네이밍 컨벤션 참조${NC}"
    
    # 링크 경로 확인
    link_path=$(grep -o '\[.*\]([^)]*NAMING_CONVENTION.md[^)]*)' "$README_PATH" | sed -n 's/.*](\([^)]*\)).*/\1/p' | head -1)
    if [ -n "$link_path" ]; then
        # 상대 경로 확인
        if [[ "$link_path" != http* ]]; then
            full_path="$TARGET_DIR/$link_path"
            if [ -f "$full_path" ]; then
                echo -e "  ${GREEN}✅ 네이밍 컨벤션 링크 유효${NC}"
            else
                echo -e "  ${YELLOW}⚠️  네이밍 컨벤션 링크 깨짐: $link_path${NC}"
                ((WARNING_COUNT++))
            fi
        fi
    fi
else
    echo -e "  ${YELLOW}⚠️  네이밍 컨벤션 참조 없음${NC}"
    ((WARNING_COUNT++))
fi

# 5. 코드 예시 확인
echo ""
echo "💻 코드 예시 검사..."
if grep -q '```dart\|```javascript\|```typescript\|```python' "$README_PATH" 2>/dev/null; then
    code_blocks=$(grep -c '```' "$README_PATH")
    code_blocks=$((code_blocks / 2))
    echo -e "  ${GREEN}✅ 코드 예시 포함 ($code_blocks개 블록)${NC}"
else
    echo -e "  ${YELLOW}⚠️  코드 예시 없음${NC}"
    ((WARNING_COUNT++))
fi

# 6. 링크 유효성 검사
echo ""
echo "🔍 문서 내 링크 검사..."
BROKEN_LINKS=0
VALID_LINKS=0

while IFS= read -r link; do
    # 링크에서 경로 추출
    link_path=$(echo "$link" | sed -n 's/.*](\([^)]*\)).*/\1/p')
    
    # 외부 링크는 스킵
    if [[ "$link_path" == http* ]] || [[ "$link_path" == "#"* ]]; then
        continue
    fi
    
    # 상대 경로 확인
    full_path="$TARGET_DIR/$link_path"
    
    if [ -e "$full_path" ]; then
        ((VALID_LINKS++))
    else
        if [ "$BROKEN_LINKS" -lt 3 ]; then
            echo -e "  ${YELLOW}⚠️  깨진 링크: $link_path${NC}"
        fi
        ((BROKEN_LINKS++))
    fi
done < <(grep -o '\[[^]]*\]([^)]*)' "$README_PATH" 2>/dev/null)

if [ "$BROKEN_LINKS" -gt 0 ]; then
    if [ "$BROKEN_LINKS" -gt 3 ]; then
        echo -e "  ${YELLOW}⚠️  총 $BROKEN_LINKS개의 깨진 링크${NC}"
    fi
    ((WARNING_COUNT++))
fi

if [ "$VALID_LINKS" -gt 0 ]; then
    echo -e "  ${GREEN}✅ $VALID_LINKS개의 유효한 링크${NC}"
fi

# 7. 디렉토리 구조 설명 확인
echo ""
echo "📂 디렉토리 구조 설명..."
if grep -q "## 📂 디렉토리 구조\|## 디렉토리 구조\|├──\|└──" "$README_PATH" 2>/dev/null; then
    echo -e "  ${GREEN}✅ 디렉토리 구조 설명 있음${NC}"
else
    echo -e "  ${BLUE}ℹ️  디렉토리 구조 설명 없음 (선택사항)${NC}"
fi

# 8. 사용 예시 확인
echo ""
echo "📖 사용 예시 검사..."
if grep -q "## 🚀 사용 예시\|## 사용 예시\|## Usage\|## Example" "$README_PATH" 2>/dev/null; then
    echo -e "  ${GREEN}✅ 사용 예시 섹션 있음${NC}"
else
    echo -e "  ${BLUE}ℹ️  사용 예시 섹션 없음 (권장사항)${NC}"
fi

# 9. 최근 업데이트 확인
echo ""
echo "📅 문서 최신성 검사..."
# 파일 수정 시간 확인
if [[ "$OSTYPE" == "darwin"* ]]; then
    MOD_TIME=$(stat -f %m "$README_PATH" 2>/dev/null)
    CURRENT_TIME=$(date +%s)
else
    MOD_TIME=$(stat -c %Y "$README_PATH" 2>/dev/null)
    CURRENT_TIME=$(date +%s)
fi

if [ -n "$MOD_TIME" ]; then
    DAYS_OLD=$(( (CURRENT_TIME - MOD_TIME) / 86400 ))
    if [ "$DAYS_OLD" -lt 30 ]; then
        echo -e "  ${GREEN}✅ 최근 업데이트됨 (${DAYS_OLD}일 전)${NC}"
    elif [ "$DAYS_OLD" -lt 90 ]; then
        echo -e "  ${YELLOW}⚠️  업데이트 필요할 수 있음 (${DAYS_OLD}일 전)${NC}"
    else
        echo -e "  ${YELLOW}⚠️  오래된 문서 (${DAYS_OLD}일 전)${NC}"
        ((WARNING_COUNT++))
    fi
fi

# 결과 요약
echo ""
echo "================================"
echo "📊 문서 검증 결과 요약"
echo "================================"
echo "디렉토리: $(basename $TARGET_DIR)"
echo "README.md: $lines 줄"
echo ""

if [ $ERROR_COUNT -eq 0 ] && [ $WARNING_COUNT -eq 0 ]; then
    echo -e "${GREEN}✅ 완벽! 모든 문서 검증 통과!${NC}"
    echo ""
    echo "문서 품질: ⭐⭐⭐⭐⭐"
    exit 0
elif [ $ERROR_COUNT -eq 0 ] && [ $WARNING_COUNT -le 2 ]; then
    echo -e "${GREEN}✅ 좋음! 문서 기본 요구사항 충족${NC}"
    echo -e "${YELLOW}   경고 $WARNING_COUNT개 발견 (개선 여지 있음)${NC}"
    echo ""
    echo "문서 품질: ⭐⭐⭐⭐"
    exit 0
elif [ $ERROR_COUNT -eq 0 ]; then
    echo -e "${YELLOW}⚠️  주의! 경고 $WARNING_COUNT개 발견${NC}"
    echo ""
    echo "문서 품질: ⭐⭐⭐"
    echo ""
    echo "개선 권장사항:"
    echo "1. 필수 섹션 추가 (개요, 네이밍 컨벤션, 주요 구성요소)"
    echo "2. 코드 예시 추가"
    echo "3. 깨진 링크 수정"
    exit 0
else
    echo -e "${RED}❌ 실패! 오류 $ERROR_COUNT개, 경고 $WARNING_COUNT개 발견${NC}"
    echo ""
    echo "문서 품질: ⭐⭐"
    echo ""
    echo "필수 조치사항:"
    echo "1. README.md 최소 20줄 이상 작성"
    echo "2. 필수 섹션 포함"
    echo "3. 네이밍 컨벤션 참조 추가"
    exit 1
fi