# Chat Components - 채팅 시스템 투표 메시지 컴포넌트

Versus Space 앱의 채팅 시스템에서 사용되는 투표 메시지 관련 UI 컴포넌트 모음입니다.

## 📋 개요

이 디렉토리는 채팅 내에서 A vs B 투표 카드 메시지를 표시하고 관리하는 핵심 컴포넌트들을 포함합니다. `flutter_chat_ui` 기반 채팅 시스템과 통합되어 실시간 투표 기능을 제공하며, Firebase와 연동하여 투표 상태를 동기화합니다.

### 주요 특징
- **실시간 투표 시스템**: Firebase와 연동된 실시간 투표 상태 동기화
- **통합 상태 관리**: VoteStateCoordinator를 통한 중앙 집중식 상태 관리
- **스마트 레이아웃**: AspectRatioAnalyzer 기반 동적 레이아웃 결정
- **멀티이미지 지원**: 옵션당 여러 이미지 표시 (PageView)
- **성능 최적화**: 전역 BoxSizes 캐시로 스크롤 성능 향상
- **디자인 시스템 통합**: VersusColors, VersusSpacing, VersusTextStyles 일관된 사용

## 🎯 네이밍 컨벤션

### 파일명
- **Dart 파일**: snake_case (`base_vote_message.dart`, `vote_card_message.dart`)
- **디렉토리**: snake_case (`vote_card/`)
- **README**: 대문자 확장자 (`README.md`)

### 코드 내 명명 규칙
- **클래스명**: PascalCase (`BaseVoteMessage`, `VoteCardMessage`)
- **변수/메서드**: camelCase (`postId`, `cardStatus`, `submitVote()`)
- **상수**: camelCase 또는 SCREAMING_SNAKE_CASE
- **Mixin**: PascalCase with Mixin suffix (`BaseVoteMessageStateMixin`)

참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 🔧 주요 구성요소

### 1. BaseVoteMessage (추상 클래스)
**파일**: `base_vote_message.dart`  
**용도**: 모든 투표 메시지 컴포넌트의 기반 클래스

#### 주요 속성
| 속성 | 타입 | 설명 |
|------|------|------|
| `postId` | String | 투표 게시물 ID |
| `title` | String | 투표 제목/질문 |
| `description` | String? | 투표 설명 |
| `optionAText` | String | A 옵션 텍스트 |
| `optionBText` | String | B 옵션 텍스트 |
| `optionAImage` | String? | A 옵션 단일 이미지 |
| `optionBImage` | String? | B 옵션 단일 이미지 |
| `optionAImages` | List<String>? | A 옵션 멀티이미지 |
| `optionBImages` | List<String>? | B 옵션 멀티이미지 |
| `aspectRatioA` | double? | A 옵션 이미지 비율 |
| `aspectRatioB` | double? | B 옵션 이미지 비율 |
| `cardStatus` | String | 투표 상태 |
| `voteEndTime` | DateTime? | 투표 종료 시간 |
| `userVotes` | Map<String, dynamic>? | 사용자별 투표 기록 |
| `isMe` | bool | 내가 만든 투표인지 여부 |

#### 주요 getter 메서드
```dart
// 현재 사용자가 투표했는지 확인
bool get hasCurrentUserVoted

// 현재 사용자의 투표 선택
String? get currentUserChoice

// 현재 사용자의 투표 시간
DateTime? get currentUserVoteTime

// 효과적인 이미지 URL 리스트
List<String> get effectiveImageUrlsA
List<String> get effectiveImageUrlsB
```

### 2. BaseVoteMessageStateMixin
**파일**: `base_vote_message.dart`  
**용도**: 투표 메시지 상태 관리를 위한 공통 mixin

#### 주요 기능
- **투표 제출**: `submitVote(String option)` - VoteStatusService와 연동
- **시간 포맷팅**: `formatTime(DateTime time)` - 상대적 시간 표시
- **타임스탬프 표시**: `buildTimestamp()` - 메시지 시간 위젯

#### 사용 예시
```dart
class _VoteCardMessageState extends State<VoteCardMessage> 
    with BaseVoteMessageStateMixin<VoteCardMessage> {
  // BaseVoteMessageStateMixin의 기능 자동 상속
  // submitVote(), formatTime(), buildTimestamp() 사용 가능
}
```

### 3. VoteCardMessage
**파일**: `vote_card_message.dart`  
**용도**: AI 채팅에서 사용되는 메인 투표 카드 메시지 위젯

#### 상태 관리
- **4가지 투표 상태 지원**:
  - `votingRequest`: 투표 요청 (투표 가능)
  - `inProgress`: 투표 진행중
  - `completed`: 투표 완료
  - `notParticipated`: 미참여

#### 주요 기능
```dart
// VoteStateCoordinator 통합
Stream<VoteStateData> _voteStateStream = 
  VoteStateCoordinator.instance.getVoteStateStream(
    postId: widget.postId,
    voteEndTime: widget.voteEndTime,
    initialStatus: widget.cardStatus,
    userVotes: widget.userVotes,
  );

// 전역 BoxSizes 캐시 (스크롤 성능 최적화)
static final Map<String, BoxSizes> _globalBoxSizesCache = {};

// 레이아웃 타입 결정
LayoutType _calculateLayoutType() {
  return AspectRatioAnalyzer.determineLayoutType(
    aspectRatioA: widget.aspectRatioA,
    aspectRatioB: widget.aspectRatioB,
    hasImagesA: widget.effectiveImageUrlsA.isNotEmpty,
    hasImagesB: widget.effectiveImageUrlsB.isNotEmpty,
  );
}
```

#### UI 구성
- **헤더**: 프로필, 발신자 정보, 상태 배지
- **투표 질문**: 제목과 설명 표시
- **옵션 박스**: A/B 옵션 이미지와 텍스트
- **타이머**: 실시간 남은 시간 표시 (진행중일 때)
- **액션 버튼**: 투표하기/결과 보기
- **투표 결과**: 완료 시 결과 표시

### 4. vote_card/ 하위 디렉토리
**경로**: `/lib/components/chat/vote_card/`  
**용도**: 투표 카드를 구성하는 개별 UI 컴포넌트

#### 포함된 컴포넌트
- **VoteActionButton**: 투표 참여/결과 보기 버튼
- **VoteCardHeader**: 투표 카드 헤더 (프로필, 상태)
- **VoteOptionBox**: A/B 옵션 박스 표시
- **VoteResultDisplay**: 투표 완료 메시지

상세 문서: [vote_card/README.md](./vote_card/README.md)

## 💡 사용 예시

### 기본 사용법
```dart
import 'package:versus_space/components/chat/vote_card_message.dart';

// 투표 카드 메시지 생성
VoteCardMessage(
  key: ValueKey(messageId),  // Widget 재사용 방지
  postId: 'post123',
  title: '커피 vs 차',
  description: '아침에 뭘 마실까요?',
  optionAText: '커피',
  optionBText: '차',
  optionAImage: 'https://coffee.jpg',
  optionBImage: 'https://tea.jpg',
  aspectRatioA: 1.5,
  aspectRatioB: 1.5,
  cardStatus: 'votingRequest',
  voteEndTime: DateTime.now().add(Duration(minutes: 10)),
  isMe: false,
  messageType: 'voteCard',
  currentUserName: '홍길동',
)
```

### 멀티이미지 지원
```dart
VoteCardMessage(
  // ... 기본 속성
  optionAImages: [
    'https://image1.jpg',
    'https://image2.jpg',
    'https://image3.jpg',
  ],
  optionBImages: [
    'https://image4.jpg',
    'https://image5.jpg',
  ],
  // 멀티이미지 사용 시 단일 이미지 URL은 무시됨
)
```

### flutter_chat_ui 통합
```dart
// ChatDetailWidget에서 커스텀 메시지 빌더
Widget _customMessageBuilder(types.CustomMessage message) {
  final metadata = message.metadata ?? {};
  
  if (metadata['type'] == 'voteCard') {
    return VoteCardMessage(
      postId: metadata['postId'] ?? '',
      title: metadata['title'] ?? '',
      optionAText: metadata['optionA'] ?? '',
      optionBText: metadata['optionB'] ?? '',
      cardStatus: metadata['status'] ?? 'votingRequest',
      voteEndTime: metadata['endTime'] != null 
        ? DateTime.parse(metadata['endTime']) 
        : null,
      isMe: message.author.id == currentUserUid,
      messageType: 'voteCard',
    );
  }
  
  return SizedBox.shrink();
}
```

## 🔄 상태 관리 시스템

### VoteStateCoordinator 통합
```dart
// 통합 상태 스트림 생성
final voteStateStream = VoteStateCoordinator.instance.getVoteStateStream(
  postId: postId,
  voteEndTime: endTime,
  initialStatus: status,
  userVotes: votes,
);

// StreamBuilder로 실시간 업데이트
StreamBuilder<VoteStateData>(
  stream: voteStateStream,
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final state = snapshot.data!;
      // state.voteState: 현재 투표 상태
      // state.remainingTime: 남은 시간
      // state.userVotes: 사용자 투표 데이터
      // state.voteResults: 투표 결과
    }
    return buildUI();
  },
)
```

### 투표 제출 프로세스
```dart
// BaseVoteMessageStateMixin의 submitVote 메서드
Future<void> submitVote(String option) async {
  await VoteStatusService.submitVote(
    postId: widget.postId,
    userId: currentUserUid,
    choice: option,
    messageId: widget.messageId,
    chatId: widget.chatId,
    onError: (error) {
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    },
  );
}
```

## ⚡ 성능 최적화

### 전역 BoxSizes 캐시
```dart
// 메시지별 박스 크기 캐싱으로 스크롤 성능 최적화
static final Map<String, BoxSizes> _globalBoxSizesCache = {};

// 캐시 키 생성 (메시지ID + 화면 너비)
final cacheKey = '${widget.messageId ?? widget.postId}_$screenWidth';

// 캐시에서 로드
if (_globalBoxSizesCache.containsKey(cacheKey)) {
  _cachedBoxSizes = _globalBoxSizesCache[cacheKey];
}

// 계산 후 캐시에 저장
_globalBoxSizesCache[cacheKey] = calculatedBoxSizes;
```

### UnifiedImageCacheService 통합
```dart
// 동적 이미지 캐시 크기 계산
final cacheWidth = UnifiedImageCacheService.calculateForBox(
  context,
  boxWidth: boxSize.width,
  isHorizontal: layoutType == LayoutType.horizontal,
);

// CachedNetworkImage 최적화
CachedNetworkImage(
  imageUrl: imageUrl,
  memCacheWidth: cacheWidth,  // 400-1600px 동적 조정
  maxWidthDiskCache: UnifiedImageCacheService.MAX_CACHE_WIDTH,
  fadeInDuration: const Duration(milliseconds: 200),
)
```

### Widget 재사용 방지
```dart
// ValueKey로 flutter_chat_ui의 widget 재사용 방지
VoteCardMessage(
  key: ValueKey(message.id),  // 필수!
  // ... 기타 속성
)
```

## 🎨 디자인 시스템

### 색상 체계
- **옵션 A**: `Color(0xFFFF6B6B)` - 빨강 계열
- **옵션 B**: `Color(0xFF4ECDC4)` - 청록 계열
- **진행중**: `Colors.blue` - 파란색
- **완료**: `Colors.green` - 초록색
- **만료**: `Colors.grey` - 회색

### 타이포그래피
- **제목**: `VersusTextStyles.titleMedium`
- **설명**: `VersusTextStyles.bodyMedium`
- **옵션 텍스트**: `VersusTextStyles.bodySmall`
- **버튼**: `VersusTextStyles.buttonMedium`
- **라벨**: `VersusTextStyles.labelSmall`

### 간격 시스템
- `VersusSpacing.xs`: 4px
- `VersusSpacing.sm`: 8px
- `VersusSpacing.md`: 16px
- `VersusSpacing.lg`: 24px

## 🔗 관련 파일

### 서비스
- `/lib/services/vote_state_coordinator.dart` - 통합 투표 상태 관리
- `/lib/services/vote_timer_service.dart` - 투표 타이머 동기화
- `/lib/services/vote_status_service.dart` - 투표 제출 및 상태 관리
- `/lib/services/unified_image_cache_service.dart` - 이미지 캐싱

### 유틸리티
- `/lib/posts/in_put_post_image/helpers/aspect_ratio_analyzer.dart` - 레이아웃 분석
- `/lib/shared/services/unified_box_calculator.dart` - 박스 크기 계산
- `/lib/utils/responsive_breakpoints.dart` - 반응형 브레이크포인트

### 상위 페이지
- `/lib/pages/chat/chat_detail_v2/` - 채팅 상세 화면
- `/lib/pages/chat/ai_chat_v2/` - AI 채팅 화면

### 알림 시스템
- `/lib/components/notifications/voting_notification_dialog.dart` - 투표 알림 다이얼로그

## 📊 아키텍처 다이어그램

```
VoteCardMessage
    ├── BaseVoteMessage (추상 클래스)
    │   └── BaseVoteMessageStateMixin
    │       └── VoteStatusService (투표 제출)
    ├── VoteStateCoordinator (상태 관리)
    │   ├── VoteTimerService (타이머)
    │   ├── VoteStatusService (상태)
    │   └── Firebase Firestore (실시간)
    ├── vote_card/ (UI 컴포넌트)
    │   ├── VoteActionButton
    │   ├── VoteCardHeader  
    │   ├── VoteOptionBox
    │   └── VoteResultDisplay
    └── 최적화 시스템
        ├── Global BoxSizes Cache
        ├── UnifiedImageCacheService
        └── AspectRatioAnalyzer
```

## 🐛 문제 해결

### 스크롤 점프 문제 (해결됨)
```dart
// 문제: 스크롤 시 메시지 높이 변동
// 원인: Widget 재사용 및 박스 크기 재계산

// 해결책:
1. ValueKey(message.id) 추가로 widget 재사용 방지
2. 전역 BoxSizes 캐시로 재계산 방지
3. UnifiedBoxCalculator 동적 기본값 사용
```

### 타이머 동기화 문제 (해결됨)
```dart
// 문제: 같은 투표가 다른 남은 시간 표시
// 원인: 각 위젯이 독립적인 Timer 인스턴스 생성

// 해결책:
VoteStateCoordinator 통합으로 중앙 집중식 타이머 관리
```

### 이미지 로딩 성능
```dart
// 문제: 고해상도 이미지로 인한 메모리 과다 사용

// 해결책:
UnifiedImageCacheService로 동적 캐시 크기 조정 (400-1600px)
```

## 📝 변경 이력

- **2025-08-22**: 문서 전체 개정 및 상세 설명 추가
- **2025-08-18**: VoteStateCoordinator 중심 리팩토링
- **2025-08-17**: 투표 타이머 동기화 시스템 구현
- **2025-08-08**: 전역 BoxSizes 캐시 시스템 구현
- **2025-08-06**: VoteRequestMessage 제거 및 VoteCardMessage 통합
- **2025-07-26**: 초기 채팅 투표 시스템 구현

---

*이 문서는 `/lib/components/chat` 디렉토리의 채팅 투표 메시지 컴포넌트를 설명합니다.*