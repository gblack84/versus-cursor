# Feature Separation Plan: Posts → Creation + Post

> 작성일: 2025-01-26
> 최종 수정: 2025-01-26
> 작성자: Architecture Team
> 버전: 2.0
> 목적: Posts Feature를 Creation과 Post 두 개의 독립적인 Feature로 분리

## 📋 Executive Summary

현재 Posts Feature는 두 가지 완전히 다른 비즈니스 도메인을 포함하고 있습니다:
- **Creation Domain (70%)**: 콘텐츠 작성, 미디어 업로드, AI 검열, 타겟 설정
- **Post Domain (30%)**: 피드 표시, 게시물 관리, 댓글/좋아요, 랭킹

이는 Single Responsibility Principle(SRP)을 위반하며, Clean Architecture 마이그레이션의 주요 장애물입니다.

## 🎯 목표 및 원칙

### 목표
1. **책임 분리**: Creation과 Post를 독립적인 Feature로 분리
2. **의존성 최소화**: Feature 간 의존성을 Contract 패턴으로 관리
3. **효율성**: 최소한의 파일 이동으로 목표 달성
4. **안정성**: Git history 보존 및 점진적 마이그레이션

### 원칙
- ✅ **UI/UX 변경 없음**: 사용자 경험 100% 유지
- ✅ **기능 보존**: 모든 기능 정상 작동
- ✅ **점진적 진행**: 한 번에 하나씩, 검증하며 진행
- ✅ **롤백 가능**: 각 단계별 커밋으로 즉시 복구 가능

## 📊 현재 상태 분석

### 파일 분포 (정밀 분석 완료)
```
전체 파일: 120개 (정확한 카운트)
├── Creation 관련: 85개 (70.8%)
│   ├── 작성 화면 및 위젯
│   ├── 미디어 업로드/편집
│   ├── AI 검열 시스템
│   └── 타겟 오디언스
├── Post 관련: 25개 (20.8%)
│   ├── 피드 표시
│   ├── Post 메트릭/통계
│   ├── 댓글/좋아요
│   └── 랭킹 시스템
└── 기타: 10개 (8.4%)
    ├── 공통 모델 (post.dart, posts_model.dart)
    ├── Voting으로 이동 필요 (2개)
    └── 공통 컴포넌트 (viewer 등)
```

### 비즈니스 플로우
```
사용자 작성 → AI 검열 → 투표 요청 → 10분 투표 → 완료 → 피드 게시
    ↓            ↓          ↓            ↓         ↓        ↓
Creation    Creation    Voting      Voting    Voting     Post
Feature     Feature     Feature     Feature   Feature   Feature
```

## 🔄 전략: Rename & Split

### 선택한 전략: Posts → Creation Rename
1. **Posts 전체를 Creation으로 rename** (70% 유지)
2. **새로운 Post Feature 생성**
3. **Post 관련 파일만 이동** (30% 이동)

### 전략 비교
| 측면 | 전략 A: Creation 이동 | 전략 B: Posts Rename (선택) |
|-----|---------------------|------------------------|
| 파일 이동 | 85개 (70%) | 25개 (20%) |
| Import 수정 | 많음 | 적음 |
| Git History | 손실 위험 | 대부분 보존 |
| 작업 시간 | ~8시간 | ~2.5시간 |
| 리스크 | 높음 | 낮음 |

## 📝 실행 계획

### Phase 0: 사전 준비 및 정리 (15분)
```bash
# 0.1 Git 백업 커밋 생성
git add -A
git commit -m "backup: Before Posts feature separation"

# 0.2 Voting Feature로 파일 이동
mv lib/features/posts/domain/usecases/voting_usecases.dart \
   lib/features/voting/domain/usecases/

# 0.3 Poll 관련 파일 이동 (선택적 - Voting과 관련된 경우만)
# mv lib/features/posts/data/models/poll_details_model.dart \
#    lib/features/voting/data/models/

# 0.4 이동한 파일의 import 경로 수정
find lib -name "*.dart" \
  -exec sed -i 's|/posts/domain/usecases/voting_usecases|/voting/domain/usecases/voting_usecases|g' {} \;

# 0.5 검증
flutter analyze | grep -E "(voting_usecases|poll_details)"
```

### Phase 1: Posts → Creation Rename (30분)
```bash
# 1.1 디렉토리 이름 변경
mv lib/features/posts lib/features/creation

# 1.2 내부 import 경로 일괄 변경
find lib/features/creation -name "*.dart" \
  -exec sed -i 's|/features/posts/|/features/creation/|g' {} \;

# 1.3 외부 참조 경로 변경
find lib -name "*.dart" \
  -exec sed -i 's|/features/posts/|/features/creation/|g' {} \;

# 1.4 검증
flutter analyze
```

### Phase 2: Post Feature 구조 생성 (10분)
```bash
# 2.1 디렉토리 구조 생성
mkdir -p lib/features/post/{domain,data,presentation}
mkdir -p lib/features/post/domain/{models,repositories,usecases}
mkdir -p lib/features/post/data/{models,repositories,datasources}
mkdir -p lib/features/post/presentation/{screens,widgets,providers}

# 2.2 기본 export 파일 생성
echo "// Post Feature exports" > lib/features/post/post.dart
```

### Phase 3: Post 관련 파일 이동 (45분)

#### 3.1 Domain Layer 이동 (7개 파일)
```bash
# Post 관련 모델들 (5개)
mv lib/features/creation/domain/models/post_metrics.dart \
   lib/features/post/domain/models/

mv lib/features/creation/domain/models/post_stats.dart \
   lib/features/post/domain/models/

mv lib/features/creation/domain/models/{comments_model.dart,likes_model.dart,dislikes_model.dart} \
   lib/features/post/domain/models/

mv lib/features/creation/domain/models/ranked_posts_model.dart \
   lib/features/post/domain/models/

# UseCase (1개)
mv lib/features/creation/domain/usecases/get_feed_usecase.dart \
   lib/features/post/domain/usecases/

# 참고: post.dart, posts_model.dart, post_core.dart는 공통 모델로 Creation에 유지
# 나중에 Contract 패턴으로 처리 (Phase 5)
```

#### 3.2 Data Layer 이동 (7개 파일)
```bash
# Data Models (6개)
mv lib/features/creation/data/models/{comments_model.dart,likes_model.dart,dislikes_model.dart} \
   lib/features/post/data/models/

mv lib/features/creation/data/models/shares_model.dart \
   lib/features/post/data/models/

mv lib/features/creation/data/models/{feed_details_model.dart,ranked_posts_model.dart} \
   lib/features/post/data/models/

# Adapter 확인 필요 (1개)
# post_model_adapter.dart가 있다면 이동
# mv lib/features/creation/presentation/adapters/post_model_adapter.dart \
#    lib/features/post/presentation/adapters/
```

#### 3.3 Presentation Layer 이동 (11개 파일)
```bash
# Screens (2개 - feed 디렉토리 전체)
mv lib/features/creation/presentation/screens/feed \
   lib/features/post/presentation/screens/

# Provider (1개)
mv lib/features/creation/presentation/providers/feed_provider.dart \
   lib/features/post/presentation/providers/

# Adapter 확인 (1개)
mv lib/features/creation/presentation/adapters/post_model_adapter.dart \
   lib/features/post/presentation/adapters/
```

### Phase 4: Import 경로 정리 (30분)
```bash
# 4.1 Post 내부 import 수정
find lib/features/post -name "*.dart" \
  -exec sed -i 's|/features/creation/|/features/post/|g' {} \;

# 4.2 Creation에서 Post 모델 참조 수정
find lib/features/creation -name "*.dart" \
  -exec sed -i 's|/creation/domain/models/posts_model|/post/domain/models/post_model|g' {} \;

# 4.3 외부에서 Post 참조 수정
find lib -name "*.dart" \
  -exec sed -i 's|/features/creation/presentation/screens/feed|/features/post/presentation/screens/feed|g' {} \;

# 4.4 검증
flutter analyze
```

### Phase 4.5: Repository 인터페이스 분리 (30분)
```dart
// 기존 i_post_repository.dart를 분리

// lib/features/creation/domain/repositories/i_creation_repository.dart
abstract class ICreationRepository {
  Future<Either<Failure, Post>> createPost(PostData data);
  Future<Either<Failure, bool>> moderateContent(String content);
  Future<Either<Failure, List<String>>> uploadMedia(List<File> files);
  Future<Either<Failure, TargetAudience>> setTargetAudience(TargetData data);
}

// lib/features/post/domain/repositories/i_feed_repository.dart
abstract class IFeedRepository {
  Future<Either<Failure, List<Post>>> getFeed({int? limit, String? lastId});
  Future<Either<Failure, PostMetrics>> getPostMetrics(String postId);
  Future<Either<Failure, bool>> likePost(String postId);
  Future<Either<Failure, bool>> commentOnPost(String postId, String comment);
}

// 구현체도 분리
// creation/data/repositories/creation_repository_impl.dart
// post/data/repositories/feed_repository_impl.dart
```

### Phase 5: Export 파일 정리 (15분)
```dart
// lib/features/creation/creation.dart
export 'domain/models/target_audience.dart';
export 'domain/usecases/create_post_usecase.dart';
export 'domain/usecases/moderate_content_usecase.dart';
export 'presentation/providers/create_post_provider.dart';
export 'presentation/screens/create_post/create_post_screen.dart';

// lib/features/post/post.dart
export 'domain/models/post_model.dart';
export 'domain/models/post_metrics.dart';
export 'domain/repositories/i_post_repository.dart';
export 'presentation/providers/feed_provider.dart';
export 'presentation/screens/feed/home_page_widget.dart';
```

### Phase 5.5: 공통 모델 Contract 패턴 구현 (20분)
```dart
// lib/core/contracts/post_contract.dart
// 공통으로 사용되는 Post 모델 정의
class PostContract {
  final String id;
  final String title;
  final String optionA;
  final String optionB;
  final DateTime createdAt;
  // ... 공통 필드들
}

// Creation Feature에서 사용
// lib/features/creation/domain/models/post_draft.dart
class PostDraft extends PostContract {
  final TargetAudience targetAudience;
  final List<MediaContent> mediaFiles;
  // Creation 전용 필드들
}

// Post Feature에서 사용
// lib/features/post/domain/models/post_feed.dart
class PostFeed extends PostContract {
  final PostMetrics metrics;
  final List<Comment> comments;
  // Post 전용 필드들
}
```

### Phase 6: DI Module 분리 (30분)
```dart
// lib/app/di/creation_module.dart (새로 생성)
class CreationModule {
  static void setup(GetIt getIt) {
    // Creation Repository (수정됨)
    getIt.registerLazySingleton<ICreationRepository>(
      () => CreationRepositoryImpl(
        firestore: getIt<FirebaseFirestore>(),
        storage: getIt<FirebaseStorage>(),
      ),
    );

    // Media services
    getIt.registerLazySingleton<IMediaService>(
      () => MediaServiceImpl(),
    );

    // Creation providers
    getIt.registerFactory<CreatePostProvider>(
      () => CreatePostProvider(
        repository: getIt<ICreationRepository>(),
        mediaService: getIt<IMediaService>(),
      ),
    );

    // Target audience
    getIt.registerFactory<TargetAudienceProvider>(
      () => TargetAudienceProvider(),
    );
  }
}

// lib/app/di/post_module.dart (새로 생성)
class PostModule {
  static void setup(GetIt getIt) {
    // Feed Repository (수정됨)
    getIt.registerLazySingleton<IFeedRepository>(
      () => FeedRepositoryImpl(
        firestore: getIt<FirebaseFirestore>(),
      ),
    );

    // Feed provider
    getIt.registerFactory<FeedProvider>(
      () => FeedProvider(
        repository: getIt<IFeedRepository>(),
      ),
    );
  }
}
```

## 📂 최종 디렉토리 구조

```
/lib/features/
├── creation/                 # 85개 파일 (70%)
│   ├── data/
│   │   ├── adapters/        # 미디어 업로드 어댑터
│   │   └── services/        # 업로드, AI 검열 서비스
│   ├── domain/
│   │   ├── models/          # target_audience, media_content
│   │   ├── services/        # i_media_upload_service
│   │   └── usecases/        # create, moderate, validate
│   └── presentation/
│       ├── screens/         # create_post, editor, thumbnail
│       ├── widgets/         # dialogs, media components
│       └── providers/       # 8개 creation providers
│
├── post/                     # 25개 파일 (20%)
│   ├── data/
│   │   ├── models/          # 6개 (comments, likes, shares 등)
│   │   └── repositories/    # FeedRepositoryImpl
│   ├── domain/
│   │   ├── models/          # 6개 (metrics, stats, rankings 등)
│   │   ├── repositories/    # IFeedRepository
│   │   └── usecases/        # 1개 (get_feed_usecase)
│   └── presentation/
│       ├── screens/         # 2개 (feed/home_page)
│       ├── providers/       # 1개 (feed_provider)
│       └── adapters/        # 1개 (post_model_adapter)
│
├── voting/                   # 기존 유지 + 2개 추가
│   ├── domain/
│   │   └── usecases/        # voting_usecases.dart (이동됨)
│   └── data/
│       └── models/          # poll_details_model.dart (선택적)
```

## ✅ 검증 체크리스트

### Phase별 검증
#### Phase 0 (사전 준비)
- [ ] Voting 파일 이동 완료
- [ ] Git 백업 커밋 생성
- [ ] flutter analyze 통과

#### Phase 1 (Rename)
- [ ] posts → creation 폴더명 변경
- [ ] 내부/외부 import 경로 수정
- [ ] flutter analyze 에러 0개

#### Phase 2 (Post Feature 생성)
- [ ] post 폴더 구조 생성
- [ ] 기본 export 파일 생성

#### Phase 3 (파일 이동)
- [ ] Domain: 7개 파일 이동
- [ ] Data: 7개 파일 이동
- [ ] Presentation: 11개 파일 이동
- [ ] 총 25개 파일 이동 확인

#### Phase 4 (Import 정리)
- [ ] Post 내부 import 수정
- [ ] Creation에서 Post 참조 수정
- [ ] 외부 참조 수정

#### Phase 4.5 (Repository 분리)
- [ ] ICreationRepository 생성
- [ ] IFeedRepository 생성
- [ ] 구현체 분리

#### Phase 5.5 (Contract 패턴)
- [ ] PostContract 공통 모델 정의
- [ ] PostDraft (Creation) 생성
- [ ] PostFeed (Post) 생성

#### Phase 6 (DI Module)
- [ ] CreationModule 생성
- [ ] PostModule 생성
- [ ] app/di.dart 업데이트

### 최종 검증
- [ ] 작성 → 투표 → 피드 전체 플로우 테스트
- [ ] Import 순환 참조 없음 확인
- [ ] flutter test 통과
- [ ] 앱 빌드 성공 (iOS/Android)

## 🚨 위험 요소 및 대응

### Risk 1: Import 경로 누락
- **위험**: sed 명령이 일부 경로를 놓칠 수 있음
- **대응**: 수동으로 `flutter analyze` 에러 확인 및 수정

### Risk 2: Git History 손실
- **위험**: mv 명령 사용 시 history 손실 가능
- **대응**: `git mv` 사용 또는 각 단계별 명확한 commit

### Risk 3: 외부 참조 깨짐
- **위험**: 다른 Feature에서 Posts 참조하는 부분
- **대응**: 전체 프로젝트 grep으로 사전 확인

## 📈 예상 효과

### 개발 효율성
- **코드 응집도**: 70% → 95% (각 Feature별)
- **테스트 용이성**: 독립적 테스트 가능
- **유지보수성**: 책임 분리로 수정 영향 최소화

### 아키텍처 품질
- **SRP 준수**: 단일 책임 원칙 완벽 준수
- **의존성 관리**: Contract 패턴으로 깔끔한 경계
- **확장성**: 새로운 작성 방식 추가 용이

## 🔗 관련 문서
- [CLEAN_ARCHITECTURE_MIGRATION_COMPLETE_GUIDE.md](./CLEAN_ARCHITECTURE_MIGRATION_COMPLETE_GUIDE.md)
- [PHASE_5_8_MIGRATION_TASKS.md](./PHASE_5_8_MIGRATION_TASKS.md)
- [MIGRATION_TASKS_UPDATED_V2.md](./MIGRATION_TASKS_UPDATED_V2.md)

## 📅 실행 일정

### 예상 소요 시간: 총 2.5시간
- Phase 0: 사전 준비 (15분)
- Phase 1: Rename (30분)
- Phase 2: 구조 생성 (10분)
- Phase 3: 파일 이동 (45분)
- Phase 4: Import 정리 (30분)
- Phase 4.5: Repository 분리 (30분)
- Phase 5: Export 정리 (15분)
- Phase 5.5: Contract 패턴 (20분)
- Phase 6: DI Module (30분)
- 최종 검증: 15분

### 권장 사항
- **실행 시간**: 주중 오전 (문제 발생 시 대응 여유)
- **백업**: 실행 전 전체 백업 및 브랜치 생성 필수
- **팀 공지**: 작업 시작 전 팀에 공지

---

**작성**: Architecture Team
**검토**: Development Team
**승인**: Project Lead