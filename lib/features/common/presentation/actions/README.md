# Common Presentation Actions

## 📋 개요
앱 전체에서 사용되는 전역 액션(Actions)과 커맨드(Commands)를 관리합니다. 사용자 상호작용, 시스템 이벤트, 비즈니스 로직 실행 등을 처리합니다.

## 🎯 역할
- **전역 액션 관리**: URL 열기, 공유, 복사 등의 공통 액션
- **에러 처리**: 전역 에러 핸들링 및 사용자 피드백
- **이벤트 로깅**: 분석 이벤트 및 사용자 행동 추적
- **알림 액션**: 토스트, 스낵바, 다이얼로그 표시
- **시스템 상호작용**: 클립보드, 파일 시스템, 권한 등

## 📁 파일 구조
```
presentation/
└── actions/
    ├── app_actions.dart
    ├── url_actions.dart
    ├── share_actions.dart
    ├── clipboard_actions.dart
    ├── file_actions.dart
    ├── permission_actions.dart
    ├── error_actions.dart
    ├── analytics_actions.dart
    └── notification_actions.dart
```

## 💻 액션 사양

### 1. AppActions
**역할**: 앱 전역 시스템 제어

**주요 메서드**:
- `exitApp()`: 앱 종료
- `setOrientation(orientations)`: 화면 방향 설정
- `setFullScreen(enable)`: 전체 화면 모드
- `setStatusBarColor(color, brightness)`: 상태바 색상
- `hideKeyboard(context)`: 키보드 숨기기
- `showKeyboard(context, focusNode)`: 키보드 표시
- `hapticFeedback(type)`: 햅틱 피드백
- `setScreenBrightness(brightness)`: 화면 밝기
- `keepScreenOn(enable)`: 화면 켜짐 유지

### 2. UrlActions
**역할**: URL 및 딥링크 처리

**주요 메서드**:
- `openUrl(url)`: URL 열기
- `openInBrowser(url)`: 브라우저에서 열기
- `openInAppBrowser(url)`: 인앱 브라우저
- `sendEmail(to, subject, body, cc, bcc)`: 이메일 전송
- `makePhoneCall(phoneNumber)`: 전화 걸기
- `sendSms(phoneNumber, body)`: SMS 전송
- `sendWhatsApp(phoneNumber, message)`: WhatsApp 메시지
- `openMap(latitude, longitude, address)`: 지도 앱 열기

### 3. ShareActions  
**역할**: 콘텐츠 공유 기능

**주요 메서드**:
- `shareText(text, subject)`: 텍스트 공유
- `shareFiles(paths, text, subject)`: 파일 공유
- `shareImage(imagePath, text, subject)`: 이미지 공유
- `shareLink(url, title, description)`: 링크 공유
- `sharePost(postId, title, description, imageUrl)`: 게시물 공유
- `shareProfile(userId, userName, bio)`: 프로필 공유

### 4. ClipboardActions
**역할**: 클립보드 관리

**주요 메서드**:
- `copyText(text, context, successMessage)`: 텍스트 복사
- `pasteText()`: 텍스트 붙여넣기
- `clearClipboard()`: 클립보드 비우기
- `hasText()`: 텍스트 존재 확인
- `copyLink(url, context)`: 링크 복사
- `copyEmail(email, context)`: 이메일 복사
- `copyPhoneNumber(phoneNumber, context)`: 전화번호 복사

### 5. FileActions
**역할**: 파일 시스템 접근

**주요 메서드**:
- `pickImageFromGallery(quality, maxWidth, maxHeight)`: 갤러리 이미지 선택
- `pickImageFromCamera(quality, maxWidth, maxHeight, camera)`: 카메라 촬영
- `pickMultipleImages(quality, maxWidth, maxHeight)`: 여러 이미지 선택
- `pickVideo(maxDuration, camera, source)`: 비디오 선택
- `pickFile(type, extensions)`: 파일 선택
- `pickMultipleFiles(type, extensions)`: 여러 파일 선택
- `getTempDirectory()`: 임시 디렉토리
- `getDocumentsDirectory()`: 문서 디렉토리
- `saveFile(fileName, bytes, directory)`: 파일 저장
- `deleteFile(path)`: 파일 삭제

### 6. PermissionActions
**역할**: 시스템 권한 관리

**주요 메서드**:
- `requestPermission(permission)`: 권한 요청
- `requestMultiplePermissions(permissions)`: 여러 권한 요청
- `checkPermission(permission)`: 권한 상태 확인
- `isGranted(permission)`: 권한 허용 확인
- `requestCameraPermission(context, rationale)`: 카메라 권한
- `requestGalleryPermission()`: 갤러리 권한
- `requestNotificationPermission()`: 알림 권한
- `requestLocationPermission()`: 위치 권한
- `requestMicrophonePermission()`: 마이크 권한
- `openAppSettings()`: 앱 설정 열기

### 7. ErrorActions
**역할**: 에러 처리 및 피드백

**주요 메서드**:
- `handleError(error, context, message, onRetry, showToast)`: 에러 처리
- `showErrorToast(message)`: 에러 토스트
- `showSuccessToast(message)`: 성공 토스트
- `showInfoToast(message)`: 정보 토스트
- `showWarningToast(message)`: 경고 토스트

### 8. AnalyticsActions
**역할**: 분석 이벤트 추적

**주요 메서드**:
- `logEvent(name, parameters)`: 이벤트 로깅
- `logScreenView(screenName, screenClass)`: 화면 조회
- `logLogin(method, userId)`: 로그인 이벤트
- `logLogout()`: 로그아웃 이벤트
- `logSignUp(method, userId)`: 회원가입 이벤트
- `setUserId(userId)`: 사용자 ID 설정
- `setUserProperty(name, value)`: 사용자 속성
- `logPostView(postId, postType, authorId)`: 게시물 조회
- `logLike(contentId, contentType, isLiked)`: 좋아요
- `logShare(contentType, itemId, method)`: 공유
- `logSearch(searchTerm, numberOfResults)`: 검색
- `logVote(postId, option, voterId)`: 투표

### 9. NotificationActions
**역할**: 사용자 알림 표시

**주요 메서드**:
- `showLoading(message, dismissible)`: 로딩 표시
- `hideLoading()`: 로딩 숨기기
- `showCustomToast(child, duration, align)`: 커스텀 토스트
- `showNotification(title, subtitle, leading, trailing, duration, onTap)`: 알림 토스트
- `showSnackBar(context, message, duration, action, backgroundColor)`: 스낵바
- `showConfirmDialog(context, title, message, confirmText, cancelText)`: 확인 다이얼로그
- `showInputDialog(context, title, message, initialValue, hintText)`: 입력 다이얼로그

## 🧪 테스트 전략

### 단위 테스트
- URI 생성 로직 테스트
- 권한 상태 확인 테스트
- 에러 메시지 추출 테스트
- 분석 이벤트 파라미터 테스트

### 통합 테스트
- 외부 앱 실행 테스트
- 파일 시스템 접근 테스트
- 권한 요청 플로우 테스트
- 공유 기능 테스트

## 📊 의존성 관리

### 필요한 패키지
```yaml
dependencies:
  url_launcher: ^6.0.0
  share_plus: ^7.0.0
  permission_handler: ^11.0.0
  file_picker: ^6.0.0
  image_picker: ^1.0.0
  path_provider: ^2.0.0
  firebase_analytics: ^10.0.0
  bot_toast: ^4.0.0
```

## ⚠️ 마이그레이션 체크리스트

### Phase 1: 핵심 액션
- [ ] AppActions 구현
- [ ] UrlActions 마이그레이션
- [ ] ShareActions 구현
- [ ] ClipboardActions 구현

### Phase 2: 파일 및 권한
- [ ] FileActions 구현
- [ ] PermissionActions 구현

### Phase 3: 피드백 및 분석
- [ ] ErrorActions 구현
- [ ] AnalyticsActions 구현
- [ ] NotificationActions 구현

### Phase 4: 테스트
- [ ] 유닛 테스트 작성
- [ ] 통합 테스트 작성

## 📝 사용 가이드

### URL 액션 사용
```dart
// URL 열기
await UrlActions.openInBrowser('https://example.com');

// 이메일 보내기
await UrlActions.sendEmail(
  to: 'support@versusspace.com',
  subject: '문의사항',
  body: '안녕하세요...',
);
```

### 공유 액션 사용
```dart
// 게시물 공유
await ShareActions.sharePost(
  postId: 'post123',
  title: 'Flutter vs React Native',
  description: '어떤 프레임워크가 더 좋을까요?',
);
```

### 권한 액션 사용
```dart
// 카메라 권한 요청
final granted = await PermissionActions.requestCameraPermission(
  context: context,
  rationale: '사진을 촬영하려면 카메라 권한이 필요합니다.',
);
```

### 에러 액션 사용
```dart
try {
  // 작업 수행
} catch (error) {
  ErrorActions.handleError(
    error,
    context: context,
    message: '게시물을 불러올 수 없습니다',
    onRetry: () => _loadPost(),
  );
}
```

---

*Common Presentation Actions는 앱 전체에서 사용되는 전역 액션을 제공합니다.*
*최종 업데이트: 2025-08-25*