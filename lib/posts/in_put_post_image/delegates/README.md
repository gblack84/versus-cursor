# Delegates Directory

## 개요 (Overview)

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **필드명**: camelCase
- 참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)
이 디렉토리는 wechat_assets_picker의 커스터마이징을 위한 델리게이트 클래스들을 포함합니다. 주로 UI 커스터마이징과 한국어 지원을 담당합니다.

## 파일 설명 (File Descriptions)

### korean_asset_picker_delegate.dart
- **역할**: wechat_assets_picker의 한국어 텍스트 델리게이트
- **주요 기능**:
  - 모든 UI 텍스트를 한국어로 번역
  - 버튼, 라벨, 에러 메시지 등 현지화
- **주요 번역**:
  ```dart
  '확인' // Confirm
  '선택' // Select
  '모든 사진' // All photos
  '권한이 필요합니다' // Permission required
  ```
- **사용처**: AssetPicker 설정에서 textDelegate로 지정

### camera_floating_button_delegate.dart
- **역할**: 카메라 플로팅 버튼을 커스터마이징하는 델리게이트
- **주요 기능**:
  - 카메라 버튼 위치 조정
  - 커스텀 스타일 적용
  - 플로팅 버튼 동작 정의
- **특징**:
  - 시뮬레이터에서는 카메라 버튼 숨김
  - 실제 기기에서만 표시

### korean_camera_picker_delegate.dart
- **역할**: 카메라 피커의 한국어 지원
- **주요 기능**:
  - 카메라 UI 텍스트 한국어화
  - 촬영 관련 안내 메시지
- **주요 번역**:
  ```dart
  '사진 촬영' // Take photo
  '동영상 촬영' // Record video
  '취소' // Cancel
  ```

## 델리게이트 시스템 이해

### AssetPickerBuilderDelegate
```dart
// 기본 구조
class CustomPickerDelegate extends AssetPickerBuilderDelegate {
  // UI 빌드 메서드 오버라이드
  @override
  Widget build(BuildContext context) {
    // 커스텀 UI 구현
  }
}
```

### AssetPickerTextDelegate
```dart
// 텍스트 델리게이트 구조
class KoreanAssetPickerTextDelegate extends AssetPickerTextDelegate {
  @override
  String get confirm => '확인';
  
  @override
  String get cancel => '취소';
  // ... 기타 텍스트
}
```

## 사용 예시

### 한국어 피커 설정
```dart
final config = AssetPickerConfig(
  textDelegate: KoreanAssetPickerTextDelegate(),
  // 기타 설정...
);

final List<AssetEntity>? result = await AssetPicker.pickAssets(
  context,
  pickerConfig: config,
);
```

### 커스텀 카메라 버튼
```dart
final config = AssetPickerConfig(
  specialPickerType: SpecialPickerType.noPreview,
  pickerTheme: customTheme,
  // 카메라 버튼 델리게이트 적용
);
```

## 커스터마이징 포인트

### UI 커스터마이징
1. **색상 테마**:
   - 배경색: 검은색
   - 강조색: 프로젝트 primary 색상
   - 텍스트: 흰색

2. **레이아웃**:
   - 그리드 컬럼 수: 4
   - 썸네일 간격 조정
   - 선택 표시 스타일

3. **동작**:
   - 최대 선택 수 제한
   - 선택 시 애니메이션
   - 확인 버튼 활성화 조건

### 텍스트 커스터마이징
- 모든 시스템 텍스트 한국어화
- 상황별 안내 메시지
- 에러 메시지 현지화

## 주의사항

1. **플랫폼 차이**:
   - iOS와 Android의 권한 메시지 차이
   - 카메라 가용성 체크

2. **버전 호환성**:
   - wechat_assets_picker 버전에 따른 API 변경
   - Flutter 버전과의 호환성

3. **성능 고려**:
   - 대량 이미지 로드 시 메모리 관리
   - 썸네일 캐싱 전략

## 확장 가능성

### 추가 커스터마이징
1. **애니메이션**:
   - 선택 시 커스텀 애니메이션
   - 페이지 전환 효과

2. **필터**:
   - 파일 타입별 필터링
   - 날짜별 그룹화

3. **고급 기능**:
   - 멀티 선택 제스처
   - 드래그 앤 드롭 정렬

## 디버깅 팁

1. **권한 문제**:
   ```dart
   // 권한 상태 확인
   final status = await Permission.photos.status;
   print('Photo permission: $status');
   ```

2. **델리게이트 동작 확인**:
   - 각 메서드에 로그 추가
   - UI 빌드 과정 추적

3. **현지화 테스트**:
   - 다양한 언어 설정에서 테스트
   - 긴 텍스트 처리 확인