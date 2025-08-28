# 📦 Core Models 레이어

> 최종 업데이트: 2025-08-28 | 버전: 1.0.0

## 📋 개요

Core Models는 애플리케이션의 기본 데이터 모델과 상태 관리 패턴을 제공하는 레이어입니다.
현재는 상태 관리, 폼 컨트롤러, 파일 업로드 관련 모델들이 혼재되어 있어 Feature-First Architecture에 따른 재구조화가 필요합니다.

## 🏗️ 현재 디렉토리 구조

```
lib/core/models/
├── app_model.dart              # 175줄 - 상태 관리 기본 모델
├── form_field_controller.dart  # 24줄 - 폼 필드 컨트롤러
├── upload_data.dart            # 383줄 - 파일 업로드 유틸리티
└── uploaded_file.dart          # 69줄 - 업로드된 파일 모델

총 4개 파일, 651줄
```

## 🔍 현재 코드 분석

### 1. app_model.dart (175줄)

#### 핵심 구성요소

**AppModel 추상 클래스**:
```dart
abstract class AppModel<W extends Widget> {
  // Provider 기반 상태 관리 모델
  void initState(BuildContext context);
  void dispose();
  void updatePage(VoidCallback callback);
}
```

**주요 기능**:
- Provider 패턴을 위한 기본 모델 클래스
- 위젯과 모델 간의 생명주기 연결
- 상태 업데이트 콜백 시스템
- 동적 모델 관리 (`AppDynamicModels`)

**AppDynamicModels 클래스**:
- 동적으로 생성되는 모델들의 컬렉션 관리
- 인덱스 기반 접근 및 값 추출
- 메모리 관리 및 자동 정리 기능

### 2. form_field_controller.dart (24줄)

**구성요소**:
```dart
class FormFieldController<T> extends ValueNotifier<T?>
class FormListFieldController<T> extends FormFieldController<List<T>>
```

**기능**:
- ValueNotifier 기반 폼 필드 상태 관리
- 초기값 저장 및 리셋 기능
- 리스트 타입을 위한 특수 컨트롤러 (참조 이슈 방지)

### 3. upload_data.dart (383줄)

**주요 구성요소**:
- `SelectedFile` 클래스 - 선택된 파일 정보
- `MediaDimensions` 클래스 - 미디어 크기 정보
- `selectMediaWithSourceBottomSheet()` - 미디어 선택 UI
- `selectMedia()` - 미디어 선택 로직
- `selectFile()/selectFiles()` - 파일 선택 기능

**문제점**:
- UI 로직 포함 (BottomSheet, SnackBar)
- Firebase 경로 하드코딩
- Feature 의존성 (`/features/auth/data/services/auth_util.dart`)
- Core 레이어에 비즈니스 로직 혼재

### 4. uploaded_file.dart (69줄)

**구성요소**:
```dart
class AppUploadedFile {
  final String? name;
  final Uint8List? bytes;
  final double? height;
  final double? width;
  final String? blurHash;
}
```

**기능**:
- 업로드된 파일 메타데이터 표현
- JSON 직렬화/역직렬화
- Equatable 구현

## ⚠️ 현재 문제점 종합

### 1. 구조적 문제
- **Feature 독립성 위반**: upload_data.dart가 UI와 Feature 의존성 포함
- **잘못된 위치**: 상태 관리 모델이 Core에 위치 (Feature별로 분리 필요)
- **책임 혼재**: 단일 파일에 UI, 로직, 데이터 모델 혼재

### 2. 아키텍처 문제
- **계층 침범**: Core가 상위 계층(Features, UI) 참조
- **순환 의존성 위험**: auth Feature 직접 참조
- **테스트 어려움**: UI와 로직이 결합되어 있음

### 3. 유지보수 문제
- **높은 결합도**: 변경 시 여러 파일 영향
- **재사용성 부족**: Feature 특화 로직이 Core에 포함
- **명확하지 않은 책임**: 각 모델의 역할 경계 모호

## 🎯 Feature-First Architecture 적용 방안

### 1. 올바른 계층 구조

```
lib/
├── core/
│   └── models/              # 순수 데이터 모델만 유지
│       └── base/
│           └── base_model.dart    # 기본 모델 인터페이스
│
├── shared/
│   ├── models/             # 공유 데이터 모델
│   │   └── uploaded_file.dart
│   └── widgets/
│       └── forms/
│           └── form_field_controller.dart
│
└── features/
    ├── common/
    │   └── domain/
    │       └── models/     # 도메인 모델
    │           ├── media_dimensions.dart
    │           └── selected_file.dart
    │
    └── upload/             # 업로드 Feature
        ├── domain/
        │   └── models/
        │       └── upload_config.dart
        └── presentation/
            └── widgets/
                └── media_selector.dart
```

### 2. 모델 분리 전략

```dart
// Core: 순수 인터페이스만
abstract class BaseModel {
  void dispose();
  void initialize();
}

// Shared: 재사용 가능한 위젯 컨트롤러
class FormFieldController<T> extends ValueNotifier<T?> {
  // 현재 로직 유지
}

// Feature: 도메인 특화 모델
class UploadedFile {
  // 업로드 관련 도메인 로직
}
```

### 3. 의존성 역전

```dart
// 이전 (잘못됨)
import '/features/auth/data/services/auth_util.dart';

// 개선 (의존성 주입)
abstract class UserProvider {
  String get currentUserId;
}

class UploadService {
  final UserProvider userProvider;
  
  UploadService(this.userProvider);
}
```

## 📊 리팩토링 우선순위

| 작업 | 우선순위 | 예상 시간 | 난이도 | 영향도 |
|------|----------|----------|--------|--------|
| upload_data.dart 분리 | 🔴 매우 높음 | 1일 | 높음 | 매우 높음 |
| 상태 관리 모델 이동 | 🔴 매우 높음 | 1일 | 중간 | 높음 |
| 폼 컨트롤러 이동 | 🟡 중간 | 0.5일 | 낮음 | 중간 |
| 테스트 작성 | 🟡 중간 | 1일 | 중간 | 높음 |
| 문서화 | 🟢 낮음 | 0.5일 | 낮음 | 중간 |

## 🚀 구현 로드맵

### Phase 1: 긴급 분리 (1일)
- upload_data.dart를 3개 파일로 분리
  - 데이터 모델 → shared/models/
  - UI 컴포넌트 → features/upload/presentation/
  - 유틸리티 → features/upload/domain/services/
- auth 의존성 제거

### Phase 2: 구조 재편성 (1일)
- AppModel → shared/state/base_model.dart
- FormFieldController → shared/widgets/forms/
- UploadedFile → shared/models/

### Phase 3: Feature 모듈 생성 (1일)
- Upload Feature 모듈 생성
- 도메인 모델 정의
- 프레젠테이션 위젯 구현

## 💡 주요 개선 제안

### 1. 상태 관리 개선
```dart
// Provider 대신 Riverpod 고려
abstract class BaseStateNotifier<T> extends StateNotifier<T> {
  // 더 강력한 상태 관리
}
```

### 2. 폼 컨트롤러 고도화
```dart
class FormFieldController<T> {
  // 검증 로직 추가
  final List<String? Function(T?)> validators;
  
  // 에러 상태 관리
  final ValueNotifier<String?> error;
  
  // 비동기 검증
  Future<bool> validateAsync();
}
```

### 3. 업로드 서비스 추상화
```dart
abstract class UploadService {
  Future<UploadResult> upload(SelectedFile file);
  Stream<UploadProgress> uploadWithProgress(SelectedFile file);
  Future<void> cancel(String uploadId);
}
```

## 🔗 연관 파일 및 의존성

### 현재 의존 관계
- **사용처**: 30+ 파일이 upload_data.dart 사용
- **auth Feature**: currentUserUid 의존
- **Firebase Storage**: 파일 업로드 경로
- **UI 위젯**: BottomSheet, SnackBar

### 리팩토링 후 의존 관계
- **Core → 없음** (독립적)
- **Shared → Core** (기본 인터페이스)
- **Features → Shared** (공유 모델)
- **Upload Feature → DI** (의존성 주입)

## ⚡ 성능 고려사항

1. **메모리 관리**: AppDynamicModels의 자동 정리 메커니즘 유지
2. **파일 크기 제한**: 업로드 시 크기 검증 추가
3. **이미지 최적화**: 업로드 전 리사이징 옵션

## 🚨 주의사항

1. **Breaking Changes**: upload_data.dart 분리 시 모든 import 수정 필요
2. **Firebase 경로**: 하드코딩된 경로를 환경 변수로 이동
3. **테스트 커버리지**: 리팩토링 전 테스트 작성 필수

## 📋 체크리스트

### 즉시 수정 필요
- [ ] upload_data.dart UI 로직 분리
- [ ] auth 의존성 제거
- [ ] Firebase 경로 추상화

### 단기 목표 (1주일)
- [ ] Feature 모듈 생성
- [ ] 모델 재배치
- [ ] 테스트 작성

### 장기 목표 (1개월)
- [ ] 상태 관리 패턴 통일
- [ ] DI 컨테이너 도입
- [ ] 문서화 완성

## 사용 예시

### 현재 사용법
```dart
// 파일 선택
final files = await selectMedia(
  storageFolderPath: 'uploads',
  isVideo: false,
);

// 폼 컨트롤러
final controller = FormFieldController<String>('');
```

### 개선된 사용법 (제안)
```dart
// DI를 통한 서비스 주입
final uploadService = ref.read(uploadServiceProvider);
final result = await uploadService.selectAndUpload(
  config: UploadConfig(
    allowedTypes: [MediaType.image],
    maxSize: 10 * 1024 * 1024, // 10MB
  ),
);

// 강화된 폼 컨트롤러
final controller = FormFieldController<String>(
  initialValue: '',
  validators: [
    RequiredValidator(),
    EmailValidator(),
  ],
);
```

---

*이 문서는 Core Models 레이어의 현재 상태와 개선 방안을 담고 있습니다.*
*Feature-First Architecture에 따른 재구조화가 시급합니다.*