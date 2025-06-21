import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'upload_choice_bottom_sheet_model.dart';
export 'upload_choice_bottom_sheet_model.dart';

class UploadChoiceBottomSheetWidget extends StatefulWidget {
  const UploadChoiceBottomSheetWidget({super.key});

  @override
  State<UploadChoiceBottomSheetWidget> createState() =>
      _UploadChoiceBottomSheetWidgetState();
}

class _UploadChoiceBottomSheetWidgetState
    extends State<UploadChoiceBottomSheetWidget> {
  late UploadChoiceBottomSheetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UploadChoiceBottomSheetModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300.0,
      decoration: BoxDecoration(
        color: Color(0x25000000),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FFButtonWidget(
            onPressed: () async {
              _model.pickedVideoPath = await actions.getVideoPath(
                'gallery',
              );
              if (_model.pickedVideoPath != null &&
                  _model.pickedVideoPath != '') {
                var postsRecordReference = PostsRecord.collection.doc();
                await postsRecordReference.set({
                  ...createPostsRecordData(
                    userid: currentUserUid,
                  ),
                  ...mapToFirestore(
                    {
                      'createdAt': FieldValue.serverTimestamp(),
                    },
                  ),
                });
                _model.postDocRef = PostsRecord.getDocumentFromData({
                  ...createPostsRecordData(
                    userid: currentUserUid,
                  ),
                  ...mapToFirestore(
                    {
                      'createdAt': DateTime.now(),
                    },
                  ),
                }, postsRecordReference);
                FFAppState().currentPostId = _model.postDocRef!.reference.id;
                safeSetState(() {});

                var videoRecordReference =
                    VideoRecord.createDoc(_model.postDocRef!.reference);
                await videoRecordReference.set({
                  ...createVideoRecordData(
                    status: '\"processing\"',
                    sourcepath: _model.pickedVideoPath,
                    owneruid: currentUserUid,
                  ),
                  ...mapToFirestore(
                    {
                      'createdat': FieldValue.serverTimestamp(),
                    },
                  ),
                });
                _model.videoDocRef = VideoRecord.getDocumentFromData({
                  ...createVideoRecordData(
                    status: '\"processing\"',
                    sourcepath: _model.pickedVideoPath,
                    owneruid: currentUserUid,
                  ),
                  ...mapToFirestore(
                    {
                      'createdat': DateTime.now(),
                    },
                  ),
                }, videoRecordReference);

                context.pushNamed(
                  EditvideoppWidget.routeName,
                  queryParameters: {
                    'videoPath': serializeParam(
                      _model.pickedVideoPath,
                      ParamType.String,
                    ),
                    'videoDocRef': serializeParam(
                      _model.videoDocRef?.reference,
                      ParamType.DocumentReference,
                    ),
                    'postid': serializeParam(
                      '',
                      ParamType.String,
                    ),
                  }.withoutNulls,
                  extra: <String, dynamic>{
                    kTransitionInfoKey: TransitionInfo(
                      hasTransition: true,
                      transitionType: PageTransitionType.bottomToTop,
                    ),
                  },
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to process video',
                      style: TextStyle(
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                    ),
                    duration: Duration(milliseconds: 4000),
                    backgroundColor: FlutterFlowTheme.of(context).secondary,
                  ),
                );
              }

              safeSetState(() {});
            },
            text: FFLocalizations.of(context).getText(
              'i36a91le' /* Gallery */,
            ),
            options: FFButtonOptions(
              height: 40.0,
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              color: Color(0x25000000),
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                    color: Colors.white,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).titleSmallIsCustom,
                  ),
              elevation: 0.0,
              borderSide: BorderSide(
                color: Color(0xFFFFDF00),
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          FFButtonWidget(
            onPressed: () {
              print('Button pressed ...');
            },
            text: FFLocalizations.of(context).getText(
              '16rkqdde' /* Camera */,
            ),
            options: FFButtonOptions(
              height: 40.0,
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              color: Color(0x25000000),
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: FlutterFlowTheme.of(context).titleSmallFamily,
                    color: Colors.white,
                    letterSpacing: 0.0,
                    useGoogleFonts:
                        !FlutterFlowTheme.of(context).titleSmallIsCustom,
                  ),
              elevation: 0.0,
              borderSide: BorderSide(
                color: Color(0xFFFFDF00),
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ],
      ),
    );
  }
}
