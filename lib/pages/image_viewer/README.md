# Image Viewer Module

## 개요 (Overview)

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **필드명**: camelCase
- 참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)
이미지 뷰어는 사용자가 이미지를 전체 화면으로 보고 상호작용할 수 있는 독립적인 페이지입니다. 주로 In Put Post Image 모듈에서 이미지 미리보기를 위해 사용됩니다.

## 파일 구조

```
image_viewer/
├── image_viewer_model.dart    # 페이지 상태 관리
└── image_viewer_page.dart     # UI 구현
```

## 주요 기능

### 1. 이미지 표시
- **전체화면 보기**: 검은 배경에 이미지 표시
- **멀티 이미지 지원**: PageView로 여러 이미지 스와이프
- **File/URL 지원**: 로컬 파일과 원격 URL 모두 표시 가능

### 2. 상호작용
- **줌 인/아웃**: 핀치 제스처로 확대/축소
- **팬**: 확대된 상태에서 이미지 이동
- **스와이프**: 좌우 스와이프로 이미지 전환
- **탭**: 한 번 탭으로 UI 표시/숨김

### 3. UI 요소
- **상단 바**: 
  - 뒤로가기 버튼
  - 현재 이미지 번호 (1/4, 2/4 등)
- **하단 인디케이터**: 페이지 점 표시 (선택적)

## 사용 방법

### 기본 사용
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ImageViewerPage(
      imagePaths: [file1, file2, file3],  // File 객체 리스트
      initialIndex: 0,  // 시작 인덱스
    ),
  ),
);
```

### URL 이미지
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ImageViewerPage(
      imageUrls: [url1, url2, url3],  // URL 리스트
      initialIndex: currentIndex,
    ),
  ),
);
```

## 상태 관리 (ImageViewerModel)

### 주요 상태
- `currentIndex`: 현재 보고 있는 이미지 인덱스
- `pageController`: PageView 컨트롤러
- `isUIVisible`: UI 표시 여부
- `zoomLevel`: 현재 줌 레벨

### 주요 메서드
```dart
void updateIndex(int index)
void toggleUI()
void resetZoom()
```

## 통합 포인트

### In Put Post Image와 연동
1. **미리보기 탭**:
   ```dart
   // MediaSelectionBox에서 이미지 탭
   onTap: () {
     Navigator.push(
       context,
       MaterialPageRoute(
         builder: (_) => ImageViewerPage(
           imagePaths: appState.uploadImageA,
           initialIndex: currentImageIndex,
         ),
       ),
     );
   }
   ```

2. **편집 후 미리보기**:
   - 편집 완료 후 결과 확인용

## 성능 최적화

### 이미지 로딩
- **프리로딩**: 인접 이미지 미리 로드
- **캐싱**: CachedNetworkImage 사용
- **메모리 관리**: 보이지 않는 이미지 메모리 해제

### 제스처 최적화
- **부드러운 애니메이션**: 60fps 유지
- **제스처 충돌 방지**: 줌/스와이프 구분

## UI/UX 가이드라인

### 디자인 원칙
1. **몰입형 경험**: 전체화면, 검은 배경
2. **직관적 제스처**: 일반적인 갤러리 앱과 동일
3. **빠른 반응**: 즉각적인 피드백

### 접근성
- 제스처 대체 버튼 제공
- 충분한 터치 영역
- 시각적 피드백

## 커스터마이징 옵션

### 설정 가능한 속성
```dart
ImageViewerPage({
  this.showPageNumber = true,      // 페이지 번호 표시
  this.showPageIndicator = true,   // 하단 점 표시
  this.backgroundColor = Colors.black,
  this.minScale = 1.0,
  this.maxScale = 3.0,
})
```

## 에러 처리

### 이미지 로드 실패
- 에러 아이콘 표시
- 재시도 옵션
- 에러 메시지

### 메모리 부족
- 저해상도 대체 이미지
- 점진적 로딩

## 향후 개선사항

1. **기능 추가**:
   - 이미지 다운로드
   - 공유 기능
   - 이미지 정보 표시

2. **성능 개선**:
   - 더 효율적인 메모리 관리
   - WebP 지원

3. **UX 개선**:
   - 더블 탭 줌
   - 스와이프 다운으로 닫기
   - 썸네일 스트립

## 디버깅

### 일반적인 문제
1. **이미지가 안 보임**:
   - File 경로 확인
   - URL 접근성 확인

2. **메모리 문제**:
   - 이미지 크기 확인
   - dispose 제대로 호출되는지 확인

3. **제스처 충돌**:
   - GestureDetector 우선순위 확인
   - 부모 위젯과의 충돌 체크