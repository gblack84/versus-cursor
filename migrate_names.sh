#!/bin/bash

# Find and replace in all dart files
find /Users/g_black/versus-cursor/lib -type f -name "*.dart" -exec sed -i '' \
  -e 's/FFLocalizations/AppLocalizations/g' \
  -e 's/FFAppState/AppState/g' \
  -e 's/FlutterFlowModel/AppModel/g' \
  -e 's/FlutterFlowTheme/AppTheme/g' \
  -e 's/flutter_flow_theme/app_theme/g' \
  -e 's/flutter_flow_util/app_utils/g' \
  -e 's/flutter_flow_model/app_model/g' \
  -e 's/flutter_flow_localizations/app_localizations/g' \
  -e 's/safeSetState/setState/g' \
  -e 's/\/flutter_flow\//\/core\//g' \
  {} \;

echo "Migration completed!"