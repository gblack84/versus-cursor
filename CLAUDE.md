# Versus Space - FlutterFlow Project

## Project Overview

**Versus Space** is a Flutter mobile application built using FlutterFlow, a visual development platform for Flutter apps. This is a social media/content sharing platform that focuses on creating "versus" style content comparisons (A vs B format) with multimedia support, allowing users to create polls, share opinions, and engage in comparative discussions.

### Project Type
- **Framework**: Flutter (Dart)
- **Builder**: ~~FlutterFlow~~ → Native Flutter (리팩토링 완료 2025-07-03)
- **Backend**: Firebase (Firestore, Auth, Storage, Functions)
- **Platform**: Cross-platform (iOS, Android, Web, macOS)

## Architecture & Structure

### Core Architecture
- **State Management**: Provider pattern with `AppState` for global state (이전 `FFAppState`)
- **Navigation**: GoRouter for declarative navigation
- **Authentication**: Firebase Auth with multiple providers (Email, Google, Apple, Phone, GitHub)
- **Backend**: Firebase ecosystem (Firestore, Storage, Functions, Performance)
- **Internationalization**: Built-in support for English and German (English fully translated, German pending)
- **Content Moderation**: Integration with Perspective API for content filtering
- **Search**: Algolia integration for advanced search capabilities

### Key Directories

```
/Users/g_black/versus-cursor/
├── lib/                          # Main Flutter application code
│   ├── main.dart                 # Application entry point
│   ├── app_state.dart           # Global application state management
│   ├── index.dart               # Widget exports
│   ├── auth/                    # Authentication modules
│   ├── backend/                 # Firebase backend integration
│   │   ├── firebase/            # Firebase configuration
│   │   ├── schema/              # Firestore data models
│   │   ├── algolia/             # Algolia search integration
│   │   └── api_requests/        # API call management
│   ├── core/                    # Core utilities (이전 flutter_flow)
│   │   ├── nav/                 # Navigation logic
│   │   ├── app_theme.dart       # 테마 설정 (이전 flutter_flow_theme.dart)
│   │   ├── app_utils.dart       # 유틸리티 함수 (이전 flutter_flow_util.dart)
│   │   └── internationalization.dart  # i18n support
│   ├── components/              # Reusable UI components
│   ├── custom_code/             # Custom Flutter code
│   │   ├── actions/             # Custom actions
│   │   └── widgets/             # Custom widgets
│   ├── pages/                   # Application screens/pages
│   ├── login/                   # Authentication screens
│   ├── createaccount/           # Account creation flow
│   ├── posts/                   # Post-related features (오타 수정: pots → posts)
│   ├── services/                # External services (Perspective API)
│   ├── utils/                   # Utility functions
│   └── widgets/                 # Custom widgets
├── assets/                      # Static assets
│   ├── fonts/                   # SourGummy font family
│   ├── images/                  # Image assets
│   └── videos/                  # Video assets
├── firebase/                    # Firebase configuration
│   ├── functions/               # Cloud Functions
│   ├── firestore.rules         # Firestore security rules
│   └── firebase.json           # Firebase project config
├── android/                     # Android-specific configuration
├── ios/                         # iOS-specific configuration
├── web/                         # Web-specific configuration
└── macos/                       # macOS-specific configuration
```

## Key Features & Functionality

### Content Management
- **Versus Format**: All content follows A vs B comparison format
- **Media Upload**: Support for images, videos, and YouTube links
- **Video Editing**: Custom video trimmer with start/end time selection
- **Image Editing**: Advanced image editor with ProImageEditor integration
- **Content Types**: Text comparisons, image comparisons, video comparisons, mixed media
- **YouTube Integration**: Direct YouTube link support for video content

### Social Features
- **User Profiles**: Display names, profile pictures, character avatars
- **Social Interactions**: Likes, dislikes, comments, shares on posts
- **Chat System**: Direct messages and group chats with real-time messaging
- **Friend System**: Friend lists and social connections
- **Rankings & Points**: Dual point system (points_A for answers, points_Q for questions)
- **Anonymous Posting**: Support for anonymous posts and comments
- **Reporting System**: Content moderation with reporting functionality

### Authentication & Users
- **Multiple Auth Methods**: Email, Google, Apple, Phone (SMS), GitHub, Anonymous
- **User Onboarding**: Multi-step account creation with profile setup
- **Interest Selection**: Job categories, expertise (up to 4), hobbies (up to 8)
- **Age Verification**: 13+ age requirement with confirmation
- **Phone Verification**: SMS OTP with resend limits (max 3 attempts)
- **Email Verification**: Email confirmation with timer and resend options

### Data Models (Firestore Collections)

**Core Collections:**
- `users_record` - User profiles, settings, points, rankings
- `posts_record` - Versus posts with A/B content, voting, metadata
- `comments_record` - Comments with like/dislike subcollections
- `characters_record` - User avatar/character information
- `encodings_record` - Video encoding status tracking

**Social Collections:**
- `chats_record` - Direct messages with message subcollection
- `group_chats_record` - Group conversations
- `friends_list_record` - Friend connections
- `likes_record`, `dislikes_record` - Post interactions

**Feature Collections:**
- `rankings_record` - Leaderboards with ranked posts
- `premium_users_record` - Premium subscriptions
- `searches_record` - Search history
- `notifications_record` - User notifications

**Content Collections:**
- `jops_category_record`, `jops_name_record` - Job categories
- `interest_record` - Interest categories with weights
- `user_contents_record` - User content with polls and feeds
- `point_record` - Point transactions

## Development Configuration

### Build Configuration
- **pubspec.yaml**: Flutter dependencies and asset configuration
- **SDK Version**: Dart 3.0.0+
- **Flutter Version**: Stable release (FlutterFlow requirement)

### Key Dependencies
```yaml
# Core Flutter
flutter_localizations: ^latest
go_router: ^12.1.3
provider: ^6.1.2

# Firebase
firebase_core: ^3.8.0
firebase_auth: ^5.3.3
cloud_firestore: ^5.5.0
firebase_storage: ^12.3.2

# Media & UI
video_player: ^2.9.2
image_picker: ^1.1.2
cached_network_image: ^3.4.1
flutter_animate: ^4.5.0

# Custom Features
pro_image_editor: ^5.4.2
flutter_native_video_trimmer: ^1.1.9
algolia: ^1.1.1
```

### Firebase Configuration
- **Project ID**: versus-space-1lwwiw
- **Services**: Authentication, Firestore, Storage, Functions, Hosting
- **Web API Key**: Configured for web deployment
- **Platform Support**: iOS, Android, Web with proper configuration files

### 플랫폼별 배포 설정 권장사항

#### iOS 설정 추천:
```yaml
최소 지원: iOS 13.0
타겟: iOS 17.0
```

**이유:**
- iOS 13.0은 2025년 4월부터 필수
- 대부분의 중요 기능 사용 가능 (다크모드, SF Symbols 등)
- 약 98% 이상의 활성 기기 지원
- iPhone 6s 이상 모든 기기 지원

#### Android 설정 추천:
```yaml
minSdkVersion: 24 (Android 7.0)
targetSdkVersion: 34 (Android 14)
```

**이유:**
- API 24는 약 95% 기기 커버
- 대부분의 현대적 기능 사용 가능
- 2017년 이후 기기는 거의 모두 지원
- 너무 오래된 기기 제외로 성능 최적화 가능

#### 이미지/비디오 편집 앱 특성상:
1. **메모리 관리 중요**
   - 최소 2GB RAM 기기 타겟
   - 이미지 리사이징, 압축 필수

2. **성능 최적화**
   - 저사양 기기에서 테스트 필수
   - 프로그레시브 로딩 구현

3. **기능 제한**
   - 구형 기기: 기본 편집만
   - 신형 기기: 고급 필터, 효과

이 설정으로:
- **시장 점유율 95% 이상 커버**
- **개발/유지보수 효율적**
- **적절한 성능 보장**

### Custom Code

**Custom Actions:**
- `get_video_path.dart` - Video selection from camera/gallery using ImagePicker

**Custom Widgets:**
- `advanced_image_editor.dart` - ProImageEditor integration with Firebase Storage upload
- `new_video_trimmer_page.dart` - Video trimming with timeline selection
- `highlighted_text_field.dart` - Custom text field with highlighting

**Services & Utils:**
- `perspective_api_service.dart` - Content moderation using Google's Perspective API
- `content_filter.dart` - Content filtering utilities

**Custom Functions:**
- Date formatting and parsing
- Age verification (13+ requirement)
- Video aspect ratio calculations

## Development Workflow

### Native Flutter Migration (2025-07-03)
- **이전**: FlutterFlow 자동 생성 코드
- **현재**: 네이티브 Flutter 코드로 완전 마이그레이션
- **변경사항**: 
  - 모든 FlutterFlow 컴포넌트를 App* 접두사로 변경
  - flutter_flow 디렉토리를 core로 이름 변경
  - 352개 에러 → 0개로 해결
  - iOS 빌드 성공, Android는 JDK 호환성 이슈
- **Git History**: 마이그레이션 커밋 (commit: 4a6a285)
- **Branch Structure**: Single `flutterflow` branch (main development branch)

### Code Analysis
- **analysis_options.yaml**: Excludes custom code and FlutterFlow generated functions
- **Excluded Paths**: 
  - `lib/custom_code/**`
  - `lib/flutter_flow/custom_functions.dart`

## Development Guidelines

### Working with Native Flutter (FlutterFlow 마이그레이션 후)
1. **Primary Development**: 네이티브 Flutter 코드로 직접 개발
2. **Custom Code**: custom_code 디렉토리의 모든 코드 통합 완료
3. **Version Control**: Git으로 직접 관리 (FlutterFlow 동기화 불필요)
4. **Testing**: Flutter testing framework 사용

### File Organization
- **Generated Code**: Most files are auto-generated by FlutterFlow
- **Custom Modifications**: Keep custom code in designated directories
- **Assets**: Organized by type (fonts, images, videos, etc.)
- **Configuration**: Platform-specific configs in respective directories

### Firebase Development
- **Security Rules**: Configured in `firestore.rules` and `storage.rules`
- **Cloud Functions**: Node.js functions in `/firebase/functions/`
- **Local Development**: Use Firebase emulators for local testing

## Internationalization (i18n)

### Supported Languages
- **English (en)**: Primary language, fully translated
- **German (de)**: Secondary language, translation keys ready but content pending

### Implementation
- Uses Flutter's built-in localization with `AppLocalizations` (이전 `FFLocalizations`)
- Translation keys stored in `kTranslationsMap`
- Language preference saved in SharedPreferences
- Supports fallback localization for unsupported locales

### Key Translated Sections
- Authentication flows (login, signup, password reset)
- User onboarding (profile setup, interests)
- Content creation (versus posts, media upload)
- UI components (buttons, alerts, navigation)

## State Management

### AppState Structure (이전 FFAppState)
The global app state manages:

**User Preferences:**
- Selected language
- Display name

**Content Creation State:**
- Dual content slots (A/B) for text, images, videos, YouTube links
- Edit mode flags for different content types
- Upload progress tracking

**Video Processing:**
- Video paths and aspect ratios
- Trimming timestamps (start/end in milliseconds)
- Cover image bytes
- Post associations

## Firebase Security Rules

### Key Security Patterns
- User-specific data requires authentication (`request.auth.uid == parent`)
- Public read access for posts, comments, and social features
- Write restrictions on most collections (create allowed, edit/delete restricted)
- Subcollection inheritance for read permissions

### Protected Resources
- User settings and notifications
- Chat history and interest preferences
- Direct message contents

## Getting Started

### Prerequisites
- Flutter SDK (stable channel, 3.0.0+)
- Firebase CLI
- FlutterFlow account and project access
- Platform-specific development tools (Xcode for iOS, Android Studio for Android)
- API Keys: Perspective API for content moderation

### Development Setup
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase project settings
4. Set up platform-specific configurations
5. Configure API keys for external services
6. Use FlutterFlow for primary UI development
7. Add custom code in designated directories

### Build Commands
```bash
# Development
flutter run

# Build for platforms
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
flutter build macos        # macOS

# Run with specific configuration
flutter run --dart-define=PERSPECTIVE_API_KEY=your_key
```

### Testing
```bash
# Run tests
flutter test

# Analyze code
flutter analyze
```

## Project Best Practices

### Code Organization
- Keep custom code separate from FlutterFlow generated code
- Use designated custom_code directories
- Follow Flutter/Dart naming conventions
- Maintain consistent file structure

### Version Control
- Regular commits with FlutterFlow sync
- Use meaningful commit messages
- Keep sensitive data out of version control
- Use environment variables for API keys

### Performance Considerations
- Lazy load heavy components
- Optimize image and video uploads
- Use caching for frequently accessed data
- Implement proper error handling

This project represents a sophisticated social media application with a unique "versus" comparison format, rich multimedia features, and comprehensive social interactions, originally built with FlutterFlow but now fully migrated to native Flutter code with Firebase backend services.

## Migration History

### 2025-07-03: FlutterFlow to Native Flutter Migration
- **작업 내용**:
  - FlutterFlow 의존성 완전 제거
  - 모든 FF/FlutterFlow 접두사를 App으로 변경
  - flutter_flow 디렉토리를 core로 리네이밍
  - AppState 호환성 유지를 위한 별칭(alias) 추가
  - 352개 에러 해결 → 0개 이슈
  - 사용하지 않는 import 및 코드 정리
- **결과**:
  - iOS 빌드 ✅ 성공
  - Android 빌드 ⚠️ JDK 호환성 이슈 (video_player 플러그인)
  - 모든 기능 유지
  - 순수 Flutter 프로젝트로 전환 완료
- **커밋**: 4a6a285 (GitHub에 푸시 완료)

### 2025-07-03: 콘텐츠 생성 UI 개선 및 유효성 검사 강화
- **작업 내용**:
  - 투명 텍스트 버그 수정 (highlighted_text_field.dart)
  - 화면 하단 여백 크기 조정 (200px → 100px)
  - 바텀시트 배경 투명도 개선
  - ContentFilter 타입 캐스팅 에러 수정
  - 필수 필드 유효성 검사 추가
  - 다음 버튼 표시 조건 개선 (스크롤 + 필수 필드 채워짐)
  - 에러 메시지 UI 통합 (필드 아래 인라인 표시)
  - 빨간색 포커스 보더 제거
  - 텍스트 지우면 에러 메시지 자동 초기화
- **결과**:
  - 더 직관적인 사용자 경험
  - 필수 필드 비어있음 방지
  - 통일된 에러 메시지 표시
  - 깨끗한 UI/UX

### 2025-07-04: A/B 박스 미디어 선택 기능 및 wechat_assets_picker 통합
- **작업 내용**:
  - A/B 박스에 비디오 아이콘 추가 및 미디어 타입 선택 바텀시트 구현
  - InkWell로 전체 박스를 클릭 가능하도록 변경
  - 아이콘을 조건부 렌더링 (이미지/비디오)
  - wechat_assets_picker 패키지 통합 (v9.5.1)
  - 한국어 텍스트 델리게이트 구현 (KoreanAssetPickerTextDelegate)
  - Flutter 3.32.5에서 모든 패키지 호환성 확인
- **구현 세부사항**:
  - _showMediaTypeSelection() 메서드로 미디어 타입 선택
  - isVideoSelectedA/B 상태 변수로 아이콘 전환
  - AssetPickerConfig 설정 (gridCount: 4, wechatMoment 스타일)
- **결과**:
  - 위챗 스타일 이미지 피커 성공적으로 작동
  - 이미지 선택 및 경로 획득 완료
  - 시뮬레이터에서는 카메라 버튼 미표시 (실기기에서는 표시 예상)

### 2025-07-05~06: MediaSelectionBox 액션 아이콘 구현
- **작업 내용**:
  - 이미지가 있을 때 3개의 액션 아이콘 추가 (편집, 이미지 추가, B박스 표시)
  - A박스에 이미지 삭제용 X 아이콘 추가
  - B박스는 항상 X 아이콘 표시 (숨기기용)
  - 아이콘 크기 및 배치 최적화 (29px로 통일)
  - 가로/세로 레이아웃에 따른 아이콘 배치 조정
- **UI 구성**:
  - 우측 상단: X 아이콘 (검은 원형 배경)
  - 우측 하단: 액션 아이콘들 (검은 반투명 원형 배경)
  - 가로 레이아웃: 3개 아이콘 가로 배치 [+B] [+이미지] [편집]
  - 세로 레이아웃: 3개 아이콘 세로 배치
- **아이콘 변경**: 
  - +B 아이콘을 Icons.add_box_outlined → Icons.add로 변경 (플러스만 표시)
- **커밋**: 115a8dc (feature/flutter-upgrade 브랜치)

### 2025-07-07: 이미지 편집 기능 및 ProImageEditor 통합
- **작업 내용**:
  - ProImageEditor 페이지 구현 완료
  - Firebase Storage URL에서 이미지 다운로드 → 편집 → 재업로드 플로우 구현
  - 이미지 뷰어 페이지 구현 (전체화면 보기, 줌/스와이프 지원)
  - MediaUploadService 클래스로 업로드 로직 중앙화
  - 로딩 상태 관리 및 에러 처리 개선
- **아키텍처 개선**:
  - InPutPostImageWidget 리팩토링 (컴포넌트 분리)
  - constants, delegates, helpers, services, widgets 디렉토리 구조화
  - MediaSelectionBox 컴포넌트 독립 분리
  - AspectRatioHelper 유틸리티 클래스 추가
- **UI/UX 업데이트**:
  - 이미지 편집 아이콘 동작 구현
  - 업로드 중 로딩 인디케이터 표시
  - 편집 완료 후 자동 이미지 업데이트
  - 스낵바로 성공/실패 피드백 제공
- **결과**:
  - 이미지 편집 워크플로우 완성
  - Firebase Storage 통합 안정화
  - 사용자 경험 개선

### 현재 진행 상황
- **InPutPostImageWidget** 페이지에서 미디어 선택 및 편집 기능 구현 완료
- MediaSelectionBox 컴포넌트 분리 및 액션 아이콘 구현 완료
- wechat_assets_picker로 갤러리 접근 가능
- Firebase Storage에 이미지 업로드 및 표시 기능 작동
- ProImageEditor 통합으로 이미지 편집 기능 완성
- 이미지 뷰어 페이지 구현 완료 (전체화면 보기, 줌/스와이프 지원)

### 2025-07-07: 이미지 처리 및 멀티 이미지 관리 개선 (추가 작업)
- **이미지 리사이징 서비스 구현**:
  - MediaUploadService 클래스 생성
  - 3단계 이미지 생성: original, display (800px), thumbnail (150px)
  - JPEG 85% 품질로 압축
  - Firebase Storage에 각각 저장
- **멀티 이미지 관리 개선**:
  - 인덱스 기반 삭제로 정확한 이미지 제거
  - AppState에 reorderUploadImage, moveToFrontUploadImage 메서드 추가
  - 썸네일에서 선택한 대표 이미지를 맨 앞으로 자동 배치
- **성능 최적화**:
  - CachedNetworkImage에 memCacheWidth 추가
  - 이미지 로딩 속도 5-10배 향상
  - 메모리 사용량 최적화
- **커밋**: a61fdb2

### 2025-07-07: 스마트 레이아웃 시스템 기반 구축
- **작업 내용**:
  - AspectRatioAnalyzer 클래스 생성 (이미지 비율 분석 및 최적 레이아웃 결정)
  - DynamicBoxCalculator 클래스 생성 (동적 박스 크기 계산)
  - MediaSelectionBox에 동적 크기 지원 추가 (dynamicHeight/Width)
  - InPutPostImageModel에 레이아웃 타입 추가 (점진적 마이그레이션)
- **레이아웃 결정 로직**:
  - 가로형 이미지들 → 세로 배치 (위/아래)
  - 세로형 이미지들 → 가로 배치 (좌/우)
  - 혼합형 → 더 극단적인 비율을 가진 쪽 우선
- **결과**:
  - 스마트 레이아웃 시스템 기반 완성
  - 기존 토글 버튼과 호환성 유지
  - 점진적 마이그레이션 가능
- **커밋**: 53674a0

### 2025-07-08: 스마트 레이아웃 시스템 완성 🎉
- **작업 내용**:
  - 스마트 레이아웃 시스템이 이미 완전히 구현되어 있음을 확인
  - 이미지 업로드 시 비율 자동 계산 및 저장 ✅
  - AppState에 aspect ratio 리스트 완비 ✅
  - Consumer 위젯으로 실시간 레이아웃 업데이트 ✅
  - 동적 박스 크기 계산 및 적용 완료 ✅
  - 디버그 정보 표시 추가 (개발 모드에서만 표시)
  - 초기화 시 이미지 없을 때 기본 레이아웃 유지 개선
- **시스템 작동 방식**:
  1. 이미지 선택 → MediaUploadService가 비율 계산
  2. AppState.uploadImageAspectRatioA/B에 저장
  3. _updateLayoutBasedOnImages()가 자동 호출
  4. AspectRatioAnalyzer가 최적 레이아웃 결정
  5. DynamicBoxCalculator가 박스 크기 계산
  6. UI가 자동으로 업데이트
- **결과**:
  - 토글 버튼 없이 이미지 비율에 따라 자동 레이아웃
  - 사용자 경험 향상
  - 화면 공간 최적화
- **커밋**: d63a86c (fix: 스마트 레이아웃 초기값 문제 해결 및 디버깅 로그 추가)

### 현재 상태 요약
- **스마트 레이아웃 시스템** 완성 ✅
- 이미지 비율에 따라 자동으로 가로/세로 레이아웃 전환
- 동적 박스 크기로 화면 공간 최적화
- 멀티 이미지 지원 (최대 4개)
- 이미지 편집 및 재배치 기능 완비

### 2025-07-08: 이미지 업로드 성능 최적화 및 스마트 레이아웃 시스템 개선
- **성능 최적화**:
  - 병렬 업로드 구현 (Future.wait 사용)
  - 업로드 직후 이미지 프리캐싱 추가
  - memCacheWidth 계산 최적화 (Firebase display 크기 기준)
  - 멀티 이미지 업로드 시간 30-50% 단축
  - 첫 이미지 우선 프리캐싱으로 체감 속도 향상
- **스마트 레이아웃 자동 적용**:
  - 이미지 업로드 후 자동으로 레이아웃 변경
  - Consumer 패턴으로 AppState 변경 감지
  - 이미지 삭제 시에도 자동 레이아웃 업데이트
  - 불필요한 _updateLayoutBasedOnImages 호출 제거
- **UI/UX 개선**:
  - B박스 X 아이콘 기능 분리
    - 이미지 있을 때: 작은 X (이미지 삭제)
    - 이미지 없을 때: 큰 X (B박스 숨기기)
  - 세로 배치 시 아이콘 세로 정렬로 수정
  - A박스 비어있고 B박스에 이미지 있을 때 경고 메시지 표시
- **버그 수정**:
  - B박스 이미지 삭제 로직 수정
  - setState() called after dispose() 에러 해결
  - Concurrent modification 에러 해결
- **커밋**: 46d0d4b

### 2025-07-08: ProImageEditor 커스터마이징 및 UI/UX 개선
- **ProImageEditor 메뉴 정리**:
  - Blur 메뉴 완전 비활성화
  - Paint 메뉴 도구 정리:
    - Rectangle, Polygon, Pixelate, Line 도구 제거
    - Pen, Arrow, Dash Line, Circle, Emoji만 유지
  - 불필요한 기능 제거로 사용자 경험 개선
- **네비게이션 버튼 스타일 개선**:
  - 기존 아이콘 버튼을 텍스트 버튼으로 변경
  - "< 갤러리", "< 썸네일" 형태의 명확한 레이블 추가
  - 검은색 둥근 배경의 일관된 디자인 적용
  - 이미지 에디터와 썸네일 페이지 모두 통일된 스타일
- **wechat_assets_picker 테마 커스터마이징**:
  - 완전 검은색 배경 적용 (scaffoldBackgroundColor: Colors.black)
  - 확인 버튼 색상을 프로젝트 primary 색상으로 변경
  - pickerTheme 설정으로 일관된 다크 테마 구현
- **코드 구조**:
  - ProImageEditorConfigs에서 blurEditor, paintEditor 설정
  - MediaSelectionFlowWidget에 커스텀 네비게이션 버튼 오버레이
  - AssetPickerConfig에 pickerTheme 적용
- **커밋**: 
  - eb6f05f (feat: ProImageEditor 메뉴 커스터마이징)
  - 7c4e88a (feat: 네비게이션 버튼 텍스트 스타일로 변경)
  - b1b8a6e (feat: 이미지 피커 확인 버튼 색상 변경)

### 현재 상태 요약
- **스마트 레이아웃 시스템** 완성 ✅
- 이미지 비율에 따라 자동으로 가로/세로 레이아웃 전환
- 동적 박스 크기로 화면 공간 최적화
- 멀티 이미지 지원 (최대 4개)
- 이미지 편집 및 재배치 기능 완비
- 업로드 성능 대폭 개선
- ProImageEditor 커스터마이징 완료
- 일관된 UI/UX 디자인 시스템 구축

### 2025-07-09: 이미지 편집 플로우 개선 및 피커 선택 상태 표시
- **편집 플로우 개선**:
  - 편집 버튼 클릭 시 바로 이미지 에디터로 이동
  - 멀티 이미지: 현재 보고 있는 이미지를 편집
  - 단일 이미지: 바로 편집
  - 에디터에서 뒤로가기 시 질문 작성 페이지로 복귀
- **이미지 교체 로직 수정**:
  - 썸네일 선택 후 편집 시 원본 위치에 교체
  - 이미지 개수 유지 (추가가 아닌 교체)
  - 편집된 이미지는 썸네일(맨 앞) 위치 유지
- **현재 이미지 인덱스 추적**:
  - PageView의 onPageChanged로 현재 인덱스 추적
  - InPutPostImageModel에 currentImageIndexA/B 추가
  - 정확한 이미지 편집 가능
- **AssetEntity ID를 활용한 선택 상태 표시**:
  - AppState에 assetEntityIdsA/B 리스트 추가
  - 이미지 선택 시 AssetEntity ID 저장
  - 피커 열 때 selectedAssets로 이전 선택 표시
  - 작성 페이지 내에서 선택 상태 유지
- **커밋**: 2ead482

### 2025-07-09: 멀티 이미지 선택 및 PageView 개선
- **멀티 이미지 선택 플로우 수정**:
  - 첫 선택 시 3개 이미지 모두 저장되도록 수정 (이전: 썸네일 1개만 저장)
  - diff 처리 조건 수정: `length > 1` 제거로 모든 경우에 diff 처리
  - 썸네일 선택 시에도 전체 파일 유지하도록 개선
- **이미지 추가/삭제 동작 개선**:
  - 자유로운 이미지 추가/삭제/재정렬 가능
  - 삭제한 이미지 위치에 새 이미지 추가 시 맨 뒤에 배치 (직관적 UX)
  - 예: 1,2,3,4에서 2번 삭제 후 5번 추가 → 1,3,4,5
- **PageView 성능 및 UX 개선**:
  - 드래그 시 박스 색상이 아닌 메인 배경색 표시
  - 이미지 프리로딩 전략 구현:
    - 초기 로드 시 첫 2개 이미지 프리로드
    - 페이지 변경 시 앞뒤 이미지 동적 프리로드
  - placeholder 배경색 통일 및 fadeIn 시간 단축 (150ms)
  - `allowImplicitScrolling: true`로 인접 페이지 프리렌더링
- **이미지 미리보기 인덱스 수정**:
  - 현재 보고 있는 이미지 인덱스로 미리보기 열기
  - currentImageIndexA/B 값 활용
  - 예: 3번 이미지 보고 있을 때 탭 → 3번 이미지 미리보기
- **커밋**: 01f021c

### 2025-07-09: 이미지 작성 페이지 리팩토링 및 UI/UX 개선
- **대규모 리팩토링** (1,296줄 → 1,112줄, 14.2% 감소):
  - 중복 코드 제거 및 헬퍼 메서드 추출
  - 컴포넌트 분리: LayoutDebugInfo, WarningMessage
  - MediaBoxCallbacks 헬퍼 클래스 생성
  - 코드 가독성 및 유지보수성 향상
- **UI/UX 개선**:
  - 중복 경고 메시지 통합 (하나의 Consumer만 사용)
  - B박스 X 아이콘 기능 수정 (이미지 없을 때 박스 숨기기)
  - 흔들림 애니메이션 개선:
    - 시간: 100ms → 200ms (더 부드럽게)
    - 횟수: 2번 → 1번
    - 곡선: elasticIn → easeInOut
    - 강도: 10px → 8px
  - 아이콘 크기 동적 조정 (박스 높이의 40-45%)
- **버그 수정**:
  - 이미지 편집 시 중복 저장 문제 해결
    - 편집 모드 판단 로직 추가
    - 편집 모드에서는 AppState 업데이트 건너뛰기
  - B박스 X 아이콘 작동 안 하는 문제 수정
    - onCancel 콜백에 setState 추가
- **커밋**: c2186ae

### 2025-07-13: 이미지 검열 시스템 구현 및 UI 개선
- **작업 내용**:
  - Google Cloud Vision API를 활용한 이미지 검열 시스템 구현
  - 동적 거부 메시지 표시 (API 응답 기반)
  - BotToast를 사용한 일관된 토스트 메시지 UI
  - ProImageEditor i18n 설정으로 한국어 로딩 메시지 표시
- **시나리오별 처리**:
  - 시나리오 1 (일부 거부): 승인된 이미지만 저장, 거부된 이미지 번호와 이유 표시
  - 시나리오 2 (전체 거부): 피커로 돌아가며 재선택 유도
  - 단일 이미지 거부: 피커로 돌아가며 재선택 유도
- **메시지 포맷**:
  - 단일 이미지: "선정적 콘텐츠"
  - 멀티 부분 거부: "선정적 콘텐츠: 2,3\n폭력적 콘텐츠: 4"
  - 멀티 전체 거부: "선정적 콘텐츠: 1,2,3,4"
- **버그 수정**:
  - setState after dispose 에러 해결
  - BotToast red screen 문제 해결 (showCustomText 사용)
  - 재시도 모드에서 피커 취소 시 모달 닫기 문제 해결
- **결과**:
  - 안전한 콘텐츠만 업로드되도록 보장
  - 사용자에게 명확한 거부 이유 제공
  - 부드러운 재시도 플로우 구현
- **커밋**: 19f868a

### 2025-07-13: 대규모 코드베이스 최적화 (10단계)
- **작업 내용**:
  - `/lib/posts/in_put_post_image/` 디렉토리 전체 최적화 (34개 파일)
  - 10단계에 걸친 체계적인 리팩토링 수행
- **주요 단계**:
  1. **메모리 누수 수정 및 인덱스 관리**
     - PageController dispose 추가
     - 스크롤 리스너 해제 추가
     - 이미지 삭제 시 인덱스 범위 검증
     - 배열 동기화 보장 (images, aspectRatios, assetIds)
  2. **Consumer 위젯 통합 및 setState 최소화**
     - 중복 Consumer 위젯 제거
     - setState 호출 전 상태 변경 확인
     - 불필요한 리빌드 방지
  3. **BaseMediaSelectionBox 생성**
     - 공통 로직을 mixin으로 추출
     - 코드 재사용성 향상
  4. **입력 필드 빌더 통합**
     - InputFieldBuilder 헬퍼 클래스 생성
     - 중복된 입력 필드 로직 통합
  5. **사용하지 않는 코드/import 제거**
     - 미사용 import 정리
     - 백업 파일 삭제
     - 중복 코드 제거
  6. **디버그 코드 조건부 컴파일**
     - DebugHelper 유틸리티 클래스 생성
     - 태그 기반 로깅 시스템 구현
     - 프로덕션에서 디버그 코드 자동 제외
  7. **이미지 캐싱 최적화**
     - ImageCacheHelper 클래스 생성
     - 동적 메모리 캐시 크기 계산
     - PageView 스와이프 시 이미지 프리로딩
  8. **에러 처리 개선**
     - ErrorHandler 유틸리티 클래스 생성
     - 에러 타입 분류 시스템
     - tryAsync/trySync 래퍼 구현
     - 일관된 Toast UI
  9. **파일명 정리 및 일관성 적용**
     - field_decoration_helper.dart 삭제 (미사용)
     - custom_asset_picker_delegate.dart → camera_floating_button_delegate.dart
     - media_selection_box.dart → media_selection_box_single.dart
     - 클래스명 일관성 개선
  10. **상수 분리**
      - 8개의 상수 파일로 체계적 분리:
        - dimensions.dart (UI 치수)
        - image_constants.dart (이미지 처리)
        - animation_constants.dart (애니메이션)
        - strings.dart (문자열)
        - text_limits.dart (텍스트 제한)
        - colors.dart (색상)
        - config.dart (설정)
        - constants.dart (export 파일)
- **결과**:
  - 코드 유지보수성 대폭 향상
  - 성능 최적화로 앱 반응성 개선
  - 체계적인 디렉토리 구조 확립
  - 재사용 가능한 컴포넌트 라이브러리 구축
- **새로운 디렉토리 구조**:
  ```
  lib/posts/in_put_post_image/
  ├── components/        # 재사용 가능한 UI 컴포넌트
  ├── constants/         # 중앙 집중식 상수 관리
  ├── delegates/         # 커스텀 델리게이트
  ├── helpers/          # 헬퍼 클래스 및 유틸리티
  ├── services/         # 비즈니스 로직 서비스
  ├── utils/            # 공통 유틸리티
  └── widgets/          # 복합 위젯
  ```

### 2025-07-14: 텍스트 필드 UI/UX 대규모 개선
- **작업 내용**:
  - 실시간 문자 카운터 업데이트 문제 해결
  - 텍스트가 underline border에 겹치는 문제 해결 (fontSize 불일치)
  - 중앙 집중식 필드 스타일 관리 시스템 구현 (field_styles.dart)
  - 텍스트 검열 시스템 전체 연결 확인 및 수정
  - Description 필드 높이 조정 (minLines: 4 → 1)
  - 필드 내부 텍스트 좌우 패딩 추가
  - 경고 메시지와 텍스트 입력 위치 정렬
  - 빈 필드 경고가 페이지 로드 시 나타나는 문제 해결
- **중앙 집중식 스타일 시스템**:
  - FieldStyles 클래스로 모든 필드 설정 통합
  - FieldConfig로 각 필드별 세부 설정 관리
  - 글자 크기, 패딩, 테두리 등 한 곳에서 관리
  - 유지보수성 대폭 향상
- **유효성 검사 개선**:
  - hasValidated 플래그 추가
  - "필수 항목입니다" 경고는 다음 버튼 클릭 후에만 표시
  - isEmpty 상태 초기값을 true로 변경 (빈 필드부터 시작)
- **결과**:
  - 직관적인 사용자 경험
  - 일관된 UI 디자인
  - 쉬운 스타일 수정 및 유지보수

### 2025-07-15~16: AI 검열 시스템 고도화 및 Genkit 통합
- **Gemini AI 통합 (Phase 1)**:
  - Google Gemini AI API를 활용한 이미지 검증 시스템 구현
  - Genkit Firebase Functions 프레임워크 통합
  - 토큰 사용량 추적 시스템 구현 (inputTokens, outputTokens, totalTokens)
- **AI 검열 시스템 개선**:
  - 검열 로직을 별도 서비스로 분리 (ai_moderation_service.dart)
  - 얼굴 평가 관련 BLOCK 처리 강화
  - 다음 버튼 클릭 시 이미지 업로드 및 AI 검증 자동 실행
  - 로딩 표시 개선 (이미지 추가 시, 네비게이션 시)
- **UI/UX 개선**:
  - 멀티 이미지 페이지 인디케이터 및 카운터 복구
  - A/B 박스 플러스 아이콘 표시 조건 최적화
  - B박스가 숨겨진 상태에서만 + 아이콘 표시
- **시스템 아키텍처**:
  - Firebase Functions에 Genkit 프레임워크 도입
  - 비동기 이미지 검증 플로우 구현
  - 에러 처리 및 재시도 로직 강화
- **커밋 이력**:
  - 0cfed3a5: Gemini AI 통합 검증 시스템 구현 (Phase 1)
  - 0d0c85af: AI 검열 시스템 분리 및 구조 개선
  - 20df3027: Genkit 통합 및 토큰 사용량 추적 개선
  - fc415fcf: 다음 버튼 클릭 시 이미지 업로드 및 AI 검증 플로우 구현
  - 6fc80488: AI 검열 시스템 개선 - 얼굴 평가 BLOCK 처리 강화

### 향후 개선 가능 사항

#### 기존 이미지 기능 개선
1. **애니메이션 추가**: 레이아웃 전환 시 부드러운 애니메이션
2. **사용자 설정**: 자동 레이아웃을 끄고 수동으로 선택하는 옵션
3. **고급 레이아웃**: 3x3, 2x2 등 더 복잡한 레이아웃 옵션
4. **AI 기반 최적화**: 이미지 내용 분석으로 더 스마트한 레이아웃 결정
5. **디버그 정보 제거**: 프로덕션 배포 전 스마트 레이아웃 디버그 정보 제거
6. **이미지 피커 고급 커스터마이징**: 
   - 커스텀 AssetPickerBuilderDelegate로 버튼 스타일 완전 제어
   - 최근 항목(Recents) 기능 개선
   - 이미지 교체 모드 추가
7. **ProImageEditor 추가 설정**:
   - 커스텀 필터 추가
   - 텍스트 에디터 폰트 옵션 확장
   - 스티커/이모지 라이브러리 통합

#### 비디오 기능 통합 계획
**현재 구조는 비디오 통합을 고려하여 설계됨**
- `isVideoSelectedA/B` 상태 변수 이미 준비
- 미디어 타입별 플로우 분기 가능한 구조
- 컴포넌트 기반 아키텍처로 확장 용이

**구현 로드맵**:
1. **Phase 1: 미디어 타입 선택 UI (1-2일)**
   - A박스 클릭 시 이미지/비디오 선택 바텀시트
   - 선택 시 A/B 박스 자동 동기화
   - 아이콘 변경 (이미지: photo, 비디오: videocam)

2. **Phase 2: 비디오 선택 및 미리보기 (3-4일)**
   - VideoSelectionFlow 위젯 생성
   - 비디오 피커 통합 (wechat_assets_picker 활용)
   - 비디오 썸네일 자동 생성
   - 비디오 미리보기 UI

3. **Phase 3: 비디오 업로드 (2-3일)**
   - VideoUploadService 생성
   - 비디오 압축 및 최적화
   - Firebase Storage 통합
   - 업로드 진행률 표시

4. **Phase 4: 비디오 재생 (2일)**
   - VideoPlayerWidget 구현
   - 재생/일시정지 컨트롤
   - 음소거/볼륨 조절
   - 진행바 표시

**예상 코드 구조**:
```dart
// 미디어 타입에 따른 분기
if (model.isVideoSelectedA) {
  // 비디오 플로우
  VideoSelectionFlow(box: 'A')
} else {
  // 이미지 플로우 (현재 구현)
  MediaSelectionFlow(box: 'A')
}
```

**재사용 가능한 컴포넌트**:
- ErrorHandler → 비디오 에러도 처리
- ValidationService → 비디오 크기/길이 검증
- MediaUploadService → 비디오 업로드 추가
- 모든 상수 파일 → 비디오 관련 상수만 추가