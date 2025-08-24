# 🔔 알림 시스템 (Notification System)

## 📋 개요

Versus Space의 핵심 알림 시스템으로, AI 기반 타겟팅을 통해 사용자에게 맞춤형 투표 요청을 전송합니다. 게시물 생성 시 자동으로 타겟 오디언스를 분석하고, 관련성이 높은 사용자를 선정하여 실시간 알림과 AI 채팅 메시지를 동시에 전송하는 스마트 알림 시스템입니다.

### 디렉토리 상태
- **상태**: ✅ **핵심 시스템**
- **중요도**: ⭐⭐⭐⭐⭐
- **용도**: 투표 알림 생성, 타겟 사용자 매칭, AI 채팅 통합
- **권장사항**: 투표 시스템의 핵심 기능으로 필수 유지

## 🎯 네이밍 컨벤션

프로젝트 표준 네이밍 컨벤션을 따릅니다:

| 구분 | 컨벤션 | 예시 |
|------|--------|------|
| **파일명** | camelCase.js | `notificationCreator.js`, `targetMatcher.js` |
| **함수명** | camelCase | `createNotificationsForUsers()`, `matchTargetUsers()` |
| **변수명** | camelCase | `targetCount`, `matchedUsers`, `postData` |
| **상수** | camelCase | `oneWeekAgo`, `expiryTime` |
| **컬렉션** | camelCase | `notifications`, `users`, `posts` |
| **필드명** | camelCase | `userId`, `createdAt`, `targetAudience` |

참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
notifications/
├── notificationCreator.js   # 알림 생성 및 배치 처리 (210줄)
├── targetMatcher.js         # 타겟 사용자 매칭 로직 (192줄)
└── README.md               # 문서 (이 파일)
```

## 🔧 주요 구성요소

### 1. notificationCreator.js - 알림 생성 엔진
**알림 문서 생성 및 AI 채팅 메시지 통합** (210줄)

#### 핵심 기능
- **타겟 메시지 생성**: 매칭 타입별 맞춤 메시지
- **배치 처리**: 최대 500개씩 효율적 처리
- **멀티이미지 지원**: A/B 각각 여러 이미지 표시
- **스마트 레이아웃**: aspectRatio 기반 자동 레이아웃
- **AI 채팅 통합**: 알림과 동시에 AI 채팅 메시지 생성

#### 알림 데이터 구조
```javascript
{
  // 기본 정보
  notificationId: 'unique_id',
  userId: 'target_user_id',
  type: 'votingRequest',
  sourceId: 'post_id',
  
  // 콘텐츠 (JSON 문자열)
  content: JSON.stringify({
    title: '새로운 투표가 도착했어요!',
    message: 'AI가 당신에게 추천하는 투표입니다',
    postData: {
      questionTitle: '질문',
      optionA: 'A 선택지',
      optionB: 'B 선택지',
      imageUrlsA: ['url1', 'url2'],  // 멀티이미지
      imageUrlsB: ['url3', 'url4'],
      aspectRatioA: [1.5, 1.2],      // 이미지 비율
      aspectRatioB: [0.8, 0.9],
      layoutType: 'horizontal',      // 레이아웃 타입
      authorName: '작성자',
      description: '설명'
    }
  }),
  
  // 메타데이터
  createdAt: Timestamp,
  read: false,
  targetAudience: ['quick'],  // 배열 형식
  expiryTime: Timestamp,      // 15분 후 만료
  interactionType: 'vote'
}
```

#### 타겟 메시지 생성 로직
```javascript
function generateTargetReason(targetAudience, user) {
  switch (type) {
    case 'quick':
      return 'AI가 당신에게 추천하는 투표입니다';
    case 'public':
      return '모든 사용자에게 공개된 투표입니다';
    case 'custom':
      // 조건별 맞춤 메시지 생성
      return `${interests.join(', ')}에 관심있으신 ${ageGroup} 분들을 위한 투표입니다`;
  }
}
```

### 2. targetMatcher.js - 타겟 사용자 매칭 엔진
**AI 기반 사용자 매칭 및 필터링** (192줄)

#### 매칭 타입

##### 2.1 Quick (빠른 수집) - AI 추천
```javascript
{
  type: 'quick',
  targetCount: 100
}
```
- **AI 분석**: Gemini AI가 게시물과 사용자 프로필 분석
- **후보군**: 목표의 5배수(최대 500명) 확보
- **선정 기준**: AI 관련성 점수 상위 선택
- **폴백**: AI 실패 시 랜덤 선택

##### 2.2 Public (전체 공개) - 랜덤
```javascript
{
  type: 'public',
  targetCount: 100
}
```
- **대상**: 최근 7일 이내 활동 사용자
- **선정**: 무작위 추출
- **공평성**: 모든 활성 사용자에게 동등한 기회

##### 2.3 Custom (맞춤 설정) - 조건부
```javascript
{
  type: 'custom',
  targetCount: 100,
  interests: ['게임', '기술'],
  ageGroup: '20대',
  gender: 'male'
}
```
- **필터링**: 관심사, 연령대, 성별 조건
- **AI 점수**: 조건 충족 사용자 중 AI 점수 우선
- **정렬**: 관련성 높은 순서로 선택

#### 활성 사용자 쿼리
```javascript
async function getActiveUsers(targetCount, oneWeekAgo, filters = {}) {
  // 1. 새 필드명 시도 (lastActive)
  let query = admin.firestore().collection('users')
    .where('lastActive', '>', oneWeekAgo);
  
  // 2. 필터 적용
  if (filters.interests?.length > 0) {
    query = query.where('interests', 'array-contains-any', filters.interests);
  }
  if (filters.ageGroup && filters.ageGroup !== '전체') {
    query = query.where('ageGroup', '==', filters.ageGroup);
  }
  
  // 3. 레거시 필드 폴백 (lastActiveTime)
  // backward compatibility 지원
}
```

## 💡 시스템 아키텍처

### 알림 생성 플로우
```
게시물 생성 (Firestore)
        ↓
타겟 오디언스 확인
        ↓
┌─────────────────────┐
│  타겟 사용자 매칭    │
├─────────────────────┤
│ 1. 활성 사용자 쿼리  │
│ 2. 조건 필터링       │
│ 3. AI 점수 계산      │
│ 4. 최종 선정         │
└─────────────────────┘
        ↓
┌─────────────────────┐
│  알림 생성           │
├─────────────────────┤
│ 1. 배치 문서 생성    │
│ 2. AI 채팅 메시지    │
│ 3. 통계 업데이트     │
└─────────────────────┘
        ↓
사용자 알림 수신
```

### AI 통합 아키텍처
```
타겟 매칭 요청
        ↓
후보군 확보 (5배수)
        ↓
AI 분석 요청 (/ai/userRecommendation)
        ↓
┌─────────────────────┐
│  Gemini AI 분석      │
├─────────────────────┤
│ • 게시물 내용 이해   │
│ • 사용자 프로필 매칭 │
│ • 관련성 점수 계산   │
│ • 다양성 보장        │
└─────────────────────┘
        ↓
점수 기반 정렬
        ↓
상위 N명 선택
```

## 🔍 사용 방법

### Firebase Function 통합
```javascript
// functions/firestore/onPostCreatedSendNotifications.js
const { matchTargetUsers } = require('../../notifications/targetMatcher');
const { createNotificationsForUsers } = require('../../notifications/notificationCreator');

exports.onPostCreatedSendNotifications = functions.firestore
  .document('posts/{postId}')
  .onCreate(async (snap, context) => {
    const postData = snap.data();
    
    // 타겟 오디언스 확인
    if (!postData.targetAudience) return;
    
    // 1. 타겟 사용자 매칭
    const targetUsers = await matchTargetUsers(
      postData.targetAudience,
      postData
    );
    
    // 2. 알림 생성 및 전송
    await createNotificationsForUsers(
      targetUsers,
      context.params.postId,
      postData
    );
  });
```

### Flutter 클라이언트 통합
```dart
// lib/services/notification_service.dart
class NotificationService {
  StreamSubscription? _notificationSubscription;
  
  void startListening(String userId) {
    _notificationSubscription = FirebaseFirestore.instance
      .collection('notifications')
      .where('userId', isEqualTo: userId)
      .where('type', isEqualTo: 'votingRequest')
      .where('read', isEqualTo: false)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            _showNotification(change.doc);
          }
        }
      });
  }
  
  void _showNotification(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final content = jsonDecode(data['content']);
    
    // 알림 다이얼로그 표시
    showVotingNotificationDialog(
      context,
      content['postData'],
    );
  }
}
```

## 📊 성능 최적화

### 쿼리 최적화
- **복합 인덱스**: `lastActive + interests`, `lastActive + ageGroup`
- **제한적 필드 선택**: 필요한 필드만 쿼리
- **배치 크기 제한**: 최대 500개씩 처리

### 캐싱 전략
```javascript
// 활성 사용자 캐싱 (메모리)
const activeUsersCache = new Map();
const CACHE_TTL = 5 * 60 * 1000; // 5분

function getCachedActiveUsers(key) {
  const cached = activeUsersCache.get(key);
  if (cached && Date.now() - cached.timestamp < CACHE_TTL) {
    return cached.users;
  }
  return null;
}
```

### 병렬 처리
```javascript
// AI 채팅 메시지 병렬 생성
const chatPromises = users
  .filter(user => user.id !== creatorId)
  .map(user => createVoteRequestMessage(user.id, postId, postData));

await Promise.all(chatPromises);
```

## 🚀 테스트 방법

### 플랫폼별 테스트 계정
```javascript
// 자동 생성되는 테스트 계정
const testAccounts = {
  ios: 'tester-ios@versus.test',
  android: 'tester-android@versus.test',
  web: 'tester-web@versus.test',
  macos: 'tester-macos@versus.test'
};
```

### 테스트 시나리오
1. **Quick 모드 테스트**
   - 테스트 계정으로 로그인
   - 게시물 작성 + Quick 타겟 설정
   - AI 추천 동작 확인
   - 알림 수신 확인

2. **Custom 모드 테스트**
   - 특정 조건 설정 (관심사, 연령대)
   - 필터링 동작 확인
   - 대상 사용자 검증

3. **부하 테스트**
   - 대량 사용자 시뮬레이션
   - 배치 처리 성능 측정
   - 메모리 사용량 모니터링

## 📈 모니터링

### 로깅 전략
```javascript
// 구조화된 로그
console.log('🔔 [NOTIFICATION] 알림 생성 시작', {
  timestamp: new Date().toISOString(),
  postId,
  userCount: users.length,
  targetType: postData.targetAudience?.type
});

// 성능 로그
console.time('notification-creation');
// ... 처리 로직
console.timeEnd('notification-creation');
```

### 주요 메트릭
- **매칭 성공률**: 목표 대비 실제 매칭 수
- **AI 응답 시간**: Gemini AI 처리 시간
- **알림 생성 시간**: 배치 처리 소요 시간
- **오류율**: 실패한 알림 생성 비율

## 📝 변경 이력

### 2025-08-24: 알림 시스템 구현
- targetMatcher.js: AI 기반 사용자 매칭
- notificationCreator.js: 배치 알림 생성
- 멀티이미지 지원 추가
- 스마트 레이아웃 정보 전달

### 2025-08-20: 초기 구현
- 기본 알림 시스템 구축
- Quick/Public/Custom 타입 정의
- AI 통합 기반 마련

## 🎯 향후 계획

### 단기 (1-2개월)
1. **고급 타겟팅**
   - 지역 기반 매칭
   - 시간대 고려
   - 행동 패턴 분석

2. **알림 최적화**
   - 푸시 알림 통합
   - 알림 그룹화
   - 우선순위 큐

### 장기 (3-6개월)
1. **AI 고도화**
   - 사용자 피드백 학습
   - 개인화 알고리즘
   - 실시간 추천

2. **분석 도구**
   - 알림 효과 측정
   - A/B 테스트 프레임워크
   - 대시보드 구축

## 🔗 관련 문서

### 프로젝트 문서
- [Firebase Functions 메인](../README.md)
- [AI 시스템](../ai/README.md)
- [서비스 레이어](../services/README.md)
- [Firestore 트리거](../functions/firestore/README.md)
- [네이밍 컨벤션](../../../NAMING_CONVENTION.md)

### 외부 참조
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Firestore 쿼리 최적화](https://firebase.google.com/docs/firestore/query-data/queries)
- [Gemini AI API](https://ai.google.dev/docs)

## ⚠️ 보안 고려사항

### 데이터 보호
- 사용자 ID 마스킹
- 민감한 정보 로깅 금지
- 15분 자동 만료 설정

### 접근 제어
- 서비스 계정만 알림 생성 가능
- 사용자는 자신의 알림만 읽기 가능
- 타겟 조건 검증

### 입력 검증
- SQL 인젝션 방지
- XSS 공격 방지
- 타겟 수 제한 (최대 500)

---

*이 디렉토리는 Versus Space의 핵심 알림 시스템으로, AI 기반 타겟팅을 통해 사용자 참여를 극대화하는 스마트 알림 엔진입니다.*