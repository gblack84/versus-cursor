import 'dart:async';

/// 입력 이벤트를 지연시켜 처리하는 유틸리티 클래스
///
/// 연속적인 입력에서 마지막 입력 후 지정된 시간이 지나면 콜백을 실행합니다.
/// 주로 검색어 입력이나 유효성 검사에서 사용됩니다.
class Debounce {
  final int milliseconds;
  Timer? _timer;

  Debounce({this.milliseconds = 500});

  /// 지정된 시간 후에 콜백 실행
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// 타이머 취소 및 리소스 정리
  void dispose() {
    _timer?.cancel();
  }
}

typedef VoidCallback = void Function();