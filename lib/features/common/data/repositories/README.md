# 📂 Common Repositories

> Data Layer의 공통 리포지토리 구현 - 공통 데이터 접근 패턴

## 📋 개요

Common Repositories는 여러 Feature에서 공통으로 사용되는 데이터 접근 패턴을 구현합니다. 스토리지, 캐싱, 설정 관리 등 전역적인 데이터 접근을 담당합니다.

## 🎯 리포지토리 역할

### 핵심 책임
- 로컬 스토리지 추상화
- 캐시 데이터 관리
- 앱 설정 저장/조회
- 파일 시스템 접근
- 공통 데이터 패턴 구현

### 리포지토리가 하는 일
- SharedPreferences 래핑
- 파일 저장/로드
- 캐시 전략 구현
- 설정 값 관리
- 데이터 변환 및 검증

### 리포지토리가 하지 않는 일
- UI 로직 처리
- 비즈니스 규칙 구현
- 네트워크 통신
- Feature 특화 데이터 관리

## 📁 파일 구조

```
repositories/
├── storage_repository_impl.dart    # 로컬 스토리지 리포지토리
├── cache_repository_impl.dart      # 캐시 관리 리포지토리
└── settings_repository_impl.dart   # 앱 설정 리포지토리
```

## 🔄 마이그레이션 대상

### 새로 생성할 파일
```bash
# 리포지토리 구현체들
touch lib/features/common/data/repositories/storage_repository_impl.dart
touch lib/features/common/data/repositories/cache_repository_impl.dart
touch lib/features/common/data/repositories/settings_repository_impl.dart
```

## 💻 리포지토리 사양

### StorageRepositoryImpl
**역할**: 로컬 스토리지 데이터 접근

**구현 내용**:
- SharedPreferences 초기화 및 관리
- 기본 타입 저장/조회 (String, Int, Bool)
- JSON 데이터 직렬화/역직렬화
- 파일 시스템 접근 (저장, 로드, 삭제)
- 키-값 쌍 관리
- 전체 초기화 기능

**주요 메서드**:
- `saveString(key, value)` - String 값 저장
- `getString(key)` - String 값 조회
- `saveJson(key, json)` - JSON 객체 저장
- `getJson(key)` - JSON 객체 조회
- `saveFile(fileName, content)` - 파일 저장
- `loadFile(fileName)` - 파일 로드
- `remove(key)` - 특정 키 삭제
- `clear()` - 전체 초기화

### CacheRepositoryImpl
**역할**: 메모리 캐시 관리

**구현 내용**:
- 인메모리 캐시 저장소
- TTL(Time To Live) 관리
- 캐시 엔트리 만료 처리
- 패턴 기반 캐시 삭제
- 캐시 크기 관리
- 자동 만료 캐시 정리

**주요 메서드**:
- `set(key, value, ttl)` - 캐시 저장
- `get(key)` - 캐시 조회
- `has(key)` - 캐시 존재 확인
- `remove(key)` - 캐시 삭제
- `removeByPattern(pattern)` - 패턴으로 삭제
- `clear()` - 전체 캐시 초기화
- `size` - 캐시 크기 조회

**캐시 정책**:
- 기본 TTL: 5분
- 만료된 캐시 자동 정리
- 조회 시 만료 확인

### SettingsRepositoryImpl
**역할**: 앱 설정 관리

**구현 내용**:
- AppSettings 모델 관리
- 설정 영속화 (StorageRepository 활용)
- 설정 캐싱
- 개별 설정 업데이트
- 기본값 관리
- 설정 초기화

**주요 메서드**:
- `loadSettings()` - 설정 로드
- `saveSettings(settings)` - 설정 저장
- `updateThemeMode(mode)` - 테마 모드 업데이트
- `updateLanguage(languageCode)` - 언어 설정 업데이트
- `updateNotificationSettings(settings)` - 알림 설정 업데이트
- `resetSettings()` - 설정 초기화

**설정 항목**:
- 테마 모드 (다크/라이트/시스템)
- 언어 설정
- 알림 설정
- 기타 앱 전역 설정

## 🧪 테스트 전략

### 단위 테스트
- 각 리포지토리 메서드 개별 테스트
- 성공/실패 케이스 검증
- 데이터 변환 정확성 확인
- 캐시 만료 동작 테스트
- 설정 업데이트 테스트

### 통합 테스트
- 리포지토리 간 상호작용
- 파일 시스템 연동
- SharedPreferences 연동
- 설정 영속화 테스트

## 📊 의존성 관리

### 필요한 패키지
```yaml
dependencies:
  shared_preferences: ^2.0.0
  path_provider: ^2.0.0
  dartz: ^0.10.0
```

## ⚠️ 마이그레이션 체크리스트

- [ ] 디렉토리 생성
  ```bash
  mkdir -p lib/features/common/data/repositories
  ```

- [ ] 파일 생성
  ```bash
  touch lib/features/common/data/repositories/storage_repository_impl.dart
  touch lib/features/common/data/repositories/cache_repository_impl.dart
  touch lib/features/common/data/repositories/settings_repository_impl.dart
  ```

- [ ] Domain 인터페이스 생성
  ```bash
  touch lib/features/common/domain/repositories/storage_repository.dart
  touch lib/features/common/domain/repositories/cache_repository.dart
  touch lib/features/common/domain/repositories/settings_repository.dart
  ```

- [ ] 테스트 작성
- [ ] 문서 업데이트

---

*Common Repositories는 애플리케이션 전반에서 사용되는 데이터 접근 패턴을 제공합니다.*