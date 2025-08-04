# Custom Code

FlutterFlow에서 지원하지 않는 고급 기능을 구현하기 위한 커스텀 코드 디렉토리입니다.

## 📋 개요

이 디렉토리는 원래 FlutterFlow의 커스텀 코드 기능을 위해 만들어졌으나, 네이티브 Flutter로 마이그레이션 후에도 특수 기능 구현을 위해 유지되고 있습니다.

## 디렉토리 구조

```
custom_code/
├── actions/                # 커스텀 액션 (비즈니스 로직)
│   ├── get_video_path.dart
│   └── index.dart
└── widgets/               # 커스텀 위젯 (UI 컴포넌트)
    ├── advanced_image_editor.dart
    ├── highlighted_text_field.dart
    ├── new_video_trimmer_page.dart
    └── index.dart
```

## Custom Actions

### get_video_path.dart
비디오 선택 및 경로 획득을 위한 액션입니다.

```dart
Future<String?> getVideoPath(BuildContext context) async {
  try {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5),
    );
    
    if (video != null) {
      return video.path;
    }
    return null;
  } catch (e) {
    print('비디오 선택 오류: $e');
    return null;
  }
}
```

**사용 예제:**
```dart
// 비디오 선택
final videoPath = await getVideoPath(context);
if (videoPath != null) {
  // AppState에 저장
  FFAppState().update(() {
    FFAppState().uploadVideoPath = videoPath;
  });
}
```

## Custom Widgets

### 1. AdvancedImageEditor
ProImageEditor를 통합한 고급 이미지 편집 위젯입니다.

```dart
AdvancedImageEditor(
  imageUrl: 'https://firebase-storage-url',
  onImageSaved: (editedImageUrl) {
    // 편집된 이미지 URL 처리
    setState(() {
      imageUrl = editedImageUrl;
    });
  },
)
```

**주요 기능:**
- 크롭/회전
- 필터 효과 (20+ 필터)
- 텍스트 오버레이
- 그리기 도구
- 스티커/이모지
- Firebase Storage 자동 업로드

**편집 플로우:**
1. Firebase URL에서 이미지 다운로드
2. ProImageEditor로 편집
3. 편집된 이미지 압축 (85% 품질)
4. Firebase Storage 업로드
5. 새 URL 콜백 반환

### 2. HighlightedTextField
텍스트 입력 시 하이라이트 효과를 제공하는 텍스트 필드입니다.

```dart
HighlightedTextField(
  onChanged: (text) => updateText(text),
  onFieldSubmitted: (text) => submitText(text),
  textStyle: TextStyle(fontSize: 16),
  hintText: '텍스트를 입력하세요',
  maxLength: 200,
  backgroundColor: Colors.grey[200],
  highlightColor: Colors.yellow.withOpacity(0.3),
)
```

**특징:**
- 입력 중 배경 하이라이트
- 글자 수 제한 표시
- 커스터마이징 가능한 스타일
- 포커스 애니메이션

**버그 수정 이력:**
- 투명 텍스트 버그 수정 (2025-07-03)
- 텍스트 색상 명시적 설정
- 하이라이트 레이어 분리

### 3. NewVideoTrimmerPage
비디오 편집 및 트리밍을 위한 전체 화면 위젯입니다.

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => NewVideoTrimmerPage(
      videoPath: '/path/to/video.mp4',
      videoMode: 'A', // 'A' 또는 'B'
    ),
  ),
);
```

**주요 기능:**
- 비디오 타임라인 표시
- 시작/종료 지점 선택
- 실시간 미리보기
- 커버 이미지 추출
- 트리밍 정보 저장

**AppState 통합:**
```dart
// 트리밍 완료 후 자동 저장
FFAppState().update(() {
  FFAppState().videoStartTime = startTime;
  FFAppState().videoEndTime = endTime;
  FFAppState().videoCoverImageBytes = coverImageBytes;
});
```

## 사용 가이드

### 1. Custom Action 사용
```dart
// 1. Import
import 'package:versus_space/custom_code/actions/index.dart';

// 2. 호출
final result = await customActionName(parameters);

// 3. 결과 처리
if (result != null) {
  // 성공 처리
}
```

### 2. Custom Widget 사용
```dart
// 1. Import
import 'package:versus_space/custom_code/widgets/index.dart';

// 2. 위젯 사용
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: CustomWidgetName(
      parameter1: value1,
      parameter2: value2,
      onCallback: (result) {
        // 콜백 처리
      },
    ),
  );
}
```

## 개발 규칙

### 1. 네이밍 컨벤션
- Actions: `actionName.dart` (camelCase)
- Widgets: `widget_name.dart` (snake_case)
- 클래스: `WidgetName` (PascalCase)

### 2. 파일 구조
```dart
// custom_widget.dart
import 'package:flutter/material.dart';
// 기타 imports

export 'custom_widget.dart' show CustomWidget;

class CustomWidget extends StatefulWidget {
  const CustomWidget({
    Key? key,
    required this.parameter,
    this.optionalParameter,
  }) : super(key: key);

  final String parameter;
  final String? optionalParameter;

  @override
  State<CustomWidget> createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<CustomWidget> {
  @override
  Widget build(BuildContext context) {
    // 위젯 구현
  }
}
```

### 3. Export 관리
```dart
// index.dart
export 'widget1.dart' show Widget1;
export 'widget2.dart' show Widget2;
export 'widget3.dart' show Widget3;
```

## 테스트

### Widget 테스트
```dart
testWidgets('CustomWidget 렌더링 테스트', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CustomWidget(
        parameter: 'test',
      ),
    ),
  );
  
  expect(find.text('test'), findsOneWidget);
});
```

### Action 테스트
```dart
test('getVideoPath 동작 테스트', () async {
  final path = await getVideoPath(context);
  expect(path, isNotNull);
  expect(path!.endsWith('.mp4'), isTrue);
});
```

## 마이그레이션 노트

### FlutterFlow → Native Flutter
1. **FFAppState** → **AppState**로 변경
2. **FlutterFlowTheme** → **VersusTheme**로 변경
3. **Navigator** 직접 사용 (FlutterFlow 네비게이션 제거)
4. **setState** 직접 호출 (FlutterFlow 래퍼 제거)

## 성능 고려사항

### 1. 이미지 처리
- 대용량 이미지는 압축 후 처리
- 메모리 효율적인 스트림 처리
- 캐싱 활용

### 2. 비디오 처리
- 청크 단위 처리
- 백그라운드 프로세싱
- 메모리 관리 철저

### 3. UI 반응성
- 무거운 작업은 isolate 사용
- 적절한 로딩 인디케이터
- 에러 상태 처리

## 향후 개선 사항

1. **코드 모듈화**
   - 공통 로직 분리
   - 유틸리티 함수 추출
   - 테스트 커버리지 향상

2. **기능 확장**
   - PDF 뷰어 위젯
   - 오디오 녹음 액션
   - 바코드 스캐너 위젯

3. **성능 최적화**
   - 이미지 처리 최적화
   - 비디오 스트리밍
   - 메모리 사용량 감소