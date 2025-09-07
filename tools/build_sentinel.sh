#!/usr/bin/env bash
# BuildSentinel - analyze/test/(optional)build 결과 요약
set -euo pipefail

MODE="${1:-quick}"   # quick|full
PLATFORM="${2:-none}" # none|web|android|ios
REPORTS="reports"; LOGS="logs"
mkdir -p "$REPORTS" "$LOGS"

echo "[BuildSentinel] flutter --version" | tee "$LOGS/build_sentinel.log" || true
flutter --version >> "$LOGS/build_sentinel.log" 2>&1 || true

echo "[analyze]" | tee "$REPORTS/analyze.txt"
flutter analyze | tee -a "$REPORTS/analyze.txt" || true

if [[ "$MODE" != "analyze-only" ]]; then
  echo "[test]" | tee "$REPORTS/test.txt"
  flutter test --reporter expanded | tee -a "$REPORTS/test.txt" || true
fi

if [[ "$PLATFORM" != "none" ]]; then
  echo "[build $PLATFORM]" | tee "$REPORTS/build_${PLATFORM}.txt"
  flutter build "$PLATFORM" --debug | tee -a "$REPORTS/build_${PLATFORM}.txt" || true
fi

cat > "$REPORTS/build_sentinel.yml" <<EOF
agent: build-sentinel
mode: $MODE
platform: $PLATFORM
outputs:
  - reports/analyze.txt
  - reports/test.txt
  - reports/build_${PLATFORM}.txt
next_steps:
  - "Review analyze/test logs"
  - "If failing, run targeted tests: flutter test <path>"
EOF

echo "[BuildSentinel] Done -> reports/build_sentinel.yml"
