# Auth Feature - Data Layer

## 📊 개요

Data Layer는 Clean Architecture의 중간 계층으로, Domain Layer의 추상 인터페이스를 구현하고 외부 시스템(Firebase, API, 로컬 저장소)과의 실제 통신을 담당합니다. 이 레이어는 비즈니스 로직과 기술적 구현 세부사항을 분리하는 핵심 역할을 수행합니다.

## 🏗️ 전체 구조도

```
lib/features/auth/data/
│
├── 📁 repositories/          # Repository 구현체
│   └── auth_repository_impl.dart
│
├── 📁 datasources/           # 데이터 소스 (원격/로컬)
│   ├── i_auth_remote_datasource.dart    # 원격 인터페이스
│   ├── firebase_auth_remote_datasource.dart  # Firebase 구현
│   ├── i_auth_local_datasource.dart     # 로컬 인터페이스
│   └── auth_local_datasource.dart       # 로컬 구현
│
├── 📁 dto/                   # Data Transfer Objects
│   ├── auth_user_dto.dart              # 사용자 DTO
│   └── user_profile_dto.dart           # 프로필 DTO
│
├── 📁 mappers/               # DTO ↔ Domain Model 변환
│   └── auth_user_mapper.dart           # 사용자 매퍼
│
└── 📁 adapters/              # 레거시 호환성 어댑터
    ├── auth_util.dart                   # 전역 변수 프록시
    ├── base_auth_user_provider.dart     # 기본 인증 프로바이더
    └── firebase_user_provider.dart      # Firebase 사용자 프로바이더
```

## 📂 디렉토리별 상세 설명

### 1. repositories/ - Repository 구현체

**목적**: Domain Layer의 Repository 인터페이스를 구현하여 실제 데이터 작업 수행

#### 📄 auth_repository_impl.dart
```dart
class AuthRepositoryImpl implements IAuthRepository, AuthContract {
  final IAuthRemoteDataSource _remoteDataSource;
  final IAuthLocalDataSource _localDataSource;

  // 주요 책임:
  // 1. 원격/로컬 데이터소스 조율
  // 2. 캐싱 전략 구현
  // 3. DTO → Domain Model 변환
  // 4. 에러 처리 및 변환
}
```

**핵심 기능**:
- ✅ 모든 인증 작업의 중앙 조정자
- ✅ 네트워크/로컬 데이터 소스 통합
- ✅ 트랜잭션 일관성 보장
- ✅ 에러 복구 메커니즘

### 2. datasources/ - 데이터 소스

**목적**: 실제 데이터를 가져오는 구체적인 구현체

#### 📄 i_auth_remote_datasource.dart (인터페이스)
```dart
abstract class IAuthRemoteDataSource {
  // Firebase Auth 작업
  Future<User?> signInWithEmailAndPassword(String email, String password);
  Future<User?> createUserWithEmailAndPassword(String email, String password);
  Future<User?> signInWithGoogle();
  Future<User?> signInWithApple();
  Future<void> signOut();

  // Firestore 작업
  Future<UserProfileDto?> getUserProfile(String uid);
  Future<void> createUserProfile(UserProfileDto profile);
}
```

#### 📄 firebase_auth_remote_datasource.dart (구현체)
```dart
class FirebaseAuthRemoteDataSource implements IAuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  // 실제 Firebase 호출 구현
  // 예: Google 로그인, Apple 로그인, SMS OTP
}
```

**특징**:
- 🔥 Firebase Auth SDK 직접 사용
- 📱 소셜 로그인 통합 (Google, Apple)
- 📲 SMS OTP 전송 및 검증
- 📊 Firestore 사용자 프로필 관리

#### 📄 i_auth_local_datasource.dart (인터페이스)
```dart
abstract class IAuthLocalDataSource {
  // 로컬 캐싱
  Future<void> cacheAuthToken(String token);
  Future<String?> getCachedAuthToken();
  Future<void> clearCache();

  // 사용자 설정
  Future<void> saveUserPreferences(Map<String, dynamic> preferences);
  Future<Map<String, dynamic>?> getUserPreferences();
}
```

#### 📄 auth_local_datasource.dart (구현체)
```dart
class AuthLocalDataSource implements IAuthLocalDataSource {
  // SharedPreferences 또는 Hive 사용
  // 토큰 캐싱, 자동 로그인 정보 저장
}
```

**기능**:
- 💾 JWT 토큰 로컬 저장
- 🔐 자동 로그인 정보 관리
- ⚙️ 사용자 설정 캐싱
- 🗑️ 캐시 무효화

### 3. dto/ - Data Transfer Objects

**목적**: 외부 시스템과 데이터를 주고받을 때 사용하는 객체

#### 📄 auth_user_dto.dart
```dart
class AuthUserDto {
  final String uid;
  final String? email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final bool isEmailVerified;
  final DateTime? createdAt;

  // JSON 직렬화/역직렬화
  Map<String, dynamic> toJson();
  factory AuthUserDto.fromJson(Map<String, dynamic> json);

  // Firebase User 변환
  factory AuthUserDto.fromFirebaseUser(User user);
}
```

#### 📄 user_profile_dto.dart
```dart
class UserProfileDto {
  final String uid;
  final String? userName;
  final String? bio;
  final List<String>? interests;
  final Map<String, dynamic>? settings;

  // Firestore 문서 변환
  Map<String, dynamic> toFirestore();
  factory UserProfileDto.fromFirestore(DocumentSnapshot doc);
}
```

**특징**:
- 🔄 JSON/Firestore 직렬화
- 🛡️ Null safety 완벽 지원
- 📝 타입 안정성 보장
- 🎯 외부 API 스키마 대응

### 4. mappers/ - 데이터 변환

**목적**: DTO와 Domain Model 간의 변환 로직 중앙화

#### 📄 auth_user_mapper.dart
```dart
class AuthUserMapper {
  // DTO → Domain Model
  static AuthUser toDomain(AuthUserDto dto) {
    return AuthUser(
      uid: dto.uid,
      email: dto.email,
      displayName: dto.displayName ?? 'User',
      // 비즈니스 로직 적용
      isActive: dto.isEmailVerified || dto.phoneNumber != null,
    );
  }

  // Domain Model → DTO
  static AuthUserDto toDto(AuthUser domain) {
    return AuthUserDto(
      uid: domain.uid,
      email: domain.email,
      // 필드 매핑
    );
  }

  // Firebase User → Domain Model (직접 변환)
  static AuthUser fromFirebaseUser(User firebaseUser) {
    return AuthUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      // 추가 로직
    );
  }
}
```

**변환 규칙**:
- ✨ 기본값 처리 (null → 기본값)
- 🔧 데이터 정제 및 검증
- 🏗️ 복합 객체 구성
- 🔍 타입 변환 및 캐스팅

### 5. adapters/ - 레거시 호환성

**목적**: 기존 코드와의 하위 호환성 유지 및 점진적 마이그레이션 지원

#### 📄 auth_util.dart (전역 변수 프록시)
```dart
// 레거시 전역 변수를 AuthProvider로 리다이렉트
BaseAuthUser? get currentUser => _authProvider.baseAuthUser;
bool get loggedIn => _authProvider.loggedIn;
String get currentUserEmail => _authProvider.currentUserEmail;
String get currentUserUid => _authProvider.currentUserUid;

// 레거시 스트림 지원
Stream<BaseAuthUser> get authUserStream => _authProvider.authStateChanges;

// Deprecated 마킹
@Deprecated('Use AuthProvider.instance instead')
VersusSpaceFirebaseUser? vsFirebaseUserAuthUserRecord;
```

**마이그레이션 전략**:
1. 🔄 기존 코드 호환성 100% 유지
2. 📢 Deprecated 어노테이션으로 경고
3. 🎯 점진적 리팩토링 가능
4. ✅ 즉시 동작 보장

#### 📄 base_auth_user_provider.dart
```dart
abstract class BaseAuthUser {
  String get uid;
  String? get email;
  String? get displayName;
  String? get photoUrl;
  String? get phoneNumber;
  bool get emailVerified;
  bool get anonymous;
}
```

#### 📄 firebase_user_provider.dart
```dart
class VersusSpaceFirebaseUser extends BaseAuthUser {
  final User user;

  // Firebase User 래핑
  VersusSpaceFirebaseUser(this.user);

  @override
  String get uid => user.uid;

  // Stream 변환
  static Stream<VersusSpaceFirebaseUser> get versusSpaceFirebaseUserStream;
}
```

## 🔄 데이터 플로우

```
[External System] → [DataSource] → [DTO] → [Mapper] → [Domain Model] → [Repository] → [UseCase]
     Firebase          실제 호출      전송 객체    변환       비즈니스 객체      조율         비즈니스 로직
```

### 예시: 이메일 로그인 플로우

1. **UseCase 요청**: `SignInWithEmailUseCase.execute(email, password)`
2. **Repository 호출**: `AuthRepositoryImpl.signInWithEmailAndPassword()`
3. **DataSource 실행**: `FirebaseAuthRemoteDataSource.signInWithEmailAndPassword()`
4. **Firebase 통신**: Firebase Auth SDK 호출
5. **DTO 생성**: `AuthUserDto.fromFirebaseUser(user)`
6. **Mapper 변환**: `AuthUserMapper.toDomain(dto)`
7. **Domain Model 반환**: `AuthUser` 객체
8. **캐싱**: `AuthLocalDataSource.cacheAuthToken()`
9. **결과 전달**: UseCase → Provider → UI

## 🛡️ 에러 처리

### DataSource 레벨
```dart
try {
  final credential = await _firebaseAuth.signInWithEmailAndPassword();
  return credential.user;
} on FirebaseAuthException catch (e) {
  // Firebase 에러를 구체적으로 처리
  switch (e.code) {
    case 'user-not-found':
      throw UserNotFoundException();
    case 'wrong-password':
      throw WrongPasswordException();
    default:
      throw AuthenticationException(e.message);
  }
}
```

### Repository 레벨
```dart
try {
  final user = await _remoteDataSource.signInWithEmailAndPassword();
  final dto = AuthUserDto.fromFirebaseUser(user);
  final domainUser = AuthUserMapper.toDomain(dto);

  // 로컬 캐싱
  await _localDataSource.cacheAuthToken(user.idToken);

  return domainUser;
} catch (e) {
  // 에러를 Domain 에러로 변환
  throw mapToDomainError(e);
}
```

## 🧪 테스트 전략

### Mock 구현
```dart
class MockAuthRemoteDataSource implements IAuthRemoteDataSource {
  // 테스트용 구현
}

class MockAuthLocalDataSource implements IAuthLocalDataSource {
  // 테스트용 구현
}
```

### Repository 테스트
```dart
test('로그인 성공 시 토큰 캐싱', () async {
  when(mockRemoteDataSource.signInWithEmailAndPassword())
    .thenAnswer((_) async => testUser);

  when(mockLocalDataSource.cacheAuthToken(any))
    .thenAnswer((_) async {});

  await repository.signInWithEmailAndPassword(email, password);

  verify(mockLocalDataSource.cacheAuthToken(any)).called(1);
});
```

## 🔐 보안 고려사항

1. **토큰 관리**
   - JWT 토큰 안전한 저장 (암호화)
   - 토큰 만료 자동 처리
   - Refresh token 로직

2. **데이터 검증**
   - DTO 입력 검증
   - SQL Injection 방지
   - XSS 공격 방지

3. **민감 정보**
   - 비밀번호 평문 저장 금지
   - 로그에 민감 정보 제외
   - 메모리 정리

## 🚀 확장 가능성

### 새로운 인증 방식 추가
1. DataSource 인터페이스에 메서드 추가
2. 구현체에 실제 로직 구현
3. Repository에서 조율
4. 기존 코드 영향 없음

### 다른 백엔드로 교체
1. 새로운 DataSource 구현체 생성
2. DI 설정만 변경
3. 비즈니스 로직 수정 불필요

## 📊 성능 최적화

- **캐싱 전략**: 자주 사용되는 데이터 로컬 캐싱
- **배치 처리**: Firestore 배치 작업 활용
- **지연 로딩**: 필요한 시점에 데이터 로드
- **연결 풀링**: Firebase 연결 재사용

## 🔗 관련 문서

- [Domain Layer](../domain/README.md) - 비즈니스 로직
- [Presentation Layer](../presentation/README.md) - UI 레이어
- [Feature Overview](../docs/FEATURE_OVERVIEW.md) - 기능 개요
- [API Reference](../docs/API_REFERENCE.md) - API 명세