# Phase 3.1: Backend 역방향 의존성 제거 마이그레이션 가이드

## 🎯 목표
backend.dart의 51개 Features 역방향 의존성을 완전히 제거하여 Clean Architecture 원칙 준수

## 📊 현재 상황
- **문제점**: backend.dart가 Features 레이어의 51개 파일을 직접 import (46개 모델 + 5개 Repository)
- **영향도**: 🔴 Critical - 아키텍처 무결성 훼손
- **예상 시간**: 3-4시간
- **위험도**: Medium (기존 코드 동작 유지 필요)

---

## 📝 Task 1: 의존성 분석 및 매핑 (30분)

### Task 1.1: 현재 의존성 목록 작성 ✅ (완료: 2025-01-09)
**목표**: 51개 역방향 의존성 완전 파악
**도구**: Inventory Scout 서브에이전트
**산출물**: dependency_map.json ✅

```bash
# 실행 완료
grep -n "import.*'/features/" lib/backend/backend.dart > dependency_list.txt
```

**체크리스트** (실제 분석 결과):
- [x] auth 관련 imports (실제: 3개)
- [x] posts 관련 imports (실제: 9개)  
- [x] profile 관련 imports (실제: 11개)
- [x] chat 관련 imports (실제: 6개)
- [x] voting 관련 imports (실제: 5개)
- [x] notifications 관련 imports (실제: 3개)
- [x] search 관련 imports (실제: 1개)
- [x] repository imports (실제: 5개)

**발견사항**: 총 51개 역방향 의존성 (46개 모델 + 5개 Repository 구현체)

### Task 1.2: 사용 패턴 분석 ✅ (완료: 2025-01-09)
**목표**: 각 import가 사용되는 위치와 방식 파악
**도구**: 서브에이전트를 통한 코드 분석
**산출물**: usage_patterns.md ✅

**분석 결과**:
- 16개 함수 (35%): 이미 Repository 패턴 사용 ✅
- 24개 함수 (52%): 직접 Firestore 쿼리 사용 ❌
- 6개 함수 (13%): 기타

**발견된 문제**:
- PostRepositoryImpl이 싱글톤이 아님 (성능 문제)
- AuthUtil import 미사용 (즉시 제거 가능)
- 24개 함수가 여전히 직접 모델 접근

### Task 1.3: 의존성 그래프 생성 ✅ (완료: 2025-01-09)
**목표**: 시각적 의존성 맵 생성
**도구**: Mermaid 다이어그램
**산출물**: dependency_graph.mmd ✅

**그래프 특징**:
- Feature별 의존성 분포 시각화
- 마이그레이션 상태 색상 코딩 (녹색: 완료, 빨강: 미완료)
- 우선순위 레벨 표시 (P1~P4)
- Profile 기능이 11개로 가장 높은 결합도

---

## 📝 Task 2: Repository 인터페이스 패턴 구현 (1시간)

### Task 2.1: Core 레이어에 Repository 인터페이스 정의 ✅ (완료: 2025-01-09)
**위치**: `/lib/core/repositories/`
**도구**: 서브에이전트를 통한 인터페이스 생성

**생성된 Repository 인터페이스**:
- ✅ PostRepository - Posts, Comments, Likes, Dislikes, RankedPosts
- ✅ UserRepository - Users, Friends, Settings, Characters  
- ✅ ChatRepository - Chats, Messages, GroupChats, GroupMessages, ChatHistory
- ✅ NotificationRepository - Notifications (legacy & new models)
- ✅ VotingRepository - Votecounts, VoteExpansion, Rankings, Weights
- ✅ MediaRepository - Images, Videos, Encodings
- ✅ SearchRepository - SearchHistory, Full-text search

**총 7개 Repository 인터페이스 생성 완료**

### Task 2.2: Feature 레이어 구현체 연결
**위치**: `/lib/features/*/data/repositories/`

```dart
// lib/features/posts/data/repositories/post_repository_impl.dart
class PostRepositoryImpl implements PostRepository {
  @override
  Stream<List<PostsModel>> queryPosts({...}) {
    // 기존 구현 유지
    return postsModelQuery(queryBuilder: queryBuilder, limit: limit);
  }
}
```

### Task 2.3: Repository 인터페이스 Export
**위치**: `/lib/core_exports.dart`

```dart
// Core Repository Interfaces
export 'core/repositories/post_repository.dart';
export 'core/repositories/user_repository.dart';
// ... 나머지 repositories
```

---

## 📝 Task 3: 의존성 주입(DI) 설정 (1시간)

### Task 3.1: GetIt 설정 파일 생성
**위치**: `/lib/app/di/injection_container.dart`

```dart
import 'package:get_it/get_it.dart';

final sl = GetIt.instance; // Service Locator

Future<void> init() async {
  // Features - Posts
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(),
  );
  
  // Features - Auth
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(),
  );
  
  // Features - Chat
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(),
  );
  
  // ... 나머지 repositories
}
```

### Task 3.2: main.dart에서 DI 초기화
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // DI 초기화
  await init();
  
  // 기존 초기화 코드...
  await Firebase.initializeApp();
}
```

### Task 3.3: Backend.dart를 Adapter로 변환
**목표**: backend.dart를 DI를 사용하는 Adapter로 변환

```dart
// lib/backend/backend.dart
import 'package:get_it/get_it.dart';
import '/core_exports.dart';

class BackendAdapter {
  final _postRepo = GetIt.instance<PostRepository>();
  final _userRepo = GetIt.instance<UserRepository>();
  
  // 기존 메서드들을 Repository 호출로 위임
  Stream<List<PostsModel>> queryPostsModel({...}) {
    return _postRepo.queryPosts(
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }
}
```

---

## 📝 Task 4: Adapter 패턴으로 점진적 마이그레이션 (30분)

### Task 4.1: Legacy Adapter 생성
**목표**: 기존 코드와의 호환성 유지

```dart
// lib/backend/legacy_adapter.dart
class LegacyBackendAdapter {
  static final instance = LegacyBackendAdapter._();
  LegacyBackendAdapter._();
  
  // 기존 static 메서드들을 instance 메서드로 래핑
  Stream<List<PostsModel>> queryPostsModel({...}) {
    return GetIt.instance<PostRepository>().queryPosts(...);
  }
}

// 기존 코드 호환을 위한 전역 함수
Stream<List<PostsModel>> queryPostsModel({...}) {
  return LegacyBackendAdapter.instance.queryPostsModel(...);
}
```

### Task 4.2: Import 경로 업데이트
**목표**: Features import를 Core import로 변경

```dart
// Before
import '/features/posts/data/models/posts_model.dart';
import '/features/posts/data/repositories/post_repository_impl.dart';

// After  
import '/core_exports.dart'; // Repository interfaces
import '/app/di/injection_container.dart'; // DI
```

### Task 4.3: 단계별 마이그레이션 실행
**전략**: Feature별로 순차 진행

1. **Auth** (5개 imports) → 10분
2. **Posts** (8개 imports) → 15분  
3. **Chat** (7개 imports) → 15분
4. **Profile** (6개 imports) → 10분
5. **Voting** (5개 imports) → 10분
6. **Notifications** (4개 imports) → 10분
7. **Search** (6개 imports) → 10분

---

## 📝 Task 5: 검증 및 테스트 (1시간)

### Task 5.1: 컴파일 검증
```bash
flutter analyze lib/backend/
flutter build apk --debug
```

**성공 기준**:
- [ ] 0 errors
- [ ] 0 warnings
- [ ] 빌드 성공

### Task 5.2: 단위 테스트 작성
```dart
// test/backend/adapter_test.dart
void main() {
  setUpAll(() async {
    await init(); // DI 초기화
  });
  
  test('PostRepository through DI works', () async {
    final adapter = BackendAdapter();
    final stream = adapter.queryPostsModel();
    
    expect(stream, isA<Stream<List<PostsModel>>>());
  });
}
```

### Task 5.3: 통합 테스트
```dart
// integration_test/backend_migration_test.dart
void main() {
  testWidgets('App starts with new backend architecture', (tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();
    
    // 주요 화면들이 정상 로드되는지 확인
    expect(find.byType(HomePage), findsOneWidget);
  });
}
```

### Task 5.4: 성능 검증
**목표**: 마이그레이션 전후 성능 동일 확인

```dart
// 측정 항목
1. 앱 시작 시간: < 2초
2. 첫 화면 로딩: < 500ms  
3. 메모리 사용량: 변화 없음
4. Firestore 쿼리 속도: 변화 없음
```

---

## 🔄 롤백 계획

### 즉시 롤백 가능 지점
1. **DI 초기화 전**: main.dart 수정 revert
2. **Repository 인터페이스 생성 후**: 파일 삭제만으로 롤백
3. **backend.dart 수정 후**: Git stash 활용

### 롤백 명령어
```bash
# 전체 롤백
git stash
git checkout HEAD -- lib/backend/backend.dart

# 부분 롤백 (DI만)
git checkout HEAD -- lib/app/di/
git checkout HEAD -- lib/main.dart
```

---

## ✅ 완료 체크리스트

### Phase 3.1 전체 진행상황
- [ ] Task 1: 의존성 분석 (30분)
  - [ ] 1.1: 의존성 목록 작성
  - [ ] 1.2: 사용 패턴 분석
  - [ ] 1.3: 의존성 그래프 생성
  
- [ ] Task 2: Repository 인터페이스 (1시간)
  - [ ] 2.1: 인터페이스 정의
  - [ ] 2.2: 구현체 연결
  - [ ] 2.3: Export 설정
  
- [ ] Task 3: DI 설정 (1시간)
  - [ ] 3.1: GetIt 설정
  - [ ] 3.2: main.dart 초기화
  - [ ] 3.3: Adapter 변환
  
- [ ] Task 4: Adapter 패턴 (30분)
  - [ ] 4.1: Legacy Adapter
  - [ ] 4.2: Import 업데이트
  - [ ] 4.3: 단계별 실행
  
- [ ] Task 5: 검증 (1시간)
  - [ ] 5.1: 컴파일 검증
  - [ ] 5.2: 단위 테스트
  - [ ] 5.3: 통합 테스트
  - [ ] 5.4: 성능 검증

**총 예상 시간**: 3시간 30분
**실제 소요 시간**: ___________

---

## 📌 주의사항

1. **순서 준수**: Task 1→2→3→4→5 순서 반드시 준수
2. **백업**: 각 Task 시작 전 Git commit
3. **테스트**: 각 Feature 마이그레이션 후 즉시 테스트
4. **문서화**: 변경사항 즉시 문서 업데이트
5. **커뮤니케이션**: 팀원과 진행상황 공유

## 🎯 성공 기준

✅ backend.dart의 Features import 0개
✅ 모든 기능 정상 동작
✅ 테스트 커버리지 80% 이상
✅ 성능 저하 없음
✅ Clean Architecture 원칙 준수