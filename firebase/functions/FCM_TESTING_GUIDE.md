# 📱 FCM 실기기 테스트 가이드

**Date**: 2025-01-20
**Status**: Ready for Testing
**Version**: 1.0.0

## ✅ 사전 준비 완료 사항

### Phase 1-4 완료
- [x] FCM 패키지 도입 및 설정
- [x] NotificationQueueService 서비스 레이어 분리
- [x] Notifications Feature Clean Architecture 적용
- [x] Firebase Functions FCM 전송 로직 추가
- [x] Firebase Functions 배포 (11개 활성 함수)
- [x] FCM 토큰 Firestore 저장 구현
- [x] NotificationOverlayProvider 초기화 추가

### FCM 아키텍처 구성
```
FCMService (Singleton)
    ↓ 토큰 관리, 메시지 수신
Global NotificationQueueService
    ↓ FCM + Firestore 통합
NotificationOverlayProvider
    ↓ 인앱 오버레이 표시
VotingNotificationDialog
```

---

## 🔧 테스트 환경 설정

### 1. iOS 실기기 빌드
```bash
cd /Users/g_black/versus-cursor

# 1. Clean build
flutter clean
flutter pub get

# 2. iOS 빌드
flutter build ios --release

# 3. Xcode에서 실기기 연결 후 빌드
# - Apple Developer 계정 필요
# - Signing & Capabilities 확인
# - Push Notifications 권한 활성화
# - Background Modes > Remote notifications 활성화
```

### 2. Android 실기기 빌드
```bash
# 1. APK 빌드
flutter build apk --release

# 또는 App Bundle (Play Store용)
flutter build appbundle --release

# 2. 실기기에 설치
adb install build/app/outputs/flutter-apk/app-release.apk

# 3. Manifest 권한 확인 (android/app/src/main/AndroidManifest.xml)
# - POST_NOTIFICATIONS (Android 13+)
# - RECEIVE_BOOT_COMPLETED
# - INTERNET
```

### 3. Firebase Console 설정 확인
```
1. Firebase Console → Project Settings
2. General → Your apps
3. iOS: GoogleService-Info.plist 등록 확인
4. Android: google-services.json 등록 확인
5. Cloud Messaging → Server key 확인 (Functions에서 사용)
```

---

## 🧪 테스트 시나리오

### 시나리오 1: FCM 토큰 저장 확인 ✅

**목표**: 앱 설치 후 FCM 토큰이 Firestore에 정상 저장되는지 확인

**Steps**:
1. 앱 삭제 후 재설치 (Clean Install)
2. 계정 생성 또는 로그인
3. 알림 권한 요청 → **허용** 선택
4. Firebase Console → Firestore Database 접속
5. `users/{userId}` 문서 확인
6. `fcmToken` 필드 존재 여부 확인

**예상 결과**:
```json
{
  "fcmToken": "eXYZ123...", // FCM 토큰 문자열 (100+ 글자)
  "displayName": "테스트유저",
  "email": "test@example.com",
  ...
}
```

**실패 시 확인사항**:
- [ ] FCMService.initialize() 호출 확인 (lib/app/app.dart:66-68)
- [ ] NotificationContract.initializeNotifications() 로그 확인
- [ ] FCM 토큰 생성 로그: `[FCMService] FCM Token: ...`
- [ ] Firestore 저장 로그: `[FCMService] FCM token saved to Firestore for user: ...`

---

### 시나리오 2: 투표 알림 전송 및 수신 ✅

**목표**: 질문 생성 시 AI 타겟팅으로 알림이 정상 전송되고 수신되는지 확인

**Prerequisites**:
- 두 개의 실기기 필요 (발신자, 수신자)
- 또는 한 기기 + Firebase Functions 로그 확인

**Steps (발신자)**:
1. 앱에서 질문 생성 (A vs B)
2. 타겟 모드 선택: **Quick Collection** (AI 추천)
3. 타겟 인원: 10명
4. 질문 제출

**Steps (수신자)**:
5. 앱을 백그라운드 상태로 전환 (Home 버튼)
6. **5-10초 대기** (Firebase Functions 처리 시간)
7. 시스템 트레이에 알림 도착 확인
8. 알림 터치하여 앱 진입
9. **인앱 오버레이(VotingNotificationDialog) 표시 확인**

**예상 결과**:
```yaml
Firebase Functions (발신자):
  - onPostCreatedSendNotifications 트리거 ✅
  - AI 사용자 매칭 (Gemini 1.5 Pro) ✅
  - FCM 메시지 전송 ✅
  - notifications 컬렉션 저장 ✅

실기기 (수신자):
  - 시스템 트레이 알림 표시 ✅
  - FCMService.messageStream 수신 ✅
  - NotificationQueueService 처리 ✅
  - NotificationOverlayProvider 구독 ✅
  - VotingNotificationDialog 표시 ✅
```

**실패 시 확인사항**:
- [ ] Firebase Functions 로그 확인:
  ```bash
  firebase functions:log --only onPostCreatedSendNotifications
  ```
- [ ] FCM 메시지 수신 로그: `[FCMService] Foreground message received: ...`
- [ ] NotificationQueue 처리 로그: `[NotificationQueueService] FCM 메시지 수신: ...`
- [ ] OverlayProvider 로그: `[NotificationOverlayProvider] Received notification: ...`

---

### 시나리오 3: 인앱 오버레이 투표 기능 ✅

**목표**: 오버레이에서 직접 투표가 정상 작동하는지 확인

**Steps**:
1. 시나리오 2에서 표시된 VotingNotificationDialog 확인
2. A 또는 B 옵션 선택
3. **투표** 버튼 클릭
4. 로딩 표시 확인
5. 투표 완료 후 오버레이 자동 닫힘 확인

**예상 결과**:
```yaml
UI:
  - 투표 옵션 선택 가능 ✅
  - 로딩 인디케이터 표시 ✅
  - 오버레이 자동 닫힘 ✅

Backend:
  - posts/{postId}/votes/{userId} 생성 ✅
  - posts/{postId}.votesA 또는 votesB 증가 ✅
  - notifications/{notificationId} 상태 업데이트 ✅
```

**실패 시 확인사항**:
- [ ] VoteService 로그 확인
- [ ] Firestore votes 서브컬렉션 생성 확인
- [ ] posts 문서 votesA/votesB 카운트 증가 확인

---

### 시나리오 4: 백그라운드/종료 상태 알림 ✅

**목표**: 앱이 백그라운드/종료 상태에서도 알림이 정상 수신되는지 확인

**Steps (백그라운드)**:
1. 앱 실행 후 Home 버튼으로 백그라운드 전환
2. 다른 사용자가 질문 생성 (타겟에 본인 포함)
3. 시스템 트레이에 알림 도착 확인
4. 알림 터치하여 앱 재진입
5. 인앱 오버레이 표시 확인

**Steps (종료 상태)**:
1. 앱 완전 종료 (Task Manager에서 종료)
2. 다른 사용자가 질문 생성 (타겟에 본인 포함)
3. 시스템 트레이에 알림 도착 확인
4. 알림 터치하여 앱 시작
5. 앱 시작 후 투표 화면으로 자동 이동 확인

**예상 결과**:
```yaml
백그라운드:
  - FirebaseMessaging.onMessageOpenedApp 트리거 ✅
  - 앱 재진입 후 오버레이 표시 ✅

종료 상태:
  - FirebaseMessaging.getInitialMessage() 호출 ✅
  - 앱 시작 후 투표 화면 이동 ✅
```

**실패 시 확인사항**:
- [ ] iOS: Background Modes 설정 확인
- [ ] Android: RECEIVE_BOOT_COMPLETED 권한 확인
- [ ] FCMService._handleBackgroundMessage() 로그 확인

---

### 시나리오 5: 다중 알림 큐 처리 ✅

**목표**: 여러 알림이 동시에 도착해도 순차적으로 정상 표시되는지 확인

**Steps**:
1. 여러 사용자가 동시에 질문 생성 (타겟에 본인 포함)
2. 3-5개 알림이 거의 동시에 도착
3. 첫 번째 오버레이 표시 확인
4. 투표 또는 닫기 후 두 번째 오버레이 자동 표시 확인
5. 모든 알림이 순차적으로 표시되는지 확인

**예상 결과**:
```yaml
NotificationQueueService:
  - 알림 큐에 순차 저장 ✅
  - 중복 제거 (postId 기반) ✅
  - 하나씩 순차 표시 ✅
  - 사용자 액션 후 다음 알림 표시 ✅
```

**실패 시 확인사항**:
- [ ] NotificationQueueService._processQueue() 로그
- [ ] GlobalNotificationManager 큐 관리 로그
- [ ] 중복 알림 표시 여부 확인

---

## 📊 테스트 체크리스트

### 기본 기능
- [ ] FCM 토큰 Firestore 저장 확인
- [ ] 알림 권한 요청 및 허용
- [ ] 시스템 트레이 알림 표시
- [ ] 앱 포어그라운드 상태 알림 수신
- [ ] 앱 백그라운드 상태 알림 수신
- [ ] 앱 종료 상태 알림 수신

### 인앱 오버레이
- [ ] VotingNotificationDialog 정상 표시
- [ ] 이미지/비디오 미디어 로드
- [ ] A/B 옵션 선택 가능
- [ ] 투표 버튼 작동
- [ ] 투표 완료 후 오버레이 닫힘
- [ ] 닫기 버튼 작동

### 알림 큐
- [ ] 다중 알림 순차 표시
- [ ] 중복 알림 필터링
- [ ] 사용자 액션 후 다음 알림 표시

### 투표 시스템
- [ ] votes 서브컬렉션 생성
- [ ] votesA/votesB 카운트 증가
- [ ] 중복 투표 방지
- [ ] 투표 완료 상태 업데이트

---

## 🐛 트러블슈팅

### 문제 1: FCM 토큰이 Firestore에 저장되지 않음

**원인**:
- FCMService 초기화 실패
- 알림 권한 거부됨
- Firebase 프로젝트 설정 오류

**해결 방법**:
1. 앱 로그 확인:
   ```
   [FCMService] Initializing FCM Service
   [FCMService] FCM Token: ...
   [FCMService] FCM token saved to Firestore for user: ...
   ```
2. 알림 권한 재요청:
   - 설정 → 앱 → 알림 → 허용
3. GoogleService-Info.plist / google-services.json 재확인

---

### 문제 2: 알림이 도착하지 않음

**원인**:
- Firebase Functions 미배포
- AI 타겟팅에서 제외됨
- FCM 토큰 만료

**해결 방법**:
1. Firebase Functions 로그 확인:
   ```bash
   firebase functions:log --limit 50
   ```
2. 타겟 모드를 **Public**으로 변경 테스트
3. FCM 토큰 재발급:
   - 앱 재설치 또는 로그아웃/로그인

---

### 문제 3: 인앱 오버레이가 표시되지 않음

**원인**:
- NotificationOverlayProvider 미초기화 (이제 수정됨 ✅)
- Navigator context 없음
- showNotificationStream 구독 실패

**해결 방법**:
1. NotificationOverlayProvider 로그 확인:
   ```
   [VersusApp] 알림 오버레이 프로바이더 시작
   [NotificationOverlayProvider] Starting notification overlay listener
   [NotificationOverlayProvider] Received notification: ...
   ```
2. app.dart 코드 확인:
   ```dart
   _overlayProvider = GetIt.instance<NotificationOverlayProvider>();
   _overlayProvider!.startListening();
   ```

---

### 문제 4: 투표가 저장되지 않음

**원인**:
- Firestore Rules 권한 오류
- VoteService 로직 에러
- 중복 투표 방지 로직 작동

**해결 방법**:
1. Firestore Rules 확인:
   ```javascript
   match /posts/{postId}/votes/{userId} {
     allow create: if request.auth.uid == userId;
   }
   ```
2. VoteService 로그 확인
3. 이미 투표한 게시물인지 확인

---

## 📈 성능 모니터링

### Firebase Console에서 확인
1. **Cloud Functions**:
   - 실행 횟수
   - 평균 실행 시간
   - 에러율

2. **Cloud Messaging**:
   - 전송 성공률
   - 오픈율

3. **Firestore**:
   - 읽기/쓰기 횟수
   - 데이터 사용량

### 앱 로그에서 확인
```bash
# iOS
flutter logs --device-id={DEVICE_ID}

# Android
adb logcat | grep "Flutter\|FCM\|Notification"
```

---

## ✅ 테스트 완료 기준

### 최소 요구사항
- [ ] 모든 테스트 시나리오 통과
- [ ] 3가지 앱 상태 모두 알림 수신 확인
- [ ] 인앱 오버레이 정상 작동
- [ ] 투표 기능 정상 작동
- [ ] 에러 없이 24시간 안정성 테스트

### 최적화 목표
- [ ] FCM 토큰 저장: < 2초
- [ ] 알림 도착 시간: < 5초
- [ ] 오버레이 표시 시간: < 1초
- [ ] 투표 저장 시간: < 2초

---

## 📝 테스트 결과 보고 템플릿

```markdown
# FCM 테스트 결과 보고서

**테스트 일자**: YYYY-MM-DD
**테스터**: 이름
**기기**: iPhone 13 Pro / Galaxy S22
**OS 버전**: iOS 17.2 / Android 14

## 테스트 결과 요약
- 총 시나리오: 5개
- 통과: X개
- 실패: X개
- 보류: X개

## 시나리오별 결과

### ✅ 시나리오 1: FCM 토큰 저장
- **결과**: 통과
- **소요시간**: 1.5초
- **비고**: 정상 작동

### ❌ 시나리오 2: 투표 알림 전송
- **결과**: 실패
- **문제**: 오버레이 표시 안 됨
- **에러 로그**: ...
- **재현 방법**: ...

...

## 개선 제안사항
1. ...
2. ...

## 첨부 자료
- 스크린샷
- 로그 파일
- 화면 녹화
```

---

## 🎯 다음 단계

테스트 완료 후:
1. [ ] 테스트 결과 보고서 작성
2. [ ] 발견된 버그 수정
3. [ ] 성능 최적화
4. [ ] 프로덕션 배포 준비
5. [ ] 사용자 피드백 수집

---

**✨ 모든 준비가 완료되었습니다! 실기기에서 테스트를 시작하세요!**
