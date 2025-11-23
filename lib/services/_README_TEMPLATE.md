# [Service Name] - [Brief Description]

> **위치**: `lib/services/[service_name]/`
> **목적**: [1-2 sentences describing the service purpose]
> **아키텍처**: Infrastructure Layer (Cross-Feature Service)
> **품질 등급**: ⭐⭐⭐⭐⭐ ([Excellent|Good|Needs Improvement])
> **마지막 업데이트**: YYYY-MM-DD

---

## 📋 목차

- [개요](#-개요)
- [빠른 시작](#-빠른-시작)
- [핵심 개념](#-핵심-개념)
- [API 레퍼런스](#-api-레퍼런스)
- [통합 가이드](#-통합-가이드)
- [성능 및 메트릭](#-성능-및-메트릭)
- [DI 등록](#-di-등록)
- [트러블슈팅](#-트러블슈팅)
- [관련 문서](#-관련-문서)

---

## 🎯 개요

### What

[Service Name]은 [what it does in 2-3 sentences]. [Key value proposition and why it exists].

**주요 특징**:
- ✅ **Feature 1**: [Brief description]
- ✅ **Feature 2**: [Brief description]
- ✅ **Feature 3**: [Brief description]
- ✅ **Feature 4**: [Brief description]

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    [Service Name]                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ Component A │  │ Component B │  │ Component C │     │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘     │
│         │                 │                 │            │
│         └─────────────────┴─────────────────┘            │
└──────────────────────┬──────────────────────────────────┘
                       │
           ┌───────────┴───────────┐
           │                       │
     ┌─────▼─────┐           ┌────▼─────┐
     │ Feature A │           │ Feature B │
     └───────────┘           └──────────┘

[ASCII diagram showing architecture]
- Use boxes for components
- Use arrows for data flow
- Keep it simple and readable
```

**아키텍처 패턴**: [Singleton|Factory|Port-Adapter|Strategy|etc.]

**사용 Feature**:
- ✅ **[Feature 1]**: [How it's used]
- ✅ **[Feature 2]**: [How it's used]
- ✅ **[Feature 3]**: [How it's used]

---

## 🚀 빠른 시작

### Scenario 1: [Most Common Use Case]

**상황**: [Describe the scenario]

**코드**:
```dart
import '/services/[service_name]/[file_name].dart';

// Step 1: [Description]
final service = [ServiceName]();

// Step 2: [Description]
final result = await service.method(
  param1: value1,
  param2: value2,
);

// Step 3: [Description]
result.fold(
  (error) => print('Error: $error'),
  (data) => print('Success: $data'),
);
```

**결과**: [Expected output or behavior]

---

### Scenario 2: [Second Common Use Case]

**상황**: [Describe the scenario]

**코드**:
```dart
// Example code for second scenario
class ExampleUsage {
  final [ServiceName] _service;

  ExampleUsage(this._service);

  Future<void> performAction() async {
    // Implementation
  }
}
```

**결과**: [Expected output or behavior]

---

### Scenario 3: [Advanced Use Case] (Optional)

**상황**: [Describe the scenario]

**코드**:
```dart
// Example code for advanced scenario
```

**결과**: [Expected output or behavior]

---

## 💡 핵심 개념

### Component 1: [Name]

**책임**: [What this component is responsible for]

**주요 메서드**:
```dart
class Component1 {
  /// [Method description]
  ///
  /// **Parameters**:
  /// - `param1`: [Description]
  /// - `param2`: [Description]
  ///
  /// **Returns**: [Return type and description]
  ///
  /// **Throws**: [Exception types and when]
  Future<ReturnType> methodName({
    required Type1 param1,
    Type2? param2,
  }) async {
    // Implementation
  }
}
```

**사용 예시**:
```dart
final component = Component1();
final result = await component.methodName(
  param1: value1,
  param2: value2,
);
```

---

### Component 2: [Name]

**책임**: [What this component is responsible for]

**주요 속성**:
```dart
class Component2 {
  // Configuration
  static const int configValue1 = 100;
  static const Duration configValue2 = Duration(minutes: 5);

  // State (if applicable)
  final Map<String, dynamic> _cache = {};
}
```

---

### Design Pattern: [Pattern Name]

**패턴 설명**: [Why this pattern was chosen]

**구현 예시**:
```dart
// Pattern implementation code
class PatternExample {
  // Singleton pattern
  static final PatternExample _instance = PatternExample._internal();
  factory PatternExample() => _instance;
  PatternExample._internal();

  // Or Factory pattern
  factory PatternExample.create({required Config config}) {
    return PatternExample._internal(config);
  }
}
```

**장점**:
- ✅ [Advantage 1]
- ✅ [Advantage 2]
- ✅ [Advantage 3]

**트레이드오프**:
- ⚠️ [Trade-off 1]
- ⚠️ [Trade-off 2]

---

## 📖 API 레퍼런스

### Core Methods

#### `methodName1()`

```dart
Future<Either<ErrorType, ReturnType>> methodName1({
  required String param1,
  int? param2,
  bool param3 = false,
}) async
```

**목적**: [What this method does]

**파라미터**:
| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|---------|------|------|--------|------|
| `param1` | String | ✅ | - | [Description] |
| `param2` | int? | ❌ | null | [Description] |
| `param3` | bool | ❌ | false | [Description] |

**반환값**:
- **성공**: `Right(ReturnType)` - [Description]
- **실패**: `Left(ErrorType)` - [Description]

**에러 타입**:
- `ErrorType.error1`: [When this error occurs]
- `ErrorType.error2`: [When this error occurs]
- `ErrorType.error3`: [When this error occurs]

**사용 예시**:
```dart
final result = await service.methodName1(
  param1: 'value',
  param2: 42,
);

result.fold(
  (error) => switch (error) {
    ErrorType.error1 => handleError1(),
    ErrorType.error2 => handleError2(),
    _ => handleUnknownError(),
  },
  (data) => handleSuccess(data),
);
```

---

#### `methodName2()`

```dart
Stream<DataType> methodName2({
  required String userId,
  int limit = 30,
})
```

**목적**: [What this method does]

**파라미터**:
| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|---------|------|------|--------|------|
| `userId` | String | ✅ | - | [Description] |
| `limit` | int | ❌ | 30 | [Description] |

**반환값**: `Stream<DataType>` - [Description]

**사용 예시**:
```dart
final stream = service.methodName2(userId: 'user123');

await for (final data in stream) {
  processData(data);
}
```

---

### Helper Methods

#### `helperMethod1()`

```dart
static String helperMethod1(String input)
```

**목적**: [What this helper does]

**파라미터**:
- `input`: [Description]

**반환값**: [Description]

**사용 예시**:
```dart
final result = ServiceName.helperMethod1('input');
```

---

## 🔗 통합 가이드

### Feature Integration Pattern

**Feature 1 통합** ([Feature Name]):

```dart
// Step 1: UseCase에서 사용
class SomeUseCase {
  final [ServiceName] _service;

  SomeUseCase({required [ServiceName] service}) : _service = service;

  Future<Either<Failure, Success>> execute() async {
    // Use service
    final result = await _service.methodName1(
      param1: 'value',
    );

    return result.fold(
      (error) => left(Failure.fromServiceError(error)),
      (data) => right(Success(data)),
    );
  }
}
```

**Feature 2 통합** ([Feature Name]):

```dart
// Step 1: Provider에서 사용
@riverpod
FutureOr<DataType> someData(SomeDataRef ref) async {
  final service = getIt<[ServiceName]>();

  final result = await service.methodName1(
    param1: ref.watch(paramProvider),
  );

  return result.fold(
    (error) => throw Exception(error.toString()),
    (data) => data,
  );
}
```

---

### DI Integration

**GetIt 등록**:
```dart
// lib/features/[feature]/di/[feature]_di_module.dart
void setup[Feature]DI(GetIt getIt) {
  // Service 등록
  getIt.registerLazySingleton<[ServiceName]>(
    () => [ServiceName](),
  );
}
```

**Riverpod Provider**:
```dart
// lib/features/[feature]/presentation/providers/[feature]_providers.dart
@riverpod
[ServiceName] [serviceName](ServiceNameRef ref) {
  return getIt<[ServiceName]>();
}
```

---

## ⚡ 성능 및 메트릭

### Performance Metrics

| 메트릭 | 측정값 | 비고 |
|--------|--------|------|
| **Response Time** | [X]ms | [Condition] |
| **Memory Usage** | [X]MB | [Condition] |
| **Throughput** | [X] ops/sec | [Condition] |
| **Cache Hit Rate** | [X]% | [Condition] |

**벤치마크** (Production 데이터, 30일):
```
Scenario 1:
- Requests: 1,000,000
- Average latency: [X]ms
- P95 latency: [X]ms
- P99 latency: [X]ms
- Error rate: [X]%

Scenario 2:
- [Metrics]
```

---

### Best Practices

#### ✅ Do

```dart
// Good: [Explanation]
final service = getIt<[ServiceName]>();
final result = await service.methodName1(
  param1: validatedInput,
);

result.fold(
  (error) => handleError(error),
  (data) => processData(data),
);
```

#### ❌ Don't

```dart
// Bad: [Explanation]
final service = [ServiceName]();  // Direct instantiation
final result = await service.methodName1(
  param1: unvalidatedInput,  // No validation
);
// Missing error handling
```

---

### Optimization Tips

**Tip 1**: [Optimization strategy]
```dart
// Before (Slow)
for (final item in items) {
  await service.processItem(item);
}

// After (Fast)
await Future.wait(
  items.map((item) => service.processItem(item)),
);
```

**Tip 2**: [Optimization strategy]
```dart
// Example code
```

---

## 🔧 DI 등록

### GetIt 등록 (Domain/Data Layer)

**파일**: `lib/features/[feature]/di/[feature]_di_module.dart`

```dart
import 'package:get_it/get_it.dart';
import '/services/[service_name]/[file_name].dart';

void setup[Feature]DI(GetIt getIt) {
  // Singleton 등록 (앱 전체에서 단일 인스턴스)
  getIt.registerLazySingleton<[ServiceName]>(
    () => [ServiceName](),
  );

  // 또는 Factory 등록 (매번 새 인스턴스)
  getIt.registerFactory<[ServiceName]>(
    () => [ServiceName](),
  );

  // 의존성이 있는 경우
  getIt.registerLazySingleton<[ServiceName]>(
    () => [ServiceName](
      dependency1: getIt<Dependency1>(),
      dependency2: getIt<Dependency2>(),
    ),
  );
}
```

---

### Riverpod Provider (Presentation Layer)

**파일**: `lib/features/[feature]/presentation/providers/[feature]_providers.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/services/[service_name]/[file_name].dart';
import '/app/di.dart';

part '[feature]_providers.g.dart';

@riverpod
[ServiceName] [serviceName](ServiceNameRef ref) {
  return getIt<[ServiceName]>();
}

// 또는 FutureProvider
@riverpod
FutureOr<DataType> someData(SomeDataRef ref) async {
  final service = getIt<[ServiceName]>();
  return service.fetchData();
}

// 또는 StreamProvider
@riverpod
Stream<DataType> someStream(SomeStreamRef ref) {
  final service = getIt<[ServiceName]>();
  return service.watchData();
}
```

---

### main.dart 등록

**파일**: `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // DI 등록
  setup[Feature1]DI(getIt);
  setup[Feature2]DI(getIt);
  setup[Feature3]DI(getIt);  // <- [ServiceName]이 여기서 등록됨

  runApp(ProviderScope(child: MyApp()));
}
```

---

## 🐛 트러블슈팅

### Issue 1: [Common Problem Title]

**증상**:
```
[Error message or description]
```

**원인**: [Why this happens]

**해결법**:
```dart
// Solution code
```

또는

```bash
# Terminal command
```

**예방**:
- [Prevention tip 1]
- [Prevention tip 2]

---

### Issue 2: [Common Problem Title]

**증상**:
```
[Error message or description]
```

**원인**: [Why this happens]

**해결법**:

**Option 1** (권장):
```dart
// Recommended solution
```

**Option 2**:
```dart
// Alternative solution
```

**예방**:
- [Prevention tip]

---

### Issue 3: [Performance Issue]

**증상**: [Performance problem description]

**진단**:
```dart
// Diagnostic code
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  final stopwatch = Stopwatch()..start();
  await service.methodName();
  print('Execution time: ${stopwatch.elapsedMilliseconds}ms');
}
```

**해결법**:
```dart
// Optimization code
```

---

### FAQ

**Q1: [Common question]?**

**A**: [Answer with code example if needed]

```dart
// Example code
```

---

**Q2: [Common question]?**

**A**: [Answer]

---

**Q3: [Common question]?**

**A**: [Answer with multiple options]

1. **Option 1**: [Description]
   ```dart
   // Code
   ```

2. **Option 2**: [Description]
   ```dart
   // Code
   ```

---

## 📚 관련 문서

### Feature 문서

- **[Feature 1 README](../../../features/[feature1]/README.md)** - [Brief description]
- **[Feature 2 README](../../../features/[feature2]/README.md)** - [Brief description]
- **[Feature 3 README](../../../features/[feature3]/README.md)** - [Brief description]

### Architecture 문서

- **[CLAUDE.md](../../../../CLAUDE.md)** - 전체 프로젝트 아키텍처 개요
- **[Clean Architecture Guide](../README.md)** - Infrastructure Layer 가이드
- **[DI Pattern](../../../app/di/README.md)** - GetIt + Riverpod DI 패턴

### Related Services

- **[Related Service 1](../[service1]/README.md)** - [How they relate]
- **[Related Service 2](../[service2]/README.md)** - [How they relate]
- **[Related Service 3](../[service3]/README.md)** - [How they relate]

### External Resources

- **[Library/Framework Name](https://external-url.com)** - [Official docs]
- **[Reference Article](https://article-url.com)** - [Relevant article]

---

## 📝 Template Usage Instructions

### How to Use This Template

1. **Copy this template**: Create new README.md in your service directory
2. **Replace placeholders**:
   - `[Service Name]` → Actual service name
   - `[Brief Description]` → 1-2 sentence description
   - `[service_name]` → snake_case directory name
   - `[file_name]` → Actual file name
   - `YYYY-MM-DD` → Current date
3. **Fill sections**: Complete each section with actual implementation details
4. **Remove optional sections**: Delete sections not applicable to your service
5. **Update examples**: Replace example code with real usage scenarios
6. **Add ASCII diagrams**: Create simple architecture diagrams
7. **Link related docs**: Update all documentation links

### Section Guidelines

**Header Block** (Required):
- Purpose: 1-2 clear sentences
- Grade: Based on documentation quality (⭐-⭐⭐⭐⭐⭐)
- Last Updated: Keep current

**Table of Contents** (Required):
- Auto-generate or manually create links
- Keep consistent with actual sections

**Overview** (Required):
- What: 2-3 sentences max
- Architecture: Simple ASCII diagram
- Key Features: 3-5 bullet points

**Quick Start** (Required):
- 2-3 real-world scenarios
- Complete, runnable code examples
- Expected results

**Core Concepts** (Optional):
- For complex services with multiple components
- Include design pattern explanations

**API Reference** (Required):
- All public methods with full signatures
- Parameter tables for clarity
- Error types with descriptions

**Integration Guide** (Required):
- At least 2 feature integration examples
- DI registration patterns

**Performance** (Optional):
- For services with performance implications
- Real metrics from production if available

**DI Registration** (Required):
- GetIt example
- Riverpod example
- main.dart registration

**Troubleshooting** (Required):
- 3-5 common issues
- Clear symptoms and solutions
- FAQ section

**Related Documentation** (Required):
- Links to features using this service
- Related services
- Architecture docs

### Quality Checklist

Before publishing your README:
- [ ] All code examples are tested and runnable
- [ ] ASCII diagrams render correctly
- [ ] All links work (features, services, external)
- [ ] Metrics/benchmarks are accurate
- [ ] No placeholder text remains
- [ ] Grammar and formatting are clean
- [ ] Examples follow project conventions
- [ ] DI registration is complete
- [ ] Troubleshooting covers real issues
- [ ] Grade reflects actual quality

### Grading Criteria

**⭐⭐⭐⭐⭐ Excellent** (3,000+ lines):
- All sections complete
- Real production metrics
- 5+ usage scenarios
- Comprehensive troubleshooting
- Examples: analytics, cache, rate_limit

**⭐⭐⭐⭐ Good** (1,000-3,000 lines):
- Most sections complete
- 3+ usage scenarios
- Good API reference
- Examples: geo_location, error

**⭐⭐⭐ Adequate** (500-1,000 lines):
- Core sections complete
- 2 usage scenarios
- Basic troubleshooting
- Examples: sharding, storage

**⭐⭐ Needs Improvement** (<500 lines):
- Missing sections
- Incomplete examples
- Minimal troubleshooting

**⭐ Incomplete** (No README):
- Create README using this template

---

**마지막 업데이트**: 2025-11-23
**템플릿 버전**: v1.0
**작성자**: Versus Space Architecture Team
**템플릿 크기**: ~850줄 (참조 포함)
