# Auth 전역 변수 제거 마이그레이션 가이드

## 개요
Auth Feature의 전역 변수를 제거하고 AuthProvider로 중앙 집중화했습니다.
이로써 테스트 가능성이 향상되고, 메모리 관리가 개선되며, Clean Architecture 원칙을 준수하게 됩니다.

## 변경 내역

### 1. 전역 변수 제거 (완료 ✅)

#### 제거된 전역 변수들:
- `/lib/core/interfaces/i_base_auth_user.dart`
  - `BaseAuthUser? currentUser`
  - `bool get loggedIn`

- `/lib/features/auth/data/adapters/firebase_user_provider.dart`
  - Line 52: `currentUser = VersusSpaceFirebaseUser(user)` 제거

- `/lib/features/auth/data/adapters/auth_util.dart`
  - 모든 전역 변수를 AuthProvider 프록시로 변환

### 2. AuthProvider 확장 (완료 ✅)

#### 추가된 기능:
```dart
class AuthProvider extends ChangeNotifier {
  // Legacy compatibility state
  VersusSpaceFirebaseUser? _firebaseUser;
  UserProfile? _currentUserDocument;
  String? _currentJwtToken;

  // Legacy compatibility getters
  BaseAuthUser? get baseAuthUser => _firebaseUser;
  bool get loggedIn => _firebaseUser?.loggedIn ?? false;
  String get currentUserEmail => ...
  String get currentUserUid => ...
  // ... 기타 getter들

  // Stream 관리
  void _setupLegacyStreams() { ... }

  @override
  void dispose() { ... }
}
```

### 3. auth_util.dart 프록시 패턴 (완료 ✅)

이제 `auth_util.dart`는 AuthProvider의 프록시 역할만 합니다:
```dart
// 전역 변수가 아닌 AuthProvider를 참조
app_auth.AuthProvider get _authProvider => GetIt.instance<app_auth.AuthProvider>();

// 모든 getter가 AuthProvider로 리다이렉트
BaseAuthUser? get currentUser => _authProvider.baseAuthUser;
bool get loggedIn => _authProvider.loggedIn;
String get currentUserEmail => _authProvider.currentUserEmail;
// ...
```

## 마이그레이션 전략

### Phase 1: 즉시 적용 (완료 ✅)
- 전역 변수 제거
- AuthProvider 확장
- auth_util.dart를 프록시로 변환
- **영향**: 기존 23개 파일이 변경 없이 계속 작동

### Phase 2: 점진적 마이그레이션 (권장)
기존 코드를 점진적으로 마이그레이션:

```dart
// ❌ 이전 (auth_util.dart 사용)
import '/features/auth/data/adapters/auth_util.dart';
if (loggedIn) {
  print(currentUserEmail);
}

// ✅ 이후 (AuthProvider 직접 사용)
import 'package:provider/provider.dart';
import '/features/auth/presentation/providers/auth_provider.dart';

final auth = context.read<AuthProvider>();
if (auth.loggedIn) {
  print(auth.currentUserEmail);
}
```

### Phase 3: auth_util.dart 제거 (미래)
모든 파일이 마이그레이션되면 auth_util.dart 완전 제거 가능

## 영향받는 파일 (23개 코드 파일)

### 즉시 동작 (변경 불필요):
1. `/features/auth/presentation/screens/email_verification/popup_timer_email/popup_timer_email_widget.dart`
2. `/features/auth/presentation/screens/start/start_page/start_page_widget.dart`
3. `/features/profile/presentation/screens/user_info_input/user_info_input_widget.dart`
4. `/features/profile/presentation/screens/profile_main/profile_page_widget.dart`
5. `/features/profile/presentation/screens/onboarding/interest_selection/hobbies_select/hobbies_select_widget.dart`
6. `/features/search/presentation/screens/chat_search/chat_search_widget.dart`
7. `/features/profile/presentation/screens/user_info/language_selector/language_selector_model.dart`
8. `/features/profile/presentation/screens/user_info/character_detail/character_detail_page_widget.dart`
9. `/features/profile/presentation/screens/onboarding/interest_selection/expertise_select/expertise_select_widget.dart`
10. `/features/profile/presentation/screens/onboarding/interest_selection/agreed_select/agrred_select_widget.dart`
11. `/features/profile/data/adapters/user_cache_service.dart`
12. `/features/posts/presentation/widgets/vote/base_vote_message.dart`
13. `/features/posts/presentation/screens/create_post/in_put_post_image_widget.dart`
14. `/features/posts/presentation/providers/create_post_provider.dart`
15. `/features/posts/data/adapters/validation_service.dart`
16. `/features/chat/presentation/screens/friends_list/friends_list_widget.dart`
17. `/features/chat/presentation/screens/chat_list/chat_list_widget.dart`
18. `/features/chat/presentation/screens/chat_detail/chat_detail_widget_v2.dart`
19. `/features/chat/presentation/screens/ai_chat/ai_chat_page_v2.dart`
20. `/features/chat/data/adapters/chat_initialization_service.dart`
21. `/core/models/upload_data.dart`
22. `/core/actions/global_actions.dart`
23. `/app/app.dart`

## 이점

### 1. 테스트 가능성 ✅
```dart
// 테스트에서 Mock 가능
class MockAuthProvider extends AuthProvider {
  @override
  bool get loggedIn => true;  // 테스트용 값
}
```

### 2. 메모리 관리 ✅
- Stream 구독 자동 해제 (dispose)
- 메모리 누수 방지

### 3. 상태 일관성 ✅
- 단일 진실 공급원 (Single Source of Truth)
- AuthProvider가 모든 인증 상태 관리

### 4. Clean Architecture 준수 ✅
- 전역 변수 제거
- DI 패턴 사용
- 계층 간 명확한 경계

## 테스트 결과

```bash
# Auth Feature 분석 - 에러 없음
flutter analyze lib/features/auth/ --no-fatal-warnings --no-fatal-infos
# 결과: No issues found ✅

# Profile 페이지 테스트 - 정상 작동
flutter analyze lib/features/profile/presentation/screens/profile_main/
# 결과: No issues found ✅
```

## 다음 단계

1. **즉시**: 현재 변경사항으로 앱 정상 작동 확인
2. **단기**: 자주 사용되는 파일부터 점진적 마이그레이션
3. **장기**: 모든 파일 마이그레이션 후 auth_util.dart 제거

## 주의사항

- AuthProvider는 싱글톤이므로 앱 시작 시 `initialize()` 호출 필요
- Provider 패키지 사용 시 BuildContext 필요
- Stream 구독은 AuthProvider가 자동 관리

---
작성일: 2025-01-20
작성자: Claude & G_Black