// Phase 2: Clean Architecture - ProfileProvider만 사용
import '/features/profile/presentation/providers/profile_provider.dart';
import '/features/profile/domain/usecases/profile/update_user_profile_usecase.dart';
import '/features/profile/presentation/constants/validation_rules.dart';
import '/features/profile/presentation/constants/profile_constants.dart';
import 'package:get_it/get_it.dart';
import '/core_exports.dart';
import '/features/profile/presentation/screens/user_info/character_detail/character_detail_page_widget.dart';
import '/features/profile/presentation/screens/user_info/language_selector/language_selector_widget.dart';
import '/app/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'user_info_input_model.dart';
export 'user_info_input_model.dart';

class UserInfoInputWidget extends StatefulWidget {
  const UserInfoInputWidget({super.key});

  static String routeName = 'user_info_input';
  static String routePath = '/userInfoInput';

  @override
  State<UserInfoInputWidget> createState() => _UserInfoInputWidgetState();
}

class _UserInfoInputWidgetState extends State<UserInfoInputWidget> {
  late UserInfoInputModel _model;
  late final ProfileProvider _profileProvider;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => UserInfoInputModel());

    // Phase 4.5 하이브리드: ProfileProvider 인스턴스 가져오기
    _profileProvider = GetIt.instance<ProfileProvider>();

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // Phase 2: Clean Architecture - ProfileProvider의 loadCurrentUserProfile() 사용
      await _profileProvider.loadCurrentUserProfile();
      _model.userDocument = _profileProvider.profile;

      setState(() {});
    });

    _model.displayNameTextController ??= TextEditingController();
    _model.displayNameFocusNode ??= FocusNode();
    _model.displayNameFocusNode!.addListener(() => setState(() {}));
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
          automaticallyImplyLeading: false,
          title: Align(
            alignment: AlignmentDirectional(-1.0, 0.0),
            child: Text(
              AppLocalizations.of(context).getText(
                'jemkmkgu' /* Versus space */,
              ),
              textAlign: TextAlign.end,
              style: AppTheme.of(context).headlineSmall.override(
                    fontFamily: 'SourGummy',
                    color: Colors.black,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          actions: [
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
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
          top: true,
          child: Form(
            key: _model.formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Align(
                          alignment: AlignmentDirectional(0.0, -1.0),
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: 770.0,
                            ),
                            decoration: BoxDecoration(),
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  16.0, 5.0, 16.0, 0.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: AlignmentDirectional(0.0, 0.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 10.0, 0.0, 0.0),
                                      child: Container(
                                        width: 155.0,
                                        height: 155.0,
                                        decoration: BoxDecoration(
                                          color: AppTheme.of(context)
                                              .secondaryBackground,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Stack(
                                          children: [
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.0, 0.0),
                                              child: InkWell(
                                                splashColor:
                                                    Colors.transparent,
                                                focusColor:
                                                    Colors.transparent,
                                                hoverColor:
                                                    Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  await showModalBottomSheet(
                                                    isScrollControlled: true,
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    enableDrag: false,
                                                    context: context,
                                                    builder: (context) {
                                                      return WebViewAware(
                                                        child:
                                                            GestureDetector(
                                                          onTap: () {
                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus();
                                                            FocusManager
                                                                .instance
                                                                .primaryFocus
                                                                ?.unfocus();
                                                          },
                                                          child: Padding(
                                                            padding: MediaQuery
                                                                .viewInsetsOf(
                                                                    context),
                                                            child: Container(
                                                              height: 450.0,
                                                              child:
                                                                  CharacterDetailPageWidget(),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ).then((value) =>
                                                      setState(() {}));
                                                },
                                                child: Container(
                                                  width: 200.0,
                                                  height: 200.0,
                                                  clipBehavior:
                                                      Clip.antiAlias,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Image.network(
                                                    valueOrDefault<String>(
                                                      // Phase 2: Clean Architecture - ProfileProvider 사용
                                                      _profileProvider.profile?.photoUrl,
                                                      'https://firebasestorage.googleapis.com/v0/b/versus-space-1lwwiw.appspot.com/o/characters%2Fdefault%2Fdefaultimage.jpg?alt=media&token=b485c8ad-c393-4ec7-bc1a-c1c3c93ec4ec',
                                                    ),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Image.asset(
                                                      'assets/images/error_image.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: AlignmentDirectional(
                                                  0.92, 1.04),
                                              child: FaIcon(
                                                FontAwesomeIcons.camera,
                                                color: Color(0xFF14181B),
                                                size: 30.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Phase 2: Clean Architecture - ProfileProvider 사용
                                  if ((_profileProvider.profile?.email ?? '') != '')
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Text(
                                        _profileProvider.profile?.email ?? '',
                                        style: AppTheme.of(context)
                                            .titleMedium
                                            .override(
                                              font: GoogleFonts.plusJakartaSans(
                                                fontWeight: AppTheme.of(context)
                                                    .titleMedium
                                                    .fontWeight,
                                                fontStyle: AppTheme.of(context)
                                                    .titleMedium
                                                    .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight: AppTheme.of(context)
                                                  .titleMedium
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                      ),
                                    ),
                                  // Phase 2: Clean Architecture - ProfileProvider 사용
                                  if ((_profileProvider.profile?.phoneNumber ?? '') != '')
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Text(
                                        _profileProvider.profile?.phoneNumber ?? '',
                                        style: AppTheme.of(context)
                                            .titleMedium
                                            .override(
                                              font:
                                                  GoogleFonts.plusJakartaSans(
                                                fontWeight:
                                                    AppTheme.of(context)
                                                        .titleMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    AppTheme.of(context)
                                                        .titleMedium
                                                        .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight: AppTheme.of(context)
                                                  .titleMedium
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .titleMedium
                                                  .fontStyle,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                      ),
                                    ),
                                  // Phase 2: Clean Architecture - ProfileProvider 사용
                                  if (_profileProvider.profile?.createdTime != null)
                                    Align(
                                      alignment: AlignmentDirectional(0.0, 0.0),
                                      child: Text(
                                        dateTimeFormat(
                                          "yMMMd",
                                          _profileProvider.profile!.createdTime!,
                                          locale: AppLocalizations.of(context)
                                              .languageCode,
                                        ),
                                        style: AppTheme.of(context)
                                            .titleSmall
                                            .override(
                                              font: GoogleFonts.plusJakartaSans(
                                                fontWeight: AppTheme.of(context)
                                                    .titleSmall
                                                    .fontWeight,
                                                fontStyle: AppTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight: AppTheme.of(context)
                                                  .titleSmall
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .titleSmall
                                                  .fontStyle,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                      ),
                                    ),
                                  Divider(
                                    thickness: 2.0,
                                    color: Color(0xFFB9B3B3),
                                  ),
                                  Align(
                                    alignment: AlignmentDirectional(0.0, -1.0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 10.0),
                                      child: Text(
                                        AppLocalizations.of(context).getText(
                                          'plunfug5' /* Information */,
                                        ),
                                        style: AppTheme.of(context)
                                            .bodyLarge
                                            .override(
                                              font: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w600,
                                                fontStyle: AppTheme.of(context)
                                                    .bodyLarge
                                                    .fontStyle,
                                              ),
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w600,
                                              fontStyle: AppTheme.of(context)
                                                  .bodyLarge
                                                  .fontStyle,
                                            ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context).getText(
                                      '9bvrno9z' /* Display Name */,
                                    ),
                                    style: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
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
                                  Container(
                                    decoration: BoxDecoration(),
                                    child: TextFormField(
                                      controller:
                                          _model.displayNameTextController,
                                      focusNode: _model.displayNameFocusNode,
                                      autofocus: true,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      obscureText: false,
                                      decoration: InputDecoration(
                                        labelText: AppLocalizations.of(context)
                                            .getText(
                                          'm58rgdkp' /* Display name* */,
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
                                              color: AppTheme.of(context)
                                                  .secondaryText,
                                              letterSpacing: 0.0,
                                              fontWeight: AppTheme.of(context)
                                                  .headlineMedium
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .headlineMedium
                                                  .fontStyle,
                                            ),
                                        hintStyle: AppTheme.of(context)
                                            .labelMedium
                                            .override(
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
                                        errorStyle: AppTheme.of(context)
                                            .bodyMedium
                                            .override(
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
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppTheme.of(context).primary,
                                            width: 2.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppTheme.of(context).error,
                                            width: 2.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppTheme.of(context).error,
                                            width: 2.0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                        filled: true,
                                        fillColor: (_model.displayNameFocusNode
                                                    ?.hasFocus ??
                                                false)
                                            ? AppTheme.of(context).accent1
                                            : AppTheme.of(context)
                                                .secondaryBackground,
                                        contentPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                16.0, 20.0, 16.0, 20.0),
                                      ),
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
                                            letterSpacing: 0.0,
                                            fontWeight: AppTheme.of(context)
                                                .headlineMedium
                                                .fontWeight,
                                            fontStyle: AppTheme.of(context)
                                                .headlineMedium
                                                .fontStyle,
                                          ),
                                      maxLength: ProfileConstants.maxDisplayNameLength,
                                      cursorColor: AppTheme.of(context).primary,
                                      validator: ValidationRules.validateDisplayName,
                                      inputFormatters: [
                                        if (!isAndroid && !isiOS)
                                          TextInputFormatter.withFunction(
                                              (oldValue, newValue) {
                                            return TextEditingValue(
                                              selection: newValue.selection,
                                              text: newValue.text
                                                  .toCapitalization(
                                                      TextCapitalization.words),
                                            );
                                          }),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    AppLocalizations.of(context).getText(
                                      'pqx67cpq' /* Language */,
                                    ),
                                    style: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
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
                                  Container(
                                    height: 40.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: wrapWithModel(
                                      model: _model.languageSelectorModel,
                                      updateCallback: () => setState(() {}),
                                      child: LanguageSelectorWidget(),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(),
                                  ),
                                  Text(
                                    AppLocalizations.of(context).getText(
                                      'e2mae9l3' /* Gender */,
                                    ),
                                    style: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
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
                                  AppChoiceChips(
                                    options: [
                                      ChipData(
                                          AppLocalizations.of(context).getText(
                                        'fy3unoj5' /* Female */,
                                      )),
                                      ChipData(
                                          AppLocalizations.of(context).getText(
                                        'sjv4inta' /* Male */,
                                      )),
                                      ChipData(
                                          AppLocalizations.of(context).getText(
                                        'tmsnqk92' /* Other */,
                                      ))
                                    ],
                                    onChanged: (val) => setState(() => _model
                                        .choiceChipsValue = val?.firstOrNull),
                                    selectedChipStyle: ChipStyle(
                                      backgroundColor:
                                          AppTheme.of(context).accent2,
                                      textStyle: AppTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                            ),
                                            color: AppTheme.of(context)
                                                .primaryText,
                                            letterSpacing: 0.0,
                                            fontWeight: AppTheme.of(context)
                                                .bodyMedium
                                                .fontWeight,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                      iconColor:
                                          AppTheme.of(context).primaryText,
                                      iconSize: 18.0,
                                      elevation: 0.0,
                                      borderColor:
                                          AppTheme.of(context).secondary,
                                      borderWidth: 2.0,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    unselectedChipStyle: ChipStyle(
                                      backgroundColor: AppTheme.of(context)
                                          .primaryBackground,
                                      textStyle: AppTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                              fontStyle: AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                            ),
                                            color: AppTheme.of(context)
                                                .secondaryText,
                                            letterSpacing: 0.0,
                                            fontWeight: AppTheme.of(context)
                                                .bodyMedium
                                                .fontWeight,
                                            fontStyle: AppTheme.of(context)
                                                .bodyMedium
                                                .fontStyle,
                                          ),
                                      iconColor:
                                          AppTheme.of(context).secondaryText,
                                      iconSize: 18.0,
                                      elevation: 0.0,
                                      borderColor:
                                          AppTheme.of(context).alternate,
                                      borderWidth: 2.0,
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    chipSpacing: 12.0,
                                    rowSpacing: 12.0,
                                    multiselect: false,
                                    alignment: WrapAlignment.start,
                                    controller:
                                        _model.choiceChipsValueController ??=
                                            FormFieldController<List<String>>(
                                      [],
                                    ),
                                    wrapped: true,
                                  ),
                                  Divider(
                                    thickness: 2.0,
                                    color: Color(0xFFB9B3B3),
                                  ),
                                  Container(
                                    width: 404.15,
                                    height: 100.0,
                                    decoration: BoxDecoration(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Container(
                                          width: 379.57,
                                          height: 39.4,
                                          decoration: BoxDecoration(),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 1.0),
                                                child: Theme(
                                                  data: ThemeData(
                                                    checkboxTheme:
                                                        CheckboxThemeData(
                                                      visualDensity:
                                                          VisualDensity.compact,
                                                      materialTapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
                                                      ),
                                                    ),
                                                    unselectedWidgetColor:
                                                        Color(0xFFFF0000),
                                                  ),
                                                  child: Checkbox(
                                                    value:
                                                        _model.checkboxValue ??=
                                                            _model.agreed13old,
                                                    onChanged:
                                                        (newValue) async {
                                                      setState(() =>
                                                          _model.checkboxValue =
                                                              newValue!);
                                                    },
                                                    side: BorderSide(
                                                      width: 2,
                                                      color: Color(0xFFFF0000),
                                                    ),
                                                    activeColor:
                                                        Color(0xFFFFC8C8),
                                                    checkColor:
                                                        Color(0xFFFF6904),
                                                  ),
                                                ),
                                              ),
                                              RichText(
                                                textScaler:
                                                    MediaQuery.of(context)
                                                        .textScaler,
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: AppLocalizations.of(
                                                              context)
                                                          .getText(
                                                        'cn54l9bj' /* I confirm that I am at least  */,
                                                      ),
                                                      style:
                                                          AppTheme.of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .plusJakartaSans(
                                                                  fontWeight: AppTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                                  fontStyle: AppTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                fontSize: 18.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: AppTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                                fontStyle: AppTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                    ),
                                                    TextSpan(
                                                      text: AppLocalizations.of(
                                                              context)
                                                          .getText(
                                                        'e8bfoncc' /*  13 */,
                                                      ),
                                                      style:
                                                          AppTheme.of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .plusJakartaSans(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontStyle: AppTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                color: Color(
                                                                    0xFFE8303B),
                                                                fontSize: 20.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontStyle: AppTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                                decoration:
                                                                    TextDecoration
                                                                        .underline,
                                                              ),
                                                    ),
                                                    TextSpan(
                                                      text: AppLocalizations.of(
                                                              context)
                                                          .getText(
                                                        'eqbsqvs2' /*   years old. */,
                                                      ),
                                                      style:
                                                          AppTheme.of(context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .plusJakartaSans(
                                                                  fontWeight: AppTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                                  fontStyle: AppTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                fontSize: 18.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: AppTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                                fontStyle: AppTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                    )
                                                  ],
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
                                            ],
                                          ),
                                        ),
                                        Text(
                                          AppLocalizations.of(context).getText(
                                            '4165t2cs' /* If you are under 13, providing... */,
                                          ),
                                          textAlign: TextAlign.center,
                                          style: AppTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontWeight:
                                                      AppTheme.of(context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      AppTheme.of(context)
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
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsetsDirectional.fromSTEB(
                                        16.0, 12.0, 16.0, 0.0),
                                    child: AppButtonWidget(
                                      onPressed: !_model.agreed13old
                                          ? null
                                          : () async {
                                              if (_model.formKey.currentState ==
                                                      null ||
                                                  !_model.formKey.currentState!
                                                      .validate()) {
                                                return;
                                              }

                                              // Phase 1: UseCase를 통한 프로필 업데이트
                                              if (_model.userDocument != null) {
                                                final updateProfileUseCase =
                                                    GetIt.instance<
                                                        UpdateUserProfileUseCase>();

                                                // UserProfile은 immutable이므로 copyWith()로 변경
                                                final updatedProfile = _model.userDocument!.copyWith(
                                                  displayName: _model.displayNameTextController.text,
                                                  gender: _model.choiceChipsValue,
                                                  language: AppLocalizations.of(context).languageCode,
                                                );

                                                // UseCase 실행
                                                final result =
                                                    await updateProfileUseCase
                                                        .execute(updatedProfile);

                                                result.fold(
                                                  (failure) {
                                                    // 에러 처리
                                                    ScaffoldMessenger.of(context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(failure
                                                              .message)),
                                                    );
                                                  },
                                                  (_) {
                                                    // Phase 2: Clean Architecture - 프로필 새로고침 및 다음 페이지로 이동
                                                    _profileProvider.loadCurrentUserProfile();
                                                    context.pushNamed(
                                                        ExpertiseSelectWidget
                                                            .routeName);
                                                  },
                                                );
                                              }
                                            },
                                      text:
                                          AppLocalizations.of(context).getText(
                                        'k84ryt65' /* Continue */,
                                      ),
                                      options: AppButtonOptions(
                                        width: double.infinity,
                                        height: 48.0,
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            24.0, 0.0, 24.0, 0.0),
                                        iconPadding:
                                            EdgeInsetsDirectional.fromSTEB(
                                                0.0, 0.0, 0.0, 0.0),
                                        color: Colors.black,
                                        textStyle: AppTheme.of(context)
                                            .titleSmall
                                            .override(
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
                                        elevation: 3.0,
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                          width: 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                ]
                                    .divide(SizedBox(height: 12.0))
                                    .addToEnd(SizedBox(height: 32.0)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
