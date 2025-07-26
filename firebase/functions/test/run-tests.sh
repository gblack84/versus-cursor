#!/bin/bash

# 색상 정의
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=================================${NC}"
echo -e "${YELLOW}투표 알림 시스템 테스트 시작${NC}"
echo -e "${YELLOW}=================================${NC}"

# Firebase 에뮬레이터 확인
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}❌ Firebase CLI가 설치되지 않았습니다.${NC}"
    echo "설치 명령: npm install -g firebase-tools"
    exit 1
fi

# 의존성 확인
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 의존성 설치 중...${NC}"
    npm install
fi

# 에뮬레이터 실행 중인지 확인
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null ; then
    echo -e "${GREEN}✓ Firestore 에뮬레이터가 이미 실행 중입니다.${NC}"
    RUN_EMULATOR=false
else
    echo -e "${YELLOW}🚀 Firebase 에뮬레이터 시작 중...${NC}"
    RUN_EMULATOR=true
fi

# 테스트 실행
if [ "$RUN_EMULATOR" = true ]; then
    echo -e "${YELLOW}에뮬레이터와 함께 테스트 실행 중...${NC}"
    npm run test:emulator
else
    echo -e "${YELLOW}테스트 실행 중...${NC}"
    npm test
fi

# 결과 확인
if [ $? -eq 0 ]; then
    echo -e "${GREEN}=================================${NC}"
    echo -e "${GREEN}✓ 모든 테스트가 성공했습니다!${NC}"
    echo -e "${GREEN}=================================${NC}"
else
    echo -e "${RED}=================================${NC}"
    echo -e "${RED}❌ 일부 테스트가 실패했습니다.${NC}"
    echo -e "${RED}=================================${NC}"
    exit 1
fi

# 선택적: 테스트 후 정리
read -p "테스트 데이터를 정리하시겠습니까? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}테스트 데이터 정리 중...${NC}"
    # 에뮬레이터 데이터 초기화
    firebase emulators:export ./test-backup --force
    rm -rf ./test-backup
    echo -e "${GREEN}✓ 정리 완료${NC}"
fi