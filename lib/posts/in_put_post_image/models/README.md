# Models Directory

## 개요 (Overview)

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **필드명**: camelCase
- 참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)
이 디렉토리는 데이터 모델과 상태 관리 클래스들을 포함합니다. 주로 특정 기능이나 페이지의 상태를 관리하는 모델들이 위치합니다.

## 파일 설명 (File Descriptions)

### target_audience_model.dart
- **역할**: 타겟 오디언스 설정 관련 상태 관리
- **주요 기능**:
  - 타겟 연령대 설정
  - 타겟 성별 설정
  - 타겟 관심사 관리
- **사용처**: 게시물 작성 시 타겟 설정 (현재 미사용)
- **상태**:
  ```dart
  class TargetAudienceModel {
    String? ageRange;
    String? gender;
    List<String> interests = [];
  }
  ```

## 모델 vs 서비스 vs 헬퍼

### Models (이 디렉토리)
- **목적**: 데이터 구조와 상태 정의
- **특징**: 
  - 주로 데이터 클래스
  - 상태 관리 로직 포함
  - UI와 독립적

### Services
- **목적**: 비즈니스 로직과 외부 통신
- **특징**:
  - API 호출
  - 데이터 처리
  - 외부 서비스 통합

### Helpers
- **목적**: 유틸리티 기능
- **특징**:
  - 계산 로직
  - 데이터 변환
  - 재사용 가능한 함수

## 모델 설계 원칙

### 1. 단일 책임
- 하나의 모델은 하나의 도메인만 담당
- 명확한 경계 유지

### 2. 불변성
- 가능한 final 필드 사용
- copyWith 메서드 제공
```dart
class UserModel {
  final String id;
  final String name;
  
  UserModel copyWith({String? name}) {
    return UserModel(
      id: this.id,
      name: name ?? this.name,
    );
  }
}
```

### 3. 직렬화
- toJson/fromJson 메서드 구현
- Firebase 통합 고려
```dart
Map<String, dynamic> toJson() => {
  'id': id,
  'name': name,
};

factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    id: json['id'],
    name: json['name'],
  );
}
```

## 사용 예시

### 모델 생성 및 사용
```dart
// 모델 생성
final targetAudience = TargetAudienceModel();

// 상태 업데이트
targetAudience.ageRange = '20-30';
targetAudience.interests.add('technology');

// 유효성 검사
if (targetAudience.isValid()) {
  // 저장 또는 전송
}
```

### Provider와 통합
```dart
class TargetAudienceProvider extends ChangeNotifier {
  TargetAudienceModel _model = TargetAudienceModel();
  
  void updateAgeRange(String range) {
    _model.ageRange = range;
    notifyListeners();
  }
}
```

## 현재 상태

### 활성 모델
- 현재 이 디렉토리의 모델들은 대부분 **미사용 상태**
- 향후 기능 확장 시 활용 예정

### 메인 상태 관리
- `InPutPostImageModel`: 메인 페이지 상태 (상위 디렉토리)
- `AppState`: 전역 상태 관리

## 향후 확장 가능성

### 1. 추가 모델 후보
- `ImageEditHistoryModel`: 편집 이력 관리
- `UploadProgressModel`: 업로드 진행 상태
- `ValidationResultModel`: 검증 결과 저장

### 2. 모델 통합
- 관련 모델들을 하나로 통합
- 계층 구조 도입

### 3. 상태 관리 패턴
- Repository 패턴 도입
- Clean Architecture 적용

## 주의사항

1. **메모리 관리**:
   - 대용량 데이터는 lazy loading
   - 사용하지 않는 데이터 정리

2. **타입 안전성**:
   - 명시적 타입 선언
   - null safety 활용

3. **테스트 가능성**:
   - 순수 함수로 구현
   - 외부 의존성 최소화

## 모델 생성 가이드

새로운 모델 생성 시:
1. 명확한 도메인 정의
2. 필요한 필드 식별
3. 유효성 검사 로직 추가
4. 직렬화 메서드 구현
5. 단위 테스트 작성