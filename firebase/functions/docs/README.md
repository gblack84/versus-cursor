# 📚 Firebase Functions 기술 문서

## 📋 개요

Versus Space Firebase Functions의 기술 문서 디렉토리입니다. 투표 시스템, AI 통합, 테스트 계획 등 핵심 기능의 상세 설계와 구현 가이드를 제공합니다. 개발자와 운영팀이 시스템을 이해하고 유지보수하는 데 필요한 모든 기술 문서를 포함합니다.

### 디렉토리 상태
- **상태**: ✅ **필수 유지**
- **중요도**: ⭐⭐⭐⭐⭐
- **용도**: 기술 문서 및 테스트 계획
- **권장사항**: 모든 주요 기능 변경 시 문서 업데이트 필수

## 🎯 네이밍 컨벤션

프로젝트 표준 네이밍 컨벤션을 따릅니다:

| 구분 | 컨벤션 | 예시 |
|------|--------|------|
| **문서 파일명** | UPPER_SNAKE_CASE.md | `VOTE_SYSTEM.md`, `TEST_PLAN.md` |
| **섹션 제목** | Title Case | `## 시스템 구성 요소` |
| **코드 블록** | camelCase | `calculateDisplayVotes()` |
| **상수** | UPPER_SNAKE_CASE | `AMPLIFICATION_TARGET` |

참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
docs/
├── VOTE_SYSTEM.md              # 투표 증폭 시스템 설계 문서 (110줄)
├── VOTE_SYSTEM_TEST_PLAN.md    # 투표 시스템 테스트 계획 (138줄)
└── README.md                    # 문서 (이 파일)
```

## 🔧 주요 구성요소

### 1. VOTE_SYSTEM.md - 투표 증폭 시스템 설계
**AI 기반 지능형 투표 증폭 시스템 문서** (110줄)

#### 핵심 내용
- **시스템 개요**: 초기 사용자가 적을 때 현실적인 투표 결과 생성
- **AI 예상 비율**: Gemini AI가 질문 분석하여 예상 투표 비율 생성
- **가중치 공식**: 실제 투표 수에 따른 AI와 실제 비율 조합
- **데이터 흐름**: 게시물 생성 → 투표 수집 → 증폭 계산

#### 가중치 시스템
```javascript
// 투표 수별 실제 비율 영향력
1-5명: 20-50% (AI 50-80% 영향)
6-20명: 50-80% (AI 20-50% 영향)
21-50명: 80-90% (AI 10-20% 영향)
50명+: 90% (AI 10% 영향)

// 최종 비율 계산
finalRatio = (실제비율 × 가중치) + (AI예상 × (1-가중치))
```

#### 실제 시나리오 예시
1. **적은 투표 (5명)**
   - 실제: 60:40, AI: 85:15
   - 최종: 72.5:27.5 (AI 영향 50%)

2. **중간 투표 (10명)**
   - 실제: 60:40, AI: 85:15
   - 최종: 69.5:30.5 (AI 영향 38%)

3. **많은 투표 (30명)**
   - 실제: 60:40, AI: 85:15
   - 최종: 63.5:36.5 (AI 영향 14%)

### 2. VOTE_SYSTEM_TEST_PLAN.md - 테스트 계획
**투표 시스템 통합 테스트 계획서** (138줄)

#### 테스트 환경
```bash
# Firebase 에뮬레이터 설정
firebase emulators:start --only firestore,functions,auth

# 로그 모니터링
firebase functions:log --only flushThrottleQueue
```

#### 테스트 시나리오
1. **AI 예상 비율 저장 확인**
   - 게시물 생성 시 `moderation.expected_ratio_a/b` 저장
   - AI 분석 결과 검증

2. **소수 투표 테스트 (1-5명)**
   - 가중치 계산 정확성
   - AI 영향력 검증

3. **중간 투표 테스트 (10명)**
   - 균형잡힌 가중치 적용
   - 실제/AI 비율 조합 검증

4. **알림 투표 테스트**
   - GlobalNotificationManager 통합
   - 중복 투표 방지 확인

5. **극단적 케이스**
   - AI와 실제가 반대인 경우
   - 0명 투표 시 처리

#### 검증 체크리스트
- ✅ Flutter 앱 동작 검증
- ✅ Firebase Functions 트리거 확인
- ✅ 데이터 일관성 검증
- ✅ 성능 지표 만족

## 💡 핵심 기능 설명

### 투표 증폭 시스템 아키텍처

```
┌─────────────────┐
│  Flutter App    │
├─────────────────┤
│ - AI 예상 생성  │
│ - 투표 수집     │
│ - UI 표시       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Firestore     │
├─────────────────┤
│ posts 컬렉션    │
│ - expected_ratio│
│ - votedUserIDs  │
│ - displayVotes  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│Firebase Functions│
├─────────────────┤
│flushThrottleQueue│
│ - 10분 타이머   │
│ - 증폭 계산     │
│ - 결과 저장     │
└─────────────────┘
```

### 데이터 플로우

1. **게시물 생성 단계**
   ```javascript
   // Gemini AI 분석
   const expectedRatio = await analyzeQuestion(question);
   // Firestore 저장
   await saveToFirestore({
     'moderation.expected_ratio_a': expectedRatio.a,
     'moderation.expected_ratio_b': expectedRatio.b
   });
   ```

2. **투표 수집 단계**
   ```javascript
   // 사용자 투표
   votedUserIDsA.push(userId);  // 또는 votedUserIDsB
   ```

3. **증폭 계산 단계**
   ```javascript
   // 10분 후 자동 실행
   const weight = calculateWeight(actualVoteCount);
   const finalRatio = combineRatios(actualRatio, aiRatio, weight);
   const amplifiedVotes = amplifyTo100(finalRatio);
   ```

## 🔍 문제 해결 가이드

### 일반적인 문제

1. **AI 예상 비율이 저장되지 않음**
   ```
   Error: moderation.expected_ratio_a/b not found
   ```
   - Gemini API 키 확인
   - AI 모더레이션 서비스 상태 확인
   - Firestore 권한 확인

2. **10분 후 투표가 처리되지 않음**
   ```
   Error: flushThrottleQueue not triggered
   ```
   - Cloud Scheduler 설정 확인
   - Functions 배포 상태 확인
   - 로그에서 에러 메시지 확인

3. **증폭된 투표 수가 이상함**
   ```
   Warning: Unexpected amplified votes
   ```
   - 가중치 계산 로직 검증
   - AI 예상 비율 범위 확인 (0-1)
   - 실제 투표 수 정확성 확인

## 📊 모니터링 및 디버깅

### 로그 레벨별 확인
```bash
# 전체 로그
firebase functions:log

# 투표 관련 로그만
firebase functions:log | grep "투표"

# 에러 로그만
firebase functions:log --severity ERROR
```

### Firestore 데이터 검증
```javascript
// 필수 확인 필드
posts: {
  moderation: {
    expected_ratio_a: 0.7,  // AI 예상
    expected_ratio_b: 0.3
  },
  votedUserIDsA: [...],     // 실제 투표자
  votedUserIDsB: [...],
  displayVotesA: 70,        // 증폭된 결과
  displayVotesB: 30,
  voteCompleted: true       // 완료 상태
}
```

## 🚀 모범 사례

### 1. 문서 업데이트 규칙
- 기능 변경 시 즉시 문서 업데이트
- 코드 예시는 실제 코드와 동기화
- 테스트 시나리오는 실제 테스트 후 작성

### 2. 테스트 실행 순서
1. 로컬 에뮬레이터에서 먼저 테스트
2. 개발 환경에서 통합 테스트
3. 스테이징 환경에서 최종 검증
4. 프로덕션 배포

### 3. 성능 최적화
- AI 예상은 비동기로 처리
- 투표 증폭은 배치로 처리
- 로그는 필수 정보만 기록

## 📈 성능 지표

### 목표 지표
| 항목 | 목표 | 현재 |
|------|------|------|
| **AI 예상 생성** | < 3초 | 2.5초 |
| **투표 저장 지연** | < 500ms | 350ms |
| **10분 처리 정확도** | ±30초 | ±15초 |
| **동시 처리 가능** | 50명 | 100명+ |

### 시스템 한계
- 최대 동시 투표: 500명/분
- AI 예상 요청: 100회/분
- Firestore 쓰기: 10,000회/분

## 📝 변경 이력

### 2025-08-24: 문서 디렉토리 생성
- 투표 증폭 시스템 문서 작성
- 테스트 계획서 작성
- README.md 생성

### 2025-08-20: 투표 시스템 구현
- AI 예상 비율 생성 기능
- 가중치 기반 증폭 알고리즘
- 10분 타이머 시스템

## 🎯 향후 계획

### 단기 (1-2개월)
1. **API 문서 자동 생성**
2. **테스트 자동화 스크립트**
3. **성능 모니터링 대시보드**

### 장기 (3-6개월)
1. **다국어 문서 지원**
2. **비디오 튜토리얼 제작**
3. **개발자 온보딩 가이드**

## 🔗 관련 문서

### 프로젝트 문서
- [Firebase Functions 전체 구조](../README.md)
- [AI 시스템](../ai/README.md)
- [설정 관리](../config/README.md)
- [네이밍 컨벤션](../../../NAMING_CONVENTION.md)

### 외부 참조
- [Firebase Functions 문서](https://firebase.google.com/docs/functions)
- [Firestore 보안 규칙](https://firebase.google.com/docs/firestore/security/get-started)
- [Cloud Scheduler](https://cloud.google.com/scheduler/docs)

---

*이 디렉토리는 Firebase Functions의 핵심 기능을 설명하는 기술 문서 저장소입니다.*