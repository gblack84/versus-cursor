import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'vsmark_model.dart';
export 'vsmark_model.dart';

class VsmarkWidget extends StatefulWidget {
  const VsmarkWidget({super.key});

  @override
  State<VsmarkWidget> createState() => _VsmarkWidgetState();
}

class _VsmarkWidgetState extends State<VsmarkWidget> {
  late VsmarkModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => VsmarkModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Container(
        decoration: BoxDecoration(),
        child: Align(
          alignment: AlignmentDirectional(0.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200.0,
                height: 100.0,
                child: Stack(
                  children: [
                    Align(
                      alignment: AlignmentDirectional(-1.2, 0.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          'assets/images/20250402_1112_____remix_01jqt4bfgvebj8s1j9b2ywjy5z.png',
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional(1.15, 0.42),
                      child: Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(1.0, 0.0, 0.0, 0.0),
                        child: Text(
                          FFLocalizations.of(context).getText(
                            'abejuxne' /* Versus */,
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'SourGummy',
                                    color: Color(0xFF14181B),
                                    fontSize: 45.0,
                                    letterSpacing: 0.0,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
