import '/etc/vsmark/vsmark_widget.dart';
import '/core_exports.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'phoneloginpincode_widget.dart' show PhoneloginpincodeWidget;
import 'package:flutter/material.dart';

class PhoneloginpincodeModel extends AppModel<PhoneloginpincodeWidget> {
  ///  Local state fields for this component.

  int resendCount = 0;

  ///  State fields for stateful widgets in this component.

  // Model for vsmark component.
  late VsmarkModel vsmarkModel;
  // State field(s) for PinCode widget.
  TextEditingController? pinCodeController;
  FocusNode? pinCodeFocusNode;
  String? Function(BuildContext, String?)? pinCodeControllerValidator;
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
    vsmarkModel = createModel(context, () => VsmarkModel());
    pinCodeController = TextEditingController();
  }

  @override
  void dispose() {
    vsmarkModel.dispose();
    pinCodeFocusNode?.dispose();
    pinCodeController?.dispose();

    timerController.dispose();
  }
}
