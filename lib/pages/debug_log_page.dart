import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/features/common/data/services/app_logger.dart';

/// 디버그 로그를 보여주는 페이지
class DebugLogPage extends StatelessWidget {
  const DebugLogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              final logs = AppLogger.getAllLogs();
              Clipboard.setData(ClipboardData(text: logs));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그가 클립보드에 복사되었습니다')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              AppLogger.clearLogs();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('로그가 삭제되었습니다')),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: SelectableText(
            AppLogger.getAllLogs(),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.green,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 최근 100개 로그만 복사
          final recentLogs = AppLogger.getRecentLogs(100);
          Clipboard.setData(ClipboardData(text: recentLogs));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('최근 100개 로그가 복사되었습니다')),
          );
        },
        child: const Icon(Icons.content_copy),
      ),
    );
  }
}