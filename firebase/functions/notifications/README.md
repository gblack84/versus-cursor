# 알림 시스템 (Notification System)

## 개요

Versus Space의 투표 알림 시스템으로, AI 기반 타겟팅을 통해 사용자에게 맞춤형 투표 요청을 전송합니다.

## 아키텍처

```
notifications/
├── targetMatcher.js        # 타겟 사용자 매칭 로직
└── notificationCreator.js  # 알림 생성 및 전송
```

## 주요 기능

### 1. 타겟 매칭 (targetMatcher.js)

#### 매칭 타입

**1.1 빠른 수집 (Quick) - AI 추천**
```javascript
{
  type: 'quick',
  targetCount: 100
}
```
- AI가 게시물과 사용자를 분석하여 최적 매칭
- 관심사, 활동 패턴, 참여 품질 기반
- 5배수 후보군에서 AI 점수로 선정

**1.2 전체 공개 (Public) - 랜덤**
```javascript
{
  type: 'public',
  targetCount: 100
}
```
- 활성 사용자 중 무작위 선택
- 최근 7일 이내 활동한 사용자 대상
- 공평한 기회 제공

**1.3 맞춤 설정 (Custom) - 조건부**
```javascript
{
  type: 'custom',
  targetCount: 100,
  interests: ['게임', '기술'],
  ageGroup: '20대',
  gender: 'all'
}
```
- 세부 조건 필터링
- 관심사, 연령대, 성별 기준
- AI 점수로 우선순위 정렬


#### 매칭 프로세스

```javascript
// 사용 예제
const matchedUsers = await matchTargetUsers(
  targetAudience,  // 타겟 설정
  postData         // 게시물 정보
);
```

1. **후보군 확보**
   - 활성 사용자 필터링 (7일 이내)
   - 조건에 맞는 사용자 쿼리

2. **AI 분석** (quick, custom 모드)
   - 게시물 내용 분석
   - 사용자 프로필 매칭
   - 관련성 점수 계산

3. **최종 선정**
   - 목표 수만큼 선택
   - 다양성 보장
   - 중복 방지

### 2. 알림 생성 (notificationCreator.js)

#### 알림 데이터 구조

```javascript
{
  notification_id: 'unique_id',
  user_id: 'target_user_id',
  type: 'voting_request',
  source_id: 'post_id',
  
  content: {
    title: '새로운 투표가 도착했어요!',
    message: 'AI가 당신에게 추천하는 투표입니다',
    postData: {
      questionTitle: '질문 제목',
      optionA: '선택지 A',
      optionB: '선택지 B',
      imageUrlA: 'https://...',
      imageUrlB: 'https://...',
      authorName: '작성자',
      category: '카테고리'
    }
  },
  
  created_at: Timestamp,
  read: false,
  target_audience: 'quick',
  expiry_time: Timestamp,  // 15분 후 만료
  interaction_type: 'vote'
}
```

#### 타겟 이유 메시지

각 매칭 타입별로 다른 메시지 생성:

- **Quick**: "AI가 당신에게 추천하는 투표입니다"
- **Public**: "모든 사용자에게 공개된 투표입니다"
- **Custom**: "게임, 기술에 관심있으신 20대 분들을 위한 투표입니다"

#### 배치 처리

```javascript
// 최대 500개씩 배치 처리
await createNotificationsForUsers(
  matchedUsers,  // 타겟 사용자 목록
  postId,        // 게시물 ID
  postData       // 게시물 데이터
);
```

## 사용 방법

### Firebase Function 통합

```javascript
// index.js
exports.onPostCreate = functions.firestore
  .document('posts/{postId}')
  .onCreate(async (snap, context) => {
    const postData = snap.data();
    
    // 타겟 오디언스가 설정된 경우만 처리
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

### 클라이언트 통합

```dart
// Flutter 클라이언트
class NotificationService {
  void startListening(String userId) {
    FirebaseFirestore.instance
      .collection('notifications')
      .where('user_id', isEqualTo: userId)
      .where('type', isEqualTo: 'voting_request')
      .where('read', isEqualTo: false)
      .snapshots()
      .listen((snapshot) {
        // 새 알림 처리
      });
  }
}
```

## 테스트 방법

### 1. 플랫폼별 테스트 계정 사용

이제 플랫폼별로 자동 생성되는 테스트 계정을 사용합니다:

- **iOS**: `tester-ios@versus.test`
- **Android**: `tester-android@versus.test`
- **Web**: `tester-web@versus.test`
- **macOS**: `tester-macos@versus.test`

### 2. 테스트 방법

1. 각 플랫폼에서 "플랫폼 테스트" 버튼으로 로그인
2. 한 플랫폼에서 게시물 작성
3. 타겟 오디언스 설정 (quick, public, custom)
4. 다른 플랫폼에서 알림 수신 확인
5. 실제 사용자 시나리오와 동일하게 테스트

### 3. 테스트 스크립트

```javascript
// test-notification.js
const { matchTargetUsers } = require('./notifications/targetMatcher');
const { createNotificationsForUsers } = require('./notifications/notificationCreator');

async function testNotifications() {
  const testPost = {
    uid: 'tester_id',
    questionTitle: '테스트 질문',
    optionA: 'A 옵션',
    optionB: 'B 옵션',
    targetAudience: {
      type: 'quick',  // 또는 'public', 'custom'
      targetCount: 50
    }
  };
  
  const users = await matchTargetUsers(
    testPost.targetAudience,
    testPost
  );
  
  console.log(`매칭된 사용자: ${users.length}명`);
}
```

## 성능 고려사항

### 1. 쿼리 최적화

- 복합 인덱스 사용
- 필요한 필드만 선택
- 페이지네이션 적용

### 2. 배치 처리

- 500개 단위로 알림 생성
- 트랜잭션 사용
- 에러 시 롤백

### 3. 캐싱

- 활성 사용자 목록 캐싱
- AI 분석 결과 캐싱
- 15분 TTL 설정

## 보안

### 1. 권한 검증

- 모든 타겟 타입은 일반 사용자도 사용 가능
- admin/tester role은 향후 다른 기능에서 활용

### 2. 데이터 검증

- 입력값 유효성 검사
- SQL 인젝션 방지
- XSS 방지

## 모니터링

### 로깅

```javascript
console.log(`[알림] 타겟 타입: ${type}, 목표: ${targetCount}`);
console.log(`[알림] 매칭 결과: ${matchedUsers.length}명`);
console.log(`[알림] ${successCount}개 알림 생성 완료`);
```

### 메트릭

- 매칭 성공률
- 알림 전송 수
- 응답 시간
- 에러율

## 문제 해결

### 1. 알림이 생성되지 않음

- 타겟 오디언스 설정 확인
- 활성 사용자 존재 여부 확인
- Firebase Functions 로그 확인

### 2. AI 매칭 실패

- API 키 설정 확인
- 네트워크 연결 확인
- 폴백 모드 동작 확인


## 향후 계획

1. **고급 타겟팅**
   - 지역 기반 매칭
   - 시간대 고려
   - 행동 패턴 분석

2. **알림 최적화**
   - 푸시 알림 통합
   - 알림 그룹화
   - 우선순위 설정

3. **분석 도구**
   - 알림 효과 측정
   - A/B 테스트
   - 사용자 피드백 수집