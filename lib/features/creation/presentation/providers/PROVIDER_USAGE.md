# Posts Feature Provider 사용 가이드

## 개요
Phase 4에서 구현한 Clean Architecture 기반 Provider 시스템 사용법입니다.

## 초기화

### 앱 시작 시 초기화
```dart
// main.dart 또는 앱 초기화 코드에서
import 'package:your_app/features/posts/presentation/providers/provider_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Posts feature 의존성 초기화
  await PostsProviderConfig.initialize();

  runApp(MyApp());
}
```

## CreatePostProviderV2 사용

### 위젯에서 사용
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/create_post_provider_v2.dart';
import '../providers/provider_config.dart';

class CreatePostScreenV2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PostsProviderConfig.createProvider<CreatePostProviderV2>(),
      child: Consumer<CreatePostProviderV2>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(title: Text('새 질문 만들기')),
            body: _buildForm(context, provider),
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, CreatePostProviderV2 provider) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // 제목 입력
          TextField(
            onChanged: provider.updateTitle,
            decoration: InputDecoration(
              labelText: '제목',
              errorText: provider.errorMessage,
            ),
          ),

          // 설명 입력
          TextField(
            onChanged: provider.updateDescription,
            decoration: InputDecoration(labelText: '설명'),
            maxLines: 3,
          ),

          // A 옵션
          TextField(
            onChanged: provider.updateTextA,
            decoration: InputDecoration(labelText: 'A 옵션'),
          ),

          // B 옵션 (단일 모드가 아닐 때만)
          if (!provider.formData.isSingleMode)
            TextField(
              onChanged: provider.updateTextB,
              decoration: InputDecoration(labelText: 'B 옵션'),
            ),

          // 단일 모드 토글
          SwitchListTile(
            title: Text('단일 옵션 모드'),
            value: provider.formData.isSingleMode,
            onChanged: (_) => provider.toggleSingleMode(),
          ),

          // 익명 게시 토글
          SwitchListTile(
            title: Text('익명으로 게시'),
            value: provider.formData.isAnonymous,
            onChanged: (_) => provider.toggleAnonymous(),
          ),

          // 로딩 인디케이터
          if (provider.isLoading)
            CircularProgressIndicator(value: provider.uploadProgress),

          // 게시 버튼
          ElevatedButton(
            onPressed: provider.canSubmit
                ? () async {
                    final userId = 'current_user_id'; // Get from auth
                    await provider.createPost(userId);

                    if (provider.createdPost != null) {
                      // Navigate to success or feed
                      Navigator.pop(context);
                    }
                  }
                : null,
            child: Text('게시하기'),
          ),

          // 에러 메시지
          if (provider.errorMessage != null)
            Text(
              provider.errorMessage!,
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}
```

## FeedProvider 사용

### 피드 화면에서 사용
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feed_provider.dart';
import '../providers/provider_config.dart';

class FeedScreenV2 extends StatefulWidget {
  @override
  _FeedScreenV2State createState() => _FeedScreenV2State();
}

class _FeedScreenV2State extends State<FeedScreenV2> {
  late FeedProvider feedProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    feedProvider = PostsProviderConfig.createProvider<FeedProvider>();

    // 초기 피드 로드
    feedProvider.initializeFeed();

    // 실시간 업데이트 시작
    feedProvider.startFeedStream();

    // 무한 스크롤 설정
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      feedProvider.loadMore();
    }
  }

  @override
  void dispose() {
    feedProvider.stopFeedStream();
    feedProvider.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: feedProvider,
      child: Consumer<FeedProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text('피드'),
              actions: [
                // 정렬 메뉴
                PopupMenuButton<FeedSortBy>(
                  onSelected: provider.changeSortOrder,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: FeedSortBy.latest,
                      child: Text('최신순'),
                    ),
                    PopupMenuItem(
                      value: FeedSortBy.popular,
                      child: Text('인기순'),
                    ),
                    PopupMenuItem(
                      value: FeedSortBy.mostVoted,
                      child: Text('투표 많은 순'),
                    ),
                    PopupMenuItem(
                      value: FeedSortBy.trending,
                      child: Text('트렌딩'),
                    ),
                  ],
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: provider.refresh,
              child: _buildFeedContent(provider),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeedContent(FeedProvider provider) {
    if (provider.isLoading && provider.posts.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (provider.isEmpty) {
      return Center(child: Text('게시물이 없습니다'));
    }

    if (provider.errorMessage != null && provider.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(provider.errorMessage!),
            ElevatedButton(
              onPressed: provider.refresh,
              child: Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: provider.posts.length + (provider.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.posts.length) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final post = provider.posts[index];
        return _buildPostCard(post, provider);
      },
    );
  }

  Widget _buildPostCard(Post post, FeedProvider provider) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Text(post.description),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOption('A', post.optionA),
                _buildOption('B', post.optionB),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('좋아요: ${post.likeCount}'),
                Text('댓글: ${post.commentCount}'),
                Text('투표: ${post.votesA + post.votesB}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String label, PostOption option) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            if (option.text != null) Text(option.text!),
            if (option.imageUrls.isNotEmpty)
              Icon(Icons.image, size: 32, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
```

## 주요 특징

### 1. Clean Architecture 준수
- UseCase를 통한 비즈니스 로직 캡슐화
- Repository 패턴으로 데이터 접근 추상화
- Provider는 순수 상태 관리만 담당

### 2. 테스트 가능성
```dart
// 테스트 예시
test('CreatePostProviderV2 validates form correctly', () {
  final mockCreateUseCase = MockCreatePostUseCase();
  final mockModerateUseCase = MockModerateContentUseCase();

  final provider = CreatePostProviderV2(
    createPostUseCase: mockCreateUseCase,
    moderateContentUseCase: mockModerateUseCase,
  );

  provider.updateTitle('Test Title');
  expect(provider.formData.title, 'Test Title');
  expect(provider.canSubmit, isFalse); // 다른 필드가 비어있음
});
```

### 3. 점진적 마이그레이션
- 기존 Provider와 병행 사용 가능 (V2 접미사)
- PostModelAdapter로 레거시 모델과 호환
- 기존 UI 코드 점진적 업데이트 가능

## 마이그레이션 전략

### 단계별 접근
1. **Phase 4 (현재)**: Provider V2 생성
2. **Phase 5**: UI 위젯을 V2 Provider로 전환
3. **Phase 6**: 레거시 Provider 제거
4. **Phase 7**: V2 접미사 제거 및 정리

### 병행 운영
```dart
// 기존 Provider와 새 Provider 동시 사용
class TransitionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 레거시 Provider
    final legacyProvider = context.watch<CreatePostProvider>();

    // Clean Architecture Provider
    final cleanProvider = context.watch<CreatePostProviderV2>();

    // 점진적으로 cleanProvider로 이동
    return Container();
  }
}
```

## 다음 단계

1. **UI 컴포넌트 리팩토링**: InPutPostImageWidget 분해
2. **테스트 작성**: Provider 단위 테스트
3. **통합 테스트**: 전체 플로우 테스트
4. **성능 최적화**: 불필요한 rebuild 최소화