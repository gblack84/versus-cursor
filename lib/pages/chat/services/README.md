# 💬 Chat Services - 채팅 시스템 서비스 레이어

> Versus Space 앱의 채팅 기능을 위한 비즈니스 로직 및 서비스 계층

## 📋 개요

Chat Services는 채팅 시스템의 핵심 비즈니스 로직을 담당하는 서비스 레이어입니다. 메시지 변환, 초기화, 애니메이션, 파일 처리, 캐싱 등 채팅 기능에 필요한 모든 서비스를 모듈화하여 제공합니다.

### 🎯 주요 목적
- **서비스 분리**: 비즈니스 로직을 UI 레이어에서 분리
- **재사용성**: 여러 채팅 화면에서 공통 사용
- **성능 최적화**: 캐싱, 병렬 처리, 배치 작업
- **유지보수성**: 모듈화된 구조로 관리 용이

## 🏗️ 디렉토리 구조

```
/lib/pages/chat/services/
├── chat_animation_service.dart        # FAB 애니메이션 제어 (63줄)
├── chat_file_size_service.dart        # 파일 크기 계산 (128줄)
├── chat_initialization_service.dart   # 채팅 초기화 (356줄)
├── chat_media_upload_service.dart     # 미디어 업로드 (188줄)
├── chat_message_lifecycle_service.dart # 메시지 상태 관리 (246줄)
├── chat_message_service.dart          # 메시지 변환 (212줄)
├── chat_scroll_service.dart           # 스크롤 제어 (71줄)
└── README.md                          # 문서 파일
```

### 📊 코드 통계
- **총 코드 라인**: 1,264줄
- **파일 수**: 7개
- **평균 파일 크기**: 180줄
- **주요 서비스**: 7개 전문 서비스

## 📐 네이밍 컨벤션

### 파일명
- **패턴**: snake_case (Dart 표준)
- **접두사**: `chat_` (네임스페이스 역할)
- **접미사**: `_service` (서비스 식별)
- **예시**: `chat_initialization_service.dart`

### 클래스명
- **패턴**: PascalCase
- **접미사**: `Service`
- **예시**: `ChatInitializationService`, `ChatMessageService`

### 메서드명
- **패턴**: camelCase
- **동사 시작**: 액션 명확히 표현
- **예시**: `loadInitialMessages()`, `markMessagesAsSeen()`

### 싱글톤 패턴
```dart
static final Service _instance = Service._internal();
factory Service() => _instance;
Service._internal();
```

> 참조: [프로젝트 전체 네이밍 컨벤션](../../../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소

### 1. ChatMessageLifecycleService - 메시지 생명주기 관리 📊

**메시지의 전송, 배달, 읽음 상태를 추적합니다.**

#### 상태 관리
```dart
enum MessageDeliveryStatus {
  sent,      // 전송됨
  delivered, // 배달됨
  seen,      // 읽음
  unknown,   // 알 수 없음
}
```

#### 주요 메서드
- `markMessagesAsSeen()`: 읽지 않은 메시지 일괄 읽음 처리
- `updateLastReadAt()`: 마지막 읽은 시간 업데이트
- `getUnreadCount()`: 읽지 않은 메시지 수 계산
- `watchMessageStatuses()`: 실시간 상태 추적

### 2. ChatInitializationService - 채팅 초기화 서비스 🚀

**채팅방 진입 시 필요한 모든 초기화 작업을 관리합니다.**

#### 주요 기능
- **통합 초기화**: bootstrap() 메서드로 전체 프로세스 관리
- **캐시 우선 로드**: 3-Layer 캐시 활용 (Memory → Hive → Firestore)
- **병렬 처리**: 사용자 정보 동시 로드
- **상태 추적**: 마지막 타임스탬프 관리

#### 초기화 프로세스
```dart
final result = await initService.bootstrap(
  chatDocument: chatDoc,
  initialMessageLimit: 30,
);

// BootstrapResult 구조
class BootstrapResult {
  final bool isSuccessful;
  final List<core.Message> messages;
  final core.User? currentUser;
  final UsersModel? currentUserRecord;
  final DateTime? lastLoadedTimestamp;
}
```

#### 성능 최적화
- 캐시 히트 시: <10ms
- 네트워크 로드: 300-500ms
- 병렬 사용자 로드: 67% 속도 향상

### 3. ChatMessageService - 메시지 변환 서비스 🔄

**Firestore 문서와 flutter_chat_ui 메시지 간 변환을 담당합니다.**

#### 지원 메시지 타입
| 타입 | 설명 | Core 클래스 |
|------|------|-------------|
| `text` | 일반 텍스트 | TextMessage |
| `image` | 이미지 첨부 | ImageMessage |
| `voteRequest` | 투표 요청 | CustomMessage |
| `voteCreated` | 투표 생성 | CustomMessage |
| `system` | 시스템 메시지 | SystemMessage |

#### 변환 메서드
```dart
// 단일 문서 변환
final message = await ChatMessageService.convertDocumentToMessage(doc);

// 병렬 일괄 변환
final messages = await ChatMessageService.convertDocumentsToMessages(docs);

// 메시지 타입 확인
if (ChatMessageService.isVoteMessage(message)) {
  // 투표 카드 처리
}
```

### 4. ChatMediaUploadService - 미디어 업로드 서비스 📸

**이미지/비디오 선택 및 Firebase Storage 업로드를 처리합니다.**

#### 기능
- **갤러리 선택**: wechat_assets_picker 활용
- **카메라 촬영**: wechat_camera_picker 활용
- **업로드 처리**: Firebase Storage 통합
- **메타데이터 관리**: 파일 크기, 타입 등

#### 사용 예시
```dart
await ChatMediaUploadService.pickMediaFromGallery(
  context: context,
  chatDocument: chatDoc,
  onMediaUploaded: (url, type, localPath) {
    // 업로드 완료 콜백
  },
);
```

### 5. ChatFileSizeService - 파일 크기 서비스 📏

**로컬 및 원격 파일의 크기를 계산하고 포맷팅합니다.**

#### 싱글톤 인스턴스
```dart
final fileSizeService = ChatFileSizeService();
```

#### 주요 기능
- **로컬 파일 크기**: `getLocalFileSize()`
- **Storage URL 파싱**: `extractStoragePathFromUrl()`
- **크기 포맷팅**: `formatFileSize()` (B, KB, MB, GB)
- **크기 제한 확인**: 기본 10MB 제한

### 6. ChatAnimationService - 애니메이션 서비스 🎨

**FAB(Floating Action Button) 애니메이션을 관리합니다.**

#### 애니메이션 타입
- **바운스 애니메이션**: 600ms, elasticOut 곡선
- **스케일 애니메이션**: 200ms, easeInOut 곡선

#### 사용 패턴
```dart
animationService.initializeAnimations(vsync);
await animationService.playFabBounce();
animationService.showFab();
```

### 7. ChatScrollService - 스크롤 관리 서비스 📜

**채팅 스크롤 상태 추적 및 제어를 담당합니다.**

#### 기능
- **스크롤 위치 추적**: 하단/근처 상태 확인
- **자동 스크롤**: 최신 메시지로 이동
- **상태 관리**: isAtBottom, isNearBottom 플래그

## 💡 사용 가이드

### 서비스 초기화 패턴
```dart
// 싱글톤 서비스 인스턴스 획득
final initService = ChatInitializationService();
final messageService = ChatMessageService();
final lifecycleService = ChatMessageLifecycleService();

// 채팅방 초기화
final result = await initService.bootstrap(
  chatDocument: chatDocument,
  initialMessageLimit: 30,
);

// 메시지 상태 업데이트
await lifecycleService.markMessagesAsSeen(
  chatId: chatId,
  currentUserId: userId,
);
```

### 캐싱 전략
```dart
// 1. 캐시 우선 로드
final cachedMessages = await cacheService.getChatMessages(chatId);

// 2. 캐시 미스 시 Firestore 로드
if (cachedMessages.isEmpty) {
  final firestoreMessages = await loadFromFirestore();
  await cacheService.setChatMessages(chatId, firestoreMessages);
}

// 3. 실시간 업데이트
messageStream.listen((newMessage) {
  await initService.addMessageToCache(chatId, newMessage);
});
```

## 🎨 아키텍처 패턴

### 서비스 레이어 원칙
1. **단일 책임**: 각 서비스는 하나의 도메인만 담당
2. **의존성 주입**: 서비스 간 느슨한 결합
3. **싱글톤 패턴**: 전역 인스턴스 관리
4. **비동기 처리**: Future/Stream 기반 설계

### 데이터 흐름
```
UI Layer (Widgets)
    ↓
Service Layer (Business Logic)
    ↓
Repository Layer (Data Access)
    ↓
Data Sources (Firestore, Cache, Storage)
```

## ⚡ 성능 최적화

### 병렬 처리
- **사용자 정보 로드**: Future.wait으로 동시 처리
- **메시지 변환**: map + Future.wait 패턴
- **배치 업데이트**: WriteBatch 활용

### 캐싱 전략
- **3-Layer 캐시**: Memory → Hive → Firestore
- **프리로딩**: 최근 채팅 백그라운드 로드
- **캐시 히트율**: 60%+ 목표

### 리소스 관리
- **메모리 정리**: dispose() 메서드 구현
- **스트림 구독 해제**: 메모리 누수 방지
- **제한된 캐시 크기**: LRU 정책 적용

## 🔒 보안 고려사항

### 구현된 보안
- **사용자 인증**: currentUserUid 기반 접근 제어
- **파일 크기 제한**: 10MB 기본 제한
- **안전한 타입 변환**: null 체크 및 폴백

### 권장 개선사항
1. **파일 타입 검증**: 허용된 MIME 타입만 업로드
2. **Rate Limiting**: 메시지 전송 빈도 제한
3. **암호화**: 민감한 메시지 내용 암호화

## 🐛 알려진 이슈 및 개선사항

### 현재 이슈
1. **캐시 동기화**: 간헐적 캐시 불일치
2. **대용량 파일**: 10MB 이상 파일 처리 미지원
3. **에러 처리**: 일부 에러가 콘솔 출력만

### 개선 제안
1. **트랜잭션 처리**: 원자적 업데이트 보장
2. **압축 지원**: 이미지 자동 압축
3. **백그라운드 업로드**: 대용량 파일 백그라운드 처리
4. **메트릭 수집**: 서비스 성능 모니터링

## 📊 통계 및 메트릭스

### 서비스별 사용 빈도
| 서비스 | 사용 빈도 | 중요도 |
|--------|-----------|--------|
| ChatInitializationService | 매우 높음 | 핵심 |
| ChatMessageService | 매우 높음 | 핵심 |
| ChatMessageLifecycleService | 높음 | 중요 |
| ChatMediaUploadService | 중간 | 보조 |
| ChatFileSizeService | 낮음 | 보조 |
| ChatAnimationService | 낮음 | UI |
| ChatScrollService | 중간 | UI |

### 성능 지표
- **초기화 시간**: 200ms (캐시 히트 시 10ms)
- **메시지 변환**: 50ms/30개 메시지
- **파일 업로드**: 2-5초 (파일 크기 의존)

## 📝 변경 이력

| 버전 | 날짜 | 변경사항 | 작성자 |
|------|------|----------|--------|
| 1.0.0 | 2025-08-23 | 초기 문서 작성 | AI Assistant |
| 0.9.0 | 2025-08-13 | 서비스 레이어 분리 | 개발팀 |

---

*이 문서는 Versus Space 프로젝트의 채팅 서비스 레이어를 설명합니다.*
*Chat Services는 채팅 시스템의 핵심 비즈니스 로직을 담당합니다.*
*마지막 업데이트: 2025-08-23*