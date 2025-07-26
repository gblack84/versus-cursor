# 투표 알림 시스템 테스트 가이드

이 문서는 투표 알림 시스템의 전체 플로우를 테스트하는 방법을 설명합니다.

## 테스트 환경 설정

### 1. 의존성 설치
```bash
cd firebase/functions
npm install
```

### 2. Firebase 에뮬레이터 설치 (전역)
```bash
npm install -g firebase-tools
```

### 3. 에뮬레이터 초기화
```bash
firebase init emulators
# Firestore, Auth, Functions 선택
```

## 테스트 실행 방법

### 방법 1: 에뮬레이터와 함께 실행 (권장)
```bash
npm run test:emulator
```

### 방법 2: 수동으로 에뮬레이터 시작 후 테스트
```bash
# 터미널 1
firebase emulators:start --only firestore,functions,auth

# 터미널 2
npm test
```

### 방법 3: 특정 시나리오만 테스트
```bash
# 테스트 모드 플로우만
npx mocha test/vote-flow-test.js --grep "테스트 모드"

# 성능 테스트만
npx mocha test/vote-flow-test.js --grep "성능 테스트"
```

### 방법 4: 와치 모드로 실행 (개발 중)
```bash
npm run test:watch
```

## 테스트 시나리오

### 시나리오 1: 테스트 모드 전체 플로우
1. 테스터가 투표 생성
2. 자동으로 본인에게 알림 전송
3. 투표 참여
4. 자동 결과 처리 및 알림

### 시나리오 2: 멀티 사용자 동시 투표
1. 퍼블릭 모드로 투표 생성
2. 5명에게 동시 알림 전송
3. 동시 투표 시뮬레이션
4. 결과 집계 검증

### 시나리오 3: 에지 케이스
- 투표 거부 처리
- 24시간 타임아웃 처리

### 성능 테스트
- 100명 동시 투표 처리
- 처리 시간 측정
- 평균 응답 시간 계산

## 테스트 결과 해석

### 성공적인 테스트 결과
```
✓ 투표 생성 → 알림 전송 → 투표 참여 → 결과 처리 (2538ms)
✓ 여러 사용자가 동시에 투표하는 경우 (1823ms)
✓ 투표 거부 처리 (523ms)
✓ 24시간 타임아웃 처리
✓ 대규모 투표 처리 (100명 동시) (8234ms)

5 passing (15s)
```

### 주요 성능 지표
- 단일 투표 처리: < 100ms
- 100명 동시 투표: < 10s
- 평균 투표 시간: < 100ms/vote

## 디버깅 팁

### 로그 확인
```bash
# Functions 로그
firebase functions:log

# 에뮬레이터 UI에서 확인
http://localhost:4000
```

### 일반적인 문제 해결

1. **에뮬레이터 포트 충돌**
   - 기본 포트: Firestore(8080), Auth(9099), Functions(5001)
   - 포트 변경: `firebase.json`에서 설정

2. **테스트 타임아웃**
   - 기본 타임아웃: 60초
   - 필요시 증가: `--timeout 120000`

3. **데이터 정리 실패**
   - 테스트 후 수동 정리: 에뮬레이터 UI에서 삭제

## 프로덕션 테스트 주의사항

**절대 프로덕션 환경에서 직접 실행하지 마세요!**

프로덕션 테스트가 필요한 경우:
1. 별도의 테스트 프로젝트 생성
2. 테스트 사용자 계정 사용
3. 테스트 후 데이터 정리 필수

## CI/CD 통합

### GitHub Actions 예시
```yaml
name: Test Vote Flow
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '20'
      - run: npm ci
        working-directory: firebase/functions
      - run: npm run test:emulator
        working-directory: firebase/functions
```

## 추가 테스트 계획

### 단위 테스트
- [ ] processVoteCompletion 함수 단위 테스트
- [ ] AI 타겟팅 로직 테스트
- [ ] 알림 생성 로직 테스트

### 통합 테스트
- [ ] Flutter 앱과의 E2E 테스트
- [ ] 실시간 업데이트 테스트
- [ ] 네트워크 오류 시나리오

### 부하 테스트
- [ ] 1000명 동시 접속
- [ ] 초당 100개 투표 처리
- [ ] 메모리 사용량 모니터링