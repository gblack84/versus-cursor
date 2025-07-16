# versus-space

A new Flutter project.

## Getting Started

FlutterFlow projects are built to run on the Flutter _stable_ release.

## TODO: Production 배포 전 필수 작업

### 1. Firestore 인덱스 생성

#### content_validations 컬렉션 복합 인덱스
- **용도**: 사용자의 최근 30일간 거부된 게시물 조회
- **필요한 필드**:
  - `userId` (오름차순)
  - `geminiResult.isValid` (오름차순)
  - `timestamp` (내림차순)
- **생성 방법**: 
  1. Firebase Console > Firestore > 인덱스 탭
  2. "인덱스 만들기" 클릭
  3. 위 필드들을 순서대로 추가
  4. 또는 에러 메시지에 나온 URL 클릭하여 자동 생성
- **관련 함수**: `firebase/functions/index.js`의 `getUserPostingHistory()`

### 2. 인덱스 생성 후 코드 복원
```javascript
// firebase/functions/index.js의 getUserPostingHistory 함수에서
// 주석 처리된 Production 코드를 다시 활성화
```
