# Post Feature - 사용 가이드

> **Version**: 1.0.0
> **Last Updated**: 2025-01-20
> **Clean Architecture**: v4.0

## 목차
- [빠른 시작](#-빠른-시작)
- [기본 사용법](#-기본-사용법)
- [고급 사용법](#-고급-사용법)
- [상태 관리](#-상태-관리)
- [UI 통합](#-ui-통합)
- [성능 최적화](#-성능-최적화)
- [트러블슈팅](#-트러블슈팅)

---

## 🚀 빠른 시작

### 1. 의존성 추가

**pubspec.yaml**
```yaml
dependencies:
  get_it: ^7.6.0
  provider: ^6.1.2
  equatable: ^2.0.5
  cloud_firestore: ^5.5.0
```

### 2. DI 설정

**lib/app/di.dart** (또는 di/posts_module.dart)
```dart
import 'package:get_it/get_it.dart';

// Post Feature DI 등록
void setupPostFeature(GetIt getIt) {
  // DataSource
  getIt.registerLazySingleton<IPostDisplayDataSource>(
    () => FirebasePostDisplayDataSource(),
  );

  // Repository
  getIt.registerLazySingleton<IPostDisplayRepositoryV2>(
    () => PostDisplayRepositoryV2Impl(
      dataSource: getIt<IPostDisplayDataSource>(),
    ),
  );

  // UseCases
  getIt.registerFactory<GetFeedUseCase>(
    () => GetFeedUseCase(
      postRepository: getIt<IPostDisplayRepositoryV2>(),
    ),
  );

  // Providers
  getIt.registerLazySingleton<FeedProvider>(
    () => FeedProvider(
      getFeedUseCase: getIt<GetFeedUseCase>(),
    ),
  );
}
```

### 3. Provider 초기화

**lib/main.dart**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // DI 설정
  await setupDependencyInjection();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<FeedProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<TrendingPostsProvider>()),
        // ... 기타 Provider
      ],
      child: MyApp(),
    ),
  );
}
```

### 4. 첫 번째 Feed 화면

**lib/pages/home_page.dart**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // 피드 초기화
    Future.microtask(
      () => context.read<FeedProvider>().initializeFeed(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feed')),
      body: Consumer<FeedProvider>(
        builder: (context, provider, child) {
          // 로딩 중
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          // 에러 상태
          if (provider.loadingState == FeedLoadingState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.errorMessage ?? '오류 발생'),
                  ElevatedButton(
                    onPressed: () => provider.refresh(),
                    child: Text('재시도'),
                  ),
                ],
              ),
            );
          }

          // 빈 상태
          if (provider.isEmpty) {
            return Center(child: Text('게시물이 없습니다'));
          }

          // 성공 - 게시물 목록 표시
          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              itemCount: provider.posts.length,
              itemBuilder: (context, index) {
                final post = provider.posts[index];
                return PostCard(post: post);
              },
            ),
          );
        },
      ),
    );
  }
}
```

---

## 📋 기본 사용법

### Feed 로딩

#### 초기 로드
```dart
class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    // 방법 1: Future.microtask 사용 (권장)
    Future.microtask(() {
      context.read<FeedProvider>().initializeFeed();
    });

    // 방법 2: WidgetsBinding.instance.addPostFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeedProvider>(context, listen: false).initializeFeed();
    });
  }
}
```

#### Pull-to-Refresh
```dart
RefreshIndicator(
  onRefresh: () async {
    await context.read<FeedProvider>().refresh();
  },
  child: ListView.builder(
    // ...
  ),
);
```

---

### 무한 스크롤 (페이지네이션)

#### ScrollController를 사용한 자동 로딩
```dart
class _HomePageState extends State<HomePage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    context.read<FeedProvider>().initializeFeed();
  }

  void _onScroll() {
    final provider = context.read<FeedProvider>();

    // 스크롤이 80% 도달 시 다음 페이지 로드
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {

      if (provider.hasMore && !provider.isLoadingMore) {
        provider.loadMore();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
      builder: (context, provider, child) {
        return ListView.builder(
          controller: _scrollController,
          itemCount: provider.posts.length + (provider.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            // 마지막 아이템 = 로딩 인디케이터
            if (index == provider.posts.length) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return PostCard(post: provider.posts[index]);
          },
        );
      },
    );
  }
}
```

---

### 게시물 상세 조회

#### 화면 진입 시 로드
```dart
class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({required this.postId});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late PostDetailProvider _provider;

  @override
  void initState() {
    super.initState();

    // Factory Provider 생성
    _provider = getIt<PostDetailProvider>();

    // 게시물 로드
    _provider.loadPost(widget.postId);
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('게시물 상세')),
      body: ChangeNotifierProvider.value(
        value: _provider,
        child: Consumer<PostDetailProvider>(
          builder: (context, provider, child) {
            // 로딩 중
            if (provider.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            // 에러 (Not Found)
            if (provider.loadingState == PostDetailLoadingState.notFound) {
              return Center(child: Text('게시물을 찾을 수 없습니다'));
            }

            // 에러 (일반)
            if (provider.loadingState == PostDetailLoadingState.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(provider.errorMessage ?? '오류 발생'),
                    ElevatedButton(
                      onPressed: () => provider.refresh(widget.postId),
                      child: Text('재시도'),
                    ),
                  ],
                ),
              );
            }

            // 성공
            final post = provider.post;
            if (post == null) {
              return Center(child: Text('게시물이 없습니다'));
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      post.questionTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),

                  // A vs B 옵션
                  VersusOptionsWidget(post: post),

                  // 투표 결과
                  VoteResultWidget(post: post),

                  // 댓글 섹션
                  CommentsWidget(postId: post.id),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
```

---

### 실시간 업데이트 구독

#### 게시물 상세 - 실시간 스트림
```dart
class _PostDetailPageState extends State<PostDetailPage> {
  late PostDetailProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = getIt<PostDetailProvider>();

    // 초기 로드
    _provider.loadPost(widget.postId);

    // 실시간 스트림 시작
    _provider.startPostStream(widget.postId);
  }

  @override
  void dispose() {
    // 스트림 중지
    _provider.stopPostStream();
    _provider.dispose();
    super.dispose();
  }

  // ... build 메서드
}
```

#### Feed - 실시간 스트림
```dart
class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    final provider = context.read<FeedProvider>();

    // 초기 로드
    provider.initializeFeed();

    // 실시간 스트림 시작
    provider.startFeedStream();
  }

  @override
  void dispose() {
    // 스트림 중지
    context.read<FeedProvider>().stopFeedStream();
    super.dispose();
  }
}
```

---

## 🔧 고급 사용법

### 정렬 옵션 변경

```dart
class FeedSortButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
      builder: (context, provider, child) {
        return DropdownButton<FeedSortBy>(
          value: provider.sortBy,
          onChanged: (FeedSortBy? newValue) {
            if (newValue != null) {
              provider.changeSortOrder(newValue);
            }
          },
          items: [
            DropdownMenuItem(
              value: FeedSortBy.latest,
              child: Row(
                children: [
                  Icon(Icons.schedule),
                  SizedBox(width: 8),
                  Text('최신순'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: FeedSortBy.popular,
              child: Row(
                children: [
                  Icon(Icons.favorite),
                  SizedBox(width: 8),
                  Text('인기순'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: FeedSortBy.mostVoted,
              child: Row(
                children: [
                  Icon(Icons.how_to_vote),
                  SizedBox(width: 8),
                  Text('투표 많은 순'),
                ],
              ),
            ),
            DropdownMenuItem(
              value: FeedSortBy.trending,
              child: Row(
                children: [
                  Icon(Icons.trending_up),
                  SizedBox(width: 8),
                  Text('트렌딩'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
```

---

### 필터링 적용

#### FeedFilterModel 생성
```dart
class FilterDialog extends StatefulWidget {
  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  String? _selectedStatus;
  bool? _hasImages;
  bool? _isAnonymous;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('필터 설정'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상태 필터
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: '상태'),
              value: _selectedStatus,
              items: [
                DropdownMenuItem(value: 'published', child: Text('게시됨')),
                DropdownMenuItem(value: 'draft', child: Text('임시저장')),
                DropdownMenuItem(value: 'archived', child: Text('보관됨')),
              ],
              onChanged: (value) => setState(() => _selectedStatus = value),
            ),

            // 이미지 유무
            CheckboxListTile(
              title: Text('이미지 포함'),
              value: _hasImages ?? false,
              tristate: true,
              onChanged: (value) => setState(() => _hasImages = value),
            ),

            // 익명 여부
            CheckboxListTile(
              title: Text('익명 게시물'),
              value: _isAnonymous ?? false,
              tristate: true,
              onChanged: (value) => setState(() => _isAnonymous = value),
            ),

            // 날짜 범위
            ListTile(
              title: Text('시작 날짜'),
              subtitle: Text(
                _startDate?.toString().split(' ')[0] ?? '선택 안 함',
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _startDate = date);
                }
              },
            ),

            ListTile(
              title: Text('종료 날짜'),
              subtitle: Text(
                _endDate?.toString().split(' ')[0] ?? '선택 안 함',
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? DateTime.now(),
                  firstDate: _startDate ?? DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _endDate = date);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소'),
        ),
        TextButton(
          onPressed: () {
            final filter = FeedFilterModel(
              status: _selectedStatus,
              hasImages: _hasImages,
              isAnonymous: _isAnonymous,
              startDate: _startDate,
              endDate: _endDate,
            );

            context.read<FeedProvider>().applyFilter(filter);
            Navigator.pop(context);
          },
          child: Text('적용'),
        ),
      ],
    );
  }
}
```

#### 필터 적용 버튼
```dart
IconButton(
  icon: Icon(Icons.filter_list),
  onPressed: () {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(),
    );
  },
);
```

#### 필터 초기화
```dart
Consumer<FeedProvider>(
  builder: (context, provider, child) {
    if (!provider.filter.hasActiveFilters) {
      return SizedBox.shrink();
    }

    return TextButton.icon(
      icon: Icon(Icons.clear),
      label: Text('필터 초기화'),
      onPressed: () => provider.clearFilters(),
    );
  },
);
```

---

### 커스텀 쿼리 빌더

#### Repository 직접 사용
```dart
class CustomFeedPage extends StatefulWidget {
  @override
  _CustomFeedPageState createState() => _CustomFeedPageState();
}

class _CustomFeedPageState extends State<CustomFeedPage> {
  late IPostDisplayRepositoryV2 _repository;
  List<PostDisplay> _posts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repository = getIt<IPostDisplayRepositoryV2>();
    _loadCustomPosts();
  }

  Future<void> _loadCustomPosts() async {
    setState(() => _isLoading = true);

    try {
      final stream = _repository.queryPosts(
        queryBuilder: (query) => query
          ..where('status', isEqualTo: 'published')
          ..where('likeCount', isGreaterThan: 10)
          ..orderBy('likeCount', descending: true)
          ..orderBy('createdAt', descending: true),
        limit: 50,
      );

      final posts = await stream.first;
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (error) {
      print('Error: $error');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: _posts.length,
      itemBuilder: (context, index) => PostCard(post: _posts[index]),
    );
  }
}
```

---

### 낙관적 UI 업데이트

#### 새 게시물 추가 (Create 후)
```dart
class CreatePostPage extends StatelessWidget {
  Future<void> _createPost(BuildContext context) async {
    final provider = context.read<FeedProvider>();

    // 게시물 생성
    final newPost = await createPostUseCase.execute(...);

    newPost.fold(
      (failure) => showError(failure.message),
      (post) {
        // 낙관적 업데이트: 즉시 피드에 추가
        provider.addPostOptimistically(post);

        // 피드 화면으로 이동
        Navigator.pop(context);
      },
    );
  }

  // ... build 메서드
}
```

#### 게시물 업데이트 (좋아요, 댓글 수)
```dart
class PostCard extends StatelessWidget {
  final PostDisplay post;

  Future<void> _likePost(BuildContext context) async {
    final provider = context.read<FeedProvider>();

    // 낙관적 업데이트: 즉시 UI 변경
    provider.updatePost(
      post.copyWith(likeCount: post.likeCount + 1),
    );

    // 서버 업데이트
    try {
      await likePostUseCase.execute(postId: post.id);
    } catch (error) {
      // 실패 시 롤백
      provider.updatePost(post);
      showError('좋아요 실패');
    }
  }

  // ... build 메서드
}
```

#### 게시물 삭제
```dart
Future<void> _deletePost(BuildContext context, String postId) async {
  final provider = context.read<FeedProvider>();

  // 확인 다이얼로그
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('게시물 삭제'),
      content: Text('정말 삭제하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('삭제'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    // 낙관적 업데이트: 즉시 제거
    provider.removePost(postId);

    // 서버 삭제
    try {
      await deletePostUseCase.execute(postId: postId);
      showSnackBar('게시물이 삭제되었습니다');
    } catch (error) {
      // 실패 시 다시 로드
      await provider.refresh();
      showError('삭제 실패');
    }
  }
}
```

---

### 배치 조회 (여러 게시물 한번에)

```dart
class BookmarkedPostsPage extends StatefulWidget {
  final List<String> bookmarkedPostIds;

  const BookmarkedPostsPage({required this.bookmarkedPostIds});

  @override
  _BookmarkedPostsPageState createState() => _BookmarkedPostsPageState();
}

class _BookmarkedPostsPageState extends State<BookmarkedPostsPage> {
  late IPostDisplayRepositoryV2 _repository;
  List<PostDisplay> _posts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repository = getIt<IPostDisplayRepositoryV2>();
    _loadBookmarkedPosts();
  }

  Future<void> _loadBookmarkedPosts() async {
    setState(() => _isLoading = true);

    try {
      // 배치 조회 (최대 10개씩)
      final posts = await _repository.getPostsByIds(
        widget.bookmarkedPostIds.take(10).toList(),
      );

      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (error) {
      print('Error: $error');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_posts.isEmpty) {
      return Center(child: Text('북마크된 게시물이 없습니다'));
    }

    return ListView.builder(
      itemCount: _posts.length,
      itemBuilder: (context, index) => PostCard(post: _posts[index]),
    );
  }
}
```

---

## 📊 상태 관리

### 로딩 상태 처리

#### FeedLoadingState 활용
```dart
Consumer<FeedProvider>(
  builder: (context, provider, child) {
    switch (provider.loadingState) {
      case FeedLoadingState.initial:
        return Center(child: Text('피드를 로드하려면 새로고침하세요'));

      case FeedLoadingState.loading:
        return Center(child: CircularProgressIndicator());

      case FeedLoadingState.loaded:
        return ListView.builder(
          itemCount: provider.posts.length,
          itemBuilder: (context, index) => PostCard(post: provider.posts[index]),
        );

      case FeedLoadingState.loadingMore:
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: provider.posts.length,
                itemBuilder: (context, index) => PostCard(post: provider.posts[index]),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ],
        );

      case FeedLoadingState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                provider.errorMessage ?? '오류가 발생했습니다',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.refresh(),
                child: Text('재시도'),
              ),
            ],
          ),
        );

      case FeedLoadingState.empty:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('게시물이 없습니다'),
            ],
          ),
        );
    }
  },
);
```

---

### 에러 처리 패턴

#### SnackBar로 에러 표시
```dart
class FeedPageWithErrorHandling extends StatefulWidget {
  @override
  _FeedPageWithErrorHandlingState createState() => _FeedPageWithErrorHandlingState();
}

class _FeedPageWithErrorHandlingState extends State<FeedPageWithErrorHandling> {
  @override
  void initState() {
    super.initState();

    final provider = context.read<FeedProvider>();
    provider.initializeFeed();

    // 에러 리스너 추가
    provider.addListener(_errorListener);
  }

  @override
  void dispose() {
    context.read<FeedProvider>().removeListener(_errorListener);
    super.dispose();
  }

  void _errorListener() {
    final provider = context.read<FeedProvider>();

    if (provider.loadingState == FeedLoadingState.error &&
        provider.errorMessage != null) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: '재시도',
            textColor: Colors.white,
            onPressed: () => provider.refresh(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feed')),
      body: Consumer<FeedProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              itemCount: provider.posts.length,
              itemBuilder: (context, index) => PostCard(post: provider.posts[index]),
            ),
          );
        },
      ),
    );
  }
}
```

---

## 🎨 UI 통합

### Provider와 위젯 연결

#### Consumer 패턴 (권장)
```dart
// ✅ Good: Consumer로 필요한 부분만 리빌드
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Feed'),
      actions: [
        // 정렬 버튼만 리빌드
        Consumer<FeedProvider>(
          builder: (context, provider, child) {
            return IconButton(
              icon: Icon(Icons.sort),
              onPressed: () => _showSortOptions(context),
            );
          },
        ),
      ],
    ),
    body: Consumer<FeedProvider>(
      builder: (context, provider, child) {
        // 피드 목록만 리빌드
        return ListView.builder(
          itemCount: provider.posts.length,
          itemBuilder: (context, index) => PostCard(post: provider.posts[index]),
        );
      },
    ),
  );
}
```

#### Selector 패턴 (최적화)
```dart
// ✅ Better: Selector로 특정 속성 변경 시에만 리빌드
Selector<FeedProvider, List<PostDisplay>>(
  selector: (context, provider) => provider.posts,
  builder: (context, posts, child) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) => PostCard(post: posts[index]),
    );
  },
);
```

---

### 로딩 인디케이터 표시

#### 초기 로딩
```dart
Consumer<FeedProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('게시물을 불러오는 중...'),
          ],
        ),
      );
    }

    // ... 피드 표시
  },
);
```

#### 페이지네이션 로딩
```dart
ListView.builder(
  itemCount: provider.posts.length + (provider.hasMore ? 1 : 0),
  itemBuilder: (context, index) {
    // 마지막 아이템
    if (index == provider.posts.length) {
      if (provider.isLoadingMore) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      return SizedBox.shrink();
    }

    return PostCard(post: provider.posts[index]);
  },
);
```

---

### 에러 위젯

#### 재사용 가능한 에러 위젯
```dart
class ErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const ErrorWidget({
    this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            SizedBox(height: 24),
            Text(
              message ?? '오류가 발생했습니다',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            if (onRetry != null) ...[
              SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.refresh),
                label: Text('재시도'),
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 사용 예
if (provider.loadingState == FeedLoadingState.error) {
  return ErrorWidget(
    message: provider.errorMessage,
    onRetry: () => provider.refresh(),
  );
}
```

---

### 빈 상태 위젯

```dart
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    required this.message,
    this.icon = Icons.inbox,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// 사용 예
if (provider.isEmpty) {
  return EmptyStateWidget(
    message: '아직 게시물이 없습니다',
    icon: Icons.post_add,
    onAction: () => Navigator.pushNamed(context, '/create-post'),
    actionLabel: '첫 게시물 작성하기',
  );
}
```

---

## ⚡ 성능 최적화

### 1. 스트림 구독 관리

#### ✅ Good: dispose에서 해제
```dart
class _PostDetailPageState extends State<PostDetailPage> {
  late PostDetailProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = getIt<PostDetailProvider>();
    _provider.startPostStream(widget.postId);
  }

  @override
  void dispose() {
    _provider.stopPostStream(); // ✅ 스트림 해제
    _provider.dispose();
    super.dispose();
  }
}
```

#### ❌ Bad: 메모리 누수
```dart
@override
void dispose() {
  _provider.dispose(); // ❌ 스트림 해제 누락
  super.dispose();
}
```

---

### 2. 중복 요청 방지

#### ✅ Good: 로딩 중 체크
```dart
Future<void> loadTrendingPosts({int limit = 20}) async {
  if (_loadingState == TrendingLoadingState.loading) return; // ✅ 중복 방지

  setLoadingState(TrendingLoadingState.loading);
  // ...
}
```

#### ❌ Bad: 무조건 요청
```dart
Future<void> loadTrendingPosts({int limit = 20}) async {
  setLoadingState(TrendingLoadingState.loading); // ❌ 중복 요청 가능
  // ...
}
```

---

### 3. Selector 활용 (리빌드 최적화)

#### ✅ Good: Selector로 특정 속성만 감지
```dart
Selector<FeedProvider, int>(
  selector: (context, provider) => provider.posts.length, // ✅ length만 감지
  builder: (context, postsCount, child) {
    return Text('게시물 $postsCount개');
  },
);
```

#### ❌ Bad: Consumer로 전체 감지
```dart
Consumer<FeedProvider>(
  builder: (context, provider, child) {
    return Text('게시물 ${provider.posts.length}개'); // ❌ 모든 변경 감지
  },
);
```

---

### 4. ListView.builder 최적화

#### ✅ Good: itemExtent 지정
```dart
ListView.builder(
  itemCount: provider.posts.length,
  itemExtent: 200.0, // ✅ 고정 높이로 성능 향상
  itemBuilder: (context, index) => PostCard(post: provider.posts[index]),
);
```

#### ✅ Good: const 위젯 활용
```dart
ListView.builder(
  itemCount: provider.posts.length,
  itemBuilder: (context, index) {
    return PostCard(
      key: ValueKey(provider.posts[index].id), // ✅ Key 지정
      post: provider.posts[index],
    );
  },
);
```

---

### 5. 이미지 캐싱

```dart
class PostImage extends StatelessWidget {
  final String imageUrl;

  const PostImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade200,
        child: Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
      memCacheWidth: 800, // ✅ 메모리 캐시 크기 제한
      maxWidthDiskCache: 1200, // ✅ 디스크 캐시 크기 제한
    );
  }
}
```

---

### 6. 페이지네이션 임계값 조정

```dart
void _onScroll() {
  final provider = context.read<FeedProvider>();

  // ✅ 80% 스크롤 시 로드 (부드러운 UX)
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent * 0.8) {

    if (provider.hasMore && !provider.isLoadingMore) {
      provider.loadMore();
    }
  }
}
```

---

## 🔍 트러블슈팅

### 문제 1: 스트림이 업데이트되지 않음

#### 증상
- 실시간 스트림을 시작했지만 UI가 업데이트되지 않음

#### 원인
- `notifyListeners()` 호출 누락
- 스트림 구독이 시작되지 않음

#### 해결 방법
```dart
// ✅ Good: notifyListeners 호출
void _updatePostsFromStream(List<PostDisplay> streamPosts) {
  _posts = streamPosts;
  notifyListeners(); // ✅ UI 업데이트
}

// ✅ Good: 스트림 시작 확인
@override
void initState() {
  super.initState();
  final provider = context.read<FeedProvider>();
  provider.initializeFeed();
  provider.startFeedStream(); // ✅ 스트림 시작
}
```

---

### 문제 2: 메모리 누수 발생

#### 증상
- 앱이 점점 느려짐
- 메모리 사용량이 계속 증가

#### 원인
- StreamSubscription 해제 누락
- Provider dispose 누락

#### 해결 방법
```dart
// ✅ Good: dispose에서 정리
@override
void dispose() {
  _feedStreamSubscription?.cancel(); // ✅ 스트림 해제
  super.dispose();
}

// Factory Provider 사용 시
@override
void dispose() {
  _provider.stopPostStream(); // ✅ 스트림 중지
  _provider.dispose(); // ✅ Provider 정리
  super.dispose();
}
```

---

### 문제 3: 에러 메시지가 표시되지 않음

#### 증상
- 에러가 발생했지만 UI에 표시되지 않음

#### 원인
- `handleError` 사용 누락
- 에러 상태 전환 누락

#### 해결 방법
```dart
// ✅ Good: handleError 사용
result.fold(
  (failure) => handleError(failure, FeedLoadingState.error), // ✅ BaseListProvider 활용
  (posts) => processSuccess(posts),
);

// ✅ Good: UI에서 에러 확인
if (provider.loadingState == FeedLoadingState.error) {
  return ErrorWidget(
    message: provider.errorMessage, // ✅ errorMessage 표시
    onRetry: () => provider.refresh(),
  );
}
```

---

### 문제 4: 페이지네이션이 작동하지 않음

#### 증상
- 스크롤해도 다음 페이지가 로드되지 않음

#### 원인
- `hasMore` 플래그가 false
- ScrollController 리스너 누락
- `loadMore()` 호출 조건 미충족

#### 해결 방법
```dart
// ✅ Good: ScrollController 리스너 등록
@override
void initState() {
  super.initState();
  _scrollController = ScrollController();
  _scrollController.addListener(_onScroll); // ✅ 리스너 등록
}

void _onScroll() {
  final provider = context.read<FeedProvider>();

  // ✅ Good: 조건 확인
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent * 0.8) {

    if (provider.hasMore && !provider.isLoadingMore) { // ✅ 조건 체크
      provider.loadMore();
    }
  }
}

@override
void dispose() {
  _scrollController.removeListener(_onScroll); // ✅ 리스너 해제
  _scrollController.dispose();
  super.dispose();
}
```

---

### 문제 5: Context 에러 (BuildContext 관련)

#### 증상
- `Looking up a deactivated widget's ancestor is unsafe`
- `setState() called after dispose()`

#### 원인
- `context.read()` 사용 시점 문제
- `setState()` 호출 타이밍 문제

#### 해결 방법
```dart
// ✅ Good: initState에서 Future.microtask 사용
@override
void initState() {
  super.initState();
  Future.microtask(() {
    context.read<FeedProvider>().initializeFeed();
  });
}

// ✅ Good: mounted 체크
void _updateUI() {
  if (mounted) {
    setState(() {
      // ...
    });
  }
}

// ✅ Good: Provider 리스너에서 context 체크
void _errorListener() {
  if (!mounted) return;

  final provider = context.read<FeedProvider>();
  // ...
}
```

---

### 문제 6: 필터가 적용되지 않음

#### 증상
- 필터를 설정했지만 게시물이 필터링되지 않음

#### 원인
- `applyFilter()` 호출 누락
- Firestore 인덱스 누락

#### 해결 방법
```dart
// ✅ Good: applyFilter 호출
void _applyFilters() {
  final filter = FeedFilterModel(
    status: 'published',
    hasImages: true,
  );

  context.read<FeedProvider>().applyFilter(filter); // ✅ 필터 적용
}

// ✅ Good: Firestore 인덱스 확인
// Firebase Console → Firestore → Indexes
// 필요한 복합 인덱스 생성:
// - status + createdAt
// - hasImages + createdAt
// - isAnonymous + createdAt
```

---

### 문제 7: Result 타입 에러

#### 증상
- `type 'ResultFailure<dynamic>' is not a subtype of type 'Result<List<PostDisplay>>'`

#### 원인
- ResultFailure 타입 불일치

#### 해결 방법
```dart
// ✅ Good: 타입 명시
return ResultFailure<List<PostDisplay>>(
  AppFailure(message: 'Failed to load posts'),
);

// ❌ Bad: 타입 누락
return ResultFailure(
  AppFailure(message: 'Failed to load posts'),
);
```

---

## 📚 추가 리소스

### 관련 문서
- [Feature Overview](./FEATURE_OVERVIEW.md) - 기능 개요
- [API Reference](./API_REFERENCE.md) - 상세 API 문서
- [Migration Guide](../../docs/migration/POST_FEATURE_MIGRATION.md) - 마이그레이션 가이드

### 외부 리소스
- [Clean Architecture 가이드](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Provider 패턴 문서](https://pub.dev/packages/provider)
- [GetIt DI 가이드](https://pub.dev/packages/get_it)
- [Firebase Firestore 문서](https://firebase.google.com/docs/firestore)

---

**작성자**: Claude Code Assistant
**마지막 업데이트**: 2025-01-20
**Clean Architecture**: v4.0
