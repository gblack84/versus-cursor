# Firebase Storage

Versus Space 앱의 Firebase Storage 통합 및 파일 업로드 관리를 담당하는 모듈입니다.

## 📋 개요

이 디렉토리는 Firebase Storage 서비스와의 통합을 관리하며, 바이너리 데이터의 업로드와 다운로드 URL 생성을 처리합니다. 앱 전반에서 사용되는 이미지, 비디오 등의 미디어 파일 업로드를 위한 핵심 유틸리티 함수를 제공합니다.

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **함수명**: camelCase
- **변수명**: camelCase
- **상수명**: camelCase
- 참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
lib/backend/firebase_storage/
├── README.md       # 이 문서
└── storage.dart    # Firebase Storage 업로드 유틸리티
```

## 🔧 주요 구성요소

### uploadData() (`storage.dart`)

Firebase Storage에 바이너리 데이터를 업로드하는 핵심 유틸리티 함수입니다.

**함수 시그니처:**
```dart
Future<String?> uploadData(String path, Uint8List data) async
```

**매개변수:**
- `path`: Storage 내 파일 경로 (예: 'user_uploads/images/profile.jpg')
- `data`: 업로드할 바이너리 데이터 (Uint8List 형태)

**반환값:**
- 성공 시: 다운로드 URL (String)
- 실패 시: null

**핵심 기능:**
1. **경로 기반 저장**: 제공된 경로에 파일 저장
2. **MIME 타입 자동 감지**: mime_type 패키지를 활용한 자동 Content-Type 설정
3. **메타데이터 설정**: SettableMetadata를 통한 파일 메타데이터 구성
4. **업로드 상태 확인**: TaskState.success 검증
5. **다운로드 URL 생성**: 업로드 성공 시 공개 접근 가능한 URL 반환

## 🔍 구현 세부사항

### 업로드 프로세스

```
1. FirebaseStorage 인스턴스 참조 획득
    ↓
2. 제공된 경로로 child 참조 생성
    ↓
3. MIME 타입 자동 감지 및 메타데이터 설정
    ↓
4. putData() 메서드로 바이너리 데이터 업로드
    ↓
5. 업로드 상태 확인 (TaskState.success)
    ↓
6. 성공 시 다운로드 URL 생성 및 반환
    ↓
7. 실패 시 null 반환
```

### MIME 타입 감지

**mime_type 패키지 활용:**
- 파일 확장자 기반 Content-Type 자동 설정
- 지원 형식: 이미지(jpg, png, gif), 비디오(mp4, mov), 문서(pdf, doc) 등
- 감지 실패 시 기본값: 'application/octet-stream'

**예시:**
```dart
'image.jpg' → 'image/jpeg'
'video.mp4' → 'video/mp4'
'document.pdf' → 'application/pdf'
```

## 🚀 사용 예시

### 프로필 이미지 업로드
```dart
import 'dart:typed_data';
import 'package:versus_space/backend/firebase_storage/storage.dart';

// 이미지 데이터 준비 (예: ImagePicker에서 획득)
Uint8List imageData = await getImageData();

// Firebase Storage에 업로드
String? downloadUrl = await uploadData(
  'user_uploads/profiles/user123.jpg',
  imageData
);

if (downloadUrl != null) {
  print('업로드 성공: $downloadUrl');
  // Firestore에 URL 저장 등 후속 작업
} else {
  print('업로드 실패');
}
```

### 동영상 업로드
```dart
// 비디오 데이터 준비
Uint8List videoData = await getVideoData();

// 타임스탬프를 포함한 고유 경로 생성
String path = 'user_uploads/videos/${DateTime.now().millisecondsSinceEpoch}.mp4';

// 업로드 실행
String? videoUrl = await uploadData(path, videoData);
```

### 썸네일 이미지 업로드
```dart
// 썸네일 생성 및 업로드
Uint8List thumbnailData = await generateThumbnail();

String? thumbnailUrl = await uploadData(
  'user_uploads/thumbnails/post_${postId}.jpg',
  thumbnailData
);
```

## ⚙️ Storage 경로 구조

### 권장 경로 패턴
```
user_uploads/
├── profiles/           # 프로필 이미지
│   └── {userId}.jpg
├── posts/              # 게시물 미디어
│   ├── images/
│   │   └── {postId}_{index}.jpg
│   └── videos/
│       └── {postId}.mp4
├── thumbnails/         # 썸네일 이미지
│   └── {contentId}.jpg
└── chat/               # 채팅 미디어
    └── {chatId}/
        └── {messageId}.{ext}
```

### 경로 네이밍 규칙
- **디렉토리**: snake_case 사용 (user_uploads, post_images)
- **파일명**: 고유 ID 포함 (userId, postId, timestamp)
- **확장자**: 실제 파일 형식과 일치

## 🔒 보안 고려사항

### Storage Security Rules
Firebase Storage 보안 규칙 설정 필요:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /user_uploads/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
        && request.resource.size < 10 * 1024 * 1024  // 10MB 제한
        && request.resource.contentType.matches('image/.*|video/.*');
    }
  }
}
```

### 업로드 제한
- **파일 크기**: 최대 10MB (보안 규칙에서 설정)
- **파일 형식**: 이미지 및 비디오만 허용
- **인증**: 로그인한 사용자만 업로드 가능

### URL 보안
- 생성된 다운로드 URL은 공개 접근 가능
- 민감한 콘텐츠는 별도 접근 제어 필요
- URL 토큰 기반 보안 적용됨

## ⚡ 성능 최적화

### 업로드 최적화
1. **이미지 압축**: 업로드 전 클라이언트 측 압축
2. **썸네일 생성**: 원본과 별도로 작은 버전 생성
3. **청크 업로드**: 대용량 파일은 청크 단위로 분할
4. **진행률 추적**: UploadTask를 통한 진행률 모니터링

### 다운로드 최적화
1. **캐싱**: CachedNetworkImage 위젯 활용
2. **지연 로딩**: 필요 시점에 다운로드
3. **해상도 최적화**: 디바이스에 맞는 해상도 제공

## 🐛 에러 처리

### 일반적인 에러
- **네트워크 연결 실패**: 오프라인 상태
- **권한 거부**: 인증 토큰 만료 또는 권한 부족
- **용량 초과**: 스토리지 할당량 초과
- **잘못된 경로**: 유효하지 않은 문자 포함

### 에러 처리 예시
```dart
try {
  String? url = await uploadData(path, data);
  if (url == null) {
    // 업로드 실패 처리
    showError('파일 업로드에 실패했습니다.');
  }
} catch (e) {
  if (e is FirebaseException) {
    switch (e.code) {
      case 'permission-denied':
        showError('업로드 권한이 없습니다.');
        break;
      case 'quota-exceeded':
        showError('저장 공간이 부족합니다.');
        break;
      default:
        showError('업로드 중 오류: ${e.message}');
    }
  }
}
```

## 📊 모니터링

### 업로드 메트릭
- 업로드 성공률
- 평균 업로드 시간
- 파일 크기 분포
- 에러 발생률

### Firebase Console 활용
- Storage 사용량 모니터링
- 대역폭 사용량 추적
- 요청 수 분석
- 에러 로그 확인

## 🔗 관련 문서
- [Backend 모듈 전체](../README.md)
- [Firebase 초기화](../firebase/README.md)
- [Firestore 스키마](../schema/README.md)
- [API 요청 관리](../api_requests/README.md)
- [Firebase Storage 공식 문서](https://firebase.google.com/docs/storage)

## 📝 변경 이력
- 2025-08-22: 문서 전면 개정 및 상세 분석 추가
- 2025-08-21: snake_case → camelCase 마이그레이션 완료
- 초기: Firebase Storage 업로드 유틸리티 구현

---

*이 문서는 `/lib/backend/firebase_storage` 디렉토리의 Firebase Storage 통합을 설명합니다.*
