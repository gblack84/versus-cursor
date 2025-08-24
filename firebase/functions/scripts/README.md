# 🔧 마이그레이션 스크립트 (Migration Scripts)

## 📋 개요

Firebase Functions의 마이그레이션 스크립트 모음으로, Firestore 데이터베이스의 스키마 변경 및 데이터 변환을 안전하게 수행합니다. 프로젝트의 네이밍 컨벤션 통일(snake_case → camelCase) 및 투표 시스템 구조 개선을 위한 필수 도구들입니다.

### 디렉토리 상태
- **상태**: ⚠️ **임시 도구**
- **중요도**: ⭐⭐⭐⭐
- **용도**: 데이터베이스 스키마 마이그레이션, 네이밍 컨벤션 변환
- **권장사항**: 마이그레이션 완료 후 백업 보관, 프로덕션 실행 시 주의

## 🎯 네이밍 컨벤션

프로젝트 표준 네이밍 컨벤션을 따릅니다:

| 구분 | 컨벤션 | 예시 |
|------|--------|------|
| **파일명** | kebab-case.js | `migrate-snake-to-camel.js` |
| **함수명** | camelCase | `migrateCollection()`, `convertFieldNames()` |
| **변수명** | camelCase | `isDryRun`, `totalProcessed` |
| **상수** | UPPER_SNAKE_CASE | `FIELD_MAPPINGS` |
| **컬렉션** | camelCase | `users`, `posts`, `messages` |
| **필드명** | camelCase | `userId`, `createdAt`, `voteEndTime` |

참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
scripts/
├── migrate-snake-to-camel.js  # 네이밍 컨벤션 마이그레이션 (305줄)
├── migrate-vote-data.js       # 투표 데이터 구조 마이그레이션 (190줄)
└── README.md                   # 문서 (이 파일)
```

## 🔧 주요 구성요소

### 1. migrate-snake-to-camel.js - 네이밍 컨벤션 마이그레이션
**Firestore 필드명을 snake_case에서 camelCase로 일괄 변환** (305줄)

#### 핵심 기능
- **136개 필드 매핑**: 전체 프로젝트 필드명 표준화
- **18개 컬렉션 처리**: 모든 Firestore 컬렉션 대상
- **배치 처리**: 500개씩 Firestore 배치 제한 준수
- **DRY RUN 모드**: 실제 변경 전 시뮬레이션
- **중첩 객체 지원**: 깊은 레벨의 필드도 변환

#### 필드 매핑 예시
```javascript
const FIELD_MAPPINGS = {
  // 공통 필드
  'created_at': 'createdAt',
  'updated_at': 'updatedAt',
  'last_active': 'lastActive',
  
  // 사용자 필드
  'user_id': 'userId',
  'display_name': 'displayName',
  'photo_url': 'photoUrl',
  'points_A': 'pointsA',
  'points_Q': 'pointsQ',
  
  // 게시물 필드
  'vote_start_time': 'voteStartTime',
  'vote_end_time': 'voteEndTime',
  'votes_a': 'votesA',
  'votes_b': 'votesB',
  
  // 메시지 필드
  'sender_id': 'senderId',
  'receiver_id': 'receiverId',
  'card_status': 'cardStatus'
};
```

#### 실행 프로세스
```javascript
async function migrateCollection(collectionName, isDryRun = true) {
  const collection = db.collection(collectionName);
  const snapshot = await collection.limit(isDryRun ? 10 : 1000).get();
  
  for (const doc of snapshot.docs) {
    const { data: convertedData, hasChanges } = convertFieldNames(doc.data());
    
    if (hasChanges && !isDryRun) {
      batch.update(doc.ref, convertedData);
    }
  }
}
```

### 2. migrate-vote-data.js - 투표 데이터 구조 마이그레이션
**개별 투표 필드를 user_votes Map 구조로 변환** (190줄)

#### 데이터 구조 변환

##### 기존 구조 (deprecated)
```javascript
{
  user_voted: true,
  vote_choice: "A",
  vote_participated_at: Timestamp
}
```

##### 새 구조 (현재)
```javascript
{
  user_votes: {
    "userId1": {
      option: "A",
      voted_at: Timestamp
    },
    "userId2": {
      option: "B", 
      voted_at: Timestamp
    }
  }
}
```

#### 마이그레이션 로직
```javascript
async function migrateMessages() {
  // AI 채팅 메시지만 대상
  const messagesQuery = db.collection('chats')
    .doc(chatId)
    .collection('messages')
    .where('messageType', 'in', ['voteRequest', 'voteCreated']);
  
  for (const messageDoc of messagesSnapshot.docs) {
    if (messageData.user_voted === true && messageData.sender_id) {
      const userVotes = {};
      userVotes[messageData.sender_id] = {
        option: messageData.vote_choice || '',
        voted_at: messageData.vote_participated_at || Timestamp.now()
      };
      
      await messageDoc.ref.update({
        user_votes: userVotes,
        migrated_at: Timestamp.now(),
        migration_version: '1.0'
      });
    }
  }
}
```

## 💡 사용 방법

### 네이밍 컨벤션 마이그레이션 (snake_case → camelCase)

#### 1. 사전 준비
```bash
cd firebase/functions
npm install firebase-admin
```

#### 2. 테스트 실행 (DRY RUN)
```bash
# 변경 사항 미리보기 (실제 변경 없음)
node scripts/migrate-snake-to-camel.js --dry-run
```

#### 3. 실제 마이그레이션
```bash
# ⚠️ 프로덕션 데이터 변경 - 5초 대기 후 실행
node scripts/migrate-snake-to-camel.js --execute
```

### 투표 데이터 구조 마이그레이션

#### 1. 환경 설정
```bash
# 서비스 계정 키 설정 (선택사항)
export GOOGLE_APPLICATION_CREDENTIALS="./service-account-key.json"
```

#### 2. 단계별 실행
```bash
# Step 1: DRY RUN으로 확인
node scripts/migrate-vote-data.js --dry-run --limit=10

# Step 2: 소량 실제 테스트
node scripts/migrate-vote-data.js --limit=5

# Step 3: 전체 마이그레이션
node scripts/migrate-vote-data.js
```

## 📊 실행 결과 예시

### 네이밍 컨벤션 마이그레이션 출력
```
==========================================
Firestore snake_case → camelCase Migration
==========================================
Mode: DRY RUN (no changes will be made)

📁 Processing collection: users
  Field renamed: user_id → userId
  Field renamed: display_name → displayName
  Field renamed: photo_url → photoUrl
  Document user123: needs update
  Processed: 10 documents, Updated: 3 documents

📁 Processing collection: posts
  Field renamed: vote_start_time → voteStartTime
  Field renamed: vote_end_time → voteEndTime
  Document post456: needs update
  Processed: 10 documents, Updated: 5 documents

==========================================
Migration Summary
==========================================
Total documents processed: 180
Total documents updated: 67

Per collection:
  users: 10 processed, 3 updated
  posts: 10 processed, 5 updated
  messages: 10 processed, 8 updated
  ...

✅ Dry run completed. No changes were made.
Run with --execute flag to apply changes.
```

### 투표 데이터 마이그레이션 출력
```
=== 투표 데이터 마이그레이션 시작 ===
모드: PRODUCTION (실제 실행)
처리 제한: 100개

📋 메시지 마이그레이션 시작...

채팅방 처리 중: ai_assistant_user123
  🔄 메시지 msg456: 마이그레이션 필요
     - sender_id: user123
     - vote_choice: A
     - user_votes: {"user123":{"option":"A","voted_at":...}}
     ✅ 마이그레이션 완료

=== 마이그레이션 완료 ===
전체 메시지: 100
마이그레이션됨: 23
스킵됨: 77
오류: 0

📊 마이그레이션 검증 시작...

=== 검증 결과 ===
구 형식만: 0
신 형식만: 23
양쪽 형식: 0

권장사항: 마이그레이션 완료
```

## ⚠️ 주의사항

### 실행 전 체크리스트
- [ ] **Firestore 백업 완료**: 프로덕션 데이터 백업 필수
- [ ] **테스트 환경 검증**: 개발 환경에서 먼저 테스트
- [ ] **DRY RUN 실행**: 실제 변경 전 시뮬레이션 확인
- [ ] **비즈니스 시간 외 실행**: 사용자 영향 최소화
- [ ] **모니터링 준비**: 실행 중 에러 모니터링

### 비용 및 성능
- **읽기 작업**: 모든 문서 스캔 (컬렉션 크기에 비례)
- **쓰기 작업**: 변경이 필요한 문서만 업데이트
- **예상 시간**: 1000개 문서당 약 1-2분
- **배치 제한**: 500개 작업/배치 (Firestore 제한)

### 안전성 보장
- **멱등성**: 여러 번 실행해도 같은 결과
- **원자성**: 배치 단위로 트랜잭션 처리
- **중복 방지**: 이미 변환된 데이터 자동 스킵
- **롤백 가능**: 백업에서 복원 가능

## 🔍 검증 방법

### 마이그레이션 후 확인 사항
1. **데이터 무결성**
   ```javascript
   // Firestore Console에서 확인
   users.where('user_id', '!=', null) // 구 필드 잔존 확인
   users.where('userId', '!=', null)  // 신 필드 존재 확인
   ```

2. **앱 동작 테스트**
   - 로그인/회원가입 정상 작동
   - 투표 생성 및 참여 기능
   - 채팅 메시지 표시
   - 알림 수신

3. **성능 모니터링**
   - Firestore 읽기/쓰기 지연 시간
   - 에러율 모니터링
   - 사용자 피드백 수집

## 📈 성능 최적화

### 배치 처리 전략
```javascript
// 500개씩 배치 처리 (Firestore 제한)
if (batchCount === 500) {
  await batch.commit();
  batchCount = 0;
}
```

### 제한적 쿼리
```javascript
// DRY RUN: 10개만 테스트
// PRODUCTION: 1000개씩 처리
const snapshot = await collection
  .limit(isDryRun ? 10 : 1000)
  .get();
```

## 📝 변경 이력

### 2025-08-21: 네이밍 컨벤션 통일
- migrate-snake-to-camel.js 생성
- 768개 필드 snake_case → camelCase 변환
- 18개 컬렉션 대상 마이그레이션

### 2025-08-13: 투표 구조 개선
- migrate-vote-data.js 생성
- 개별 투표 필드 → user_votes Map 구조
- AI 채팅 메시지 타겟

## 🎯 향후 계획

### 단기 (1개월)
1. **자동화 개선**
   - GitHub Actions 통합
   - 자동 백업 후 마이그레이션
   - 실행 결과 Slack 알림

2. **검증 강화**
   - 마이그레이션 전/후 데이터 검증
   - 자동 롤백 메커니즘
   - 상세 로그 생성

### 장기 (3개월)
1. **도구 확장**
   - 범용 스키마 마이그레이션 프레임워크
   - GUI 기반 마이그레이션 도구
   - 버전 관리 시스템

2. **모니터링**
   - 실시간 진행률 대시보드
   - 성능 메트릭 수집
   - 비용 분석 리포트

## 🔗 관련 문서

### 프로젝트 문서
- [Firebase Functions 메인](../README.md)
- [네이밍 컨벤션](../../../NAMING_CONVENTION.md)
- [프로젝트 아키텍처](../../../ARCHITECTURE.md)

### 외부 참조
- [Firestore 배치 작업](https://firebase.google.com/docs/firestore/manage-data/transactions)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)
- [Firestore 비용 계산기](https://cloud.google.com/products/calculator)

## ⚠️ 보안 고려사항

### 인증 및 권한
- 서비스 계정 키 절대 커밋 금지
- 환경 변수로 인증 정보 관리
- 최소 권한 원칙 적용

### 데이터 보호
- 마이그레이션 중 데이터 암호화
- 로그에 민감 정보 제외
- 백업 파일 안전한 저장소 보관

---

*이 디렉토리는 Versus Space 프로젝트의 데이터베이스 스키마 진화를 관리하는 필수 도구 모음입니다.*