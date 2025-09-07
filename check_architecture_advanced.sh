#!/bin/bash
# Feature-First Architecture 검증 스크립트 (고급 버전)
# 작성일: 2025-01-06
# 버전: 2.0.0
# 사용법: ./check_architecture_advanced.sh [all|feature-name|core|backend|services]

# 색상 코드 정의
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 파라미터 처리
TARGET=${1:-all}
FEATURE_NAME=""
SCAN_PATH=""

# 사용법 출력 함수
show_usage() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📘 Feature-First Architecture 검증 스크립트 v2.0${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}사용법:${NC}"
    echo "  ./check_architecture_advanced.sh [옵션]"
    echo ""
    echo -e "${YELLOW}옵션:${NC}"
    echo "  all             - 전체 프로젝트 스캔 (기본값)"
    echo "  posts           - posts Feature만 스캔"
    echo "  auth            - auth Feature만 스캔"
    echo "  chat            - chat Feature만 스캔"
    echo "  [feature-name]  - 특정 Feature만 스캔"
    echo "  core            - Core 레이어만 스캔"
    echo "  backend         - Backend 디렉토리만 분석"
    echo "  services        - Services 디렉토리만 분석"
    echo "  help            - 이 도움말 표시"
    echo ""
    echo -e "${YELLOW}예시:${NC}"
    echo "  ./check_architecture_advanced.sh              # 전체 스캔"
    echo "  ./check_architecture_advanced.sh posts        # posts Feature만"
    echo "  ./check_architecture_advanced.sh core         # Core 레이어만"
    echo ""
}

# 대상 설정
case "$TARGET" in
    help|--help|-h)
        show_usage
        exit 0
        ;;
    all)
        echo -e "${BLUE}🔍 전체 프로젝트를 스캔합니다...${NC}"
        SCAN_MODE="all"
        ;;
    core)
        echo -e "${BLUE}🔍 Core 레이어를 스캔합니다...${NC}"
        SCAN_MODE="core"
        SCAN_PATH="lib/core"
        ;;
    backend)
        echo -e "${BLUE}🔍 Backend 디렉토리를 분석합니다...${NC}"
        SCAN_MODE="backend"
        SCAN_PATH="lib/backend"
        ;;
    services)
        echo -e "${BLUE}🔍 Services 디렉토리를 분석합니다...${NC}"
        SCAN_MODE="services"
        SCAN_PATH="lib/services"
        ;;
    *)
        # Feature 이름으로 간주
        if [ -d "lib/features/$TARGET" ]; then
            echo -e "${BLUE}🔍 $TARGET Feature를 스캔합니다...${NC}"
            SCAN_MODE="feature"
            FEATURE_NAME="$TARGET"
            SCAN_PATH="lib/features/$TARGET"
        else
            echo -e "${RED}❌ 오류: 'lib/features/$TARGET' 디렉토리를 찾을 수 없습니다${NC}"
            echo ""
            show_usage
            exit 1
        fi
        ;;
esac

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

VIOLATIONS=0
WARNINGS=0

# Feature 스캔 함수
scan_feature() {
    local feature_path=$1
    local feature_name=$2
    
    echo -e "${CYAN}📦 $feature_name Feature 분석${NC}"
    echo -e "${CYAN}────────────────────────────────${NC}"
    
    # 1. Backend import 체크
    echo -e "\n  📌 Backend 의존성 체크..."
    BACKEND_IMPORTS=$(grep -r "import.*'/backend/\|import.*'package:versus_space/backend/" "$feature_path" 2>/dev/null | grep -v ".g.dart" || true)
    if [ ! -z "$BACKEND_IMPORTS" ]; then
        COUNT=$(echo "$BACKEND_IMPORTS" | wc -l | tr -d ' ')
        echo -e "  ${RED}❌ Backend 직접 참조: $COUNT개${NC}"
        echo "$BACKEND_IMPORTS" | head -3 | sed 's/^/    /'
        VIOLATIONS=$((VIOLATIONS + 1))
    else
        echo -e "  ${GREEN}✅ Backend 의존성 없음${NC}"
    fi
    
    # 2. Services import 체크
    echo -e "\n  📌 Services 구현체 의존성 체크..."
    SERVICE_IMPORTS=$(grep -r "import.*'/services/\|import.*'package:versus_space/services/" "$feature_path" 2>/dev/null | grep -v ".g.dart" || true)
    if [ ! -z "$SERVICE_IMPORTS" ]; then
        COUNT=$(echo "$SERVICE_IMPORTS" | wc -l | tr -d ' ')
        echo -e "  ${RED}❌ Services 직접 참조: $COUNT개${NC}"
        echo "$SERVICE_IMPORTS" | head -3 | sed 's/^/    /'
        VIOLATIONS=$((VIOLATIONS + 1))
    else
        echo -e "  ${GREEN}✅ Services 의존성 없음${NC}"
    fi
    
    # 3. Cross-feature import 체크
    echo -e "\n  📌 다른 Feature 의존성 체크..."
    CROSS_IMPORTS=$(grep -r "import.*'/features/" "$feature_path" 2>/dev/null | grep -v "$feature_name" | grep -v ".g.dart" || true)
    if [ ! -z "$CROSS_IMPORTS" ]; then
        COUNT=$(echo "$CROSS_IMPORTS" | wc -l | tr -d ' ')
        echo -e "  ${RED}❌ Cross-feature 참조: $COUNT개${NC}"
        echo "$CROSS_IMPORTS" | head -3 | sed 's/^/    /'
        VIOLATIONS=$((VIOLATIONS + 1))
    else
        echo -e "  ${GREEN}✅ Cross-feature 의존성 없음${NC}"
    fi
    
    # 4. Domain 순수성 체크
    if [ -d "$feature_path/domain" ]; then
        echo -e "\n  📌 Domain 레이어 순수성 체크..."
        DOMAIN_VIOLATIONS=$(grep -r "@JsonSerializable\|fromJson\|toJson\|DocumentReference\|Timestamp" "$feature_path/domain" 2>/dev/null | grep -v ".g.dart" || true)
        if [ ! -z "$DOMAIN_VIOLATIONS" ]; then
            COUNT=$(echo "$DOMAIN_VIOLATIONS" | wc -l | tr -d ' ')
            echo -e "  ${RED}❌ Domain 오염: $COUNT개${NC}"
            echo "$DOMAIN_VIOLATIONS" | head -3 | sed 's/^/    /'
            VIOLATIONS=$((VIOLATIONS + 1))
        else
            echo -e "  ${GREEN}✅ Domain 레이어 순수함${NC}"
        fi
    fi
    
    # 5. Public API 체크
    echo -e "\n  📌 Public API 체크..."
    if [ ! -f "$feature_path/public.dart" ]; then
        echo -e "  ${YELLOW}⚠️  public.dart 파일 없음${NC}"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "  ${GREEN}✅ public.dart 존재${NC}"
    fi
    
    # 6. 파일 크기 체크
    echo -e "\n  📌 대용량 파일 체크..."
    LARGE_FILES=$(find "$feature_path" -name "*.dart" -type f -exec wc -l {} + 2>/dev/null | awk '$1 > 400 {print $1 " " $2}' | sort -rn)
    if [ ! -z "$LARGE_FILES" ]; then
        COUNT=$(echo "$LARGE_FILES" | wc -l | tr -d ' ')
        echo -e "  ${YELLOW}⚠️  400줄 초과 파일: $COUNT개${NC}"
        echo "$LARGE_FILES" | head -3 | while read lines file; do
            echo "    $(basename $file) ($lines줄)"
        done
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "  ${GREEN}✅ 모든 파일 400줄 이하${NC}"
    fi
    
    # 7. 구조 체크
    echo -e "\n  📌 Clean Architecture 구조 체크..."
    STRUCTURE_OK=true
    for layer in "data" "domain" "presentation"; do
        if [ ! -d "$feature_path/$layer" ]; then
            echo -e "  ${YELLOW}⚠️  $layer 레이어 없음${NC}"
            STRUCTURE_OK=false
            WARNINGS=$((WARNINGS + 1))
        fi
    done
    if [ "$STRUCTURE_OK" = true ]; then
        echo -e "  ${GREEN}✅ Clean Architecture 구조 완벽${NC}"
    fi
}

# Core 스캔 함수
scan_core() {
    echo -e "${CYAN}🔧 Core 레이어 분석${NC}"
    echo -e "${CYAN}────────────────────────────────${NC}"
    
    echo -e "\n  📌 Features 의존성 체크..."
    CORE_VIOLATIONS=$(grep -r "import.*'/features/" lib/core 2>/dev/null | grep -v ".g.dart" || true)
    if [ ! -z "$CORE_VIOLATIONS" ]; then
        COUNT=$(echo "$CORE_VIOLATIONS" | wc -l | tr -d ' ')
        echo -e "  ${RED}❌ Features 참조: $COUNT개${NC}"
        echo "$CORE_VIOLATIONS" | head -5 | sed 's/^/    /'
        VIOLATIONS=$((VIOLATIONS + 1))
    else
        echo -e "  ${GREEN}✅ Features 의존성 없음${NC}"
    fi
    
    echo -e "\n  📌 Backend 의존성 체크..."
    BACKEND_DEPS=$(grep -r "import.*'/backend/" lib/core 2>/dev/null | grep -v ".g.dart" || true)
    if [ ! -z "$BACKEND_DEPS" ]; then
        COUNT=$(echo "$BACKEND_DEPS" | wc -l | tr -d ' ')
        echo -e "  ${RED}❌ Backend 참조: $COUNT개${NC}"
        VIOLATIONS=$((VIOLATIONS + 1))
    else
        echo -e "  ${GREEN}✅ Backend 의존성 없음${NC}"
    fi
}

# Backend 분석 함수
analyze_backend() {
    echo -e "${CYAN}🗄️ Backend 디렉토리 분석${NC}"
    echo -e "${CYAN}────────────────────────────────${NC}"
    
    if [ -d "lib/backend" ]; then
        FILE_COUNT=$(find lib/backend -name "*.dart" -type f | wc -l | tr -d ' ')
        echo -e "  ${RED}❌ Monolithic Backend 존재${NC}"
        echo -e "  📊 총 파일 수: ${YELLOW}$FILE_COUNT개${NC}"
        
        # 가장 큰 파일들
        echo -e "\n  📌 대용량 파일 (상위 5개):"
        find lib/backend -name "*.dart" -type f -exec wc -l {} + | sort -rn | head -6 | tail -5 | while read lines file; do
            echo -e "    ${YELLOW}$(basename $file): $lines줄${NC}"
        done
        
        # 어떤 Feature들이 의존하는지
        echo -e "\n  📌 이 Backend를 참조하는 Feature들:"
        for feature_dir in lib/features/*/; do
            if [ -d "$feature_dir" ]; then
                feature_name=$(basename "$feature_dir")
                COUNT=$(grep -r "import.*'/backend/" "$feature_dir" 2>/dev/null | wc -l | tr -d ' ')
                if [ "$COUNT" -gt 0 ]; then
                    echo -e "    ${YELLOW}$feature_name: $COUNT개 참조${NC}"
                fi
            fi
        done
    else
        echo -e "  ${GREEN}✅ Backend 디렉토리 없음 (좋음!)${NC}"
    fi
}

# Services 분석 함수
analyze_services() {
    echo -e "${CYAN}🛠️ Services 디렉토리 분석${NC}"
    echo -e "${CYAN}────────────────────────────────${NC}"
    
    if [ -d "lib/services" ]; then
        FILE_COUNT=$(find lib/services -name "*.dart" -type f | wc -l | tr -d ' ')
        echo -e "  ${YELLOW}⚠️  전역 Services 존재${NC}"
        echo -e "  📊 총 파일 수: ${YELLOW}$FILE_COUNT개${NC}"
        
        # 서비스 카테고리
        echo -e "\n  📌 서비스 카테고리:"
        for service_dir in lib/services/*/; do
            if [ -d "$service_dir" ]; then
                service_name=$(basename "$service_dir")
                file_count=$(find "$service_dir" -name "*.dart" -type f | wc -l | tr -d ' ')
                echo -e "    ${CYAN}$service_name: $file_count개 파일${NC}"
            fi
        done
        
        # 어떤 Feature들이 의존하는지
        echo -e "\n  📌 Services를 참조하는 Feature들:"
        for feature_dir in lib/features/*/; do
            if [ -d "$feature_dir" ]; then
                feature_name=$(basename "$feature_dir")
                COUNT=$(grep -r "import.*'/services/" "$feature_dir" 2>/dev/null | wc -l | tr -d ' ')
                if [ "$COUNT" -gt 0 ]; then
                    echo -e "    ${YELLOW}$feature_name: $COUNT개 참조${NC}"
                fi
            fi
        done
    else
        echo -e "  ${GREEN}✅ Services 디렉토리 없음${NC}"
    fi
}

# 메인 실행 로직
case "$SCAN_MODE" in
    all)
        # 전체 프로젝트 스캔
        scan_core
        echo ""
        
        # 모든 Feature 스캔
        for feature_dir in lib/features/*/; do
            if [ -d "$feature_dir" ]; then
                feature_name=$(basename "$feature_dir")
                scan_feature "$feature_dir" "$feature_name"
                echo ""
            fi
        done
        
        analyze_backend
        echo ""
        analyze_services
        ;;
    feature)
        scan_feature "$SCAN_PATH" "$FEATURE_NAME"
        ;;
    core)
        scan_core
        ;;
    backend)
        analyze_backend
        ;;
    services)
        analyze_services
        ;;
esac

# 결과 요약
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}📊 검증 결과 요약${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ $VIOLATIONS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 완벽합니다! 모든 규칙이 준수되고 있습니다!${NC}"
    exit 0
else
    if [ $VIOLATIONS -gt 0 ]; then
        echo -e "${RED}❌ 위반 사항: $VIOLATIONS개${NC}"
    fi
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠️  경고 사항: $WARNINGS개${NC}"
    fi
    
    # 스캔 대상별 맞춤 조언
    echo ""
    echo -e "${BLUE}💡 추천 액션:${NC}"
    
    case "$SCAN_MODE" in
        feature)
            echo "  1. 이 Feature의 Backend/Services 의존성을 제거하세요"
            echo "  2. Domain 레이어를 순수하게 유지하세요"
            echo "  3. public.dart를 추가하여 외부 API를 명시하세요"
            ;;
        core)
            echo "  1. Core는 Features를 절대 참조하면 안 됩니다"
            echo "  2. 인터페이스만 정의하고 구현은 App 레이어로 이동하세요"
            ;;
        backend)
            echo "  1. Backend 코드를 각 Feature의 data/repositories로 이동하세요"
            echo "  2. 공통 로직은 Core의 인터페이스로 추상화하세요"
            ;;
        services)
            echo "  1. 인터페이스를 Core/services/interfaces로 이동하세요"
            echo "  2. 구현체를 App/services로 이동하세요"
            echo "  3. Feature들이 인터페이스만 사용하도록 수정하세요"
            ;;
        all)
            echo "  1. Feature별로 단계적 마이그레이션을 진행하세요"
            echo "  2. ./check_architecture_advanced.sh [feature-name]으로 진행 상황을 추적하세요"
            ;;
    esac
    
    if [ $VIOLATIONS -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
fi