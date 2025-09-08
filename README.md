# Versus Space

AI 기반 투표 및 소셜 플랫폼 - A vs B 형식의 비교 콘텐츠를 통한 의견 공유 커뮤니티

[![Architecture](https://img.shields.io/badge/Architecture-Feature--First-blue)](./FEATURE_ARCHITECTURE.md)
[![Clean Architecture](https://img.shields.io/badge/Clean%20Architecture-85%25-green)](./FEATURE_ARCHITECTURE.md)
[![Flutter](https://img.shields.io/badge/Flutter-3.0.0+-blue)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-orange)](https://firebase.google.com)

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

### Feature-First Architecture (85% 마이그레이션 완료)
프로젝트는 **Feature-First Architecture**와 **Clean Architecture** 원칙을 따릅니다.
- ✅ **Phase 1.1 진행 중**: 모놀리식 구조에서 Feature-First로 전환 (90% 완료)
- 📊 **준수율**: 85% (목표: 95%+)
- 🎯 **완료 예정**: 2025-01-10

```
versus-space/
├── lib/
│   ├── main.dart              # 애플리케이션 진입점
│   │
│   ├── features/              # 🎯 기능별 모듈 (Clean Architecture) ✅
│   │   ├── auth/              # 인증 기능 ✅ 완전 마이그레이션
│   │   ├── chat/              # 채팅 기능 ✅ 완전 마이그레이션
│   │   ├── posts/             # 게시물 기능 ✅ 완전 마이그레이션
│   │   ├── profile/           # 프로필 기능 ✅ 완전 마이그레이션
│   │   ├── search/            # 검색 기능 ✅ 완전 마이그레이션
│   │   ├── voting/            # 투표 기능 ✅ 완전 마이그레이션
│   │   └── notifications/     # 알림 기능 ✅ 완전 마이그레이션
│   │
│   ├── core/                  # 🔧 전역 공통 요소
│   │   ├── design_system/     # 디자인 시스템 (컴포넌트, 토큰)
│   │   ├── theme/             # 앱 테마 설정
│   │   ├── localization/      # 다국어 지원
│   │   ├── utils/             # 유틸리티 함수
│   │   └── widgets/           # 공통 위젯
│   │
│   ├── backend/               # ⚠️ 레거시 (2025-06-30 제거 예정)
│   │   ├── firebase/          # Firebase 설정 (core로 이동 중)
│   │   ├── models/            # ⚠️ Deprecated - features/*/data/models/ 사용
│   │   │   └── index.dart     # Backward compatibility (임시)
│   │   ├── api/               # 외부 API (features로 이동 중)
│   │   └── repositories/      # ⚠️ Deprecated - features/*/data/repositories/ 사용
│   │
│   ├── services/              # 🛠️ 전역 서비스 레이어
│   │   ├── cache/             # 3-Layer 캐싱 시스템
│   │   ├── moderation/        # 콘텐츠 검열 서비스
│   │   ├── logger/            # 로깅 서비스
│   │   └── validators/        # 유효성 검증
│   │
│   └── app/                   # 🚀 앱 설정 및 진입점
│       ├── router.dart        # GoRouter 라우팅 설정
│       ├── state/             # 전역 상태 관리 (Provider)
│       └── di.dart            # 의존성 주입 (GetIt)
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
│   ├── models/               # Firestore 모델 및 DTOs
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

## 📊 주요 데이터 모델 (Feature-First 구조)

### 모델 위치 변경 안내
모든 모델이 Feature별로 재구성되었습니다:

| 모델 | 기존 경로 (Deprecated) | 새로운 경로 |
|------|------------------------|-------------|
| **UsersModel** | `/backend/models/users_model.dart` | `/features/auth/data/models/users_model.dart` |
| **PostsModel** | `/backend/models/posts_model.dart` | `/features/posts/data/models/posts_model.dart` |
| **ChatsModel** | `/backend/models/chats_model.dart` | `/features/chat/data/models/chats_model.dart` |
| **MessagesModel** | `/backend/models/messages_model.dart` | `/features/chat/data/models/messages_model.dart` |
| **NotificationsModel** | `/backend/models/notifications_model.dart` | `/features/notifications/data/models/notifications_model.dart` |
| **CommentsModel** | `/backend/models/comments_model.dart` | `/features/posts/data/models/comments_model.dart` |

**Note**: Backward compatibility는 2025-06-30까지 `/backend/models/index.dart`를 통해 유지됩니다.

## 📚 Documentation

### 핵심 문서
- [Feature-First Architecture](./FEATURE_ARCHITECTURE.md) - 🆕 아키텍처 가이드 및 마이그레이션 상태
- [기술 상세 문서](./CLAUDE.md) - 전체 기술 스택 및 구현 상세
- [시스템 아키텍처](./docs/archive/backup-2025-08-24/ARCHITECTURE.md) - 시스템 구조 및 데이터 플로우
- [변경 이력](./CHANGELOG.md) - 버전별 변경사항
- [네이밍 컨벤션](./docs/guides/NAMING_CONVENTION.md) - 코딩 표준

### 개발 가이드
- [Flutter 개발 환경](./docs/TMUX_FLUTTER_GUIDE.md)
- [투표 알림 시스템](./docs/VOTE_NOTIFICATION_SYSTEM.md)
- [문서 관리 가이드](./docs/DOCUMENTATION_GUIDE.md)

### API & Backend
- [Firebase Functions](./firebase/functions/README.md)
- [마이그레이션 가이드](./lib/backend/MIGRATION_TASKS_PHASE_1_1.md) - 🆕 Feature-First 전환 진행 상황

## 🔄 Feature-First Architecture 마이그레이션

### 현재 진행 상황 (Phase 1.1)
- ✅ **Phase 1.1A**: 모델 구조 분해 완료
- ✅ **Phase 1.1B**: Repository 마이그레이션 완료  
- ✅ **Phase 1.1C**: Import 정리 (90% 완료)
- ⏳ **Phase 1.1D**: Backend 제거 (진행 중)
- ⏳ **Phase 1.1E**: Services 재구조화 (대기)

### 마이그레이션 가이드
```bash
# 기존 import (Deprecated)
import '/backend/models/users_model.dart';  # ❌

# 새로운 import (권장)
import '/features/auth/data/models/users_model.dart';  # ✅
```

자세한 내용은 [FEATURE_ARCHITECTURE.md](./FEATURE_ARCHITECTURE.md) 참조

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

### v3.0.0 (2025-01-08) - Feature-First Architecture
- 🏗️ Feature-First Architecture 마이그레이션 85% 완료
- 📦 모든 모델을 Feature별로 분해 및 이동
- 🔄 Repository 패턴 전체 적용
- 🎯 Clean Architecture 준수율 85% 달성
- ⚡ 아키텍처 위반 83.7% 감소 (196개 → 32개)

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
| **아키텍처** | Feature-First (85% 완료) |
| **Clean Architecture** | 85% 준수 |
| **Cloud Functions** | 12개 배포 |
| **Firestore 컬렉션** | 36개 |
| **AI 서비스** | 4개 통합 |
| **캐시 적중률** | 95%+ |
| **동시 처리** | 1000명 투표 (<60초) |
| **아키텍처 위반** | 32개 (목표: 0개) |

## 🚀 Quick Reference

### Architecture 체크리스트
```bash
# Architecture 위반 검사
grep -r "import.*'/backend/'" lib/features/ | wc -l  # 목표: 0

# Cross-feature imports 검사
for feature in lib/features/*/; do
  grep -r "import.*'/features/" "$feature" | grep -v $(basename "$feature")
done

# 파일 크기 검사
find lib -name "*.dart" -exec wc -l {} \; | sort -rn | head -10
```

### 주요 명령어
```bash
# 코드 분석
flutter analyze

# 테스트 실행
flutter test

# 의존성 그래프 생성
flutter pub deps --style=tree

# 빌드 최적화
flutter build apk --split-per-abi
```

## 🤝 Contributing

프로젝트 기여 가이드라인은 [CONTRIBUTING.md](./docs/CONTRIBUTING.md) 참조

## 📄 License

Copyright © 2025 Versus Space Team. All rights reserved.

---

**Project**: Versus Space  
**Version**: 3.0.0  
**Architecture**: Feature-First (85% 마이그레이션)  
**Last Updated**: 2025-01-08  
**Status**: Production (마이그레이션 진행 중)