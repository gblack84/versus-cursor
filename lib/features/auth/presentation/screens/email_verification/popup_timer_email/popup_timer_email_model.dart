import '/core/widgets/pickle_mark/pickle_mark_widget.dart';
import '/core_exports.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'popup_timer_email_widget.dart' show PopupTimerEmailWidget;
import 'package:flutter/material.dart';

class PopupTimerEmailModel extends AppModel<PopupTimerEmailWidget> {
  ///  Local state fields for this component.

  int resendCount = 0;

  bool isVerifiedEmail = false;

  ///  State fields for stateful widgets in this component.

  // Model for pickle mark component.
  late PickleMarkModel pickleMarkModel;
  // State field(s) for Timer widget.
  final timerInitialTimeMs = 180000;
  int timerMilliseconds = 180000;
  String timerValue = StopWatchTimer.getDisplayTime(
    180000,
    hours: false,
    milliSecond: false,
  );
  AppTimerController timerController =
      AppTimerController(StopWatchTimer(mode: StopWatchMode.countDown));

  @override
  void initState(BuildContext context) {
    pickleMarkModel = createModel(context, () => PickleMarkModel());
  }

  @override
  void dispose() {
    pickleMarkModel.dispose();
    timerController.dispose();
  }
}
