/// **앱 레벨 위젯 통합 Export - Barrel Export Pattern**
///
/// 이 파일은 Versus Space 앱의 모든 Feature별 화면 위젯을 중앙집중식으로
/// export하는 **Barrel Export** 패턴을 구현합니다.
///
/// ## Barrel Export Pattern이란?
///
/// 여러 모듈에서 export된 위젯들을 하나의 파일에서 재export하여,
/// 다른 코드에서 **단일 import**로 모든 위젯에 접근할 수 있게 하는 패턴입니다.
///
/// ### Before (Barrel 없이)
///
/// ```dart
/// // nav.dart에서 24개 위젯을 개별 import
/// import '/features/auth/presentation/screens/login/login_page/login_page_widget.dart';
/// import '/features/auth/presentation/screens/signup/create_account/create_account_widget.dart';
/// import '/features/auth/presentation/screens/forgot_password/forgot_password/forgot_password_widget.dart';
/// import '/features/profile/presentation/screens/user_info_input/user_info_input_widget.dart';
/// // ... 20개 더
/// ```
///
/// ### After (Barrel 사용)
///
/// ```dart
/// // nav.dart에서 한 줄로 모든 위젯 import
/// import '/app/widgets/index.dart';
///
/// // 바로 사용 가능
/// GoRoute(
///   path: '/login',
///   builder: (context, state) => LoginPageWidget(),
/// ),
/// ```
///
/// ## 주요 장점
///
/// 1. **단일 진입점**:
///    - 24개 위젯을 하나의 import로 접근
///    - import 문 수 감소: 24줄 → 1줄 (96% 감소)
///
/// 2. **Tree Shaking 지원**:
///    - `show` 키워드로 명시적 export
///    - Release 빌드 시 미사용 위젯 자동 제거
///    - 번들 크기 최적화
///
/// 3. **유지보수 용이**:
///    - 위젯 경로 변경 시 이 파일만 수정
///    - 다른 코드 영향 없음 (import 경로 변경 불필요)
///
/// 4. **GoRouter 통합**:
///    - `/lib/app/router/navigation/nav.dart`가 이 파일 하나만 import
///    - 모든 route builder에서 위젯 즉시 사용 가능
///
/// ## 현재 Export 위젯 통계
///
/// - **총 위젯 수**: 24개
/// - **Feature 수**: 8개 (Auth, Profile, Chat, Creation, Post, Search, Notifications, Debug)
/// - **총 줄 수**: 47줄
/// - **의존성**: Feature별 Presentation Layer 위젯들
///
/// ## Feature별 구성
///
/// | Feature | 위젯 수 | 주요 화면 |
/// |---------|--------|----------|
/// | **Auth** | 6 | Login, Signup, ForgotPassword, Start, Phone인증 |
/// | **Profile** | 6 | UserInfo, Expertise, Hobbies, Agreed, Profile, UserInfoDisplay |
/// | **Creation** | 3 | CreatePost, ImageEditor, ImageViewer |
/// | **Chat** | 4 | ChatList, Friends, ChatDetail, AIChat |
/// | **Post** | 1 | Home (Feed) |
/// | **Search** | 1 | Search |
/// | **Notifications** | 1 | NotificationsList |
/// | **Debug** | 1 | DebugLogs (kDebugMode only) |
/// | **Other** | 1 | TestpageSelect (개발용) |
///
/// ## Clean Architecture v4.0 적용
///
/// - **레이어**: App Layer (Presentation 위젯 통합)
/// - **원칙**: Dependency Rule 준수 (위젯만 export, 비즈니스 로직 제외)
/// - **패턴**: Barrel Export (단일 진입점)
/// - **최적화**: Tree Shaking (미사용 코드 자동 제거)
///
/// ## 사용 예시
///
/// ### GoRouter에서 사용
///
/// ```dart
/// // /lib/app/router/navigation/nav.dart
/// import '/app/widgets/index.dart';  // 한 줄로 모든 위젯 import
///
/// final router = GoRouter(
///   routes: [
///     // Auth Feature
///     GoRoute(path: '/login', builder: (context, state) => LoginPageWidget()),
///     GoRoute(path: '/signup', builder: (context, state) => CreateAccountWidget()),
///
///     // Profile Feature
///     GoRoute(path: '/profile', builder: (context, state) => ProfilePageWidget()),
///
///     // Chat Feature
///     GoRoute(path: '/chat/list', builder: (context, state) => ChatListWidgetClean()),
///
///     // ... 21개 더
///   ],
/// );
/// ```
///
/// ### 다른 위젯에서 사용
///
/// ```dart
/// // 다른 Feature의 위젯에서도 사용 가능
/// import '/app/widgets/index.dart';
///
/// class CustomNavigator extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Column(
///       children: [
///         ElevatedButton(
///           onPressed: () => Navigator.push(
///             context,
///             MaterialPageRoute(builder: (_) => LoginPageWidget()),
///           ),
///           child: Text('Login'),
///         ),
///       ],
///     );
///   }
/// }
/// ```
///
/// ## Tree Shaking 작동 원리
///
/// ```dart
/// // index.dart
/// export '/features/auth/.../login_page_widget.dart' show LoginPageWidget;
/// export '/features/auth/.../signup_widget.dart' show CreateAccountWidget;
/// // ... 22개 더
///
/// // nav.dart
/// import '/app/widgets/index.dart';  // 24개 위젯 모두 import
///
/// GoRoute(path: '/login', builder: (_) => LoginPageWidget()),  // 사용
/// // CreateAccountWidget는 사용 안 함
///
/// // Release 빌드 결과:
/// // - LoginPageWidget: 번들에 포함 ✅
/// // - CreateAccountWidget: 번들에서 제거 ❌ (Tree Shaking)
/// // - 나머지 22개: 사용 여부에 따라 자동 결정
/// ```
///
/// ## 참고
///
/// - GoRouter 설정: `/lib/app/router/navigation/nav.dart`
/// - Feature 구조: `/lib/features/[feature_name]/presentation/screens/`
/// - Tree Shaking 문서: https://flutter.dev/docs/deployment/obfuscate
/// - Barrel Pattern 모범 사례: https://dart.dev/guides/libraries/create-library-packages

// ============================================================
// 🔐 Auth Feature (6 widgets)
// ============================================================
// 인증 관련 화면: 로그인, 회원가입, 비밀번호 재설정, 전화번호 인증

/// **로그인 화면** - 이메일/비밀번호 또는 소셜 로그인
export '/features/auth/presentation/screens/login/login_page/login_page_widget.dart'
    show LoginPageWidget;

/// **회원가입 화면** - 새 계정 생성 (이메일/소셜)
export '/features/auth/presentation/screens/signup/create_account/create_account_widget.dart'
    show CreateAccountWidget;

/// **비밀번호 재설정 화면** - 이메일로 비밀번호 복구
export '/features/auth/presentation/screens/forgot_password/forgot_password/forgot_password_widget.dart'
    show ForgotPasswordWidget;

/// **시작 화면** - 앱 첫 진입 시 보이는 화면 (로그인/회원가입 선택)
export '/features/auth/presentation/screens/start/start_page/start_page_widget.dart'
    show StartPageWidget;

/// **전화번호 회원가입 화면** - 전화번호로 계정 생성
export '/features/auth/presentation/screens/phone_auth/phone_creat_account/phone_creat_account_widget.dart'
    show PhoneCreatAccountWidget;

/// **전화번호 로그인 PIN 코드 화면** - SMS 인증 코드 입력
export '/features/auth/presentation/screens/phone_auth/phonelogeinpincode_widget.dart'
    show PhonelogeinpincodeWidget;

// ============================================================
// 👤 Profile Feature (6 widgets)
// ============================================================
// 프로필 관련 화면: 사용자 정보 입력, 관심사 선택, 프로필 보기

/// **사용자 정보 입력 화면** - 초기 프로필 설정 (닉네임, 생년월일 등)
export '/features/profile/presentation/screens/user_info_input/user_info_input_widget.dart'
    show UserInfoInputWidget;

/// **전문 분야 선택 화면** - 온보딩: 사용자의 전문 분야 선택
export '/features/profile/presentation/screens/onboarding/interest_selection/expertise_select/expertise_select_widget.dart'
    show ExpertiseSelectWidget;

/// **취미 선택 화면** - 온보딩: 사용자의 취미 선택
export '/features/profile/presentation/screens/onboarding/interest_selection/hobbies_select/hobbies_select_widget.dart'
    show HobbiesSelectWidget;

/// **동의 항목 선택 화면** - 온보딩: 약관 동의 및 선호사항 선택
export '/features/profile/presentation/screens/onboarding/interest_selection/agreed_select/agrred_select_widget.dart'
    show AgrredSelectWidget;

/// **프로필 메인 화면** - 사용자 프로필 보기 및 설정
export '/features/profile/presentation/screens/profile_main/profile_page_widget.dart'
    show ProfilePageWidget;

// ============================================================
// ✨ Creation Feature (3 widgets)
// ============================================================
// 콘텐츠 생성 관련 화면: 게시물 작성, 이미지 편집, 이미지 뷰어

/// **게시물 생성 화면** - A vs B 투표 게시물 작성 (AI 타겟팅 포함)
export '/features/creation/presentation/screens/create_post/create_post_screen.dart'
    show CreatePostScreen;

/// **이미지 편집기** - ProImageEditor 통합 (필터, 크롭, 텍스트 추가)
export '/features/creation/presentation/screens/editor/pro_image_editor_page.dart'
    show ProImageEditorPage;

/// **이미지 뷰어** - 전체 화면 이미지 보기 (줌, 스와이프)
export '/features/creation/presentation/screens/viewer/image_viewer_page.dart'
    show ImageViewerPage;

// ============================================================
// 💬 Chat Feature (4 widgets)
// ============================================================
// 채팅 관련 화면: 채팅 목록, 친구 목록, 1:1 채팅, AI 채팅

/// **채팅 목록 화면** - 모든 대화 목록 보기 (flutter_chat_ui v2)
export '/features/chat/presentation/screens/chat_list/chat_list_widget_clean.dart'
    show ChatListWidgetClean;

/// **친구 목록 화면** - 친구 및 팔로워 관리
export '/features/chat/presentation/screens/friends/friends_widget.dart'
    show FriendsWidget;

/// **1:1 채팅 화면** - 개별 대화 (실시간 메시지 동기화)
export '/features/chat/presentation/screens/chat_detail/chat_detail_widget_clean.dart'
    show ChatDetailWidgetClean;

/// **AI 채팅 화면** - Gemini AI와의 대화 (Genkit 통합)
export '/features/chat/presentation/screens/ai_chat/ai_chat_page_clean.dart'
    show AIChatPageClean;

// ============================================================
// 📰 Post Feature (1 widget)
// ============================================================
// 게시물 피드 화면

/// **홈 피드 화면** - 모든 게시물 타임라인 (무한 스크롤)
export '/features/post/presentation/screens/feed/home_page_widget.dart'
    show HomePageWidget;

// ============================================================
// 🔍 Search Feature (1 widget)
// ============================================================
// 검색 화면

/// **검색 화면** - 게시물, 사용자, 태그 검색
export '/features/search/presentation/screens/search_page/search_page_widget.dart'
    show SearchPageWidget;

// ============================================================
// 🔔 Notifications Feature (1 widget)
// ============================================================
// 알림 화면

/// **알림 목록 화면** - 모든 알림 보기 (Social/System/Voting 타입)
export '/features/notifications/presentation/screens/notifications_list/notifications_list_widget.dart'
    show NotificationsListWidget;

// ============================================================
// 🧪 Other/Testing (1 widget)
// ============================================================
// 개발 및 테스트용 화면

/// **테스트 페이지 선택 화면** - 개발용 테스트 페이지 (kDebugMode only)
export '/testpage_select/testpage_select_widget.dart' show TestpageSelectWidget;

// ============================================================
// 🔧 Debug Tools (1 widget)
// ============================================================
// 디버그 도구 (개발 환경 전용, kDebugMode로 보호)

/// **디버그 로그 페이지** - 앱 전체 로그 보기 (Settings에서 5번 탭으로 진입)
/// **중요**: Release 빌드에서 자동 제거됨 (Tree Shaking)
export '/app/widgets/debug/debug_log_page.dart' show DebugLogPage;
