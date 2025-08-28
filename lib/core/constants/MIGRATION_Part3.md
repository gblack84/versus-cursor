# 📋 Core Constants 마이그레이션 계획 (Part 3)

> 작성일: 2025-08-28 | 대상: Core Constants 레이어 | 예상 기간: 1주일

## 🎯 마이그레이션 목표

Core Constants 레이어를 Feature-First Architecture에 맞게 재구조화하여:
- ✅ 타입 안전성 강화
- ✅ 도메인별 상수 그룹핑
- ✅ Design System과 통합
- ✅ Feature 독립성 보장

## 📊 현재 상태 분석

### 📁 현재 구조
```
lib/core/constants/
└── layout_constants.dart (214줄)
```

### 🔍 식별된 문제점
1. **단일 파일 집중** - 모든 레이아웃 상수가 하나의 파일에
2. **문자열 기반 타입** - 타입 안전성 부족
3. **Design System 분리** - tokens와 constants 중복
4. **확장성 부족** - 새로운 상수 추가 어려움

## 📈 마이그레이션 전략

### 🏗️ 목표 구조
```
lib/
├── core/
│   ├── constants/
│   │   ├── app/                      # 앱 전역 상수
│   │   │   ├── app_constants.dart    # 앱 설정 상수
│   │   │   ├── api_constants.dart    # API 엔드포인트
│   │   │   └── env_constants.dart    # 환경 변수
│   │   │
│   │   ├── layout/                   # 레이아웃 시스템
│   │   │   ├── layout_constants.dart # 기존 파일 (개선)
│   │   │   ├── container_types.dart  # ContainerType enum
│   │   │   ├── breakpoints.dart      # 반응형 중단점
│   │   │   └── grid_constants.dart   # 그리드 시스템
│   │   │
│   │   ├── validation/               # 유효성 검증
│   │   │   ├── input_limits.dart     # 입력 제한값
│   │   │   ├── file_limits.dart      # 파일 크기 제한
│   │   │   └── business_rules.dart   # 비즈니스 규칙
│   │   │
│   │   ├── base/                     # 베이스 클래스
│   │   │   └── base_constants.dart   # 상수 인터페이스
│   │   │
│   │   └── index.dart                # 통합 export
│   │
│   └── design_system/
│       └── tokens/                   # 기존 유지 (통합 계획)
```

## 🔄 마이그레이션 단계

### Phase 1: 타입 안전성 강화 (Day 1)
#### 1.1 ContainerType Enum 생성
```dart
// lib/core/constants/layout/container_types.dart
enum ContainerType {
  question('question'),
  notification('notification'),
  message('message');
  
  final String value;
  const ContainerType(this.value);
}
```

#### 1.2 LayoutConstants 업데이트
- [ ] 문자열 상수를 enum으로 변경
- [ ] getMaxHeight() 메서드 시그니처 수정
- [ ] getMinHeight() 메서드 시그니처 수정
- [ ] getWidthRatio() 메서드 시그니처 수정

#### 1.3 사용처 마이그레이션
- [ ] `unified_box_calculator.dart` 수정
- [ ] 테스트 코드 업데이트
- [ ] 타입 체크 검증

### Phase 2: 디렉토리 구조화 (Day 2)
#### 2.1 폴더 생성
```bash
mkdir -p lib/core/constants/{app,layout,validation,base}
```

#### 2.2 상수 분리
- [ ] 앱 전역 상수 분리 (`app/app_constants.dart`)
- [ ] API 엔드포인트 분리 (`app/api_constants.dart`)
- [ ] 환경 변수 분리 (`app/env_constants.dart`)
- [ ] 입력 제한 분리 (`validation/input_limits.dart`)

#### 2.3 Index 파일 생성
```dart
// lib/core/constants/index.dart
export 'app/app_constants.dart';
export 'app/api_constants.dart';
export 'app/env_constants.dart';
export 'layout/layout_constants.dart';
export 'layout/container_types.dart';
export 'validation/input_limits.dart';
```

### Phase 3: Design System 통합 (Day 3-4)
#### 3.1 중복 제거
- [ ] `versus_colors.dart`와 color 상수 통합
- [ ] `versus_spacing.dart`와 spacing 상수 통합
- [ ] `versus_text_styles.dart`와 typography 상수 통합

#### 3.2 통합 전략
```dart
// lib/core/constants/theme/theme_constants.dart
import 'package:versus_space/core/design_system/tokens/versus_colors.dart';
import 'package:versus_space/core/design_system/tokens/versus_spacing.dart';

class ThemeConstants {
  // Design System tokens를 상수로 노출
  static const primaryColor = VersusColors.primary;
  static const defaultSpacing = VersusSpacing.md;
}
```

### Phase 4: Feature별 확장 (Day 5-6)
#### 4.1 Base 클래스 생성
```dart
// lib/core/constants/base/base_constants.dart
abstract class BaseConstants {
  Map<String, dynamic> toJson();
  static BaseConstants fromJson(Map<String, dynamic> json);
}
```

#### 4.2 Feature 상수 생성
```dart
// lib/features/posts/constants/post_constants.dart
class PostConstants extends BaseConstants {
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxImageCount = 4;
  static const int maxImageSize = 10485760; // 10MB
}
```

### Phase 5: 테스트 및 검증 (Day 7)
#### 5.1 유닛 테스트
- [ ] ContainerType enum 테스트
- [ ] 헬퍼 메서드 테스트
- [ ] Feature 상수 테스트

#### 5.2 통합 테스트
- [ ] 레이아웃 시스템 테스트
- [ ] Design System 통합 테스트
- [ ] Feature 사용 테스트

## 📋 체크리스트

### 🔴 즉시 작업 (Day 1)
- [ ] ContainerType enum 생성
- [ ] 타입 안전성 개선
- [ ] 기존 사용처 마이그레이션

### 🟡 단기 작업 (Day 2-4)
- [ ] 디렉토리 구조 생성
- [ ] 상수 파일 분리
- [ ] Design System 통합
- [ ] Index 파일 생성

### 🟢 장기 작업 (Day 5-7)
- [ ] Feature별 상수 확장
- [ ] 테스트 코드 작성
- [ ] 문서화 완성
- [ ] 성능 검증

## 🚀 실행 계획

### Day 1: 타입 안전성
```bash
# ContainerType enum 생성
touch lib/core/constants/layout/container_types.dart

# LayoutConstants 수정
# unified_box_calculator.dart 수정
# 테스트 실행
```

### Day 2: 구조화
```bash
# 디렉토리 생성
mkdir -p lib/core/constants/{app,layout,validation,base}

# 파일 분리
# Index 생성
```

### Day 3-4: Design System 통합
```bash
# 중복 분석
# 통합 전략 수립
# 구현 및 테스트
```

### Day 5-6: Feature 확장
```bash
# Base 클래스 생성
# Feature 상수 생성
# 마이그레이션
```

### Day 7: 테스트 및 배포
```bash
# 유닛 테스트 실행
# 통합 테스트 실행
# 성능 검증
# 문서 업데이트
```

## ⚠️ 위험 요소 및 대응 방안

### 위험 1: Breaking Changes
- **위험도**: 높음
- **영향**: 전체 앱
- **대응**: 점진적 마이그레이션, @deprecated 활용

### 위험 2: Design System 충돌
- **위험도**: 중간
- **영향**: UI 일관성
- **대응**: 단계적 통합, 철저한 테스트

### 위험 3: Feature 의존성
- **위험도**: 낮음
- **영향**: Feature 모듈
- **대응**: 인터페이스 기반 설계

## 📊 예상 효과

### 정량적 효과
- 타입 에러 90% 감소
- 상수 관리 시간 50% 단축
- 코드 중복 30% 감소

### 정성적 효과
- 타입 안전성 보장
- 유지보수성 향상
- Feature 독립성 강화
- 개발자 경험 개선

## 📝 참고 자료

- [Flutter 상수 관리 베스트 프랙티스](https://flutter.dev/docs)
- [Design System 통합 가이드](https://material.io)
- [Feature-First Architecture](https://github.com/feature-first)

---

*이 문서는 Core Constants 레이어의 Feature-First Architecture 마이그레이션 계획입니다.*
*1주일 동안 점진적으로 진행되며, 각 단계별 검증을 포함합니다.*