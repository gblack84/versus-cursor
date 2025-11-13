import '/core/widgets/pickle_mark/pickle_mark_widget.dart';
import '/core_exports.dart';
import '/app/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Phase 10: PhonemaximumModel 제거 (빈 모델, 상태 없음)

class PhonemaximumWidget extends StatefulWidget {
  const PhonemaximumWidget({super.key});

  @override
  State<PhonemaximumWidget> createState() => _PhonemaximumWidgetState();
}

class _PhonemaximumWidgetState extends State<PhonemaximumWidget> {
  // Phase 10: AppModel 제거 - 상태 없음

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Container(
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
                  child: PickleMarkWidget(),
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
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      AppLocalizations.of(context).getText(
                        '3dcoy1cp' /* You have exceeded the maximum ... */,
                      ),
                      textAlign: TextAlign.center,
                      style: AppTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontStyle:
                                  AppTheme.of(context).bodyMedium.fontStyle,
                            ),
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
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
              child: AppButtonWidget(
                onPressed: () async {
                  Navigator.pop(context);

                  context.pushNamed(
                    PhoneCreatAccountWidget.routeName,
                    queryParameters: {
                      'phoneNumberParam': serializeParam(
                        '',
                        ParamType.String,
                      ),
                    }.withoutNulls,
                  );
                },
                text: AppLocalizations.of(context).getText(
                  'vgyx5a8r' /* Ok */,
                ),
                options: AppButtonOptions(
                  width: 80.0,
                  height: 40.0,
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  iconPadding:
                      EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: AppTheme.of(context).primaryText,
                  textStyle: AppTheme.of(context).titleSmall.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight:
                              AppTheme.of(context).titleSmall.fontWeight,
                          fontStyle: AppTheme.of(context).titleSmall.fontStyle,
                        ),
                        color: Colors.white,
                        letterSpacing: 0.0,
                        fontWeight: AppTheme.of(context).titleSmall.fontWeight,
                        fontStyle: AppTheme.of(context).titleSmall.fontStyle,
                      ),
                  elevation: 0.0,
                  borderSide: BorderSide(
                    color: AppTheme.of(context).info,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                  hoverColor: Color(0xFFE0E3E7),
                  hoverBorderSide: BorderSide(
                    color: Color(0xFF14181B),
                  ),
                  hoverTextColor: Color(0xFF14181B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
