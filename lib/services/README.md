# Flutter Services Layer Documentation

이 디렉토리는 Versus Space 앱의 비즈니스 로직과 서비스 레이어를 담당합니다.

## 📋 개요

Versus Space 애플리케이션의 서비스 레이어로, 비즈니스 로직과 외부 서비스 통합을 담당합니다.

## 디렉토리 구조

```
services/
├── ai_moderation/              # AI 기반 콘텐츠 검열 시스템
│   ├── ai_moderation_service.dart
│   ├── text_moderation/
│   ├── image_moderation/
│   ├── models/
│   └── constants/
├── notification_service.dart    # 실시간 알림 처리
├── global_notification_manager.dart # 글로벌 알림 매니저 (새로운 파일)
├── target_audience_service.dart # 타겟 오디언스 관리
├── perspective_api_service.dart # Google Perspective API
├── cloud_image_moderation_service.dart # Cloud Vision API
├── image_moderation_service.dart # 이미지 검열 (레거시)
├── storage_service.dart        # Firebase Storage 관리
├── unified_image_cache_service.dart # 통합 이미지 캐싱 서비스
└── vote_timer_service.dart     # 투표 타이머 동기화 서비스
```

## 주요 서비스

### 1. NotificationService

**실시간 투표 알림 관리 서비스**

#### 주요 기능
- Firebase Firestore 실시간 리스너
- 투표 요청 알림 처리
- 알림 표시/숨기기 관리
- 알림 읽음 처리

#### 사용 방법
```dart
// 싱글톤 인스턴스
final notificationService = NotificationService.instance;

// 알림 리스닝 시작
notificationService.startListening(userId);

// 알림 표시
await NotificationOverlay.showVoting(
  context: context,
  notification: notificationData,
);

// 알림 숨기기
NotificationOverlay.hide();
```

#### 알림 데이터 구조
```dart
{
  'notification_id': String,
  'user_id': String,
  'type': 'voting_request',
  'content': {
    'title': String,
    'message': String,
    'postData': {
      'questionTitle': String,
      'optionA': String,
      'optionB': String,
      'imageUrlA': String?,
      'imageUrlB': String?,
      'imageUrlsA': List<String>?,
      'imageUrlsB': List<String>?,
      'aspectRatioA': double?,     // v1.3.0: 이미지 비율 정보
      'aspectRatioB': double?,     // v1.3.0: 이미지 비율 정보
      'layoutType': String?,       // v1.3.0: 'horizontal', 'vertical', 'single'
      'description': String?,
      'authorName': String
    }
  },
  'created_at': Timestamp,
  'read': bool,
  'expiry_time': Timestamp
}
```

#### 알림 데이터 플로우 (v1.3.0)
1. **알림 생성 시점**: Firebase Functions에서 기본 알림 데이터 생성
2. **클라이언트 수신**: NotificationService가 알림 감지
3. **데이터 보강**: 
   - content가 불완전한 경우 posts 컬렉션에서 직접 조회
   - optionA/optionB Map에서 aspectRatio, mediaUrls 추출
   - layoutType 정보 추가
4. **UI 표시**: NotificationOverlay → VotingNotificationDialog로 전달

### 2. TargetAudienceService

**타겟 오디언스 설정 및 전송 서비스**

#### 주요 기능
- 타겟 오디언스 다이얼로그 표시
- 수집 방식 선택 (quick/public/custom/test)
- 타겟 수 설정
- 세부 조건 설정 (관심사, 연령대, 성별)

#### 사용 방법
```dart
// 타겟 오디언스 다이얼로그 표시
final targetAudience = await TargetAudienceService.showTargetAudienceDialog(
  context: context,
  postId: 'post123',
);

if (targetAudience != null) {
  // 선택된 타겟 정보로 알림 전송
  print('수집 방식: ${targetAudience.collectionType}');
  print('목표 수: ${targetAudience.targetCount}');
}
```

#### 타겟 모델
```dart
class TargetAudienceModel {
  String collectionType;     // quick, public, custom, test
  int targetCount;           // 목표 응답 수
  List<String> interests;    // 관심사 목록
  String? ageGroup;          // 연령대
  String? gender;            // 성별
  bool isPremium;            // 프리미엄 여부
}
```

### 3. GlobalNotificationManager

**글로벌 알림 표시 및 관리 시스템**

#### 주요 기능
- NotificationService와 연동하여 알림 표시
- 알림 큐 관리 및 순차 표시
- 모달 다이얼로그 형태로 알림 표시
- 멀티이미지 알림 지원
- 사용자 반응 추적 (투표, 닫기, 나중에)

#### 사용 방법
```dart
// 싱글톤 인스턴스
final manager = GlobalNotificationManager.instance;

// 알림 리스닝 시작 (앱 시작 시)
manager.startListening();

// 알림 리스닝 중지 (앱 종료 시)
manager.stopListening();
```

#### 알림 표시 플로우
1. NotificationService가 새 알림 감지
2. GlobalNotificationManager가 알림 큐에 추가
3. 순차적으로 모달 다이얼로그 표시
4. 사용자 상호작용 처리 (투표/닫기)
5. 다음 알림 자동 표시

#### 특징
- **큐 관리**: 여러 알림을 순차적으로 표시
- **모달 UI**: 검은색 반투명 배경으로 몰입도 향상
- **92% 화면 너비**: 적절한 여백으로 가독성 개선
- **멀티이미지**: PageView로 여러 이미지 탐색 가능
- **박스 크기 평균화**: 일관된 UI 표현

### 4. AI Moderation Service

**통합 AI 콘텐츠 검열 시스템**

#### 구성 요소
- **텍스트 검열**: Perspective API + Gemini AI
- **이미지 검열**: Google Cloud Vision API
- **통합 검증**: 단계별 검증 프로세스

#### 사용 방법
```dart
final request = ModerationRequest(
  questionTitle: "질문 제목",
  titleA: "옵션 A",
  titleB: "옵션 B",
  userId: currentUser.uid,
  images: [imageFile1, imageFile2],
);

final result = await AIModerationService.moderatePostContent(
  request: request,
  onProgressUpdate: (message) {
    // 진행 상태 업데이트
  },
);

if (!result.isValid) {
  // 검증 실패 처리
  await AIModerationService.showModerationDialog(context, result);
}
```

### 5. Perspective API Service

**Google Perspective API를 통한 텍스트 유해성 검사**

#### 검사 항목
- TOXICITY (유해성)
- PROFANITY (욕설)
- THREAT (위협)
- INSULT (모욕)
- IDENTITY_ATTACK (신원 공격)

#### 사용 방법
```dart
final scores = await PerspectiveApiService.analyzeText(
  "검사할 텍스트",
  apiKey: PERSPECTIVE_API_KEY,
);

if (scores['TOXICITY']! > 0.6) {
  // 유해성 감지
}
```

### 6. Cloud Image Moderation Service

**Google Cloud Vision API를 통한 이미지 검열**

#### 검사 항목
- 성인 콘텐츠 (ADULT)
- 폭력적 콘텐츠 (VIOLENCE)
- 의료 콘텐츠 (MEDICAL)
- 선정적 콘텐츠 (RACY)
- 스푸핑 콘텐츠 (SPOOF)

#### 사용 방법
```dart
final result = await CloudImageModerationService.moderateImages(
  images: [File1, File2],
  onProgressUpdate: (current, total) {
    // 진행률 업데이트
  },
);

if (result.allRejected) {
  // 모든 이미지 거부됨
  showToast(result.rejectionMessage);
}
```

### 7. VoteTimerService (2025-08-17 추가)

**투표 타이머 동기화 서비스**

싱글톤 패턴으로 구현된 투표 타이머 관리 서비스입니다. 모든 투표 카드가 동일한 남은 시간을 표시하도록 postId별로 단일 Timer를 관리합니다.

#### 주요 기능
- postId별 단일 Timer 인스턴스 관리
- Firebase 서버 시간 동기화
- StreamController를 통한 브로드캐스트
- 자동 메모리 정리 메커니즘
- 네트워크 지연 보정

#### 서버 시간 동기화
```dart
// 서버 시간 동기화 (5분 캐싱)
await VoteTimerService.instance.syncServerTime();

// 동기화된 현재 시간 가져오기
final syncedNow = VoteTimerService.instance.synchronizedNow;
```

#### 사용 방법
```dart
// 싱글톤 인스턴스
final timerService = VoteTimerService.instance;

// 남은 시간 스트림 구독
final stream = timerService.getRemainingTimeStream(
  postId, 
  voteEndTime,
);

// StreamBuilder에서 사용
StreamBuilder<Duration>(
  stream: stream,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final remaining = snapshot.data!;
      return Text('${remaining.inMinutes}분 ${remaining.inSeconds % 60}초');
    }
    return Text('로딩중...');
  },
);

// 타이머 중지
timerService.stopTimer(postId);
```

#### 성능 최적화
- Timer 인스턴스: N개 → 1개로 감소
- 메모리 사용량: O(n) → O(1)
- 모든 기기에서 동일한 시간 표시
- 위젯 재생성 시에도 시간 일관성 유지

### 8. Storage Service

**Firebase Storage 파일 관리 서비스**

#### 주요 기능
- 이미지 업로드 (원본, 디스플레이, 썸네일)
- 파일 삭제
- URL 생성
- 메타데이터 관리

#### 사용 방법
```dart
// 이미지 업로드
final urls = await StorageService.uploadImage(
  file: imageFile,
  path: 'posts/images',
  generateThumbnail: true,
);

print('원본: ${urls['original']}');
print('디스플레이: ${urls['display']}');
print('썸네일: ${urls['thumbnail']}');

// 파일 삭제
await StorageService.deleteFile(fileUrl);
```

## 서비스 간 통합

### 게시물 작성 플로우

```dart
// 1. 콘텐츠 검열
final moderationResult = await AIModerationService.moderatePostContent(
  request: moderationRequest,
);

if (!moderationResult.isValid) {
  return; // 검증 실패
}

// 2. 이미지 업로드
final imageUrls = await StorageService.uploadImage(
  file: selectedImage,
  path: 'posts/images',
);

// 3. 게시물 생성
final postRef = await FirebaseFirestore.instance
  .collection('posts')
  .add(postData);

// 4. 타겟 오디언스 설정
final targetAudience = await TargetAudienceService.showTargetAudienceDialog(
  context: context,
  postId: postRef.id,
);

// 5. 알림 전송 (Firebase Functions에서 자동 처리)
```

### 알림 수신 플로우

```dart
// 1. 앱 시작 시 NotificationService 초기화
void initState() {
  if (currentUser != null) {
    NotificationService.instance.startListening(currentUser.uid);
  }
}

// 2. 알림 수신 시 자동 표시
// NotificationService 내부에서 처리

// 3. 사용자 상호작용
// - 투표하기: 해당 게시물로 이동
// - 나중에: 알림 숨기기
// - 닫기(X): 알림 읽음 처리
```

### 5. UnifiedImageCacheService

**통합 이미지 캐싱 서비스**

#### 주요 기능
- 동적 memCacheWidth 계산 (400-1600px)
- 컨텍스트별 최적화
- 전역 인스턴스 관리
- 이미지 프리로딩 지원

#### 사용 방법
```dart
// 싱글톤 인스턴스
final cacheService = UnifiedImageCacheService.instance;

// 동적 캐시 너비 계산
final cacheWidth = UnifiedImageCacheService.calculateMemCacheWidth(displaySize);

// 박스용 캐시 계산
final boxCacheWidth = UnifiedImageCacheService.calculateForBox(
  context,
  boxWidth: 200,
  isHorizontal: true,
);

// 이미지 프리로딩
await cacheService.preloadImages(
  context,
  imageUrls,
  overrideMemCacheWidth: 800,
);

// 인접 이미지 프리로드
await cacheService.preloadAdjacentImages(
  context,
  allImageUrls,
  currentIndex,
);
```

#### 캐시 전략
- **최소 너비**: 400px (모바일 최적화)
- **최대 너비**: 1600px (고해상도 지원)
- **스케일 팩터**: 2.0x (레티나 디스플레이)
- **컨텍스트 인식**: 메시지 카드, 알림, 질문 작성별 최적화

## 설정 및 환경 변수

### 필수 API 키

```dart
// 환경 변수 또는 설정 파일
const PERSPECTIVE_API_KEY = 'your_perspective_api_key';
const GEMINI_API_KEY = 'your_gemini_api_key';
const CLOUD_VISION_API_KEY = 'your_vision_api_key';
```

### Firebase 설정

```dart
// Firebase 프로젝트 설정
// firebase_options.dart에서 자동 관리
```

## 에러 처리

### 공통 에러 처리 패턴

```dart
try {
  // 서비스 호출
  final result = await someService.doSomething();
} catch (e) {
  // 에러 로깅
  debugPrint('[ServiceName] Error: $e');
  
  // 사용자 피드백
  showToast('작업 중 오류가 발생했습니다');
  
  // 기본값 반환 또는 재시도
  return defaultValue;
}
```

### 서비스별 에러 처리

1. **API 호출 실패**: 재시도 또는 기본값 반환
2. **네트워크 오류**: 오프라인 모드 또는 캐싱
3. **권한 오류**: 재인증 요청
4. **데이터 검증 실패**: 상세 피드백 제공

## 테스트

### 단위 테스트

```dart
// test/services/notification_service_test.dart
test('알림 서비스 초기화', () {
  final service = NotificationService.instance;
  expect(service, isNotNull);
});
```

### 통합 테스트

```dart
// 전체 플로우 테스트
testWidgets('게시물 작성 플로우', (tester) async {
  // 1. 콘텐츠 입력
  // 2. 검열 통과
  // 3. 업로드 성공
  // 4. 알림 전송
});
```

## 성능 최적화

1. **싱글톤 패턴**: 서비스 인스턴스 재사용
2. **캐싱**: API 응답 캐싱
3. **배치 처리**: 여러 요청 묶어서 처리
4. **지연 로딩**: 필요한 시점에 초기화

## 보안 고려사항

1. **API 키 보호**: 환경 변수 사용
2. **입력 검증**: 모든 사용자 입력 검증
3. **권한 확인**: 작업 전 권한 검증
4. **데이터 암호화**: 민감한 데이터 암호화

## 최근 변경사항

### 2025-08-04: 스마트 레이아웃 시스템 통합
**작업 내용**: 
- NotificationService에 aspectRatio와 layoutType 데이터 전달 로직 추가
- posts 컬렉션에서 optionA/optionB Map 구조로 데이터 추출
- NotificationOverlay에 aspectRatio 파라미터 추가
- VotingNotificationDialog에서 VersusBoxSizeData 자동 생성

**해결된 문제**:
- 질문 작성 시 세로 배치였던 콘텐츠가 알림에서 가로로 표시되는 문제
- aspectRatio null로 인한 기본 레이아웃 적용 문제
- 스마트 레이아웃 시스템이 알림에서 작동하지 않던 문제

### 2025-08-03: AI 채팅 메시지 통합
**문제**: Android와 Web에서 AI 채팅 메시지가 표시되지 않음 (iOS는 정상)

**원인**: 
- Firebase Functions의 채팅방 ID 생성 로직 문제
- JavaScript `.sort()` 함수가 대소문자에 따라 다른 순서로 정렬
- 결과적으로 일부 사용자는 잘못된 채팅방 ID를 가짐

**해결**:
1. Firebase Functions `aiChatService.js` 수정
   - 채팅방 ID를 `ai_assistant_userId` 형식으로 고정
2. 기존 채팅방 마이그레이션 함수 추가
3. Flutter 쿼리는 이미 올바르게 작성되어 있음:
   ```dart
   .where('participantIds', arrayContains: currentUserId)
   ```

### 투표 권한 문제 해결
**문제**: 투표 시 permission-denied 오류 발생

**원인**: votedUserIDsA/B 필드가 없는 새 게시물에서 보안 규칙 실패

**해결**: Firebase Security Rules 수정으로 필드 존재 여부 확인 추가

### 알림 시스템 개선
- GlobalNotificationManager 추가로 알림 큐 관리
- 모달 다이얼로그 UI로 전환 (92% 화면 너비)
- 멀티이미지 지원 추가
- 박스 크기 평균화로 일관된 UI

## 향후 계획

1. **서비스 확장**
   - 비디오 검열 서비스
   - 실시간 채팅 서비스
   - 분석 및 통계 서비스

2. **성능 개선**
   - GraphQL 통합
   - 캐싱 레이어 강화
   - 오프라인 지원

3. **기능 추가**
   - 다국어 검열
   - 커스텀 필터
   - 머신러닝 모델 통합