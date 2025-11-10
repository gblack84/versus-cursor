# EnvironmentConfig - 환경 변수 관리 시스템

> **위치**: `lib/core/config/environment_config.dart`
> **역할**: 중앙 집중식 환경 변수 로더 (Infrastructure Layer)
> **보안 등급**: 🔴 **Critical** (Firebase 자격증명, API 키 관리)

---

## 📋 목차

- [개요](#-개요)
- [보안 메커니즘](#-보안-메커니즘)
- [사용 방법](#-사용-방법)
- [언제 사용해야 하는가](#-언제-사용해야-하는가)
- [마이그레이션 가이드](#-마이그레이션-가이드)
- [보안 체크리스트](#-보안-체크리스트)
- [트러블슈팅](#-트러블슈팅)
- [FAQ](#-faq)

---

## 🎯 개요

### EnvironmentConfig란?

**EnvironmentConfig**는 Versus Space 프로젝트의 **모든 환경 변수를 중앙에서 관리**하는 Infrastructure Layer 컴포넌트입니다.

### 핵심 역할

```
┌─────────────────────────────────────────┐
│  .env (실제 민감 정보 저장)              │
│  ─────────────────────────────          │
│  FIREBASE_API_KEY=AIzaSy...            │ ← 🔒 Git 제외
│  PERSPECTIVE_API_KEY=AIza...           │
│  ALGOLIA_API_KEY=123e265...            │
└────────────────┬────────────────────────┘
                 │ 읽기
                 ▼
┌─────────────────────────────────────────┐
│  EnvironmentConfig (로더)               │
│  ─────────────────────────────          │
│  static String get firebaseApiKey {     │
│    return dotenv.env['...'] ?? '';     │ ← 📖 읽기만 함
│  }                                      │
└────────────────┬────────────────────────┘
                 │ 제공
                 ▼
┌─────────────────────────────────────────┐
│  사용 파일들                             │
│  ─────────────────────────────          │
│  • main.dart (앱 초기화)                │
│  • firebase_config.dart (Firebase)     │
│  • perspective_api_service.dart (AI)   │
└─────────────────────────────────────────┘
```

### 관리 설정 값 (13개)

| 카테고리 | 설정 값 | 사용 현황 |
|---------|---------|----------|
| **Firebase** (6개) | firebaseApiKey, firebaseProjectId, firebaseAuthDomain, firebaseStorageBucket, firebaseMessagingSenderId, firebaseAppId | ✅ 사용 중 |
| **외부 API** (3개) | perspectiveApiKey, algoliaAppId, algoliaApiKey | ⚠️ Algolia는 하드코딩됨 |
| **기본 에셋** (1개) | defaultCharacterImageUrl | ❌ 미사용 |
| **환경 설정** (3개) | environment, isDebug, isProduction | ✅ 사용 중 |

---

## 🔐 보안 메커니즘

### 3-Layer 보안 구조

#### Layer 1: `.env` 파일 (실제 비밀 정보)

```bash
# .env (프로젝트 루트, .gitignore 등록)

# Firebase Web 설정
FIREBASE_API_KEY=AIzaSyDTX1234567890abcdefghijklmnopqrst
FIREBASE_PROJECT_ID=versus-space-prod
FIREBASE_AUTH_DOMAIN=versus-space-prod.firebaseapp.com
FIREBASE_STORAGE_BUCKET=versus-space-prod.appspot.com
FIREBASE_MESSAGING_SENDER_ID=636984750551
FIREBASE_APP_ID=1:636984750551:web:4cf3216b87a29dc7691b92

# Perspective API (Content Moderation)
PERSPECTIVE_API_KEY=AIzaSyYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY

# Algolia Search
ALGOLIA_APP_ID=0GAS0MPT9Z
ALGOLIA_API_KEY=123e265bbab0702b220a66a59f22ab8e

# 기본 에셋
DEFAULT_CHARACTER_IMAGE_URL=https://storage.googleapis.com/.../default.png

# 환경 설정
ENVIRONMENT=development  # development | staging | production
```

**⚠️ 이 파일은 절대 Git 저장소에 올라가지 않습니다!**

---

#### Layer 2: `.env.example` (템플릿)

```bash
# .env.example (Git 포함)

# Firebase Web 설정
FIREBASE_API_KEY=your_firebase_api_key_here
FIREBASE_PROJECT_ID=your_project_id_here
FIREBASE_AUTH_DOMAIN=your_auth_domain_here
FIREBASE_STORAGE_BUCKET=your_storage_bucket_here
FIREBASE_MESSAGING_SENDER_ID=your_messaging_sender_id_here
FIREBASE_APP_ID=your_app_id_here

# Perspective API
PERSPECTIVE_API_KEY=your_perspective_api_key_here

# Algolia Search
ALGOLIA_APP_ID=your_algolia_app_id_here
ALGOLIA_API_KEY=your_algolia_api_key_here

# 기본 에셋
DEFAULT_CHARACTER_IMAGE_URL=https://example.com/default.png

# 환경 설정
ENVIRONMENT=development
```

**✅ 템플릿만 제공 (실제 값 없음)**

---

#### Layer 3: `environment_config.dart` (로더)

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  // .env 파일 로드
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }

  // Firebase API 키 getter
  static String get firebaseApiKey {
    return dotenv.env['FIREBASE_API_KEY'] ?? '';
  }

  // ... 기타 getter들
}
```

**✅ Git 포함 가능 (실제 값 없음)**

---

### .gitignore 설정

```bash
# .gitignore

# 환경 변수 파일 (실제 비밀 정보 포함)
.env
.env.local
.env.*.local

# 예시 파일은 포함 (템플릿)
!.env.example
```

---

## 🛠 사용 방법

### 1. 앱 초기화 (main.dart)

```dart
import '/core/config/environment_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. .env 파일 로드 (최우선)
  await EnvironmentConfig.init();

  // 2. 필수 설정 값 검증
  if (!EnvironmentConfig.validateConfiguration()) {
    print('❌ Environment configuration is invalid');
    return;
  }

  // 3. 개발 환경에서만 상태 출력
  EnvironmentConfig.printStatus();

  // 4. Firebase 초기화
  await Firebase.initializeApp(...);

  runApp(MyApp());
}
```

---

### 2. Firebase 설정 (firebase_config.dart)

```dart
import '/core/config/environment_config.dart';

Future<void> initializeFirebaseForWeb() async {
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: EnvironmentConfig.firebaseApiKey,
      projectId: EnvironmentConfig.firebaseProjectId,
      authDomain: EnvironmentConfig.firebaseAuthDomain,
      storageBucket: EnvironmentConfig.firebaseStorageBucket,
      messagingSenderId: EnvironmentConfig.firebaseMessagingSenderId,
      appId: EnvironmentConfig.firebaseAppId,
    ),
  );
}
```

---

### 3. 외부 API 서비스 (perspective_api_service.dart)

```dart
import '/core/config/environment_config.dart';

class PerspectiveApiService {
  final String _apiKey;

  PerspectiveApiService({required String apiKey}) : _apiKey = apiKey;

  // Factory 생성자로 EnvironmentConfig 주입
  factory PerspectiveApiService.fromEnvironment() {
    return PerspectiveApiService(
      apiKey: EnvironmentConfig.perspectiveApiKey,
    );
  }
}
```

---

### 4. 새로운 환경 변수 추가하기

#### Step 1: .env 파일에 추가

```bash
# .env

# 새로운 API 키
NEW_API_KEY=your_actual_api_key_here
NEW_API_ENDPOINT=https://api.example.com
```

#### Step 2: .env.example 템플릿에 추가

```bash
# .env.example

# 새로운 API 키
NEW_API_KEY=your_new_api_key_here
NEW_API_ENDPOINT=https://api.example.com
```

#### Step 3: EnvironmentConfig에 getter 추가

```dart
// lib/core/config/environment_config.dart

class EnvironmentConfig {
  // ... 기존 코드

  // 새로운 API 키 getter
  static String get newApiKey => dotenv.env['NEW_API_KEY'] ?? '';
  static String get newApiEndpoint => dotenv.env['NEW_API_ENDPOINT'] ?? '';
}
```

#### Step 4: (선택) Validation 추가

```dart
static bool validateConfiguration() {
  bool isValid = true;
  final requiredVars = [
    'FIREBASE_API_KEY',
    'FIREBASE_PROJECT_ID',
    'FIREBASE_AUTH_DOMAIN',
    'FIREBASE_STORAGE_BUCKET',
    'NEW_API_KEY',  // 추가
  ];

  for (var varName in requiredVars) {
    if (!dotenv.env.containsKey(varName) || dotenv.env[varName]!.isEmpty) {
      print('❌ Required environment variable $varName is missing or empty.');
      isValid = false;
    }
  }

  return isValid;
}
```

#### Step 5: 사용

```dart
import '/core/config/environment_config.dart';

class NewApiService {
  final String apiKey = EnvironmentConfig.newApiKey;
  final String endpoint = EnvironmentConfig.newApiEndpoint;
}
```

---

## 🎯 언제 사용해야 하는가

### ✅ 사용해야 하는 경우

1. **API 키, 자격증명 등 민감 정보**
   ```dart
   // ✅ 좋은 예
   final apiKey = EnvironmentConfig.perspectiveApiKey;
   ```

2. **환경별로 다른 값이 필요한 설정**
   ```dart
   // ✅ 좋은 예
   if (EnvironmentConfig.isProduction) {
     // Production 로직
   } else {
     // Development 로직
   }
   ```

3. **Firebase, AWS 등 클라우드 서비스 자격증명**
   ```dart
   // ✅ 좋은 예
   FirebaseOptions(
     apiKey: EnvironmentConfig.firebaseApiKey,
     projectId: EnvironmentConfig.firebaseProjectId,
   )
   ```

4. **외부 서비스 URL, 엔드포인트**
   ```dart
   // ✅ 좋은 예
   final apiUrl = EnvironmentConfig.apiEndpoint;
   ```

---

### ❌ 사용하지 말아야 하는 경우

1. **앱 UI 문자열**
   ```dart
   // ❌ 나쁜 예
   static String get appTitle => dotenv.env['APP_TITLE'] ?? '';

   // ✅ 좋은 예 (localization 사용)
   Text(AppLocalizations.of(context).getText('app_title'))
   ```

2. **상수 값**
   ```dart
   // ❌ 나쁜 예
   static const int maxRetryCount = 3;

   // ✅ 좋은 예 (코드에 상수로 정의)
   const int kMaxRetryCount = 3;
   ```

3. **Feature 플래그 (간단한 경우)**
   ```dart
   // ❌ 나쁜 예 (간단한 플래그)
   static bool get enableNewFeature => dotenv.env['ENABLE_NEW_FEATURE'] == 'true';

   // ✅ 좋은 예 (코드에 플래그로 정의)
   const bool kEnableNewFeature = true;
   ```

---

## 🔄 마이그레이션 가이드

### 하드코딩된 API 키를 EnvironmentConfig로 전환하기

#### Before (하드코딩 - 🔴 보안 위험)

```dart
// lib/features/search/data/adapters/algolia_manager.dart

// 🔴 보안 위험: API 키가 Git 저장소에 노출됨
const kAlgoliaApplicationId = '0GAS0MPT9Z';
const kAlgoliaApiKey = '123e265bbab0702b220a66a59f22ab8e';

final algolia = Algolia.init(
  applicationId: kAlgoliaApplicationId,
  apiKey: kAlgoliaApiKey,
);
```

**문제점**:
- ❌ API 키가 Git 저장소에 **영구적으로 기록**됨
- ❌ 누구나 코드를 보면 **API 키를 알 수 있음**
- ❌ 키를 변경하려면 **코드를 수정**해야 함
- ❌ 환경별 다른 키 사용 불가

---

#### After (EnvironmentConfig - ✅ 안전)

**Step 1**: .env 파일에 추가

```bash
# .env

ALGOLIA_APP_ID=0GAS0MPT9Z
ALGOLIA_API_KEY=123e265bbab0702b220a66a59f22ab8e
```

**Step 2**: .env.example 템플릿 업데이트

```bash
# .env.example

ALGOLIA_APP_ID=your_algolia_app_id_here
ALGOLIA_API_KEY=your_algolia_api_key_here
```

**Step 3**: EnvironmentConfig에서 이미 정의됨 (확인만)

```dart
// lib/core/config/environment_config.dart

static String get algoliaAppId => dotenv.env['ALGOLIA_APP_ID'] ?? '';
static String get algoliaApiKey => dotenv.env['ALGOLIA_API_KEY'] ?? '';
```

**Step 4**: 코드 수정

```dart
// lib/features/search/data/adapters/algolia_manager.dart

import '/core/config/environment_config.dart';

// ✅ 안전: .env 파일에서 읽어옴
final kAlgoliaApplicationId = EnvironmentConfig.algoliaAppId;
final kAlgoliaApiKey = EnvironmentConfig.algoliaApiKey;

final algolia = Algolia.init(
  applicationId: kAlgoliaApplicationId,
  apiKey: kAlgoliaApiKey,
);
```

**장점**:
- ✅ API 키가 Git 저장소에 **올라가지 않음**
- ✅ 코드는 공개 가능 (실제 값은 .env에만 있음)
- ✅ 키를 변경해도 **코드 수정 불필요** (.env만 수정)
- ✅ 환경별 다른 키 사용 가능 (.env.dev, .env.prod)

---

## ✅ 보안 체크리스트

### 초기 설정

- [ ] `.env` 파일이 `.gitignore`에 등록되어 있는가?
- [ ] `.env.example` 템플릿이 Git 저장소에 포함되어 있는가?
- [ ] `.env` 파일에 실제 API 키가 포함되어 있는가?
- [ ] `main.dart`에서 `EnvironmentConfig.init()` 호출하는가?
- [ ] `validateConfiguration()` 검증을 통과하는가?

### 새 환경 변수 추가 시

- [ ] `.env` 파일에 실제 값 추가했는가?
- [ ] `.env.example`에 템플릿 값 추가했는가?
- [ ] `EnvironmentConfig`에 getter 추가했는가?
- [ ] 필수 항목인 경우 `validateConfiguration()`에 추가했는가?
- [ ] 코드에서 하드코딩 제거하고 EnvironmentConfig 사용하는가?

### 배포 전 확인

- [ ] `.env` 파일이 Git 커밋에 포함되지 않았는가?
- [ ] Production `.env` 파일이 서버에 별도로 준비되어 있는가?
- [ ] 모든 필수 환경 변수가 설정되어 있는가?
- [ ] `validateConfiguration()` 검증을 통과하는가?

---

## 🔧 트러블슈팅

### 문제 1: ".env file not found" 에러

**증상**:
```
Error: Unable to load asset: .env
```

**원인**: `.env` 파일이 프로젝트 루트에 없음

**해결**:
```bash
# 1. .env.example을 복사하여 .env 생성
cp .env.example .env

# 2. .env 파일 편집 (실제 API 키 입력)
nano .env

# 3. pubspec.yaml에 .env 파일 등록 확인
# assets:
#   - .env
```

---

### 문제 2: "Environment variable is missing" 경고

**증상**:
```
❌ Required environment variable FIREBASE_API_KEY is missing or empty.
```

**원인**: `.env` 파일에 필수 환경 변수가 없음

**해결**:
```bash
# .env 파일에 누락된 변수 추가
echo "FIREBASE_API_KEY=your_actual_api_key_here" >> .env
```

---

### 문제 3: API 키가 작동하지 않음

**증상**: API 호출 시 401 Unauthorized 에러

**원인**: `.env` 파일의 API 키가 잘못됨

**해결**:
1. Firebase Console / Google Cloud Console에서 실제 API 키 확인
2. `.env` 파일의 API 키 업데이트
3. 앱 재시작 (Hot Reload 안 됨!)

```bash
# 앱 완전 재시작 필요
flutter run
```

---

### 문제 4: Production 빌드 시 .env 파일 누락

**증상**: Release 빌드 시 환경 변수가 로드되지 않음

**원인**: 빌드 프로세스에 .env 파일이 포함되지 않음

**해결**:
```bash
# 1. pubspec.yaml에 .env 파일 등록 확인
assets:
  - .env

# 2. Flutter clean 후 재빌드
flutter clean
flutter pub get
flutter build apk --release
```

---

### 문제 5: Git에 .env 파일이 커밋됨

**증상**: `.env` 파일이 Git 저장소에 추가됨

**원인**: `.gitignore`에 `.env`가 등록되지 않았거나, 이미 Git 추적 중

**해결**:
```bash
# 1. .gitignore에 .env 추가 (이미 있다면 스킵)
echo ".env" >> .gitignore

# 2. Git 캐시에서 .env 제거
git rm --cached .env

# 3. 커밋
git add .gitignore
git commit -m "chore: Remove .env from Git tracking"

# 4. GitHub에 이미 푸시된 경우 (주의!)
# API 키를 즉시 재발급해야 함!
```

---

## ❓ FAQ

### Q1: .env 파일을 Git에 올려도 되나요?

**A**: **절대 안 됩니다!** `.env` 파일에는 실제 API 키와 자격증명이 포함되어 있어 Git 저장소에 올리면 보안 위험이 발생합니다.

대신 `.env.example` 템플릿만 Git에 포함하세요.

---

### Q2: 팀원들과 어떻게 .env 파일을 공유하나요?

**A**: 다음 방법 중 하나를 사용하세요:

1. **안전한 메신저** (Slack, Discord 등)로 직접 전달
2. **비밀번호 관리 도구** (1Password, LastPass)에 저장
3. **Google Cloud Secret Manager** 사용
4. **Firebase Remote Config** 사용

---

### Q3: Development와 Production 환경을 어떻게 구분하나요?

**A**: 환경별 `.env` 파일을 분리하세요:

```bash
.env.development
.env.staging
.env.production
```

그리고 `EnvironmentConfig.init()`에서 환경에 맞는 파일 로드:

```dart
static Future<void> init() async {
  final fileName = kReleaseMode ? '.env.production' : '.env.development';
  await dotenv.load(fileName: fileName);
}
```

---

### Q4: Algolia 하드코딩은 왜 문제인가요?

**A**: `algolia_manager.dart`의 하드코딩된 API 키는 다음 문제가 있습니다:

```dart
// 🔴 보안 위험
const kAlgoliaApiKey = '123e265bbab0702b220a66a59f22ab8e';
```

1. **Git 저장소에 영구 기록** - 누구나 열람 가능
2. **키 변경 시 코드 수정 필요** - 배포 필요
3. **환경별 다른 키 사용 불가** - Dev/Prod 구분 불가

EnvironmentConfig로 마이그레이션하면 모두 해결됩니다.

---

### Q5: defaultCharacterImageUrl는 왜 미사용인가요?

**A**: `.env.example`에 정의되어 있지만, 코드에서 실제로 사용되지 않습니다.

확인 필요:
1. Profile Feature에서 기본 캐릭터 이미지 로직 확인
2. 사용처가 있다면 구현 완료
3. 사용처가 없다면 설정 값 제거

---

## 📚 관련 문서

- **`.env.example`**: 환경 변수 템플릿
- **`lib/main.dart`**: 앱 초기화 및 EnvironmentConfig.init() 호출
- **`lib/app/config/firebase_config.dart`**: Firebase 초기화
- **`lib/services/moderation/perspective_api_service.dart`**: Perspective API 서비스

---

## 🚀 다음 단계

1. **Algolia 마이그레이션** - `algolia_manager.dart`의 하드코딩 제거
2. **Validation 확장** - Algolia, Perspective API 키 검증 추가
3. **환경별 .env 분리** - Development/Staging/Production 환경 구분
4. **Secret Manager 통합** - Google Cloud Secret Manager 또는 Firebase Remote Config

---

**문서 버전**: v1.0.0
**작성일**: 2025-11-09
**작성자**: Claude Code (Documentation)
**마지막 업데이트**: 2025-11-09
