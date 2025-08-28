# 🧪 Backend Models 테스트 전략

> 데이터 모델 레이어 테스트 가이드  
> 목표 커버리지: 80% | 예상 기간: 3일

## 📋 테스트 개요

### 현재 상태
- **테스트 커버리지**: 0%
- **테스트 파일**: 없음
- **Mock 구현**: 없음
- **통합 테스트**: 없음

### 목표 상태
- **단위 테스트**: 60% (모델 로직)
- **통합 테스트**: 30% (Firestore 연동)
- **E2E 테스트**: 10% (전체 플로우)
- **총 커버리지**: 80% 이상

## 🎯 테스트 전략

### 테스트 피라미드
```
         /\
        /E2E\      10% - 전체 시나리오
       /______\    
      /  통합  \    30% - Firestore 연동
     /__________\  
    /   단위 테스트 \  60% - 모델 로직
   /________________\
```

### 테스트 범위
1. **모델 생성 및 초기화**
2. **필드 접근 및 기본값**
3. **JSON 직렬화/역직렬화**
4. **Firestore 변환 함수**
5. **헬퍼 메서드 로직**
6. **Equality 및 Hash 구현**

## 🧪 단위 테스트 (60%)

### 1. 모델 생성 테스트
```dart
// test/backend/models/user/users_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:versus_space/backend/models/user/users_model.dart';

void main() {
  group('UsersModel', () {
    late FakeFirebaseFirestore firestore;
    
    setUp(() {
      firestore = FakeFirebaseFirestore();
    });
    
    group('생성자 테스트', () {
      test('빈 데이터로 생성 시 기본값 반환', () {
        // Arrange
        final emptyData = <String, dynamic>{};
        final ref = firestore.collection('users').doc('test');
        
        // Act
        final user = UsersModel.getDocumentFromData(
          emptyData,
          ref,
        );
        
        // Assert
        expect(user.uid, equals(''));
        expect(user.email, equals(''));
        expect(user.displayName, equals(''));
        expect(user.pointsA, equals(0));
        expect(user.pointsQ, equals(0));
        expect(user.interests, isEmpty);
        expect(user.isPremiumUser, isFalse);
      });
      
      test('완전한 데이터로 생성', () {
        // Arrange
        final completeData = {
          'uid': 'user123',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'pointsA': 100,
          'pointsQ': 50,
          'interests': ['tech', 'sports'],
          'isPremiumUser': true,
          'createdTime': DateTime(2024, 1, 1),
        };
        final ref = firestore.collection('users').doc('test');
        
        // Act
        final user = UsersModel.getDocumentFromData(
          completeData,
          ref,
        );
        
        // Assert
        expect(user.uid, equals('user123'));
        expect(user.email, equals('test@example.com'));
        expect(user.displayName, equals('Test User'));
        expect(user.pointsA, equals(100));
        expect(user.pointsQ, equals(50));
        expect(user.interests, equals(['tech', 'sports']));
        expect(user.isPremiumUser, isTrue);
      });
    });
    
    group('has 메서드 테스트', () {
      test('null 필드에 대해 false 반환', () {
        // Arrange
        final data = {'uid': 'user123'};
        final ref = firestore.collection('users').doc('test');
        final user = UsersModel.getDocumentFromData(data, ref);
        
        // Assert
        expect(user.hasUid(), isTrue);
        expect(user.hasEmail(), isFalse);
        expect(user.hasPhotoUrl(), isFalse);
        expect(user.hasDateOfBirth(), isFalse);
      });
    });
    
    group('Backward Compatibility', () {
      test('Deprecated 필드 접근 가능', () {
        // Arrange
        final data = {
          'isPremiumUser': true,
          'friends': ['friend1', 'friend2'],
        };
        final ref = firestore.collection('users').doc('test');
        final user = UsersModel.getDocumentFromData(data, ref);
        
        // Act & Assert (deprecated 필드도 작동해야 함)
        // ignore: deprecated_member_use_from_same_package
        expect(user.isPrmiumUser, equals(user.isPremiumUser));
        // ignore: deprecated_member_use_from_same_package
        expect(user.frinds, equals(user.friends));
      });
    });
  });
}
```

### 2. PostsModel 테스트
```dart
// test/backend/models/post/posts_model_test.dart
void main() {
  group('PostsModel', () {
    group('투표 시스템', () {
      test('투표 시간 계산', () {
        // Arrange
        final now = DateTime.now();
        final data = {
          'voteStartTime': now,
          'voteEndTime': now.add(Duration(minutes: 10)),
          'voteStatus': 'active',
          'votesA': 5,
          'votesB': 3,
        };
        final ref = firestore.collection('posts').doc('test');
        final post = PostsModel.getDocumentFromData(data, ref);
        
        // Assert
        expect(post.voteStartTime, equals(now));
        expect(post.voteEndTime!.difference(now).inMinutes, equals(10));
        expect(post.voteStatus, equals('active'));
        expect(post.votesA, equals(5));
        expect(post.votesB, equals(3));
        expect(post.totalVotes, equals(8));
      });
      
      test('투표 완료 상태', () {
        // Arrange
        final data = {
          'voteStatus': 'completed',
          'voteCompleted': true,
          'votesA': 10,
          'votesB': 15,
        };
        final ref = firestore.collection('posts').doc('test');
        final post = PostsModel.getDocumentFromData(data, ref);
        
        // Assert
        expect(post.voteCompleted, isTrue);
        expect(post.voteStatus, equals('completed'));
        
        // 퍼센트 계산 (수동으로 해야 함)
        final total = post.votesA + post.votesB;
        final percentA = (post.votesA / total * 100).round();
        final percentB = (post.votesB / total * 100).round();
        
        expect(percentA, equals(40));
        expect(percentB, equals(60));
      });
    });
    
    group('중첩 Map 필드', () {
      test('optionA/B Map 파싱', () {
        // Arrange
        final data = {
          'optionA': {
            'text': 'Option A Text',
            'images': ['image1.jpg', 'image2.jpg'],
            'aspectRatio': 1.5,
          },
          'optionB': {
            'text': 'Option B Text',
            'images': ['image3.jpg'],
            'aspectRatio': 0.75,
          },
        };
        final ref = firestore.collection('posts').doc('test');
        final post = PostsModel.getDocumentFromData(data, ref);
        
        // Assert
        expect(post.optionA['text'], equals('Option A Text'));
        expect(post.optionA['images'], hasLength(2));
        expect(post.optionA['aspectRatio'], equals(1.5));
        
        expect(post.optionB['text'], equals('Option B Text'));
        expect(post.optionB['images'], hasLength(1));
        expect(post.optionB['aspectRatio'], equals(0.75));
      });
    });
  });
}
```

### 3. MessagesModel 직렬화 테스트
```dart
// test/backend/models/chat/messages_model_test.dart
void main() {
  group('MessagesModel JSON 직렬화', () {
    test('toJson/fromJson 왕복 변환', () {
      // Arrange
      final originalData = {
        'messageId': 'msg123',
        'senderId': 'user456',
        'content': 'Hello World',
        'timeStamp': DateTime(2024, 1, 1, 12, 0),
        'isRead': true,
        'messageType': 'text',
      };
      final ref = firestore.collection('chats')
          .doc('chat1')
          .collection('messages')
          .doc('msg123');
      
      // Act
      final message = MessagesModel.getDocumentFromData(
        originalData,
        ref,
      );
      final json = message.toJson();
      final restored = MessagesModel.fromJson(json);
      
      // Assert
      expect(restored.messageId, equals(message.messageId));
      expect(restored.senderId, equals(message.senderId));
      expect(restored.content, equals(message.content));
      expect(restored.isRead, equals(message.isRead));
      expect(restored.messageType, equals(message.messageType));
    });
    
    test('DateTime 파싱 - 다양한 형식', () {
      // Arrange & Act & Assert
      
      // 1. int (milliseconds)
      final json1 = {'timeStamp': 1704106800000};
      final msg1 = MessagesModel.fromJson(json1);
      expect(msg1.timeStamp, isNotNull);
      expect(msg1.timeStamp!.year, equals(2024));
      
      // 2. String (ISO 8601)
      final json2 = {'timeStamp': '2024-01-01T12:00:00.000'};
      final msg2 = MessagesModel.fromJson(json2);
      expect(msg2.timeStamp, isNotNull);
      
      // 3. null
      final json3 = {'timeStamp': null};
      final msg3 = MessagesModel.fromJson(json3);
      expect(msg3.timeStamp, isNull);
    });
    
    test('투표 카드 userVotes 헬퍼 메서드', () {
      // Arrange
      final data = {
        'messageType': 'vote_card',
        'userVotes': {
          'user1': {
            'option': 'A',
            'votedAt': DateTime(2024, 1, 1, 10, 0),
          },
          'user2': {
            'option': 'B',
            'votedAt': DateTime(2024, 1, 1, 11, 0),
          },
        },
      };
      final ref = firestore.collection('chats')
          .doc('chat1')
          .collection('messages')
          .doc('msg123');
      final message = MessagesModel.getDocumentFromData(data, ref);
      
      // Act & Assert
      expect(message.checkUserVoted('user1'), isTrue);
      expect(message.checkUserVoted('user3'), isFalse);
      
      expect(message.getUserVoteChoice('user1'), equals('A'));
      expect(message.getUserVoteChoice('user2'), equals('B'));
      expect(message.getUserVoteChoice('user3'), isNull);
      
      expect(message.getUserVoteTime('user1'), isNotNull);
      expect(message.getUserVoteTime('user3'), isNull);
    });
  });
}
```

## 🔗 통합 테스트 (30%)

### 1. Firestore 연동 테스트
```dart
// test/backend/models/integration/firestore_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../test_helpers/firebase_test_helper.dart';

void main() {
  setUpAll(() async {
    await Firebase.initializeApp(
      options: FirebaseTestHelper.testOptions,
    );
    FirebaseFirestore.instance.useFirestoreEmulator(
      'localhost',
      8080,
    );
  });
  
  group('Firestore 모델 통합 테스트', () {
    late FirebaseFirestore firestore;
    
    setUp(() async {
      firestore = FirebaseFirestore.instance;
      // 테스트 데이터 정리
      await FirebaseTestHelper.clearFirestore();
    });
    
    test('사용자 생성 및 조회', () async {
      // Arrange
      final userData = createUsersModelData(
        uid: 'test123',
        email: 'test@example.com',
        displayName: 'Test User',
        pointsA: 100,
        pointsQ: 50,
        createdTime: DateTime.now(),
      );
      
      // Act - 생성
      final docRef = await firestore
          .collection('users')
          .add(userData);
      
      // Act - 조회
      final doc = await docRef.get();
      final user = UsersModel.fromSnapshot(doc);
      
      // Assert
      expect(user.uid, equals('test123'));
      expect(user.email, equals('test@example.com'));
      expect(user.displayName, equals('Test User'));
      expect(user.pointsA, equals(100));
      expect(user.pointsQ, equals(50));
    });
    
    test('게시물과 투표 생성', () async {
      // Arrange
      final postData = createPostsModelData(
        userid: 'user123',
        questionTitle: 'Test Question',
        description: 'Test Description',
        optionA: {
          'text': 'Option A',
          'images': ['img1.jpg'],
        },
        optionB: {
          'text': 'Option B',
          'images': ['img2.jpg'],
        },
        voteStartTime: DateTime.now(),
        voteEndTime: DateTime.now().add(Duration(minutes: 10)),
        voteStatus: 'active',
        votesA: 0,
        votesB: 0,
        createdAt: DateTime.now(),
      );
      
      // Act
      final docRef = await firestore
          .collection('posts')
          .add(postData);
      
      // 투표 서브컬렉션 생성
      await docRef.collection('votes').add({
        'userId': 'voter1',
        'option': 'A',
        'votedAt': FieldValue.serverTimestamp(),
      });
      
      // Assert
      final post = await PostsModel.getDocumentOnce(docRef);
      expect(post.questionTitle, equals('Test Question'));
      expect(post.voteStatus, equals('active'));
      
      final votes = await docRef.collection('votes').get();
      expect(votes.docs, hasLength(1));
    });
    
    test('메시지 스트림 테스트', () async {
      // Arrange
      final chatRef = firestore
          .collection('chats')
          .doc('chat1');
      await chatRef.set({
        'participants': ['user1', 'user2'],
        'lastMessageAt': DateTime.now(),
      });
      
      final messagesCol = chatRef.collection('messages');
      
      // Act - 스트림 구독
      final stream = messagesCol
          .orderBy('timeStamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => MessagesModel.fromSnapshot(doc))
              .toList());
      
      // 메시지 추가
      await messagesCol.add(createMessagesModelData(
        messageId: 'msg1',
        senderId: 'user1',
        content: 'Hello',
        timeStamp: DateTime.now(),
      ));
      
      await messagesCol.add(createMessagesModelData(
        messageId: 'msg2',
        senderId: 'user2',
        content: 'Hi there',
        timeStamp: DateTime.now(),
      ));
      
      // Assert
      await expectLater(
        stream,
        emitsInOrder([
          predicate<List<MessagesModel>>((messages) => messages.isEmpty),
          predicate<List<MessagesModel>>((messages) => messages.length == 1),
          predicate<List<MessagesModel>>((messages) => messages.length == 2),
        ]),
      );
    });
  });
}
```

### 2. 트랜잭션 테스트
```dart
// test/backend/models/integration/transaction_test.dart
void main() {
  group('Firestore 트랜잭션 테스트', () {
    test('포인트 업데이트 트랜잭션', () async {
      // Arrange
      final userRef = firestore.collection('users').doc('user1');
      await userRef.set({
        'uid': 'user1',
        'pointsA': 100,
        'pointsQ': 50,
      });
      
      // Act - 트랜잭션으로 포인트 증가
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        final currentPointsA = snapshot.data()?['pointsA'] ?? 0;
        
        transaction.update(userRef, {
          'pointsA': currentPointsA + 10,
        });
      });
      
      // Assert
      final updated = await UsersModel.getDocumentOnce(userRef);
      expect(updated.pointsA, equals(110));
      expect(updated.pointsQ, equals(50));
    });
    
    test('투표 카운트 동시성 테스트', () async {
      // Arrange
      final postRef = firestore.collection('posts').doc('post1');
      await postRef.set({
        'votesA': 0,
        'votesB': 0,
      });
      
      // Act - 동시에 여러 투표 실행
      final futures = List.generate(10, (index) async {
        await firestore.runTransaction((transaction) async {
          final snapshot = await transaction.get(postRef);
          final currentVotesA = snapshot.data()?['votesA'] ?? 0;
          
          transaction.update(postRef, {
            'votesA': currentVotesA + 1,
          });
        });
      });
      
      await Future.wait(futures);
      
      // Assert
      final updated = await PostsModel.getDocumentOnce(postRef);
      expect(updated.votesA, equals(10));
    });
  });
}
```

## 🚀 E2E 테스트 (10%)

### 전체 플로우 테스트
```dart
// test/backend/models/e2e/user_journey_test.dart
void main() {
  group('사용자 여정 E2E 테스트', () {
    test('회원가입 → 게시물 작성 → 투표 → 결과', () async {
      // 1. 사용자 생성
      final userData = createUsersModelData(
        uid: 'newuser',
        email: 'new@example.com',
        displayName: 'New User',
        createdTime: DateTime.now(),
      );
      
      final userRef = await firestore
          .collection('users')
          .add(userData);
      final user = await UsersModel.getDocumentOnce(userRef);
      
      expect(user.uid, equals('newuser'));
      
      // 2. 게시물 작성
      final postData = createPostsModelData(
        userid: user.uid,
        questionTitle: 'Which is better?',
        optionA: {'text': 'Coffee'},
        optionB: {'text': 'Tea'},
        voteStartTime: DateTime.now(),
        voteEndTime: DateTime.now().add(Duration(minutes: 10)),
        createdAt: DateTime.now(),
      );
      
      final postRef = await firestore
          .collection('posts')
          .add(postData);
      final post = await PostsModel.getDocumentOnce(postRef);
      
      expect(post.userid, equals(user.uid));
      
      // 3. 다른 사용자들이 투표
      final voters = ['voter1', 'voter2', 'voter3'];
      for (final voterId in voters) {
        await postRef.collection('votes').add({
          'userId': voterId,
          'option': voterId == 'voter1' ? 'A' : 'B',
          'votedAt': FieldValue.serverTimestamp(),
        });
        
        // 카운트 업데이트
        await firestore.runTransaction((transaction) async {
          final snapshot = await transaction.get(postRef);
          final data = snapshot.data()!;
          
          if (voterId == 'voter1') {
            transaction.update(postRef, {
              'votesA': (data['votesA'] ?? 0) + 1,
            });
          } else {
            transaction.update(postRef, {
              'votesB': (data['votesB'] ?? 0) + 1,
            });
          }
        });
      }
      
      // 4. 투표 결과 확인
      final finalPost = await PostsModel.getDocumentOnce(postRef);
      expect(finalPost.votesA, equals(1));
      expect(finalPost.votesB, equals(2));
      
      // 5. 사용자 포인트 업데이트
      await userRef.update({
        'pointsQ': FieldValue.increment(10), // 질문 포인트
      });
      
      final updatedUser = await UsersModel.getDocumentOnce(userRef);
      expect(updatedUser.pointsQ, equals(10));
    });
  });
}
```

## 🛠️ 테스트 유틸리티

### Mock 생성기
```dart
// test/backend/models/mocks/model_mocks.dart
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockUsersModel {
  static UsersModel create({
    String? uid,
    String? email,
    String? displayName,
    int? pointsA,
    int? pointsQ,
    List<String>? interests,
  }) {
    final data = {
      'uid': uid ?? 'test_user',
      'email': email ?? 'test@example.com',
      'displayName': displayName ?? 'Test User',
      'pointsA': pointsA ?? 0,
      'pointsQ': pointsQ ?? 0,
      'interests': interests ?? [],
    };
    
    final mockRef = MockDocumentReference();
    when(mockRef.id).thenReturn('test_doc');
    when(mockRef.path).thenReturn('users/test_doc');
    
    return UsersModel.getDocumentFromData(data, mockRef);
  }
}

class MockPostsModel {
  static PostsModel create({
    String? userid,
    String? questionTitle,
    Map<String, dynamic>? optionA,
    Map<String, dynamic>? optionB,
    String? voteStatus,
    int? votesA,
    int? votesB,
  }) {
    final data = {
      'userid': userid ?? 'test_user',
      'questionTitle': questionTitle ?? 'Test Question',
      'optionA': optionA ?? {'text': 'Option A'},
      'optionB': optionB ?? {'text': 'Option B'},
      'voteStatus': voteStatus ?? 'pending',
      'votesA': votesA ?? 0,
      'votesB': votesB ?? 0,
    };
    
    final mockRef = MockDocumentReference();
    when(mockRef.id).thenReturn('test_post');
    when(mockRef.path).thenReturn('posts/test_post');
    
    return PostsModel.getDocumentFromData(data, mockRef);
  }
}

class MockDocumentReference extends Mock implements DocumentReference {}
```

### 테스트 헬퍼
```dart
// test/backend/models/helpers/test_helper.dart
class ModelTestHelper {
  static Future<void> setupFirestoreEmulator() async {
    const host = 'localhost';
    const port = 8080;
    
    FirebaseFirestore.instance.useFirestoreEmulator(host, port);
    
    // 설정 확인
    FirebaseFirestore.instance.settings = Settings(
      persistenceEnabled: false,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }
  
  static Future<void> clearCollection(String collection) async {
    final batch = FirebaseFirestore.instance.batch();
    final snapshots = await FirebaseFirestore.instance
        .collection(collection)
        .get();
        
    for (final doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }
  
  static Future<void> seedTestData() async {
    // 테스트 사용자 생성
    final users = ['user1', 'user2', 'user3'];
    for (final userId in users) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set({
        'uid': userId,
        'email': '$userId@test.com',
        'displayName': 'Test $userId',
        'pointsA': 100,
        'pointsQ': 50,
        'createdTime': DateTime.now(),
      });
    }
    
    // 테스트 게시물 생성
    for (int i = 1; i <= 5; i++) {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc('post$i')
          .set({
        'userid': 'user1',
        'questionTitle': 'Question $i',
        'optionA': {'text': 'Option A-$i'},
        'optionB': {'text': 'Option B-$i'},
        'votesA': i * 10,
        'votesB': i * 5,
        'createdAt': DateTime.now(),
      });
    }
  }
}
```

## 📊 커버리지 측정

### 실행 스크립트
```bash
# test/run_model_tests.sh
#!/bin/bash

# Firebase Emulator 시작
firebase emulators:start --only firestore &
EMULATOR_PID=$!

# 테스트 실행 대기
sleep 5

# 커버리지 수집과 함께 테스트 실행
flutter test \
  --coverage \
  test/backend/models/

# 커버리지 리포트 생성
genhtml coverage/lcov.info \
  -o coverage/html \
  --title "Backend Models Coverage"

# 커버리지 요약
lcov --summary coverage/lcov.info

# Emulator 종료
kill $EMULATOR_PID
```

### GitHub Actions CI
```yaml
# .github/workflows/model_tests.yml
name: Model Tests

on:
  pull_request:
    paths:
      - 'lib/backend/models/**'
      - 'test/backend/models/**'

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Setup Firebase Emulator
        run: |
          npm install -g firebase-tools
          firebase setup:emulators:firestore
      
      - name: Run tests
        run: |
          firebase emulators:exec \
            --only firestore \
            "flutter test --coverage test/backend/models/"
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
          flags: models
          name: model-coverage
```

## 📈 성공 지표

### 커버리지 목표
| 카테고리 | 현재 | 목표 | 달성 기준 |
|---------|------|------|-----------|
| Line Coverage | 0% | 80% | 모든 주요 로직 |
| Branch Coverage | 0% | 70% | 조건문 및 null 체크 |
| Function Coverage | 0% | 90% | 모든 public 메서드 |

### 테스트 품질
- **테스트 실행 시간**: < 30초
- **Flaky 테스트**: 0개
- **Mock 사용률**: 60% (통합 테스트 제외)
- **Assertion 밀도**: 테스트당 3개 이상

### 유지보수성
- **테스트 코드 중복**: < 10%
- **헬퍼 함수 활용**: 70% 이상
- **테스트 가독성**: AAA 패턴 준수

---

*이 테스트 전략은 안정적이고 유지보수 가능한 모델 레이어를 보장합니다.*