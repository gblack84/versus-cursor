import '/features/auth/data/adapters/auth_util.dart';
import '/features/profile/domain/usecases/interests/update_user_interests_usecase.dart';
import '/core_exports.dart';
import '/app/widgets/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'package:get_it/get_it.dart';
import 'hobbies_select_model.dart';
export 'hobbies_select_model.dart';

class HobbiesSelectWidget extends StatefulWidget {
  const HobbiesSelectWidget({super.key});

  static String routeName = 'hobbies_select';
  static String routePath = '/hobbiesSelect';

  @override
  State<HobbiesSelectWidget> createState() => _HobbiesSelectWidgetState();
}

class _HobbiesSelectWidgetState extends State<HobbiesSelectWidget> {
  late HobbiesSelectModel _model;
  late final UpdateUserInterestsUseCase _updateInterestsUseCase;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HobbiesSelectModel());

    _model.hobbiesTextController ??= TextEditingController();
    _model.hobbiesFocusNode ??= FocusNode();
    _model.hobbiesFocusNode!.addListener(() => setState(() {}));

    // Week 7: Initialize UpdateUserInterestsUseCase from DI
    _updateInterestsUseCase = GetIt.instance<UpdateUserInterestsUseCase>();

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
        backgroundColor: Color(0xFFECECEC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: true,
          leading: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.pushNamed(UserInfoInputWidget.routeName);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 24.0,
            ),
          ),
          title: Align(
            alignment: AlignmentDirectional(-1.0, 1.0),
            child: Text(
              AppLocalizations.of(context).getText(
                'flvvuyvo' /* versus space */,
              ),
              textAlign: TextAlign.end,
              style: AppTheme.of(context).headlineSmall.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: AppTheme.of(context).headlineSmall.fontWeight,
                      fontStyle: AppTheme.of(context).headlineSmall.fontStyle,
                    ),
                    color: Color(0xFF14181B),
                    letterSpacing: 0.0,
                    fontWeight: AppTheme.of(context).headlineSmall.fontWeight,
                    fontStyle: AppTheme.of(context).headlineSmall.fontStyle,
                  ),
            ),
          ),
          actions: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                'assets/images/versus-sign-black-white-symbol_679005-151@1x.png',
                width: 100.0,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Container(
            decoration: BoxDecoration(),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: 412.0,
                      decoration: BoxDecoration(),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Container(
                              decoration: BoxDecoration(),
                              child: RichText(
                                textScaler: MediaQuery.of(context).textScaler,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: currentUserDisplayName,
                                      style: AppTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w800,
                                              fontStyle: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                            ),
                                            fontSize: 18.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w800,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                    ),
                                    TextSpan(
                                      text:
                                          AppLocalizations.of(context).getText(
                                        'jnha4tov' /*  Next, share your hobbies and ... */,
                                      ),
                                      style: AppTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                    ),
                                    TextSpan(
                                      text:
                                          AppLocalizations.of(context).getText(
                                        's6khifdw' /* 
We’ll tailor recommendations ... */
                                        ,
                                      ),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16.0,
                                      ),
                                    )
                                  ],
                                  style:
                                      AppTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.bold,
                                              fontStyle: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                            ),
                                            fontSize: 16.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.bold,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.0),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                AppLocalizations.of(context).getText(
                                  '8cyk6y1f' /* What are your hobbies or inter... */,
                                ),
                                textAlign: TextAlign.center,
                                style: AppTheme.of(context)
                                    .headlineMedium
                                    .override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: AppTheme.of(context)
                                            .headlineMedium
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                      ),
                                      color: Color(0xFF14181B),
                                      letterSpacing: 0.0,
                                      fontWeight: AppTheme.of(context)
                                          .headlineMedium
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .headlineMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Container(
                        height: 142.3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(0.0),
                            bottomRight: Radius.circular(0.0),
                            topLeft: Radius.circular(0.0),
                            topRight: Radius.circular(0.0),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            TextFormField(
                              controller: _model.hobbiesTextController,
                              focusNode: _model.hobbiesFocusNode,
                              onChanged: (_) => EasyDebounce.debounce(
                                '_model.hobbiesTextController',
                                Duration(milliseconds: 2000),
                                () async {
                                  _model.hobbiesTag =
                                      _model.hobbiesTextController.text;
                                  setState(() {});
                                },
                              ),
                              autofocus: true,
                              textCapitalization: TextCapitalization.words,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context).getText(
                                  'kh1x2j64' /* hobby or interest… */,
                                ),
                                labelStyle: AppTheme.of(context)
                                    .headlineMedium
                                    .override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: AppTheme.of(context)
                                            .headlineMedium
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                      ),
                                      color: AppTheme.of(context).secondaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: AppTheme.of(context)
                                          .headlineMedium
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .headlineMedium
                                          .fontStyle,
                                    ),
                                hintStyle:
                                    AppTheme.of(context).labelMedium.override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: AppTheme.of(context)
                                                .labelMedium
                                                .fontWeight,
                                            fontStyle: AppTheme.of(context)
                                                .labelMedium
                                                .fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight: AppTheme.of(context)
                                              .labelMedium
                                              .fontWeight,
                                          fontStyle: AppTheme.of(context)
                                              .labelMedium
                                              .fontStyle,
                                        ),
                                errorStyle:
                                    AppTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight: AppTheme.of(context)
                                                .bodyMedium
                                                .fontWeight,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                          color: AppTheme.of(context).error,
                                          fontSize: 12.0,
                                          letterSpacing: 0.0,
                                          fontWeight: AppTheme.of(context)
                                              .bodyMedium
                                              .fontWeight,
                                          fontStyle: AppTheme.of(context)
                                              .bodyMedium
                                              .fontStyle,
                                        ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.of(context).primary,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.of(context).error,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppTheme.of(context).error,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                filled: true,
                                fillColor: (_model.hobbiesFocusNode?.hasFocus ??
                                        false)
                                    ? AppTheme.of(context).accent1
                                    : AppTheme.of(context).secondaryBackground,
                                contentPadding: EdgeInsetsDirectional.fromSTEB(
                                    16.0, 20.0, 16.0, 20.0),
                              ),
                              style:
                                  AppTheme.of(context).headlineMedium.override(
                                        font: GoogleFonts.plusJakartaSans(
                                          fontWeight: AppTheme.of(context)
                                              .headlineMedium
                                              .fontWeight,
                                          fontStyle: AppTheme.of(context)
                                              .headlineMedium
                                              .fontStyle,
                                        ),
                                        letterSpacing: 0.0,
                                        fontWeight: AppTheme.of(context)
                                            .headlineMedium
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .headlineMedium
                                            .fontStyle,
                                      ),
                              maxLength: 20,
                              buildCounter: (context,
                                      {required currentLength,
                                      required isFocused,
                                      maxLength}) =>
                                  null,
                              cursorColor: AppTheme.of(context).primary,
                              validator: _model.hobbiesTextControllerValidator
                                  .asValidator(context),
                              inputFormatters: [
                                if (!isAndroid && !isiOS)
                                  TextInputFormatter.withFunction(
                                      (oldValue, newValue) {
                                    return TextEditingValue(
                                      selection: newValue.selection,
                                      text: newValue.text.toCapitalization(
                                          TextCapitalization.words),
                                    );
                                  }),
                              ],
                            ),
                            Align(
                              alignment: AlignmentDirectional(1.0, 0.0),
                              child: Text(
                                AppLocalizations.of(context).getText(
                                  'qdn4sbni' /* You can add up to 8 items. */,
                                ),
                                textAlign: TextAlign.center,
                                style: AppTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: AppTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: AppTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: FontStyle.italic,
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 10.0, 0.0, 0.0),
                              child: AppButtonWidget(
                                onPressed: (_model.hobbiesTag != ''
                                        ? false
                                        : true)
                                    ? null
                                    : () async {
                                        if ((currentUserDocument?.interests
                                                        .toList() ??
                                                    [])
                                                .length >=
                                            8) {
                                          await showDialog(
                                            context: context,
                                            builder: (alertDialogContext) {
                                              return WebViewAware(
                                                child: AlertDialog(
                                                  title:
                                                      Text('\"Limit Reached\"'),
                                                  content: Text(
                                                      '\"You can only add up to 8 expertise.\"'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              alertDialogContext),
                                                      child: Text('Ok'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        } else {
                                          // Week 7: UpdateUserInterestsUseCase로 전환
                                          final result = await _updateInterestsUseCase.addInterest(
                                            userId: currentUserUid,
                                            interest: _model.hobbiesTextController.text,
                                            category: 'hobby',
                                          );

                                          result.fold(
                                            (failure) {
                                              // 실패 처리
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text(failure.message)),
                                              );
                                            },
                                            (_) {
                                              // 성공 처리
                                              setState(() {
                                                _model.hobbiesTextController?.clear();
                                              });
                                              // AppState 갱신
                                              AppState().update(() {});
                                            },
                                          );
                                        }
                                      },
                                text: AppLocalizations.of(context).getText(
                                  '0a61zfnb' /* Add */,
                                ),
                                options: AppButtonOptions(
                                  height: 40.0,
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      16.0, 0.0, 16.0, 0.0),
                                  iconPadding: EdgeInsetsDirectional.fromSTEB(
                                      0.0, 0.0, 0.0, 0.0),
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
                                  elevation: 0.0,
                                  borderRadius: BorderRadius.circular(8.0),
                                  disabledColor: Color(0xFF646464),
                                  disabledTextColor: Color(0xFFA7A6A6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (((currentUserDocument?.expertise.toList() ?? [])
                            .isNotEmpty) ==
                        true)
                      AuthUserStreamWidget(
                        builder: (context) => Container(
                          width: 380.0,
                          height: 20.0,
                          decoration: BoxDecoration(),
                          child: Align(
                            alignment: AlignmentDirectional(0.0, -1.0),
                            child: Text(
                              AppLocalizations.of(context).getText(
                                'tial28r9' /* List. */,
                              ),
                              textAlign: TextAlign.center,
                              style: AppTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w800,
                                      fontStyle: AppTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w800,
                                    fontStyle: AppTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    if (((currentUserDocument?.expertise.toList() ?? [])
                            .isNotEmpty) ==
                        true)
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: AuthUserStreamWidget(
                          builder: (context) => Container(
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).secondary,
                            ),
                            child: Align(
                              alignment: AlignmentDirectional(0.0, 0.0),
                              child: Builder(
                                builder: (context) {
                                  final authenticatedUser = (currentUserDocument
                                              ?.interests
                                              .toList() ??
                                          [])
                                      .toList();

                                  return Wrap(
                                    spacing: 4.0,
                                    runSpacing: 1.0,
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    direction: Axis.horizontal,
                                    runAlignment: WrapAlignment.center,
                                    verticalDirection: VerticalDirection.down,
                                    clipBehavior: Clip.none,
                                    children:
                                        List.generate(authenticatedUser.length,
                                            (authenticatedUserIndex) {
                                      final authenticatedUserItem =
                                          authenticatedUser[
                                              authenticatedUserIndex];
                                      return Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            8.0, 8.0, 8.0, 8.0),
                                        child: Container(
                                          height: 32.0,
                                          decoration: BoxDecoration(
                                            color: AppTheme.of(context).accent3,
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            border: Border.all(
                                              color:
                                                  AppTheme.of(context).tertiary,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(
                                                        8.0, 0.0, 0.0, 0.0),
                                                child: Text(
                                                  authenticatedUserItem,
                                                  textAlign: TextAlign.center,
                                                  style: AppTheme.of(context)
                                                      .bodyMedium
                                                      .override(
                                                        font: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontWeight:
                                                              AppTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              AppTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                        letterSpacing: 0.0,
                                                        fontWeight:
                                                            AppTheme.of(context)
                                                                .bodyMedium
                                                                .fontWeight,
                                                        fontStyle:
                                                            AppTheme.of(context)
                                                                .bodyMedium
                                                                .fontStyle,
                                                      ),
                                                ),
                                              ),
                                              AppIconButton(
                                                borderRadius: 8.0,
                                                buttonSize: 30.0,
                                                icon: Icon(
                                                  Icons.cancel_outlined,
                                                  color:
                                                      AppTheme.of(context).info,
                                                  size: 15.0,
                                                ),
                                                onPressed: () async {
                                                  // Week 7: UpdateUserInterestsUseCase로 전환
                                                  final result = await _updateInterestsUseCase.removeInterest(
                                                    userId: currentUserUid,
                                                    interest: authenticatedUserItem,
                                                    category: 'hobby',
                                                  );

                                                  result.fold(
                                                    (failure) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(content: Text(failure.message)),
                                                      );
                                                    },
                                                    (_) {
                                                      // AppState 갱신
                                                      AppState().update(() {});
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    Align(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Padding(
                        padding: EdgeInsets.all(14.0),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(0.0),
                              bottomRight: Radius.circular(0.0),
                              topLeft: Radius.circular(0.0),
                              topRight: Radius.circular(0.0),
                            ),
                          ),
                          alignment: AlignmentDirectional(0.0, 0.0),
                          child: RichText(
                            textScaler: MediaQuery.of(context).textScaler,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: AppLocalizations.of(context).getText(
                                    'ddy2vf0h' /* Tip. */,
                                  ),
                                  style:
                                      AppTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w600,
                                              fontStyle: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                            ),
                                            fontSize: 17.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(context).getText(
                                    'ap7dkw8g' /*  Add your favorite hobbies or ... */,
                                  ),
                                  style:
                                      AppTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w500,
                                              fontStyle: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w500,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(context).getText(
                                    'r0p1jhwa' /* 

“Which instrument is more be... */
                                    ,
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(context).getText(
                                    'ng6aurtj' /* 
“For a short getaway, would y... */
                                    ,
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              ],
                              style: AppTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: AppTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: AppTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          16.0, 20.0, 16.0, 20.0),
                      child: AppButtonWidget(
                        onPressed: () async {
                          context.pushNamed(AgrredSelectWidget.routeName);
                        },
                        text: AppLocalizations.of(context).getText(
                          '0m7oqr3n' /* Next */,
                        ),
                        options: AppButtonOptions(
                          width: 300.0,
                          height: 48.0,
                          padding: EdgeInsetsDirectional.fromSTEB(
                              16.0, 0.0, 16.0, 0.0),
                          iconPadding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 0.0, 0.0),
                          color: AppTheme.of(context).primaryText,
                          textStyle: AppTheme.of(context).titleSmall.override(
                                font: GoogleFonts.plusJakartaSans(
                                  fontWeight: AppTheme.of(context)
                                      .titleSmall
                                      .fontWeight,
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
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
