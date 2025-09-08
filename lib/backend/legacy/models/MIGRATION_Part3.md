# 🔄 Backend Models Migration Plan - Part 3

> Feature-First Architecture 마이그레이션 계획  
> 예상 기간: 5일 | 난이도: ⭐⭐⭐⭐☆

## 📋 마이그레이션 개요

### 현재 상태
- **중앙집중식 모델**: 모든 Feature가 `/lib/backend/models/`에 의존
- **과도한 필드**: PostsModel 60개+, UsersModel 40개+ 필드
- **타입 안전성 부족**: Map<String, dynamic> 과다 사용
- **테스트 없음**: 0% 커버리지

### 목표 상태
- **Feature별 모델**: 각 Feature가 자체 도메인 모델 보유
- **단일 책임**: 각 모델이 하나의 명확한 목적
- **타입 안전성**: 구체적 타입과 ValueObject 사용
- **테스트 커버리지**: 80% 이상

## 📅 단계별 마이그레이션

### Day 1: 모델 분석 및 계획 수립

#### 1.1 모델 의존성 매핑
```dart
// 현재 의존성 분석 스크립트
// analysis/model_dependencies.dart
import 'dart:io';

void analyzeModelDependencies() {
  final models = [
    'users_model',
    'posts_model', 
    'messages_model',
    'comments_model',
  ];
  
  for (final model in models) {
    print('=== $model 사용처 ===');
    final result = Process.runSync('grep', [
      '-r',
      model,
      'lib/features',
      'lib/pages',
      'lib/components',
    ]);
    print(result.stdout);
  }
}
```

#### 1.2 Feature별 필드 매핑
```yaml
# model_mapping.yaml
users_model:
  auth_feature:
    - uid
    - email
    - createdTime
    - phoneNumber
  profile_feature:
    - displayName
    - photoUrl
    - shortDescription
    - gender
    - dateOfBirth
  ranking_feature:
    - pointsA
    - pointsQ
    - currentRank
    - currentTitle
  social_feature:
    - friends
    - activeChats
    - groupChats
```

### Day 2: 도메인 모델 설계

#### 2.1 Base Entity 생성
```dart
// lib/core/domain/entities/base_entity.dart
abstract class BaseEntity {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const BaseEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });
  
  // 값 객체 비교
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaseEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;
  
  @override
  int get hashCode => id.hashCode;
}
```

#### 2.2 Value Objects 생성
```dart
// lib/core/domain/value_objects/email.dart
import 'package:dartz/dartz.dart';

class Email {
  final String value;
  
  const Email._(this.value);
  
  static Either<String, Email> create(String input) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    
    if (!emailRegex.hasMatch(input)) {
      return Left('Invalid email format');
    }
    
    return Right(Email._(input));
  }
  
  @override
  String toString() => value;
}

// lib/core/domain/value_objects/user_points.dart
class UserPoints {
  final int answersPoints;  // pointsA
  final int questionsPoints; // pointsQ
  
  const UserPoints({
    required this.answersPoints,
    required this.questionsPoints,
  });
  
  int get total => answersPoints + questionsPoints;
  
  UserPoints addAnswer(int points) => UserPoints(
    answersPoints: answersPoints + points,
    questionsPoints: questionsPoints,
  );
  
  UserPoints addQuestion(int points) => UserPoints(
    answersPoints: answersPoints,
    questionsPoints: questionsPoints + points,
  );
}
```

### Day 3: Feature별 모델 구현

#### 3.1 Auth Feature 모델
```dart
// lib/features/auth/domain/models/auth_user.dart
import 'package:equatable/equatable.dart';
import '/core/domain/entities/base_entity.dart';
import '/core/domain/value_objects/email.dart';

class AuthUser extends BaseEntity with EquatableMixin {
  final String uid;
  final Email email;
  final String? phoneNumber;
  final bool isEmailVerified;
  final String? role; // admin, tester, user
  
  const AuthUser({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.uid,
    required this.email,
    this.phoneNumber,
    required this.isEmailVerified,
    this.role,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
  
  @override
  List<Object?> get props => [
    id, uid, email, phoneNumber, 
    isEmailVerified, role,
  ];
  
  // Factory constructor from Firestore
  factory AuthUser.fromFirestore(Map<String, dynamic> data, String docId) {
    return AuthUser(
      id: docId,
      uid: data['uid'] ?? '',
      email: Email.create(data['email'] ?? '').fold(
        (l) => throw Exception(l),
        (r) => r,
      ),
      phoneNumber: data['phoneNumber'],
      isEmailVerified: data['isEmailVerified'] ?? false,
      role: data['role'],
      createdAt: (data['createdTime'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  
  // To Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email.value,
      'phoneNumber': phoneNumber,
      'isEmailVerified': isEmailVerified,
      'role': role,
      'createdTime': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
```

#### 3.2 Profile Feature 모델
```dart
// lib/features/profile/domain/models/user_profile.dart
class UserProfile extends BaseEntity {
  final String userId;
  final String displayName;
  final String? photoUrl;
  final String? shortDescription;
  final List<String> interests;
  final List<String> expertise;
  final UserPoints points;
  final UserRank rank;
  
  const UserProfile({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.userId,
    required this.displayName,
    this.photoUrl,
    this.shortDescription,
    required this.interests,
    required this.expertise,
    required this.points,
    required this.rank,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
  
  // 포인트 업데이트
  UserProfile updatePoints(UserPoints newPoints) {
    return UserProfile(
      id: id,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      userId: userId,
      displayName: displayName,
      photoUrl: photoUrl,
      shortDescription: shortDescription,
      interests: interests,
      expertise: expertise,
      points: newPoints,
      rank: rank,
    );
  }
}

// lib/features/profile/domain/models/user_rank.dart
class UserRank {
  final String currentRank;
  final String currentTitle;
  final DateTime? rankChangeDate;
  final DateTime? titleChangeDate;
  final List<String> rankHistory;
  final List<String> titleHistory;
  
  const UserRank({
    required this.currentRank,
    required this.currentTitle,
    this.rankChangeDate,
    this.titleChangeDate,
    required this.rankHistory,
    required this.titleHistory,
  });
  
  bool get isEligibleForPromotion {
    if (rankChangeDate == null) return true;
    final daysSinceChange = DateTime.now()
        .difference(rankChangeDate!)
        .inDays;
    return daysSinceChange >= 30; // 30일 경과
  }
}
```

#### 3.3 Post Feature 모델 분리
```dart
// lib/features/posts/domain/models/post.dart
class Post extends BaseEntity {
  final String userId;
  final String questionTitle;
  final String description;
  final PostContent optionA;
  final PostContent optionB;
  final PostVisibility visibility;
  final PostCategory category;
  final List<String> tags;
  final bool isAnonymous;
  
  const Post({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.userId,
    required this.questionTitle,
    required this.description,
    required this.optionA,
    required this.optionB,
    required this.visibility,
    required this.category,
    required this.tags,
    required this.isAnonymous,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

// lib/features/posts/domain/models/post_content.dart
class PostContent {
  final String text;
  final List<String> imageUrls;
  final String? videoUrl;
  final double? aspectRatio;
  final ContentType type;
  
  const PostContent({
    required this.text,
    required this.imageUrls,
    this.videoUrl,
    this.aspectRatio,
    required this.type,
  });
}

// lib/features/posts/domain/models/post_stats.dart
class PostStats {
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int saveCount;
  final int participantCount;
  
  const PostStats({
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.saveCount,
    required this.participantCount,
  });
  
  PostStats incrementLikes() => PostStats(
    likeCount: likeCount + 1,
    commentCount: commentCount,
    shareCount: shareCount,
    saveCount: saveCount,
    participantCount: participantCount,
  );
}
```

#### 3.4 투표 모델 분리
```dart
// lib/features/voting/domain/models/vote.dart
class Vote extends BaseEntity {
  final String postId;
  final DateTime startTime;
  final DateTime endTime;
  final VoteStatus status;
  final VoteResults results;
  final List<String> voterIdsA;
  final List<String> voterIdsB;
  final TargetAudience targetAudience;
  
  const Vote({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required this.postId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.results,
    required this.voterIdsA,
    required this.voterIdsB,
    required this.targetAudience,
  }) : super(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
  
  bool get isActive => 
      status == VoteStatus.active && 
      DateTime.now().isBefore(endTime);
      
  bool get isCompleted => 
      status == VoteStatus.completed || 
      DateTime.now().isAfter(endTime);
      
  bool hasUserVoted(String userId) =>
      voterIdsA.contains(userId) || 
      voterIdsB.contains(userId);
}

// lib/features/voting/domain/models/vote_results.dart
class VoteResults {
  final int votesA;
  final int votesB;
  final int totalVotes;
  
  const VoteResults({
    required this.votesA,
    required this.votesB,
  }) : totalVotes = votesA + votesB;
  
  double get percentA => 
      totalVotes > 0 ? (votesA / totalVotes * 100) : 0;
      
  double get percentB => 
      totalVotes > 0 ? (votesB / totalVotes * 100) : 0;
}
```

### Day 4: Repository 패턴 구현

#### 4.1 Repository Interface
```dart
// lib/core/domain/repositories/base_repository.dart
abstract class BaseRepository<T extends BaseEntity> {
  Future<T?> getById(String id);
  Future<List<T>> getAll();
  Future<String> create(T entity);
  Future<void> update(T entity);
  Future<void> delete(String id);
  Stream<T?> watchById(String id);
  Stream<List<T>> watchAll();
}
```

#### 4.2 Feature Repository 구현
```dart
// lib/features/posts/domain/repositories/post_repository.dart
abstract class PostRepository extends BaseRepository<Post> {
  Future<List<Post>> getUserPosts(String userId);
  Future<List<Post>> getPostsByCategory(PostCategory category);
  Future<List<Post>> searchPosts(String query);
  Future<PostStats> getPostStats(String postId);
  Future<void> updatePostStats(String postId, PostStats stats);
}

// lib/features/posts/data/repositories/post_repository_impl.dart
class PostRepositoryImpl implements PostRepository {
  final FirebaseFirestore _firestore;
  
  PostRepositoryImpl(this._firestore);
  
  @override
  Future<Post?> getById(String id) async {
    try {
      final doc = await _firestore
          .collection('posts')
          .doc(id)
          .get();
          
      if (!doc.exists) return null;
      
      return Post.fromFirestore(
        doc.data()!,
        doc.id,
      );
    } catch (e) {
      throw RepositoryException('Failed to get post: $e');
    }
  }
  
  @override
  Future<String> create(Post entity) async {
    try {
      final docRef = await _firestore
          .collection('posts')
          .add(entity.toFirestore());
          
      return docRef.id;
    } catch (e) {
      throw RepositoryException('Failed to create post: $e');
    }
  }
  
  @override
  Stream<List<Post>> getUserPosts(String userId) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromFirestore(
                doc.data(),
                doc.id,
              ))
            .toList());
  }
}
```

### Day 5: 마이그레이션 및 테스트

#### 5.1 점진적 마이그레이션 전략
```dart
// lib/backend/models/migration/model_adapter.dart
/// 기존 모델과 새 모델 간의 어댑터
class ModelAdapter {
  /// 기존 PostsModel을 새로운 Post와 Vote로 분리
  static (Post, Vote) fromPostsModel(PostsModel old) {
    final post = Post(
      id: old.reference.id,
      createdAt: old.createdAt ?? DateTime.now(),
      updatedAt: old.updatedAt ?? DateTime.now(),
      userId: old.userid,
      questionTitle: old.questionTitle,
      description: old.description,
      optionA: PostContent(
        text: old.optionA['text'] ?? '',
        imageUrls: List<String>.from(old.optionA['images'] ?? []),
        type: ContentType.mixed,
      ),
      optionB: PostContent(
        text: old.optionB['text'] ?? '',
        imageUrls: List<String>.from(old.optionB['images'] ?? []),
        type: ContentType.mixed,
      ),
      visibility: PostVisibility.values[old.visibility],
      category: PostCategory.fromString(old.category),
      tags: old.tags,
      isAnonymous: old.isAnonymous,
    );
    
    final vote = Vote(
      id: old.reference.id,
      postId: old.reference.id,
      startTime: old.voteStartTime ?? DateTime.now(),
      endTime: old.voteEndTime ?? DateTime.now().add(Duration(minutes: 10)),
      status: VoteStatus.fromString(old.voteStatus),
      results: VoteResults(
        votesA: old.votesA,
        votesB: old.votesB,
      ),
      voterIdsA: old.votedUserIdsA,
      voterIdsB: old.votedUserIdsB,
      targetAudience: TargetAudience.fromMap(old.targetAudience),
      createdAt: old.createdAt ?? DateTime.now(),
      updatedAt: old.updatedAt ?? DateTime.now(),
    );
    
    return (post, vote);
  }
  
  /// 새로운 모델을 기존 형식으로 변환 (호환성)
  static Map<String, dynamic> toFirestoreCompat(
    Post post,
    Vote? vote,
    PostStats? stats,
  ) {
    final data = <String, dynamic>{
      'userid': post.userId,
      'questionTitle': post.questionTitle,
      'description': post.description,
      'optionA': {
        'text': post.optionA.text,
        'images': post.optionA.imageUrls,
        'aspectRatio': post.optionA.aspectRatio,
      },
      'optionB': {
        'text': post.optionB.text,
        'images': post.optionB.imageUrls,
        'aspectRatio': post.optionB.aspectRatio,
      },
      'visibility': post.visibility.index,
      'category': post.category.value,
      'tags': post.tags,
      'isAnonymous': post.isAnonymous,
      'createdAt': Timestamp.fromDate(post.createdAt),
      'updatedAt': Timestamp.fromDate(post.updatedAt),
    };
    
    // 투표 정보 추가
    if (vote != null) {
      data.addAll({
        'voteStartTime': Timestamp.fromDate(vote.startTime),
        'voteEndTime': Timestamp.fromDate(vote.endTime),
        'voteStatus': vote.status.value,
        'votesA': vote.results.votesA,
        'votesB': vote.results.votesB,
        'votedUserIdsA': vote.voterIdsA,
        'votedUserIdsB': vote.voterIdsB,
        'totalVotes': vote.results.totalVotes,
        'targetAudience': vote.targetAudience.toMap(),
      });
    }
    
    // 통계 정보 추가
    if (stats != null) {
      data.addAll({
        'likecount': stats.likeCount,
        'commentcount': stats.commentCount,
        'sherecount': stats.shareCount,
        'savecount': stats.saveCount,
        'participantcount': stats.participantCount,
      });
    }
    
    return data;
  }
}
```

#### 5.2 DI 설정 업데이트
```dart
// lib/app/di/model_module.dart
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModelModule {
  static void register(GetIt getIt) {
    // Repositories
    getIt.registerLazySingleton<PostRepository>(
      () => PostRepositoryImpl(
        getIt<FirebaseFirestore>(),
      ),
    );
    
    getIt.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(
        getIt<FirebaseFirestore>(),
      ),
    );
    
    getIt.registerLazySingleton<VoteRepository>(
      () => VoteRepositoryImpl(
        getIt<FirebaseFirestore>(),
      ),
    );
    
    // Model Adapter
    getIt.registerLazySingleton(
      () => ModelAdapter(),
    );
  }
}
```

## 🔍 마이그레이션 체크리스트

### Phase 1: 준비 (Day 1)
- [ ] 모델 의존성 분석 완료
- [ ] Feature별 필드 매핑 완료
- [ ] 영향 범위 파악 완료
- [ ] 팀 리뷰 및 승인

### Phase 2: 구현 (Day 2-4)
- [ ] Base Entity 구현
- [ ] Value Objects 구현
- [ ] Auth Feature 모델 구현
- [ ] Profile Feature 모델 구현
- [ ] Post Feature 모델 구현
- [ ] Vote Feature 모델 구현
- [ ] Repository 패턴 구현
- [ ] Model Adapter 구현

### Phase 3: 마이그레이션 (Day 5)
- [ ] DI 설정 업데이트
- [ ] 점진적 마이그레이션 시작
- [ ] 테스트 작성 및 실행
- [ ] 문서 업데이트

## ⚠️ 주의사항

### 호환성 유지
```dart
// 마이그레이션 기간 동안 두 시스템 병행
if (useNewModels) {
  return PostRepository.getById(id);
} else {
  return PostsModel.getDocument(ref);
}
```

### 데이터 무결성
- Firestore 트랜잭션 사용
- 백업 생성 후 진행
- 롤백 계획 수립

### 성능 고려
- 배치 작업으로 대량 데이터 처리
- 인덱스 최적화
- 캐싱 전략 유지

## 📊 예상 결과

### Before
```dart
// 60개 필드의 거대한 모델
class PostsModel extends FirestoreRecord {
  // 모든 것이 하나에...
}
```

### After
```dart
// 명확한 책임 분리
class Post { /* 기본 정보 */ }
class Vote { /* 투표 정보 */ }
class PostStats { /* 통계 정보 */ }
```

### 개선 효과
- **코드 가독성**: 70% 향상
- **테스트 용이성**: 80% 향상
- **유지보수성**: 60% 향상
- **타입 안전성**: 95% 달성

---

*이 마이그레이션 계획은 점진적이고 안전한 전환을 목표로 합니다.*