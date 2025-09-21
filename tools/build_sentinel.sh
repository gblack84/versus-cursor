#!/usr/bin/env bash
# BuildSentinel - Flutter/Dart quality gate runner with filtering support
set -euo pipefail

# Get project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Parameters
MODE="${1:-quick}"           # quick(analyze only) | full(all) | test(tests only)
PLATFORM="${2:-none}"        # none | android | ios | web | macos | windows | linux
TEST_PATH="${3:-.}"          # Test path filter (default: current directory)
TEST_TAGS="${4:-}"           # Test tags filter (optional)

# Setup directories
REPORTS="reports"
LOGS="logs"
mkdir -p "$REPORTS" "$LOGS"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}[BuildSentinel] Starting validation${NC}"
echo "Mode: $MODE, Platform: $PLATFORM, Test Path: $TEST_PATH, Tags: $TEST_TAGS"

# Record Flutter/Dart versions
echo "[BuildSentinel] Recording versions..." | tee "$LOGS/build_sentinel.log"
flutter --version >> "$LOGS/build_sentinel.log" 2>&1 || true
dart --version >> "$LOGS/build_sentinel.log" 2>&1 || true

# Initialize counters
TOTAL_ERRORS=0
TOTAL_WARNINGS=0
TEST_FAILURES=0

# Phase 1: Flutter pub get (if needed)
if [[ ! -d ".dart_tool" ]] || [[ ! -f "pubspec.lock" ]]; then
  echo -e "${YELLOW}[pub get] Running flutter pub get...${NC}"
  flutter pub get >> "$LOGS/build_sentinel.log" 2>&1 || true
fi

# Phase 2: Analyze (unless test-only mode)
if [[ "$MODE" != "test" ]]; then
  echo -e "${GREEN}[analyze] Running flutter analyze...${NC}" | tee "$REPORTS/analyze.txt"

  # Run analyze and capture output
  if flutter analyze 2>&1 | tee -a "$REPORTS/analyze.txt"; then
    echo -e "${GREEN}✓ Analysis passed${NC}"
  else
    echo -e "${RED}✗ Analysis failed${NC}"

    # Parse errors and warnings
    TOTAL_ERRORS=$(grep -c "error •" "$REPORTS/analyze.txt" || echo "0")
    TOTAL_WARNINGS=$(grep -c "warning •" "$REPORTS/analyze.txt" || echo "0")

    echo "Found $TOTAL_ERRORS errors, $TOTAL_WARNINGS warnings"
  fi
fi

# Phase 3: Test (unless quick mode)
if [[ "$MODE" != "quick" ]]; then
  echo -e "${GREEN}[test] Running flutter test...${NC}" | tee "$REPORTS/test.txt"

  # Build test command with filters
  TEST_CMD="flutter test"

  # Add path filter if not default
  if [[ "$TEST_PATH" != "." ]]; then
    TEST_CMD="$TEST_CMD $TEST_PATH"
  fi

  # Add tags filter if specified
  if [[ -n "$TEST_TAGS" ]]; then
    TEST_CMD="$TEST_CMD --tags $TEST_TAGS"
  fi

  # Add reporter for better parsing
  TEST_CMD="$TEST_CMD --reporter expanded"

  echo "Executing: $TEST_CMD"

  # Run tests and capture output
  if $TEST_CMD 2>&1 | tee -a "$REPORTS/test.txt"; then
    echo -e "${GREEN}✓ All tests passed${NC}"
  else
    echo -e "${RED}✗ Some tests failed${NC}"

    # Parse test failures
    echo "Extracting failure details..."
    grep -E "(FAILED:|✗|Error:)" "$REPORTS/test.txt" > "$REPORTS/failures.txt" || true

    # Count failures
    TEST_FAILURES=$(grep -c "FAILED:" "$REPORTS/test.txt" 2>/dev/null || echo "0")
    echo "Found $TEST_FAILURES test failures"

    # Extract failing test files
    echo -e "\n${YELLOW}Failed test files:${NC}"
    grep -E "test/.*\.dart.*FAILED" "$REPORTS/test.txt" | \
      sed -E 's/.*\((test[^)]+)\).*/\1/' | \
      sort -u | \
      tee "$REPORTS/failed_test_files.txt"
  fi
fi

# Phase 4: Build (if platform specified)
if [[ "$PLATFORM" != "none" ]]; then
  echo -e "${GREEN}[build] Building for $PLATFORM...${NC}" | tee "$REPORTS/build_${PLATFORM}.txt"

  BUILD_CMD="flutter build $PLATFORM"

  # Add debug flag for faster builds during migration
  if [[ "$PLATFORM" == "web" ]] || [[ "$PLATFORM" == "android" ]] || [[ "$PLATFORM" == "ios" ]]; then
    BUILD_CMD="$BUILD_CMD --debug"
  fi

  echo "Executing: $BUILD_CMD"

  if $BUILD_CMD 2>&1 | tee -a "$REPORTS/build_${PLATFORM}.txt"; then
    echo -e "${GREEN}✓ Build succeeded${NC}"
    BUILD_STATUS="success"
  else
    echo -e "${RED}✗ Build failed${NC}"
    BUILD_STATUS="fail"

    # Extract build error
    tail -20 "$REPORTS/build_${PLATFORM}.txt" > "$REPORTS/build_error_summary.txt"
  fi
else
  BUILD_STATUS="skipped"
fi

# Phase 5: Generate summary outputs
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
FLUTTER_VERSION=$(flutter --version | head -1 | cut -d' ' -f2 || echo "unknown")
DART_VERSION=$(dart --version | cut -d' ' -f4 || echo "unknown")

# Determine overall status
if [[ $TOTAL_ERRORS -gt 0 ]] || [[ $TEST_FAILURES -gt 0 ]] || [[ "$BUILD_STATUS" == "fail" ]]; then
  OVERALL_STATUS="fail"
else
  OVERALL_STATUS="success"
fi

# JSON output will be generated at the end of the script

# Generate YAML output for backward compatibility
cat > "$REPORTS/build_sentinel.yml" <<EOF
agent: build-sentinel
status: $OVERALL_STATUS
timestamp: $TIMESTAMP
flutter_version: $FLUTTER_VERSION
dart_version: $DART_VERSION
mode: $MODE
parameters:
  platform: $PLATFORM
  test_path: $TEST_PATH
  test_tags: $TEST_TAGS
analysis:
  errors: $TOTAL_ERRORS
  warnings: $TOTAL_WARNINGS
tests:
  failures: $TEST_FAILURES
build:
  platform: $PLATFORM
  status: $BUILD_STATUS
outputs:
  - reports/analyze.txt
  - reports/test.txt
  - reports/failures.txt
  - reports/build_${PLATFORM}.txt
next_steps:
EOF

# Generate next steps based on failures
if [[ $TOTAL_ERRORS -gt 0 ]]; then
  echo "  - \"Fix $TOTAL_ERRORS analysis errors (see reports/analyze.txt)\"" >> "$REPORTS/build_sentinel.yml"
fi

if [[ $TEST_FAILURES -gt 0 ]]; then
  echo "  - \"Fix $TEST_FAILURES failing tests (see reports/failures.txt)\"" >> "$REPORTS/build_sentinel.yml"
  echo "  - \"Re-run specific tests: flutter test \$(cat reports/failed_test_files.txt | head -1)\"" >> "$REPORTS/build_sentinel.yml"
fi

if [[ "$BUILD_STATUS" == "fail" ]]; then
  echo "  - \"Fix build errors for $PLATFORM (see reports/build_${PLATFORM}.txt)\"" >> "$REPORTS/build_sentinel.yml"
fi

if [[ "$OVERALL_STATUS" == "success" ]]; then
  echo "  - \"All checks passed! Ready for next migration step\"" >> "$REPORTS/build_sentinel.yml"
fi

# Final output
echo ""
if [[ "$OVERALL_STATUS" == "success" ]]; then
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${GREEN}✓ BuildSentinel: ALL CHECKS PASSED${NC}"
  echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
else
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${RED}✗ BuildSentinel: VALIDATION FAILED${NC}"
  echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo ""
  echo "Summary:"
  [[ $TOTAL_ERRORS -gt 0 ]] && echo "  - Analysis errors: $TOTAL_ERRORS"
  [[ $TOTAL_WARNINGS -gt 0 ]] && echo "  - Analysis warnings: $TOTAL_WARNINGS"
  [[ $TEST_FAILURES -gt 0 ]] && echo "  - Test failures: $TEST_FAILURES"
  [[ "$BUILD_STATUS" == "fail" ]] && echo "  - Build: FAILED"
fi

echo ""
echo "Full report: reports/build_sentinel.yml"

# Generate Claude-centric JSON output
python3 "$PROJECT_ROOT/tools/build_sentinel_json.py" \
  --status "$OVERALL_STATUS" \
  --errors "$TOTAL_ERRORS" \
  --warnings "$TOTAL_WARNINGS" \
  --failures "$TEST_FAILURES" \
  --mode "$MODE" \
  --platform "$PLATFORM" \
  --flutter-version "$FLUTTER_VERSION" \
  --dart-version "$DART_VERSION"

# Exit with appropriate code
if [[ "$OVERALL_STATUS" == "success" ]]; then
  exit 0
else
  exit 1
fi