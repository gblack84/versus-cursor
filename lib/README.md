# 📱 lib/ - Versus Space Flutter 애플리케이션 핵심 디렉토리

## 📋 개요

Versus Space는 A vs B 형식의 투표 기반 소셜 미디어 Flutter 애플리케이션입니다. 이 디렉토리는 FlutterFlow에서 네이티브 Flutter로 완전히 마이그레이션된 전체 애플리케이션 코드베이스를 포함합니다.

### 🏗️ 프로젝트 현황
- **총 디렉토리**: 96개 (하위 디렉토리 포함)
- **문서화 완료**: 96개 (100%) 🎉
- **코드 규모**: 약 50,000+ 줄
- **마이그레이션**: FlutterFlow → Native Flutter (2025-07-03 완료)
- **네이밍 컨벤션**: snake_case → camelCase (768개 필드, 2025-08-21 완료)

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준) - `chat_list_widget.dart`
- **클래스명**: PascalCase - `ChatListWidget`
- **필드명**: camelCase - `currentUserId`, `voteStartTime`
- **메서드명**: camelCase - `initializeState()`, `loadMessages()`
- 참조: [NAMING_CONVENTION.md](../NAMING_CONVENTION.md)

## 🏛️ 아키텍처 구조

```
lib/
├── 🚀 진입점
│   ├── main.dart                 # 앱 진입점, Provider 초기화
│   ├── app_state.dart           # 전역 상태 관리 (싱글톤 패턴)
│   └── index.dart               # 위젯 export 중앙 관리
│
├── 🔐 인증 시스템 (auth/)
│   ├── firebase_auth/           # Firebase Auth 통합
│   └── auth_manager.dart        # 인증 매니저
│
├── 🔥 백엔드 통합 (backend/)
│   ├── schema/                  # 44개 Firestore 모델
│   ├── firebase/                # Firebase 설정
│   ├── firebase_storage/        # 스토리지 관리
│   ├── api_requests/            # API 호출 관리
│   └── algolia/                 # 검색 엔진 통합
│
├── 🎨 UI 컴포넌트 (components/)
│   ├── chat/                    # 채팅 관련 컴포넌트
│   ├── notifications/           # 알림 UI 시스템
│   └── navigation/              # 네비게이션 셸
│
├── ⚙️ 핵심 유틸리티 (core/)
│   ├── app_theme.dart          # 테마 관리
│   ├── app_utils.dart          # 유틸리티 함수
│   ├── app_localizations.dart  # 다국어 지원
│   └── nav/                    # GoRouter 네비게이션
│
├── 📄 페이지 (pages/)
│   ├── chat/                   # 채팅 관련 페이지
│   ├── home/                   # 홈 피드
│   ├── profile/                # 프로필
│   └── jop/                    # 직업/관심사 선택
│
├── 📝 게시물 (posts/)
│   └── in_put_post_image/      # 이미지 게시물 생성
│       ├── components/         # UI 컴포넌트
│       ├── services/           # 업로드 서비스
│       └── widgets/            # 다이얼로그
│
├── 🎨 디자인 시스템 (design_system/)
│   ├── tokens/                 # 디자인 토큰
│   └── components/             # UI 컴포넌트
│
├── 💼 서비스 레이어 (services/)
│   ├── ai_moderation/          # AI 콘텐츠 검열
│   ├── cache/                  # 3-Layer 캐싱
│   ├── notification_service.dart
│   ├── vote_timer_service.dart
│   └── vote_state_coordinator.dart
│
├── 📊 상태 관리 (providers/)
│   └── navigation_provider.dart # 네비게이션 상태
│
├── 🔧 유틸리티 (utils/)
│   ├── app_logger.dart         # 로깅 시스템
│   ├── content_filter.dart     # 콘텐츠 필터링
│   └── responsive_breakpoints.dart
│
└── 🎯 기타
    ├── login/                   # 로그인 플로우
    ├── createaccount/           # 계정 생성
    ├── models/                  # 데이터 모델
    ├── shared/                  # 공유 유틸리티
    ├── widgets/                 # 커스텀 위젯
    ├── testpage_select/         # 테스트 페이지
    └── etc/                     # 레거시 코드

```

## 🔧 주요 구성요소

### 1. 진입점 파일

#### main.dart
```dart
// 앱 초기화 및 Provider 설정
void main() async {
  await initFirebase();
  await UnifiedCacheService.initialize();  // 3-Layer 캐싱
  await AppTheme.initialize();
  
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppState()),
      ChangeNotifierProvider(create: (_) => NavigationProvider()),
    ],
    child: MyApp(),
  ));
}
```

#### app_state.dart
- 싱글톤 패턴의 전역 상태 관리
- 업로드 데이터, 사용자 설정, 콘텐츠 상태 관리
- 196개 속성과 메서드로 구성

### 2. 핵심 시스템별 구조

#### 🔐 인증 시스템 (auth/)
- **다중 인증 지원**: Email, Google, Apple, Phone, GitHub, Anonymous
- **Firebase Auth 통합**: 모든 인증 플로우 구현
- **계정 생성 플로우**: 3단계 온보딩 (이메일/전화 → 관심사 → 프로필)

#### 🔥 백엔드 (backend/)
- **44개 Firestore 모델**: 완전한 타입 안전성
- **Firebase Storage**: 이미지/비디오 업로드 관리
- **Algolia 검색**: 실시간 검색 기능
- **API 통합**: Perspective API, Gemini AI, Cloud Vision

#### 🎨 UI 컴포넌트 (components/)
- **채팅 컴포넌트**: 투표 카드, 메시지 버블
- **알림 시스템**: 다이얼로그, 오버레이, 배지
- **네비게이션**: 듀얼 모드 바텀 네비게이션
- **비디오 플레이어**: YouTube 통합 지원

#### 📄 페이지 시스템 (pages/)
- **채팅 페이지**: flutter_chat_ui v2 기반
- **AI 채팅**: 투표 어시스턴트 봇
- **홈 피드**: 무한 스크롤 포스트 목록
- **프로필**: 사용자 정보 및 통계

#### 💼 서비스 레이어 (services/)
- **AI 콘텐츠 검열**: Perspective API + Gemini AI + Cloud Vision
- **3-Layer 캐싱**: Memory → Hive → Firestore
- **투표 시스템**: 타이머, 상태 관리, 실시간 업데이트
- **알림 서비스**: FCM 통합, 타겟 알림

#### 🎨 디자인 시스템 (design_system/)
- **디자인 토큰**: 색상, 간격, 타이포그래피
- **UI 컴포넌트**: 버튼, 다이얼로그, 텍스트 필드
- **아이콘 시스템**: 커스텀 아이콘 세트

## 💡 핵심 기능

### 투표 시스템
- **실시간 투표**: 10분 타이머 자동 완료
- **멀티미디어 지원**: 이미지, 비디오, YouTube 링크
- **AI 타겟팅**: 관련 사용자 자동 매칭
- **상태 관리**: VoteStateCoordinator 중앙 관리

### 채팅 시스템
- **실시간 메시징**: Firebase Realtime 통합
- **투표 카드 메시지**: 채팅 내 투표 기능
- **미디어 공유**: 이미지, 비디오 업로드
- **AI 어시스턴트**: 자동 투표 생성 봇

### 캐싱 시스템
- **3-Layer 아키텍처**: 
  - L1: Memory Cache (LRU, 100개 제한)
  - L2: Hive Local DB (영구 저장)
  - L3: Firestore Offline (무제한)
- **성능 지표**: <10ms 응답, 60% 캐시 히트율

### AI 통합
- **콘텐츠 검열**: 텍스트, 이미지 자동 검증
- **사용자 매칭**: 관심사 기반 추천
- **Genkit Framework**: 통합 AI 관리

## 🚀 성능 최적화

### 메모리 관리
- **이미지 캐싱**: CachedNetworkImage 사용
- **위젯 재사용**: const 생성자 활용
- **Lazy Loading**: 필요 시점 로딩

### 네트워크 최적화
- **배치 처리**: Future.wait 병렬 처리
- **디바운싱**: 과도한 API 호출 방지
- **오프라인 지원**: Firestore 오프라인 캐시

## 📊 프로젝트 통계

| 카테고리 | 수량 | 설명 |
|---------|------|------|
| **디렉토리** | 96개 | 전체 하위 디렉토리 |
| **Dart 파일** | 400+개 | 소스 코드 파일 |
| **모델 클래스** | 44개 | Firestore 데이터 모델 |
| **페이지** | 30+개 | 화면/라우트 |
| **서비스** | 20+개 | 비즈니스 로직 |
| **컴포넌트** | 50+개 | 재사용 UI |

## 🔄 마이그레이션 이력

### 2025-08-21: CamelCase 마이그레이션
- 768개 필드명 변환 완료
- Firebase Functions 동기화
- Backward compatibility 제거

### 2025-08-03: 투표 시스템 구현
- 실시간 타이머 시스템
- AI 타겟팅 알림
- 멀티미디어 투표 카드

### 2025-07-03: Native Flutter 마이그레이션
- FlutterFlow 의존성 완전 제거
- 352개 에러 해결
- iOS/Android 빌드 성공

## 🐛 디버깅 가이드

### 일반적인 문제 해결

#### setState() called after dispose
```dart
if (mounted) {
  setState(() {
    // 상태 업데이트
  });
}
```

#### Hive 캐시 에러
```bash
flutter clean
flutter pub get
# 앱 재설치
```

#### Firebase 권한 오류
- Firestore Rules 확인
- 필드 존재 여부 체크
- null safety 처리

## 🏗️ 빌드 및 배포

### 개발 환경
```bash
flutter run --debug
flutter run --profile  # 성능 프로파일링
```

### 프로덕션 빌드
```bash
# iOS
flutter build ios --release

# Android  
flutter build apk --release
flutter build appbundle --release

# Web
flutter build web --release
```

### 환경 변수
```bash
# .env 파일
PERSPECTIVE_API_KEY=your_key
GEMINI_API_KEY=your_key
ALGOLIA_APP_ID=your_id
```

## 📚 추가 문서

### 프로젝트 문서
- [프로젝트 개요](../CLAUDE.md)
- [네이밍 컨벤션](../NAMING_CONVENTION.md)
- [아키텍처 설계](../ARCHITECTURE.md)

### 하위 디렉토리 문서
- [인증 시스템](auth/README.md)
- [백엔드 통합](backend/README.md)
- [UI 컴포넌트](components/README.md)
- [서비스 레이어](services/README.md)
- [디자인 시스템](design_system/README.md)

## 📝 변경 이력
- 2025-08-24: 통합 문서화 완료
- 2025-08-21: CamelCase 마이그레이션 완료
- 2025-08-03: 투표 시스템 구현
- 2025-07-03: Native Flutter 마이그레이션

---

*이 문서는 Versus Space Flutter 애플리케이션의 전체 구조와 구성을 설명합니다.*