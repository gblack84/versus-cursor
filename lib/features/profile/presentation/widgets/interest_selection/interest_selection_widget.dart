// Phase 3: Riverpod
import '/features/profile/domain/usecases/interests/update_user_interests_usecase.dart';
import '/features/profile/presentation/constants/profile_constants.dart';
import '/core_exports.dart';
import '/app/widgets/index.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/features/profile/presentation/providers/profile_providers.dart';
import '/features/profile/domain/models/user_profile.dart';
import '/app/contracts/auth_contract.dart';
import 'interest_category.dart';
import 'interest_selection_model.dart';
export 'interest_selection_model.dart';
export 'interest_category.dart';

/// Generic interest selection widget for onboarding (Riverpod)
///
/// **Clean Architecture v4.0 + Riverpod**:
/// - ✅ ConsumerStatefulWidget으로 전환
/// - ✅ profileStreamProvider 사용
/// - ✅ UpdateUserInterestsUseCase 유지
///
/// Consolidates expertise_select, hobbies_select, and agrred_select into a single generic implementation.
/// Category-specific behavior is controlled by the `category` parameter using InterestCategory enum.
///
/// **Fixes 5 bugs from duplicate code**:
/// 1. ✅ Fixed: hobbies Line 461 - Correct error message
/// 2. ✅ Fixed: hobbies Lines 540-542 - Correct field check
/// 3. ✅ Fixed: agrred Line 461 - Correct error message
/// 4. ✅ Fixed: agrred Lines 540-542 - Correct field check
/// 5. ✅ Fixed: agrred Lines 813-815 - Next button now navigates correctly
class InterestSelectionWidget extends ConsumerStatefulWidget {
  const InterestSelectionWidget({
    super.key,
    required this.category,
  });

  /// Category of interest selection (expertise, hobbies, or agrred)
  final InterestCategory category;

  @override
  ConsumerState<InterestSelectionWidget> createState() =>
      _InterestSelectionWidgetState();
}

class _InterestSelectionWidgetState extends ConsumerState<InterestSelectionWidget> {
  late InterestSelectionModel _model;
  late final UpdateUserInterestsUseCase _updateInterestsUseCase;
  // Phase 3: ProfileProvider → profileStreamProvider로 전환

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Phase 3: Riverpod - AuthContract를 통한 userId 가져오기
  String? get _userId {
    final authContract = GetIt.instance<AuthContract>();
    return authContract.getCurrentUserId();
  }

  /// Phase 3: Riverpod - profileStreamProvider를 통한 프로필 가져오기
  UserProfile? get _currentProfile {
    if (_userId == null) return null;

    final profileState = ref.read(profileStreamProvider(
      ProfileStreamParams(userId: _userId!),
    ));

    UserProfile? profile;
    profileState.when(
      loading: () => profile = null,
      error: (error, stackTrace) => profile = null,
      data: (data) => profile = data,
    );
    return profile;
  }

  /// Get the appropriate interest list based on category
  List<String> get _currentInterests {
    final user = _currentProfile;
    if (user == null) return [];

    switch (widget.category) {
      case InterestCategory.expertise:
        return user.expertise.toList();
      case InterestCategory.hobbies:
      case InterestCategory.agrred:
        return user.interests.toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InterestSelectionModel());

    // Phase 3: Riverpod - UseCase 초기화 (프로필은 profileStreamProvider가 자동 관리)
    _updateInterestsUseCase = GetIt.instance<UpdateUserInterestsUseCase>();

    _model.inputTextController ??= TextEditingController();
    _model.inputFocusNode ??= FocusNode();
    _model.inputFocusNode!.addListener(() => setState(() {}));
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
                '519xixp4' /* versus space */,
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
                                      // Phase 3: Riverpod - _currentProfile 사용
                                      text: _currentProfile?.displayName ?? '사용자',
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
                                        'lfhxure4' /* , Tell us your expertise, */,
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
                                        'wdoi0lud' /*
we'll send you better questio... */
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
                                widget.category.titleText,
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
                              controller: _model.inputTextController,
                              focusNode: _model.inputFocusNode,
                              onChanged: (_) => EasyDebounce.debounce(
                                '_model.inputTextController',
                                Duration(milliseconds: 2000),
                                () async {
                                  _model.inputTag =
                                      _model.inputTextController!.text;
                                  setState(() {});
                                },
                              ),
                              autofocus: true,
                              textCapitalization: TextCapitalization.words,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelText: widget.category.displayName,
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
                                fillColor:
                                    (_model.inputFocusNode?.hasFocus ?? false)
                                        ? AppTheme.of(context).accent1
                                        : AppTheme.of(context)
                                            .secondaryBackground,
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
                              maxLength: ProfileConstants.maxDisplayNameLength,
                              buildCounter: (context,
                                      {required currentLength,
                                      required isFocused,
                                      maxLength}) =>
                                  null,
                              cursorColor: AppTheme.of(context).primary,
                              validator: _model.inputTextControllerValidator
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
                                widget.category.subtitleText,
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
                                onPressed: (_model.inputTag != '' ? false : true)
                                    ? null
                                    : () async {
                                        // ✅ Fixed: Check correct field based on category
                                        if (_currentInterests.length >=
                                            widget.category.maxSelections) {
                                          await showDialog(
                                            context: context,
                                            builder: (alertDialogContext) {
                                              return WebViewAware(
                                                child: AlertDialog(
                                                  title: Text('\"Limit Reached\"'),
                                                  content: Text(
                                                      widget.category.maxSelectionError),
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
                                          // Phase 3: Riverpod - _userId 사용
                                          final currentUserId = _userId;
                                          if (currentUserId == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('사용자 정보를 불러올 수 없습니다')),
                                            );
                                            return;
                                          }

                                          final result = await _updateInterestsUseCase
                                              .addInterest(
                                            userId: currentUserId,
                                            interest:
                                                _model.inputTextController!.text,
                                            category:
                                                widget.category.firestoreField,
                                          );

                                          result.fold(
                                            (failure) {
                                              // Handle failure
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content:
                                                        Text(failure.message)),
                                              );
                                            },
                                            (_) {
                                              // Handle success
                                              setState(() {
                                                _model.inputTextController
                                                    ?.clear();
                                              });
                                              // Update AppState
                                              AppState().update(() {});
                                            },
                                          );
                                        }
                                      },
                                text: AppLocalizations.of(context).getText(
                                  '2l833og3' /* Add */,
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
                    // ✅ Fixed: Check correct field based on category
                    if (_currentInterests.isNotEmpty)
                      Container(
                        width: 380.0,
                        height: 20.0,
                        decoration: BoxDecoration(),
                        child: Align(
                          alignment: AlignmentDirectional(0.0, -1.0),
                          child: Text(
                            AppLocalizations.of(context).getText(
                              'qvwfh5oz' /* List. */,
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
                    // ✅ Fixed: Check correct field based on category
                    if (_currentInterests.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.of(context).secondary,
                          ),
                          child: Align(
                            alignment: AlignmentDirectional(0.0, 0.0),
                            child: Builder(
                              builder: (context) {
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
                                  children: List.generate(
                                      _currentInterests.length,
                                      (authenticatedUserIndex) {
                                    final authenticatedUserItem =
                                        _currentInterests[
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
                                                // Phase 3: Riverpod - _userId 사용
                                                final currentUserId = _userId;
                                                if (currentUserId == null) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('사용자 정보를 불러올 수 없습니다')),
                                                  );
                                                  return;
                                                }

                                                final result =
                                                    await _updateInterestsUseCase
                                                        .removeInterest(
                                                  userId: currentUserId,
                                                  interest:
                                                      authenticatedUserItem,
                                                  category: widget
                                                      .category.firestoreField,
                                                );

                                                result.fold(
                                                  (failure) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              failure.message)),
                                                    );
                                                  },
                                                  (_) {
                                                    // Update AppState
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
                                    'jvb8485b' /* Tip. */,
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
                                    'r2cx59n4' /*  Add your expertise tags (e.g.... */,
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
                                    'qdcvozij' /*

"Which of these two coding f... */
                                    ,
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                TextSpan(
                                  text: AppLocalizations.of(context).getText(
                                    'qoetb929' /*
"Which tool is easier for beg... */
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
                        onPressed: (_currentInterests.isEmpty)
                            ? null
                            : () async {
                                // ✅ Fixed: agrred now navigates correctly
                                context.pushNamed(widget.category.nextRoute);
                              },
                        text: AppLocalizations.of(context).getText(
                          'nb2efhx9' /* Next */,
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
                                  fontStyle: AppTheme.of(context)
                                      .titleSmall
                                      .fontStyle,
                                ),
                                color: Colors.white,
                                letterSpacing: 0.0,
                                fontWeight: AppTheme.of(context)
                                    .titleSmall
                                    .fontWeight,
                                fontStyle:
                                    AppTheme.of(context).titleSmall.fontStyle,
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
          ),
        ),
      ),
    );
  }
}
