import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:uuid/uuid.dart';
import '/core/utils/error_handler.dart';
import '/features/auth/presentation/providers/auth_providers.dart';
import '/features/auth/presentation/providers/usecase_providers.dart';
import '/core_exports.dart';
import '/app/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'phone_creat_account_model.dart';
export 'phone_creat_account_model.dart';

class PhoneCreatAccountWidget extends ConsumerStatefulWidget {
  const PhoneCreatAccountWidget({
    super.key,
    required this.phoneNumberParam,
  });

  final String? phoneNumberParam;

  static String routeName = 'PhoneCreatAccount';
  static String routePath = '/phoneCreatAccount';

  @override
  ConsumerState<PhoneCreatAccountWidget> createState() =>
      _PhoneCreatAccountWidgetState();
}

class _PhoneCreatAccountWidgetState extends ConsumerState<PhoneCreatAccountWidget> {
  late PhoneCreatAccountModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PhoneCreatAccountModel());

    _model.codeCuntryTextController ??= TextEditingController();
    _model.codeCuntryFocusNode ??= FocusNode();

    _model.codeCuntryMask = MaskTextInputFormatter(mask: '+###');
    _model.phoneNumberTextController ??= TextEditingController();
    _model.phoneNumberFocusNode ??= FocusNode();

    // Phone Auth 상태 변경 처리는 Provider 내부에서 처리
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: AppIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 60.0,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
            size: 30.0,
          ),
          onPressed: () async {
            context.pushNamed(CreateAccountWidget.routeName);
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 0.0, 0.0),
              child: Text(
                AppLocalizations.of(context).getText(
                  'qgyftxro' /* Back */,
                ),
                style: AppTheme.of(context).displaySmall.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight:
                            AppTheme.of(context).displaySmall.fontWeight,
                        fontStyle: AppTheme.of(context).displaySmall.fontStyle,
                      ),
                      color: Colors.black,
                      fontSize: 16.0,
                      letterSpacing: 0.0,
                      fontWeight: AppTheme.of(context).displaySmall.fontWeight,
                      fontStyle: AppTheme.of(context).displaySmall.fontStyle,
                    ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                'assets/images/20250402_1112_____remix_01jqt4bfgvebj8s1j9b2ywjy5z.png',
                width: 50.0,
                height: 50.0,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
        actions: [],
        centerTitle: false,
        elevation: 0.0,
      ),
      body: Align(
        alignment: AlignmentDirectional(0.0, -1.0),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: 570.0,
          ),
          decoration: BoxDecoration(
            color: Color(0xFFECECEC),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 20.0, 0.0, 0.0),
                child: Text(
                  AppLocalizations.of(context).getText(
                    'gwbbszpy' /* Phone Login */,
                  ),
                  style: AppTheme.of(context).headlineMedium.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight:
                              AppTheme.of(context).headlineMedium.fontWeight,
                          fontStyle:
                              AppTheme.of(context).headlineMedium.fontStyle,
                        ),
                        color: Colors.black,
                        letterSpacing: 0.0,
                        fontWeight:
                            AppTheme.of(context).headlineMedium.fontWeight,
                        fontStyle:
                            AppTheme.of(context).headlineMedium.fontStyle,
                      ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
                child: Text(
                  AppLocalizations.of(context).getText(
                    'xv3gqx8x' /* Please enter your phone number... */,
                  ),
                  style: AppTheme.of(context).labelMedium.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight:
                              AppTheme.of(context).labelMedium.fontWeight,
                          fontStyle: AppTheme.of(context).labelMedium.fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight: AppTheme.of(context).labelMedium.fontWeight,
                        fontStyle: AppTheme.of(context).labelMedium.fontStyle,
                      ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Container(
                  width: 400.0,
                  height: 100.0,
                  decoration: BoxDecoration(),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 5.0, 0.0),
                        child: Container(
                          width: 70.0,
                          child: TextFormField(
                            controller: _model.codeCuntryTextController,
                            focusNode: _model.codeCuntryFocusNode,
                            autofillHints: [
                              AutofillHints.telephoneNumberCountryCode
                            ],
                            textCapitalization: TextCapitalization.none,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context).getText(
                                '3rvgi38u' /* +Code */,
                              ),
                              labelStyle:
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
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppTheme.of(context).alternate,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppTheme.of(context).primary,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppTheme.of(context).error,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppTheme.of(context).error,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsetsDirectional.fromSTEB(
                                  5.0, 24.0, 5.0, 24.0),
                            ),
                            style: AppTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: AppTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: Colors.black,
                                  letterSpacing: 0.0,
                                  fontWeight: AppTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle:
                                      AppTheme.of(context).bodyMedium.fontStyle,
                                ),
                            maxLines: null,
                            maxLength: 4,
                            keyboardType: TextInputType.phone,
                            cursorColor: AppTheme.of(context).primary,
                            validator: _model.codeCuntryTextControllerValidator
                                .asValidator(context),
                            inputFormatters: [_model.codeCuntryMask],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _model.phoneNumberTextController,
                            focusNode: _model.phoneNumberFocusNode,
                            textCapitalization: TextCapitalization.none,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context).getText(
                                'kna6yami' /* Your Phone Number... */,
                              ),
                              labelStyle:
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
                              hintText: AppLocalizations.of(context).getText(
                                'npd3p5vi' /* Enter your Phone Number... */,
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
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppTheme.of(context).alternate,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppTheme.of(context).primary,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppTheme.of(context).error,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppTheme.of(context).error,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsetsDirectional.fromSTEB(
                                  24.0, 24.0, 20.0, 24.0),
                            ),
                            style: AppTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.plusJakartaSans(
                                    fontWeight: AppTheme.of(context)
                                        .bodyMedium
                                        .fontWeight,
                                    fontStyle: AppTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: Colors.black,
                                  letterSpacing: 0.0,
                                  fontWeight: AppTheme.of(context)
                                      .bodyMedium
                                      .fontWeight,
                                  fontStyle:
                                      AppTheme.of(context).bodyMedium.fontStyle,
                                ),
                            maxLines: null,
                            maxLength: 12,
                            keyboardType: TextInputType.phone,
                            cursorColor: AppTheme.of(context).primary,
                            validator: _model.phoneNumberTextControllerValidator
                                .asValidator(context),
                            inputFormatters: [
                              if (!isAndroid && !isiOS)
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  return TextEditingValue(
                                    selection: newValue.selection,
                                    text: newValue.text.toCapitalization(
                                        TextCapitalization.none),
                                  );
                                }),
                              FilteringTextInputFormatter.allow(RegExp('[0-9]'))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 0.0),
                  child: AppButtonWidget(
                    onPressed: ((_model.codeCuntryTextController.text != '') &&
                            (_model.phoneNumberTextController.text != ''))
                        ? null
                        : () async {
                            final phoneNumberVal =
                                '${_model.codeCuntryTextController.text}${_model.phoneNumberTextController.text}';
                            if (phoneNumberVal.isEmpty ||
                                !phoneNumberVal.startsWith('+')) {
                              BotToast.showText(text: '전화번호는 필수이며 +로 시작해야 합니다.');
                              return;
                            }

                            // 로딩 중이면 리턴
                            final isLoading = ref.read(authLoadingProvider);
                            if (isLoading) {
                              return;
                            }

                            // 로딩 시작
                            ref.read(authLoadingProvider.notifier).setLoading(true);

                            // OTP 발송
                            final signInWithPhoneUseCase = ref.read(signInWithPhoneUseCaseProvider);
                            final result = await signInWithPhoneUseCase.sendOtp(
                              phoneNumber: phoneNumberVal,
                              eventId: const Uuid().v4(),
                            );

                            // 결과 처리
                            result.fold(
                              (failure) {
                                // 실패 처리
                                ref.read(authErrorProvider.notifier).setError(failure.message);
                                ref.read(authLoadingProvider.notifier).setLoading(false);

                                if (context.mounted) {
                                  ErrorHandler.handle(
                                    failure.message,
                                    customMessage: 'SMS 코드 발송에 실패했습니다.',
                                    context: context,
                                  );
                                }
                              },
                              (_) {
                                // 성공 처리
                                ref.read(authLoadingProvider.notifier).setLoading(false);

                                // 코드가 성공적으로 전송되면 PIN 입력 화면으로 이동
                                if (context.mounted) {
                                  context.goNamedAuth(
                                    PhonelogeinpincodeWidget.routeName,
                                    context.mounted,
                                    queryParameters: {
                                      'phoneNumberParam': serializeParam(
                                        phoneNumberVal,
                                        ParamType.String,
                                      ),
                                    }.withoutNulls,
                                    ignoreRedirect: true,
                                  );
                                }
                              },
                            );
                          },
                    text: AppLocalizations.of(context).getText(
                      'pqidvgqu' /* Send  Code */,
                    ),
                    options: AppButtonOptions(
                      width: 270.0,
                      height: 50.0,
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      iconPadding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: Colors.black,
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
                      elevation: 10.0,
                      borderSide: BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                      disabledColor: AppTheme.of(context).secondaryText,
                      disabledTextColor: Color(0xFFA7A6A6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
