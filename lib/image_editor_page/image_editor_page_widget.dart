import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'image_editor_page_model.dart';
export 'image_editor_page_model.dart';

class ImageEditorPageWidget extends StatefulWidget {
  const ImageEditorPageWidget({
    super.key,
    this.originalVideoPath,
    required this.startMs,
    required this.endMs,
    required this.postId,
  });

  final String? originalVideoPath;
  final int? startMs;
  final int? endMs;
  final String? postId;

  static String routeName = 'ImageEditorPage';
  static String routePath = '/imageEditorPage';

  @override
  State<ImageEditorPageWidget> createState() => _ImageEditorPageWidgetState();
}

class _ImageEditorPageWidgetState extends State<ImageEditorPageWidget> {
  late ImageEditorPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ImageEditorPageModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
          ),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: custom_widgets.AdvancedImageEditor(
              width: double.infinity,
              height: double.infinity,
              originalVideoPath: widget.originalVideoPath,
              startMs: widget.startMs,
              endMs: widget.endMs,
              postId: widget.postId,
            ),
          ),
        ),
      ),
    );
  }
}
