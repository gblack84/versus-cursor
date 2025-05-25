import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
            ),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: custom_widgets.NewFFVideoEditorView(
                width: double.infinity,
                height: double.infinity,
                videoPath: FFAppState().TempPath,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
