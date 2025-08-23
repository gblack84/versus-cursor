# 🎨 InPutPostImage Dialogs 위젯 디렉토리

> 이미지 게시물 작성 과정에서 사용되는 다이얼로그 컴포넌트 모음

## 🎯 개요

이 디렉토리는 이미지 게시물 작성 플로우에서 사용되는 모든 다이얼로그 위젯을 포함합니다. AI 콘텐츠 검열, 타겟 오디언스 설정 등 사용자 상호작용이 필요한 모든 모달 인터페이스를 관리합니다.

### 주요 특징
- 🛡️ **AI 콘텐츠 검열**: 이미지 안전성 검사 및 피드백
- 🎯 **타겟 오디언스 설정**: 다단계 투표 대상 설정 플로우
- 🎨 **일관된 디자인**: AppTheme 기반 통일된 UI
- ⚡ **애니메이션 효과**: 부드러운 전환과 시각적 피드백
- 🔒 **PopScope 보호**: 중요 작업 중 뒤로가기 방지

## 📐 네이밍 컨벤션

| 구분 | 규칙 | 예시 |
|------|------|------|
| **파일명** | snake_case | `moderation_dialog.dart` |
| **클래스명** | PascalCase | `ModerationDialog` |
| **메서드명** | camelCase | `show()` |
| **변수명** | camelCase | `currentIndex` |
| **상수** | camelCase | `dialogWidth` |
| **헬퍼 메서드** | static show() | `ModerationDialog.show()` |

> 상세 규칙은 [프로젝트 네이밍 컨벤션](../../../../NAMING_CONVENTION.md) 참조

## 📁 디렉토리 구조

```
dialogs/
├── moderation_dialog.dart              # AI 검열 진행 표시
├── moderation_error_dialog.dart        # 검열 실패 경고
├── target_audience_dialog.dart         # 타겟 설정 메인 다이얼로그
├── target_audience_steps/              # 타겟 설정 단계별 UI
│   ├── collection_type_selector.dart   # Step 1: 수집 방식
│   ├── target_count_selector.dart      # Step 2: 목표 응답 수
│   ├── detailed_target_selector.dart   # Step 3: 세부 타겟
│   └── README.md                       # 하위 디렉토리 문서
└── README.md                           # 현재 문서
```

## 🔧 주요 구성요소

### 1. ModerationDialog (`moderation_dialog.dart`)

#### 개요
이미지 AI 검열이 진행되는 동안 표시되는 로딩 다이얼로그입니다. 사용자가 작업을 취소할 수 없도록 보호합니다.

#### 주요 기능
- **진행 상태 표시**: CircularProgressIndicator로 로딩 표시
- **멀티 이미지 지원**: 전체 개수 중 현재 진행 상황 표시
- **뒤로가기 방지**: PopScope로 다이얼로그 보호
- **반투명 배경**: 검은색 87% 투명도로 몰입감 제공

#### 핵심 구성

##### UI 구조
```dart
Widget build(BuildContext context) {
  return PopScope(
    canPop: false,  // 뒤로가기 방지
    child: Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            Text('안전성 검사 중...'),
            if (totalCount > 1)
              Text('$currentIndex/$totalCount 검열 중'),
          ],
        ),
      ),
    ),
  );
}
```

##### 헬퍼 메서드
```dart
static void show({
  required BuildContext context,
  required int currentIndex,
  required int totalCount,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => ModerationDialog(
      currentIndex: currentIndex,
      totalCount: totalCount,
    ),
  );
}
```

#### 사용 예시
```dart
// 검열 시작 시
ModerationDialog.show(
  context: context,
  currentIndex: 1,
  totalCount: 3,
);

// 검열 완료 후
Navigator.pop(context);
```

### 2. ModerationErrorDialog (`moderation_error_dialog.dart`)

#### 개요
이미지 검열 실패 시 사용자에게 경고를 표시하고 재시도 옵션을 제공하는 다이얼로그입니다.

#### 주요 기능
- **경고 아이콘**: 빨간색 경고 아이콘으로 시각적 알림
- **거부 이유 표시**: AI가 판단한 부적절한 콘텐츠 이유 표시
- **재시도 옵션**: 다른 이미지 선택을 위한 콜백 제공
- **강제 표시**: barrierDismissible false로 확인 필수

#### 핵심 구성

##### UI 레이아웃
```dart
AlertDialog(
  backgroundColor: secondaryBackground,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),
  title: Row(
    children: [
      Icon(Icons.warning_amber_rounded, color: error),
      Text('부적절한 콘텐츠'),
    ],
  ),
  content: Text('$reason\n다른 이미지를 선택해주세요.'),
  actions: [
    TextButton(
      onPressed: () {
        Navigator.pop(context);
        onRetry?.call();
      },
      child: Text('다시 선택'),
    ),
  ],
)
```

##### 콜백 처리
```dart
ModerationErrorDialog.show(
  context: context,
  reason: '선정적 콘텐츠가 감지되었습니다',
  box: 'A',
  onRetry: () {
    // 이미지 피커 재실행
    _reopenImagePicker();
  },
);
```

### 3. TargetAudienceDialog (`target_audience_dialog.dart`)

#### 개요
투표 타겟 오디언스를 설정하는 메인 다이얼로그로, PageView를 사용한 다단계 플로우를 관리합니다.

#### 주요 기능
- **다단계 플로우**: 2-3단계의 동적 설정 프로세스
- **스텝 인디케이터**: 현재 진행 상황 시각화
- **애니메이션 전환**: FadeTransition과 PageView 애니메이션
- **상태 관리**: Provider 패턴으로 중앙 집중식 관리
- **조건부 단계**: 수집 방식에 따른 동적 단계 조정

#### 핵심 구성

##### 다이얼로그 구조
```dart
Dialog(
  backgroundColor: Colors.transparent,
  child: FadeTransition(
    opacity: _fadeAnimation,
    child: Container(
      constraints: BoxConstraints(
        maxHeight: dialogMaxHeight,
        maxWidth: dialogWidth,
      ),
      child: Column(
        children: [
          _buildStepIndicator(model),     // 상단 진행 표시
          Flexible(
            child: PageView(               // 단계별 컨텐츠
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                CollectionTypeSelector(),
                TargetCountSelector(),
                DetailedTargetSelector(),
              ],
            ),
          ),
          _buildBottomButtons(model),     // 하단 버튼
        ],
      ),
    ),
  ),
)
```

##### 스텝 인디케이터
```dart
Widget _buildStepIndicator(TargetAudienceModel model) {
  final totalSteps = model.collectionType == 'custom' ? 3 : 2;
  
  return Row(
    children: List.generate(totalSteps, (index) {
      final isActive = index <= model.currentStep;
      final isCompleted = index < model.currentStep;
      
      return Container(
        decoration: BoxDecoration(
          color: isActive ? primary : secondaryText,
          shape: BoxShape.circle,
        ),
        child: isCompleted 
            ? Icon(Icons.check)
            : Text('${index + 1}'),
      );
    }),
  );
}
```

##### 플로우 제어
```dart
void _goToNextStep(TargetAudienceModel model) {
  // Custom이 아닌 경우 2단계에서 완료
  if (model.collectionType != 'custom' && model.currentStep == 1) {
    _completeSetup(model);
    return;
  }
  
  // 다음 단계로 이동
  if (model.currentStep < 2) {
    model.currentStep++;
    _pageController.animateToPage(
      model.currentStep,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  } else {
    _completeSetup(model);
  }
}
```

#### 사용 예시
```dart
// 다이얼로그 표시 및 결과 받기
final result = await TargetAudienceDialog.show(context);

if (result != null) {
  print('수집 방식: ${result['type']}');
  print('목표 수: ${result['targetCount']}');
  print('관심사: ${result['interests']}');
  print('연령대: ${result['ageGroup']}');
  print('성별: ${result['gender']}');
}
```

## 💡 통합 사용 예시

### 전체 플로우 예시
```dart
class ImagePostCreator {
  Future<void> createPost() async {
    // 1. 이미지 선택
    final images = await _selectImages();
    
    // 2. AI 검열 시작
    ModerationDialog.show(
      context: context,
      currentIndex: 1,
      totalCount: images.length,
    );
    
    try {
      // 3. 검열 수행
      await _moderateImages(images);
      Navigator.pop(context);  // 검열 다이얼로그 닫기
      
      // 4. 타겟 오디언스 설정
      final targetAudience = await TargetAudienceDialog.show(context);
      
      if (targetAudience != null) {
        // 5. 게시물 생성
        await _createPost(images, targetAudience);
      }
    } catch (e) {
      Navigator.pop(context);  // 검열 다이얼로그 닫기
      
      // 검열 실패 처리
      ModerationErrorDialog.show(
        context: context,
        reason: e.toString(),
        box: 'A',
        onRetry: () => createPost(),  // 재시도
      );
    }
  }
}
```

### 개별 다이얼로그 사용
```dart
// 검열 다이얼로그만 사용
void showModerationOnly() {
  ModerationDialog.show(
    context: context,
    currentIndex: 1,
    totalCount: 1,
  );
  
  // 작업 수행...
  Future.delayed(Duration(seconds: 2), () {
    Navigator.pop(context);
  });
}

// 에러 다이얼로그만 사용
void showErrorOnly() {
  ModerationErrorDialog.show(
    context: context,
    reason: '부적절한 콘텐츠가 감지되었습니다',
    box: 'B',
    onRetry: null,  // 재시도 없음
  );
}

// 타겟 설정만 사용
void showTargetOnly() async {
  final result = await TargetAudienceDialog.show(context);
  if (result != null) {
    _processTargetAudience(result);
  }
}
```

## 🎨 UI/UX 특징

### 시각적 일관성
- **색상 체계**: AppTheme 기반 다크/라이트 모드 지원
- **모서리 반경**: 16-20px의 일관된 BorderRadius
- **그림자 효과**: 20px blur의 부드러운 그림자
- **투명도**: 배경 87%, 오버레이 20% 표준화

### 애니메이션
- **페이드 인/아웃**: 300ms FadeTransition
- **페이지 전환**: Curves.easeInOut 곡선
- **스텝 전환**: AnimatedContainer로 부드러운 변화
- **버튼 상태**: Enable/Disable 상태 전환

### 접근성
- **터치 타겟**: 최소 44px 크기 유지
- **명확한 레이블**: 모든 버튼과 옵션에 설명
- **피드백**: 즉각적인 시각적/촉각적 응답
- **에러 메시지**: 명확한 문제 설명과 해결 방법

## 📊 상태 관리

### Provider 패턴
```dart
// TargetAudienceModel 제공
ChangeNotifierProvider(
  create: (_) => TargetAudienceModel(),
  child: Consumer<TargetAudienceModel>(
    builder: (context, model, child) {
      // model 상태 사용
      return TargetAudienceDialog();
    },
  ),
)
```

### 상태 전파
```dart
// 상태 변경 알림
void updateCollectionType(String type) {
  collectionType = type;
  notifyListeners();  // UI 자동 업데이트
}
```

## 🐛 디버그 로깅

### 로그 패턴
```dart
debugPrint('[TargetAudienceDialog] 동작: 상세 정보');
debugPrint('[TargetAudienceDialog]   - 파라미터: 값');
```

### 주요 로그 포인트
- 다이얼로그 열기/닫기
- 단계 전환
- 사용자 선택
- 최종 결과

## 🔄 변경 이력

### v1.2.0 (2025-08-15)
- 타겟 오디언스 다단계 플로우 구현
- 조건부 단계 로직 추가
- 애니메이션 효과 강화

### v1.1.0 (2025-08-10)
- AI 검열 다이얼로그 추가
- 에러 다이얼로그 및 재시도 로직
- PopScope 보호 구현

### v1.0.0 (2025-08-05)
- 초기 버전 릴리즈
- 기본 다이얼로그 구조 구현

## 📊 성능 고려사항

### 메모리 관리
- **PageController 해제**: dispose()에서 컨트롤러 정리
- **AnimationController 해제**: 애니메이션 리소스 정리
- **Provider 범위**: 필요한 범위만 래핑

### 렌더링 최적화
- **PageView 물리**: NeverScrollableScrollPhysics로 불필요한 스크롤 방지
- **조건부 렌더링**: 필요한 단계만 표시
- **캐싱**: 반복 사용되는 위젯 메서드화

## 🚀 향후 개선 계획

### 계획된 기능
1. **AI 추천 타겟**: 게시물 내용 기반 자동 타겟 추천
2. **프리셋 저장**: 자주 사용하는 설정 저장/불러오기
3. **통계 표시**: 예상 도달률 및 응답률 시각화
4. **국제화**: 다국어 지원 확대

### 기술적 개선
- 위젯 테스트 추가
- 접근성 레이블 강화
- 애니메이션 커스터마이징
- 성능 프로파일링

## 📚 참고 자료

- [Flutter Dialog 가이드](https://flutter.dev/docs/development/ui/widgets/material#Dialogs)
- [Provider 패턴](https://pub.dev/packages/provider)
- [Material Design 다이얼로그](https://material.io/components/dialogs)
- [하위 디렉토리 문서](./target_audience_steps/README.md)

---

*이 문서는 InPutPostImage Dialogs 위젯 디렉토리의 구조와 사용법을 설명합니다.*
*최종 업데이트: 2025-08-23*