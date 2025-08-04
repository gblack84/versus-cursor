# Actions

Versus Space 앱의 비즈니스 로직 액션들을 관리하는 디렉토리입니다.

## 📋 개요

Actions는 UI와 비즈니스 로직을 분리하여 재사용 가능한 기능 단위로 구성된 함수들입니다. 주로 FlutterFlow에서 시작되었지만, 네이티브 Flutter에서도 동일한 패턴을 유지합니다.

## 주요 액션 카테고리

### 1. 인증 관련 액션

**로그아웃**
```dart
Future<void> logoutAction(BuildContext context) async {
  try {
    // 로그아웃 확인 다이얼로그
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('로그아웃'),
        content: Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('로그아웃'),
          ),
        ],
      ),
    );
    
    if (shouldLogout == true) {
      // Firebase 로그아웃
      await FirebaseAuth.instance.signOut();
      
      // 로컬 데이터 정리
      await clearLocalData();
      
      // 시작 페이지로 이동
      context.goNamed('StartPage');
    }
  } catch (e) {
    showSnackbar(context, '로그아웃 중 오류가 발생했습니다');
  }
}
```

**계정 삭제**
```dart
Future<void> deleteAccountAction(BuildContext context) async {
  try {
    // 재인증 요구
    final password = await showPasswordDialog(context);
    if (password == null) return;
    
    final user = FirebaseAuth.instance.currentUser!;
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    
    await user.reauthenticateWithCredential(credential);
    
    // 사용자 데이터 삭제
    await deleteUserData(user.uid);
    
    // 계정 삭제
    await user.delete();
    
    // 시작 페이지로 이동
    context.goNamed('StartPage');
  } catch (e) {
    handleDeleteAccountError(e);
  }
}
```

### 2. 데이터 처리 액션

**이미지 업로드**
```dart
Future<String?> uploadImageAction({
  required BuildContext context,
  required File imageFile,
  String? path,
}) async {
  try {
    showLoadingDialog(context);
    
    // 이미지 압축
    final compressedImage = await compressImage(imageFile);
    
    // Firebase Storage 업로드
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storagePath = path ?? 'uploads/images/$fileName';
    
    final ref = FirebaseStorage.instance.ref(storagePath);
    final uploadTask = ref.putFile(compressedImage);
    
    // 진행률 모니터링
    uploadTask.snapshotEvents.listen((snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      updateLoadingProgress(progress);
    });
    
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    
    Navigator.pop(context); // 로딩 다이얼로그 닫기
    return downloadUrl;
    
  } catch (e) {
    Navigator.pop(context);
    showSnackbar(context, '이미지 업로드에 실패했습니다');
    return null;
  }
}
```

**게시물 생성**
```dart
Future<void> createPostAction({
  required BuildContext context,
  required String questionTitle,
  required Map<String, dynamic> optionA,
  required Map<String, dynamic> optionB,
  Map<String, dynamic>? targetAudience,
}) async {
  try {
    // 유효성 검사
    if (!validatePostData(questionTitle, optionA, optionB)) {
      showSnackbar(context, '필수 정보를 모두 입력해주세요');
      return;
    }
    
    showLoadingDialog(context);
    
    // 콘텐츠 검열
    final moderationResult = await moderateContent(
      questionTitle: questionTitle,
      optionA: optionA,
      optionB: optionB,
    );
    
    if (!moderationResult.isValid) {
      Navigator.pop(context);
      showModerationErrorDialog(context, moderationResult);
      return;
    }
    
    // Firestore에 저장
    final postData = {
      'userid': currentUserUid,
      'questionTitle': questionTitle,
      'optionA': optionA,
      'optionB': optionB,
      'targetAudience': targetAudience,
      'created_at': FieldValue.serverTimestamp(),
      'vote_start_time': FieldValue.serverTimestamp(),
      'vote_end_time': DateTime.now().add(Duration(minutes: 10)),
      'vote_status': 'active',
      'votes_a': 0,
      'votes_b': 0,
      'total_votes': 0,
    };
    
    await FirebaseFirestore.instance
      .collection('posts')
      .add(postData);
    
    // 상태 초기화
    AppState().clearPostCreationData();
    
    Navigator.pop(context); // 로딩 닫기
    
    // 홈으로 이동
    context.goNamed('HomePage');
    showSnackbar(context, '게시물이 생성되었습니다');
    
  } catch (e) {
    Navigator.pop(context);
    showSnackbar(context, '게시물 생성에 실패했습니다');
  }
}
```

### 3. 소셜 기능 액션

**친구 추가**
```dart
Future<void> addFriendAction({
  required BuildContext context,
  required String targetUserId,
}) async {
  try {
    final currentUserId = currentUserUid;
    if (currentUserId == targetUserId) {
      showSnackbar(context, '자기 자신은 친구로 추가할 수 없습니다');
      return;
    }
    
    // 이미 친구인지 확인
    final doc = await FirebaseFirestore.instance
      .collection('friends_list')
      .doc('${currentUserId}_$targetUserId')
      .get();
    
    if (doc.exists) {
      showSnackbar(context, '이미 친구입니다');
      return;
    }
    
    // 친구 관계 생성 (양방향)
    final batch = FirebaseFirestore.instance.batch();
    
    // 내가 상대를 친구로
    batch.set(
      FirebaseFirestore.instance
        .collection('friends_list')
        .doc('${currentUserId}_$targetUserId'),
      {
        'user_id': currentUserId,
        'friend_id': targetUserId,
        'created_at': FieldValue.serverTimestamp(),
      },
    );
    
    // 상대가 나를 친구로
    batch.set(
      FirebaseFirestore.instance
        .collection('friends_list')
        .doc('${targetUserId}_$currentUserId'),
      {
        'user_id': targetUserId,
        'friend_id': currentUserId,
        'created_at': FieldValue.serverTimestamp(),
      },
    );
    
    await batch.commit();
    showSnackbar(context, '친구로 추가되었습니다');
    
  } catch (e) {
    showSnackbar(context, '친구 추가에 실패했습니다');
  }
}
```

**투표하기**
```dart
Future<void> voteOnPostAction({
  required BuildContext context,
  required String postId,
  required String choice, // 'A' or 'B'
}) async {
  try {
    final userId = currentUserUid;
    
    // 트랜잭션으로 원자적 업데이트
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final postRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId);
      
      final postDoc = await transaction.get(postRef);
      if (!postDoc.exists) {
        throw Exception('게시물을 찾을 수 없습니다');
      }
      
      final data = postDoc.data()!;
      
      // 중복 투표 확인
      final votedUsersA = List<String>.from(data['voted_user_ids_a'] ?? []);
      final votedUsersB = List<String>.from(data['voted_user_ids_b'] ?? []);
      
      if (votedUsersA.contains(userId) || votedUsersB.contains(userId)) {
        throw Exception('이미 투표했습니다');
      }
      
      // 투표 시간 확인
      final voteEndTime = (data['vote_end_time'] as Timestamp).toDate();
      if (DateTime.now().isAfter(voteEndTime)) {
        throw Exception('투표가 종료되었습니다');
      }
      
      // 투표 업데이트
      if (choice == 'A') {
        transaction.update(postRef, {
          'votes_a': FieldValue.increment(1),
          'voted_user_ids_a': FieldValue.arrayUnion([userId]),
          'total_votes': FieldValue.increment(1),
        });
      } else {
        transaction.update(postRef, {
          'votes_b': FieldValue.increment(1),
          'voted_user_ids_b': FieldValue.arrayUnion([userId]),
          'total_votes': FieldValue.increment(1),
        });
      }
    });
    
    showSnackbar(context, '투표가 완료되었습니다');
    
  } catch (e) {
    showSnackbar(context, e.toString());
  }
}
```

### 4. 네비게이션 액션

**조건부 네비게이션**
```dart
Future<void> conditionalNavigationAction({
  required BuildContext context,
  required bool condition,
  required String trueRoute,
  required String falseRoute,
  Map<String, String>? queryParams,
}) async {
  final targetRoute = condition ? trueRoute : falseRoute;
  
  if (queryParams != null && queryParams.isNotEmpty) {
    context.goNamed(targetRoute, queryParams: queryParams);
  } else {
    context.goNamed(targetRoute);
  }
}
```

### 5. 유틸리티 액션

**클립보드 복사**
```dart
Future<void> copyToClipboardAction({
  required BuildContext context,
  required String text,
  String? successMessage,
}) async {
  await Clipboard.setData(ClipboardData(text: text));
  showSnackbar(
    context, 
    successMessage ?? '클립보드에 복사되었습니다'
  );
}
```

**공유하기**
```dart
Future<void> shareAction({
  required BuildContext context,
  required String text,
  String? subject,
}) async {
  try {
    await Share.share(
      text,
      subject: subject,
    );
  } catch (e) {
    showSnackbar(context, '공유하기에 실패했습니다');
  }
}
```

## 액션 작성 가이드

### 1. 기본 구조
```dart
Future<T?> myAction({
  required BuildContext context,
  // 필수 파라미터
  required String param1,
  // 선택적 파라미터
  String? param2,
}) async {
  try {
    // 유효성 검사
    if (!isValid(param1)) {
      showSnackbar(context, '유효하지 않은 입력입니다');
      return null;
    }
    
    // 로딩 표시 (필요한 경우)
    showLoadingDialog(context);
    
    // 비즈니스 로직
    final result = await performBusinessLogic();
    
    // 로딩 숨기기
    Navigator.pop(context);
    
    // 성공 피드백
    showSnackbar(context, '성공적으로 완료되었습니다');
    
    return result;
    
  } catch (e) {
    // 에러 처리
    Navigator.pop(context); // 로딩 숨기기
    handleError(context, e);
    return null;
  }
}
```

### 2. 에러 처리 패턴
```dart
void handleError(BuildContext context, dynamic error) {
  String message = '작업 중 오류가 발생했습니다';
  
  if (error is FirebaseException) {
    message = getFirebaseErrorMessage(error.code);
  } else if (error is NetworkException) {
    message = '네트워크 연결을 확인해주세요';
  } else if (error is ValidationException) {
    message = error.message;
  }
  
  showSnackbar(context, message);
  
  // 개발 환경에서는 상세 로그
  if (kDebugMode) {
    print('Error in action: $error');
  }
}
```

### 3. 로딩 처리
```dart
// 간단한 로딩
void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: CircularProgressIndicator(),
    ),
  );
}

// 진행률 표시 로딩
void showProgressDialog(
  BuildContext context, 
  Stream<double> progress,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => StreamBuilder<double>(
      stream: progress,
      builder: (context, snapshot) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: snapshot.data ?? 0,
              ),
              SizedBox(height: 16),
              Text('${((snapshot.data ?? 0) * 100).toInt()}%'),
            ],
          ),
        );
      },
    ),
  );
}
```

## 테스트

```dart
// 액션 테스트 예제
testWidgets('createPostAction creates post successfully', (tester) async {
  // Mock 설정
  final mockFirestore = MockFirebaseFirestore();
  
  // 테스트 실행
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => createPostAction(
            context: context,
            questionTitle: 'Test Question',
            optionA: {'title': 'Option A'},
            optionB: {'title': 'Option B'},
          ),
          child: Text('Create Post'),
        ),
      ),
    ),
  );
  
  // 버튼 탭
  await tester.tap(find.text('Create Post'));
  await tester.pumpAndSettle();
  
  // 검증
  verify(mockFirestore.collection('posts').add(any)).called(1);
});
```

## 베스트 프랙티스

1. **단일 책임**: 각 액션은 하나의 명확한 기능만 수행
2. **에러 처리**: 모든 예외 상황을 적절히 처리
3. **사용자 피드백**: 작업 진행 상황을 사용자에게 알림
4. **트랜잭션 사용**: 데이터 일관성이 중요한 경우 트랜잭션 사용
5. **테스트 가능성**: 의존성 주입으로 테스트 용이하게 작성

## 향후 개선 사항

1. **액션 조합**: 여러 액션을 조합한 복합 액션
2. **오프라인 지원**: 네트워크 없이도 작동하는 액션
3. **취소 가능**: 진행 중인 액션 취소 기능
4. **재시도**: 실패한 액션 자동 재시도