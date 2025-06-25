import '/flutter_flow/flutter_flow_language_selector.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'language_selector_model.dart';
export 'language_selector_model.dart';

class LanguageSelectorWidget extends StatefulWidget {
  const LanguageSelectorWidget({super.key});

  @override
  State<LanguageSelectorWidget> createState() => _LanguageSelectorWidgetState();
}

class _LanguageSelectorWidgetState extends State<LanguageSelectorWidget> {
  late LanguageSelectorModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => LanguageSelectorModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterFlowLanguageSelector(
      width: 200.0,
      height: 40.0,
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      borderColor: Colors.transparent,
      dropdownIconColor: FlutterFlowTheme.of(context).secondaryText,
      borderRadius: 8.0,
      textStyle: FlutterFlowTheme.of(context).bodyMedium.override(
            fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
            letterSpacing: 0.0,
            useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
          ),
      hideFlags: true,
      flagSize: 24.0,
      flagTextGap: 8.0,
      currentLanguage: FFLocalizations.of(context).languageCode,
      languages: FFLocalizations.languages(),
      onChanged: (lang) => setAppLanguage(context, lang),
    );
  }
}
