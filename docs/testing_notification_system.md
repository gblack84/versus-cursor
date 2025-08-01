# 알림 시스템 테스트 가이드

## 1. 전체 플로우 테스트 순서

### 1.1 사전 준비
- 테스터 권한이 있는 계정으로 로그인
- 이미지 준비 (A박스, B박스용)

### 1.2 게시물 작성 플로우
1. **이미지 업로드**
   - A박스와 B박스에 각각 이미지 선택
   - 이미지 편집 (선택사항)
   
2. **텍스트 입력**
   - 질문 제목 입력
   - 설명 입력 (선택사항)
   - A/B 선택지 텍스트 입력

3. **다음 버튼 클릭**
   - AI 검증 진행
   - 검증 통과 시 타겟 오디언스 다이얼로그 표시

4. **타겟 오디언스 설정**
   - 테스트 모드 선택
   - 목표 수 설정 (기본값: 100)
   - 다음 → 다음 클릭

5. **게시물 저장**
   - Firestore에 게시물 저장
   - Firebase Functions 트리거 실행
   - 알림 생성 및 발송

## 2. 예상되는 로그 출력

### 2.1 Flutter 앱 로그
```
flutter: [_validateAllTexts] TargetAudienceDialog.show() 호출 전
flutter: [_validateAllTexts] TargetAudienceDialog.show() 반환값: {type: test, targetCount: 100, ...}
flutter: [_validateAllTexts] targetAudience 값 확인:
flutter: [_validateAllTexts]   - type: test
flutter: [_validateAllTexts]   - targetCount: 100
flutter: [_validateAllTexts] _saveToFirestore 호출 시작
flutter: [_saveToFirestore] ========== 게시물 저장 시작 ==========
flutter: [_saveToFirestore] Firestore에 게시물 저장 시작...
flutter: [_saveToFirestore] ✅ 게시물 저장 성공! ID: [POST_ID]
flutter: [_saveToFirestore] ========== 게시물 저장 완료 ==========
```

### 2.2 GlobalNotificationManager 로그
```
flutter: [GlobalNotificationManager] 새로운 알림 수신: 1개
flutter: [GlobalNotificationManager] 큐에 알림 추가: [POST_ID]
flutter: [GlobalNotificationManager] 알림 표시 시작: [POST_ID]
flutter: [GlobalNotificationManager] 투표 알림 표시
```

## 3. Firebase Functions 로그 확인 방법

### 3.1 Firebase Console에서 확인
1. [Firebase Console](https://console.firebase.google.com) 접속
2. 프로젝트 선택: `versus-space-1lwwiw`
3. 좌측 메뉴에서 **Functions** 클릭
4. **로그** 탭 클릭
5. 필터 설정:
   - 함수 이름: `onPostCreate`
   - 로그 레벨: 모든 레벨

### 3.2 Firebase CLI로 확인
```bash
# Firebase CLI 설치 (이미 설치되어 있다면 생략)
npm install -g firebase-tools

# 로그인
firebase login

# 실시간 로그 보기
firebase functions:log --project versus-space-1lwwiw

# 특정 함수 로그만 보기
firebase functions:log --only onPostCreate --project versus-space-1lwwiw

# 최근 100개 로그 보기
firebase functions:log -n 100 --project versus-space-1lwwiw
```

### 3.3 예상되는 Functions 로그
```
[onPostCreate] ========== 새 게시물 생성 감지 ==========
[onPostCreate] 게시물 ID: [POST_ID]
[onPostCreate] 타겟 오디언스: test
[onPostCreate] 목표 수: 100

[테스트 모드] ========== 테스트 모드 시작 ==========
[테스트 모드] 요청된 타겟 수: 100
[테스트 모드] 생성자 ID 확인: [USER_ID]

[알림 생성] ========== 알림 생성 시작 ==========
[알림 생성] 대상 사용자 수: 100명
[알림 생성] 게시물 ID: [POST_ID]
[알림 생성] 타겟 타입: test
[알림 생성] ✅ 100개의 알림이 성공적으로 생성되었습니다
```

## 4. 문제 해결

### 4.1 알림이 표시되지 않는 경우

1. **Flutter 앱 로그 확인**
   - `targetAudience`가 `null`인지 확인
   - `_saveToFirestore`가 호출되는지 확인
   - 게시물 ID가 생성되는지 확인

2. **Firebase Functions 로그 확인**
   - `onPostCreate` 함수가 트리거되는지 확인
   - 알림 생성 로그가 있는지 확인

3. **Firestore 데이터 확인**
   - `posts` 컬렉션에 게시물이 저장되었는지 확인
   - `targetAudience` 필드가 올바르게 저장되었는지 확인
   - `notifications` 컬렉션에 알림이 생성되었는지 확인

### 4.2 일반적인 문제와 해결책

- **문제**: 타겟 오디언스 다이얼로그 후 게시물이 저장되지 않음
  - **해결**: 로그에서 `targetAudience`가 `null`인지 확인

- **문제**: Firebase Functions가 트리거되지 않음
  - **해결**: Functions가 배포되어 있는지 확인 (`firebase deploy --only functions`)

- **문제**: 알림이 생성되었지만 표시되지 않음
  - **해결**: NotificationService가 올바른 사용자 ID로 리스닝하고 있는지 확인