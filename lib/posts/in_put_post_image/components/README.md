# Components Directory

## 개요 (Overview)

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **필드명**: camelCase
- 참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)
이 디렉토리는 In Put Post Image 모듈에서 사용되는 재사용 가능한 UI 컴포넌트들을 포함합니다. 각 컴포넌트는 독립적으로 작동하며 명확한 책임을 가지고 있습니다.

## 파일 설명 (File Descriptions)

### base_media_selection_box.dart
- **역할**: MediaSelectionBox의 기본 추상 클래스 및 공통 기능 믹스인
- **주요 기능**:
  - 박스 높이 계산 로직
  - 아이콘 크기 동적 계산
  - 공통 UI 요소 (라벨, 메인 아이콘, + 아이콘)
  - 이미지 프리로드 기능
- **사용처**: MediaSelectionBox와 MediaSelectionBoxMulti의 부모 클래스

### media_selection_box_single.dart
- **역할**: 단일 이미지를 표시하는 A/B 박스 컴포넌트
- **주요 기능**:
  - 단일 이미지 표시
  - 이미지가 있을 때 액션 버튼 표시 (편집, 추가, +B)
  - X 버튼으로 이미지 삭제
  - + 아이콘으로 B박스 토글 (A박스만)
  - 검열 상태 오버레이 표시
- **특징**:
  - File과 URL 모두 지원
  - 동적 크기 조정 가능
  - 흔들림 애니메이션 지원

### media_selection_box_multi.dart
- **역할**: 멀티 이미지(최대 4개)를 표시하는 A/B 박스 컴포넌트
- **주요 기능**:
  - PageView로 여러 이미지 스와이프
  - 페이지 인디케이터 (점)
  - 이미지 카운터 (1/4, 2/4 등)
  - 현재 보고 있는 이미지 삭제
  - 액션 버튼 (편집, 추가, +B)
- **특징**:
  - 인접 이미지 프리로딩
  - 현재 인덱스 추적 및 콜백
  - File 리스트 우선, URL 리스트 폴백

### character_count_display.dart
- **역할**: 텍스트 필드의 글자수를 표시하는 카운터
- **주요 기능**:
  - 현재 글자수/최대 글자수 표시
  - 제한 초과 시 빨간색 표시
  - 오른쪽 정렬
- **사용처**: Description, A title, B title 필드

### layout_debug_info.dart
- **역할**: 개발 모드에서 레이아웃 정보를 표시
- **표시 정보**:
  - 현재 레이아웃 (가로/세로)
  - A/B 박스 크기
  - 이미지 비율
- **특징**: 디버그 모드에서만 표시

### warning_message.dart
- **역할**: 경고 메시지를 표시하는 컴포넌트
- **주요 사용**:
  - "A를 먼저 채워주세요" 경고
  - 빨간색 배경의 둥근 컨테이너
  - 흔들림 애니메이션 지원

### simple_character_count.dart
- **역할**: 심플한 글자수 카운터 (옵션)
- **특징**: character_count_display의 간소화 버전

### simple_validated_field.dart
- **역할**: 유효성 검사가 포함된 텍스트 필드
- **주요 기능**:
  - 실시간 유효성 검사
  - 에러 메시지 표시
  - 필수 필드 체크

### next_button.dart
- **역할**: 다음 단계로 넘어가는 버튼
- **특징**:
  - 활성화/비활성화 상태
  - 로딩 상태 표시

## 컴포넌트 간 관계

```
BaseMediaSelectionBox (추상 클래스)
    ├── MediaSelectionBox (단일 이미지)
    └── MediaSelectionBoxMulti (멀티 이미지)

CharacterCountDisplay ← 텍스트 필드들에서 사용
WarningMessage ← InPutPostImageWidget에서 조건부 표시
LayoutDebugInfo ← 개발 모드에서만 표시
```

## 사용 예시

### MediaSelectionBox 사용
```dart
MediaSelectionBox(
  label: 'A',
  isSelected: true,
  isVideoSelected: false,
  onTap: () => _showMediaPicker('A'),
  onCancel: () => _removeImage('A'),
  isHorizontal: false,
  boxColor: AppTheme.of(context).primary,
  imageFile: selectedImageFile,
  showPlusIcon: !isBBoxVisible,
  onPlusIconTap: () => _toggleBBox(),
  onEditTap: () => _editImage('A'),
  onAddImageTap: () => _addMoreImages('A'),
)
```

### CharacterCountDisplay 사용
```dart
CharacterCountDisplay(
  currentCount: descriptionText.length,
  maxCount: 200,
)
```

## 중요 사항

1. **+ 아이콘 규칙**:
   - A박스에만 표시
   - B박스가 숨겨진 상태에서만 표시
   - 이미지 유무와 관계없이 동작

2. **액션 버튼 규칙**:
   - 이미지가 있을 때만 표시
   - 가로 레이아웃: 가로 배치
   - 세로 레이아웃: 세로 배치

3. **멀티 이미지 인덱스 관리**:
   - 삭제 시 현재 인덱스 조정
   - 범위 초과 방지 로직 포함

4. **File vs URL**:
   - File 객체 우선 사용
   - URL은 하위 호환성을 위해 유지