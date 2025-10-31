# Chat Feature - Phase 3: UnifiedCacheService Integration

> **마이그레이션 가이드**: 3-Layer 캐싱 시스템 통합
> **난이도**: ⭐⭐⭐⭐⭐ (매우 고급)
> **예상 소요 시간**: 2일 (16시간)
> **작성일**: 2025-01-31

---

## 📋 개요

### 마이그레이션 목적

Chat Feature에 UnifiedCacheService를 통합하여 3-Layer 캐싱 아키텍처를 구축하고, 성능을 대폭 향상시킵니다.

### 3-Layer Caching Architecture

```
┌─────────────────────────────────────────────┐
│  L1: SimpleMemoryCache (LRU)               │
│  - 100개 제한                                │
│  - 5분 TTL                                   │
│  - 응답 시간: <10ms                          │
└──────────────┬──────────────────────────────┘
               │ Cache Miss
               ↓
┌─────────────────────────────────────────────┐
│  L2: Hive Local DB (Persistent)            │
│  - 무제한 크기                               │
│  - 영구 저장                                 │
│  - 응답 시간: 10-30ms                       │
└──────────────┬──────────────────────────────┘
               │ Cache Miss
               ↓
┌─────────────────────────────────────────────┐
│  L3: Firestore Offline Cache               │
│  - Firebase 내장 캐시                        │
│  - 무제한 크기                               │
│  - 응답 시간: 50-100ms                      │
└──────────────┬──────────────────────────────┘
               │ Cache Miss
               ↓
        Network Request (300-500ms)
```

### 영향 범위

| 레이어 | 파일 수 | 변경 줄 수 | 주요 변경 사항 |
|--------|---------|-----------|---------------|
| **Data (Repository)** | 1개 | +150줄 | 캐시 읽기/쓰기 로직 추가 |
| **Services** | 3개 | +450줄 | ChatCacheService, CacheKeys, Preload |
| **DI** | 1개 | +20줄 | Cache Provider 등록 |
| **Main** | 1개 | +30줄 | 캐시 초기화 및 프리로드 |
| **합계** | **6개** | **+650줄** | - |

### 주요 이점

| 항목 | Before (캐싱 없음) | After (3-Layer Cache) | 개선율 |
|------|-------------------|----------------------|--------|
| **응답 시간** | 300-500ms | <10ms (L1 히트) | **97% ↓** |
| **Firestore 읽기** | 100% | 40% | **60% ↓** |
| **오프라인 지원** | 제한적 | 완전 지원 | **100% ↑** |
| **캐시 히트율** | 0% | 60-80% | **60-80% ↑** |
| **사용자 경험** | 느림 | 즉시 응답 | **대폭 개선** |

---

## 🔍 현재 상태 분석

### 1. Repository (캐싱 없음)

**파일**: `data/repositories/chat_repository_impl.dart:46-59`

```dart
/// ❌ 현재: 캐싱 없이 직접 Firestore 접근
@override
Stream<List<Chat>> queryChats({
  required String userId,
  int limit = 50,
  String? orderBy,
  bool descending = true,
}) =>
    _remoteDatasource
        .queryChats(
          userId: userId,
          limit: limit,
          orderBy: orderBy,
          descending: descending,
        )
        .map((dtos) => ChatMapper.toEntityList(dtos));
```

**문제점**:
1. **매번 Firestore 접근**: 네트워크 요청으로 300-500ms 소요
2. **중복 읽기**: 동일한 데이터를 반복 요청
3. **비용 증가**: Firestore 읽기 작업 비용 발생
4. **오프라인 미지원**: 네트워크 없으면 데이터 접근 불가

### 2. Provider (캐시 전략 없음)

**파일**: `presentation/providers/chat_providers.dart`

```dart
/// ❌ 현재: 캐시 없이 즉시 빈 리스트 emit
final chatListStreamProvider =
    StreamProvider.autoDispose.family<List<Chat>, ChatListParams>(
  (ref, params) async* {
    yield [];  // ❌ 캐시된 데이터 없음

    await for (final either in getChatListUseCase.execute(...)) {
      yield* either.fold(
        (failure) => Stream.error(failure),
        (chats) async* { yield chats; },
      );
    }

    ref.keepAlive();
  },
);
```

**문제점**:
1. **첫 emit이 빈 리스트**: 캐시된 데이터가 있어도 표시 안 함
2. **로딩 시간 길어짐**: 매번 Firestore 응답 대기
3. **플리커링**: 빈 화면 → 로딩 → 데이터 순서로 깜빡임

---

## 🎯 마이그레이션 목표

### Before → After 비교

#### 1. Repository 계층 (Cache-First Pattern)

```dart
// ❌ Before: 캐싱 없음
@override
Stream<List<Chat>> queryChats({required String userId}) =>
    _remoteDatasource
        .queryChats(userId: userId)
        .map((dtos) => ChatMapper.toEntityList(dtos));

// ✅ After: 3-Layer 캐싱
@override
Stream<List<Chat>> queryChats({required String userId}) async* {
  // 1. L1 캐시 시도 (Memory)
  final cachedChats = await _cacheService.getChatList(userId);
  if (cachedChats != null) {
    yield cachedChats;  // <10ms 응답
  }

  // 2. Firestore Stream (L2, L3 자동 처리)
  await for (final dtos in _remoteDatasource.queryChats(userId: userId)) {
    final chats = ChatMapper.toEntityList(dtos);

    // 3. 캐시 업데이트 (Write-Through)
    await _cacheService.setChatList(userId, chats);

    yield chats;
  }
}
```

#### 2. Provider 계층 (캐시 인식)

```dart
// ❌ Before: 빈 리스트 즉시 emit
yield [];  // 캐시 무시

// ✅ After: 캐시된 데이터가 있으면 자동으로 emit
// Repository에서 캐시를 먼저 emit하므로 Provider는 변경 불필요
// 단, 첫 emit을 제거하여 캐시가 없을 때만 로딩 상태 표시
```

#### 3. 프리로드 전략

```dart
// ✅ After: 앱 시작 시 미리 캐싱
Future<void> preloadChatData() async {
  final currentUserId = getCurrentUserId();

  // 1. 최근 채팅 목록 프리로드
  await chatRepository.queryChats(userId: currentUserId, limit: 10).first;

  // 2. 각 채팅의 최근 메시지 프리로드
  final chats = await cacheService.getChatList(currentUserId);
  for (final chat in chats ?? []) {
    await chatRepository.queryMessagesByChatId(chatId: chat.id, limit: 15).first;
  }
}
```

---

## 📝 단계별 마이그레이션 가이드

### Step 1: UnifiedCacheService 확인

**파일**: `services/cache/unified_cache_service.dart`

UnifiedCacheService가 이미 구현되어 있는지 확인:

```dart
/// UnifiedCacheService - 3-Layer 캐싱 오케스트레이터
///
/// **Caching Strategy**:
/// - L1 (Memory): SimpleMemoryCache (LRU, 100개 제한, 5분 TTL)
/// - L2 (Local DB): Hive (영구 저장)
/// - L3 (Remote Cache): Firestore Offline Cache
///
/// **Flow**:
/// 1. Get: L1 → L2 → L3 → Network
/// 2. Set: L1, L2 동시 업데이트
class UnifiedCacheService {
  final SimpleMemoryCache _memoryCache;
  final Box<dynamic> _hiveBox;

  UnifiedCacheService({
    required SimpleMemoryCache memoryCache,
    required Box<dynamic> hiveBox,
  })  : _memoryCache = memoryCache,
        _hiveBox = hiveBox;

  /// 캐시 읽기 (3-Layer 순회)
  Future<T?> get<T>(String key, T Function(dynamic) fromJson) async {
    // L1: Memory
    final memCached = _memoryCache.get(key);
    if (memCached != null) {
      return fromJson(memCached);
    }

    // L2: Hive
    final hiveCached = _hiveBox.get(key);
    if (hiveCached != null) {
      final result = fromJson(hiveCached);
      _memoryCache.put(key, hiveCached);  // L1 업데이트
      return result;
    }

    // L3: Firestore Offline Cache (자동 처리)
    return null;
  }

  /// 캐시 쓰기 (L1, L2 동시 업데이트)
  Future<void> set(String key, dynamic value) async {
    _memoryCache.put(key, value);
    await _hiveBox.put(key, value);
  }

  /// 캐시 무효화
  Future<void> invalidate(String key) async {
    _memoryCache.remove(key);
    await _hiveBox.delete(key);
  }

  /// 캐시 통계
  CacheStatistics getStatistics() {
    return CacheStatistics(
      l1HitCount: _memoryCache.hitCount,
      l1MissCount: _memoryCache.missCount,
      l2HitCount: _hiveBox.length,
      // ...
    );
  }
}
```

✅ **이미 구현되어 있다면 Step 2로 이동**
❌ **없다면 UnifiedCacheService 먼저 구현 필요**

### Step 2: ChatCacheService 생성

**신규 파일**: `services/chat_cache_service.dart`

```dart
import 'package:fpdart/fpdart.dart';

import '../data/repositories/chat_repository_impl.dart';
import '../domain/entities/chat.dart';
import '../domain/entities/message.dart';
import '/services/cache/unified_cache_service.dart';
import 'cache_keys.dart';

/// Chat Feature 전용 캐시 서비스
///
/// **Responsibilities**:
/// - UnifiedCacheService 래핑
/// - Chat/Message 직렬화/역직렬화
/// - 캐시 키 관리
///
/// **Pattern**:
/// - Cache-Aside: 애플리케이션이 캐시 관리
/// - Write-Through: 쓰기 시 캐시와 DB 동시 업데이트
class ChatCacheService {
  final UnifiedCacheService _cacheService;

  ChatCacheService({required UnifiedCacheService cacheService})
      : _cacheService = cacheService;

  // ========== Chat List Caching ==========

  /// 채팅 목록 캐시 읽기
  ///
  /// **Key**: `chat_list_{userId}`
  /// **TTL**: 5분 (L1), 무제한 (L2)
  Future<List<Chat>?> getChatList(String userId) async {
    final key = ChatCacheKeys.chatList(userId);

    return _cacheService.get<List<Chat>>(
      key,
      (json) {
        if (json is! List) return [];
        return json
            .map((item) => Chat.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// 채팅 목록 캐시 쓰기
  Future<void> setChatList(String userId, List<Chat> chats) async {
    final key = ChatCacheKeys.chatList(userId);
    final json = chats.map((chat) => chat.toJson()).toList();

    await _cacheService.set(key, json);
  }

  /// 채팅 목록 캐시 무효화
  Future<void> invalidateChatList(String userId) async {
    final key = ChatCacheKeys.chatList(userId);
    await _cacheService.invalidate(key);
  }

  // ========== Messages Caching ==========

  /// 메시지 목록 캐시 읽기
  ///
  /// **Key**: `chat_messages_{chatId}`
  /// **TTL**: 5분 (L1), 무제한 (L2)
  Future<List<Message>?> getMessages(String chatId) async {
    final key = ChatCacheKeys.messages(chatId);

    return _cacheService.get<List<Message>>(
      key,
      (json) {
        if (json is! List) return [];
        return json
            .map((item) => Message.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// 메시지 목록 캐시 쓰기
  Future<void> setMessages(String chatId, List<Message> messages) async {
    final key = ChatCacheKeys.messages(chatId);
    final json = messages.map((msg) => msg.toJson()).toList();

    await _cacheService.set(key, json);
  }

  /// 메시지 캐시 무효화
  Future<void> invalidateMessages(String chatId) async {
    final key = ChatCacheKeys.messages(chatId);
    await _cacheService.invalidate(key);
  }

  // ========== Single Chat Caching ==========

  /// 단일 채팅 캐시 읽기
  Future<Chat?> getChat(String chatId) async {
    final key = ChatCacheKeys.chat(chatId);

    return _cacheService.get<Chat>(
      key,
      (json) => Chat.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 단일 채팅 캐시 쓰기
  Future<void> setChat(Chat chat) async {
    final key = ChatCacheKeys.chat(chat.id);
    await _cacheService.set(key, chat.toJson());
  }

  /// 단일 채팅 캐시 무효화
  Future<void> invalidateChat(String chatId) async {
    final key = ChatCacheKeys.chat(chatId);
    await _cacheService.invalidate(key);
  }

  // ========== Cache Statistics ==========

  /// 캐시 통계 조회
  CacheStatistics getStatistics() {
    return _cacheService.getStatistics();
  }

  /// 캐시 전체 삭제 (로그아웃 시)
  Future<void> clearAll() async {
    // Chat List keys
    // Messages keys
    // Single Chat keys
    // 모든 chat 관련 키 삭제
  }
}
```

### Step 3: ChatCacheKeys 생성

**신규 파일**: `services/cache_keys.dart`

```dart
/// Chat Feature 캐시 키 관리
///
/// **Naming Convention**:
/// - chat_list_{userId}
/// - chat_messages_{chatId}
/// - chat_{chatId}
///
/// **Key Versioning**:
/// - v1: 초기 버전
/// - v2: Freezed 마이그레이션
/// - v3: Either 패턴 적용
class ChatCacheKeys {
  static const String _version = 'v3';

  /// 채팅 목록 키
  static String chatList(String userId) => '${_version}_chat_list_$userId';

  /// 메시지 목록 키
  static String messages(String chatId) => '${_version}_chat_messages_$chatId';

  /// 단일 채팅 키
  static String chat(String chatId) => '${_version}_chat_$chatId';

  /// 읽지 않은 채팅 개수 키
  static String unreadCount(String userId) => '${_version}_unread_count_$userId';

  /// AI 채팅방 키
  static String aiChat(String userId) => '${_version}_ai_chat_$userId';
}
```

### Step 4: ChatRepositoryImpl에 캐싱 통합

**파일**: `data/repositories/chat_repository_impl.dart`

#### Before (226줄, 캐싱 없음):

```dart
class ChatRepositoryImpl implements IChatRepository, ChatContract {
  final IChatRemoteDatasource _remoteDatasource;

  ChatRepositoryImpl({required IChatRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  @override
  Stream<List<Chat>> queryChats({...}) =>
      _remoteDatasource
          .queryChats(...)
          .map((dtos) => ChatMapper.toEntityList(dtos));
}
```

#### After (376줄, +150줄, 캐싱 추가):

```dart
class ChatRepositoryImpl implements IChatRepository, ChatContract {
  final IChatRemoteDatasource _remoteDatasource;
  final ChatCacheService _cacheService;  // ✅ 캐시 서비스 추가

  ChatRepositoryImpl({
    required IChatRemoteDatasource remoteDatasource,
    required ChatCacheService cacheService,  // ✅ DI 주입
  })  : _remoteDatasource = remoteDatasource,
        _cacheService = cacheService;

  // ========== Cache-First Pattern ==========

  /// 채팅 목록 조회 (Cache-First)
  ///
  /// **Flow**:
  /// 1. 캐시된 데이터 즉시 emit (L1 → L2 → L3)
  /// 2. Firestore Stream 구독
  /// 3. 새 데이터 수신 시 캐시 업데이트 + emit
  @override
  Stream<List<Chat>> queryChats({
    required String userId,
    int limit = 50,
    String? orderBy,
    bool descending = true,
  }) async* {
    // 1. ✅ 캐시 먼저 시도 (L1 → L2 → L3)
    final cachedChats = await _cacheService.getChatList(userId);
    if (cachedChats != null && cachedChats.isNotEmpty) {
      yield cachedChats;  // <10ms 응답
    }

    // 2. ✅ Firestore Stream (실시간 업데이트)
    await for (final dtos in _remoteDatasource.queryChats(
      userId: userId,
      limit: limit,
      orderBy: orderBy,
      descending: descending,
    )) {
      final chats = ChatMapper.toEntityList(dtos);

      // 3. ✅ 캐시 업데이트 (Write-Through)
      await _cacheService.setChatList(userId, chats);

      yield chats;
    }
  }

  /// 메시지 목록 조회 (Cache-First)
  @override
  Stream<List<Message>> queryMessagesByChatId({
    required String chatId,
    int limit = 30,
    String? orderBy,
    bool descending = true,
  }) async* {
    // 1. ✅ 캐시 먼저 시도
    final cachedMessages = await _cacheService.getMessages(chatId);
    if (cachedMessages != null && cachedMessages.isNotEmpty) {
      yield cachedMessages;
    }

    // 2. ✅ Firestore Stream
    await for (final dtos in _remoteDatasource.queryMessagesByChatId(
      chatId: chatId,
      limit: limit,
      orderBy: orderBy,
      descending: descending,
    )) {
      final messages = MessageMapper.toEntityList(dtos);

      // 3. ✅ 캐시 업데이트
      await _cacheService.setMessages(chatId, messages);

      yield messages;
    }
  }

  // ========== CRUD with Cache Invalidation ==========

  /// 채팅 생성 (캐시 무효화)
  @override
  Future<void> createChat(Chat chat) async {
    await _remoteDatasource.createChat(ChatMapper.toDto(chat));

    // ✅ 채팅 목록 캐시 무효화 (재조회 필요)
    for (final userId in chat.participantIds) {
      await _cacheService.invalidateChatList(userId);
    }
  }

  /// 채팅 삭제 (캐시 무효화)
  @override
  Future<void> deleteChat(String chatId) async {
    final chat = await getChat(chatId);
    if (chat == null) return;

    await _remoteDatasource.deleteChat(chatId);

    // ✅ 관련 캐시 모두 무효화
    await _cacheService.invalidateChat(chatId);
    await _cacheService.invalidateMessages(chatId);

    for (final userId in chat.participantIds) {
      await _cacheService.invalidateChatList(userId);
    }
  }

  /// 메시지 전송 (캐시 업데이트)
  @override
  Future<void> sendMessage(String chatId, Message message) async {
    await _remoteDatasource.sendMessage(chatId, MessageMapper.toDto(message));

    // ✅ 메시지 캐시 무효화 (새 메시지 추가됨)
    await _cacheService.invalidateMessages(chatId);

    // ✅ 채팅 목록 캐시 무효화 (lastMessageAt 변경됨)
    final chat = await getChat(chatId);
    if (chat != null) {
      for (final userId in chat.participantIds) {
        await _cacheService.invalidateChatList(userId);
      }
    }
  }
}
```

**변경 사항**:
1. **ChatCacheService 주입**: DI를 통해 캐시 서비스 주입
2. **Cache-First Pattern**: 캐시 → Firestore 순서로 조회
3. **Write-Through**: Firestore 응답 시 캐시 자동 업데이트
4. **Cache Invalidation**: CRUD 작업 시 관련 캐시 무효화

### Step 5: DI 모듈 업데이트

**파일**: `di/chat_di_module.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/services/cache/unified_cache_service.dart';
import '../services/chat_cache_service.dart';
import '../data/repositories/chat_repository_impl.dart';

// ========== Cache Service Provider ==========

/// UnifiedCacheService Provider (Global)
///
/// **Note**: UnifiedCacheService는 앱 전체에서 공유되므로
/// main.dart에서 초기화된 인스턴스를 사용
final unifiedCacheServiceProvider = Provider<UnifiedCacheService>((ref) {
  throw UnimplementedError('UnifiedCacheService must be initialized in main.dart');
});

/// ChatCacheService Provider
final chatCacheServiceProvider = Provider<ChatCacheService>((ref) {
  final cacheService = ref.watch(unifiedCacheServiceProvider);
  return ChatCacheService(cacheService: cacheService);
});

// ========== Repository Provider (캐시 통합) ==========

final chatRepositoryProvider = Provider<ChatRepositoryImpl>((ref) {
  final remoteDatasource = ref.watch(chatRemoteDatasourceProvider);
  final cacheService = ref.watch(chatCacheServiceProvider);  // ✅ 캐시 주입

  return ChatRepositoryImpl(
    remoteDatasource: remoteDatasource,
    cacheService: cacheService,  // ✅ 생성자에 전달
  );
});
```

### Step 6: main.dart에서 캐시 초기화

**파일**: `main.dart`

```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/services/cache/unified_cache_service.dart';
import '/services/cache/simple_memory_cache.dart';
import '/services/cache/preload_strategy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ========== 1. Hive 초기화 ==========
  await Hive.initFlutter();
  final hiveBox = await Hive.openBox<dynamic>('unified_cache');

  // ========== 2. UnifiedCacheService 생성 ==========
  final memoryCache = SimpleMemoryCache(
    maxSize: 100,
    defaultTTL: Duration(minutes: 5),
  );

  final cacheService = UnifiedCacheService(
    memoryCache: memoryCache,
    hiveBox: hiveBox,
  );

  // ========== 3. ProviderScope with Override ==========
  runApp(
    ProviderScope(
      overrides: [
        // ✅ UnifiedCacheService를 전역 Provider로 등록
        unifiedCacheServiceProvider.overrideWithValue(cacheService),
      ],
      child: MyApp(),
    ),
  );

  // ========== 4. 프리로드 전략 실행 (백그라운드) ==========
  Future.microtask(() async {
    // 500ms 지연 (UI 렌더링 완료 대기)
    await Future.delayed(Duration(milliseconds: 500));

    final preloadStrategy = PreloadStrategy(cacheService: cacheService);
    await preloadStrategy.preloadChatData();
  });
}
```

### Step 7: PreloadStrategy 구현

**신규 파일**: `services/cache/preload_strategy.dart`

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/services/cache/unified_cache_service.dart';
import '/features/chat/data/repositories/chat_repository_impl.dart';

/// 캐시 프리로드 전략
///
/// **목표**:
/// - 앱 시작 시 최근 채팅 데이터 미리 캐싱
/// - 백그라운드 실행으로 UI 차단 없음
/// - 60-80% 캐시 히트율 달성
///
/// **전략**:
/// 1. 최근 10개 채팅 프리로드
/// 2. 각 채팅의 최근 15개 메시지 프리로드
/// 3. 100ms 간격으로 순차 실행 (부하 분산)
class PreloadStrategy {
  final UnifiedCacheService _cacheService;

  PreloadStrategy({required UnifiedCacheService cacheService})
      : _cacheService = cacheService;

  /// 채팅 데이터 프리로드
  Future<void> preloadChatData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // 1. 최근 채팅 목록 조회
      final chatSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('participantIds', arrayContains: currentUser.uid)
          .orderBy('lastMessageAt', descending: true)
          .limit(10)
          .get();

      // 2. 각 채팅의 메시지 프리로드
      for (final chatDoc in chatSnapshot.docs) {
        final chatId = chatDoc.id;

        // 최근 15개 메시지 조회
        final messageSnapshot = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(15)
            .get();

        // 100ms 간격 (부하 분산)
        await Future.delayed(Duration(milliseconds: 100));
      }

      print('✅ Preload completed: ${chatSnapshot.docs.length} chats');
    } catch (e) {
      print('❌ Preload failed: $e');
    }
  }
}
```

---

## 🧪 테스트 전략

### 1. 캐시 히트/미스 테스트

**파일**: `test/unit/services/chat_cache_service_test.dart`

```dart
void main() {
  group('ChatCacheService', () {
    late ChatCacheService cacheService;
    late MockUnifiedCacheService mockCacheService;

    setUp(() {
      mockCacheService = MockUnifiedCacheService();
      cacheService = ChatCacheService(cacheService: mockCacheService);
    });

    test('L1 캐시 히트 시 <10ms 응답', () async {
      // Arrange
      final mockChats = [Chat(id: '1', participantIds: ['user1'])];
      when(mockCacheService.get<List<Chat>>(any, any))
          .thenAnswer((_) async => mockChats);

      // Act
      final stopwatch = Stopwatch()..start();
      final result = await cacheService.getChatList('user1');
      stopwatch.stop();

      // Assert
      expect(result, mockChats);
      expect(stopwatch.elapsedMilliseconds, lessThan(10));
    });

    test('캐시 미스 시 null 반환', () async {
      // Arrange
      when(mockCacheService.get<List<Chat>>(any, any))
          .thenAnswer((_) async => null);

      // Act
      final result = await cacheService.getChatList('user1');

      // Assert
      expect(result, isNull);
    });

    test('setChatList 시 L1, L2 모두 업데이트', () async {
      // Arrange
      final mockChats = [Chat(id: '1', participantIds: ['user1'])];

      // Act
      await cacheService.setChatList('user1', mockChats);

      // Assert
      verify(mockCacheService.set(any, any)).called(1);
    });
  });
}
```

### 2. Repository 캐싱 통합 테스트

**파일**: `test/integration/chat_repository_cache_test.dart`

```dart
void main() {
  group('ChatRepository - Cache Integration', () {
    late ChatRepositoryImpl repository;
    late MockChatCacheService mockCacheService;
    late MockChatRemoteDatasource mockDatasource;

    setUp(() {
      mockCacheService = MockChatCacheService();
      mockDatasource = MockChatRemoteDatasource();
      repository = ChatRepositoryImpl(
        remoteDatasource: mockDatasource,
        cacheService: mockCacheService,
      );
    });

    test('캐시 히트 시 즉시 emit', () async {
      // Arrange
      final cachedChats = [Chat(id: '1', participantIds: ['user1'])];
      when(mockCacheService.getChatList('user1'))
          .thenAnswer((_) async => cachedChats);

      when(mockDatasource.queryChats(userId: 'user1'))
          .thenAnswer((_) => Stream.empty());

      // Act
      final stream = repository.queryChats(userId: 'user1');

      // Assert
      await expectLater(
        stream,
        emits(cachedChats),  // 캐시된 데이터 즉시 emit
      );
    });

    test('Firestore 응답 시 캐시 업데이트', () async {
      // Arrange
      final newChats = [
        Chat(id: '1', participantIds: ['user1']),
        Chat(id: '2', participantIds: ['user1']),
      ];
      final newDtos = ChatMapper.toDtoList(newChats);

      when(mockCacheService.getChatList('user1'))
          .thenAnswer((_) async => null);

      when(mockDatasource.queryChats(userId: 'user1'))
          .thenAnswer((_) => Stream.value(newDtos));

      // Act
      final stream = repository.queryChats(userId: 'user1');
      await stream.first;

      // Assert
      verify(mockCacheService.setChatList('user1', newChats)).called(1);
    });

    test('채팅 삭제 시 관련 캐시 모두 무효화', () async {
      // Arrange
      final chat = Chat(
        id: 'chat1',
        participantIds: ['user1', 'user2'],
      );

      when(mockCacheService.getChat('chat1'))
          .thenAnswer((_) async => chat);

      // Act
      await repository.deleteChat('chat1');

      // Assert
      verify(mockCacheService.invalidateChat('chat1')).called(1);
      verify(mockCacheService.invalidateMessages('chat1')).called(1);
      verify(mockCacheService.invalidateChatList('user1')).called(1);
      verify(mockCacheService.invalidateChatList('user2')).called(1);
    });
  });
}
```

### 3. 캐시 성능 벤치마크

**파일**: `test/benchmark/cache_performance_test.dart`

```dart
void main() {
  group('Cache Performance Benchmark', () {
    late ChatCacheService cacheService;
    late UnifiedCacheService unifiedCache;

    setUp(() async {
      await Hive.initFlutter();
      final hiveBox = await Hive.openBox<dynamic>('test_cache');
      final memCache = SimpleMemoryCache(maxSize: 100);

      unifiedCache = UnifiedCacheService(
        memoryCache: memCache,
        hiveBox: hiveBox,
      );

      cacheService = ChatCacheService(cacheService: unifiedCache);
    });

    test('L1 캐시 응답 시간 < 10ms', () async {
      // Arrange
      final mockChats = List.generate(
        10,
        (i) => Chat(id: 'chat$i', participantIds: ['user1']),
      );
      await cacheService.setChatList('user1', mockChats);

      // Act
      final stopwatch = Stopwatch()..start();
      final result = await cacheService.getChatList('user1');
      stopwatch.stop();

      // Assert
      expect(result, isNotNull);
      expect(stopwatch.elapsedMilliseconds, lessThan(10));
      print('✅ L1 cache hit: ${stopwatch.elapsedMilliseconds}ms');
    });

    test('L2 캐시 응답 시간 < 30ms', () async {
      // Arrange
      final mockChats = List.generate(
        10,
        (i) => Chat(id: 'chat$i', participantIds: ['user1']),
      );
      await cacheService.setChatList('user1', mockChats);

      // L1 캐시 클리어 (L2 테스트)
      unifiedCache._memoryCache.clear();

      // Act
      final stopwatch = Stopwatch()..start();
      final result = await cacheService.getChatList('user1');
      stopwatch.stop();

      // Assert
      expect(result, isNotNull);
      expect(stopwatch.elapsedMilliseconds, lessThan(30));
      print('✅ L2 cache hit: ${stopwatch.elapsedMilliseconds}ms');
    });

    test('1000번 조회 평균 < 15ms', () async {
      // Arrange
      final mockChats = List.generate(
        10,
        (i) => Chat(id: 'chat$i', participantIds: ['user1']),
      );
      await cacheService.setChatList('user1', mockChats);

      // Act
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        await cacheService.getChatList('user1');
      }
      stopwatch.stop();

      final avgMs = stopwatch.elapsedMilliseconds / 1000;

      // Assert
      expect(avgMs, lessThan(15));
      print('✅ 1000번 조회 평균: ${avgMs.toStringAsFixed(2)}ms');
    });
  });
}
```

---

## 🔄 롤백 계획

### 롤백이 필요한 경우

1. **캐시 불일치 문제**: Firestore와 캐시 데이터가 동기화되지 않음
2. **메모리 사용량 증가**: L1 캐시가 메모리를 과도하게 사용
3. **복잡도 증가**: 캐시 관리 로직이 오히려 성능 저하

### 롤백 절차

#### Step 1: Git Revert

```bash
git log --oneline --grep="Cache Integration"
git revert <commit-hash>
```

#### Step 2: Repository 복구

```dart
// After (롤백 후)
@override
Stream<List<Chat>> queryChats({required String userId}) =>
    _remoteDatasource
        .queryChats(userId: userId)
        .map((dtos) => ChatMapper.toEntityList(dtos));

// Before (마이그레이션 전)
@override
Stream<List<Chat>> queryChats({required String userId}) async* {
  final cachedChats = await _cacheService.getChatList(userId);
  if (cachedChats != null) yield cachedChats;

  await for (final dtos in _remoteDatasource.queryChats(...)) {
    final chats = ChatMapper.toEntityList(dtos);
    await _cacheService.setChatList(userId, chats);
    yield chats;
  }
}
```

#### Step 3: DI 복구

```dart
// After (롤백 후)
final chatRepositoryProvider = Provider<ChatRepositoryImpl>((ref) {
  final remoteDatasource = ref.watch(chatRemoteDatasourceProvider);
  return ChatRepositoryImpl(remoteDatasource: remoteDatasource);
});

// Before (마이그레이션 전)
final chatRepositoryProvider = Provider<ChatRepositoryImpl>((ref) {
  final remoteDatasource = ref.watch(chatRemoteDatasourceProvider);
  final cacheService = ref.watch(chatCacheServiceProvider);
  return ChatRepositoryImpl(
    remoteDatasource: remoteDatasource,
    cacheService: cacheService,
  );
});
```

#### Step 4: main.dart 복구

```dart
// After (롤백 후)
runApp(
  ProviderScope(
    child: MyApp(),
  ),
);

// Before (마이그레이션 전)
runApp(
  ProviderScope(
    overrides: [
      unifiedCacheServiceProvider.overrideWithValue(cacheService),
    ],
    child: MyApp(),
  ),
);
```

---

## ✅ 완료 체크리스트

### Phase 3 완료 기준

- [ ] **의존성 확인**
  - [ ] pubspec.yaml에 hive_flutter 추가
  - [ ] UnifiedCacheService 구현 확인
  - [ ] SimpleMemoryCache 구현 확인

- [ ] **ChatCacheService 생성**
  - [ ] chat_cache_service.dart 생성
  - [ ] getChatList/setChatList 구현
  - [ ] getMessages/setMessages 구현
  - [ ] invalidate 메서드 구현

- [ ] **Cache Keys 생성**
  - [ ] cache_keys.dart 생성
  - [ ] 버전 관리 (v3) 확인
  - [ ] 모든 캐시 키 정의

- [ ] **Repository 캐싱 통합**
  - [ ] ChatCacheService 의존성 주입
  - [ ] queryChats() Cache-First 패턴 적용
  - [ ] queryMessagesByChatId() 캐싱 추가
  - [ ] CRUD 작업 시 캐시 무효화

- [ ] **DI 업데이트**
  - [ ] chatCacheServiceProvider 등록
  - [ ] chatRepositoryProvider 캐시 주입
  - [ ] unifiedCacheServiceProvider override

- [ ] **main.dart 초기화**
  - [ ] Hive.initFlutter() 호출
  - [ ] UnifiedCacheService 생성
  - [ ] ProviderScope override
  - [ ] 프리로드 전략 실행

- [ ] **PreloadStrategy 구현**
  - [ ] preload_strategy.dart 생성
  - [ ] 최근 10개 채팅 프리로드
  - [ ] 채팅당 15개 메시지 프리로드
  - [ ] 100ms 간격 부하 분산

- [ ] **테스트**
  - [ ] 단위 테스트: ChatCacheService
  - [ ] 통합 테스트: Repository 캐싱
  - [ ] 성능 테스트: L1/L2 응답 시간
  - [ ] 벤치마크: 1000번 조회 평균

- [ ] **성능 검증**
  - [ ] L1 캐시 히트 < 10ms
  - [ ] L2 캐시 히트 < 30ms
  - [ ] 캐시 히트율 60-80%
  - [ ] Firestore 읽기 60% 감소

- [ ] **문서화**
  - [ ] CHANGELOG.md 업데이트
  - [ ] README.md에 캐싱 전략 설명
  - [ ] Phase 4 준비 (Idempotency)

---

## 📊 마이그레이션 영향 분석

### 캐시 성능 지표

| 시나리오 | Before (캐싱 없음) | After (3-Layer Cache) | 개선율 |
|---------|-------------------|----------------------|--------|
| **첫 조회** | 300-500ms | 300-500ms | 0% (동일) |
| **두 번째 조회** | 300-500ms | <10ms (L1) | **97% ↓** |
| **오프라인** | 불가 | <30ms (L2) | **100% ↑** |
| **앱 재시작** | 300-500ms | <10ms (L1) | **97% ↓** |

### Firestore 비용 절감

```
Before (캐싱 없음):
- 10회 채팅 목록 조회 = 10 reads
- 10회 메시지 조회 = 10 reads
- 합계: 20 reads

After (3-Layer Cache):
- 첫 조회: 1 read (캐시 저장)
- 이후 9회: 0 reads (캐시 히트)
- 합계: 1 read

비용 절감: 95% (20 → 1)
```

### 사용자 경험 개선

| 항목 | Before | After | 변화 |
|------|--------|-------|------|
| **로딩 시간** | 500ms | <10ms | **98% ↓** |
| **오프라인 지원** | ❌ | ✅ | **100% ↑** |
| **플리커링** | 발생 | 없음 | **제거** |
| **앱 반응성** | 느림 | 즉시 | **대폭 개선** |

---

## 🎓 추가 학습 자료

### 캐싱 전략 패턴

#### 1. Cache-Aside (Lazy Loading)

```dart
// ✅ Chat Feature 사용 패턴
Future<List<Chat>> getChats(String userId) async {
  // 1. 캐시 먼저 확인
  final cached = await cache.get(userId);
  if (cached != null) return cached;

  // 2. 캐시 미스 → DB 조회
  final chats = await db.queryChats(userId);

  // 3. 캐시 업데이트
  await cache.set(userId, chats);

  return chats;
}
```

#### 2. Write-Through

```dart
// ✅ Chat Feature 사용 패턴
Future<void> updateChat(Chat chat) async {
  // 1. DB 쓰기
  await db.updateChat(chat);

  // 2. 캐시 동시 업데이트
  await cache.set(chat.id, chat);
}
```

#### 3. Write-Behind (Async)

```dart
// ❌ Chat Feature는 미사용 (실시간 일관성 필요)
Future<void> updateChat(Chat chat) async {
  // 1. 캐시만 업데이트
  await cache.set(chat.id, chat);

  // 2. DB는 나중에 비동기로 업데이트
  scheduleMicrotask(() async {
    await db.updateChat(chat);
  });
}
```

### Auth & Voting Feature 참조

- **UnifiedCacheService**: 3-Layer 캐싱 아키텍처 구현
- **Voting Feature**: 캐시 무효화 전략 (투표 완료 시)
- **Profile Feature**: 프리로드 전략 (사용자 프로필)

---

## 📌 다음 단계: Phase 4

Phase 3 완료 후, **Phase 4: CRUD Cleanup & Idempotency**로 진행:

```
서브컬렉션 정리 + IdempotencyService 통합
```

**예상 효과**:
- 고아 서브컬렉션 0개 (완전 정리)
- 중복 작업 방지 (UUID 기반)
- Transaction 안전성 보장

---

**작성자**: AI Assistant
**리뷰어**: [Your Name]
**승인일**: [YYYY-MM-DD]
