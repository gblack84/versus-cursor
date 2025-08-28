# 🚀 Backend Repositories 마이그레이션 계획

> Repository 패턴 구현 및 Feature-First Architecture 적용  
> 작성일: 2025-08-28 | 예상 기간: 2주 (10 작업일)

## 📋 마이그레이션 개요

### 현재 상태
- **문제점**: Repository 패턴 없이 UI에서 직접 Firestore 접근
- **영향**: 테스트 불가능, 높은 결합도, 코드 중복, 캐싱 전략 부재
- **파일**: 4개 파일 모두 TODO 상태

### 목표 상태
- **구조**: Clean Architecture 기반 Repository 패턴
- **효과**: 테스트 가능, 낮은 결합도, 코드 재사용, 효율적 캐싱
- **통합**: Feature-First Architecture와 완벽 통합

## 🎯 마이그레이션 목표

### 1. 기술적 목표
- ✅ Repository 패턴 100% 구현
- ✅ 의존성 역전 원칙 준수
- ✅ 테스트 커버리지 85% 이상
- ✅ 3-Layer 캐싱 통합

### 2. 비즈니스 목표
- ✅ 네트워크 요청 50% 감소
- ✅ 앱 응답 속도 40% 개선
- ✅ 개발 생산성 30% 향상
- ✅ 버그 발생률 60% 감소

## 📐 아키텍처 설계

### 1. 레이어 구조
```
┌─────────────────────────────────────┐
│     Presentation Layer (UI)         │
├─────────────────────────────────────┤
│     Domain Layer (Use Cases)        │
├─────────────────────────────────────┤
│   Data Layer (Repositories) ← HERE  │
├─────────────────────────────────────┤
│  Infrastructure (Firebase, APIs)     │
└─────────────────────────────────────┘
```

### 2. Repository 패턴 구조
```dart
// Domain Layer - 인터페이스
abstract class IUserRepository {
  Future<User?> getUser(String userId);
  Stream<User> watchUser(String userId);
}

// Data Layer - 구현
@LazySingleton(as: IUserRepository)
class UserRepository implements IUserRepository {
  final FirebaseFirestore _firestore;
  final UnifiedCacheService _cache;
  final UserMapper _mapper;
  
  UserRepository(
    this._firestore,
    this._cache,
    this._mapper,
  );
  
  @override
  Future<User?> getUser(String userId) async {
    // 1. 캐시 확인
    final cached = await _cache.get('user_$userId');
    if (cached != null) return _mapper.fromCache(cached);
    
    // 2. Firestore 조회
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .get();
    
    if (!doc.exists) return null;
    
    // 3. 매핑 및 캐싱
    final user = _mapper.fromFirestore(doc);
    await _cache.set('user_$userId', user);
    
    return user;
  }
}
```

### 3. Feature 통합 구조
```
/lib/features/auth/
├── domain/
│   └── repositories/
│       └── i_auth_repository.dart    # 인터페이스
├── data/
│   └── repositories/
│       └── auth_repository.dart      # 구현
└── presentation/
    └── providers/
        └── auth_provider.dart         # Repository 사용
```

## 📅 마이그레이션 일정

### Week 1: 기반 구축

#### Day 1-2: 인프라 설정
```bash
# 백업 생성
git checkout -b migration/repositories-$(date +%Y%m%d)
git tag -a backup/pre-repositories-$(date +%Y%m%d) -m "Before repositories migration"
```

**작업 내용:**
```dart
// 1. 인터페이스 정의
// lib/backend/repositories/interfaces/
├── i_repository.dart          // Base interface
├── i_user_repository.dart
├── i_post_repository.dart
├── i_chat_repository.dart
└── i_media_repository.dart

// 2. Exception 정의
// lib/backend/repositories/exceptions/
├── repository_exception.dart
├── network_exception.dart
├── cache_exception.dart
└── validation_exception.dart

// 3. Mapper 정의
// lib/backend/repositories/mappers/
├── base_mapper.dart
├── user_mapper.dart
├── post_mapper.dart
├── message_mapper.dart
└── media_mapper.dart
```

#### Day 3-4: UserRepository 구현
```dart
// lib/backend/repositories/user_repository.dart
import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/cache/unified_cache_service.dart';
import '/backend/repositories/interfaces/i_user_repository.dart';
import '/backend/repositories/mappers/user_mapper.dart';
import '/backend/repositories/exceptions/repository_exception.dart';

@LazySingleton(as: IUserRepository)
class UserRepository implements IUserRepository {
  static const String _collection = 'users';
  static const Duration _cacheTimeout = Duration(hours: 1);
  
  final FirebaseFirestore _firestore;
  final UnifiedCacheService _cache;
  final UserMapper _mapper;
  final Logger _logger;
  
  UserRepository(
    @Named('firestore') this._firestore,
    this._cache,
    this._mapper,
    this._logger,
  );
  
  @override
  Future<User?> getUser(String userId) async {
    try {
      // 1. 유효성 검사
      if (userId.isEmpty) {
        throw ValidationException('User ID cannot be empty');
      }
      
      // 2. 캐시 확인
      final cacheKey = 'user_$userId';
      final cached = await _cache.get<Map<String, dynamic>>(cacheKey);
      
      if (cached != null) {
        _logger.debug('User loaded from cache: $userId');
        return _mapper.fromJson(cached);
      }
      
      // 3. Firestore 조회
      final doc = await _firestore
          .collection(_collection)
          .doc(userId)
          .get();
      
      if (!doc.exists) {
        _logger.info('User not found: $userId');
        return null;
      }
      
      // 4. 매핑
      final user = _mapper.fromFirestore(doc);
      
      // 5. 캐싱
      await _cache.set(
        cacheKey,
        _mapper.toJson(user),
        timeout: _cacheTimeout,
      );
      
      _logger.debug('User loaded from Firestore: $userId');
      return user;
      
    } on FirebaseException catch (e, stack) {
      _logger.error('Firebase error getting user', e, stack);
      throw NetworkException(
        'Failed to load user',
        originalError: e,
      );
    } catch (e, stack) {
      _logger.error('Unexpected error getting user', e, stack);
      throw RepositoryException(
        'An error occurred while loading user',
        originalError: e,
      );
    }
  }
  
  @override
  Future<List<User>> getUsers(List<String> userIds) async {
    if (userIds.isEmpty) return [];
    
    // 배치 처리로 효율성 향상
    final futures = userIds.map((id) => getUser(id));
    final results = await Future.wait(futures);
    
    return results.whereType<User>().toList();
  }
  
  @override
  Future<void> createUser(User user) async {
    try {
      final data = _mapper.toFirestore(user);
      
      await _firestore
          .collection(_collection)
          .doc(user.id)
          .set(data);
      
      // 캐시 무효화
      await _cache.remove('user_${user.id}');
      
      _logger.info('User created: ${user.id}');
      
    } on FirebaseException catch (e, stack) {
      _logger.error('Failed to create user', e, stack);
      throw NetworkException(
        'Failed to create user account',
        originalError: e,
      );
    }
  }
  
  @override
  Future<void> updateUser(User user) async {
    try {
      final data = _mapper.toFirestore(user);
      
      await _firestore
          .collection(_collection)
          .doc(user.id)
          .update(data);
      
      // 캐시 업데이트
      final cacheKey = 'user_${user.id}';
      await _cache.set(
        cacheKey,
        _mapper.toJson(user),
        timeout: _cacheTimeout,
      );
      
      _logger.info('User updated: ${user.id}');
      
    } on FirebaseException catch (e, stack) {
      _logger.error('Failed to update user', e, stack);
      throw NetworkException(
        'Failed to update user profile',
        originalError: e,
      );
    }
  }
  
  @override
  Stream<User> watchUser(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            throw RepositoryException('User not found');
          }
          return _mapper.fromFirestore(doc);
        })
        .handleError((error, stack) {
          _logger.error('Error watching user', error, stack);
          throw NetworkException(
            'Failed to watch user updates',
            originalError: error,
          );
        });
  }
  
  @override
  Future<List<User>> searchUsers(String query) async {
    if (query.isEmpty || query.length < 2) return [];
    
    try {
      // Algolia 검색 사용 (더 효율적)
      // 또는 Firestore 쿼리
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('searchableTerms', arrayContains: query.toLowerCase())
          .limit(20)
          .get();
      
      return querySnapshot.docs
          .map((doc) => _mapper.fromFirestore(doc))
          .toList();
      
    } catch (e, stack) {
      _logger.error('Failed to search users', e, stack);
      return [];
    }
  }
}
```

#### Day 5: PostRepository 구현
```dart
// lib/backend/repositories/post_repository.dart
@LazySingleton(as: IPostRepository)
class PostRepository implements IPostRepository {
  static const String _collection = 'posts';
  static const int _pageSize = 20;
  
  final FirebaseFirestore _firestore;
  final UnifiedCacheService _cache;
  final PostMapper _mapper;
  final IUserRepository _userRepository;
  
  @override
  Future<List<Post>> getFeedPosts({
    int limit = _pageSize,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get();
      
      // 병렬로 사용자 정보 로드
      final posts = snapshot.docs
          .map((doc) => _mapper.fromFirestore(doc))
          .toList();
      
      final userIds = posts
          .map((p) => p.userId)
          .toSet()
          .toList();
      
      final users = await _userRepository.getUsers(userIds);
      final userMap = {for (var u in users) u.id: u};
      
      // 사용자 정보 병합
      return posts.map((post) {
        final user = userMap[post.userId];
        return post.copyWith(author: user);
      }).toList();
      
    } catch (e, stack) {
      _logger.error('Failed to get feed posts', e, stack);
      throw RepositoryException('Failed to load feed');
    }
  }
  
  @override
  Future<void> vote(
    String postId,
    String userId,
    VoteOption option,
  ) async {
    try {
      // 트랜잭션으로 동시성 처리
      await _firestore.runTransaction((transaction) async {
        final postRef = _firestore
            .collection(_collection)
            .doc(postId);
        
        final voteRef = postRef
            .collection('votes')
            .doc(userId);
        
        final postDoc = await transaction.get(postRef);
        
        if (!postDoc.exists) {
          throw RepositoryException('Post not found');
        }
        
        final post = _mapper.fromFirestore(postDoc);
        
        // 투표 마감 확인
        if (post.voteEndTime?.isBefore(DateTime.now()) ?? false) {
          throw ValidationException('Voting has ended');
        }
        
        // 투표 기록
        transaction.set(voteRef, {
          'userId': userId,
          'option': option.name,
          'votedAt': FieldValue.serverTimestamp(),
        });
        
        // 카운트 업데이트
        final field = option == VoteOption.a ? 'votesA' : 'votesB';
        transaction.update(postRef, {
          field: FieldValue.increment(1),
        });
      });
      
      // 캐시 무효화
      await _cache.remove('post_$postId');
      
    } catch (e, stack) {
      _logger.error('Failed to vote', e, stack);
      throw RepositoryException('Failed to submit vote');
    }
  }
}
```

### Week 2: 고급 기능 구현

#### Day 6-7: ChatRepository 구현
```dart
// lib/backend/repositories/chat_repository.dart
@LazySingleton(as: IChatRepository)
class ChatRepository implements IChatRepository {
  static const String _chatsCollection = 'chats';
  static const String _messagesCollection = 'messages';
  
  final FirebaseFirestore _firestore;
  final UnifiedCacheService _cache;
  final MessageMapper _mapper;
  
  @override
  Future<List<Message>> getMessages(
    String chatId, {
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      // 캐시 확인
      final cacheKey = 'chat_messages_$chatId';
      final cached = await _cache.get<List<Map<String, dynamic>>>(cacheKey);
      
      if (cached != null && startAfter == null) {
        return cached.map((json) => _mapper.fromJson(json)).toList();
      }
      
      // Firestore 조회
      Query query = _firestore
          .collection(_chatsCollection)
          .doc(chatId)
          .collection(_messagesCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get();
      final messages = snapshot.docs
          .map((doc) => _mapper.fromFirestore(doc))
          .toList();
      
      // 첫 페이지만 캐싱
      if (startAfter == null) {
        await _cache.set(
          cacheKey,
          messages.map((m) => _mapper.toJson(m)).toList(),
          timeout: Duration(minutes: 5),
        );
      }
      
      return messages;
      
    } catch (e, stack) {
      _logger.error('Failed to get messages', e, stack);
      throw RepositoryException('Failed to load messages');
    }
  }
  
  @override
  Stream<List<Message>> watchMessages(String chatId) {
    return _firestore
        .collection(_chatsCollection)
        .doc(chatId)
        .collection(_messagesCollection)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => _mapper.fromFirestore(doc))
              .toList();
        })
        .handleError((error, stack) {
          _logger.error('Error watching messages', error, stack);
        });
  }
  
  @override
  Future<void> sendMessage(Message message) async {
    try {
      final batch = _firestore.batch();
      
      // 1. 메시지 추가
      final messageRef = _firestore
          .collection(_chatsCollection)
          .doc(message.chatId)
          .collection(_messagesCollection)
          .doc();
      
      batch.set(messageRef, _mapper.toFirestore(message));
      
      // 2. 채팅방 업데이트
      final chatRef = _firestore
          .collection(_chatsCollection)
          .doc(message.chatId);
      
      batch.update(chatRef, {
        'lastMessage': message.text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadCount.${message.receiverId}': FieldValue.increment(1),
      });
      
      await batch.commit();
      
      // 캐시 무효화
      await _cache.remove('chat_messages_${message.chatId}');
      
    } catch (e, stack) {
      _logger.error('Failed to send message', e, stack);
      throw RepositoryException('Failed to send message');
    }
  }
}
```

#### Day 8: MediaRepository 구현
```dart
// lib/backend/repositories/media_repository.dart
@LazySingleton(as: IMediaRepository)
class MediaRepository implements IMediaRepository {
  final FirebaseStorage _storage;
  final ImageCompressor _compressor;
  final VideoProcessor _processor;
  
  @override
  Future<String> uploadImage(
    File image, {
    String? path,
    bool compress = true,
  }) async {
    try {
      // 압축
      File processedImage = image;
      if (compress) {
        processedImage = await _compressor.compress(
          image,
          quality: 85,
          maxWidth: 1920,
        );
      }
      
      // 경로 생성
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
      final storagePath = path ?? 'uploads/images/$fileName';
      
      // 업로드
      final ref = _storage.ref(storagePath);
      final uploadTask = ref.putFile(processedImage);
      
      // 진행률 모니터링
      uploadTask.snapshotEvents.listen((event) {
        final progress = event.bytesTransferred / event.totalBytes;
        _logger.debug('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
      });
      
      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();
      
      return url;
      
    } catch (e, stack) {
      _logger.error('Failed to upload image', e, stack);
      throw RepositoryException('Failed to upload image');
    }
  }
  
  @override
  Future<List<String>> uploadMultipleImages(List<File> images) async {
    // 병렬 업로드
    final futures = images.map((image) => uploadImage(image));
    return Future.wait(futures);
  }
  
  @override
  Future<String> generateThumbnail(String videoUrl) async {
    try {
      // 비디오 다운로드
      final videoFile = await downloadFile(videoUrl);
      if (videoFile == null) {
        throw RepositoryException('Failed to download video');
      }
      
      // 썸네일 생성
      final thumbnail = await _processor.extractThumbnail(
        videoFile,
        position: Duration(seconds: 1),
      );
      
      // 썸네일 업로드
      return uploadImage(
        thumbnail,
        path: 'thumbnails/',
        compress: true,
      );
      
    } catch (e, stack) {
      _logger.error('Failed to generate thumbnail', e, stack);
      throw RepositoryException('Failed to generate thumbnail');
    }
  }
}
```

#### Day 9: DI 설정 및 통합
```dart
// lib/backend/repositories/di/repository_module.dart
import 'package:injectable/injectable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

@module
abstract class RepositoryModule {
  // Mappers
  @lazySingleton
  UserMapper get userMapper => UserMapper();
  
  @lazySingleton
  PostMapper get postMapper => PostMapper();
  
  @lazySingleton
  MessageMapper get messageMapper => MessageMapper();
  
  // Services
  @lazySingleton
  ImageCompressor get imageCompressor => ImageCompressor();
  
  @lazySingleton
  VideoProcessor get videoProcessor => VideoProcessor();
  
  // Logger
  @lazySingleton
  Logger get logger => Logger('Repository');
}

// lib/app/di/injection.dart 업데이트
import '/backend/repositories/di/repository_module.dart';

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  await getIt.init();
}
```

#### Day 10: Feature 통합 및 마이그레이션
```dart
// 1. Feature별 Repository 인터페이스 생성
// lib/features/auth/domain/repositories/i_auth_repository.dart
abstract class IAuthRepository {
  Future<AuthUser?> signIn(String email, String password);
  Future<AuthUser?> signUp(String email, String password);
  Future<void> signOut();
  Stream<AuthUser?> watchAuthState();
}

// 2. Feature Repository 구현
// lib/features/auth/data/repositories/auth_repository.dart
@LazySingleton(as: IAuthRepository)
class AuthRepository implements IAuthRepository {
  final FirebaseAuth _auth;
  final IUserRepository _userRepository;
  
  @override
  Future<AuthUser?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user == null) return null;
      
      // User Repository 활용
      final user = await _userRepository.getUser(credential.user!.uid);
      
      return AuthUser(
        uid: credential.user!.uid,
        email: credential.user!.email,
        profile: user,
      );
      
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign in failed');
    }
  }
}

// 3. Provider에서 Repository 사용
// lib/features/auth/presentation/providers/auth_provider.dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  late final IAuthRepository _repository;
  
  @override
  FutureOr<AuthState> build() async {
    _repository = ref.read(authRepositoryProvider);
    
    // Repository를 통한 인증 상태 확인
    final user = await _repository.getCurrentUser();
    
    return user != null
        ? AuthState.authenticated(user)
        : AuthState.unauthenticated();
  }
  
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    
    try {
      final user = await _repository.signIn(email, password);
      state = AsyncValue.data(AuthState.authenticated(user!));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
```

## 🔄 점진적 마이그레이션 전략

### Phase 1: Facade 패턴 적용 (Day 1-2)
```dart
// 기존 코드를 감싸는 Facade 생성
class FirestoreFacade {
  final IUserRepository _userRepository;
  final IPostRepository _postRepository;
  
  // 기존 메서드 시그니처 유지
  Future<DocumentSnapshot> getUserDoc(String userId) async {
    // 내부적으로 Repository 사용
    final user = await _userRepository.getUser(userId);
    // DocumentSnapshot처럼 보이도록 래핑
    return FakeDocumentSnapshot(user);
  }
}
```

### Phase 2: 점진적 교체 (Day 3-7)
```dart
// Step 1: Repository와 기존 코드 병행
class HomePageWidget {
  Future<void> loadPosts() async {
    if (FeatureFlags.useRepository) {
      // 새로운 방식
      final posts = await _postRepository.getFeedPosts();
    } else {
      // 기존 방식
      final posts = await FirebaseFirestore.instance
          .collection('posts')
          .get();
    }
  }
}

// Step 2: 점진적 전환
// A/B 테스트로 안정성 확인
```

### Phase 3: 완전 전환 (Day 8-10)
```dart
// 모든 직접 Firestore 호출 제거
// Repository만 사용하도록 전환
class HomePageWidget {
  final IPostRepository _repository = getIt<IPostRepository>();
  
  Future<void> loadPosts() async {
    final posts = await _repository.getFeedPosts();
    // 완전히 Repository 기반으로 전환
  }
}
```

## 📊 성능 최적화 전략

### 1. 캐싱 전략
```dart
class CachingStrategy {
  // L1: 메모리 캐시 (즉시 응답)
  static const memoryCache = Duration(minutes: 5);
  
  // L2: 로컬 DB (Hive)
  static const localCache = Duration(hours: 1);
  
  // L3: Firestore 오프라인 캐시
  static const offlineCache = Duration(days: 7);
}
```

### 2. 배치 처리
```dart
// 여러 요청을 하나로 묶기
Future<Map<String, User>> getUsersBatch(List<String> userIds) async {
  final chunks = userIds.chunked(10); // 10개씩 나누기
  final results = await Future.wait(
    chunks.map((chunk) => _fetchUserChunk(chunk))
  );
  return results.expand((r) => r.entries).toMap();
}
```

### 3. 프리로딩
```dart
// 자주 사용되는 데이터 미리 로드
class PreloadService {
  Future<void> preloadEssentialData() async {
    await Future.wait([
      _userRepository.getUser(currentUserId),
      _postRepository.getTrendingPosts(),
      _chatRepository.getRecentChats(),
    ]);
  }
}
```

## 🧪 테스트 전략

### 1. 단위 테스트
```dart
// test/backend/repositories/user_repository_test.dart
@GenerateMocks([FirebaseFirestore, UnifiedCacheService, UserMapper])
void main() {
  late UserRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockUnifiedCacheService mockCache;
  
  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCache = MockUnifiedCacheService();
    repository = UserRepository(mockFirestore, mockCache, UserMapper());
  });
  
  group('getUser', () {
    test('should return user from cache when available', () async {
      // Given
      const userId = 'test123';
      final cachedUser = {'id': userId, 'name': 'Test User'};
      
      when(mockCache.get('user_$userId'))
          .thenAnswer((_) async => cachedUser);
      
      // When
      final user = await repository.getUser(userId);
      
      // Then
      expect(user?.id, userId);
      verify(mockCache.get('user_$userId')).called(1);
      verifyNever(mockFirestore.collection(any));
    });
  });
}
```

### 2. 통합 테스트
```dart
// Firebase Emulator 사용
void main() {
  late UserRepository repository;
  
  setUpAll(() async {
    // Emulator 연결
    await Firebase.initializeApp();
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  });
  
  test('should create and retrieve user', () async {
    // 실제 Firestore Emulator와 통합 테스트
    final user = User(id: 'test', name: 'Test User');
    
    await repository.createUser(user);
    final retrieved = await repository.getUser(user.id);
    
    expect(retrieved?.name, user.name);
  });
}
```

## 🚨 위험 관리

### 위험 요소 및 대응
| 위험 | 확률 | 영향 | 대응 방안 |
|-----|-----|-----|----------|
| **데이터 불일치** | 중간 | 높음 | 트랜잭션 사용, 동기화 메커니즘 |
| **성능 저하** | 낮음 | 높음 | 캐싱 전략, 프로파일링 |
| **Breaking Changes** | 중간 | 매우 높음 | Facade 패턴, 점진적 마이그레이션 |
| **캐시 무효화 실패** | 중간 | 중간 | 이벤트 기반 무효화, TTL 설정 |

## 🔄 롤백 계획

### 즉시 롤백 (< 1시간)
```dart
// Feature Flag 비활성화
class FeatureFlags {
  static const useRepository = false; // true → false
}
```

### 부분 롤백 (< 1일)
```dart
// 특정 Repository만 비활성화
class DIConfig {
  static bool useUserRepository = true;  // 유지
  static bool usePostRepository = false; // 롤백
}
```

### 전체 롤백 (< 3일)
```bash
# Git 롤백
git checkout backup/pre-repositories-[date]
git checkout -b hotfix/repository-rollback
```

## 📊 성공 지표

### 정량적 지표
- [ ] Repository 구현율: 100%
- [ ] 테스트 커버리지: > 85%
- [ ] 네트워크 요청: -50%
- [ ] 응답 속도: +40%
- [ ] 메모리 사용량: ±10%

### 정성적 지표
- [ ] 코드 재사용성 향상
- [ ] 테스트 작성 용이성
- [ ] 유지보수성 개선
- [ ] 개발자 만족도 상승

## 📚 참고 문서

- [Repository 패턴 가이드](https://docs.flutter.dev/data-and-backend/state-mgmt/options)
- [Clean Architecture in Flutter](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [DI with GetIt](https://pub.dev/packages/get_it)
- [Firebase Best Practices](https://firebase.google.com/docs/firestore/best-practices)

---

*이 문서는 Backend Repositories 레이어의 마이그레이션 계획을 정의합니다.*  
*2주간의 체계적인 구현으로 테스트 가능하고 유지보수가 쉬운 Repository 패턴을 구축합니다.*