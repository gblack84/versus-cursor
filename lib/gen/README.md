# Generated Assets (FlutterGen)

이 디렉토리는 **FlutterGen**에 의해 자동으로 생성됩니다.
**절대 수동으로 편집하지 마세요!**

## 📁 생성 파일

- `assets.gen.dart` - 이미지, 비디오, 오디오 등 모든 asset 경로
- `fonts.gen.dart` - 폰트 패밀리 상수

## 🔄 코드 재생성

asset 파일을 추가/삭제/이름 변경한 후:

```bash
# 한 번만 실행
dart run build_runner build --delete-conflicting-outputs

# Watch 모드 (개발 중 권장)
dart run build_runner watch --delete-conflicting-outputs
```

## 📖 사용 방법

### 1. Import

```dart
import 'package:versus_space/gen/assets.gen.dart';
import 'package:versus_space/gen/fonts.gen.dart';
```

### 2. 이미지 사용

```dart
// ✅ NEW - FlutterGen (타입 안전)
Assets.images_pikle_icon.image(
  width: 100.0,
  height: 100.0,
  fit: BoxFit.cover,
)

// ❌ OLD - 문자열 (런타임 에러 가능)
Image.asset(
  'assets/images/pikle_icon.png',
  width: 100.0,
  height: 100.0,
)
```

### 3. 이미지 사용 - ImageProvider

DecorationImage 등에서 사용:

```dart
// ✅ NEW
decoration: BoxDecoration(
  image: DecorationImage(
    image: Assets.images_login_header.provider(),
    fit: BoxFit.cover,
  ),
)

// ❌ OLD
decoration: BoxDecoration(
  image: DecorationImage(
    image: Image.asset('assets/images/login_header.png').image,
    fit: BoxFit.cover,
  ),
)
```

### 4. 폰트 사용

```dart
// ✅ NEW
Text(
  'Welcome',
  style: TextStyle(
    fontFamily: FontFamily.sourGummy,
    fontSize: 24.0,
  ),
)

// ❌ OLD
Text(
  'Welcome',
  style: TextStyle(
    fontFamily: 'SourGummy',  // 오타 가능!
    fontSize: 24.0,
  ),
)
```

### 5. 경로만 필요한 경우

```dart
// ✅ NEW
final String iconPath = Assets.images_pikle_icon.path;
print(iconPath);  // 'assets/images/pikle_icon.png'

// ❌ OLD
final String iconPath = 'assets/images/pikle_icon.png';  // 오타 가능!
```

## 📊 현재 Asset 목록

### 이미지 (5개)
- `Assets.images_pikle_icon` - 브랜드 아이콘
- `Assets.images_signup_header` - 회원가입 헤더
- `Assets.images_login_header` - 로그인 헤더
- `Assets.images_versus_logo` - Versus 로고
- `Assets.images_error_image` - 에러 폴백 이미지

### 폰트 (1개)
- `FontFamily.sourGummy` - SourGummy 폰트 패밀리 (18개 파일)

## 🎯 장점

### 1. 타입 안전성
```dart
// ✅ 컴파일 타임에 에러 발견
Assets.images_wrong_name.image()  // ← 컴파일 에러!

// ❌ 런타임에만 에러 발견
Image.asset('assets/images/wrong_name.png')  // ← 앱 실행 시 crash
```

### 2. IDE 자동완성
- `Assets.` 입력 시 모든 asset 목록 표시
- `FontFamily.` 입력 시 모든 폰트 목록 표시

### 3. 리팩토링 안전성
- 파일 이름 변경 시 자동으로 코드 재생성
- 사용하지 않는 asset 쉽게 발견 (Find Usages)

## ⚙️ 설정

pubspec.yaml 설정:

```yaml
dev_dependencies:
  flutter_gen_runner: ^5.7.0

flutter_gen:
  output: lib/gen/
  line_length: 80
  integrations:
    flutter_svg: false
    rive: false
    lottie: false
  assets:
    outputs:
      class_name: Assets
      style: snake-case  # images_pikle_icon
  fonts:
    outputs:
      class_name: FontFamily
```

## 📝 변경 이력

- **2025-11-10**: FlutterGen v5.7.0 도입
  - 14개 파일 마이그레이션 완료
  - 기존 'assets/...' 문자열 패턴 0개
  - Assets/FontFamily 패턴 16개 사용

## 🔗 참고

- [FlutterGen 공식 문서](https://pub.dev/packages/flutter_gen)
- [Build Runner 가이드](https://pub.dev/packages/build_runner)
