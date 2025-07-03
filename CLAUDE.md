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