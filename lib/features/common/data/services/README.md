# 📂 Common Services

> Data Layer의 공통 서비스 구현 - 전역적으로 사용되는 서비스 레이어

## 📋 개요

Common Services는 여러 Feature에서 공통으로 사용되는 서비스를 제공합니다. 로깅, 필터링, 레이아웃 계산, 반응형 처리 등 애플리케이션 전반에서 필요한 기능을 구현합니다.

## 🎯 서비스 역할

### 핵심 책임
- 로깅 시스템 관리
- 콘텐츠 필터링 및 검증
- 레이아웃 크기 계산
- 반응형 브레이크포인트 관리
- 파일 시스템 로깅

### 서비스가 하는 일
- 애플리케이션 전역 로그 수집 및 관리
- 부적절한 콘텐츠 필터링
- 동적 박스 크기 계산
- 디바이스별 반응형 처리
- 파일 기반 로그 저장

### 서비스가 하지 않는 일
- Feature 특화 비즈니스 로직
- UI 렌더링
- 데이터베이스 직접 접근
- 네트워크 통신 관리

## 📁 파일 구조

```
services/
├── app_logger.dart                  # 애플리케이션 로거 (from /utils/)
├── file_logger.dart                 # 파일 시스템 로거 (from /utils/)
├── content_filter.dart              # 콘텐츠 필터링 서비스 (from /utils/)
├── unified_box_calculator.dart      # 박스 크기 계산 서비스 (from /shared/services/)
└── responsive_breakpoints.dart      # 반응형 브레이크포인트 (from /utils/)
```

## 🔄 마이그레이션 대상

### 이동할 파일
```bash
# 유틸리티에서 이동 (5개)
git mv lib/utils/app_logger.dart \
       lib/features/common/data/services/app_logger.dart

git mv lib/utils/file_logger.dart \
       lib/features/common/data/services/file_logger.dart

git mv lib/utils/content_filter.dart \
       lib/features/common/data/services/content_filter.dart

git mv lib/utils/responsive_breakpoints.dart \
       lib/features/common/data/services/responsive_breakpoints.dart

# shared에서 이동 (1개)
git mv lib/shared/services/unified_box_calculator.dart \
       lib/features/common/data/services/unified_box_calculator.dart

# NOTE: vote_message_helper.dart는 Voting Feature로 이동
# git mv lib/utils/vote_message_helper.dart lib/features/voting/data/services/
```

## 💻 서비스 사양

### AppLogger
**역할**: 애플리케이션 전역 로깅 시스템

**기능**:
- 레벨별 로깅 (Verbose, Debug, Info, Warning, Error, Fatal)
- 태그 기반 로그 분류
- 콘솔 출력 (디버그 모드)
- 파일 시스템 저장
- 스택 트레이스 지원
- 싱글톤 패턴 구현

**로그 레벨**:
- `verbose (0)`: 세부 디버깅 정보
- `debug (1)`: 디버그 정보
- `info (2)`: 일반 정보
- `warning (3)`: 경고
- `error (4)`: 오류
- `fatal (5)`: 치명적 오류

### FileLogger
**역할**: 파일 시스템 기반 로그 저장

**기능**:
- 앱 문서 디렉토리에 로그 파일 생성
- 날짜별 로그 파일 분리
- 로그 파일 순환 (rotation)
- 최대 파일 크기 관리
- 비동기 파일 쓰기

### ContentFilter
**역할**: 콘텐츠 필터링 및 검증

**기능**:
- 금지어 감지 및 필터링
- 패턴 기반 콘텐츠 검증
- 텍스트 마스킹 처리
- 콘텐츠 타입별 검증 규칙
- 길이 및 형식 검증

**콘텐츠 타입**:
- `title`: 제목 (3-100자)
- `description`: 설명 (최대 1000자)
- `comment`: 댓글 (1-500자)
- `username`: 사용자명 (3-30자, 영숫자)
- `general`: 일반 텍스트

### UnifiedBoxCalculator
**역할**: 동적 박스 크기 계산

**기능**:
- 가로/세로 레이아웃별 크기 계산
- 이미지 비율 기반 최적화
- 컨테이너 크기 대응
- 일관된 박스 높이 유지
- 최적 레이아웃 추천

**계산 로직**:
- 가로 레이아웃: 평균 비율 사용
- 세로 레이아웃: 고정 비율 적용
- 박스 간격: 8px 고정
- 크기 제한: 컨테이너의 50-80%

### ResponsiveBreakpoints
**역할**: 반응형 디자인 지원

**기능**:
- 디바이스 타입 감지 (Mobile, Tablet, Desktop)
- 디바이스 크기 세분화 (XS ~ XXXL)
- 반응형 값 계산
- 반응형 패딩/폰트 크기
- 그리드 컬럼 수 결정

**브레이크포인트**:
- Mobile Small: 320px
- Mobile Medium: 375px
- Mobile Large: 428px
- Tablet: 768px
- Desktop: 1024px
- Desktop Large: 1440px

## 🧪 테스트 전략

### 단위 테스트
- 로그 레벨 필터링 테스트
- 콘텐츠 필터링 정확성
- 박스 크기 계산 검증
- 반응형 값 계산 테스트

### 통합 테스트
- 로거와 파일 시스템 연동
- 필터링 서비스 성능
- 레이아웃 계산 정확성

## 📊 의존성 관리

### 필요한 패키지
```yaml
dependencies:
  flutter:
    sdk: flutter
  path_provider: ^2.0.0  # 파일 시스템 접근
```

## ⚠️ 마이그레이션 체크리스트

- [ ] 디렉토리 생성
  ```bash
  mkdir -p lib/features/common/data/services
  ```

- [ ] 파일 이동 (git mv)
  ```bash
  git mv lib/utils/app_logger.dart lib/features/common/data/services/
  git mv lib/utils/file_logger.dart lib/features/common/data/services/
  git mv lib/utils/content_filter.dart lib/features/common/data/services/
  git mv lib/utils/responsive_breakpoints.dart lib/features/common/data/services/
  git mv lib/shared/services/unified_box_calculator.dart lib/features/common/data/services/
  ```

- [ ] Import 경로 수정
  ```dart
  // Before
  import '/utils/app_logger.dart';
  
  // After
  import '/features/common/data/services/app_logger.dart';
  ```

- [ ] 테스트 작성
- [ ] 문서 업데이트

---

*Common Services는 애플리케이션 전반에서 사용되는 핵심 서비스를 제공합니다.*
*최종 업데이트: 2025-08-25*