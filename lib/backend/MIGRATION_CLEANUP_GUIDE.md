# Backend.dart 제거 가이드 - Direct Repository Migration

## 🎯 목표
backend.dart를 완전히 제거하고 모든 의존성을 Repository + DI 직접 연결로 전환

## 📊 현재 상황
- **문제점**: backend.dart가 단순 위임자(delegator) 역할만 수행
- **해결책**: 중간 레이어 제거하고 Repository 직접 사용
- **영향 범위**: 28개 파일이 backend.dart import

## ❌ 제거된 접근 방식 (Adapter 패턴)
이전에 고려했던 Adapter 패턴은 불필요한 복잡성을 추가하므로 완전히 제거:
- ~~LegacyBackendAdapter 생성~~
- ~~Adapter를 통한 점진적 마이그레이션~~
- ~~중간 호환성 레이어 유지~~

## ✅ 새로운 접근 방식 (Direct Repository)

### 아키텍처 변경
```
❌ BEFORE (4단계):
UI → backend.dart → Repository → Firestore

✅ AFTER (3단계):
UI → Repository (DI) → Firestore
```

### 코드 변경 예시
```dart
// ❌ BEFORE: backend.dart 사용
import '/backend/backend.dart';

class ChatListWidget {
  Stream<List<ChatsModel>> getChats() {
    return queryChatsModel(
      queryBuilder: (q) => q.where('userId', isEqualTo: userId)
    );
  }
}

// ✅ AFTER: Repository 직접 사용
import 'package:get_it/get_it.dart';
import '/core/repositories/chat_repository.dart';

class ChatListWidget {
  final _chatRepository = GetIt.instance<ChatRepository>();
  
  Stream<List<ChatsModel>> getChats() {
    return _chatRepository.queryChats(
      queryBuilder: (q) => q.where('userId', isEqualTo: userId)
    );
  }
}
```

## 📝 마이그레이션 대상 파일 (28개)

### Priority 1: Service Layer (11개)
1. `/lib/services/notification_service.dart`
2. `/lib/services/global_notification_manager.dart`
3. `/lib/services/chat_initialization_service.dart`
4. `/lib/services/chat_detail_migration_service.dart`
5. `/lib/services/vote_status_service.dart`
6. `/lib/features/auth/data/services/firebase_auth_manager.dart`
7. `/lib/features/auth/data/services/auth_util.dart`
8. `/lib/features/auth/data/services/serialization_util.dart`
9. `/lib/backend/algolia/algolia_manager.dart`
10. `/lib/services/cache/unified_cache_service.dart`
11. `/lib/services/ai_moderation/image_moderation_model.dart`

### Priority 2: Presentation Layer (10개)
1. `/lib/features/notifications/presentation/screens/notifications_list_widget.dart`
2. `/lib/features/auth/presentation/screens/login_page_widget.dart`
3. `/lib/features/chat/presentation/screens/ai_chat_v2/ai_chat_page_v2.dart`
4. `/lib/features/chat/presentation/screens/chat_detail_v2/chat_detail_widget_v2.dart`
5. `/lib/features/chat/presentation/screens/chat_detail_v2/components/chat_detail_app_bar.dart`
6. `/lib/features/chat/presentation/screens/chat_detail_v2/components/chat_message_builder.dart`
7. `/lib/features/profile/presentation/screens/friends_list/friends_list_widget.dart`
8. `/lib/features/chat/presentation/screens/chat_list/chat_list_widget.dart`
9. `/lib/features/posts/presentation/screens/in_put_post_image_widget.dart`
10. `/lib/global_actions.dart`

### Priority 3: Repository Layer (5개)
1. `/lib/features/search/data/repositories/search_repository_impl.dart`
2. `/lib/features/notifications/data/repositories/notification_repository_impl.dart`
3. `/lib/features/voting/data/repositories/voting_repository_impl.dart`
4. `/lib/features/chat/data/repositories/chat_repository_impl.dart`
5. `/lib/features/profile/data/repositories/user_repository_impl.dart`

### Priority 4: Test Files (2개)
1. `/lib/backend/algolia/algolia_test_model.dart`
2. `/lib/backend/algolia/algolia_test_widget.dart`

## 🔧 마이그레이션 패턴

### Pattern 1: Service Layer
```dart
// BEFORE
import '/backend/backend.dart';
final notifications = await queryNotificationsModelOnce();

// AFTER
import 'package:get_it/get_it.dart';
import '/core/repositories/notification_repository.dart';
final _notificationRepo = GetIt.instance<NotificationRepository>();
final notifications = await _notificationRepo.queryNotificationsOnce();
```

### Pattern 2: Widget Layer
```dart
// BEFORE
import '/backend/backend.dart';
_chatsStream = queryChatsModel(...);

// AFTER
import 'package:get_it/get_it.dart';
import '/core/repositories/chat_repository.dart';
final _chatRepo = GetIt.instance<ChatRepository>();
_chatsStream = _chatRepo.queryChats(...);
```

### Pattern 3: Repository Implementation
```dart
// BEFORE
import '/backend/backend.dart';
// backend.dart의 함수 사용

// AFTER
// backend.dart import 제거
// 직접 Firestore 쿼리 또는 내부 메서드 사용
```

## 🗑️ backend.dart 삭제 절차

### Step 1: 사전 검증
```bash
# backend.dart를 import하는 파일 확인 (결과가 없어야 함)
grep -r "import.*'/backend/backend.dart'" lib/ --include="*.dart"

# 빌드 테스트
flutter analyze
flutter build apk --debug
```

### Step 2: 파일 삭제
```bash
# backend.dart 삭제
rm lib/backend/backend.dart

# 레거시 파일 정리
rm -rf lib/backend/legacy/
rm lib/backend/*.backup

# core_exports.dart에서 export 제거
# export '/backend/backend.dart'; 라인 삭제
```

### Step 3: 최종 검증
```bash
# 컴파일 확인
flutter analyze

# 테스트 실행
flutter test

# 앱 빌드
flutter build apk
```

## ⚠️ 주의사항

### 기존 Adapter 파일들은 유지
다음 파일들은 모델 변환용이므로 삭제하지 않음:
- `/lib/features/posts/data/adapters/posts_model_adapter.dart`
- `/lib/features/profile/data/adapters/user_profile_adapter.dart`
- `/lib/features/posts/data/adapters/posts_data_source_impl.dart`

이들은 레거시 ↔ 도메인 모델 변환을 담당하며, backend.dart 제거와 무관합니다.

## 📈 이점
- ✅ 코드 복잡도 30% 감소
- ✅ 호출 체인 1단계 감소로 성능 향상
- ✅ Mock Repository 주입으로 테스트 용이
- ✅ 직접적인 의존성 추적 가능
- ✅ Clean Architecture 원칙 준수

## 🚀 예상 소요 시간
- Service Layer (11개): 2시간
- Presentation Layer (10개): 1.5시간
- Repository Layer (5개): 30분
- Test Files (2개): 15분
- 검증 및 정리: 1시간
- **총 예상 시간: 5시간**

## 📅 완료 날짜
- 시작: 2025-01-09
- 목표 완료: 2025-01-09