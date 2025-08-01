#!/bin/bash

# FlutterFlow 스키마 완전 리팩토링 스크립트
# 모든 *_record.dart 파일과 관련 참조를 한번에 변경

set -e  # 에러 발생 시 즉시 중단

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== FlutterFlow 스키마 완전 리팩토링 시작 ===${NC}"

# 백업 디렉토리 생성
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
echo -e "${YELLOW}백업 디렉토리 생성: $BACKUP_DIR${NC}"
mkdir -p "$BACKUP_DIR"

# 전체 lib 디렉토리 백업
echo -e "${YELLOW}전체 lib 디렉토리 백업 중...${NC}"
cp -r lib "$BACKUP_DIR/"

# 모든 *_record.dart 파일 목록 가져오기
echo -e "\n${BLUE}=== 스키마 파일 목록 수집 ===${NC}"
SCHEMA_FILES=$(find lib/backend/schema -name "*_record.dart" -type f | sort)
FILE_COUNT=$(echo "$SCHEMA_FILES" | wc -l | tr -d ' ')

echo -e "${GREEN}총 ${FILE_COUNT}개의 스키마 파일 발견${NC}"

# 각 파일에 대한 변환 정보 생성
declare -A CLASS_MAP
declare -A FILE_MAP

echo -e "\n${BLUE}=== 변환 맵 생성 ===${NC}"
for file_path in $SCHEMA_FILES; do
    file_name=$(basename "$file_path")
    base_name=$(echo $file_name | sed 's/_record\.dart//')
    new_file="${file_name/_record.dart/_model.dart}"
    
    # Snake case를 Pascal case로 변환
    class_name_base=$(echo $base_name | awk -F_ '{for(i=1;i<=NF;i++){$i=toupper(substr($i,1,1))substr($i,2)}}1' | tr -d ' ')
    class_name_old="${class_name_base}Record"
    class_name_new="${class_name_base}Model"
    
    CLASS_MAP[$class_name_old]=$class_name_new
    FILE_MAP[$file_name]=$new_file
    
    echo "  $file_name → $new_file ($class_name_old → $class_name_new)"
done

# Step 1: 모든 스키마 파일 이름 변경
echo -e "\n${GREEN}=== Step 1: 파일명 변경 ===${NC}"
for file_path in $SCHEMA_FILES; do
    file_name=$(basename "$file_path")
    dir_path=$(dirname "$file_path")
    new_file="${FILE_MAP[$file_name]}"
    
    echo -e "  ${YELLOW}$file_name → $new_file${NC}"
    git mv "$file_path" "$dir_path/$new_file"
done

# Step 2: 스키마 파일 내용 수정
echo -e "\n${GREEN}=== Step 2: 클래스명 변경 ===${NC}"
for old_class in "${!CLASS_MAP[@]}"; do
    new_class="${CLASS_MAP[$old_class]}"
    echo -e "  ${YELLOW}$old_class → $new_class${NC}"
    
    # 모든 dart 파일에서 클래스명 변경
    find lib -name "*.dart" -type f -exec sed -i '' "s/\b$old_class\b/$new_class/g" {} +
    
    # serializer 이름도 변경
    base_name=$(echo $old_class | sed 's/Record$//')
    old_serializer="${base_name}RecordSerializer"
    new_serializer="${base_name}ModelSerializer"
    find lib -name "*.dart" -type f -exec sed -i '' "s/$old_serializer/$new_serializer/g" {} +
    
    # create*RecordData 함수명도 변경
    old_create="create${old_class}Data"
    new_create="create${new_class}Data"
    find lib -name "*.dart" -type f -exec sed -i '' "s/$old_create/$new_create/g" {} +
done

# Step 3: import/export 경로 수정
echo -e "\n${GREEN}=== Step 3: Import/Export 경로 업데이트 ===${NC}"
for old_file in "${!FILE_MAP[@]}"; do
    new_file="${FILE_MAP[$old_file]}"
    echo -e "  ${YELLOW}$old_file → $new_file${NC}"
    
    # import 문 수정
    find lib -name "*.dart" -type f -exec sed -i '' "s|$old_file|$new_file|g" {} +
done

# Step 4: Query 함수명 변경
echo -e "\n${GREEN}=== Step 4: Query 함수명 업데이트 ===${NC}"
for old_class in "${!CLASS_MAP[@]}"; do
    new_class="${CLASS_MAP[$old_class]}"
    base_name=$(echo $old_class | sed 's/Record$//')
    
    # query*RecordCount → query*ModelCount
    old_query="query${base_name}RecordCount"
    new_query="query${base_name}ModelCount"
    find lib -name "*.dart" -type f -exec sed -i '' "s/$old_query/$new_query/g" {} +
    
    # query*Record → query*Model
    old_query="query${base_name}Record"
    new_query="query${base_name}Model"
    find lib -name "*.dart" -type f -exec sed -i '' "s/$old_query/$new_query/g" {} +
    
    # query*RecordOnce → query*ModelOnce
    old_query="query${base_name}RecordOnce"
    new_query="query${base_name}ModelOnce"
    find lib -name "*.dart" -type f -exec sed -i '' "s/$old_query/$new_query/g" {} +
done

# Step 5: 특수 케이스 처리
echo -e "\n${GREEN}=== Step 5: 특수 케이스 처리 ===${NC}"

# votes_record.dart는 VotesRecord가 아닌 VotesRecord로 되어 있을 수 있음
# notification_record.dart도 체크

# image_moderation_record.dart가 아직 남아있는지 확인
if [ -f "lib/backend/schema/image_moderation_record.dart" ]; then
    echo "  image_moderation_record.dart 발견, 변경 중..."
    git mv "lib/backend/schema/image_moderation_record.dart" "lib/backend/schema/image_moderation_model.dart"
    find lib -name "*.dart" -type f -exec sed -i '' "s|image_moderation_record\.dart|image_moderation_model.dart|g" {} +
    find lib -name "*.dart" -type f -exec sed -i '' "s/\bImageModerationRecord\b/ImageModerationModel/g" {} +
fi

echo -e "\n${GREEN}=== 완료! ===${NC}"
echo -e "${YELLOW}변경 내용:${NC}"
echo "- 파일명 변경: *_record.dart → *_model.dart"
echo "- 클래스명 변경: *Record → *Model"
echo "- Import/Export 경로 업데이트"
echo "- Query 함수명 업데이트"
echo ""
echo -e "${YELLOW}다음 단계:${NC}"
echo "1. flutter analyze 실행하여 에러 확인"
echo "2. flutter test 실행하여 테스트 확인"
echo "3. 앱 실행하여 기능 테스트"
echo ""
echo -e "${YELLOW}문제 발생 시:${NC}"
echo "백업 복원: cp -r $BACKUP_DIR/lib ."
echo ""
echo -e "${GREEN}변경된 파일 수: ${FILE_COUNT}개${NC}"