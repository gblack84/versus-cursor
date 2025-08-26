# 📂 Common Domain Models

> Domain Layer의 공통 모델 - 여러 Feature에서 사용되는 도메인 모델

## 📋 개요

Common Domain Models는 애플리케이션 전반에서 사용되는 공통 도메인 모델을 정의합니다. 페이지네이션, 에러, 설정, 레이아웃 상수 등 범용적인 데이터 구조를 포함합니다.

## 🎯 모델 역할

### 핵심 책임
- 공통 데이터 구조 정의
- 비즈니스 로직 캡슐화
- 타입 안정성 제공
- 불변성 보장
- 도메인 규칙 구현

### 모델이 하는 일
- 데이터 검증
- 비즈니스 규칙 적용
- 값 객체 정의
- 엔티티 표현
- 상태 관리

### 모델이 하지 않는 일
- UI 로직 포함
- 데이터베이스 직접 접근
- 네트워크 호출
- 파일 시스템 조작

## 📁 파일 구조

```
models/
# 실제 마이그레이션 파일
├── layout_constants.dart       # 레이아웃 상수 (from /shared/constants/)
├── uploaded_file.dart          # 파일 업로드 모델 (from /core/)
├── lat_lng.dart                # 위치 좌표 모델 (from /core/)
├── place.dart                  # 장소 정보 모델 (from /core/)
# 선택적 추가 모델
├── pagination_model.dart       # 페이지네이션 모델 (새로 생성)
├── error_model.dart            # 에러 표현 모델 (새로 생성)
├── app_settings.dart           # 앱 설정 모델 (새로 생성)
├── result_model.dart           # 작업 결과 모델 (새로 생성)
└── failure_model.dart          # 실패 타입 정의 (새로 생성)
```

## 🔄 마이그레이션 대상

### 이동할 파일
```bash
# shared에서 이동 (1개)
git mv lib/shared/constants/layout_constants.dart \
       lib/features/common/domain/models/layout_constants.dart

# Core에서 이동 (3개)
git mv lib/core/uploaded_file.dart \
       lib/features/common/domain/models/uploaded_file.dart
git mv lib/core/lat_lng.dart \
       lib/features/common/domain/models/lat_lng.dart
git mv lib/core/place.dart \
       lib/features/common/domain/models/place.dart
```

### 새로 생성할 파일 (선택사항)
```bash
# 필요 시 추가 모델 생성
touch lib/features/common/domain/models/pagination_model.dart
touch lib/features/common/domain/models/error_model.dart
touch lib/features/common/domain/models/app_settings.dart
touch lib/features/common/domain/models/result_model.dart
touch lib/features/common/domain/models/failure_model.dart
```

## 💻 모델 사양

### PaginationModel
**역할**: 리스트 데이터의 페이지네이션 정보 관리

**핵심 필드**:
- `items`: 현재 페이지 아이템 리스트
- `currentPage`: 현재 페이지 번호
- `totalPages`: 전체 페이지 수
- `totalItems`: 전체 아이템 수
- `itemsPerPage`: 페이지당 아이템 수
- `hasNext/hasPrevious`: 다음/이전 페이지 존재 여부

**주요 메서드**:
- `nextPage(newItems)`: 다음 페이지 데이터 추가
- `refresh(newItems)`: 첫 페이지로 리프레시
- `copyWith()`: 불변 객체 복사
- `fromJson/toJson`: JSON 직렬화

### ErrorModel
**역할**: 애플리케이션 에러 표현

**핵심 필드**:
- `code`: 에러 코드
- `message`: 에러 메시지
- `details`: 상세 정보
- `timestamp`: 발생 시간
- `type`: ErrorType enum
- `severity`: ErrorSeverity enum
- `metadata`: 추가 데이터

**에러 타입**:
- `network`: 네트워크 에러
- `validation`: 검증 실패
- `permission`: 권한 없음
- `notFound`: 리소스 없음
- `server`: 서버 에러
- `unknown`: 알 수 없는 에러

**팩토리 메서드**:
- `ErrorModel.unknown()`
- `ErrorModel.network()`
- `ErrorModel.validation()`
- `ErrorModel.permission()`

### AppSettings
**역할**: 애플리케이션 전역 설정 관리

**핵심 구조**:
- `themeMode`: 테마 모드 (다크/라이트/시스템)
- `languageCode`: 언어 설정
- `notificationSettings`: 알림 설정
- `privacySettings`: 개인정보 설정
- `displaySettings`: 표시 설정

**NotificationSettings**:
- Push, Email, SMS 알림 활성화
- 투표, 댓글, 팔로우 알림
- 마케팅 알림

**PrivacySettings**:
- 프로필 공개 여부
- 온라인 상태 표시
- 다이렉트 메시지 허용
- 활동 상태 표시

**DisplaySettings**:
- 폰트 크기 배율
- 컴팩트 모드
- 자동 비디오 재생
- 썸네일 표시

### LayoutConstants
**역할**: 애플리케이션 레이아웃 상수 정의

**상수 카테고리**:
- **패딩**: XSmall(4) ~ XLarge(32)
- **마진**: XSmall(4) ~ XLarge(32)
- **반경**: XSmall(4) ~ Circle(999)
- **아이콘 크기**: XSmall(16) ~ XLarge(48)
- **버튼 높이**: Small(32), Medium(44), Large(56)
- **앱바 높이**: AppBar(56), BottomBar(60)
- **애니메이션**: Fast(200ms), Normal(300ms), Slow(500ms)
- **브레이크포인트**: Mobile(428), Tablet(768), Desktop(1200)
- **화면 비율**: 16:9, 4:3, 1:1, 3:4, 9:16

### UploadedFile (from Core)
**역할**: 업로드된 파일 정보 관리

**핵심 필드**:
- 파일 경로
- 파일 이름
- 파일 크기
- MIME 타입
- 업로드 상태

### LatLng (from Core)
**역할**: 위치 좌표 표현

**핵심 필드**:
- `latitude`: 위도
- `longitude`: 경도
- 좌표 유효성 검증

### Place (from Core)
**역할**: 장소 정보 표현

**핵심 필드**:
- 장소명
- 주소
- 좌표 (LatLng)
- 메타데이터

## 🧪 테스트 전략

### 단위 테스트
- Equatable 동작 검증
- copyWith 메서드 정확성
- JSON 직렬화/역직렬화
- 비즈니스 규칙 적용
- 경계값 처리

### 테스트 시나리오
- PaginationModel: 페이지 전환, 리프레시
- ErrorModel: 에러 타입별 메시지
- AppSettings: 설정 업데이트, 기본값
- LayoutConstants: 상수 값 일관성

## 📊 의존성 관리

### 필요한 패키지
```yaml
dependencies:
  equatable: ^2.0.0
  flutter:
    sdk: flutter
```

## ⚠️ 마이그레이션 체크리스트

- [ ] 디렉토리 생성
  ```bash
  mkdir -p lib/features/common/domain/models
  ```

- [ ] 파일 이동 (git mv)
  ```bash
  # shared에서 이동
  git mv lib/shared/constants/layout_constants.dart \
         lib/features/common/domain/models/layout_constants.dart
  
  # Core에서 이동
  git mv lib/core/uploaded_file.dart \
         lib/features/common/domain/models/uploaded_file.dart
  git mv lib/core/lat_lng.dart \
         lib/features/common/domain/models/lat_lng.dart
  git mv lib/core/place.dart \
         lib/features/common/domain/models/place.dart
  ```

- [ ] 새 파일 생성
  ```bash
  touch lib/features/common/domain/models/pagination_model.dart
  touch lib/features/common/domain/models/error_model.dart
  touch lib/features/common/domain/models/app_settings.dart
  touch lib/features/common/domain/models/result_model.dart
  touch lib/features/common/domain/models/failure_model.dart
  ```

- [ ] Import 경로 수정
  ```dart
  // Before
  import '/shared/constants/layout_constants.dart';
  
  // After
  import '/features/common/domain/models/layout_constants.dart';
  ```

- [ ] 테스트 작성
- [ ] 문서 업데이트

## 📌 Core 마이그레이션 연동

**필수 이동 파일**: Core 디렉토리의 다음 파일들이 이 디렉토리로 이동됩니다:
- `uploaded_file.dart`: 파일 업로드 관련 모델
- `lat_lng.dart`: 위치 데이터 모델
- `place.dart`: 장소 정보 모델

---

*Common Domain Models는 애플리케이션 전반에서 사용되는 핵심 데이터 구조를 제공합니다.*
*최종 업데이트: 2025-08-25*