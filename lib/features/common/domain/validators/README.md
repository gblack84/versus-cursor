# 📂 Common Validators

> Domain Layer의 검증 로직 - 공통 입력 검증 및 비즈니스 규칙

## 📋 개요

Common Validators는 애플리케이션 전반에서 사용되는 입력 검증 로직을 제공합니다. 이메일, 전화번호, 패스워드 등 일반적인 검증과 비즈니스 규칙을 구현합니다.

## 🎯 검증자 역할

### 핵심 책임
- 입력 데이터 검증
- 비즈니스 규칙 적용
- 일관된 검증 로직 제공
- 에러 메시지 표준화
- 타입 안정성 보장

### 검증자가 하는 일
- 형식 검증 (이메일, URL, 전화번호 등)
- 길이 검증 (최소/최대)
- 패턴 매칭
- 비즈니스 규칙 검증
- 커스텀 검증 로직

### 검증자가 하지 않는 일
- UI 렌더링
- 데이터베이스 접근
- 네트워크 호출
- 상태 관리

## 📁 파일 구조

```
validators/
├── input_validators.dart       # 입력 필드 검증
├── auth_validators.dart        # 인증 관련 검증
├── content_validators.dart     # 콘텐츠 검증
├── business_validators.dart    # 비즈니스 규칙 검증
└── validation_result.dart      # 검증 결과 모델
```

## 💻 검증자 사양

### ValidationResult 모델
**역할**: 검증 결과 표현 및 에러 정보 관리

**핵심 필드**:
- `isValid`: 검증 성공 여부
- `errorMessage`: 에러 메시지
- `errorCode`: 에러 코드 (프로그래밍 용도)
- `metadata`: 추가 정보 (Map)

**팩토리 메서드**:
- `ValidationResult.valid()`: 성공 결과 생성
- `ValidationResult.invalid(message, code, metadata)`: 실패 결과 생성

**FieldValidationResult**: 여러 필드 검증 결과 집합
- `fieldResults`: 필드별 검증 결과 Map
- `isValid`: 모든 필드 유효성
- `errors`: 에러 메시지 리스트
- `fieldErrors`: 필드별 에러 Map

### InputValidators
**역할**: 일반적인 입력 필드 검증

**검증 메서드**:
- `required(value, fieldName)`: 필수 입력 검증
- `email(value)`: 이메일 형식 검증
- `url(value)`: URL 형식 검증
- `phone(value)`: 전화번호 형식 검증 (한국)
- `minLength(value, min, fieldName)`: 최소 길이
- `maxLength(value, max, fieldName)`: 최대 길이
- `lengthRange(value, min, max, fieldName)`: 길이 범위
- `numbersOnly(value)`: 숫자만 허용
- `alphabetsOnly(value)`: 알파벳만 허용
- `alphanumeric(value)`: 알파벳과 숫자만 허용
- `username(value)`: 사용자명 검증 (3-20자, 영문/숫자/_)

### AuthValidators
**역할**: 인증 및 계정 관련 검증

**검증 메서드**:
- `password(value)`: 패스워드 복잡도 검증
  - 최소 8자, 최대 128자
  - 대문자, 소문자, 숫자, 특수문자 중 3가지 이상 포함
- `confirmPassword(password, confirmPassword)`: 패스워드 일치 확인
- `otpCode(value)`: 6자리 OTP 코드 검증
- `age(birthDate)`: 나이 제한 검증 (13세 이상)

### ContentValidators
**역할**: 사용자 생성 콘텐츠 검증

**검증 메서드**:
- `title(value)`: 제목 검증
  - 3-100자 제한
  - 금지어 필터링
- `description(value)`: 설명 검증
  - 최대 1000자
  - 선택 사항
- `comment(value)`: 댓글 검증
  - 최대 500자
  - 스팸 감지 (반복 문자)
- `tag(value)`: 태그 검증
  - 2-30자
  - 한글/영문/숫자/언더스코어만 허용

### BusinessValidators
**역할**: 도메인 특화 비즈니스 규칙 검증

**검증 메서드**:
- `versusOptions(optionA, optionB)`: A vs B 옵션 검증
  - 두 옵션 필수
  - 중복 불가
- `votingPeriod(startTime, endTime)`: 투표 기간 검증
  - 최소 10분, 최대 30일
  - 종료 시간이 시작 시간 이후
- `points(points, maxPoints)`: 포인트 검증
  - 0 이상
  - 보유 포인트 초과 불가
- `imageFile(filePath)`: 이미지 파일 검증
  - 지원 형식: JPG, PNG, GIF, WebP
- `videoFile(filePath)`: 비디오 파일 검증
  - 지원 형식: MP4, MOV, AVI, WebM

## 🧪 테스트 전략

### 단위 테스트
- 각 검증 메서드별 테스트
- 유효한 입력 케이스
- 무효한 입력 케이스
- 경계값 테스트
- 에러 코드 및 메시지 확인

### 테스트 시나리오
- InputValidators: 이메일, 전화번호, 길이 제한
- AuthValidators: 패스워드 복잡도, OTP, 나이 제한
- ContentValidators: 금지어, 스팸, 길이 제한
- BusinessValidators: 비즈니스 규칙, 파일 형식

## 📊 의존성 관리

### 필요한 패키지
```yaml
dependencies:
  equatable: ^2.0.0
```

## ⚠️ 마이그레이션 체크리스트

- [ ] 디렉토리 생성
  ```bash
  mkdir -p lib/features/common/domain/validators
  ```

- [ ] 파일 생성
  ```bash
  touch lib/features/common/domain/validators/validation_result.dart
  touch lib/features/common/domain/validators/input_validators.dart
  touch lib/features/common/domain/validators/auth_validators.dart
  touch lib/features/common/domain/validators/content_validators.dart
  touch lib/features/common/domain/validators/business_validators.dart
  ```

- [ ] 테스트 작성
- [ ] 문서 업데이트

---

*Common Validators는 애플리케이션 전반에서 사용되는 검증 로직을 제공합니다.*
*최종 업데이트: 2025-08-25*