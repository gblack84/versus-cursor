# 💉 DI (Dependency Injection) - 의존성 주입

> GetIt을 활용한 서비스 로케이터 패턴 구현

## 개요

앱 전체의 의존성을 관리하고 주입하는 중앙 시스템입니다. GetIt 서비스 로케이터를 사용하여 싱글톤, 팩토리, Lazy 싱글톤 패턴을 구현합니다.

## 구조

```
di/
├── di.dart                  # GetIt 초기화
├── modules/                 # 모듈별 설정
│   ├── app_module.dart     # 앱 전역 모듈
│   ├── network_module.dart # 네트워크 모듈
│   ├── storage_module.dart # 스토리지 모듈
│   └── service_module.dart # 서비스 모듈
└── README.md
```

## 주요 기능

### 1. DI 초기화 (di.dart)

**역할**: GetIt 인스턴스 초기화 및 전체 모듈 구성

**주요 기능**:
- GetIt 인스턴스 생성 및 관리
- 환경 설정 등록 (AppConfig)
- 모듈별 의존성 순차적 등록
- Feature 모듈 통합
- 초기화 완료 대기
- 의존성 정리 (reset)

**모듈 등록 순서**:
1. AppModule - 앱 전역 설정
2. NetworkModule - 네트워크 관련
3. StorageModule - 저장소 관련
4. ServiceModule - 비즈니스 서비스
5. Feature Modules - 기능별 모듈

### 2. 앱 모듈 (modules/app_module.dart)

**역할**: 앱 전역 의존성 관리

**등록 컴포넌트**:
- **AppState**: 앱 상태 관리 (LazySingleton)
- **GoRouter**: 네비게이션 라우터 (LazySingleton)
- **ThemeData**: 라이트/다크 테마 (Factory with instanceName)
- **AppLocalizations**: 다국어 지원 (LazySingleton)

### 3. 네트워크 모듈 (modules/network_module.dart)

**역할**: 네트워크 및 외부 서비스 의존성 관리

**등록 컴포넌트**:
- **Dio**: HTTP 클라이언트
  - BaseURL 설정
  - Timeout 설정 (30초)
  - Interceptors: Auth, Log, Retry
- **Firebase Services**:
  - FirebaseAuth: 인증
  - FirebaseFirestore: 데이터베이스
  - FirebaseStorage: 파일 저장소
  - FirebaseMessaging: 푸시 알림
- **Algolia**: 검색 엔진
  - Application ID 설정
  - API Key 설정

### 4. 스토리지 모듈 (modules/storage_module.dart)

**역할**: 로컬 스토리지 및 캐싱 시스템 관리

**등록 컴포넌트**:
- **SharedPreferences**: 간단한 키-값 저장소 (Singleton)
- **Hive Boxes**:
  - cache: 일반 캐시 박스
  - users: UserModel 전용 박스
  - messages: MessagesModel 전용 박스
- **캐시 서비스**:
  - UnifiedCacheService: 통합 캐시 서비스
  - SimpleMemoryCache: 메모리 캐시 (maxSize: 100)

### 5. 서비스 모듈 (modules/service_module.dart)

**역할**: 비즈니스 서비스 의존성 관리

**등록 서비스**:
- **AuthService**: 인증 서비스 (LazySingleton)
- **NotificationService**: 알림 서비스 (LazySingleton)
- **VoteStateCoordinator**: 투표 상태 관리 (LazySingleton)
- **ChatService**: 채팅 서비스 (Factory)
- **SearchService**: 검색 서비스 (LazySingleton)
- **MediaUploadService**: 미디어 업로드 (Factory)

## 사용 방법

### 1. 의존성 주입

**초기화 위치**: main.dart의 main() 함수
- WidgetsFlutterBinding 초기화 후
- configureDependencies() 호출
- 앱 실행 전 완료 필수

### 2. 의존성 사용

**접근 방법**:
- 직접 접근: `getIt<ServiceType>()`
- 인스턴스 이름 지정: `getIt<Type>(instanceName: 'name')`
- Widget에서 사용: 필드로 저장
- Provider에서 사용: 생성자나 필드로 주입

### 3. 테스트에서 Mock 주입

**테스트 설정**:
- setUpAll()에서 Mock 등록
- tearDownAll()에서 reset() 호출
- 실제 서비스 대신 Mock 객체 사용

## 패턴 및 전략

### 1. 등록 타입

- **Singleton**: 앱 생명주기 동안 단일 인스턴스
- **LazySingleton**: 처음 요청 시 생성되는 싱글톤
- **Factory**: 매번 새 인스턴스 생성
- **LazySingletonAsync**: 비동기 초기화가 필요한 싱글톤

### 2. 인스턴스 이름

같은 타입의 다른 인스턴스를 구분하기 위한 명명 전략:
- 테마: 'light', 'dark'
- 환경: 'dev', 'prod'
- 용도: 'cache', 'persistent'

### 3. 의존성 체인

의존성 관계가 있는 서비스들의 등록 순서:
- 의존 대상이 먼저 등록되어야 함
- 순환 의존성 방지 필요
- 체인 깊이 최소화 권장

### 4. 순환 의존성 방지 패턴

#### 문제 상황 예시
```dart
// ❌ 순환 의존성 (Circular Dependency)
class ServiceA {
  final ServiceB serviceB;
  ServiceA(this.serviceB);
}

class ServiceB {
  final ServiceA serviceA;
  ServiceB(this.serviceA);
}
```

#### 해결 방법 1: 인터페이스 추상화
```dart
// ✅ 인터페이스를 통한 의존성 역전
abstract class IServiceA {
  void doSomething();
}

abstract class IServiceB {
  void doOther();
}

class ServiceA implements IServiceA {
  final IServiceB serviceB;
  ServiceA(this.serviceB);
}

class ServiceB implements IServiceB {
  // ServiceA가 필요하면 Factory 패턴 사용
  void useServiceA() {
    final serviceA = getIt<IServiceA>();
    serviceA.doSomething();
  }
}
```

#### 해결 방법 2: Provider 패턴
```dart
// ✅ Provider를 통한 느슨한 결합
class ServiceA {
  void doSomething() {
    // ServiceB가 필요한 시점에만 가져옴
    final serviceB = getIt<ServiceB>();
    serviceB.doOther();
  }
}

class ServiceB {
  void doOther() {
    // ServiceA가 필요한 시점에만 가져옴
    final serviceA = getIt<ServiceA>();
    serviceA.doSomething();
  }
}
```

#### 해결 방법 3: 이벤트 버스 패턴
```dart
// ✅ EventBus를 통한 통신
class ServiceA {
  final EventBus eventBus;
  
  ServiceA(this.eventBus) {
    eventBus.on<ServiceBEvent>().listen((event) {
      // ServiceB의 이벤트 처리
    });
  }
  
  void doSomething() {
    eventBus.fire(ServiceAEvent());
  }
}

class ServiceB {
  final EventBus eventBus;
  
  ServiceB(this.eventBus) {
    eventBus.on<ServiceAEvent>().listen((event) {
      // ServiceA의 이벤트 처리
    });
  }
}
```

#### 해결 방법 4: 중재자 패턴 (Mediator)
```dart
// ✅ 중재자를 통한 간접 통신
class ServiceCoordinator {
  late ServiceA serviceA;
  late ServiceB serviceB;
  
  void initialize() {
    serviceA = ServiceA(this);
    serviceB = ServiceB(this);
  }
  
  void handleServiceARequest() {
    serviceB.doOther();
  }
  
  void handleServiceBRequest() {
    serviceA.doSomething();
  }
}
```

#### 순환 의존성 감지 도구
```dart
// dependency_validator.dart
class DependencyValidator {
  static void checkCircularDependencies() {
    final dependencies = <String, Set<String>>{};
    
    // GetIt에 등록된 모든 서비스 검사
    for (final registration in getIt.allReadyTypes()) {
      final typeName = registration.toString();
      final deps = _extractDependencies(registration);
      dependencies[typeName] = deps;
    }
    
    // DFS로 순환 참조 검사
    for (final entry in dependencies.entries) {
      if (_hasCircularDependency(
        entry.key, 
        dependencies, 
        <String>{},
      )) {
        throw CircularDependencyError(
          'Circular dependency detected: ${entry.key}',
        );
      }
    }
  }
  
  static bool _hasCircularDependency(
    String current,
    Map<String, Set<String>> graph,
    Set<String> visited,
  ) {
    if (visited.contains(current)) {
      return true; // 순환 참조 발견
    }
    
    visited.add(current);
    
    for (final dep in graph[current] ?? <String>{}) {
      if (_hasCircularDependency(dep, graph, visited)) {
        return true;
      }
    }
    
    visited.remove(current);
    return false;
  }
}
```

#### 베스트 프랙티스
1. **단방향 의존성**: 상위 레이어는 하위 레이어만 의존
2. **인터페이스 분리**: 구체 클래스 대신 추상 인터페이스 의존
3. **Factory 패턴**: 직접 주입 대신 필요 시점 생성
4. **도메인 중심 설계**: 비즈니스 로직을 도메인 레이어로 분리
5. **의존성 검증**: CI/CD에서 순환 의존성 자동 검사

## 마이그레이션 체크리스트

- [ ] 기존 싱글톤 패턴을 GetIt으로 변경
- [ ] Provider 생성자에서 GetIt 사용
- [ ] 전역 변수를 DI로 관리
- [ ] 테스트 코드에 Mock 주입 설정
- [ ] 순환 의존성 확인

## 주의사항

1. **순환 의존성**: A → B → A 같은 순환 참조 방지
2. **초기화 순서**: 의존성이 있는 서비스는 의존 대상이 먼저 등록되어야 함
3. **메모리 관리**: Singleton은 앱 종료까지 메모리에 유지됨
4. **테스트 격리**: 테스트 간 DI 컨테이너 초기화 필수

---

*의존성 주입 시스템 문서 - Feature-First Architecture*