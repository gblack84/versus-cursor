#!/usr/bin/env python3
"""build_sentinel.sh의 JSON 출력 헬퍼"""
import json
import argparse
from datetime import datetime
from pathlib import Path

def main():
    parser = argparse.ArgumentParser(description="Generate JSON output for build_sentinel")
    parser.add_argument('--status', required=True, help="Overall status (success/fail)")
    parser.add_argument('--errors', type=int, default=0, help="Total analysis errors")
    parser.add_argument('--warnings', type=int, default=0, help="Total analysis warnings")
    parser.add_argument('--failures', type=int, default=0, help="Total test failures")
    parser.add_argument('--mode', default='quick', help="Execution mode")
    parser.add_argument('--platform', default='none', help="Build platform")
    parser.add_argument('--flutter-version', default='unknown', help="Flutter version")
    parser.add_argument('--dart-version', default='unknown', help="Dart version")
    args = parser.parse_args()

    # 에러 타입 분석
    analyze_txt = Path('reports/analyze.txt')
    import_errors = 0
    di_errors = 0
    undefined_errors = 0

    if analyze_txt.exists():
        content = analyze_txt.read_text()
        # 더 정확한 패턴 매칭
        import_errors = len([line for line in content.split('\n') if 'import' in line and 'error' in line])
        di_errors = len([line for line in content.split('\n') if 'GetIt' in line or 'dependency injection' in line.lower()])
        undefined_errors = len([line for line in content.split('\n') if 'undefined' in line and 'error' in line])

    output = {
        "agent": "build-sentinel",
        "version": "1.0.0",
        "timestamp": datetime.now().isoformat(),
        "status": args.status,
        "data": {
            "mode": args.mode,
            "platform": args.platform,
            "flutter_version": args.flutter_version,
            "dart_version": args.dart_version,
            "analysis": {
                "errors": args.errors,
                "warnings": args.warnings,
                "by_type": {
                    "import": import_errors,
                    "di": di_errors,
                    "undefined": undefined_errors
                }
            },
            "test": {
                "failures": args.failures
            }
        },
        "next_action": determine_next_action(args.status, import_errors, di_errors, args.failures),
        "decision_hints": {
            "has_import_errors": import_errors > 0,
            "has_di_errors": di_errors > 0,
            "has_test_failures": args.failures > 0,
            "needs_rollback": args.status == "fail",
            "error_priority": get_error_priority(import_errors, di_errors, args.failures)
        }
    }

    # JSON 파일 저장
    output_file = Path('reports/build_sentinel.json')
    output_file.parent.mkdir(parents=True, exist_ok=True)

    with open(output_file, 'w') as f:
        json.dump(output, f, indent=2)

    print(f"JSON output saved to {output_file}")

def determine_next_action(status, import_errors, di_errors, test_failures):
    """다음 실행할 에이전트 결정"""
    if status == "success":
        return None

    # 우선순위: import 에러 > DI 에러 > 테스트 실패
    if import_errors > 0:
        return {
            "recommended_agent": "import-guardian",
            "params": {
                "mode": "fix",
                "scope": "all"
            },
            "priority": "high",
            "reason": f"{import_errors} import errors detected - need to fix import paths"
        }

    if di_errors > 0:
        return {
            "recommended_agent": "di-binder",
            "params": {
                "mode": "detect",
                "feature": "all"
            },
            "priority": "high",
            "reason": f"{di_errors} dependency injection errors detected"
        }

    if test_failures > 0:
        return {
            "recommended_agent": "code-surgeon",
            "params": {
                "mode": "analyze"
            },
            "priority": "medium",
            "reason": f"{test_failures} test failures - may need code refactoring"
        }

    # 다른 에러들
    return {
        "recommended_agent": "inventory-scout",
        "params": {
            "scope": "all",
            "depth": 5
        },
        "priority": "low",
        "reason": "General failure - need full analysis"
    }

def get_error_priority(import_errors, di_errors, test_failures):
    """에러 우선순위 결정"""
    if import_errors > 0:
        return "import"
    elif di_errors > 0:
        return "di"
    elif test_failures > 0:
        return "test"
    else:
        return "none"

if __name__ == "__main__":
    main()