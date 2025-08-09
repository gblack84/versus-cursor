# Shared Services Documentation

공유 서비스 레이어 - 애플리케이션 전반에서 사용되는 핵심 서비스들

## 📋 개요

이 디렉토리는 Versus Space 앱의 여러 컴포넌트에서 공유하는 핵심 서비스들을 포함합니다.

## 📁 파일 구조

```
shared/services/
├── unified_box_calculator.dart  # 통합 박스 크기 계산 서비스
└── README.md                   # 문서
```

## 🎯 UnifiedBoxCalculator

**통합 박스 크기 계산 서비스**

모든 A/B 박스 레이아웃의 크기를 일관되게 계산하는 중앙 집중식 서비스입니다.

### 핵심 기능

- **통일된 크기 시스템**: 메시지 카드, 알림 다이얼로그, 질문 작성 페이지에서 일관된 크기
- **레이아웃 타입 지원**: horizontal, vertical, single
- **AspectRatio 기반 계산**: 이미지 비율을 고려한 동적 크기 조정
- **반응형 디자인**: 화면 크기에 따른 자동 조정

### 사용 방법

#### 메시지 카드용 계산
```dart
final boxSizes = UnifiedBoxCalculator.calculateForMessageCard(
  bubbleWidth: 344.0,
  layoutType: LayoutType.horizontal,
  aspectRatioA: 1.5,
  aspectRatioB: 1.5,
  hasImageA: true,
  hasImageB: true,
);

print('박스 A 크기: ${boxSizes.sizeA}');
print('박스 B 크기: ${boxSizes.sizeB}');
print('통일 높이: ${boxSizes.unifiedHeight}');
```

#### 알림 다이얼로그용 계산
```dart
final boxSizes = UnifiedBoxCalculator.calculateForNotificationDialog(
  dialogWidth: MediaQuery.of(context).size.width * 0.92,
  layoutType: LayoutType.vertical,
  aspectRatioA: 1.3,
  aspectRatioB: 1.7,
  hasImageA: true,
  hasImageB: true,
);
```

#### 질문 작성 페이지용 계산
```dart
final boxSizes = UnifiedBoxCalculator.calculateForQuestion(
  containerWidth: MediaQuery.of(context).size.width,
  layoutType: LayoutType.horizontal,
  aspectRatioA: aspectRatioA,
  aspectRatioB: aspectRatioB,
  hasImageA: true,
  hasImageB: false,
);
```

### BoxSizes 데이터 구조

```dart
class BoxSizes {
  final Size sizeA;           // A박스 크기
  final Size sizeB;           // B박스 크기
  final LayoutType layoutType; // 레이아웃 타입
  final String containerType;  // 컨테이너 타입
  final double spacing;        // 박스 간 간격
  final double unifiedHeight;  // 통일된 높이
  final double boxWidth;       // 박스 너비
}
```

### 레이아웃 타입

- **horizontal**: 가로 배치 (A | B)
- **vertical**: 세로 배치 (A 위, B 아래)
- **single**: 단일 이미지 모드

### 크기 제한

#### 메시지 카드
- **최대 높이**: 400px
- **최소 높이**: 100px (vertical), 200px (horizontal/single)
- **기본 높이**: boxWidth / 1.5 (aspectRatio가 없을 때)

#### 알림 다이얼로그
- **최대 높이**: 500px (single), 400px (horizontal), 350px (vertical)
- **최소 높이**: 150px
- **다이얼로그 너비**: 화면의 92%

#### 질문 작성
- **최대 높이**: 500px
- **최소 높이**: 200px
- **컨테이너 패딩**: 20px

### 계산 로직

1. **컨테이너 타입 결정**: message, notification, question
2. **박스 너비 계산**: 컨테이너 너비와 레이아웃에 따라 결정
3. **높이 제한 설정**: 컨테이너 타입별 최대/최소 높이
4. **AspectRatio 기반 높이 계산**: `height = width / aspectRatio`
5. **통일 높이 결정**: 
   - single: 해당 이미지 높이
   - 둘 다 있음: 평균 높이
   - 하나만 있음: 해당 높이
6. **제한 적용**: min/max 높이로 클램핑

### 동적 기본값

AspectRatio가 null일 때:
- **이전**: 고정값 300px 사용 (문제 발생)
- **현재**: `boxWidth / 1.5` 동적 계산 (안정적)

### 성능 최적화

- **캐싱 권장**: 계산 결과를 컴포넌트에서 캐싱
- **재계산 최소화**: aspectRatio 변경 시에만 재계산
- **디버그 모드**: 개발 환경에서만 로그 출력

### 통합 사례

1. **VoteCardMessage**: 전역 BoxSizes 캐시와 함께 사용
2. **VotingNotificationDialog**: VersusBoxSizeData와 연동
3. **InPutPostImageWidget**: 실시간 레이아웃 업데이트

## 🔧 유지보수

### 새로운 컨테이너 타입 추가

1. `LayoutConstants`에 새 타입 상수 추가
2. `calculate` 메서드에 타입별 로직 추가
3. 편의 메서드 생성 (예: `calculateForNewType`)

### 크기 제한 조정

`calculate` 메서드 내 제한값 수정:
- maxHeight, minHeight 조정
- 기본 비율 변경 (현재 1.5)

### 디버그 정보

개발 모드에서 자동으로 출력:
- 버블/다이얼로그 너비
- 레이아웃 타입
- 박스 너비
- 계산된 높이
- 통일 높이