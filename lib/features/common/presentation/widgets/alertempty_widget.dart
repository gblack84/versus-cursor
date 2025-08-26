import '/etc/vsmark/vsmark_widget.dart';
import '/core_exports.dart';
// import '/posts/in_put_text/in_put_text_widget.dart'; // 삭제된 파일
// import '/index.dart'; // 사용하지 않는 import 제거
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import '/features/common/domain/models/alertempty_model.dart';
export '/features/common/domain/models/alertempty_model.dart';

class AlertemptyWidget extends StatefulWidget {
  const AlertemptyWidget({super.key});

  @override
  State<AlertemptyWidget> createState() => _AlertemptyWidgetState();
}

class _AlertemptyWidgetState extends State<AlertemptyWidget> {
  late AlertemptyModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AlertemptyModel());

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
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.0),
          bottomRight: Radius.circular(30.0),
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
        shape: BoxShape.rectangle,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                width: 200.46,
                height: 56.5,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).secondaryBackground,
                ),
                child: wrapWithModel(
                  model: _model.vsmarkModel,
                  updateCallback: () => setState(() {}),
                  child: VsmarkWidget(),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.of(context).secondaryBackground,
              ),
              child: Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    AppLocalizations.of(context).getText(
                      '707q86sk' /* No Text Entered */,
                    ),
                    textAlign: TextAlign.center,
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontStyle: AppTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          color: Color(0xFFE04343),
                          fontSize: 20.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w800,
                          fontStyle:
                              AppTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.of(context).secondaryBackground,
              ),
              child: Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    AppLocalizations.of(context).getText(
                      'sz1sjey3' /* The text field is empty. If yo... */,
                    ),
                    textAlign: TextAlign.center,
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontStyle: AppTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w800,
                          fontStyle:
                              AppTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 20.0, 0.0),
                  child: AppIconButton(
                    borderRadius: 8.0,
                    buttonSize: 40.0,
                    fillColor: AppTheme.of(context).primary,
                    icon: FaIcon(
                      FontAwesomeIcons.rotateRight,
                      color: AppTheme.of(context).info,
                      size: 24.0,
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      AppState().uploadTextEditing = 0;
                      setState(() {});
                      await showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        enableDrag: false,
                        context: context,
                        builder: (context) {
                          return WebViewAware(
                            child: Padding(
                              padding: MediaQuery.viewInsetsOf(context),
                              // InPutTextWidget 임시 비활성화
                              child: Container(
                                child: Center(
                                  child: Text('텍스트 입력 기능이 삭제되었습니다.'),
                                ),
                              ),
                            ),
                          );
                        },
                      ).then((value) => setState(() {}));
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 20.0, 0.0),
                  child: AppButtonWidget(
                    onPressed: () async {
                      Navigator.pop(context);

                      // HomeAndPostsCopyWidget 임시 비활성화
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('페이지가 삭제되었습니다.')),
                      );
                    },
                    text: AppLocalizations.of(context).getText(
                      'xhyu1hyf' /* Ok */,
                    ),
                    options: AppButtonOptions(
                      width: 80.0,
                      height: 40.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: AppTheme.of(context).primaryText,
                      textStyle:
                          AppTheme.of(context).titleSmall.override(
                                font: GoogleFonts.plusJakartaSans(
                                  fontWeight: AppTheme.of(context)
                                      .titleSmall
                                      .fontWeight,
                                  fontStyle: AppTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                                color: Colors.white,
                                letterSpacing: 0.0,
                                fontWeight: AppTheme.of(context)
                                    .titleSmall
                                    .fontWeight,
                                fontStyle: AppTheme.of(context)
                                    .titleSmall
                                    .fontStyle,
                              ),
                      elevation: 10.0,
                      borderSide: BorderSide(
                        color: AppTheme.of(context).info,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
