# 📱 /lib/features/voting/presentation/screens

> Feature-First Architecture - Voting 화면 계층

## 📋 개요

투표 기능의 **Screen Layer**를 담당하는 디렉토리입니다. 투표 관련 전체 화면을 구성하며, 사용자 인터페이스의 최상위 레벨을 담당합니다.

### 🎯 목적
- **화면 구성**: 투표 관련 전체 페이지 구현
- **네비게이션**: 화면 간 이동 및 라우팅
- **상태 연결**: Provider와 UI 연결
- **레이아웃 관리**: 반응형 레이아웃 구현

## 🏗️ 디렉토리 구조

```
screens/
├── voting_detail/                  # 투표 상세 화면
│   ├── voting_detail_widget.dart
│   └── voting_detail_model.dart
│
├── voting_results/                 # 투표 결과 화면
│   ├── voting_results_widget.dart
│   └── voting_results_model.dart
│
├── rankings/                       # 순위 화면
│   ├── rankings_widget.dart
│   └── rankings_model.dart
│
├── notifications_list/             # 알림 목록 화면
│   ├── notifications_list_widget.dart
│   └── notifications_list_model.dart
│
└── vote_creation/                  # 투표 생성 화면
    ├── vote_creation_widget.dart
    └── vote_creation_model.dart
```

## 📂 주요 화면 구현

### VotingDetailWidget

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/vote_provider.dart';
import '../../widgets/vote_card/vote_card_message.dart';
import '../../domain/models/vote_state_model.dart';
import '../../domain/models/enums/vote_option.dart';
import 'voting_detail_model.dart';

/// 투표 상세 화면
class VotingDetailWidget extends StatefulWidget {
  final String postId;
  final String? postTitle;
  final Map<String, dynamic>? postData;
  
  const VotingDetailWidget({
    Key? key,
    required this.postId,
    this.postTitle,
    this.postData,
  }) : super(key: key);
  
  @override
  State<VotingDetailWidget> createState() => _VotingDetailWidgetState();
}

class _VotingDetailWidgetState extends State<VotingDetailWidget> {
  late VotingDetailModel _model;
  final _unfocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    _model = VotingDetailModel();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeVote();
    });
  }
  
  @override
  void dispose() {
    _model.dispose();
    _unfocusNode.dispose();
    super.dispose();
  }
  
  /// 투표 초기화
  Future<void> _initializeVote() async {
    final voteProvider = context.read<VoteProvider>();
    final currentUser = context.read<AuthProvider>().currentUser;
    
    if (currentUser != null) {
      await voteProvider.initializeVote(
        widget.postId,
        currentUser.uid,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: Theme.of(context).primaryColor,
              size: 30,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            widget.postTitle ?? '투표',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: Consumer<VoteProvider>(
            builder: (context, voteProvider, child) {
              final voteState = voteProvider.getVoteState(widget.postId);
              
              if (voteProvider.isLoading && voteState == null) {
                return _buildLoadingState();
              }
              
              if (voteProvider.errorMessage != null) {
                return _buildErrorState(voteProvider.errorMessage!);
              }
              
              if (voteState == null) {
                return _buildEmptyState();
              }
              
              return _buildVoteContent(voteState, voteProvider);
            },
          ),
        ),
      ),
    );
  }
  
  /// 투표 컨텐츠 빌드
  Widget _buildVoteContent(
    VoteStateModel voteState,
    VoteProvider voteProvider,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 투표 카드
          VoteCardMessage(
            postId: widget.postId,
            postData: widget.postData ?? {},
            voteState: voteState,
            onVote: (option) => _handleVote(option, voteProvider),
            isDetailView: true,
          ),
          
          SizedBox(height: 24),
          
          // 투표 통계
          if (voteState.canShowResults)
            _buildVoteStatistics(voteState),
          
          SizedBox(height: 24),
          
          // 투표 참여자
          if (voteState.totalVotes > 0)
            _buildVotersList(voteState),
        ],
      ),
    );
  }
  
  /// 투표 처리
  Future<void> _handleVote(
    VoteOption option,
    VoteProvider voteProvider,
  ) async {
    final currentUser = context.read<AuthProvider>().currentUser;
    if (currentUser == null) {
      // 로그인 필요
      _showLoginDialog();
      return;
    }
    
    await voteProvider.castVote(
      postId: widget.postId,
      userId: currentUser.uid,
      option: option,
    );
    
    if (voteProvider.errorMessage != null) {
      _showErrorSnackBar(voteProvider.errorMessage!);
    } else {
      _showSuccessSnackBar('투표가 완료되었습니다!');
    }
  }
  
  /// 투표 통계 빌드
  Widget _buildVoteStatistics(VoteStateModel voteState) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Color(0x1A000000),
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '투표 결과',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          
          // A 옵션
          _buildOptionResult(
            'A',
            voteState.votesA,
            voteState.percentageA,
            voteState.userVoteOption == VoteOption.A,
          ),
          
          SizedBox(height: 12),
          
          // B 옵션
          _buildOptionResult(
            'B',
            voteState.votesB,
            voteState.percentageB,
            voteState.userVoteOption == VoteOption.B,
          ),
          
          SizedBox(height: 16),
          
          // 총 투표 수
          Text(
            '총 ${voteState.totalVotes}명 참여',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
  
  /// 옵션 결과 빌드
  Widget _buildOptionResult(
    String option,
    int votes,
    double percentage,
    bool isUserChoice,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUserChoice 
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUserChoice 
              ? Theme.of(context).primaryColor
              : Colors.grey.withOpacity(0.3),
          width: isUserChoice ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: option == 'A' 
                ? Colors.blue 
                : Colors.red,
            child: Text(
              option,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '옵션 $option',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    option == 'A' ? Colors.blue : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '$votes표',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 투표 참여자 목록
  Widget _buildVotersList(VoteStateModel voteState) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '투표 참여자',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 16),
          
          // 참여자 프로필 목록
          // 실제 구현에서는 참여자 정보를 로드
          Text(
            '${voteState.totalVotes}명이 투표에 참여했습니다',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  /// 로딩 상태
  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
  
  /// 에러 상태
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            '오류가 발생했습니다',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _initializeVote,
            child: Text('다시 시도'),
          ),
        ],
      ),
    );
  }
  
  /// 빈 상태
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.how_to_vote_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            '투표 정보를 불러올 수 없습니다',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
  
  /// 로그인 다이얼로그
  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('로그인 필요'),
        content: Text('투표에 참여하려면 로그인이 필요합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/login');
            },
            child: Text('로그인'),
          ),
        ],
      ),
    );
  }
  
  /// 성공 스낵바
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  /// 에러 스낵바
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

### NotificationsListWidget

**역할**: 알림 목록 화면 위젯

**주요 기능**:
- 사용자 알림 목록 표시
- 읽음/안읽음 상태 관리
- 알림별 액션 처리
- 일괄 읽음 처리
- 스와이프로 삭제
- Pull-to-refresh 지원

**의존성**:
- NotificationProvider: 알림 상태 관리
- NotificationBadgeProvider: 뱃지 상태 관리
- AuthProvider: 사용자 인증 정보

**상태 관리**:
- isLoading: 로딩 상태
- errorMessage: 에러 메시지
- notifications: 알림 목록
- unreadCount: 미읽음 개수

**화면 구성**:
- **AppBar**: 제목, 뒤로가기, 모두 읽음 버튼
- **ListView**: 알림 목록 (NotificationListTile 사용)
- **EmptyState**: 알림 없음 상태
- **ErrorState**: 에러 발생 상태
- **LoadingState**: 로딩 중 상태

**알림 액션 처리**:
- voteRequest: 투표 화면으로 이동 (/voting/[postId])
- voteCompleted: 결과 화면으로 이동 (/voting/results/[postId])
- rankingUpdate: 순위 화면으로 이동 (/rankings)
- general: 상세 정보 표시

**제스처 처리**:
- onTap: 알림 읽음 처리 및 액션 실행
- onDismiss: 스와이프로 알림 삭제
- onRefresh: Pull-to-refresh로 목록 새로고침

**생명주기 처리**:
- initState: 알림 초기화 및 뱃지 리셋
- dispose: 스크롤 컨트롤러 정리

## 🎨 화면 디자인 패턴

### 일관된 레이아웃

**BaseScreen 구조**:
- **AppBar**: 일관된 스타일의 상단바
- **SafeArea**: 노치/홈 인디케이터 영역 회피
- **Body**: 메인 콘텐츠 영역
- **Actions**: 화면별 액션 버튼

## 🧪 테스트 전략

### Widget 테스트

**테스트 케이스**:
- Widget 렌더링 테스트
- 상태 변경에 따른 UI 업데이트
- 사용자 인터랙션 테스트
- 네비게이션 플로우 테스트
- 에러 상태 처리 테스트

**Mock 객체**:
- MockVoteProvider
- MockNotificationProvider
- MockAuthProvider

**검증 항목**:
- 위젯이 올바르게 렌더링되는지
- Provider 상태 변경이 UI에 반영되는지
- 버튼 클릭 시 올바른 액션 실행
- 에러 상태가 적절히 표시되는지

## ✅ 체크리스트

### 구현 완료
- [x] VotingDetailWidget - 투표 상세
- [x] NotificationsListWidget - 알림 목록

### 구현 예정
- [ ] VotingResultsWidget - 투표 결과
- [ ] RankingsWidget - 순위 화면
- [ ] VoteCreationWidget - 투표 생성

## 📚 참고 자료

- [Flutter Layout Guide](https://docs.flutter.dev/ui/layout)
- [Navigation and Routing](https://docs.flutter.dev/ui/navigation)
- [Responsive Design](https://docs.flutter.dev/ui/layout/responsive)

---

*이 문서는 Feature-First Architecture의 Voting 기능 화면 가이드입니다.*
*최종 업데이트: 2025-08-24*