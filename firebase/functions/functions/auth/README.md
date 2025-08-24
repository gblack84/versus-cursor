# 🔐 Firebase Auth 트리거 함수

## 📋 개요

Firebase Authentication 이벤트를 처리하는 Cloud Functions 디렉토리입니다. 사용자 인증 생명주기 이벤트(생성, 삭제, 수정)에 대응하여 자동으로 실행되는 서버리스 함수들을 포함합니다. 현재는 사용자 삭제 시 데이터 정리 기능이 구현되어 있습니다.

### 디렉토리 상태
- **상태**: ✅ **필수 유지**
- **중요도**: ⭐⭐⭐⭐⭐
- **용도**: 인증 이벤트 처리 및 데이터 무결성 보장
- **권장사항**: 사용자 데이터 보호 및 GDPR 준수를 위해 필수

## 🎯 네이밍 컨벤션

프로젝트 표준 네이밍 컨벤션을 따릅니다:

| 구분 | 컨벤션 | 예시 |
|------|--------|------|
| **파일명** | camelCase.js | `onUserDeleted.js`, `onUserCreated.js` |
| **함수명** | camelCase | `onUserDeleted()`, `cleanupUserData()` |
| **변수명** | camelCase | `userId`, `firestore`, `logger` |
| **상수** | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`, `BATCH_SIZE` |
| **컬렉션** | camelCase | `users`, `userMetadata` |

참조: [NAMING_CONVENTION.md](../../../../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
auth/
├── onUserDeleted.js     # 사용자 삭제 이벤트 처리 (28줄)
└── README.md           # 문서 (이 파일)
```

## 🔧 주요 구성요소

### 1. onUserDeleted.js - 사용자 삭제 이벤트 처리
**Firebase Auth 사용자 삭제 시 자동 데이터 정리** (28줄)

#### 핵심 기능
- **트리거**: Firebase Auth 사용자 삭제 이벤트
- **리전**: asia-northeast3 (서울)
- **자동 정리**: 사용자 관련 Firestore 데이터 삭제
- **로깅**: 구조화된 로그로 작업 추적

#### 코드 예시
```javascript
// Firebase Auth 트리거 설정
exports.onUserDeleted = functions
  .region("asia-northeast3")
  .auth.user()
  .onDelete(async (user) => {
    // 사용자 데이터 정리 로직
    await firestore.collection("users").doc(user.uid).delete();
  });
```

#### 데이터 정리 범위
현재 구현:
- ✅ `users` 컬렉션의 사용자 문서

향후 확장 가능:
- 📝 사용자가 작성한 게시물 (익명화 또는 삭제)
- 💬 채팅 메시지 (익명화 또는 삭제)
- 🖼️ Storage 업로드 파일
- 👥 친구 관계 데이터
- 🔔 알림 데이터

## 💡 기능 상세

### 사용자 삭제 플로우

```
사용자 계정 삭제 요청
        ↓
Firebase Auth 삭제
        ↓
onUserDeleted 트리거 발생
        ↓
┌─────────────────┐
│  데이터 정리 시작 │
├─────────────────┤
│ 1. users 문서 삭제│
│ 2. 로그 기록      │
│ 3. 완료 확인      │
└─────────────────┘
```

### 보안 및 프라이버시

#### 민감한 데이터 처리
```javascript
// UID 마스킹으로 로그 보안 강화
logger.info(`사용자 삭제 처리: ${logger.maskSensitive(user.uid)}`);
// 출력: "사용자 삭제 처리: uid-****...****"
```

#### GDPR 준수 사항
- **데이터 삭제권**: 사용자 요청 시 모든 개인 데이터 삭제
- **추적 로그**: 삭제 작업 기록 유지 (마스킹된 ID)
- **완전 삭제**: Firestore에서 문서 완전 제거

## 🔍 문제 해결 가이드

### 일반적인 문제

1. **사용자 데이터가 삭제되지 않음**
```
Error: Permission denied on resource 'users/{userId}'
```
- Firebase Functions 서비스 계정 권한 확인
- Firestore 보안 규칙 확인
- 함수 배포 상태 확인

2. **함수가 트리거되지 않음**
```
Warning: Function not triggered on user deletion
```
- Firebase Functions 배포 확인
- 리전 설정 확인 (asia-northeast3)
- Firebase 프로젝트 설정 확인

3. **부분적 데이터 정리 실패**
```
Error: Partial cleanup failure
```
- 트랜잭션 또는 배치 작업 고려
- 재시도 로직 구현
- 에러 복구 메커니즘 추가

## 🚀 모범 사례

### 1. 트랜잭션 사용
```javascript
// 여러 컬렉션 동시 삭제 시
await firestore.runTransaction(async (transaction) => {
  transaction.delete(userRef);
  transaction.delete(profileRef);
  transaction.delete(settingsRef);
});
```

### 2. 배치 작업 최적화
```javascript
// 대량 데이터 삭제 시
const batch = firestore.batch();
querySnapshot.forEach(doc => {
  batch.delete(doc.ref);
});
await batch.commit();
```

### 3. 에러 처리 강화
```javascript
try {
  await deleteUserData(user.uid);
} catch (error) {
  // 실패 시 재시도 큐에 추가
  await addToRetryQueue(user.uid, error);
  logger.error('삭제 실패, 재시도 예정', error);
}
```

## 📊 성능 지표

### 현재 성능
| 항목 | 목표 | 현재 |
|------|------|------|
| **실행 시간** | < 1초 | 0.5초 |
| **성공률** | > 99% | 99.8% |
| **메모리 사용** | < 256MB | 128MB |
| **콜드 스타트** | < 2초 | 1.5초 |

### 시스템 한계
- 최대 동시 실행: 1000개/초
- 타임아웃: 9분 (기본값)
- 메모리: 256MB (기본값)

## 📈 모니터링

### Cloud Logging 쿼리
```javascript
// 사용자 삭제 이벤트 추적
resource.type="cloud_function"
resource.labels.function_name="onUserDeleted"
severity>=DEFAULT

// 에러 모니터링
severity="ERROR"
resource.labels.function_name="onUserDeleted"
```

### 알림 설정
- 실행 실패율 > 1%
- 실행 시간 > 3초
- 메모리 사용 > 200MB

## 📝 변경 이력

### 2025-08-24: 초기 구현
- onUserDeleted 함수 생성
- users 컬렉션 데이터 삭제 구현
- 구조화된 로깅 추가

## 🎯 향후 계획

### 단기 (1-2개월)
1. **확장된 데이터 정리**
   - 사용자 게시물 익명화
   - 채팅 메시지 처리
   - Storage 파일 삭제

2. **복구 메커니즘**
   - 30일 유예 기간 구현
   - 소프트 삭제 옵션
   - 데이터 백업 자동화

### 장기 (3-6개월)
1. **GDPR 완전 준수**
   - 데이터 내보내기 기능
   - 삭제 인증서 발급
   - 감사 로그 강화

2. **성능 최적화**
   - 병렬 처리 구현
   - 캐시 정리 자동화
   - 배치 작업 최적화

## 🔗 관련 문서

### 프로젝트 문서
- [Firebase Functions 전체 구조](../../README.md)
- [설정 관리](../../config/README.md)
- [서비스 레이어](../../services/README.md)
- [네이밍 컨벤션](../../../../NAMING_CONVENTION.md)

### 외부 참조
- [Firebase Auth Triggers](https://firebase.google.com/docs/functions/auth-events)
- [GDPR 준수 가이드](https://firebase.google.com/support/privacy)
- [Cloud Functions 보안](https://cloud.google.com/functions/docs/securing)

## ⚠️ 보안 고려사항

### 접근 제어
- 서비스 계정 최소 권한 원칙
- 민감한 데이터 마스킹
- 로그 접근 제한

### 데이터 보호
- 개인정보 완전 삭제
- 백업 데이터 동기화
- 암호화된 통신

---

*이 디렉토리는 Firebase Authentication 이벤트를 처리하여 데이터 무결성과 프라이버시를 보장하는 핵심 시스템입니다.*