# Versus Space

AI 기반 투표 및 소셜 플랫폼 - A vs B 형식의 비교 콘텐츠를 통한 의견 공유 커뮤니티

## 프로젝트 소개

Versus Space는 사용자들이 A vs B 형식의 비교 질문을 만들고, 투표하며, 의견을 공유할 수 있는 소셜 미디어 플랫폼입니다. AI 기술을 활용하여 콘텐츠 검열, 사용자 매칭, 맞춤형 알림 등의 기능을 제공합니다.

### 주요 기능
- 📊 **A vs B 투표**: 텍스트, 이미지, 비디오를 활용한 비교 콘텐츠
- 🤖 **AI 콘텐츠 검열**: Gemini AI와 Cloud Vision API를 통한 안전한 콘텐츠 관리
- 🎯 **스마트 타겟팅**: AI 기반 사용자 매칭으로 관련성 높은 투표 전달
- 💬 **실시간 알림**: Firebase를 활용한 실시간 투표 요청 알림
- 👥 **소셜 기능**: 좋아요, 댓글, 친구 시스템

## 최근 업데이트 (2025-07-20)

### 🚀 AI 기반 알림 시스템 구축
- **Genkit 프레임워크 통합**: Google의 최신 AI 개발 프레임워크 도입
- **스마트 사용자 매칭**: Gemini 1.5 Pro를 활용한 AI 추천 시스템
- **실시간 알림 서비스**: Flutter 앱과 Firebase Functions 연동
- **테스트 모드**: 관리자/테스터를 위한 개발 모드 지원

### 🛡️ 강화된 콘텐츠 검열
- **다단계 검증**: 텍스트(Perspective API) → AI 논리성(Gemini) → 이미지(Vision API)
- **실시간 피드백**: 검열 진행 상태 실시간 업데이트
- **사용자 친화적 UI**: 검열 결과에 따른 명확한 가이드 제공

## 기술 스택

### Frontend
- **Framework**: Flutter (Dart)
- **State Management**: Provider
- **Navigation**: GoRouter
- **UI Components**: Custom widgets + FlutterFlow 마이그레이션

### Backend
- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth (Email, Google, Apple, Phone, GitHub)
- **Storage**: Firebase Storage
- **Functions**: Firebase Cloud Functions (Node.js)
- **AI/ML**: Google Genkit, Gemini AI, Cloud Vision API

### 서비스 통합
- **검색**: Algolia
- **콘텐츠 검열**: Perspective API
- **이미지 처리**: ProImageEditor
- **비디오 처리**: flutter_native_video_trimmer

## 프로젝트 구조

```
versus-space/
├── lib/                          # Flutter 애플리케이션
│   ├── services/                 # 비즈니스 로직 서비스
│   │   ├── ai_moderation/       # AI 콘텐츠 검열
│   │   ├── notification_service.dart
│   │   └── target_audience_service.dart
│   ├── posts/                    # 게시물 관련 기능
│   ├── components/               # 재사용 가능한 UI 컴포넌트
│   └── main.dart                # 앱 진입점
│
├── firebase/                     # Firebase 설정 및 함수
│   └── functions/
│       ├── ai/                   # AI 시스템 (Genkit)
│       │   ├── config.js        # Genkit 설정
│       │   ├── contentModeration.js
│       │   └── userRecommendation.js
│       ├── notifications/        # 알림 시스템
│       │   ├── targetMatcher.js
│       │   └── notificationCreator.js
│       └── index.js             # Cloud Functions 진입점
│
├── assets/                       # 정적 리소스
├── ios/                         # iOS 플랫폼 설정
├── android/                     # Android 플랫폼 설정
└── web/                         # Web 플랫폼 설정
```

## 시작하기

### 필수 요구사항
- Flutter SDK (stable channel)
- Node.js 18+ (Firebase Functions)
- Firebase CLI
- 각 플랫폼별 개발 도구 (Xcode, Android Studio)

### 환경 설정

1. **프로젝트 클론**
   ```bash
   git clone [repository-url]
   cd versus-space
   ```

2. **Flutter 의존성 설치**
   ```bash
   flutter pub get
   ```

3. **Firebase 설정**
   ```bash
   # Firebase CLI 로그인
   firebase login
   
   # Functions 의존성 설치
   cd firebase/functions
   npm install
   ```

4. **환경 변수 설정**
   ```bash
   # Firebase Functions 환경 변수
   firebase functions:config:set \
     google.genai_api_key="YOUR_GEMINI_API_KEY" \
     perspective.api_key="YOUR_PERSPECTIVE_API_KEY"
   ```

5. **개발 서버 실행**
   ```bash
   # Flutter 앱 실행
   flutter run
   
   # Firebase 에뮬레이터 (선택사항)
   firebase emulators:start
   ```

## API 키 발급

### 필수 API
1. **Google AI (Gemini)**: [Google AI Studio](https://makersuite.google.com/app/apikey)
2. **Perspective API**: [Google Cloud Console](https://console.cloud.google.com)
3. **Cloud Vision API**: Firebase 프로젝트에서 자동 활성화

## 개발 가이드

### 브랜치 전략
- `flutterflow`: 메인 개발 브랜치
- `feature/*`: 기능 개발 브랜치
- `hotfix/*`: 긴급 수정 브랜치

### 코드 스타일
- Dart: `flutter analyze` 통과 필수
- JavaScript: ESLint 설정 준수
- 커밋 메시지: Conventional Commits 형식

### 테스트
```bash
# Flutter 테스트
flutter test

# Functions 테스트
cd firebase/functions
npm test
```

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

## 테스트 모드 사용법

### 관리자/테스터 계정 설정

1. **Firestore에서 사용자 role 설정**
   ```javascript
   // users_record 컬렉션
   {
     uid: "user_id",
     email: "admin@versus.test",
     role: "admin",  // 또는 "tester"
   }
   ```

2. **테스트 모드 활성화**
   - 관리자 또는 테스터 계정으로 로그인
   - 게시물 작성 시 타겟 오디언스에서 "테스트 모드" 선택
   - 설정한 수만큼 본인에게만 알림 전송

3. **테스트 시나리오**
   - UI/UX 플로우 검증
   - 알림 시스템 동작 확인
   - 다양한 타겟 수 테스트

## 문서

각 모듈별 상세 문서는 해당 디렉토리의 README.md를 참조하세요:

- [AI 시스템](/firebase/functions/ai/README.md)
- [알림 시스템](/firebase/functions/notifications/README.md)
- [서비스 레이어](/lib/services/README.md)
- [AI 검열 시스템](/lib/services/ai_moderation/README.md)

## 기여 가이드

1. 이슈 생성 또는 기존 이슈 확인
2. 기능 브랜치 생성 (`feature/issue-number-description`)
3. 변경사항 커밋 (Conventional Commits 형식)
4. Pull Request 생성
5. 코드 리뷰 및 머지

## 라이선스

이 프로젝트는 비공개 소프트웨어입니다. 무단 복제 및 배포를 금지합니다.

## 문의

프로젝트 관련 문의사항은 이슈 트래커를 통해 등록해주세요.
