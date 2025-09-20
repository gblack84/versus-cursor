# Analysis Addendum: Auth Feature Migration Issues

**Date**: 2025-01-20
**Branch**: `001-users-g-black`
**Purpose**: 문제 분석 결과 및 개선 계획 보충

## 🔍 문제 분석 요약

### 발견된 핵심 문제점

#### 1. Voting 피처 참조 모델 누락 ❌
- **현황**: 5개 문서 모두에서 voting 피처 언급 전혀 없음
- **영향**: 실제 프로젝트 구조와 불일치하는 계획 수립
- **원인**: 처음부터 참조 모델 지정 없이 시작

#### 2. DI 모듈 계획 불완전 ⚠️
- **Voting 구조**: `lib/features/voting/di/voting_di_module.dart` 완비
- **Auth 계획**: DI 언급은 있으나 구체적 구현 계획 부족
- **누락**: GetIt 바인딩 구조, Mock 분리 전략

#### 3. Ports 패턴 미적용 ❌
- **Voting 구조**:
  ```
  domain/
  ├── repositories/  # Repository 인터페이스
  └── ports/        # External service 인터페이스
  ```
- **Auth 계획**: repositories/만 사용, ports/ 없음

#### 4. DataSources 구조 단순화 ⚠️
- **Voting 구조**:
  ```
  data/datasources/
  ├── local/
  │   ├── services/  # 캐시 서비스
  │   └── utils/     # 헬퍼 함수
  └── remote/
      └── firebase/  # 외부 연동
  ```
- **Auth 계획**: 단순 datasources/ 구조만 계획

## 📊 비교 분석표

| 구성 요소 | Voting 피처 (실제) | Auth Tasks (계획) | 개선 필요 |
|----------|-------------------|-------------------|-----------|
| **DI Module** | ✅ `di/voting_di_module.dart` | ⚠️ 부분 언급만 | ✅ 추가 필요 |
| **Ports Pattern** | ✅ `domain/ports/` | ❌ 없음 | ✅ 추가 필요 |
| **DataSources** | ✅ `local/services/utils` | ❌ 단순 구조 | ✅ 구조화 필요 |
| **UseCase Count** | ✅ 15개 실제 구현 | ⚠️ 25개 계획 | ✅ 재검토 필요 |
| **Test Structure** | ✅ feature-level | ✅ 계획됨 | ✅ 유지 |
| **Reference Model** | - | ❌ 없음 | ✅ voting 지정 |

## 🎯 개선 계획

### Phase 0: 참조 모델 설정 (신규)
```yaml
reference_model: "/lib/features/voting"
analysis_command: |
  /spawn inventory-scout --feature voting --export-structure
  /spawn code-surgeon --analyze voting/di voting/domain/ports
```

### Phase 1: DI 모듈 추가
```dart
// lib/features/auth/di/auth_di_module.dart
class AuthDIModule {
  static void configureDependencies(GetIt getIt) {
    // Repositories
    getIt.registerLazySingleton<IAuthRepository>(
      () => AuthRepositoryImpl(/* deps */),
    );

    // UseCases (1 per file principle)
    getIt.registerFactory(() => GetCurrentUserUseCase(getIt()));
    getIt.registerFactory(() => SignInUseCase(getIt()));
    // ... 23 more UseCases

    // Ports (External Services)
    getIt.registerLazySingleton<IAuthService>(
      () => FirebaseAuthService(),
    );
  }
}
```

### Phase 2: Ports 패턴 적용
```
domain/
├── repositories/        # Data access interfaces
│   └── i_auth_repository.dart
└── ports/              # External service interfaces
    ├── i_auth_service.dart
    ├── i_token_service.dart
    ├── i_session_service.dart
    └── i_notification_port.dart
```

### Phase 3: DataSources 구조화
```
data/datasources/
├── local/
│   ├── services/
│   │   ├── auth_cache_service.dart
│   │   ├── token_storage_service.dart
│   │   └── session_cache_service.dart
│   └── utils/
│       ├── cache_keys.dart
│       └── cache_helpers.dart
└── remote/
    ├── firebase/
    │   ├── firebase_auth_datasource.dart
    │   └── firestore_user_datasource.dart
    └── api/
        └── external_auth_api.dart
```

## 🚨 중요 수정 사항

### Tasks.md 수정 필요 항목

#### T000: DI 모듈 생성 (신규 추가)
- **설명**: Voting 피처와 동일한 DI 구조 구현
- **파일**: `lib/features/auth/di/auth_di_module.dart`
- **참조**: `lib/features/voting/di/voting_di_module.dart`

#### T004: DataSources 구조 개선
- **기존**: 단순 datasources 인터페이스
- **수정**: local/services + remote/firebase 구조
- **추가 파일**:
  - `data/datasources/local/services/` (3개 서비스)
  - `data/datasources/local/utils/` (2개 헬퍼)

#### T013-T025: UseCase 확장 명확화
- **기존 2개 UseCase 기반**:
  - `auth_state_usecase.dart` → 5개로 분할
  - `get_current_user_usecase.dart` → 사용자 관련 3개 추가
- **신규 UseCase** (17개):
  - Authentication: 7개
  - Token Management: 3개
  - Profile Management: 4개
  - Session Management: 3개

## 📋 체크리스트

### 즉시 수정 필요
- [x] spec.md에 voting 피처 참조 명시 ✅
- [x] tasks.md에 T000 (DI 모듈) 추가 ✅
- [x] tasks.md T004 DataSources 구조 세분화 ✅
- [x] plan.md에 Ports 패턴 섹션 추가 ✅

### 추가 개선사항 (2025-01-20 완료) 🆕
- [x] spec.md에 --bridge false 플래그 추가 ✅
- [x] tasks.md에 T0.5 grep 검색 작업 추가 ✅
- [x] plan.md에 Atomic Commit Strategy 섹션 추가 ✅
- [x] auth_migration_manifest.yml 생성 ✅
- [x] quickstart.md에 커밋 추적 가이드라인 추가 ✅

### 구현 시 확인
- [ ] Voting 피처 구조 완전 분석
- [ ] Sub-agent 활용 (InventoryScout, DIBinder)
- [ ] 기존 auth 코드 재사용 계획 구체화
- [ ] Mock 인프라가 Ports 패턴 지원하는지 확인

## 🔄 Sub-agent 활용 전략

### 올바른 활용 순서
```bash
# 1. Voting 피처 구조 분석
/spawn inventory-scout --feature voting --export-structure

# 2. Auth 피처 현황 분석
/spawn inventory-scout --feature auth --compare voting

# 3. Repository 이동 계획
/spawn repo-mover --feature auth --reference voting --dry-run

# 4. DI 바인딩 생성
/spawn di-binder --feature auth --pattern voting

# 5. Import 검증
/spawn import-guardian --feature auth --fix
```

## 💡 핵심 교훈

1. **참조 모델 필수**: 마이그레이션 시 기존 성공 사례를 반드시 참조
2. **구조 분석 우선**: 코드 작성 전 기존 구조 완전 이해
3. **Sub-agent 활용**: 수동 분석보다 자동화 도구 적극 활용
4. **점진적 검증**: 각 단계별 voting 피처와 비교 검증

---

*이 문서는 원래 계획의 보충 자료로, voting 피처 구조를 완전히 반영한 개선 계획을 담고 있습니다.*