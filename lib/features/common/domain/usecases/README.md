# 📂 Common Use Cases

> Domain Layer의 공통 유스케이스 - 공통 비즈니스 로직

## 📋 개요

Common Use Cases는 여러 Feature에서 공통으로 사용되는 비즈니스 로직을 구현합니다. 콘텐츠 검증, 설정 관리, 캐시 관리 등의 핵심 비즈니스 로직을 포함합니다.

## 🎯 유스케이스 역할

### 핵심 책임
- 공통 비즈니스 로직 구현
- 단일 책임 원칙 준수
- 비즈니스 규칙 적용
- 리포지토리 조정
- 도메인 로직 캡슐화

### 유스케이스가 하는 일
- 비즈니스 규칙 실행
- 데이터 검증 및 변환
- 리포지토리 호출 조정
- 에러 처리
- 트랜잭션 관리

### 유스케이스가 하지 않는 일
- UI 로직 처리
- 직접적인 데이터베이스 접근
- 네트워크 호출
- 상태 관리

## 📁 파일 구조

```
usecases/
├── validate_content_usecase.dart    # 콘텐츠 검증
├── clear_cache_usecase.dart        # 캐시 초기화
├── load_settings_usecase.dart      # 설정 로드
├── save_settings_usecase.dart      # 설정 저장
├── export_data_usecase.dart        # 데이터 내보내기
└── import_data_usecase.dart        # 데이터 가져오기
```

## 💻 유스케이스 사양

### UseCase 기본 인터페이스
**역할**: 모든 유스케이스의 기본 계약 정의

**구성 요소**:
- `UseCase<Type, Params>`: 파라미터가 있는 유스케이스
- `NoParamsUseCase<Type>`: 파라미터가 없는 유스케이스
- `Params`: 파라미터 기본 클래스 (Equatable)
- `Failure`: 에러 표현 기본 클래스

**Failure 타입**:
- `CacheFailure`: 캐시 관련 에러
- `ValidationFailure`: 검증 실패
- `StorageFailure`: 스토리지 에러
- `SettingsFailure`: 설정 관련 에러

### ValidateContentUseCase
**역할**: 사용자 콘텐츠 검증 및 필터링

**입력 파라미터**:
- `content`: 검증할 콘텐츠
- `type`: ContentType (title, description, comment)
- `additionalRules`: 추가 검증 규칙 (선택적)

**반환 타입**: `Either<Failure, ValidationResult>`

**검증 프로세스**:
1. 기본 형식 검증 (길이, 패턴)
2. 콘텐츠 필터링 (금지어, 부적절한 내용)
3. 추가 비즈니스 규칙 적용
4. 검증 결과 반환

### ClearCacheUseCase
**역할**: 캐시 데이터 초기화

**입력 파라미터**:
- `keys`: 삭제할 캐시 키 목록 (선택적)
- `pattern`: 패턴 매칭으로 삭제 (선택적)
- 파라미터 없음: 전체 캐시 초기화

**반환 타입**: `Either<Failure, void>`

**초기화 옵션**:
- `ClearCacheParams.all()`: 전체 캐시 삭제
- `ClearCacheParams.byKeys(keys)`: 특정 키만 삭제
- `ClearCacheParams.byPattern(pattern)`: 패턴 매칭 삭제

### LoadSettingsUseCase
**역할**: 앱 설정 로드

**입력 파라미터**: 없음 (NoParamsUseCase)

**반환 타입**: `Either<Failure, AppSettings>`

**로드 프로세스**:
1. 설정 리포지토리 호출
2. 설정 데이터 검증
3. AppSettings 모델 반환
4. 에러 처리 및 매핑

### SaveSettingsUseCase
**역할**: 앱 설정 저장

**입력 파라미터**:
- `settings`: AppSettings 객체

**반환 타입**: `Either<Failure, void>`

**저장 프로세스**:
1. 설정 데이터 검증
2. 필수 필드 확인
3. 리포지토리를 통한 저장
4. 성공/실패 반환

### ExportDataUseCase
**역할**: 데이터 내보내기

**입력 파라미터**:
- `data`: 내보낼 데이터 (Map)
- `dataType`: ExportDataType (settings, userData, posts, all)
- `saveToFile`: 파일 저장 여부 (선택적)

**반환 타입**: `Either<Failure, String>` (JSON 문자열)

**내보내기 프로세스**:
1. 데이터 수집 및 메타데이터 추가
2. JSON 직렬화
3. 파일 저장 (선택적)
4. JSON 문자열 반환

### ImportDataUseCase
**역할**: 외부 데이터 가져오기

**입력 파라미터**:
- `fileName`: 파일명 (선택적)
- `jsonString`: JSON 문자열 (선택적)
- `validateVersion`: 버전 검증 여부

**반환 타입**: `Either<Failure, Map<String, dynamic>>`

**가져오기 프로세스**:
1. 데이터 소스 확인 (파일 또는 문자열)
2. JSON 파싱
3. 버전 검증 (선택적)
4. 데이터 추출 및 반환

## 🧪 테스트 전략

### 단위 테스트
- Mock Repository 사용
- 성공/실패 시나리오 테스트
- 경계값 테스트
- 에러 핸들링 검증

### 테스트 케이스
- ValidateContentUseCase: 유효한 콘텐츠, 부적절한 콘텐츠, 길이 초과
- ClearCacheUseCase: 전체 삭제, 패턴 삭제, 특정 키 삭제
- LoadSettingsUseCase: 설정 로드 성공, 설정 없음, 로드 실패
- SaveSettingsUseCase: 저장 성공, 검증 실패, 저장 실패
- ExportDataUseCase: JSON 변환, 파일 저장, 내보내기 실패
- ImportDataUseCase: 파일 가져오기, JSON 파싱, 버전 검증

## 📊 의존성 관리

### 필요한 패키지
```yaml
dependencies:
  dartz: ^0.10.0
  equatable: ^2.0.0
```

### Repository 인터페이스
- `CacheRepository`: 캐시 관리 인터페이스
- `StorageRepository`: 스토리지 관리 인터페이스
- `SettingsRepository`: 설정 관리 인터페이스

## ⚠️ 마이그레이션 체크리스트

- [ ] 디렉토리 생성
  ```bash
  mkdir -p lib/features/common/domain/usecases
  mkdir -p lib/features/common/domain/repositories
  ```

- [ ] 파일 생성
  ```bash
  touch lib/features/common/domain/usecases/usecase.dart
  touch lib/features/common/domain/usecases/validate_content_usecase.dart
  touch lib/features/common/domain/usecases/clear_cache_usecase.dart
  touch lib/features/common/domain/usecases/load_settings_usecase.dart
  touch lib/features/common/domain/usecases/save_settings_usecase.dart
  touch lib/features/common/domain/usecases/export_data_usecase.dart
  touch lib/features/common/domain/usecases/import_data_usecase.dart
  ```

- [ ] Repository 인터페이스 생성
  ```bash
  touch lib/features/common/domain/repositories/cache_repository.dart
  touch lib/features/common/domain/repositories/storage_repository.dart
  touch lib/features/common/domain/repositories/settings_repository.dart
  ```

- [ ] 테스트 작성
- [ ] 문서 업데이트

---

*Common Use Cases는 애플리케이션 전반에서 사용되는 핵심 비즈니스 로직을 제공합니다.*
*최종 업데이트: 2025-08-25*