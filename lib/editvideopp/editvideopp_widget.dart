import '/core/app_utils.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'editvideopp_model.dart';
export 'editvideopp_model.dart';

class EditvideoppWidget extends StatefulWidget {
  const EditvideoppWidget({super.key});

  static String routeName = 'editvideopp';
  static String routePath = '/editvideopp';

  @override
  State<EditvideoppWidget> createState() => _EditvideoppWidgetState();
}

class _EditvideoppWidgetState extends State<EditvideoppWidget> {
  late EditvideoppModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditvideoppModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: custom_widgets.NewVideoTrimmerPage(
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
