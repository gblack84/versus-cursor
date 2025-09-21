#!/usr/bin/env python3
"""
JSON Output Schema Validation Tests
Tests that all agents produce valid Claude-centric JSON
"""

import json
import subprocess
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, Any, List, Tuple

# Add parent directory to path for imports
sys.path.append(str(Path(__file__).resolve().parents[1]))

class JSONSchemaValidator:
    """Validates agent JSON outputs against expected schema"""

    REQUIRED_FIELDS = [
        'agent',
        'version',
        'timestamp',
        'status',
        'data'
    ]

    OPTIONAL_FIELDS = [
        'next_action',
        'decision_hints'
    ]

    VALID_STATUSES = [
        'success',
        'fail',
        'warning',
        'no_action',
        'error',
        'partial'
    ]

    def validate_json_output(self, json_str: str, agent_name: str) -> Tuple[bool, List[str]]:
        """
        Validate JSON output from an agent
        Returns: (is_valid, list_of_errors)
        """
        errors = []

        # Parse JSON
        try:
            data = json.loads(json_str)
        except json.JSONDecodeError as e:
            return False, [f"Invalid JSON: {e}"]

        # Check required fields
        for field in self.REQUIRED_FIELDS:
            if field not in data:
                errors.append(f"Missing required field: {field}")

        # Validate agent name
        if 'agent' in data and data['agent'] != agent_name:
            errors.append(f"Agent name mismatch: expected '{agent_name}', got '{data['agent']}'")

        # Validate version format (should be semantic versioning)
        if 'version' in data:
            version = data['version']
            if not self._is_valid_version(version):
                errors.append(f"Invalid version format: {version}")

        # Validate timestamp
        if 'timestamp' in data:
            if not self._is_valid_timestamp(data['timestamp']):
                errors.append(f"Invalid timestamp format: {data['timestamp']}")

        # Validate status
        if 'status' in data and data['status'] not in self.VALID_STATUSES:
            errors.append(f"Invalid status: {data['status']}. Must be one of: {self.VALID_STATUSES}")

        # Validate data is a dict
        if 'data' in data and not isinstance(data['data'], dict):
            errors.append(f"'data' field must be a dictionary, got {type(data['data']).__name__}")

        # Validate next_action if present
        if 'next_action' in data and data['next_action']:
            next_errors = self._validate_next_action(data['next_action'])
            errors.extend(next_errors)

        # Validate decision_hints if present
        if 'decision_hints' in data and not isinstance(data['decision_hints'], dict):
            errors.append(f"'decision_hints' must be a dictionary, got {type(data['decision_hints']).__name__}")

        return len(errors) == 0, errors

    def _is_valid_version(self, version: str) -> bool:
        """Check if version follows semantic versioning"""
        parts = version.split('.')
        if len(parts) != 3:
            return False
        try:
            for part in parts:
                int(part)
            return True
        except ValueError:
            return False

    def _is_valid_timestamp(self, timestamp: str) -> bool:
        """Check if timestamp is valid ISO format"""
        try:
            datetime.fromisoformat(timestamp)
            return True
        except:
            return False

    def _validate_next_action(self, next_action: Dict) -> List[str]:
        """Validate next_action structure"""
        errors = []
        required = ['recommended_agent', 'priority', 'reason']

        if not isinstance(next_action, dict):
            errors.append("'next_action' must be a dictionary")
            return errors

        for field in required:
            if field not in next_action:
                errors.append(f"'next_action' missing required field: {field}")

        if 'priority' in next_action:
            valid_priorities = ['critical', 'high', 'medium', 'low']
            if next_action['priority'] not in valid_priorities:
                errors.append(f"Invalid priority: {next_action['priority']}. Must be one of: {valid_priorities}")

        return errors


class AgentTester:
    """Tests individual agents for JSON output"""

    def __init__(self):
        self.validator = JSONSchemaValidator()
        self.root_dir = Path(__file__).resolve().parents[1]
        self.results = []

    def test_agent(self, agent_name: str, test_commands: List[str]) -> bool:
        """Test an agent with multiple commands"""
        print(f"\n{'='*60}")
        print(f"Testing Agent: {agent_name}")
        print(f"{'='*60}")

        all_passed = True

        for cmd in test_commands:
            print(f"\nCommand: {cmd}")
            result = self._run_command(cmd)

            if result['success']:
                # Look for JSON output in stdout
                json_output = self._extract_json(result['stdout'])

                # If not in stdout, try reading from file
                if not json_output:
                    json_output = self._try_read_json_file(agent_name)
                    if json_output:
                        print(f"   (JSON read from file)")

                if json_output:
                    is_valid, errors = self.validator.validate_json_output(json_output, agent_name)

                    if is_valid:
                        print(f"✅ Valid JSON output")
                        self._print_json_summary(json.loads(json_output))
                    else:
                        print(f"❌ Invalid JSON output:")
                        for error in errors:
                            print(f"   - {error}")
                        all_passed = False
                else:
                    print(f"⚠️  No JSON output found")
                    all_passed = False
            else:
                print(f"❌ Command failed: {result['error']}")
                all_passed = False

        self.results.append({
            'agent': agent_name,
            'passed': all_passed
        })

        return all_passed

    def _run_command(self, cmd: str) -> Dict[str, Any]:
        """Run a command and capture output"""
        try:
            result = subprocess.run(
                cmd,
                shell=True,
                capture_output=True,
                text=True,
                cwd=self.root_dir,
                timeout=30
            )

            return {
                'success': result.returncode == 0,
                'stdout': result.stdout,
                'stderr': result.stderr,
                'error': result.stderr if result.returncode != 0 else None
            }
        except subprocess.TimeoutExpired:
            return {
                'success': False,
                'stdout': '',
                'stderr': '',
                'error': 'Command timed out'
            }
        except Exception as e:
            return {
                'success': False,
                'stdout': '',
                'stderr': '',
                'error': str(e)
            }

    def _extract_json(self, text: str) -> str:
        """Extract JSON output from text or try reading from file"""
        lines = text.split('\n')

        # First try to extract from stdout
        json_start = -1
        json_end = -1
        brace_count = 0

        for i, line in enumerate(lines):
            if line.strip().startswith('{'):
                if json_start == -1:
                    json_start = i
                    brace_count = 0

                brace_count += line.count('{') - line.count('}')

                if brace_count == 0:
                    json_end = i
                    break
            elif json_start != -1:
                brace_count += line.count('{') - line.count('}')
                if brace_count == 0:
                    json_end = i
                    break

        if json_start != -1 and json_end != -1:
            json_lines = lines[json_start:json_end+1]
            return '\n'.join(json_lines)

        return None

    def _try_read_json_file(self, agent_name: str) -> str:
        """Try to read JSON from reports directory"""
        # Map agent names to their JSON file patterns
        file_mappings = {
            'build-sentinel': 'build_sentinel.json',
            'inventory-scout': 'inventory_scout.json',
            'import-guardian': 'import_guardian.json',
            'code-surgeon': 'code_surgeon.json',
            'di-binder': 'di_binder.json',
            'repo-mover': 'repo_mover.json',
            'router-splitter': 'router_splitter.json',
            'struct-weaver': 'struct_weaver.json'
        }

        json_file = file_mappings.get(agent_name)
        if json_file:
            json_path = self.root_dir / 'reports' / json_file
            if json_path.exists():
                try:
                    return json_path.read_text(encoding='utf-8')
                except Exception:
                    pass

        return None

    def _print_json_summary(self, data: Dict):
        """Print a summary of the JSON output"""
        print(f"   Agent: {data.get('agent')}")
        print(f"   Version: {data.get('version')}")
        print(f"   Status: {data.get('status')}")
        if 'next_action' in data and data['next_action']:
            print(f"   Next Action: {data['next_action'].get('recommended_agent')}")
        if 'decision_hints' in data:
            hints = data.get('decision_hints', {})
            if hints:
                print(f"   Decision Hints: {list(hints.keys())}")

    def print_summary(self):
        """Print test summary"""
        print(f"\n{'='*60}")
        print("TEST SUMMARY")
        print(f"{'='*60}")

        passed = sum(1 for r in self.results if r['passed'])
        total = len(self.results)

        for result in self.results:
            status = "✅" if result['passed'] else "❌"
            print(f"{status} {result['agent']}")

        print(f"\nPassed: {passed}/{total}")

        if passed == total:
            print("\n🎉 All agents produce valid JSON!")
        else:
            print("\n⚠️  Some agents need fixes")

        return passed == total


def main():
    """Run all agent tests"""
    tester = AgentTester()

    # Define test commands for each agent
    agent_tests = [
        ('build-sentinel', [
            'bash build_sentinel.sh quick',
            # 'bash build_sentinel.sh analyze'  # Skip - no test directory
        ]),

        ('inventory-scout', [
            'python3 inventory_scout.py --scope auth --depth 3 --output stdout',
            'python3 inventory_scout.py --scope all --output stdout'
        ]),

        ('import-guardian', [
            'python3 import_guardian.py --scope auth --mode detect --output stdout',
            'python3 import_guardian.py --scope posts --mode detect --output stdout'
        ]),

        ('code-surgeon', [
            # Required --map argument for symbol mapping
            'python3 code_surgeon.py --file lib/app/state/app_state.dart --map "AppState->lib/features/auth/domain/models/auth_state.dart" --mode detect --output stdout',
        ]),

        ('di-binder', [
            # Required --port and --adapter arguments
            'python3 di_binder.py --feature auth --port lib/features/auth/domain/repositories/auth_repository.dart --adapter lib/features/auth/data/repositories/auth_repository_impl.dart --mode detect --output stdout',
        ]),

        ('repo-mover', [
            'python3 repo_mover.py --feature auth --mode dry-run --output stdout',
            'python3 repo_mover.py --feature posts --mode dry-run --include repositories --output stdout'
        ]),

        ('router-splitter', [
            'python3 router_splitter.py --scope all --mode detect --output stdout',
            'python3 router_splitter.py --features auth,posts --mode detect --output stdout'
        ]),

        ('struct-weaver', [
            'python3 struct_weaver.py --task mapper --mode detect --output stdout',
            'python3 struct_weaver.py --task state --mode detect --output stdout'
        ])
    ]

    # Run tests for each agent
    for agent_name, commands in agent_tests:
        tester.test_agent(agent_name, commands)

    # Print summary
    all_passed = tester.print_summary()

    # Exit with appropriate code
    sys.exit(0 if all_passed else 1)


if __name__ == "__main__":
    main()