# Thumbnail Selection Module

## 개요 (Overview)
썸네일 선택 모듈은 멀티 이미지 중에서 대표 이미지(썸네일)를 선택하는 독립적인 페이지입니다. 사용자가 여러 이미지 중 게시물을 대표할 메인 이미지를 선택할 수 있게 합니다.

## 파일 구조

```
thumbnail_selection/
├── thumbnail_selection_model.dart    # 페이지 상태 관리
└── thumbnail_selection_page.dart     # UI 구현
```

## 주요 기능

### 1. 이미지 그리드 표시
- **그리드 레이아웃**: 2열 또는 3열 그리드
- **멀티 소스 지원**: File 객체와 URL 모두 표시
- **순서 표시**: 현재 순서 번호 오버레이

### 2. 상호작용
- **탭하여 선택**: 대표 이미지 선택
- **선택 표시**: 선택된 이미지에 하이라이트
- **즉시 반영**: 선택 즉시 AppState 업데이트

### 3. 네비게이션
- **커스텀 뒤로가기**: "< 갤러리" 스타일
- **자동 닫기**: 선택 후 자동으로 페이지 닫기

## 사용 방법

### 기본 호출
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ThumbnailSelectionPage(
      imagePaths: appState.uploadImageA,  // File 리스트
      box: 'A',  // 'A' 또는 'B'
      onThumbnailSelected: (index) {
        // 선택 완료 콜백
      },
    ),
  ),
);
```

### MediaSelectionFlow에서 호출
```dart
// 썸네일 모드로 MediaSelectionFlow 열기
MediaSelectionFlowWidget(
  box: 'A',
  isThumbnailMode: true,  // 썸네일 선택 모드
  maxAssets: 1,  // 하나만 선택
)
```

## 상태 관리 (ThumbnailSelectionModel)

### 주요 상태
- `selectedIndex`: 현재 선택된 썸네일 인덱스
- `imagePaths`: 표시할 이미지 리스트
- `isProcessing`: 처리 중 상태

### 주요 메서드
```dart
void selectThumbnail(int index)
void reorderImages()  // 선택된 이미지를 맨 앞으로
Future<void> updateAppState()
```

## 통합 플로우

### 1. 썸네일 선택 플로우
```
멀티 이미지 업로드 → 썸네일 선택 페이지 → 
사용자 선택 → 이미지 순서 재정렬 → 
AppState 업데이트 → 페이지 닫기
```

### 2. AppState 업데이트
```dart
// 선택된 이미지를 맨 앞으로 이동
void reorderImages(int selectedIndex) {
  if (selectedIndex > 0) {
    final selected = images.removeAt(selectedIndex);
    images.insert(0, selected);
    
    // 관련 리스트도 모두 재정렬
    aspectRatios.reorder(selectedIndex);
    assetIds.reorder(selectedIndex);
  }
}
```

## UI/UX 디자인

### 레이아웃
- **그리드 간격**: 8px
- **이미지 비율**: 1:1 (정사각형)
- **모서리 반경**: 8px

### 시각적 피드백
- **선택 표시**:
  - 파란색 테두리 (4px)
  - 체크 아이콘 오버레이
- **순서 표시**:
  - 우측 상단 숫자 배지
  - 반투명 검은 배경

### 애니메이션
- **선택 애니메이션**: 스케일 효과
- **그리드 애니메이션**: 부드러운 등장

## 성능 최적화

### 이미지 로딩
- **썸네일 크기**: 메모리 절약을 위해 작은 크기로 로드
- **점진적 로딩**: 보이는 영역부터 우선 로드
- **캐싱**: 이미 로드된 이미지 재사용

### 그리드 최적화
- **가상화**: 많은 이미지에서도 부드러운 스크롤
- **재사용**: 스크롤 시 위젯 재사용

## 사용 시나리오

### 1. 초기 업로드
- 4개 이미지 선택 후 자동으로 썸네일 선택 화면
- 첫 번째 이미지가 기본 선택됨

### 2. 추가 업로드
- 기존 이미지에 추가 후 썸네일 재선택
- 새로 추가된 이미지 우선 표시

### 3. 편집 후 재선택
- 이미지 편집 완료 후 썸네일 변경
- 편집된 이미지 하이라이트

## 에러 처리

### 이미지 로드 실패
- 깨진 이미지 아이콘 표시
- 선택 불가 처리

### 빈 리스트
- 적절한 안내 메시지
- 자동으로 이전 화면 복귀

## 접근성

### 제스처 지원
- 탭: 선택
- 길게 누르기: 미리보기 (선택적)

### 시각적 표시
- 충분한 대비
- 명확한 선택 상태
- 색맹 친화적 디자인

## 커스터마이징 옵션

```dart
ThumbnailSelectionPage({
  this.gridColumns = 2,           // 그리드 열 수
  this.showNumbers = true,        // 순서 번호 표시
  this.autoClose = true,          // 선택 후 자동 닫기
  this.backgroundColor = Colors.black,
})
```

## 테스트 포인트

1. **기능 테스트**:
   - 이미지 선택/변경
   - 순서 재정렬 확인
   - AppState 동기화

2. **엣지 케이스**:
   - 1개 이미지만 있을 때
   - 많은 이미지 (20개 이상)
   - 네트워크 이미지 혼재

3. **성능 테스트**:
   - 스크롤 부드러움
   - 메모리 사용량
   - 선택 반응 속도

## 향후 개선사항

1. **드래그 앤 드롭**:
   - 수동으로 순서 재정렬
   - 직관적인 순서 변경

2. **미리보기 개선**:
   - 롱프레스로 전체 미리보기
   - 핀치 줌 지원

3. **일괄 작업**:
   - 여러 이미지 선택
   - 일괄 삭제/편집