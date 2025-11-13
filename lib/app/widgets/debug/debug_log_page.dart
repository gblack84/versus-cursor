import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/services/logging/logger_service.dart';
import 'guard_analytics_tab.dart';

/// **디버그 로그 뷰어 페이지 (개발자 전용)**
///
/// 이 페이지는 Flutter 앱의 모든 로그를 터미널 스타일 UI로 표시하며,
/// **개발 환경에서만 접근 가능**합니다.
///
/// ## Phase 5: Tab-based UI (2개 탭)
///
/// ### Tab 1: App Logs (기존 기능)
/// - 전체 앱 로그 표시
/// - 복사/삭제 기능
///
/// ### Tab 2: Guard Analytics (Phase 5 Day 3 구현 예정)
/// - Route Guard 실행 이벤트
/// - 실시간 통계
///
/// ## 보안 및 접근 제어
///
/// ### 이중 보안 체크
///
/// 1. **Router Level** (`/lib/app/router/navigation/nav.dart`):
///    ```dart
///    GoRoute(
///      path: '/debug/logs',
///      pageBuilder: (context, state) {
///        if (!kDebugMode) {
///          return MaterialPage(child: AccessDeniedScreen());
///        }
///        return MaterialPage(child: DebugLogPage());
///      },
///    )
///    ```
///
/// 2. **Build-Time Optimization**:
///    - `kDebugMode`는 컴파일 타임 상수
///    - Release 빌드 시 Flutter가 자동으로 이 페이지 코드 제거 (Tree Shaking)
///    - 프로덕션 번들 크기에 영향 없음
///
/// ### 접근 방법
///
/// **개발 환경에서**:
/// - Settings 화면에서 타이틀 5번 연속 탭
/// - 직접 URL: `context.push('/debug/logs')`
/// - 브라우저 주소창: `http://localhost:port/#/debug/logs`
///
/// **프로덕션 환경**:
/// - 완전히 접근 불가 (코드 자체가 번들에 포함되지 않음)
/// - Router가 AccessDeniedScreen 반환
///
/// ## 핵심 기능
///
/// ### 1. 전체 로그 보기
///
/// - **데이터 소스**: [Logger.getAllLogs()]
/// - **UI**: [SelectableText] (텍스트 선택 가능)
/// - **스타일**: 터미널 테마 (검은 배경, 녹색 텍스트, monospace 폰트)
/// - **스크롤**: [SingleChildScrollView] (전체 로그 스크롤 가능)
///
/// ### 2. 로그 복사 (2가지 방식)
///
/// #### A. 전체 로그 복사 (AppBar Icon)
/// ```dart
/// IconButton(
///   icon: Icon(Icons.copy),
///   onPressed: () {
///     Clipboard.setData(ClipboardData(text: Logger.getAllLogs()));
///   },
/// )
/// ```
///
/// #### B. 최근 100개 로그만 복사 (FAB)
/// ```dart
/// FloatingActionButton(
///   child: Icon(Icons.content_copy),
///   onPressed: () {
///     Clipboard.setData(ClipboardData(text: Logger.getRecentLogs(100)));
///   },
/// )
/// ```
///
/// **사용 시나리오**:
/// - 전체 복사: 버그 리포트 첨부용
/// - 100개 복사: Slack/Discord에 빠르게 공유
///
/// ### 3. 로그 삭제
///
/// - **API**: [Logger.clearLogs()]
/// - **트리거**: AppBar 휴지통 아이콘
/// - **효과**: 메모리와 Hive 저장소 모두 클리어
/// - **확인**: SnackBar로 삭제 완료 메시지
///
/// ## Logger API 통합
///
/// 이 페이지는 `/lib/core/utils/logger.dart`의 전역 Logger와 통합됩니다:
///
/// ```dart
/// // Logger API 3가지
/// Logger.getAllLogs()       // 전체 로그 반환 (String)
/// Logger.getRecentLogs(100) // 최근 N개 로그만 반환
/// Logger.clearLogs()        // 로그 전체 삭제
/// ```
///
/// Logger는 다음을 수집합니다:
/// - 앱 생명주기 이벤트
/// - 네트워크 요청/응답
/// - 에러 및 예외
/// - 사용자 액션 (버튼 클릭, 페이지 전환)
/// - Firebase 이벤트
///
/// ## UI 스펙
///
/// ### 터미널 스타일 디자인
///
/// ```dart
/// Container(
///   color: Colors.black,  // 검은 배경 (터미널)
///   child: SelectableText(
///     logs,
///     style: TextStyle(
///       fontFamily: 'monospace',  // 고정폭 폰트
///       fontSize: 12,             // 작은 텍스트
///       color: Colors.green,      // 녹색 (Matrix 스타일)
///     ),
///   ),
/// )
/// ```
///
/// ### AppBar 액션
///
/// - **복사 아이콘** (Icons.copy): 전체 로그 클립보드 복사
/// - **삭제 아이콘** (Icons.delete): 로그 전체 삭제
///
/// ### FAB (FloatingActionButton)
///
/// - **아이콘**: Icons.content_copy
/// - **기능**: 최근 100개 로그만 복사 (빠른 공유용)
///
/// ## 사용 예시
///
/// ### 개발 중 버그 디버깅
///
/// 1. Settings → 타이틀 5번 탭 → Debug Logs 진입
/// 2. 로그 확인하여 버그 발생 지점 파악
/// 3. 전체 로그 복사 → GitHub Issue 첨부
///
/// ### 팀원과 로그 공유
///
/// 1. Debug Logs 페이지 진입
/// 2. FAB 버튼으로 최근 100개 복사
/// 3. Slack/Discord에 붙여넣기
///
/// ## Clean Architecture v4.0
///
/// - **레이어**: Presentation (앱 레벨 위젯)
/// - **의존성**: Logger (Core/Utils), GuardAnalyticsService (Services/Analytics)
/// - **상태 관리**: TabController (StatefulWidget)
/// - **라우팅**: GoRouter `/debug/logs`
///
/// ## Phase 5: TabController Integration
///
/// - **Tab 개수**: 2개 (App Logs, Guard Analytics)
/// - **Mixin**: SingleTickerProviderStateMixin
/// - **생명주기**: initState (TabController 생성), dispose (TabController 해제)
///
/// ## 참고
///
/// - [Logger]: 전역 로그 수집 시스템 (`/lib/core/utils/logger.dart`)
/// - [GuardAnalyticsService]: Route Guard 이벤트 추적 (`/lib/services/analytics/guard_analytics_service.dart`)
/// - [kDebugMode]: Flutter 기본 제공 디버그 모드 플래그
/// - Tree Shaking: Release 빌드에서 자동 코드 제거
/// - [Settings Screen]: 5번 탭으로 이 페이지 진입 (개발 환경만)
class DebugLogPage extends StatefulWidget {
  /// [DebugLogPage] 생성자
  ///
  /// 파라미터 없이 생성할 수 있으며, GoRouter가 자동으로 인스턴스화합니다.
  const DebugLogPage({Key? key}) : super(key: key);

  @override
  State<DebugLogPage> createState() => _DebugLogPageState();
}

class _DebugLogPageState extends State<DebugLogPage>
    with SingleTickerProviderStateMixin {
  /// TabController - 2개 탭 (App Logs, Guard Analytics)
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Phase 5: TabController 초기화 (2개 탭)
    _tabController = TabController(length: 2, vsync: this);

    // TabController listener 추가 (탭 변경 시 FAB 표시 업데이트)
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Phase 5: TabController 해제
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Tools'),
        actions: [
          // App Logs 탭에서만 활성화되는 액션들
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy all logs',
            onPressed: () {
              final logs = Logger.getAllLogs();
              Clipboard.setData(ClipboardData(text: logs));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그가 클립보드에 복사되었습니다')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Clear logs',
            onPressed: () {
              Logger.clearLogs();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그가 삭제되었습니다')),
              );
            },
          ),
        ],
        // Phase 5: TabBar 추가 (AppBar 하단)
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.list_alt),
              text: 'App Logs',
            ),
            Tab(
              icon: Icon(Icons.security),
              text: 'Guard Analytics',
            ),
          ],
        ),
      ),
      // Phase 5: TabBarView로 변경
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: App Logs (기존 기능)
          _buildAppLogsTab(),
          // Tab 2: Guard Analytics (Phase 5 Day 3 구현 예정)
          const GuardAnalyticsTab(),
        ],
      ),
      // FAB는 App Logs 탭에서만 표시
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                // 최근 100개 로그만 복사
                final recentLogs = Logger.getRecentLogs(100);
                Clipboard.setData(ClipboardData(text: recentLogs));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('최근 100개 로그가 복사되었습니다')),
                );
              },
              child: const Icon(Icons.content_copy),
            )
          : null,
    );
  }

  /// App Logs 탭 UI (기존 로그 표시)
  ///
  /// **터미널 스타일**:
  /// - 배경: Colors.black
  /// - 텍스트: Colors.green
  /// - 폰트: monospace (고정폭)
  /// - 선택 가능: SelectableText
  Widget _buildAppLogsTab() {
    return Container(
      color: Colors.black,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          Logger.getAllLogs(),
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}
