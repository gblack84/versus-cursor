# 📏 In Put Post Image Constants 디렉토리

> 게시물 작성 모듈의 모든 상수를 중앙 집중식으로 관리하는 디렉토리

## 📑 목차
- [개요](#개요)
- [네이밍 컨벤션](#네이밍-컨벤션)
- [주요 구성요소](#주요-구성요소)
- [상수 파일 상세](#상수-파일-상세)
- [사용 예시](#사용-예시)
- [아키텍처 패턴](#아키텍처-패턴)
- [의존성](#의존성)
- [변경 이력](#변경-이력)

## 🎯 개요

이 디렉토리는 In Put Post Image 모듈에서 사용되는 모든 상수들을 체계적으로 관리합니다. 하드코딩된 값들을 제거하고 유지보수성을 높이기 위해 10개의 특화된 상수 파일로 분리되어 있습니다.

### 주요 목적
- **중앙 집중식 관리**: 모든 상수를 한 곳에서 관리
- **타입 안정성**: 강력한 타입 체크와 컴파일 타임 검증
- **재사용성**: 프로젝트 전반에서 일관된 값 사용
- **유지보수성**: 값 변경 시 한 곳에서만 수정
- **코드 가독성**: 의미있는 이름으로 코드 이해도 향상

## 📐 네이밍 컨벤션

프로젝트 전체 네이밍 규칙을 따릅니다:

- **파일명**: snake_case (Dart 표준)
  - ✅ `field_styles.dart`
  - ✅ `image_constants.dart`
  - ❌ `FieldStyles.dart`

- **클래스명**: PascalCase
  - ✅ `ImageConstants`
  - ✅ `FieldStyles`

- **상수명**: camelCase with 'k' prefix (선택적)
  - ✅ `static const double defaultPadding = 10.0;`
  - ✅ `static const String userNotLoggedIn = '...';`
  - ✅ `static const int maxImageCount = 4;`

상세 내용: [NAMING_CONVENTION.md](../../../../NAMING_CONVENTION.md)

## 🔧 주요 구성요소

### 1. Constants.dart (배럴 파일)
```dart
// 모든 상수 파일을 한번에 import
export 'animation_constants.dart';
export 'colors.dart';
export 'config.dart';
export 'dimensions.dart';
export 'field_styles.dart';
export 'image_constants.dart';
export 'strings.dart';
export 'text_limits.dart';
```

### 2. 카테고리별 상수 구조

| 파일명 | 용도 | 상수 개수 | 주요 카테고리 |
|--------|------|-----------|--------------|
| **dimensions.dart** | UI 치수 | 47개 | 패딩, 크기, 반경 |
| **image_constants.dart** | 이미지 처리 | 20개 | 크기, 비율, 캐시 |
| **animation_constants.dart** | 애니메이션 | 11개 | 지속시간, 이징 |
| **strings.dart** | 문자열 | 58개 | 메시지, 라벨 |
| **text_limits.dart** | 텍스트 제한 | 7개 | 최대 길이 |
| **colors.dart** | 색상 정의 | 11개 | 오버레이, 상태색 |
| **config.dart** | 설정값 | 29개 | Firebase, 메타데이터 |
| **field_styles.dart** | 필드 스타일 | 4개 필드 설정 | 입력 필드 스타일 |
| **target_audience_constants.dart** | 타겟 설정 | 74개 | 수집 방식, 필터 |

## 📋 상수 파일 상세

### Dimensions.dart - UI 치수 관리
```dart
class Dimensions {
  // 패딩 & 간격
  static const double defaultPadding = 10.0;
  static const double smallPadding = 2.5;
  static const double mediumPadding = 5.0;
  static const double largePadding = 20.0;
  
  // 미디어 박스
  static const double boxBorderRadius = 20.0;
  static const double actionButtonSize = 45.0;
  static const double actionIconSize = 29.0;
  
  // 페이지 인디케이터
  static const double pageIndicatorSize = 8.0;
  static const double pageIndicatorSpacing = 2.0;
}
```

### ImageConstants.dart - 이미지 처리 설정
```dart
class ImageConstants {
  // 이미지 크기
  static const int displayMaxWidth = 800;
  static const int thumbnailSize = 150;
  static const int jpegQuality = 85;
  
  // 비율 임계값
  static const double landscapeThreshold = 1.2;
  static const double portraitThreshold = 0.8;
  
  // 박스 크기 제한
  static const double maxHeightHorizontal = 500;
  static const double minHeightVertical = 120;
}
```

### AnimationConstants.dart - 애니메이션 타이밍
```dart
class AnimationConstants {
  // 지속시간
  static const Duration shakeAnimationDuration = Duration(milliseconds: 200);
  static const Duration fadeInDuration = Duration(milliseconds: 150);
  static const Duration uploadTimeout = Duration(seconds: 15);
  
  // 애니메이션 값
  static const double shakeAnimationExtent = 8.0;
  static const Alignment toastAlignment = Alignment(0, 0.8);
}
```

### StringConstants.dart - 문자열 리소스
```dart
class StringConstants {
  // 에러 메시지
  static const String userNotLoggedIn = '사용자가 로그인되어 있지 않습니다.';
  static const String imageUploadError = '이미지 업로드 실패: ';
  
  // 성공 메시지
  static const String postSaved = '게시물이 성공적으로 저장되었습니다!';
  
  // 검증 카테고리
  static const String toxicityCategory = '독성 콘텐츠';
  static const String violentContentCategory = '폭력적 콘텐츠';
}
```

### FieldStyles.dart - 입력 필드 스타일 관리
```dart
class FieldStyles {
  static const Map<String, FieldConfig> fieldConfigs = {
    'questionTitle': FieldConfig(
      textSize: 30.0,
      labelSize: 30.0,
      maxLength: 60,
      maxLines: 3,
      borderType: FieldBorderType.underline,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
    ),
    'description': FieldConfig(
      textSize: 20.0,
      maxLength: 200,
      maxLines: null, // 무제한
      textInputAction: TextInputAction.newline,
    ),
  };
  
  // 헬퍼 메서드
  static FieldConfig getConfig(String fieldName) {
    return fieldConfigs[fieldName] ?? _defaultConfig;
  }
}
```

### TargetAudienceConstants.dart - 타겟 오디언스 설정
```dart
class TargetAudienceConstants {
  // 수집 방식
  static const Map<String, CollectionTypeInfo> collectionTypes = {
    'quick': CollectionTypeInfo(
      id: 'quick',
      title: '빠른 수집',
      subtitle: 'AI가 최적의 타겟을 자동으로 선정합니다',
      icon: '🎯',
    ),
  };
  
  // 관심사 목록
  static const List<String> interests = [
    '스포츠', '게임', '음악', '영화', '패션',
    '음식', '여행', '기술', '예술', '독서',
  ];
  
  // 시간 제한
  static const int freeTimeLimit = 600;  // 10분
  static const int premiumTimeLimit = 300;  // 5분
}
```

## 💻 사용 예시

### 전체 상수 Import
```dart
import 'constants/constants.dart';

// 사용
Container(
  padding: EdgeInsets.all(Dimensions.defaultPadding),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(Dimensions.boxBorderRadius),
    color: AppColors.blackOverlay60,
  ),
  child: Text(
    StringConstants.loading,
    style: TextStyle(fontSize: Dimensions.labelFontSize),
  ),
)
```

### 개별 파일 Import
```dart
import 'constants/dimensions.dart';
import 'constants/strings.dart';

// 치수 사용
final boxHeight = Dimensions.defaultHeightHorizontal;

// 문자열 사용
showToast(StringConstants.postSaved);
```

### 필드 스타일 적용
```dart
// 필드 설정 가져오기
final config = FieldStyles.getConfig('questionTitle');

// TextFormField에 적용
TextFormField(
  maxLength: config.maxLength,
  maxLines: config.maxLines,
  style: TextStyle(fontSize: config.textSize),
  decoration: InputDecoration(
    contentPadding: config.contentPadding,
  ),
)
```

### 타겟 오디언스 설정
```dart
// 수집 방식 선택
final quickCollection = TargetAudienceConstants.collectionTypes['quick'];
print(quickCollection?.title); // '빠른 수집'

// 관심사 필터
final selectedInterests = TargetAudienceConstants.interests.take(3);

// 시간 제한 체크
final timeLimit = isPremium 
    ? TargetAudienceConstants.premiumTimeLimit 
    : TargetAudienceConstants.freeTimeLimit;
```

## 🏗️ 아키텍처 패턴

### 1. 배럴 파일 패턴
- `constants.dart`가 모든 상수 파일을 export
- 사용처에서는 하나의 import로 모든 상수 접근

### 2. 카테고리별 분리
- 관련된 상수들을 논리적으로 그룹화
- 각 파일은 단일 책임 원칙 준수

### 3. 타입 안정성
- 모든 상수에 명시적 타입 선언
- enum 사용으로 타입 안정성 강화

### 4. 설정 객체 패턴
- `FieldConfig`, `CollectionTypeInfo` 등 설정 객체 사용
- 관련 설정을 하나의 객체로 관리

## 📦 의존성

### 외부 패키지
- `flutter/material.dart` - Color, EdgeInsets, Duration 등

### 내부 의존성
- 없음 (독립적인 상수 정의)

## 🔄 변경 이력

### 2025-08-23
- 문서 전체 재작성
- 10개 상수 파일 상세 문서화
- 사용 예시 및 패턴 추가

### 주요 리팩토링 이력
- **중앙 집중식 상수 관리** (2025-07-13)
  - 하드코딩된 값들을 상수로 추출
  - 카테고리별 파일 분리

- **FieldStyles 시스템 도입** (2025-07-14)
  - 입력 필드 스타일 중앙 관리
  - FieldConfig 객체 패턴 적용

- **타겟 오디언스 상수 추가** (2025-07-20)
  - AI 기반 타겟팅 시스템 지원
  - 수집 방식 및 필터 옵션 정의

## 📝 주요 규칙 및 가이드라인

### 상수 추가 규칙
1. **카테고리 확인**: 적절한 파일에 추가
2. **중복 체크**: 기존 상수 재사용 우선
3. **타입 명시**: 항상 명시적 타입 선언
4. **의미있는 이름**: 용도가 명확한 이름 사용

### 명명 규칙
- **클래스**: PascalCase (예: `ImageConstants`)
- **상수**: lowerCamelCase (예: `defaultPadding`)
- **파일**: snake_case (예: `field_styles.dart`)

### 그룹화 원칙
- 관련 상수는 같은 클래스에
- 논리적 섹션으로 구분 (주석 사용)
- static const 사용

## 🚀 향후 개선 사항

### 계획된 개선
- [ ] 환경별 설정 분리 (dev/prod)
- [ ] 다국어 지원 (strings.dart → i18n)
- [ ] 테마 통합 (colors.dart → theme)
- [ ] 동적 설정 지원

### 성능 최적화
- [ ] const 생성자 활용 극대화
- [ ] tree shaking 최적화
- [ ] 빌드 타임 상수 주입

### 유지보수
- [ ] 자동 문서 생성
- [ ] 상수 사용처 추적
- [ ] 미사용 상수 정리