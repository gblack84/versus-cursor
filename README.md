# Versus Space

AI 기반 투표 및 소셜 플랫폼 - A vs B 형식의 비교 콘텐츠를 통한 의견 공유 커뮤니티

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (stable channel)
- Node.js 18+
- Firebase CLI
- Android Studio / VS Code

### Installation
```bash
# Clone repository
git clone https://github.com/your-org/versus-space.git
cd versus-space

# Install Flutter dependencies
flutter pub get

# Install Firebase Functions dependencies
cd firebase/functions
npm install
cd ../..

# Run the app
flutter run
```

### Environment Setup
```bash
# Configure Firebase
firebase login
firebase use versus-space-1lwwiw

# Set API keys
firebase functions:config:set \
  gemini.api_key="YOUR_KEY" \
  perspective.api_key="YOUR_KEY"
```

## 🎯 주요 기능

### 핵심 기능
- **📊 A vs B 투표**: 텍스트, 이미지, 비디오를 활용한 비교 콘텐츠
- **🤖 AI 콘텐츠 검열**: Gemini AI와 Cloud Vision API를 통한 안전한 콘텐츠 관리
- **🎯 스마트 타겟팅**: AI 기반 사용자 매칭으로 관련성 높은 투표 전달
- **💬 실시간 채팅**: 투표 카드를 통한 메시징 시스템
- **🔔 실시간 알림**: Firebase를 활용한 즉각적인 투표 요청 알림

### 기술 스택
- **Frontend**: Flutter (Native, FlutterFlow 마이그레이션 완료)
- **Backend**: Firebase (Firestore, Functions, Storage, Auth)
- **AI Services**: Gemini AI, Cloud Vision API, Perspective API
- **Caching**: 3-Layer 시스템 (Memory → Hive → Firestore)
- **Search**: Algolia

## 📁 프로젝트 구조

### Feature-First Architecture
프로젝트는 **Feature-First Architecture**와 **Clean Architecture** 원칙을 따릅니다.

```
versus-space/
├── lib/
│   ├── main.dart              # 애플리케이션 진입점
│   │
│   ├── features/              # 🎯 기능별 모듈 (Clean Architecture)
│   │   ├── auth/              # 인증 기능
│   │   ├── chat/              # 채팅 기능
│   │   ├── posts/             # 게시물 기능
│   │   ├── profile/           # 프로필 기능
│   │   ├── search/            # 검색 기능
│   │   ├── voting/            # 투표 기능
│   │   └── notifications/     # 알림 기능
│   │
│   ├── core/                  # 🔧 전역 공통 요소
│   │   ├── design_system/     # 디자인 시스템 (컴포넌트, 토큰)
│   │   ├── theme/             # 앱 테마 설정
│   │   ├── localization/      # 다국어 지원
│   │   ├── utils/             # 유틸리티 함수
│   │   └── widgets/           # 공통 위젯
│   │
│   ├── backend/               # 🗄️ 전역 백엔드 레이어
│   │   ├── firebase/          # Firebase 설정 및 유틸리티
│   │   ├── models/            # 데이터 모델 (Firestore 스키마)
│   │   ├── api/               # 외부 API 통합 (Algolia 등)
│   │   └── repositories/      # 데이터 접근 추상화
│   │
│   ├── services/              # 🛠️ 전역 서비스 레이어
│   │   ├── cache/             # 3-Layer 캐싱 시스템
│   │   ├── moderation/        # 콘텐츠 검열 서비스
│   │   ├── logger/            # 로깅 서비스
│   │   └── validators/        # 유효성 검증
│   │
│   └── app/                   # 🚀 앱 설정 및 진입점
│       ├── router/            # 라우팅 설정
│       ├── state/             # 전역 상태 관리
│       └── di/                # 의존성 주입
│
├── firebase/                  # ☁️ Backend 인프라
│   ├── functions/             # Cloud Functions (12개 배포)
│   ├── firestore.rules        # Firestore 보안 규칙
│   └── storage.rules          # Storage 보안 규칙
│
└── docs/                      # 📚 프로젝트 문서
    ├── guides/                # 개발 가이드
    └── archive/               # 아카이브된 문서
```

### 각 Feature의 내부 구조 (Clean Architecture)
```
features/[feature_name]/
├── data/                      # 데이터 레이어
│   ├── datasources/          # 원격/로컬 데이터 소스
│   ├── repositories/         # Repository 구현체
│   └── services/             # Feature 전용 서비스
│
├── domain/                    # 도메인 레이어 (비즈니스 로직)
│   ├── models/               # 도메인 모델
│   ├── usecases/             # 유스케이스 (비즈니스 규칙)
│   └── repositories/         # Repository 인터페이스
│
└── presentation/              # 프레젠테이션 레이어 (UI)
    ├── screens/              # 화면 위젯
    ├── widgets/              # UI 컴포넌트
    └── providers/            # 상태 관리
```

## 📚 Documentation

### 핵심 문서
- [기술 상세 문서](./CLAUDE.md) - 전체 기술 스택 및 구현 상세
- [시스템 아키텍처](./ARCHITECTURE.md) - 시스템 구조 및 데이터 플로우
- [변경 이력](./CHANGELOG.md) - 버전별 변경사항
- [네이밍 컨벤션](./docs/guides/NAMING_CONVENTION.md) - 코딩 표준

### 개발 가이드
- [Flutter 개발 환경](./docs/TMUX_FLUTTER_GUIDE.md)
- [투표 알림 시스템](./docs/VOTE_NOTIFICATION_SYSTEM.md)
- [문서 관리 가이드](./docs/DOCUMENTATION_GUIDE.md)

### API & Backend
- [Firebase Functions](./firebase/functions/README.md)
- [Firestore 스키마](./lib/backend/schema/README.md)

## 🔧 Development

### Build Commands
```bash
# Development
flutter run

# Build for platforms
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
flutter build macos        # macOS

# Run tests
flutter test

# Analyze code
flutter analyze
```

### Firebase Deployment
```bash
# Deploy functions
firebase deploy --only functions

# Deploy security rules
firebase deploy --only firestore:rules

# Deploy everything
firebase deploy
```

## 🌟 Recent Updates

### v2.1.0 (2025-08-10)
- Chat System v2 마이그레이션 완료
- 3-Layer 캐싱 시스템 구현
- 투표 메시지 컴포넌트 통합

### v2.0.0 (2025-01-06)  
- AI 기반 알림 시스템 구현
- 실시간 투표 동기화
- 성능 최적화 (60% 개선)

자세한 내용은 [CHANGELOG.md](./CHANGELOG.md) 참조

## 📊 프로젝트 현황

| 항목 | 상태 |
|------|------|
| **플랫폼** | iOS, Android, Web, macOS |
| **코드 규모** | 50,000+ 줄 |
| **Cloud Functions** | 12개 배포 |
| **Firestore 컬렉션** | 36개 |
| **AI 서비스** | 4개 통합 |
| **캐시 적중률** | 95%+ |
| **동시 처리** | 1000명 투표 (<60초) |

## 🤝 Contributing

프로젝트 기여 가이드라인은 [CONTRIBUTING.md](./docs/CONTRIBUTING.md) 참조

## 📄 License

Copyright © 2025 Versus Space Team. All rights reserved.

---

**Project**: Versus Space  
**Version**: 2.1.0  
**Last Updated**: 2025-08-24  
**Status**: Production