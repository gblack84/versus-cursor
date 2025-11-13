import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

/// **Auth Feature 전용 타이머 UI**
///
/// **Clean Architecture v4.0 (Feature-First)**:
/// - ✅ Auth Feature 독립 (core/utils 의존성 제거)
/// - ✅ stop_watch_timer 패키지 직접 사용 (불필요한 래퍼 제거)
/// - ✅ StreamBuilder로 실시간 타이머 표시
///
/// **사용처** (3곳):
/// - popup_timer_email_widget.dart (이메일 인증 120초 타이머)
/// - otp_timer_display.dart (OTP 120초 타이머 디스플레이)
/// - phonelogeinpincode_widget.dart (전화번호 PIN 코드 120초 타이머)
///
/// **설계 원칙**:
/// - ✅ KISS: 불필요한 래퍼(AppTimer) 제거
/// - ✅ Feature-First: Auth 전용 코드는 Auth Feature에
/// - ✅ Don't Reinvent the Wheel: stop_watch_timer 직접 사용
class AuthTimerDisplay extends StatelessWidget {
  /// stop_watch_timer 패키지의 타이머 인스턴스
  final StopWatchTimer timer;

  /// Text 위젯 스타일 (선택적)
  final TextStyle? style;

  /// Text 정렬 (기본값: TextAlign.start)
  final TextAlign? textAlign;

  const AuthTimerDisplay({
    super.key,
    required this.timer,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: timer.rawTime,
      builder: (context, snapshot) {
        final value = snapshot.data ?? 0;

        // stop_watch_timer의 포맷팅 함수 직접 사용
        final displayTime = StopWatchTimer.getDisplayTime(
          value,
          hours: false,
          milliSecond: false,
        );

        return Text(
          displayTime,
          style: style,
          textAlign: textAlign ?? TextAlign.start,
        );
      },
    );
  }
}
