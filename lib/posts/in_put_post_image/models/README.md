# 🎯 In Put Post Image Models 디렉토리

> 질문 작성 모듈의 데이터 모델 및 상태 관리 클래스

## 📑 목차
- [개요](#개요)
- [네이밍 컨벤션](#네이밍-컨벤션)
- [주요 구성요소](#주요-구성요소)
- [모델 상세](#모델-상세)
- [사용 예시](#사용-예시)
- [타겟 오디언스 시스템](#타겟-오디언스-시스템)
- [의존성](#의존성)
- [변경 이력](#변경-이력)

## 🎯 개요

이 디렉토리는 In Put Post Image 모듈의 데이터 모델과 상태 관리 클래스를 관리합니다. 현재 AI 기반 타겟 오디언스 시스템을 위한 모델이 구현되어 있으며, 사용자가 질문을 작성할 때 원하는 응답자를 설정할 수 있도록 지원합니다.

### 주요 목적
- **타겟 설정**: AI 기반 스마트 타겟팅 또는 커스텀 필터링
- **상태 관리**: ChangeNotifier 패턴으로 UI 반응형 업데이트
- **데이터 검증**: 입력 데이터 유효성 확인
- **Firebase 통합**: Cloud Functions와 호환되는 데이터 구조

## 📐 네이밍 컨벤션

프로젝트 전체 네이밍 규칙을 따릅니다:

- **파일명**: snake_case (Dart 표준)
  - ✅ `target_audience_model.dart`
  - ❌ `TargetAudienceModel.dart`

- **클래스명**: PascalCase
  - ✅ `TargetAudienceModel`
  - ❌ `target_audience_model`

- **메서드/변수명**: camelCase
  - ✅ `collectionType`, `targetCount`
  - ❌ `collection_type`, `target_count`

- **상수명**: camelCase 또는 SCREAMING_SNAKE_CASE
  - ✅ `defaultTargetCount = 100`
  - ✅ `MAX_TARGET_COUNT = 1000`

상세 내용: [NAMING_CONVENTION.md](../../../../NAMING_CONVENTION.md)

## 🔧 주요 구성요소

### 파일 구조
```
models/
├── target_audience_model.dart  # 타겟 오디언스 설정 모델
└── README.md                   # 디렉토리 문서
```

### 모델 분류

| 모델명 | 용도 | 상태 | 의존성 |
|--------|------|------|--------|
| **TargetAudienceModel** | 타겟 오디언스 설정 및 관리 | 활성 | ChangeNotifier |

## 📋 모델 상세

### TargetAudienceModel

타겟 오디언스 설정을 관리하는 핵심 모델로, AI 기반 알림 시스템과 연동됩니다.

#### 주요 속성

```dart
class TargetAudienceModel extends ChangeNotifier {
  // 수집 방식
  String collectionType;  // 'quick', 'public', 'custom'
  
  // 목표 응답 수
  int targetCount;        // 기본값: 100
  
  // 프리미엄 여부
  bool isPremium;         // 우선순위 처리 여부
  
  // Custom 설정
  List<String> selectedInterests;  // 관심사 필터
  String selectedAgeGroup;         // 연령대 필터
  String selectedGender;           // 성별 필터
  bool activeUserOnly;             // 활성 사용자만
  
  // UI 상태
  int currentStep;        // 현재 진행 단계 (0-2)
}
```

#### 수집 방식 (Collection Types)

| 타입 | 설명 | AI 사용 | 필터링 |
|------|------|---------|---------|
| **quick** | AI가 최적 사용자 자동 선택 | ✅ | 자동 |
| **public** | 활성 사용자 중 랜덤 선택 | ❌ | 없음 |
| **custom** | 사용자가 직접 조건 설정 | ❌ | 수동 |

#### 주요 메서드

```dart
// 관심사 토글
void toggleInterest(String interest)

// 관심사 초기화
void clearInterests()

// 유효성 검사
bool get isValid

// 다음 단계 이동 가능 여부
bool get canGoNext

// 최종 단계 여부
bool get isFinalStep

// 예상 소요 시간 계산
String get estimatedTime

// Firestore 저장용 변환
Map<String, dynamic> toMap()

// 모델 초기화
void reset()
```

#### 유효성 검사 로직

```dart
bool get isValid {
  // Step 0: 수집 방식 선택 (항상 유효)
  if (currentStep == 0) return true;
  
  // Step 1: 목표 수 설정 (0보다 커야 함)
  if (currentStep == 1) return targetCount > 0;
  
  // Step 2: Custom 설정 (최소 하나의 조건)
  if (currentStep == 2 && collectionType == 'custom') {
    return selectedInterests.isNotEmpty || 
           selectedAgeGroup != '전체' || 
           selectedGender != 'all';
  }
  
  return true;
}
```

## 💻 사용 예시

### 모델 초기화 및 설정

```dart
// 1. 모델 생성
final targetModel = TargetAudienceModel();

// 2. 수집 방식 설정
targetModel.collectionType = 'quick';  // AI 자동 선택

// 3. 목표 응답 수 설정
targetModel.targetCount = 100;

// 4. 프리미엄 설정
targetModel.isPremium = true;  // 우선 처리
```

### Custom 타겟 설정

```dart
// Custom 모드로 변경
targetModel.collectionType = 'custom';

// 관심사 추가
targetModel.toggleInterest('스포츠');
targetModel.toggleInterest('음악');
targetModel.toggleInterest('게임');

// 연령대 설정
targetModel.selectedAgeGroup = '20대';

// 성별 설정
targetModel.selectedGender = 'female';

// 활성 사용자만
targetModel.activeUserOnly = true;
```

### UI 진행 단계 관리

```dart
// 현재 단계 확인
int step = targetModel.currentStep;

// 다음 단계로 이동 가능 여부
if (targetModel.canGoNext) {
  targetModel.currentStep++;
}

// 최종 단계 확인
if (targetModel.isFinalStep) {
  // 완료 처리
  final data = targetModel.toMap();
  await saveToFirestore(data);
}
```

### Provider 패턴 통합

```dart
// Provider로 래핑
ChangeNotifierProvider(
  create: (_) => TargetAudienceModel(),
  child: TargetAudienceSetupWidget(),
);

// Widget에서 사용
Consumer<TargetAudienceModel>(
  builder: (context, model, child) {
    return Text('선택된 방식: ${model.collectionType}');
  },
);
```

### Firestore 저장

```dart
// 모델을 Map으로 변환
final data = targetModel.toMap();

// Firestore에 저장
await FirebaseFirestore.instance
  .collection('posts')
  .doc(postId)
  .update({
    'targetAudience': data,
  });
```

## 🎯 타겟 오디언스 시스템

### 시스템 아키텍처

```
사용자 입력
    ↓
TargetAudienceModel
    ↓
toMap() 변환
    ↓
Firestore 저장
    ↓
Cloud Functions 트리거
    ↓
AI 또는 필터링 처리
    ↓
알림 전송
```

### 수집 방식별 플로우

#### Quick Collection (AI)
1. 사용자가 'quick' 선택
2. 목표 수만 설정
3. Cloud Functions에서 Gemini AI 호출
4. AI가 게시물 내용 분석
5. 최적 사용자 자동 선택
6. 알림 전송

#### Public Collection
1. 사용자가 'public' 선택
2. 목표 수 설정
3. 활성 사용자 중 랜덤 선택
4. 알림 전송

#### Custom Collection
1. 사용자가 'custom' 선택
2. 필터 조건 설정
   - 관심사 (복수 선택 가능)
   - 연령대 (10대, 20대, 30대, 40대, 50대 이상)
   - 성별 (전체, 남성, 여성)
3. Firestore 쿼리로 필터링
4. 조건 맞는 사용자에게 알림

### 예상 소요 시간 로직

```dart
String get estimatedTime {
  if (isPremium) {
    return '약 3-5분';  // 프리미엄: 우선 처리
  } else {
    if (targetCount <= 50) {
      return '약 5-10분';
    } else if (targetCount <= 100) {
      return '약 10-15분';
    } else {
      return '약 15-30분';
    }
  }
}
```

### 데이터 구조 (Firestore)

```json
{
  "type": "quick",
  "targetCount": 100,
  "isPremium": false,
  "createdAt": "2025-08-23T10:00:00Z",
  "status": "pending",
  "criteria": {
    "interests": ["스포츠", "음악"],
    "ageGroup": "20s",
    "gender": "all",
    "activeUserOnly": true
  }
}
```

## 📦 의존성

### 외부 패키지
```yaml
dependencies:
  flutter/material.dart  # ChangeNotifier, 기본 위젯
```

### 내부 의존성
- Firebase Functions (간접적)
- Firestore (간접적)
- AI 시스템 (Genkit/Gemini)

## 🔄 변경 이력

### 2025-08-23
- 문서 전체 재작성
- TargetAudienceModel 상세 문서화
- 타겟 오디언스 시스템 아키텍처 추가

### 주요 개발 이력
- **타겟 오디언스 모델 구현** (2025-07-20)
  - TargetAudienceModel 클래스 생성
  - 3가지 수집 방식 구현
  - Custom 필터링 로직 추가
  
- **Firebase Functions 통합** (2025-07-20)
  - toMap() 메서드 구현
  - 한국어 → 영어 변환 로직
  - Cloud Functions 호환 데이터 구조

## 📝 주요 규칙 및 가이드라인

### 모델 설계 원칙
1. **단일 책임**: 하나의 모델은 하나의 도메인만 관리
2. **불변성**: 가능한 final 필드 사용
3. **반응형**: ChangeNotifier 패턴 활용
4. **검증**: 모든 입력에 대한 유효성 검사

### 상태 관리 가이드라인
- **즉시 알림**: setter에서 notifyListeners() 호출
- **불변 리스트**: List.unmodifiable() 사용
- **명시적 초기화**: reset() 메서드 제공
- **메모리 관리**: dispose()에서 정리

### 테스트 체크리스트
- [ ] 모든 setter가 notifyListeners() 호출
- [ ] 유효성 검사 로직 정확성
- [ ] toMap() 변환 정확성
- [ ] reset() 완전 초기화
- [ ] Custom 필터 조합 테스트

## 🚀 향후 개선 사항

### 계획된 개선
- [ ] 더 세밀한 관심사 카테고리
- [ ] 지역 기반 타겟팅
- [ ] 사용자 활동 패턴 분석
- [ ] 실시간 타겟 수정

### 성능 최적화
- [ ] 타겟 사용자 캐싱
- [ ] 배치 처리 최적화
- [ ] AI 응답 시간 단축

### 기능 확장
- [ ] 타겟 템플릿 저장
- [ ] 타겟 히스토리 관리
- [ ] A/B 테스트 지원