import '/backend/backend.dart';
import '/core/app_theme.dart';
import '/core/app_utils.dart';
import '/core/app_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
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
          AppButtonWidget(
            onPressed: () async {
              var postsRecordReference = PostsRecord.collection.doc();
              await postsRecordReference.set(createPostsRecordData());
              _model.newPost = PostsRecord.getDocumentFromData(
                  createPostsRecordData(), postsRecordReference);
              _model.pickedVideoPath = await actions.getVideoPath(
                'gallery',
              );
              if (_model.pickedVideoPath != null &&
                  _model.pickedVideoPath != '') {
                AppState().uploadPostId = _model.newPost!.reference.id;
                AppState().uploadVideoPath = _model.pickedVideoPath!;
                setState(() {});

                context.pushNamed(EditvideoppWidget.routeName);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '\"비디오 선택이 취소되었습니다\" ',
                      style: TextStyle(
                        color: AppTheme.of(context).primaryText,
                      ),
                    ),
                    duration: Duration(milliseconds: 4000),
                    backgroundColor: AppTheme.of(context).secondary,
                  ),
                );
              }

              setState(() {});
            },
            text: AppLocalizations.of(context).getText(
              'i36a91le' /* Gallery */,
            ),
            options: AppButtonOptions(
              height: 40.0,
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              color: Color(0x25000000),
              textStyle: AppTheme.of(context).titleSmall.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight:
                          AppTheme.of(context).titleSmall.fontWeight,
                      fontStyle:
                          AppTheme.of(context).titleSmall.fontStyle,
                    ),
                    color: Colors.white,
                    letterSpacing: 0.0,
                    fontWeight:
                        AppTheme.of(context).titleSmall.fontWeight,
                    fontStyle:
                        AppTheme.of(context).titleSmall.fontStyle,
                  ),
              elevation: 0.0,
              borderSide: BorderSide(
                color: Color(0xFFFFDF00),
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          AppButtonWidget(
            onPressed: () {
              print('Button pressed ...');
            },
            text: AppLocalizations.of(context).getText(
              '16rkqdde' /* Camera */,
            ),
            options: AppButtonOptions(
              height: 40.0,
              padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              color: Color(0x25000000),
              textStyle: AppTheme.of(context).titleSmall.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight:
                          AppTheme.of(context).titleSmall.fontWeight,
                      fontStyle:
                          AppTheme.of(context).titleSmall.fontStyle,
                    ),
                    color: Colors.white,
                    letterSpacing: 0.0,
                    fontWeight:
                        AppTheme.of(context).titleSmall.fontWeight,
                    fontStyle:
                        AppTheme.of(context).titleSmall.fontStyle,
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
