# Widgets Directory

## 개요 (Overview)

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **필드명**: camelCase
- 참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)
이 디렉토리는 복잡한 기능을 수행하는 복합 위젯들을 포함합니다. 주로 전체 화면이나 모달, 플로우를 담당하는 위젯들입니다.

## 파일 설명 (File Descriptions)

### media_selection_flow_widget.dart
- **역할**: 이미지 선택 전체 플로우를 관리하는 위젯
- **주요 기능**:
  - wechat_assets_picker 통합
  - 이미지 선택 → 검열 → 업로드 플로우
  - 멀티 이미지 및 썸네일 모드 지원
  - 로딩 상태 관리
- **플로우**:
  ```
  피커 열기 → 이미지 선택 → 
  로딩 표시 → 업로드/검열 → 
  결과 처리 → UI 업데이트
  ```
- **모드**:
  - 일반 모드: 새 이미지 선택
  - 추가 모드: 기존 이미지에 추가
  - 썸네일 모드: 대표 이미지 선택

### media_editor_widget.dart
- **역할**: ProImageEditor를 래핑한 이미지 편집 위젯
- **주요 기능**:
  - Firebase URL에서 이미지 다운로드
  - ProImageEditor 호출
  - 편집 완료 후 재업로드
  - 재검열 처리
- **커스터마이징**:
  - Blur 메뉴 비활성화
  - Paint 도구 일부 제거
  - 한국어 UI 적용
- **네비게이션**:
  - "< 갤러리" 버튼
  - "< 썸네일" 버튼

### thumbnail_navigation_helper.dart
- **역할**: 썸네일 페이지 네비게이션 헬퍼
- **주요 기능**:
  - 커스텀 네비게이션 버튼
  - 검은색 둥근 배경 스타일
  - 텍스트 기반 버튼

### dialogs/ (하위 디렉토리)
- 다양한 다이얼로그 위젯들
- 미디어 타입 선택
- 에러 메시지 표시
- 확인 다이얼로그

## 주요 위젯 상호작용

### 이미지 선택 → 편집 플로우
```
InPutPostImageWidget
    ↓ (이미지 아이콘 클릭)
MediaSelectionFlowWidget
    ↓ (이미지 선택)
ImageUploadOrchestratorV2 (서비스)
    ↓ (편집 버튼 클릭)
MediaEditorWidget
    ↓ (편집 완료)
재업로드 및 UI 업데이트
```

### 검열 처리 플로우
```
MediaSelectionFlowWidget
    ↓
이미지 업로드
    ↓
검열 API 호출
    ↓
결과에 따른 처리:
- 전체 승인: UI 업데이트
- 부분 거부: 승인된 것만 저장
- 전체 거부: 재선택 유도
```

## 사용 예시

### MediaSelectionFlowWidget 사용
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => MediaSelectionFlowWidget(
    box: 'A',
    maxAssets: 4,
    isAddMode: hasExistingImages,
    isThumbnailMode: false,
    existingAssetIds: appState.assetEntityIdsA,
    onError: (error) => showErrorDialog(error),
  ),
);
```

### MediaEditorWidget 사용
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => MediaEditorWidget(
      imageUrl: firebaseUrl,
      box: 'A',
      isEditMode: true,
      currentIndex: 0,
    ),
  ),
);
```

## 상태 관리

### MediaSelectionFlowWidget
- **로컬 상태**:
  - 선택된 AssetEntity 리스트
  - 로딩 상태
  - 에러 메시지
- **AppState 업데이트**:
  - 이미지 파일
  - Firebase URL
  - AssetEntity ID
  - 이미지 비율

### MediaEditorWidget
- **편집 상태**:
  - 원본 이미지
  - 편집된 이미지
  - 편집 모드 플래그
- **결과 처리**:
  - 성공: AppState 업데이트
  - 취소: 변경 없음
  - 에러: Toast 메시지

## UI/UX 고려사항

### 로딩 표시
- 이미지 업로드 중: 프로그레스 인디케이터
- 검열 중: "안전성 검사 중..." 메시지
- 편집 저장 중: 로딩 오버레이

### 에러 처리
- 네트워크 에러: 재시도 옵션
- 검열 거부: 구체적인 이유 표시
- 업로드 실패: 사용자 친화적 메시지

### 접근성
- 모든 버튼에 적절한 라벨
- 충분한 터치 영역
- 명확한 시각적 피드백

## 성능 최적화

### 이미지 처리
- 편집 전 이미지 다운샘플링
- 메모리 효율적인 처리
- 불필요한 재렌더링 방지

### 비동기 처리
- 병렬 업로드로 시간 단축
- 취소 가능한 작업
- 적절한 타임아웃 설정

## 중요 사항

1. **모달 관리**:
   - `isScrollControlled: true` 필수
   - 투명 배경으로 커스텀 디자인
   - 적절한 dismiss 처리

2. **네비게이션**:
   - 편집 완료 후 자동으로 이전 화면 복귀
   - 딥 링크 지원 고려

3. **메모리 관리**:
   - 대용량 이미지 처리 시 주의
   - 위젯 dispose 시 리소스 정리

4. **플랫폼 차이**:
   - iOS: 사진 접근 권한 필수
   - Android: 스토리지 권한 체크

## 테스트 포인트

1. **이미지 선택**:
   - 단일/멀티 선택
   - 취소 처리
   - 권한 거부 시나리오

2. **편집 기능**:
   - 다양한 편집 도구 테스트
   - 메모리 부족 상황
   - 큰 이미지 처리

3. **검열 시나리오**:
   - 전체 승인
   - 부분 거부
   - 네트워크 오류