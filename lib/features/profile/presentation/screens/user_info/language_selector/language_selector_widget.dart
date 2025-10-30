import '/core_exports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'language_selector_model.dart';
export 'language_selector_model.dart';

/// 언어 선택 위젯 (Riverpod)
///
/// **Clean Architecture v4.0 + Riverpod**:
/// - ✅ ConsumerStatefulWidget으로 전환
/// - ✅ LanguageSelectorModel에 ref 전달 가능
class LanguageSelectorWidget extends ConsumerStatefulWidget {
  const LanguageSelectorWidget({super.key});

  @override
  ConsumerState<LanguageSelectorWidget> createState() => _LanguageSelectorWidgetState();
}

class _LanguageSelectorWidgetState extends ConsumerState<LanguageSelectorWidget> {
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

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLanguageSelector(
      width: 200.0,
      height: 40.0,
      backgroundColor: AppTheme.of(context).secondaryBackground,
      borderColor: Colors.transparent,
      dropdownIconColor: AppTheme.of(context).secondaryText,
      borderRadius: 8.0,
      textStyle: AppTheme.of(context).bodyMedium.override(
            font: GoogleFonts.plusJakartaSans(
              fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
              fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
            ),
            letterSpacing: 0.0,
            fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
            fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
          ),
      hideFlags: true,
      flagSize: 24.0,
      flagTextGap: 8.0,
      currentLanguage: AppLocalizations.of(context).languageCode,
      languages: AppLocalizations.languages(),
      onChanged: (lang) => setAppLanguage(context, lang),
    );
  }
}
