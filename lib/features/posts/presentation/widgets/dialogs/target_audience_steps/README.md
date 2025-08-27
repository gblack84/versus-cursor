# 🎯 Target Audience Steps 위젯 디렉토리

> 타겟 오디언스 설정을 위한 단계별 UI 컴포넌트 모음

## 🎯 개요

이 디렉토리는 투표 요청 시 타겟 오디언스를 설정하는 다단계 UI 플로우를 구성하는 위젯들을 포함합니다. 각 단계는 독립적인 위젯으로 분리되어 있으며, 상태 관리는 TargetAudienceModel을 통해 중앙에서 관리됩니다.

### 주요 특징
- 🔄 **3단계 플로우**: 수집 방식 → 목표 수 → 세부 타겟 설정
- 🎨 **일관된 디자인**: AppTheme 기반 통일된 UI/UX
- 📱 **반응형 레이아웃**: 다양한 화면 크기 지원
- ⚡ **애니메이션 효과**: 부드러운 선택 전환 효과
- 🔍 **디버그 로깅**: 개발 모드에서 상세한 동작 추적

## 📐 네이밍 컨벤션

| 구분 | 규칙 | 예시 |
|------|------|------|
| **파일명** | snake_case | `collection_type_selector.dart` |
| **클래스명** | PascalCase | `CollectionTypeSelector` |
| **메서드명** | camelCase | `onTypeSelected()` |
| **변수명** | camelCase | `isSelected` |
| **상수** | UPPER_SNAKE_CASE | `contentPadding` |
| **위젯 빌더** | _build접두사 | `_buildTypeOption()` |

> 상세 규칙은 [프로젝트 네이밍 컨벤션](../../../../../NAMING_CONVENTION.md) 참조

## 📁 디렉토리 구조

```
target_audience_steps/
├── collection_type_selector.dart     # Step 1: 수집 방식 선택
├── target_count_selector.dart        # Step 2: 목표 응답 수 설정
├── detailed_target_selector.dart     # Step 3: 세부 타겟 설정
└── README.md                         # 현재 문서
```

## 🔧 주요 구성요소

### 1. CollectionTypeSelector (`collection_type_selector.dart`)

#### 개요
투표 수집 방식을 선택하는 첫 번째 단계 위젯입니다. 빠른 수집, 공개 수집, 맞춤 설정 등의 옵션을 제공합니다.

#### 주요 기능
- **수집 방식 옵션 표시**: TargetAudienceConstants에서 정의된 모든 수집 타입 표시
- **시각적 피드백**: 선택된 옵션 강조 표시
- **애니메이션 전환**: AnimatedContainer로 부드러운 상태 변경
- **아이콘 기반 UI**: 각 옵션에 직관적인 이모지 아이콘 표시

#### 핵심 메서드

##### Widget 빌드
```dart
Widget build(BuildContext context) {
  return Consumer<TargetAudienceModel>(
    builder: (context, model, child) {
      final availableTypes = TargetAudienceConstants
          .collectionTypes.entries.toList();
      
      return SingleChildScrollView(
        padding: const EdgeInsets.all(
          TargetAudienceConstants.contentPadding
        ),
        child: Column(
          children: [
            // 제목
            Text('투표 수집 방식을 선택하세요'),
            // 옵션 리스트
            ...availableTypes.map((entry) => 
              _buildTypeOption(...)
            ),
          ],
        ),
      );
    },
  );
}
```

##### 옵션 빌드
```dart
Widget _buildTypeOption({
  required BuildContext context,
  required CollectionTypeInfo typeInfo,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected 
            ? primary.withOpacity(0.1)
            : secondaryBackground,
        border: Border.all(
          color: isSelected ? primary : alternate,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(child: Text(typeInfo.icon)),
          // 제목 및 설명
          Column(
            children: [
              Text(typeInfo.title),
              Text(typeInfo.subtitle),
            ],
          ),
          // 선택 표시
          Container(/* 체크 아이콘 */),
        ],
      ),
    ),
  );
}
```

#### 사용 예시
```dart
CollectionTypeSelector(
  onTypeSelected: (String type) {
    debugPrint('선택된 수집 방식: $type');
    // 다음 단계로 이동
    _moveToNextStep();
  },
)
```

### 2. TargetCountSelector (`target_count_selector.dart`)

#### 개요
목표 응답 수와 프리미엄 옵션을 설정하는 두 번째 단계 위젯입니다. 예상 소요 시간을 실시간으로 표시합니다.

#### 주요 기능
- **목표 응답 수 설정**: 드롭다운 및 빠른 선택 버튼
- **예상 시간 계산**: 선택한 옵션에 따른 동적 시간 표시
- **프리미엄 옵션**: 빠른 수집 모드 선택
- **시각적 안내**: 정보 메시지로 사용자 가이드

#### 핵심 메서드

##### 목표 수 섹션 빌드
```dart
Widget _buildTargetCountSection(
  BuildContext context, 
  TargetAudienceModel model
) {
  return Container(
    child: Column(
      children: [
        // 드롭다운
        DropdownButton<int>(
          value: model.targetCount,
          items: TargetAudienceConstants
              .targetCountOptions.map((count) {
            return DropdownMenuItem(
              value: count,
              child: Text('$count명'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onCountChanged(value);
            }
          },
        ),
        // 빠른 선택 버튼들
        Row(
          children: targetCountOptions.map((count) {
            return OutlinedButton(
              onPressed: () => onCountChanged(count),
              child: Text('$count'),
            );
          }).toList(),
        ),
      ],
    ),
  );
}
```

##### 예상 시간 표시
```dart
Widget _buildEstimatedTimeSection(
  BuildContext context,
  TargetAudienceModel model
) {
  return Container(
    decoration: BoxDecoration(
      color: accent1.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Icon(Icons.access_time),
            Text('예상 소요 시간'),
          ],
        ),
        Text(
          model.estimatedTime,  // "약 10분"
          style: headlineMedium,
        ),
      ],
    ),
  );
}
```

#### 콜백 처리
```dart
TargetCountSelector(
  onCountChanged: (int count) {
    model.targetCount = count;
    _updateEstimatedTime();
  },
  onPremiumChanged: (bool isPremium) {
    model.isPremium = isPremium;
    _updateEstimatedTime();
  },
)
```

### 3. DetailedTargetSelector (`detailed_target_selector.dart`)

#### 개요
맞춤 설정 선택 시 나타나는 세 번째 단계로, 관심사, 연령대, 성별 등 세부 타겟 조건을 설정합니다.

#### 주요 기능
- **관심사 선택**: FilterChip을 사용한 복수 선택
- **연령대 선택**: 라디오 버튼 스타일의 단일 선택
- **성별 선택**: 3개 옵션 중 단일 선택
- **고급 옵션**: 활성 사용자 우선 설정

#### 핵심 메서드

##### 관심사 섹션
```dart
Widget _buildInterestsSection(
  BuildContext context,
  TargetAudienceModel model
) {
  return Column(
    children: [
      Text('관심사 (복수 선택 가능)'),
      Wrap(
        spacing: chipSpacing,
        runSpacing: chipRunSpacing,
        children: interests.map((interest) {
          final isSelected = model.selectedInterests
              .contains(interest);
          
          return FilterChip(
            label: Text(interest),
            selected: isSelected,
            onSelected: (_) {
              model.toggleInterest(interest);
            },
            selectedColor: primary,
            checkmarkColor: Colors.white,
          );
        }).toList(),
      ),
    ],
  );
}
```

##### 연령대 선택
```dart
Widget _buildAgeGroupSection(
  BuildContext context,
  TargetAudienceModel model
) {
  return Wrap(
    children: ageGroups.entries.map((entry) {
      final isSelected = model.selectedAgeGroup == entry.key;
      
      return InkWell(
        onTap: () {
          model.selectedAgeGroup = entry.key;
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? primary : secondaryBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 라디오 버튼 스타일
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? white : transparent,
                ),
              ),
              Text(entry.value),  // "10대", "20대" 등
            ],
          ),
        ),
      );
    }).toList(),
  );
}
```

##### 성별 선택
```dart
Widget _buildGenderSection(
  BuildContext context,
  TargetAudienceModel model
) {
  return Row(
    children: genderOptions.entries.map((entry) {
      final isSelected = model.selectedGender == entry.key;
      
      return Expanded(
        child: InkWell(
          onTap: () {
            model.selectedGender = entry.key;
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? primary : secondaryBackground,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 라디오 버튼
                Container(/* ... */),
                Text(entry.value.label),  // "남성", "여성", "무관"
              ],
            ),
          ),
        ),
      );
    }).toList(),
  );
}
```

## 💡 사용 예시

### 전체 플로우 통합
```dart
class TargetAudienceDialog extends StatefulWidget {
  @override
  _TargetAudienceDialogState createState() => 
      _TargetAudienceDialogState();
}

class _TargetAudienceDialogState 
    extends State<TargetAudienceDialog> {
  int currentStep = 0;
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TargetAudienceModel(),
      child: Consumer<TargetAudienceModel>(
        builder: (context, model, child) {
          return Dialog(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _buildCurrentStep(),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return CollectionTypeSelector(
          onTypeSelected: (type) {
            model.collectionType = type;
            if (type == 'custom') {
              setState(() => currentStep = 2);
            } else {
              setState(() => currentStep = 1);
            }
          },
        );
      
      case 1:
        return TargetCountSelector(
          onCountChanged: (count) {
            model.targetCount = count;
          },
          onPremiumChanged: (isPremium) {
            model.isPremium = isPremium;
          },
        );
      
      case 2:
        return DetailedTargetSelector();
      
      default:
        return SizedBox();
    }
  }
}
```

### 개별 위젯 사용
```dart
// Step 1만 사용
CollectionTypeSelector(
  onTypeSelected: (String type) {
    debugPrint('선택된 타입: $type');
    // 처리 로직
  },
)

// Step 2만 사용
TargetCountSelector(
  onCountChanged: (int count) {
    debugPrint('목표 수: $count');
  },
  onPremiumChanged: (bool isPremium) {
    debugPrint('프리미엄: $isPremium');
  },
)

// Step 3만 사용 (Provider 필요)
DetailedTargetSelector()
```

## 🎨 UI/UX 특징

### 시각적 피드백
- **선택 상태**: 테두리 굵기 및 색상 변경
- **호버 효과**: InkWell의 리플 효과
- **애니메이션**: 200ms 전환 애니메이션
- **색상 코딩**: Primary 색상으로 선택 강조

### 접근성
- **터치 영역**: 최소 48px 터치 타겟
- **명확한 레이블**: 모든 옵션에 설명 텍스트
- **시각적 계층**: 제목, 부제목, 설명으로 구분
- **피드백**: 선택 시 즉각적인 시각적 응답

### 반응형 디자인
- **SingleChildScrollView**: 작은 화면에서 스크롤 가능
- **Wrap 위젯**: 화면 크기에 따른 자동 줄바꿈
- **Expanded 위젯**: 가용 공간 자동 분배
- **동적 패딩**: 화면 크기에 따른 여백 조정

## 📊 상태 관리

### TargetAudienceModel 통합
```dart
// Provider를 통한 상태 접근
Consumer<TargetAudienceModel>(
  builder: (context, model, child) {
    // model.collectionType - 수집 방식
    // model.targetCount - 목표 응답 수
    // model.selectedInterests - 선택된 관심사
    // model.selectedAgeGroup - 선택된 연령대
    // model.selectedGender - 선택된 성별
    // model.activeUserOnly - 활성 사용자 우선
    // model.isPremium - 프리미엄 옵션
    
    return YourWidget(model: model);
  },
)
```

### 상태 변경 알림
```dart
// 모델에서 변경 알림
void toggleInterest(String interest) {
  if (selectedInterests.contains(interest)) {
    selectedInterests.remove(interest);
  } else {
    selectedInterests.add(interest);
  }
  notifyListeners();  // UI 업데이트 트리거
}
```

## 🐛 디버그 로깅

### 로그 패턴
```dart
debugPrint('[위젯명] 동작: 상세 정보');
// 예시
debugPrint('[CollectionTypeSelector] 수집 방식 선택: quick');
debugPrint('[TargetCountSelector] 목표 응답 수 선택: 10');
debugPrint('[DetailedTargetSelector] 관심사 토글: 스포츠 (현재: true)');
```

### 개발 모드 확인
```dart
if (kDebugMode) {
  debugPrint('[디버그] 상세 정보...');
}
```

## 🔄 변경 이력

### v1.0.0 (2025-08-08)
- 초기 버전 릴리즈
- 3단계 타겟 설정 플로우 구현
- CollectionTypeSelector, TargetCountSelector, DetailedTargetSelector 생성

### v1.1.0 (2025-08-10)
- 애니메이션 효과 추가
- 디버그 로깅 강화
- 프리미엄 옵션 UI 개선

### v1.2.0 (2025-08-12)
- 반응형 레이아웃 최적화
- 접근성 개선 (터치 타겟 크기)
- 성능 최적화 (Consumer 범위 축소)

## 📊 성능 고려사항

### 렌더링 최적화
- **Consumer 범위**: 필요한 부분만 감싸기
- **AnimatedContainer**: 불필요한 애니메이션 제한
- **FilterChip**: 대량 아이템 시 성능 고려

### 메모리 관리
- **SingleChildScrollView**: 보이는 영역만 렌더링
- **상수 사용**: TargetAudienceConstants 참조
- **위젯 재사용**: 반복되는 UI 패턴 메서드화

## 🚀 향후 개선 계획

### 계획된 기능
1. **AI 추천**: 게시물 내용 기반 타겟 자동 추천
2. **프리셋 저장**: 자주 사용하는 타겟 설정 저장
3. **통계 표시**: 예상 도달률 및 응답률 표시
4. **A/B 테스트**: 다양한 타겟 그룹 동시 테스트

### 기술적 개선
- 위젯 테스트 추가
- 접근성 레이블 강화
- 다국어 지원 확대
- 애니메이션 커스터마이징 옵션

## 📚 참고 자료

- [Flutter Provider 패턴](https://pub.dev/packages/provider)
- [Material Design 가이드라인](https://material.io/design)
- [Flutter 접근성 가이드](https://flutter.dev/docs/development/accessibility-and-localization/accessibility)

---

*이 문서는 Target Audience Steps 위젯 디렉토리의 구조와 사용법을 설명합니다.*
*최종 업데이트: 2025-08-23*