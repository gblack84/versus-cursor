# 투표 증폭 시스템 문서

## 개요
초기 사용자가 적을 때 현실적인 투표 결과를 보여주기 위한 AI 기반 투표 증폭 시스템입니다.

## 시스템 구성 요소

### 1. AI 예상 비율 생성 (Flutter)
- **위치**: `lib/services/ai_moderation/text_moderation/gemini_service.dart`
- **저장**: `posts.moderation.expected_ratio_a/b`
- **시점**: 게시물 생성 시
- **기능**: Gemini AI가 질문을 분석하여 예상 투표 비율 생성

### 2. 실제 투표 수집
- **채팅 투표**: `VoteCardMessage` 컴포넌트에서 처리
- **알림 투표**: `GlobalNotificationManager._submitVote()`에서 처리
- **저장 필드**: `votedUserIDsA/B` 배열

### 3. 투표 증폭 계산 (Firebase Functions)
- **트리거**: `flushThrottleQueue` (매분 실행)
- **조건**: 10분 경과 후 (`voteEndTime` 초과)
- **함수**: `calculateDisplayVotes()`

## 데이터 흐름

```
0분: 게시물 생성
├─ AI가 질문 분석 → 예상 비율 생성
├─ posts.moderation.expected_ratio_a/b에 저장
└─ 10분 타이머 시작

0~10분: 투표 진행
├─ 사용자들이 실제 투표
└─ votedUserIDsA/B 배열에 추가

10분: 투표 종료 및 계산
├─ AI 예상 비율 읽기
├─ 실제 투표 수 계산
├─ 가중치 적용하여 조합
└─ 100명 기준으로 증폭
```

## 가중치 공식

```javascript
// 투표 수에 따른 가중치 (실제 비율의 영향력)
1-5명: 20-50% (AI가 50-80% 영향)
6-20명: 50-80% (AI가 20-50% 영향)
21-50명: 80-90% (AI가 10-20% 영향)
50명+: 90% (AI가 10% 영향)

// 최종 비율 계산
finalRatio = (실제비율 × 가중치) + (AI예상 × (1-가중치))
```

## 예시 시나리오

### 시나리오 1: 적은 투표
- 실제: 5명 투표 (3:2 = 60:40)
- AI 예상: 85:15
- 가중치: 0.5 (50% 실제, 50% AI)
- 최종: (0.6×0.5) + (0.85×0.5) = 72.5:27.5

### 시나리오 2: 중간 투표
- 실제: 10명 투표 (6:4 = 60:40)
- AI 예상: 85:15
- 가중치: 0.62 (62% 실제, 38% AI)
- 최종: (0.6×0.62) + (0.85×0.38) = 69.5:30.5

### 시나리오 3: 많은 투표
- 실제: 30명 투표 (18:12 = 60:40)
- AI 예상: 85:15
- 가중치: 0.86 (86% 실제, 14% AI)
- 최종: (0.6×0.86) + (0.85×0.14) = 63.5:36.5

## 주요 파일 위치

### Flutter (Frontend)
- `/lib/posts/in_put_post_image/in_put_post_image_widget.dart` - AI 비율 저장
- `/lib/services/global_notification_manager.dart` - 알림 투표 처리
- `/lib/components/chat/vote_card_message.dart` - 채팅 투표 처리

### Firebase Functions (Backend)
- `/functions/scheduled/flushThrottleQueue.js` - 10분 후 투표 처리
- `/services/voteManagement.js` - 투표 증폭 계산
- `/services/aiChatService.js` - AI 채팅 메시지 업데이트

## 모니터링 및 디버깅

### 로그 확인
```bash
# Firebase Functions 로그
firebase functions:log

# 주요 로그 메시지
"[투표 처리] AI 예상 비율 - A: 0.7, B: 0.3"
"[투표 증폭] 실제 투표: 10명, 가중치: 0.62"
"[투표 증폭] 최종 비율 - A: 70%, B: 30%"
```

### 데이터 확인
1. Firestore `posts` 컬렉션에서 `moderation.expected_ratio_a/b` 확인
2. `votedUserIDsA/B` 배열로 실제 투표 수 확인
3. `displayVotesA/B`로 증폭된 결과 확인

## 향후 개선 사항
1. AI 예상 정확도 추적 및 개선
2. 사용자별 투표 패턴 분석
3. 카테고리별 가중치 조정
4. 실시간 투표 추이 반영