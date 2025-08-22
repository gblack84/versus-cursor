#!/bin/bash

# sync_docs.sh - 코드와 문서 동기화 스크립트
# 
# 사용법: ./scripts/sync_docs.sh [check|update]
# 
# 설명: 코드 변경사항과 문서의 동기화 상태를 확인하고 업데이트합니다.

MODE="${1:-check}"
PROJECT_ROOT="$(pwd)"
SYNC_ISSUES=0

echo "🔄 코드-문서 동기화 검사..."
echo "================================"

# 1. 새로운 디렉토리에 README 존재 확인
echo "📁 새 디렉토리 README 확인..."
while IFS= read -r dir; do
    readme_path="$dir/README.md"
    if [ ! -f "$readme_path" ]; then
        echo "  ⚠️  README 없음: $dir"
        ((SYNC_ISSUES++))
        
        if [ "$MODE" = "update" ]; then
            echo "    → README 생성 중..."
            cat > "$readme_path" << EOF
# $(basename "$dir")

## 📋 개요
[이 디렉토리의 목적을 설명해주세요]

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **필드명**: camelCase
- 참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)

## 🔧 주요 구성요소
[주요 파일과 클래스를 나열해주세요]

## 📝 변경 이력
- $(date +%Y-%m-%d): 초기 생성
EOF
            echo "    ✅ README 생성 완료"
        fi
    fi
done < <(find "$PROJECT_ROOT/lib" -type d -mindepth 1 -maxdepth 3 ! -path "*/.*" 2>/dev/null)

# 2. 주요 클래스/파일 변경 시 README 업데이트 필요 확인
echo "📝 최근 변경된 코드와 문서 동기화 확인..."
# 최근 7일 내 변경된 Dart 파일 찾기
RECENT_CHANGES=0
while IFS= read -r dart_file; do
    dir=$(dirname "$dart_file")
    readme="$dir/README.md"
    
    if [ -f "$readme" ]; then
        # README가 Dart 파일보다 오래된 경우
        if [ "$dart_file" -nt "$readme" ]; then
            ((RECENT_CHANGES++))
            if [ "$RECENT_CHANGES" -le 5 ]; then
                echo "  📅 문서 업데이트 필요: $(basename "$dir")/README.md"
                echo "     ($(basename "$dart_file") 최근 수정됨)"
            fi
        fi
    fi
done < <(find "$PROJECT_ROOT/lib" -name "*.dart" -type f -mtime -7 2>/dev/null)

if [ "$RECENT_CHANGES" -gt 5 ]; then
    echo "  ... 외 $((RECENT_CHANGES - 5))개 더"
    ((SYNC_ISSUES++))
fi

# 3. 삭제된 파일/디렉토리 참조 확인
echo "🗑️  삭제된 코드 참조 확인..."
DEAD_REFS=0
while IFS= read -r readme; do
    # Skip certain directories
    if [[ "$readme" == *"/Pods/"* ]] || [[ "$readme" == *"/node_modules/"* ]]; then
        continue
    fi
    
    # README에서 .dart 파일 참조 찾기
    while IFS= read -r dart_ref; do
        # 파일명 추출
        file_ref=$(echo "$dart_ref" | sed -n 's/.*`\([^`]*\.dart\)`*.*/\1/p')
        if [ -n "$file_ref" ]; then
            dir=$(dirname "$readme")
            full_path="$dir/$file_ref"
            
            if [ ! -f "$full_path" ]; then
                if [ "$DEAD_REFS" -lt 3 ]; then
                    echo "  ❌ 존재하지 않는 파일 참조: $readme → $file_ref"
                fi
                ((DEAD_REFS++))
            fi
        fi
    done < <(grep -o '[`][^`]*\.dart[`]' "$readme" 2>/dev/null)
done < <(find "$PROJECT_ROOT" -name "README.md" -type f 2>/dev/null)

if [ "$DEAD_REFS" -gt 3 ]; then
    echo "  ... 외 $((DEAD_REFS - 3))개 더"
    ((SYNC_ISSUES++))
fi

# 4. 네이밍 컨벤션 참조 추가
if [ "$MODE" = "update" ]; then
    echo "📚 네이밍 컨벤션 참조 추가..."
    UPDATED=0
    while IFS= read -r readme; do
        # Skip if already has naming convention reference
        if ! grep -q "NAMING_CONVENTION.md" "$readme" 2>/dev/null; then
            # Add naming convention section after overview
            sed -i '' '/## 개요/a\
\
## 🎯 네이밍 컨벤션\
- **파일명**: snake_case (Dart 표준)\
- **필드명**: camelCase\
- 참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)\
' "$readme" 2>/dev/null || \
            sed -i '/## 개요/a\
\
## 🎯 네이밍 컨벤션\
- **파일명**: snake_case (Dart 표준)\
- **필드명**: camelCase\
- 참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)\
' "$readme" 2>/dev/null
            
            if [ $? -eq 0 ]; then
                ((UPDATED++))
            fi
        fi
    done < <(find "$PROJECT_ROOT/lib" -name "README.md" -type f 2>/dev/null)
    
    if [ "$UPDATED" -gt 0 ]; then
        echo "  ✅ $UPDATED개 README에 네이밍 컨벤션 참조 추가"
    fi
fi

echo "================================"
if [ "$SYNC_ISSUES" -eq 0 ]; then
    echo "✅ 코드와 문서가 잘 동기화되어 있습니다!"
else
    echo "⚠️  총 $SYNC_ISSUES 개의 동기화 이슈 발견"
    
    if [ "$MODE" = "check" ]; then
        echo ""
        echo "업데이트하려면 다음 명령어를 실행하세요:"
        echo "  ./scripts/sync_docs.sh update"
    fi
fi

exit $SYNC_ISSUES