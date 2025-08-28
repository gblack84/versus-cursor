# 📋 Core Models 마이그레이션 계획 (Part 3)

> 작성일: 2025-08-28 | 대상: Core Models 레이어 | 예상 기간: 1주일

## 🎯 마이그레이션 목표

Core Models를 Feature-First Architecture에 맞게 재구조화하여:
- ✅ 계층 간 의존성 정리
- ✅ UI와 비즈니스 로직 분리
- ✅ Feature 독립성 확보
- ✅ 테스트 가능한 구조 구축
- ✅ DI 패턴 도입

## 📊 현재 상태 분석

### 📁 현재 구조
```
lib/core/models/
├── app_model.dart              # 175줄 - 상태 관리
├── form_field_controller.dart  # 24줄 - 폼 컨트롤러
├── upload_data.dart            # 383줄 - 업로드 유틸리티 (문제)
└── uploaded_file.dart          # 69줄 - 파일 모델
```

### 🔍 식별된 문제점
1. **계층 위반** - Core가 Features와 UI 참조
2. **책임 혼재** - upload_data.dart에 UI, 로직, 모델 혼재
3. **의존성 문제** - auth Feature 직접 참조로 순환 의존성 위험
4. **테스트 어려움** - UI와 로직 결합
5. **재사용성 부족** - Feature 특화 로직이 Core에 포함

## 📈 마이그레이션 전략

### 🏗️ 목표 구조
```
lib/
├── core/
│   └── models/
│       └── base/
│           ├── base_model.dart        # 기본 모델 인터페이스
│           └── index.dart
│
├── shared/
│   ├── models/
│   │   ├── uploaded_file.dart         # 업로드 파일 모델
│   │   ├── media_dimensions.dart      # 미디어 크기 모델
│   │   └── index.dart
│   │
│   └── widgets/
│       └── forms/
│           ├── form_field_controller.dart  # 폼 컨트롤러
│           ├── form_validators.dart        # 검증 로직
│           └── index.dart
│
└── features/
    ├── upload/                         # 새로운 Upload Feature
    │   ├── domain/
    │   │   ├── models/
    │   │   │   ├── selected_file.dart
    │   │   │   ├── upload_config.dart
    │   │   │   └── upload_result.dart
    │   │   ├── repositories/
    │   │   │   └── upload_repository.dart
    │   │   └── services/
    │   │       └── upload_service.dart
    │   │
    │   ├── data/
    │   │   ├── repositories/
    │   │   │   └── firebase_upload_repository.dart
    │   │   └── services/
    │   │       └── media_selector_service.dart
    │   │
    │   └── presentation/
    │       ├── providers/
    │       │   └── upload_provider.dart
    │       └── widgets/
    │           ├── media_source_selector.dart
    │           └── upload_progress_indicator.dart
    │
    └── common/
        └── presentation/
            └── providers/
                └── app_state_provider.dart
```

## 🔄 마이그레이션 단계

### Phase 1: 분석 및 준비 (Day 1)

#### 1.1 의존성 분석
```bash
# upload_data.dart 사용처 찾기
grep -r "upload_data" lib/ --include="*.dart" | wc -l
# 예상: 30+ 파일

# app_model.dart 사용처 찾기
grep -r "AppModel\|AppDynamicModels" lib/ --include="*.dart"
```

#### 1.2 테스트 작성
```dart
// test/core/models/upload_data_test.dart
void main() {
  group('SelectedFile', () {
    test('should create with required fields', () {
      // 현재 동작 테스트
    });
  });
}
```

### Phase 2: Upload Feature 모듈 생성 (Day 2)

#### 2.1 Feature 구조 생성
```bash
# Upload Feature 디렉토리 생성
mkdir -p lib/features/upload/{domain,data,presentation}/{models,repositories,services,providers,widgets}

# 기본 파일 생성
touch lib/features/upload/domain/models/selected_file.dart
touch lib/features/upload/domain/models/upload_config.dart
touch lib/features/upload/domain/repositories/upload_repository.dart
touch lib/features/upload/domain/services/upload_service.dart
```

#### 2.2 도메인 모델 정의
```dart
// lib/features/upload/domain/models/selected_file.dart
class SelectedFile {
  final String storagePath;
  final String? filePath;
  final Uint8List bytes;
  final MediaDimensions? dimensions;
  final String? blurHash;
  
  const SelectedFile({
    required this.storagePath,
    this.filePath,
    required this.bytes,
    this.dimensions,
    this.blurHash,
  });
}

// lib/features/upload/domain/models/upload_config.dart
class UploadConfig {
  final List<MediaType> allowedTypes;
  final int maxFileSize;
  final String? storagePath;
  final bool requireDimensions;
  
  const UploadConfig({
    required this.allowedTypes,
    this.maxFileSize = 10485760, // 10MB
    this.storagePath,
    this.requireDimensions = false,
  });
}
```

#### 2.3 Repository 인터페이스
```dart
// lib/features/upload/domain/repositories/upload_repository.dart
abstract class UploadRepository {
  Future<UploadResult> upload(SelectedFile file);
  Stream<UploadProgress> uploadWithProgress(SelectedFile file);
  Future<void> cancelUpload(String uploadId);
  String generateStoragePath({String? prefix});
}
```

### Phase 3: upload_data.dart 분리 (Day 3)

#### 3.1 UI 컴포넌트 추출
```dart
// lib/features/upload/presentation/widgets/media_source_selector.dart
class MediaSourceSelector extends StatelessWidget {
  final Function(MediaSource) onSourceSelected;
  
  Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => _buildSourceOptions(),
    );
  }
}
```

#### 3.2 서비스 로직 분리
```dart
// lib/features/upload/data/services/media_selector_service.dart
class MediaSelectorService {
  Future<List<SelectedFile>?> selectMedia({
    required MediaSource source,
    required UploadConfig config,
  }) async {
    // ImagePicker 로직
  }
}
```

#### 3.3 의존성 주입 구현
```dart
// lib/features/upload/domain/services/upload_service.dart
abstract class UserProvider {
  String get currentUserId;
}

class UploadService {
  final UserProvider userProvider;
  final UploadRepository repository;
  
  UploadService({
    required this.userProvider,
    required this.repository,
  });
  
  String _generatePath() {
    return 'users/${userProvider.currentUserId}/uploads';
  }
}
```

### Phase 4: 모델 재배치 (Day 4)

#### 4.1 Shared Models 이동
```bash
# uploaded_file.dart 이동
git mv lib/core/models/uploaded_file.dart \
       lib/shared/models/uploaded_file.dart

# MediaDimensions 분리 및 이동
cat > lib/shared/models/media_dimensions.dart << 'EOF'
class MediaDimensions {
  final double? height;
  final double? width;
  
  const MediaDimensions({
    this.height,
    this.width,
  });
  
  double get aspectRatio => 
    (width != null && height != null && height! > 0) 
      ? width! / height! 
      : 1.0;
}
EOF
```

#### 4.2 Form Controller 이동
```bash
# 폼 컨트롤러 이동
mkdir -p lib/shared/widgets/forms
git mv lib/core/models/form_field_controller.dart \
       lib/shared/widgets/forms/form_field_controller.dart

# 검증자 추가
cat > lib/shared/widgets/forms/form_validators.dart << 'EOF'
abstract class FormValidator<T> {
  String? validate(T? value);
  Future<String?> validateAsync(T? value);
}

class RequiredValidator extends FormValidator<String> {
  @override
  String? validate(String? value) {
    return (value?.isEmpty ?? true) ? 'This field is required' : null;
  }
}
EOF
```

### Phase 5: 상태 관리 재구조화 (Day 5)

#### 5.1 Base Model 인터페이스
```dart
// lib/core/models/base/base_model.dart
abstract class BaseModel {
  void initialize();
  void dispose();
}

abstract class BaseStateModel<T> extends BaseModel {
  T get state;
  set state(T newState);
  
  void notify();
}
```

#### 5.2 Provider 마이그레이션
```dart
// lib/features/common/presentation/providers/app_state_provider.dart
class AppStateProvider extends ChangeNotifier implements BaseStateModel {
  // AppModel 로직 마이그레이션
  
  @override
  void initialize() {
    // 초기화 로직
  }
  
  @override
  void dispose() {
    // 정리 로직
    super.dispose();
  }
}
```

### Phase 6: Import 경로 업데이트 (Day 6)

#### 6.1 자동 업데이트 스크립트
```bash
#!/bin/bash
# update_imports.sh

# upload_data.dart imports 업데이트
find lib -name "*.dart" -exec sed -i '' \
  's|import .*/core/models/upload_data.dart|import .*/features/upload/domain/models/selected_file.dart|g' {} \;

# form_field_controller imports 업데이트
find lib -name "*.dart" -exec sed -i '' \
  's|import .*/core/models/form_field_controller.dart|import .*/shared/widgets/forms/form_field_controller.dart|g' {} \;

# uploaded_file imports 업데이트  
find lib -name "*.dart" -exec sed -i '' \
  's|import .*/core/models/uploaded_file.dart|import .*/shared/models/uploaded_file.dart|g' {} \;
```

#### 6.2 수동 검증
```bash
# 변경 확인
git diff --name-only | xargs grep -l "import.*models"

# 컴파일 확인
flutter analyze
```

### Phase 7: 테스트 및 검증 (Day 7)

#### 7.1 단위 테스트
```dart
// test/features/upload/domain/models/selected_file_test.dart
void main() {
  group('SelectedFile', () {
    test('should calculate storage path correctly', () {
      final file = SelectedFile(
        storagePath: 'users/123/uploads/test.jpg',
        bytes: Uint8List(0),
      );
      
      expect(file.storagePath, contains('users/123'));
    });
  });
}
```

#### 7.2 통합 테스트
```dart
// test/features/upload/upload_feature_test.dart
void main() {
  testWidgets('Upload flow test', (tester) async {
    // 전체 업로드 플로우 테스트
  });
}
```

## 📊 위험 요소 및 대응 방안

### 위험 1: 대규모 Breaking Changes
- **위험도**: 높음
- **영향**: 30+ 파일
- **대응**:
  - Facade 패턴으로 임시 호환성 레이어 제공
  - 점진적 마이그레이션
  - 충분한 테스트 커버리지

### 위험 2: 순환 의존성
- **위험도**: 중간
- **영향**: auth와 upload 간
- **대응**:
  - DI를 통한 의존성 역전
  - 인터페이스 분리
  - Provider 패턴 활용

### 위험 3: 성능 저하
- **위험도**: 낮음
- **영향**: 파일 업로드
- **대응**:
  - 기존 최적화 로직 유지
  - 프로파일링 수행
  - 캐싱 전략 구현

## 📋 체크리스트

### 🔴 Day 1: 분석 및 준비
- [ ] 의존성 맵핑 완료
- [ ] 테스트 작성
- [ ] 마이그레이션 브랜치 생성

### 🟡 Day 2: Upload Feature 생성
- [ ] Feature 디렉토리 구조 생성
- [ ] 도메인 모델 정의
- [ ] Repository 인터페이스 작성

### 🟡 Day 3: upload_data.dart 분리
- [ ] UI 컴포넌트 추출
- [ ] 서비스 로직 분리
- [ ] DI 패턴 구현

### 🟢 Day 4: 모델 재배치
- [ ] uploaded_file.dart 이동
- [ ] form_field_controller.dart 이동
- [ ] 새로운 모델 파일 생성

### 🟢 Day 5: 상태 관리 재구조화
- [ ] Base Model 인터페이스 정의
- [ ] Provider 마이그레이션
- [ ] AppDynamicModels 리팩토링

### 🔵 Day 6: Import 업데이트
- [ ] 자동 스크립트 실행
- [ ] 수동 검증
- [ ] 컴파일 에러 수정

### 🔵 Day 7: 테스트 및 배포
- [ ] 단위 테스트 실행
- [ ] 통합 테스트 실행
- [ ] PR 생성 및 리뷰

## 🚀 실행 명령

### 빠른 시작
```bash
# Feature 구조 생성
./scripts/create_upload_feature.sh

# Import 업데이트
./scripts/update_imports.sh

# 테스트 실행
flutter test test/features/upload/
```

### 검증
```bash
# 정적 분석
flutter analyze

# 의존성 확인
dart pub deps

# 커버리지 측정
flutter test --coverage
```

## ⚠️ 롤백 계획

만약 문제 발생 시:

```bash
# 1. 임시 호환성 레이어 생성
cat > lib/core/models/upload_data_compat.dart << 'EOF'
// Temporary compatibility layer
export '/features/upload/domain/models/selected_file.dart';
export '/features/upload/presentation/widgets/media_source_selector.dart' 
  show selectMediaWithSourceBottomSheet;
EOF

# 2. 원래 import로 복구
find lib -name "*.dart" -exec sed -i '' \
  's|import .*/features/upload/.*|import .*/core/models/upload_data.dart|g' {} \;

# 3. 점진적 재시도
```

## 📊 예상 효과

### 정량적 효과
- 코드 재사용성 40% 향상
- 테스트 커버리지 60% → 90%
- 빌드 시간 10% 단축 (모듈화로 인한 최적화)

### 정성적 효과
- 명확한 책임 분리
- 쉬운 유지보수
- 새로운 Feature 추가 용이
- 테스트 작성 간소화

## 📝 참고 자료

- [Feature-First Architecture](https://codewithandrea.com/articles/flutter-project-structure/)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture/)
- [Dependency Injection in Flutter](https://pub.dev/packages/get_it)
- [Provider Pattern Best Practices](https://pub.dev/packages/provider)

---

*이 문서는 Core Models의 Feature-First Architecture 마이그레이션 계획입니다.*
*체계적인 분리로 유지보수 가능한 구조를 만듭니다.*