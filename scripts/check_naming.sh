#!/bin/bash

# check_naming.sh - 네이밍 컨벤션 검사 스크립트
# 
# 사용법: ./scripts/check_naming.sh [디렉토리]
# 
# 설명: 프로젝트 전체의 네이밍 컨벤션 준수 여부를 검사합니다.

PROJECT_ROOT="${1:-$(pwd)}"
ERROR_COUNT=0

echo "🔍 네이밍 컨벤션 검사 시작..."
echo "================================"

# 1. Dart 파일명 검사 (snake_case 확인)
echo "📁 Dart 파일명 검사 중..."
while IFS= read -r file; do
    filename=$(basename "$file" .dart)
    # snake_case가 아닌 파일 찾기 (대문자 포함 또는 camelCase)
    if [[ "$filename" =~ [A-Z] ]]; then
        echo "  ❌ 파일명 오류: $file (snake_case 사용 필요)"
        ((ERROR_COUNT++))
    fi
done < <(find "$PROJECT_ROOT/lib" -name "*.dart" -type f 2>/dev/null)

# 2. Firestore 필드명 검사 (camelCase 확인)
echo "📋 Firestore 필드 검사 중..."
# Firebase Functions 내 snake_case 필드 검색
if grep -r "'\(user_id\|created_at\|display_name\|photo_url\|vote_.*\|last_.*\)'" "$PROJECT_ROOT/firebase/functions" --include="*.js" 2>/dev/null | grep -v "// legacy" > /dev/null; then
    echo "  ⚠️  Firebase Functions에 snake_case 필드 발견"
    grep -r "'\(user_id\|created_at\|display_name\|photo_url\|vote_.*\|last_.*\)'" "$PROJECT_ROOT/firebase/functions" --include="*.js" 2>/dev/null | head -5
    ((ERROR_COUNT++))
fi

# 3. 라우트명 검사 (camelCase 확인)
echo "🗺️  라우트명 검사 중..."
if grep -r "goNamed('[a-z]*_[a-z]*')" "$PROJECT_ROOT/lib" --include="*.dart" 2>/dev/null > /dev/null; then
    echo "  ⚠️  snake_case 라우트명 발견"
    grep -r "goNamed('[a-z]*_[a-z]*')" "$PROJECT_ROOT/lib" --include="*.dart" 2>/dev/null | head -5
    ((ERROR_COUNT++))
fi

# 4. README 파일 네이밍 컨벤션 참조 확인
echo "📚 README 문서 검사 중..."
README_COUNT=0
NO_CONVENTION_COUNT=0
while IFS= read -r readme; do
    ((README_COUNT++))
    if ! grep -q "NAMING_CONVENTION.md" "$readme" 2>/dev/null; then
        ((NO_CONVENTION_COUNT++))
    fi
done < <(find "$PROJECT_ROOT" -name "README.md" -type f ! -path "*/node_modules/*" ! -path "*/Pods/*" 2>/dev/null)

if [ $NO_CONVENTION_COUNT -gt 0 ]; then
    echo "  ⚠️  $NO_CONVENTION_COUNT/$README_COUNT README 파일이 네이밍 컨벤션을 참조하지 않음"
fi

echo "================================"
if [ $ERROR_COUNT -eq 0 ]; then
    echo "✅ 모든 네이밍 컨벤션 검사 통과!"
else
    echo "❌ 총 $ERROR_COUNT 개의 네이밍 컨벤션 위반 발견"
    exit 1
fi