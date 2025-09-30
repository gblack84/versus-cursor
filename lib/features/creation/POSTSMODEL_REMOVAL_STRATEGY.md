## 🆕 PostsModel 제거 전략 (2025-01-28)

### 📊 현재 진행 상황 (2025-01-28 12:50)

#### ✅ 완료된 작업
1. **Phase 1-4 완료**: 인프라 구축에서 Services 전환까지
   - PostBundle을 /app/contracts/models로 이동
   - V2 Repository 인터페이스 및 구현 생성
   - UseCase들 V2로 전환 (GetFeedUseCase, CreatePostUseCase)
   - HomePageWidget UI를 PostDisplay로 변경
   - UnifiedCacheService가 이미 Map<String, dynamic> 사용 중

#### 🔄 진행중인 작업
1. **Voting Feature 마이그레이션 필요**
   - VoteUseCase가 아직 IPostRepository V1 사용
   - Creation의 IPostRepository에 의존

2. **V1 인터페이스 제거 준비**
   - i_post_creation_repository.dart (V1)
   - post_repository_impl.dart (V1 impl)
   - 아직 V1 참조하는 코드가 있어 점진적 제거 필요

#### 📝 남은 작업
- [ ] Voting Feature의 VoteUseCase를 V2로 전환
- [ ] posts_model_adapter.dart 최종 정리
- [ ] V1 인터페이스 및 구현체 제거
- [ ] PostsModel 파일 제거
- [ ] 백업 파일들(.backup) 삭제

---

### 새로 생성된 V2 인프라

#### 1. Contract Layer (`/app/contracts/`)
- `models/post_bundle.dart` - Feature 간 통신 모델
- `cache_contract.dart` - Services 레이어 인터페이스

#### 2. Post Feature V2
- `domain/models/post_display.dart` - UI 프레젠테이션 모델
- `domain/repositories/i_post_display_repository_v2.dart` 
- `data/repositories/post_display_repository_v2_impl.dart`

#### 3. Creation Feature V2  
- `domain/repositories/i_post_creation_repository_v2.dart`
- `data/repositories/post_creation_repository_v2_impl.dart`

### 점진적 마이그레이션 단계

#### Phase 1: 인프라 구축 ✅ (완료)
- PostBundle을 app/contracts/models로 이동
- CacheContract 생성
- V2 Repository 인터페이스 생성

#### Phase 2: 병렬 운영 ✅ (완료)
```dart
// 기존 코드 (계속 작동)
final postsModel = await repository.getPostById(postId);

// 새 코드 (점진적 전환)
final postBundle = await repositoryV2.getPostBundle(postId);
```

#### Phase 3: UI 전환 ✅ (완료)
```dart
// Before
StreamBuilder<List<PostsModel>>(...)

// After  
StreamBuilder<List<Map<String, dynamic>>>(
  builder: (context, snapshot) {
    final posts = snapshot.data?.map((data) => 
      PostDisplay.fromMap(data, data['id'])
    ).toList();
  }
)
```

#### Phase 4: Services 전환 ✅ (완료)
```dart
// UnifiedCacheService 수정
@override
Future<List<Map<String, dynamic>>> getFeedPosts() {
  // PostsModel 대신 Map 반환
}
```

#### Phase 5: 레거시 제거 (진행중)
- PostsModel 파일 제거
- V1 Repository 제거
- 관련 import 정리

### 주요 이점
- ✅ FirestoreRecord 의존성 제거
- ✅ Domain Layer 순수성 확보  
- ✅ Feature 간 명확한 경계
- ✅ 점진적 마이그레이션 가능
- ✅ 롤백 가능한 구조
