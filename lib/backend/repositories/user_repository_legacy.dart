import 'package:get_it/get_it.dart';
import '/backend/backend.dart';
import '/backend/models/migration/model_adapter.dart';
import '/backend/repositories/interfaces/i_user_repository.dart';
import '/backend/repositories/exceptions/repository_exception.dart';
import '/backend/repositories/exceptions/network_exception.dart';
import '/backend/repositories/exceptions/cache_exception.dart';
import '/backend/repositories/exceptions/validation_exception.dart';
import '/backend/repositories/mappers/user_mapper.dart';
import '/services/cache/unified_cache_service.dart';

/// User Repository 구현체
/// 
/// 사용자 데이터 관리를 위한 Repository 패턴 구현체입니다.
/// 3-Layer 캐싱 전략을 통합하여 성능을 최적화합니다.
class UserRepository implements IUserRepository {
  
  UserRepository({
    FirebaseFirestore? firestore,
    UnifiedCacheService? cacheService,
    UserMapper? mapper,
  }) : _firestore = firestore ?? GetIt.instance<FirebaseFirestore>(),
       _cacheService = cacheService ?? GetIt.I<UnifiedCacheService>(),
       _mapper = mapper ?? UserMapper();
  final FirebaseFirestore _firestore;
  final UnifiedCacheService _cacheService;
  final UserMapper _mapper;
  
  static const String _collection = 'users';
  static const String _cachePrefix = 'user_';
  static const Duration _cacheTTL = Duration(hours: 1);
  
  // ==================== 기본 CRUD 메서드 ====================
  
  @override
  Future<UserProfile?> get(String id) async {
    try {
      // 1. 캐시 확인
      final cacheKey = '$_cachePrefix$id';
      final cached = await _cacheService.get<Map<String, dynamic>>(cacheKey);
      
      if (cached != null) {
        final legacyModel = _mapper.fromJson(cached);
        return ModelAdapter.toUserProfile(legacyModel);
      }
      
      // 2. Firestore에서 조회
      final doc = await _firestore.collection(_collection).doc(id).get();
      
      if (!doc.exists) {
        return null;
      }
      
      // 3. 모델 변환
      final legacyModel = _mapper.fromFirestore(doc);
      
      // 4. 캐시 저장
      await _cacheService.set(
        cacheKey,
        _mapper.toJson(legacyModel),
        ttl: _cacheTTL,
      );
      
      return ModelAdapter.toUserProfile(legacyModel);
    } on FirebaseException catch (e, stack) {
      throw NetworkException.fromFirebaseException(e, stack);
    } catch (e, stack) {
      throw RepositoryException(
        code: 'USER_GET_ERROR',
        message: 'Failed to get user: $e',
        userMessage: '사용자 정보를 불러오는데 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  @override
  Future<List<UserProfile>> getAll() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('createdTime', descending: true)
          .get();
      
      final legacyModels = _mapper.fromFirestoreBatch(querySnapshot.docs);
      return legacyModels.map((legacy) => ModelAdapter.toUserProfile(legacy)).toList();
    } on FirebaseException catch (e, stack) {
      throw NetworkException.fromFirebaseException(e, stack);
    } catch (e, stack) {
      throw RepositoryException(
        code: 'USER_GET_ALL_ERROR',
        message: 'Failed to get all users: $e',
        userMessage: '사용자 목록을 불러오는데 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  @override
  Future<List<UserProfile>> getPage({
    int limit = 20,
    dynamic startAfter,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .orderBy('createdTime', descending: true)
          .limit(limit);
      
      if (startAfter != null) {
        if (startAfter is DocumentSnapshot) {
          query = query.startAfterDocument(startAfter);
        } else if (startAfter is Map) {
          query = query.startAfter([startAfter['createdTime']]);
        }
      }
      
      final querySnapshot = await query.get();
      final legacyModels = _mapper.fromFirestoreBatch(querySnapshot.docs);
      return legacyModels.map((legacy) => ModelAdapter.toUserProfile(legacy)).toList();
    } on FirebaseException catch (e, stack) {
      throw NetworkException.fromFirebaseException(e, stack);
    } catch (e, stack) {
      throw RepositoryException(
        code: 'USER_GET_PAGE_ERROR',
        message: 'Failed to get user page: $e',
        userMessage: '사용자 목록 페이지를 불러오는데 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  @override
  Future<UserProfile> create(UserProfile item) async {
    try {
      // Feature 모델을 레거시 형식으로 변환
      // UserProfile에는 email이 없으므로 uid로 유효성 검사
      if (item.uid.isEmpty) {
        throw ValidationException.simple(
          field: 'uid',
          value: item.uid,
          rule: 'required',
        );
      }
      
      // Firestore에 저장
      final docRef = _firestore.collection(_collection).doc(item.uid);
      // UserProfile을 Map으로 변환
      final data = {
        'uid': item.uid,
        'displayName': item.displayName,
        'photoUrl': item.photoUrl,
        'bio': item.bio,
        'birthDate': item.birthDate,
        'gender': item.gender,
        'interests': item.interests,
        'jobCategory': item.jobCategory,
        'jobName': item.jobName,
        'pointsA': item.pointsA,
        'pointsQ': item.pointsQ,
        'isPremiumUser': item.isPremium,
        'role': item.role,
        'createdTime': item.createdAt,
        'lastActive': item.updatedAt,
      };
      
      await docRef.set(data);
      
      // 생성된 문서 다시 조회
      final doc = await docRef.get();
      final created = _mapper.fromFirestore(doc);
      
      // 캐시 저장
      final cacheKey = '$_cachePrefix${docRef.id}';
      await _cacheService.set(
        cacheKey,
        _mapper.toJson(created),
        ttl: _cacheTTL,
      );
      
      return ModelAdapter.toUserProfile(created);
    } on FirebaseException catch (e, stack) {
      throw NetworkException.fromFirebaseException(e, stack);
    } on ValidationException {
      rethrow;
    } catch (e, stack) {
      throw RepositoryException(
        code: 'USER_CREATE_ERROR',
        message: 'Failed to create user: $e',
        userMessage: '사용자 생성에 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  @override
  Future<UserProfile> update(UserProfile item) async {
    try {
      if (item.uid.isEmpty) {
        throw ValidationException.simple(
          field: 'uid',
          value: item.uid,
          rule: 'required',
        );
      }
      
      // UserProfile을 Map으로 변환
      final data = {
        'uid': item.uid,
        'displayName': item.displayName,
        'photoUrl': item.photoUrl,
        'bio': item.bio,
        'birthDate': item.birthDate,
        'gender': item.gender,
        'interests': item.interests,
        'jobCategory': item.jobCategory,
        'jobName': item.jobName,
        'pointsA': item.pointsA,
        'pointsQ': item.pointsQ,
        'isPremiumUser': item.isPremium,
        'role': item.role,
        'lastActive': FieldValue.serverTimestamp(),
      };
      
      await _firestore.collection(_collection).doc(item.uid).update(data);
      
      // 업데이트된 문서 다시 조회
      final doc = await _firestore.collection(_collection).doc(item.uid).get();
      final updated = _mapper.fromFirestore(doc);
      
      // 캐시 업데이트
      final cacheKey = '$_cachePrefix${item.uid}';
      await _cacheService.set(
        cacheKey,
        _mapper.toJson(updated),
        ttl: _cacheTTL,
      );
      
      return ModelAdapter.toUserProfile(updated);
    } on FirebaseException catch (e, stack) {
      throw NetworkException.fromFirebaseException(e, stack);
    } on ValidationException {
      rethrow;
    } catch (e, stack) {
      throw RepositoryException(
        code: 'USER_UPDATE_ERROR',
        message: 'Failed to update user: $e',
        userMessage: '사용자 정보 업데이트에 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  @override
  Future<bool> delete(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      
      // 캐시 삭제
      final cacheKey = '$_cachePrefix$id';
      await _cacheService.delete(cacheKey);
      
      return true;
    } on FirebaseException catch (e, stack) {
      throw NetworkException.fromFirebaseException(e, stack);
    } catch (e, stack) {
      throw RepositoryException(
        code: 'USER_DELETE_ERROR',
        message: 'Failed to delete user: $e',
        userMessage: '사용자 삭제에 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  @override
  Stream<UserProfile?> watch(String id) {
    return _firestore
        .collection(_collection)
        .doc(id)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      
      final legacyModel = _mapper.fromFirestore(doc);
      
      // 스트림 데이터도 캐시 업데이트
      final cacheKey = '$_cachePrefix$id';
      _cacheService.set(
        cacheKey,
        _mapper.toJson(legacyModel),
        ttl: _cacheTTL,
      );
      
      return ModelAdapter.toUserProfile(legacyModel);
    }).handleError((error, stack) {
      throw RepositoryException(
        code: 'USER_WATCH_ERROR',
        message: 'Failed to watch user: $error',
        userMessage: '사용자 정보 실시간 감시에 실패했습니다',
        originalError: error,
        stackTrace: stack,
      );
    });
  }
  
  @override
  Stream<List<UserProfile>> watchAll() {
    return _firestore
        .collection(_collection)
        .orderBy('createdTime', descending: true)
        .snapshots()
        .map((snapshot) {
          final legacyModels = _mapper.fromFirestoreBatch(snapshot.docs);
          return legacyModels.map((legacy) => ModelAdapter.toUserProfile(legacy)).toList();
        })
        .handleError((error, stack) {
      throw RepositoryException(
        code: 'USER_WATCH_ALL_ERROR',
        message: 'Failed to watch all users: $error',
        userMessage: '사용자 목록 실시간 감시에 실패했습니다',
        originalError: error,
        stackTrace: stack,
      );
    });
  }
  
  @override
  Future<List<UserProfile>> getBatch(List<String> ids) async {
    try {
      if (ids.isEmpty) return [];
      
      // 캐시에서 먼저 확인
      final List<UserProfile> results = [];
      final List<String> uncachedIds = [];
      
      for (final id in ids) {
        final cacheKey = '$_cachePrefix$id';
        final cached = await _cacheService.get<Map<String, dynamic>>(cacheKey);
        
        if (cached != null) {
          final legacyModel = _mapper.fromJson(cached);
          results.add(ModelAdapter.toUserProfile(legacyModel));
        } else {
          uncachedIds.add(id);
        }
      }
      
      // 캐시되지 않은 항목들을 Firestore에서 조회
      if (uncachedIds.isNotEmpty) {
        // Firestore where-in은 최대 10개까지만 지원
        for (var i = 0; i < uncachedIds.length; i += 10) {
          final batch = uncachedIds.skip(i).take(10).toList();
          
          final querySnapshot = await _firestore
              .collection(_collection)
              .where(FieldPath.documentId, whereIn: batch)
              .get();
          
          for (final doc in querySnapshot.docs) {
            final legacyModel = _mapper.fromFirestore(doc);
            results.add(ModelAdapter.toUserProfile(legacyModel));
            
            // 캐시 저장
            final cacheKey = '$_cachePrefix${doc.id}';
            await _cacheService.set(
              cacheKey,
              _mapper.toJson(legacyModel),
              ttl: _cacheTTL,
            );
          }
        }
      }
      
      return results;
    } on FirebaseException catch (e, stack) {
      throw NetworkException.fromFirebaseException(e, stack);
    } catch (e, stack) {
      throw RepositoryException(
        code: 'USER_GET_BATCH_ERROR',
        message: 'Failed to get user batch: $e',
        userMessage: '여러 사용자 정보를 불러오는데 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  @override
  Future<void> invalidateCache([String? id]) async {
    try {
      if (id != null) {
        final cacheKey = '$_cachePrefix$id';
        await _cacheService.delete(cacheKey);
      } else {
        // 모든 사용자 캐시 삭제
        await _cacheService.clearPattern(_cachePrefix);
      }
    } catch (e, stack) {
      throw CacheException.simple(
        operation: 'invalidate',
        key: id ?? 'all',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  // ==================== 사용자 전용 메서드 ====================
  
  Future<UsersModel?> getByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      
      return _mapper.fromFirestore(querySnapshot.docs.first);
    } on FirebaseException catch (e, stack) {
      throw NetworkException.fromFirebaseException(e, stack);
    } catch (e, stack) {
      throw RepositoryException(
        code: 'USER_GET_BY_EMAIL_ERROR',
        message: 'Failed to get user by email: $e',
        userMessage: '이메일로 사용자를 찾는데 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  Future<UsersModel?> getByPhone(String phoneNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      
      return _mapper.fromFirestore(querySnapshot.docs.first);
    } on FirebaseException catch (e, stack) {
      throw NetworkException.fromFirebaseException(e, stack);
    } catch (e, stack) {
      throw RepositoryException(
        code: 'USER_GET_BY_PHONE_ERROR',
        message: 'Failed to get user by phone: $e',
        userMessage: '전화번호로 사용자를 찾는데 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  Future<bool> checkEmailExists(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } on FirebaseException catch (e, stack) {
      throw NetworkException.fromFirebaseException(e, stack);
    } catch (e, stack) {
      throw RepositoryException(
        code: 'USER_CHECK_EMAIL_ERROR',
        message: 'Failed to check email existence: $e',
        userMessage: '이메일 중복 확인에 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  Future<bool> checkPhoneExists(String phoneNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      
      return querySnapshot.docs.isNotEmpty;
    } on FirebaseException catch (e, stack) {
      throw NetworkException.fromFirebaseException(e, stack);
    } catch (e, stack) {
      throw RepositoryException(
        code: 'USER_CHECK_PHONE_ERROR',
        message: 'Failed to check phone existence: $e',
        userMessage: '전화번호 중복 확인에 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  Future<UserProfile> updateProfile(String userId, Map<String, dynamic> profileData) async {
    try {
      // 부분 업데이트를 위한 데이터 준비
      final updateData = _mapper.toPartialUpdate(profileData);
      
      await _firestore.collection(_collection).doc(userId).update(updateData);
      
      // 업데이트된 사용자 정보 반환
      final user = await get(userId);
      if (user == null) {
        throw RepositoryException(
          code: 'USER_NOT_FOUND',
          message: 'User not found after update',
          userMessage: '업데이트 후 사용자를 찾을 수 없습니다',
        );
      }
      
      return user;
    } on FirebaseException catch (e, stack) {
      throw NetworkException.fromFirebaseException(e, stack);
    } catch (e, stack) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException(
        code: 'USER_UPDATE_PROFILE_ERROR',
        message: 'Failed to update profile: $e',
        userMessage: '프로필 업데이트에 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  Future<UserProfile> updateLastActive(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'lastActive': FieldValue.serverTimestamp(),
      });
      
      // 캐시 무효화
      await invalidateCache(userId);
      
      final user = await get(userId);
      if (user == null) {
        throw RepositoryException(
          code: 'USER_NOT_FOUND',
          message: 'User not found after update',
          userMessage: '사용자를 찾을 수 없습니다',
        );
      }
      
      return user;
    } on FirebaseException catch (e, stack) {
      throw NetworkException.fromFirebaseException(e, stack);
    } catch (e, stack) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException(
        code: 'USER_UPDATE_LAST_ACTIVE_ERROR',
        message: 'Failed to update last active: $e',
        userMessage: '마지막 활동 시간 업데이트에 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  @override
  Future<List<UserProfile>> searchUsers(String query, {int limit = 20}) async {
    try {
      if (query.isEmpty) return [];
      
      final searchTerms = query.toLowerCase().split(' ');
      
      // 검색어로 사용자 검색
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('searchableTerms', arrayContainsAny: searchTerms)
          .limit(limit)
          .get();
      
      final legacyModels = _mapper.fromFirestoreBatch(querySnapshot.docs);
      return legacyModels.map((legacy) => ModelAdapter.toUserProfile(legacy)).toList();
    } on FirebaseException catch (e, stack) {
      throw NetworkException.fromFirebaseException(e, stack);
    } catch (e, stack) {
      throw RepositoryException(
        code: 'USER_SEARCH_ERROR',
        message: 'Failed to search users: $e',
        userMessage: '사용자 검색에 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  Future<List<UserProfile>> getRecentUsers({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('lastActive', descending: true)
          .limit(limit)
          .get();
      
      final legacyModels = _mapper.fromFirestoreBatch(querySnapshot.docs);
      return legacyModels.map((legacy) => ModelAdapter.toUserProfile(legacy)).toList();
    } on FirebaseException catch (e, stack) {
      throw NetworkException.fromFirebaseException(e, stack);
    } catch (e, stack) {
      throw RepositoryException(
        code: 'USER_GET_RECENT_ERROR',
        message: 'Failed to get recent users: $e',
        userMessage: '최근 활동 사용자를 불러오는데 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  Future<List<UserProfile>> getTopUsers({int limit = 10}) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('totalPoints', descending: true)
          .limit(limit)
          .get();
      
      final legacyModels = _mapper.fromFirestoreBatch(querySnapshot.docs);
      return legacyModels.map((legacy) => ModelAdapter.toUserProfile(legacy)).toList();
    } on FirebaseException catch (e, stack) {
      throw NetworkException.fromFirebaseException(e, stack);
    } catch (e, stack) {
      throw RepositoryException(
        code: 'USER_GET_TOP_ERROR',
        message: 'Failed to get top users: $e',
        userMessage: '상위 랭킹 사용자를 불러오는데 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final user = await get(userId);
      if (user == null) {
        throw RepositoryException(
          code: 'USER_NOT_FOUND',
          message: 'User not found',
          userMessage: '사용자를 찾을 수 없습니다',
        );
      }
      
      // 통계 계산
      final stats = {
        'totalPosts': 0,
        'totalVotes': 0,
        'totalComments': 0,
        'totalLikes': 0,
        'totalPoints': (user.pointsA + user.pointsQ),
        'pointsA': user.pointsA,
        'pointsQ': user.pointsQ,
        'ranking': 0, // UserProfile에 ranking 필드가 없음
        'joinedDays': user.createdAt != null ? DateTime.now().difference(user.createdAt!).inDays : 0,
      };
      
      // 추가 통계는 필요시 다른 컬렉션에서 조회
      // TODO: PostRepository, CommentRepository 구현 후 연동
      
      return stats;
    } catch (e, stack) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException(
        code: 'USER_GET_STATS_ERROR',
        message: 'Failed to get user stats: $e',
        userMessage: '사용자 통계를 불러오는데 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  Future<bool> isAdmin(String userId) async {
    try {
      final user = await get(userId);
      return user?.role == 'admin';
    } catch (e, stack) {
      throw RepositoryException(
        code: 'USER_IS_ADMIN_ERROR',
        message: 'Failed to check admin status: $e',
        userMessage: '관리자 권한 확인에 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  Future<bool> isTester(String userId) async {
    try {
      final user = await get(userId);
      return user?.role == 'tester' || user?.role == 'admin';
    } catch (e, stack) {
      throw RepositoryException(
        code: 'USER_IS_TESTER_ERROR',
        message: 'Failed to check tester status: $e',
        userMessage: '테스터 권한 확인에 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  Future<void> incrementPoints(String userId, int pointsA, int pointsQ) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'pointsA': FieldValue.increment(pointsA),
        'pointsQ': FieldValue.increment(pointsQ),
        'totalPoints': FieldValue.increment(pointsA + pointsQ),
      });
      
      // 캐시 무효화
      await invalidateCache(userId);
    } on FirebaseException catch (e, stack) {
      throw NetworkException.fromFirebaseException(e, stack);
    } catch (e, stack) {
      throw RepositoryException(
        code: 'USER_INCREMENT_POINTS_ERROR',
        message: 'Failed to increment points: $e',
        userMessage: '포인트 증가에 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
  
  // ==================== 인터페이스 추가 메서드 ====================
  
  @override
  Future<UserProfile?> getUser(String userId) async {
    return get(userId);
  }
  
  @override
  Future<List<UserProfile>> getUsers(List<String> userIds) async {
    return getBatch(userIds);
  }
  
  @override
  Future<UserProfile?> getCurrentUser() async {
    // TODO: Firebase Auth와 통합 필요
    throw UnimplementedError('getCurrentUser needs Firebase Auth integration');
  }
  
  @override
  Future<UserProfile> createUser(UserProfile user) async {
    return create(user);
  }
  
  @override
  Future<UserProfile> updateUser(UserProfile user) async {
    return update(user);
  }
  
  @override
  Future<bool> deleteUser(String userId) async {
    return delete(userId);
  }
  
  @override
  Stream<UserProfile?> watchUser(String userId) {
    return watch(userId);
  }
  
  @override
  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    await _firestore.collection(_collection).doc(userId).update({
      'isOnline': isOnline,
      'lastActive': FieldValue.serverTimestamp(),
    });
    await invalidateCache(userId);
  }
  
  @override
  Future<void> updateLastSeen(String userId) async {
    await updateLastActive(userId);
  }
  
  @override
  Future<void> updateUserPoints(
    String userId, {
    int? pointsA,
    int? pointsQ,
  }) async {
    await incrementPoints(userId, pointsA ?? 0, pointsQ ?? 0);
  }
  
  @override
  Future<List<UserProfile>> getUserRankings(
    String type, {
    int limit = 100,
  }) async {
    final field = type == 'pointsA' ? 'pointsA' : 'pointsQ';
    final querySnapshot = await _firestore
        .collection(_collection)
        .orderBy(field, descending: true)
        .limit(limit)
        .get();
    
    final legacyModels = _mapper.fromFirestoreBatch(querySnapshot.docs);
    return legacyModels.map((legacy) => ModelAdapter.toUserProfile(legacy)).toList();
  }
  
  @override
  Future<bool> userExists(String userId) async {
    final user = await get(userId);
    return user != null;
  }
  
  @override
  Future<UserProfile?> getUserByEmail(String email) async {
    final legacyModel = await getByEmail(email);
    return legacyModel != null ? ModelAdapter.toUserProfile(legacyModel) : null;
  }
  
  @override
  Future<UserProfile?> getUserByPhone(String phoneNumber) async {
    final legacyModel = await getByPhone(phoneNumber);
    return legacyModel != null ? ModelAdapter.toUserProfile(legacyModel) : null;
  }
  
  Future<void> updateRanking(String userId, int newRanking) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'ranking': newRanking,
      });
      
      // 캐시 무효화
      await invalidateCache(userId);
    } on FirebaseException catch (e, stack) {
      throw NetworkException.fromFirebaseException(e, stack);
    } catch (e, stack) {
      throw RepositoryException(
        code: 'USER_UPDATE_RANKING_ERROR',
        message: 'Failed to update ranking: $e',
        userMessage: '랭킹 업데이트에 실패했습니다',
        originalError: e,
        stackTrace: stack,
      );
    }
  }
}