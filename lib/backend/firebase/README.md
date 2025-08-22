# Firebase Configuration

Versus Space 앱의 Firebase 초기화 및 설정을 담당하는 모듈입니다.

## 📋 개요

이 디렉토리는 Firebase 서비스의 초기화를 관리하며, 플랫폼별(웹/모바일) Firebase 설정을 처리합니다. Firebase Core 패키지를 사용하여 앱 시작 시 Firebase 서비스를 초기화하고, 에러 처리를 통해 안정적인 초기화를 보장합니다.

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **클래스명**: PascalCase
- **함수명**: camelCase
- **변수명**: camelCase
- **상수명**: camelCase
- 참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
lib/backend/firebase/
├── README.md                    # 이 문서
└── firebase_config.dart        # Firebase 초기화 설정
```

## 🔧 주요 구성요소

### initFirebase() (`firebase_config.dart`)

Firebase 서비스를 초기화하는 비동기 함수입니다.

**함수 시그니처:**
```dart
Future initFirebase() async
```

**핵심 기능:**
- 플랫폼별 초기화 로직 분기 (Web vs Mobile)
- 웹 플랫폼용 Firebase 설정 옵션 제공
- 모바일 플랫폼은 네이티브 설정 파일 사용
- 포괄적인 에러 처리 및 로깅

### Firebase 프로젝트 설정

**프로젝트 정보:**
- **Project ID**: `versus-space-1lwwiw`
- **Auth Domain**: `versus-space-1lwwiw.firebaseapp.com`
- **Storage Bucket**: `versus-space-1lwwiw.appspot.com`
- **Messaging Sender ID**: `636984750551`
- **Web App ID**: `1:636984750551:web:4cf3216b87a29dc7691b92`

**웹 플랫폼 설정 (FirebaseOptions):**
```dart
FirebaseOptions(
  apiKey: "AIzaSyDQTChIlq8kj9PKn7LZJsmDxmW5HTvh0BY",
  authDomain: "versus-space-1lwwiw.firebaseapp.com",
  projectId: "versus-space-1lwwiw",
  storageBucket: "versus-space-1lwwiw.appspot.com",
  messagingSenderId: "636984750551",
  appId: "1:636984750551:web:4cf3216b87a29dc7691b92"
)
```

## 🔍 초기화 플로우

### 플랫폼별 초기화 과정

```
앱 시작
    ↓
initFirebase() 호출
    ↓
플랫폼 확인 (kIsWeb)
    ↓                 ↓
[웹 플랫폼]      [모바일 플랫폼]
    ↓                 ↓
FirebaseOptions    네이티브 설정 파일
전달               (google-services.json / GoogleService-Info.plist)
    ↓                 ↓
Firebase.initializeApp() 실행
    ↓
초기화 완료 또는 에러 처리
```

### 에러 처리

**에러 캐칭 및 로깅:**
```dart
try {
  // Firebase 초기화
} catch (e) {
  print('Firebase initialization error: $e');
  print('Error type: ${e.runtimeType}');
  if (e is FirebaseException) {
    print('Firebase error code: ${e.code}');
    print('Firebase error message: ${e.message}');
  }
  rethrow; // 에러를 상위로 전파
}
```

**일반적인 에러 시나리오:**
- 네트워크 연결 실패
- 잘못된 API 키 또는 프로젝트 ID
- 중복 초기화 시도
- 플랫폼별 설정 파일 누락

## 🚀 사용 방법

### 앱 초기화 시 호출

일반적으로 `main.dart`에서 앱 시작 시 호출됩니다:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화
  await initFirebase();
  
  // 다른 초기화 작업...
  
  runApp(MyApp());
}
```

### 초기화 확인

Firebase 초기화 상태를 확인하려면:

```dart
// Firebase 앱 인스턴스 확인
final app = Firebase.app();
print('Firebase initialized: ${app.name}');
```

## ⚙️ 플랫폼별 설정

### 웹 플랫폼
- `FirebaseOptions` 직접 전달
- 코드에 설정 정보 포함
- 별도 설정 파일 불필요

### iOS 플랫폼
- `ios/Runner/GoogleService-Info.plist` 파일 필요
- Firebase 콘솔에서 다운로드
- Xcode 프로젝트에 추가

### Android 플랫폼
- `android/app/google-services.json` 파일 필요
- Firebase 콘솔에서 다운로드
- 앱 모듈 디렉토리에 배치

## 🔒 보안 고려사항

### API 키 관리
⚠️ **주의**: 현재 API 키가 하드코딩되어 있습니다.

**권장 보안 조치:**
1. **환경 변수 사용**: 프로덕션 환경에서는 환경 변수로 관리
2. **Firebase Security Rules**: 적절한 보안 규칙 설정
3. **도메인 제한**: Firebase 콘솔에서 승인된 도메인만 허용
4. **API 키 제한**: Google Cloud Console에서 API 키 사용 제한

### 보안 개선 예시
```dart
// 환경 변수 사용 예시
await Firebase.initializeApp(
  options: FirebaseOptions(
    apiKey: const String.fromEnvironment('FIREBASE_API_KEY'),
    authDomain: const String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
    // ... 기타 설정
  )
);
```

## 📊 Firebase 서비스 활용

초기화 후 사용 가능한 Firebase 서비스:

- **Authentication**: 사용자 인증 및 관리
- **Firestore**: NoSQL 클라우드 데이터베이스
- **Storage**: 파일 저장 및 관리
- **Cloud Functions**: 서버리스 백엔드 함수
- **Performance Monitoring**: 앱 성능 모니터링
- **Analytics**: 사용자 행동 분석
- **Crashlytics**: 크래시 리포팅

## 🐛 디버깅

### 초기화 실패 시 체크리스트

1. **인터넷 연결 확인**
2. **Firebase 프로젝트 설정 확인**
   - 프로젝트 ID가 정확한지
   - API 키가 유효한지
3. **플랫폼별 설정 파일 확인**
   - iOS: GoogleService-Info.plist
   - Android: google-services.json
4. **Firebase 콘솔 설정 확인**
   - 앱이 Firebase 프로젝트에 등록되어 있는지
   - 필요한 서비스가 활성화되어 있는지

### 디버그 로그 활성화

```dart
// Firebase 디버그 모드 활성화
FirebaseOptions options = FirebaseOptions(
  // ... 설정
);

if (kDebugMode) {
  print('Firebase 초기화 시작...');
  print('Project ID: ${options.projectId}');
}
```

## 📈 모니터링

### 초기화 성능 측정

```dart
final stopwatch = Stopwatch()..start();
await initFirebase();
stopwatch.stop();
print('Firebase 초기화 시간: ${stopwatch.elapsedMilliseconds}ms');
```

### 초기화 상태 모니터링

Firebase 콘솔에서 다음 항목 확인:
- 활성 사용자 수
- API 호출 횟수
- 에러 발생률
- 서비스 상태

## 🔗 관련 문서
- [Backend 모듈 전체](../README.md)
- [Firebase Auth 구현](../../auth/firebase_auth/README.md)
- [Firestore 스키마](../schema/README.md)
- [Firebase Storage](../firebase_storage/README.md)
- [Firebase 공식 문서](https://firebase.google.com/docs)

## 📝 변경 이력
- 2025-08-22: 문서 전면 개정 및 상세 분석 추가
- 2025-08-21: snake_case → camelCase 마이그레이션 완료
- 초기: Firebase 초기화 구현

---

*이 문서는 `/lib/backend/firebase` 디렉토리의 Firebase 초기화 설정을 설명합니다.*