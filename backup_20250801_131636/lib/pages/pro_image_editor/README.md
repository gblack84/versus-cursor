# Pro Image Editor Module

## 개요 (Overview)
ProImageEditor는 Flutter용 고급 이미지 편집 라이브러리를 래핑하고 커스터마이징한 모듈입니다. Versus Space 앱의 디자인과 요구사항에 맞춰 설정되어 있으며, In Put Post Image 모듈과 긴밀하게 통합됩니다.

## 파일 구조

```
pro_image_editor/
├── pro_image_editor_model.dart    # 편집기 상태 관리
└── pro_image_editor_page.dart     # 편집기 UI 및 설정
```

## 주요 기능

### 1. 편집 도구
- **그리기 (Paint)**:
  - Pen (펜)
  - Arrow (화살표)
  - Dash Line (점선)
  - Circle (원)
  - Emoji (이모지)
  - ~~Rectangle, Polygon, Pixelate, Line~~ (비활성화)
  
- **텍스트 (Text)**:
  - 텍스트 추가
  - 폰트 스타일 변경
  - 색상 선택
  - 정렬 옵션

- **자르기 (Crop)**:
  - 자유 비율
  - 사전 정의 비율
  - 회전

- **필터 (Filter)**:
  - 다양한 사전 정의 필터
  - 커스텀 필터 지원

- **~~블러 (Blur)~~**: 완전 비활성화됨

### 2. 사용자 인터페이스
- **커스텀 네비게이션**:
  - "< 갤러리" 버튼 (텍스트 스타일)
  - 검은색 둥근 배경
- **한국어 지원**:
  - i18n 설정으로 한국어 UI
  - 로딩 메시지: "처리 중..."
- **다크 테마**: 프로젝트 스타일에 맞춘 어두운 테마

## 통합 플로우

### 1. 새 이미지 편집
```dart
// In Put Post Image에서 편집 버튼 클릭
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ProImageEditorPage(
      imageFile: selectedFile,  // 또는 imageUrl
      onEditComplete: (editedFile) {
        // 편집 완료 처리
      },
    ),
  ),
);
```

### 2. Firebase 이미지 편집
```dart
// URL에서 다운로드 → 편집 → 재업로드
ProImageEditorPage(
  imageUrl: firebaseUrl,
  box: 'A',
  currentIndex: 0,
  isEditMode: true,
)
```

## 커스터마이징 내역

### ProImageEditorConfigs
```dart
ProImageEditorConfigs(
  // i18n 설정
  i18n: I18n(
    various: I18nVarious(
      // 한국어 메시지
    ),
  ),
  
  // 블러 에디터 비활성화
  blurEditor: BlurEditorConfigs(enabled: false),
  
  // Paint 에디터 도구 제한
  paintEditor: PaintEditorConfigs(
    showColorPicker: true,
    icons: PaintIcons(
      // 선택된 도구만 표시
    ),
  ),
  
  // 테마 설정
  theme: customTheme,
)
```

### 상태 관리 (ProImageEditorModel)

#### 주요 상태
- `editedImageBytes`: 편집된 이미지 데이터
- `isProcessing`: 처리 중 상태
- `originalImagePath`: 원본 이미지 경로
- `editHistory`: 편집 이력 (실행 취소용)

#### 주요 메서드
```dart
Future<void> saveEditedImage()
void undoLastEdit()
void resetToOriginal()
```

## 편집 완료 처리

### 1. 저장 플로우
```
편집 완료 → 이미지 바이트 생성 → 
임시 파일 저장 → Firebase 업로드 → 
검열 확인 → AppState 업데이트
```

### 2. 콜백 처리
```dart
onEditComplete: (editedFile) async {
  // 1. 업로드
  final urls = await uploadImage(editedFile);
  
  // 2. 검열
  final moderationResult = await moderateImage(urls.display);
  
  // 3. 상태 업데이트
  if (moderationResult.isAppropriate) {
    updateAppState(urls);
  }
}
```

## 성능 최적화

### 메모리 관리
- **이미지 리사이징**: 편집 전 적절한 크기로 조정
- **캐시 정리**: 편집 완료 후 임시 데이터 삭제
- **점진적 렌더링**: 무거운 작업은 비동기 처리

### 렌더링 최적화
- **레이어 캐싱**: 자주 변경되지 않는 레이어 캐시
- **프레임 제한**: 부드러운 60fps 유지

## 에러 처리

### 일반적인 에러
1. **메모리 부족**:
   - 이미지 크기 자동 조정
   - 사용자에게 안내 메시지

2. **저장 실패**:
   - 재시도 옵션
   - 임시 저장 기능

3. **편집기 크래시**:
   - 자동 복구
   - 마지막 상태 저장

## UI/UX 가이드라인

### 디자인 원칙
1. **일관성**: 앱 전체 디자인과 통일
2. **직관성**: 명확한 아이콘과 레이블
3. **반응성**: 즉각적인 시각적 피드백

### 접근성
- 충분한 터치 영역 (최소 44pt)
- 명확한 시각적 구분
- 제스처 대체 방법 제공

## 테스트 포인트

### 기능 테스트
1. **도구별 테스트**:
   - 각 그리기 도구 동작
   - 텍스트 입력 및 스타일
   - 필터 적용/취소

2. **통합 테스트**:
   - 편집 → 저장 → 업로드 플로우
   - 검열 실패 시나리오
   - 메모리 부족 상황

### 성능 테스트
- 대용량 이미지 처리
- 연속 편집 작업
- 메모리 누수 체크

## 향후 개선사항

1. **기능 추가**:
   - 스티커 라이브러리
   - 고급 필터 효과
   - AI 기반 편집 도구

2. **성능 개선**:
   - GPU 가속 활용
   - 더 효율적인 캐싱

3. **UX 개선**:
   - 편집 이력 시각화
   - 실시간 협업 편집
   - 튜토리얼 모드

## 라이선스 및 의존성

- **ProImageEditor**: [라이브러리 라이선스]
- **주요 의존성**:
  - image: 이미지 처리
  - path_provider: 파일 시스템 접근
  - permission_handler: 권한 관리