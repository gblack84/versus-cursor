import '/core/firebase/query_helpers.dart';
import '/core_exports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'algolia_test_model.dart';
export 'algolia_test_model.dart';

class TestalgoriaWidget extends StatefulWidget {
  const TestalgoriaWidget({super.key});
  
  static const String routeName = 'testalgoria';
  static const String routePath = '/testalgoria';

  @override
  State<TestalgoriaWidget> createState() => _TestalgoriaWidgetState();
}

class _TestalgoriaWidgetState extends State<TestalgoriaWidget> {
  late TestalgoriaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TestalgoriaModel());

    _model.textController ??= TextEditingController();
    _model.textFieldFocusNode ??= FocusNode();

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
        backgroundColor: AppTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.of(context).primary,
          automaticallyImplyLeading: false,
          title: Text(
            AppLocalizations.of(context).getText(
              'fafdx2pw' /* Page Title */,
            ),
            style: AppTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.plusJakartaSans(
                    fontWeight:
                        AppTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        AppTheme.of(context).headlineMedium.fontStyle,
                  ),
                  color: Colors.white,
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight:
                      AppTheme.of(context).headlineMedium.fontWeight,
                  fontStyle:
                      AppTheme.of(context).headlineMedium.fontStyle,
                ),
          ),
          actions: [],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Builder(
                  builder: (context) {
                    if (_model.algoliaSearchResults == null) {
                      return Center(
                        child: SizedBox(
                          width: 50.0,
                          height: 50.0,
                          child: SpinKitRing(
                            color: Color(0xFFE7E6E6),
                            size: 50.0,
                          ),
                        ),
                      );
                    }
                    final searchlist =
                        _model.algoliaSearchResults?.toList() ?? [];

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: searchlist.length,
                      itemBuilder: (context, searchlistIndex) {
                        final searchlistItem = searchlist[searchlistIndex];
                        return Container(
                          width: 100.0,
                          height: 100.0,
                          decoration: BoxDecoration(
                            color: AppTheme.of(context)
                                .secondaryBackground,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                searchlistItem.jopName,
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
                              Text(
                                searchlistItem.categoryRefB,
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
                              Text(
                                searchlistItem.categoryRefA,
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
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 30.0, 0.0, 0.0),
                  child: Container(
                    width: 200.0,
                    child: TextFormField(
                      controller: _model.textController,
                      focusNode: _model.textFieldFocusNode,
                      autofocus: false,
                      obscureText: false,
                      decoration: InputDecoration(
                        isDense: true,
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
                          '4ofzrgyp' /* TextField */,
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
                            color: Color(0x00000000),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0x00000000),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppTheme.of(context).error,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppTheme.of(context).error,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        filled: true,
                        fillColor:
                            AppTheme.of(context).secondaryBackground,
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
                            letterSpacing: 0.0,
                            fontWeight: AppTheme.of(context)
                                .bodyMedium
                                .fontWeight,
                            fontStyle: AppTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                      cursorColor: AppTheme.of(context).primaryText,
                      validator:
                          _model.textControllerValidator.asValidator(context),
                    ),
                  ),
                ),
                AppIconButton(
                  borderRadius: 8.0,
                  buttonSize: 40.0,
                  fillColor: AppTheme.of(context).primary,
                  icon: Icon(
                    Icons.arrow_back,
                    color: AppTheme.of(context).info,
                    size: 24.0,
                  ),
                  onPressed: () async {
                    setState(() => _model.algoliaSearchResults = null);
                    await JopsCategoryModel.search(
                      term: _model.textController.text,
                    )
                        .then((r) => _model.algoliaSearchResults = r)
                        .onError((_, __) => _model.algoliaSearchResults = [])
                        .whenComplete(() => setState(() {}));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
