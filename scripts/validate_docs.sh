#!/bin/bash

# validate_docs.sh - 문서 검증 스크립트
# 
# 사용법: ./scripts/validate_docs.sh
# 
# 설명: 프로젝트 문서의 일관성과 완성도를 검증합니다.

PROJECT_ROOT="$(pwd)"
ISSUES_COUNT=0

echo "📋 문서 검증 시작..."
echo "================================"

# 1. 빈 README 파일 찾기
echo "🔍 빈 README 파일 검사..."
while IFS= read -r readme; do
    lines=$(wc -l < "$readme")
    if [ "$lines" -lt 20 ]; then
        echo "  ⚠️  최소 내용 부족: $readme ($lines 줄)"
        ((ISSUES_COUNT++))
    fi
done < <(find "$PROJECT_ROOT" -name "README.md" -type f ! -path "*/node_modules/*" ! -path "*/Pods/*" ! -path "*/.dart_tool/*" ! -path "*/ios/*" ! -path "*/macos/*" 2>/dev/null)

# 2. 중복 문서 검사
echo "🔍 중복 문서 검사..."
# Migration 관련 문서 개수 확인
MIGRATION_DOCS=$(find "$PROJECT_ROOT" -name "*MIGRATION*.md" -o -name "*migration*.md" 2>/dev/null | wc -l)
if [ "$MIGRATION_DOCS" -gt 2 ]; then
    echo "  ⚠️  마이그레이션 문서가 너무 많음 ($MIGRATION_DOCS개)"
    find "$PROJECT_ROOT" -name "*MIGRATION*.md" -o -name "*migration*.md" 2>/dev/null
    ((ISSUES_COUNT++))
fi

# 3. 오래된 문서 검사 (최근 수정일 확인)
echo "🔍 오래된 문서 검사..."
OLD_DOCS=0
THREE_MONTHS_AGO=$(date -v-3m +%s 2>/dev/null || date -d '3 months ago' +%s)
while IFS= read -r doc; do
    # Skip certain directories
    if [[ "$doc" == *"/Pods/"* ]] || [[ "$doc" == *"/node_modules/"* ]]; then
        continue
    fi
    
    # Get file modification time
    if [[ "$OSTYPE" == "darwin"* ]]; then
        MOD_TIME=$(stat -f %m "$doc" 2>/dev/null)
    else
        MOD_TIME=$(stat -c %Y "$doc" 2>/dev/null)
    fi
    
    if [ -n "$MOD_TIME" ] && [ "$MOD_TIME" -lt "$THREE_MONTHS_AGO" ]; then
        ((OLD_DOCS++))
        if [ "$OLD_DOCS" -le 5 ]; then
            echo "  📅 3개월 이상 미수정: $(basename "$doc")"
        fi
    fi
done < <(find "$PROJECT_ROOT" -name "*.md" -type f 2>/dev/null)

if [ "$OLD_DOCS" -gt 5 ]; then
    echo "  ... 외 $((OLD_DOCS - 5))개 더"
fi

# 4. 문서 링크 유효성 검사
echo "🔍 깨진 링크 검사..."
BROKEN_LINKS=0
while IFS= read -r doc; do
    # Skip certain directories
    if [[ "$doc" == *"/Pods/"* ]] || [[ "$doc" == *"/node_modules/"* ]]; then
        continue
    fi
    
    # 상대 경로 링크 찾기
    while IFS= read -r link; do
        # 링크에서 경로 추출
        link_path=$(echo "$link" | sed -n 's/.*](\([^)]*\)).*/\1/p')
        if [[ "$link_path" == /* ]] || [[ "$link_path" == http* ]]; then
            continue
        fi
        
        # 상대 경로 확인
        doc_dir=$(dirname "$doc")
        full_path="$doc_dir/$link_path"
        
        if [ ! -e "$full_path" ]; then
            if [ "$BROKEN_LINKS" -lt 5 ]; then
                echo "  ❌ 깨진 링크: $doc → $link_path"
            fi
            ((BROKEN_LINKS++))
        fi
    done < <(grep -o '\[[^]]*\]([^)]*)' "$doc" 2>/dev/null)
done < <(find "$PROJECT_ROOT" -name "*.md" -type f 2>/dev/null)

if [ "$BROKEN_LINKS" -gt 5 ]; then
    echo "  ... 외 $((BROKEN_LINKS - 5))개 더"
    ((ISSUES_COUNT++))
fi

# 5. 필수 섹션 확인
echo "🔍 README 필수 섹션 검사..."
MISSING_SECTIONS=0
while IFS= read -r readme; do
    # Skip certain directories
    if [[ "$readme" == *"/Pods/"* ]] || [[ "$readme" == *"/node_modules/"* ]] || [[ "$readme" == *"/.dart_tool/"* ]]; then
        continue
    fi
    
    # 필수 섹션 확인
    if ! grep -q "## 개요\|## Overview" "$readme" 2>/dev/null; then
        ((MISSING_SECTIONS++))
    fi
done < <(find "$PROJECT_ROOT/lib" -name "README.md" -type f 2>/dev/null)

if [ "$MISSING_SECTIONS" -gt 0 ]; then
    echo "  ⚠️  $MISSING_SECTIONS개 README에 개요 섹션 누락"
    ((ISSUES_COUNT++))
fi

echo "================================"
if [ "$ISSUES_COUNT" -eq 0 ]; then
    echo "✅ 모든 문서 검증 통과!"
else
    echo "⚠️  총 $ISSUES_COUNT 개의 문서 이슈 발견"
    echo ""
    echo "권장 조치:"
    echo "1. 빈 README는 템플릿 사용: docs/README_TEMPLATE.md"
    echo "2. 중복 문서는 통합 또는 삭제"
    echo "3. 오래된 문서는 업데이트 또는 archive 폴더로 이동"
    echo "4. 깨진 링크는 수정 또는 제거"
fi

exit $ISSUES_COUNT