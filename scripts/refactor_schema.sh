#!/bin/bash

# FlutterFlow 스키마 리팩토링 스크립트
# *_record.dart -> *_model.dart
# *Record -> *Model

set -e  # 에러 발생 시 즉시 중단

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== FlutterFlow 스키마 리팩토링 시작 ===${NC}"

# 백업 디렉토리 생성
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
echo -e "${YELLOW}백업 디렉토리 생성: $BACKUP_DIR${NC}"
mkdir -p "$BACKUP_DIR"

# 현재 schema 디렉토리 백업
cp -r lib/backend/schema "$BACKUP_DIR/"

# 변경할 파일 목록 (첫 번째 배치 - 5개)
FILES=(
    "users_record.dart"
    "posts_record.dart"
    "chats_record.dart"
    "messages_record.dart"
    "comments_record.dart"
)

echo -e "${GREEN}첫 번째 배치: ${#FILES[@]}개 파일${NC}"

for file in "${FILES[@]}"; do
    echo -e "\n${YELLOW}처리 중: $file${NC}"
    
    # 파일명에서 클래스명 추출
    base_name=$(echo $file | sed 's/_record\.dart//')
    # Snake case를 Pascal case로 변환
    class_name_base=$(echo $base_name | awk -F_ '{for(i=1;i<=NF;i++){$i=toupper(substr($i,1,1))substr($i,2)}}1' | tr -d ' ')
    class_name_old="${class_name_base}Record"
    class_name_new="${class_name_base}Model"
    
    echo "  클래스명: $class_name_old -> $class_name_new"
    
    # 1. 파일명 변경
    old_path="lib/backend/schema/$file"
    new_file="${file/_record.dart/_model.dart}"
    new_path="lib/backend/schema/$new_file"
    
    if [ -f "$old_path" ]; then
        echo "  파일명 변경: $file -> $new_file"
        git mv "$old_path" "$new_path"
        
        # 2. 파일 내용 수정 (클래스명 변경)
        echo "  클래스명 변경 중..."
        sed -i '' "s/$class_name_old/$class_name_new/g" "$new_path"
        
        # 3. serializer 이름도 변경
        old_serializer="${base_name}RecordSerializer"
        new_serializer="${base_name}ModelSerializer"
        sed -i '' "s/$old_serializer/$new_serializer/g" "$new_path"
        
        # 4. DocumentSnapshot 타입도 업데이트
        sed -i '' "s/DocumentSnapshot<$class_name_old>/DocumentSnapshot<$class_name_new>/g" "$new_path"
        
        echo -e "  ${GREEN}✓ 완료${NC}"
    else
        echo -e "  ${RED}✗ 파일을 찾을 수 없음: $old_path${NC}"
    fi
done

echo -e "\n${GREEN}=== import 경로 업데이트 ===${NC}"

# 프로젝트 전체에서 import 경로 수정
for file in "${FILES[@]}"; do
    old_import="${file}"
    new_import="${file/_record.dart/_model.dart}"
    
    echo "  import 수정: $old_import -> $new_import"
    find lib -name "*.dart" -type f -exec sed -i '' "s|$old_import|$new_import|g" {} +
done

echo -e "\n${GREEN}=== 타입 참조 업데이트 ===${NC}"

# 클래스명 참조 수정
for file in "${FILES[@]}"; do
    base_name=$(echo $file | sed 's/_record\.dart//')
    # Snake case를 Pascal case로 변환
    class_name_base=$(echo $base_name | awk -F_ '{for(i=1;i<=NF;i++){$i=toupper(substr($i,1,1))substr($i,2)}}1' | tr -d ' ')
    class_name_old="${class_name_base}Record"
    class_name_new="${class_name_base}Model"
    
    echo "  타입 수정: $class_name_old -> $class_name_new"
    find lib -name "*.dart" -type f -exec sed -i '' "s/\b$class_name_old\b/$class_name_new/g" {} +
done

echo -e "\n${GREEN}=== 완료! ===${NC}"
echo -e "${YELLOW}다음 단계:${NC}"
echo "1. flutter analyze 실행하여 에러 확인"
echo "2. flutter test 실행하여 테스트 확인"
echo "3. 앱 실행하여 기능 테스트"
echo -e "\n${YELLOW}문제 발생 시:${NC}"
echo "백업 복원: cp -r $BACKUP_DIR/schema lib/backend/"