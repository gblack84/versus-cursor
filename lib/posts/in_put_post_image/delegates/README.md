# 📸 In Put Post Image Delegates 디렉토리

> 이미지/카메라 피커의 UI 커스터마이징과 한국어 현지화를 담당하는 델리게이트 모음

## 📑 목차
- [개요](#개요)
- [네이밍 컨벤션](#네이밍-컨벤션)
- [주요 구성요소](#주요-구성요소)
- [델리게이트 상세](#델리게이트-상세)
- [사용 예시](#사용-예시)
- [델리게이트 패턴](#델리게이트-패턴)
- [의존성](#의존성)
- [변경 이력](#변경-이력)

## 🎯 개요

이 디렉토리는 WeChat Assets Picker와 Camera Picker의 커스터마이징을 위한 델리게이트 클래스들을 관리합니다. Flutter의 델리게이트 패턴을 활용하여 서드파티 라이브러리의 UI와 동작을 프로젝트 요구사항에 맞게 확장합니다.

### 주요 목적
- **한국어 현지화**: 모든 피커 UI를 한국어로 완전 번역
- **UI 커스터마이징**: 프로젝트 디자인 시스템과 일치하는 UI 구현
- **플로팅 버튼 추가**: 카메라 접근을 위한 추가적인 UI 요소
- **사용자 경험 개선**: 직관적인 한국어 인터페이스 제공

## 📐 네이밍 컨벤션

프로젝트 전체 네이밍 규칙을 따릅니다:

- **파일명**: snake_case (Dart 표준)
  - ✅ `korean_asset_picker_delegate.dart`
  - ✅ `camera_floating_button_delegate.dart`
  - ❌ `KoreanAssetPickerDelegate.dart`

- **클래스명**: PascalCase
  - ✅ `CustomKoreanAssetPickerTextDelegate`
  - ✅ `CameraFloatingButtonDelegate`

- **메서드/변수명**: camelCase
  - ✅ `onCameraPressed`
  - ✅ `shootingTips`

상세 내용: [NAMING_CONVENTION.md](../../../../NAMING_CONVENTION.md)

## 🔧 주요 구성요소

### 1. 델리게이트 구조
```
delegates/
├── camera_floating_button_delegate.dart  # UI 빌더 델리게이트
├── korean_asset_picker_delegate.dart     # 이미지 피커 텍스트 델리게이트
└── korean_camera_picker_delegate.dart    # 카메라 피커 텍스트 델리게이트
```

### 2. 델리게이트 타입별 분류

| 타입 | 파일 | 용도 | 상속 클래스 |
|-----|-----|-----|-----------|
| **UI 빌더** | camera_floating_button_delegate.dart | 커스텀 UI 레이아웃 | DefaultAssetPickerBuilderDelegate |
| **텍스트 현지화** | korean_asset_picker_delegate.dart | 이미지 피커 한국어화 | AssetPickerTextDelegate |
| **텍스트 현지화** | korean_camera_picker_delegate.dart | 카메라 피커 한국어화 | CameraPickerTextDelegate |

## 📋 델리게이트 상세

### CameraFloatingButtonDelegate
```dart
class CameraFloatingButtonDelegate extends DefaultAssetPickerBuilderDelegate {
  final Future<void> Function() onCameraPressed;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        super.build(context),  // 기본 피커 UI
        Positioned(
          bottom: 100,
          right: 16,
          child: FloatingActionButton(
            onPressed: onCameraPressed,
            child: Icon(Icons.camera_alt),
          ),
        ),
      ],
    );
  }
}
```

**특징:**
- 기본 피커 UI 위에 플로팅 카메라 버튼 추가
- Stack 위젯으로 레이어드 UI 구현
- 카메라 액션을 위한 콜백 처리
- Hero 애니메이션 태그 설정 ('camera_fab')

### CustomKoreanAssetPickerTextDelegate
```dart
class CustomKoreanAssetPickerTextDelegate extends AssetPickerTextDelegate {
  @override
  String get confirm => '확인';
  
  @override
  String get cancel => '취소';
  
  @override
  String get emptyList => '사진이 없습니다';
  
  @override
  String get accessAllTip => '앱이 일부 사진에만 접근 가능합니다.\n'
      '설정에서 모든 사진 접근을 허용해주세요.';
}
```

**번역 항목 (총 16개):**
- 기본 액션: 확인, 취소, 편집, 선택, 미리보기
- 상태 메시지: 로드 실패, 사진 없음, 원본
- 권한 관련: 접근 제한, 설정 이동, 권한 요청
- 특수 표시: GIF 인디케이터

### CustomKoreanCameraPickerTextDelegate
```dart
class CustomKoreanCameraPickerTextDelegate extends CameraPickerTextDelegate {
  @override
  String get shootingTips => '탭하여 사진 촬영, 길게 눌러 비디오 녹화';
  
  @override
  String sFlashModeLabel(FlashMode mode) {
    switch (mode) {
      case FlashMode.off: return '플래시 끄기';
      case FlashMode.auto: return '플래시 자동';
      case FlashMode.always: return '플래시 켜기';
      case FlashMode.torch: return '손전등';
    }
  }
  
  @override
  String sCameraLensDirectionLabel(CameraLensDirection value) {
    switch (value) {
      case CameraLensDirection.front: return '전면 카메라';
      case CameraLensDirection.back: return '후면 카메라';
      case CameraLensDirection.external: return '외부 카메라';
    }
  }
}
```

**번역 카테고리:**
- 촬영 안내: 사진/비디오 촬영 팁
- 플래시 모드: 4가지 모드 라벨
- 카메라 전환: 전면/후면/외부 카메라
- 상태 메시지: 로딩, 저장 중

## 💻 사용 예시

### 이미지 피커에 한국어 델리게이트 적용
```dart
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'delegates/korean_asset_picker_delegate.dart';

// 한국어 설정
final List<AssetEntity>? result = await AssetPicker.pickAssets(
  context,
  pickerConfig: AssetPickerConfig(
    maxAssets: 4,
    gridCount: 4,
    textDelegate: const CustomKoreanAssetPickerTextDelegate(),
    pickerTheme: ThemeData(
      primaryColor: Colors.black,
      scaffoldBackgroundColor: Colors.black,
    ),
  ),
);
```

### 플로팅 카메라 버튼 델리게이트 사용
```dart
import 'delegates/camera_floating_button_delegate.dart';

final pickerConfig = AssetPickerConfig(
  maxAssets: 1,
  gridCount: 4,
  textDelegate: const CustomKoreanAssetPickerTextDelegate(),
  // 커스텀 빌더 델리게이트 적용
  specialPickerType: SpecialPickerType.noPreview,
);

// 델리게이트 생성
final delegate = CameraFloatingButtonDelegate(
  provider: DefaultAssetPickerProvider(
    maxAssets: 1,
    requestType: RequestType.image,
  ),
  initialPermission: PermissionState.authorized,
  onCameraPressed: () async {
    // 카메라 실행 로직
    final AssetEntity? entity = await CameraPicker.pickFromCamera(
      context,
      pickerConfig: CameraPickerConfig(
        textDelegate: const CustomKoreanCameraPickerTextDelegate(),
      ),
    );
  },
);
```

### 카메라 피커 한국어 설정
```dart
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'delegates/korean_camera_picker_delegate.dart';

final AssetEntity? result = await CameraPicker.pickFromCamera(
  context,
  pickerConfig: CameraPickerConfig(
    enableRecording: true,
    maximumRecordingDuration: const Duration(seconds: 30),
    textDelegate: const CustomKoreanCameraPickerTextDelegate(),
    theme: ThemeData.dark(),
  ),
);
```

## 🏗️ 델리게이트 패턴

### 패턴 설명
델리게이트 패턴은 객체의 특정 책임을 다른 객체에 위임하는 디자인 패턴입니다. Flutter에서는 주로 UI 커스터마이징과 현지화에 사용됩니다.

### 구현 원리
```dart
// 1. 기본 델리게이트 상속
class CustomDelegate extends BaseDelegate {
  // 2. 필요한 메서드 오버라이드
  @override
  String get someText => '커스텀 텍스트';
  
  // 3. UI 빌드 메서드 재정의
  @override
  Widget build(BuildContext context) {
    return CustomWidget();
  }
}
```

### 장점
- **확장성**: 라이브러리 수정 없이 동작 변경
- **재사용성**: 여러 곳에서 동일한 델리게이트 사용
- **유지보수성**: 현지화 텍스트 중앙 관리
- **테스트 용이성**: 델리게이트 단위 테스트 가능

## 📦 의존성

### 외부 패키지
```yaml
dependencies:
  wechat_assets_picker: ^9.5.1
  wechat_camera_picker: ^4.3.1
```

### 내부 의존성
- flutter/material.dart (UI 컴포넌트)
- 없음 (독립적인 델리게이트 구현)

### 버전 호환성
- Flutter SDK: >=3.0.0
- Dart SDK: >=3.0.0
- iOS: >=11.0
- Android: minSdkVersion 21

## 🔄 변경 이력

### 2025-08-23
- 문서 전체 재작성
- 3개 델리게이트 파일 상세 문서화
- 사용 예시 및 패턴 설명 추가

### 주요 마이그레이션 이력
- **WeChat Picker 통합** (2025-07-04)
  - image_picker에서 wechat_assets_picker로 전환
  - 한국어 델리게이트 구현
  
- **플로팅 카메라 버튼 추가** (2025-07-06)
  - CameraFloatingButtonDelegate 구현
  - 시뮬레이터/실기기 분기 처리

- **카메라 피커 한국어화** (2025-07-08)
  - CustomKoreanCameraPickerTextDelegate 구현
  - 플래시 모드, 카메라 전환 텍스트 번역

## 📝 주요 규칙 및 가이드라인

### 델리게이트 추가 규칙
1. **명명 규칙**: `Custom[언어][피커타입]TextDelegate` 형식
2. **상속 체크**: 올바른 베이스 클래스 상속
3. **완전성**: 모든 필수 메서드 구현
4. **일관성**: 프로젝트 전체 텍스트 톤 유지

### 번역 가이드라인
- **간결성**: 짧고 명확한 표현 사용
- **일관성**: 동일 용어는 동일하게 번역
- **사용자 친화적**: 기술 용어 최소화
- **문맥 고려**: 화면 크기와 레이아웃 고려

### 테스트 체크리스트
- [ ] 모든 텍스트가 한국어로 표시되는지 확인
- [ ] 긴 텍스트가 UI를 깨뜨리지 않는지 확인
- [ ] iOS/Android 양 플랫폼에서 동작 확인
- [ ] 권한 다이얼로그 텍스트 확인
- [ ] 에러 메시지 표시 확인

## 🚀 향후 개선 사항

### 계획된 개선
- [ ] 다국어 지원 확장 (영어, 독일어)
- [ ] 동적 테마 적용 델리게이트
- [ ] 애니메이션 커스터마이징
- [ ] 접근성 개선

### 성능 최적화
- [ ] 썸네일 로딩 최적화
- [ ] 메모리 사용량 모니터링
- [ ] 대량 이미지 처리 개선

### UX 개선
- [ ] 선택 피드백 개선
- [ ] 로딩 인디케이터 커스터마이징
- [ ] 에러 처리 UX 개선