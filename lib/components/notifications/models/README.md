# Notification Models - 알림 시스템 데이터 모델

투표 알림 시스템에서 사용되는 데이터 모델과 타입 정의를 관리하는 디렉토리입니다.

## 📋 개요

이 디렉토리는 Versus Space 앱의 투표 알림 시스템에서 질문 작성 페이지와 알림 UI 간의 데이터 전달을 위한 모델 클래스를 포함합니다. 주로 A/B 박스의 크기, 레이아웃, 이미지 비율 등의 정보를 구조화하여 저장하고 전달하는 역할을 담당합니다.

### 주요 특징
- **레이아웃 정보 보존**: 질문 작성 시의 박스 크기와 배치 저장
- **이미지 비율 관리**: A/B 각 옵션의 이미지 aspect ratio 추적
- **JSON 직렬화**: Firestore 저장을 위한 직렬화/역직렬화
- **유효성 검증**: 데이터 무결성 확인 메서드
- **헬퍼 프로퍼티**: 상태 확인을 위한 편의 기능
- **불변성 패턴**: copyWith 메서드로 안전한 데이터 수정

## 🎯 네이밍 컨벤션

### 파일명
- **Dart 파일**: snake_case (`versus_box_size_data.dart`)
- **README**: 대문자 확장자 (`README.md`)

### 코드 내 명명 규칙
- **클래스명**: PascalCase (`VersusBoxSizeData`)
- **프로퍼티**: lowerCamelCase (`layoutType`, `aspectRatioA`)
- **메서드**: lowerCamelCase (`fromJson`, `toJson`, `copyWith`)
- **팩토리 생성자**: lowerCamelCase (`fromCurrentState`, `fromJson`)

참조: [NAMING_CONVENTION.md](../../../../NAMING_CONVENTION.md)

## 🔧 주요 구성요소

### VersusBoxSizeData 클래스
**파일**: `versus_box_size_data.dart`  
**용도**: 투표 알림에서 질문 작성 시의 A/B 박스 레이아웃을 재현하기 위한 데이터 모델

#### 핵심 프로퍼티

| 프로퍼티 | 타입 | 설명 |
|---------|------|------|
| `layoutType` | LayoutType | 레이아웃 배치 (horizontal/vertical/single) |
| `aspectRatioA` | double? | A 이미지의 가로/세로 비율 |
| `aspectRatioB` | double? | B 이미지의 가로/세로 비율 |
| `originalSizeA` | Size | 질문 작성 시 A 박스 크기 |
| `originalSizeB` | Size | 질문 작성 시 B 박스 크기 |
| `screenWidth` | double | 질문 작성 시 화면 너비 |
| `createdAt` | DateTime | 데이터 생성 시간 |
| `hasImageA` | bool | A 박스 이미지 유무 |
| `hasImageB` | bool | B 박스 이미지 유무 |

#### LayoutType Enum
```dart
enum LayoutType {
  horizontal,  // 가로 배치 (좌/우)
  vertical,    // 세로 배치 (위/아래)
  single       // 단일 박스 (A만 표시)
}
```

#### 생성자 패턴

##### 기본 생성자
```dart
const VersusBoxSizeData({
  required this.layoutType,
  this.aspectRatioA,
  this.aspectRatioB,
  required this.originalSizeA,
  required this.originalSizeB,
  required this.screenWidth,
  required this.createdAt,
  this.hasImageA = false,
  this.hasImageB = false,
})
```

##### 팩토리 생성자 - 현재 상태에서 생성
```dart
factory VersusBoxSizeData.fromCurrentState({
  required BuildContext context,
  required LayoutType layoutType,
  List<double>? aspectRatiosA,
  List<double>? aspectRatiosB,
  required Size boxSizeA,
  required Size boxSizeB,
})
```

##### 팩토리 생성자 - JSON에서 복원
```dart
factory VersusBoxSizeData.fromJson(Map<String, dynamic> json)
```

#### 핵심 메서드

##### JSON 직렬화
```dart
Map<String, dynamic> toJson() {
  return {
    'layoutType': layoutType.name,
    'aspectRatioA': aspectRatioA,
    'aspectRatioB': aspectRatioB,
    'originalSizeA': {
      'width': originalSizeA.width,
      'height': originalSizeA.height,
    },
    // ...
  };
}
```

##### 데이터 복사
```dart
VersusBoxSizeData copyWith({
  LayoutType? layoutType,
  double? aspectRatioA,
  // ... 모든 필드 선택적 수정 가능
})
```

#### 헬퍼 프로퍼티

| 프로퍼티 | 반환 타입 | 설명 |
|---------|-----------|------|
| `isValid` | bool | 데이터 유효성 확인 |
| `isAOnly` | bool | A 박스만 있는지 |
| `isBOnly` | bool | B 박스만 있는지 |
| `hasBothImages` | bool | 둘 다 이미지가 있는지 |
| `hasNoImages` | bool | 이미지가 없는지 |
| `orientationA` | ImageOrientation? | A 이미지 방향 (portrait/landscape) |
| `orientationB` | ImageOrientation? | B 이미지 방향 (portrait/landscape) |

## 💡 사용 예시

### 질문 작성 시 데이터 생성

```dart
// InPutPostImageWidget에서 투표 생성 시
final sizeData = VersusBoxSizeData.fromCurrentState(
  context: context,
  layoutType: currentLayoutType,
  aspectRatiosA: appState.uploadImageAspectRatioA,
  aspectRatiosB: appState.uploadImageAspectRatioB,
  boxSizeA: Size(boxWidthA, boxHeightA),
  boxSizeB: Size(boxWidthB, boxHeightB),
);

// Firestore에 저장
await FirebaseFirestore.instance
  .collection('posts')
  .doc(postId)
  .update({
    'boxSizeData': sizeData.toJson(),
  });
```

### 알림 표시 시 데이터 복원

```dart
// VotingNotificationDialog에서 사용
class VotingNotificationDialog extends StatelessWidget {
  final Map<String, dynamic> postData;
  
  @override
  Widget build(BuildContext context) {
    // JSON에서 복원
    final sizeData = postData['boxSizeData'] != null
      ? VersusBoxSizeData.fromJson(postData['boxSizeData'])
      : null;
    
    // 레이아웃 타입에 따른 UI 구성
    if (sizeData?.layoutType == LayoutType.horizontal) {
      return Row(
        children: [
          _buildBoxA(sizeData!.originalSizeA),
          SizedBox(width: 8),
          _buildBoxB(sizeData.originalSizeB),
        ],
      );
    } else if (sizeData?.layoutType == LayoutType.vertical) {
      return Column(
        children: [
          _buildBoxA(sizeData!.originalSizeA),
          SizedBox(height: 8),
          _buildBoxB(sizeData.originalSizeB),
        ],
      );
    }
    // ...
  }
}
```

### 유효성 검사

```dart
// 데이터 사용 전 유효성 확인
if (sizeData.isValid) {
  // 안전하게 사용
  final ratioA = sizeData.aspectRatioA ?? 1.0;
  final orientationA = sizeData.orientationA;
  
  if (sizeData.hasBothImages) {
    // A/B 둘 다 이미지가 있는 경우
    _showDualImageLayout(sizeData);
  } else if (sizeData.isAOnly) {
    // A만 있는 경우
    _showSingleImageLayout(sizeData);
  }
}
```

### 데이터 수정

```dart
// 불변성을 유지하며 일부 필드 수정
final updatedData = sizeData.copyWith(
  layoutType: LayoutType.vertical,
  aspectRatioB: 1.5,
  hasImageB: true,
);

// 원본 데이터는 변경되지 않음
print(sizeData.layoutType);      // horizontal
print(updatedData.layoutType);   // vertical
```

### 디버깅

```dart
// 디버그 출력
print(sizeData);
// 출력: VersusBoxSizeData(
//   layout: horizontal,
//   ratioA: 1.5,
//   ratioB: 0.75,
//   sizeA: Size(200.0, 150.0),
//   sizeB: Size(200.0, 267.0),
//   screenWidth: 375.0,
//   hasImages: A=true B=true
// )
```

## 🎨 데이터 플로우

```
질문 작성 페이지 (InPutPostImageWidget)
    ↓
[VersusBoxSizeData 생성]
    ↓
Firestore 저장 (toJson)
    ↓
알림 시스템 (NotificationService)
    ↓
[VersusBoxSizeData 복원] (fromJson)
    ↓
알림 UI (VotingNotificationDialog)
```

### 데이터 생성 시점
1. **질문 작성 완료**: 사용자가 '다음' 버튼 클릭
2. **레이아웃 분석**: AspectRatioAnalyzer가 최적 레이아웃 결정
3. **박스 크기 계산**: DynamicBoxCalculator가 크기 계산
4. **데이터 객체 생성**: VersusBoxSizeData.fromCurrentState()
5. **Firestore 저장**: JSON 직렬화 후 posts 컬렉션에 저장

### 데이터 소비 시점
1. **알림 트리거**: 새 투표 생성 시 알림 발송
2. **데이터 로드**: Firestore에서 post 문서 읽기
3. **모델 복원**: VersusBoxSizeData.fromJson()
4. **UI 렌더링**: 레이아웃 타입과 크기 정보로 UI 구성
5. **반응형 조정**: 현재 화면 크기에 맞춰 스케일링

## ⚡ 성능 최적화

### 불변성 패턴
```dart
// copyWith 메서드로 새 인스턴스 생성
// 원본 데이터 보존으로 예측 가능한 상태 관리
final newData = originalData.copyWith(
  layoutType: LayoutType.vertical,
);
```

### 효율적인 직렬화
```dart
// null 값 처리 최적화
'aspectRatioA': aspectRatioA,  // null이면 자동 제외
'aspectRatioB': aspectRatioB,
```

### 캐싱 전략
```dart
// 자주 사용되는 계산값 캐싱
class NotificationWidget extends StatefulWidget {
  late final VersusBoxSizeData? sizeData;
  
  @override
  void initState() {
    super.initState();
    // 한 번만 파싱
    sizeData = widget.postData['boxSizeData'] != null
      ? VersusBoxSizeData.fromJson(widget.postData['boxSizeData'])
      : null;
  }
}
```

## 🔗 관련 파일

### 의존성
- `/lib/posts/in_put_post_image/helpers/aspect_ratio_analyzer.dart` - 이미지 비율 분석
- `flutter/material.dart` - Size, BuildContext 등 Flutter 타입

### 사용처
- `/lib/posts/in_put_post_image/in_put_post_image_widget.dart` - 데이터 생성
- `/lib/components/notifications/widgets/voting_notification_dialog.dart` - 데이터 소비
- `/lib/services/notification_service.dart` - 데이터 전달

### 연관 모듈
- `/lib/components/notifications/constants/` - 크기 제약 조건
- `/lib/components/notifications/utils/` - 박스 크기 계산 유틸리티

## 📊 아키텍처

```
VersusBoxSizeData
├── 레이아웃 정보
│   ├── layoutType (horizontal/vertical/single)
│   ├── screenWidth (원본 화면 너비)
│   └── createdAt (생성 시간)
├── 박스 크기
│   ├── originalSizeA (A 박스 크기)
│   └── originalSizeB (B 박스 크기)
├── 이미지 정보
│   ├── aspectRatioA (A 이미지 비율)
│   ├── aspectRatioB (B 이미지 비율)
│   ├── hasImageA (A 이미지 유무)
│   └── hasImageB (B 이미지 유무)
└── 유틸리티
    ├── toJson() (직렬화)
    ├── fromJson() (역직렬화)
    ├── copyWith() (복사)
    └── 헬퍼 프로퍼티들
```

## 🐛 문제 해결

### JSON 파싱 에러
```dart
// 문제: type 'int' is not a subtype of type 'double'
// 해결: 명시적 타입 변환
aspectRatioA: json['aspectRatioA']?.toDouble(),  // .toDouble() 추가
```

### Null 안전성 처리
```dart
// 문제: The property 'aspectRatioA' can't be unconditionally accessed
// 해결: null 체크 후 사용
if (sizeData.aspectRatioA != null) {
  final ratio = sizeData.aspectRatioA!;
  // 안전하게 사용
}
```

### 레이아웃 타입 복원 실패
```dart
// 문제: Invalid argument: No enum value with that name
// 해결: orElse 제공
layoutType: LayoutType.values.firstWhere(
  (e) => e.name == json['layoutType'],
  orElse: () => LayoutType.horizontal,  // 기본값
)
```

### 멀티 이미지 처리
```dart
// 문제: 여러 이미지 중 어떤 비율을 사용할지
// 해결: 첫 번째 이미지를 대표값으로 사용
final aspectRatioA = aspectRatiosA?.isNotEmpty == true 
  ? aspectRatiosA!.first 
  : null;
```

## 📝 변경 이력

- **2025-08-22**: 문서 전체 작성 및 코드 분석 완료
- **2025-08-04**: VersusBoxSizeData 모델 클래스 생성
  - 레이아웃 정보 저장 기능 추가
  - JSON 직렬화/역직렬화 구현
  - 헬퍼 메서드 및 유효성 검사 추가
- **2025-08-03**: 초기 디렉토리 생성
  - 알림 시스템 데이터 모델 분리

---

*이 문서는 `/lib/components/notifications/models` 디렉토리의 알림 시스템 데이터 모델을 설명합니다.*