#!/usr/bin/env python3
"""
Add --output stdout support to all Python tools
"""

import re
from pathlib import Path

def add_stdout_support(file_path: Path) -> bool:
    """Add stdout output support to a Python tool"""

    content = file_path.read_text(encoding="utf-8")
    modified = False

    # Skip if already has --output argument
    if "--output" in content:
        print(f"  ✓ {file_path.name} already has --output support")
        return False

    # Pattern 1: Add --output argument to argparse
    argparse_pattern = r'(p\.add_argument\([^)]+\)\n)([\s]*)(return p\.parse_args\(\))'
    if re.search(argparse_pattern, content):
        replacement = r'\1\2p.add_argument("--output", choices=["file", "stdout", "both"], default="file",\n\2                   help="Output destination: file (default), stdout, or both")\n\2\3'
        content = re.sub(argparse_pattern, replacement, content)
        modified = True

    # Pattern 2: Modify JSON write to support stdout
    # Look for patterns like: (REPORTS / "xxx.json").write_text(json.dumps(...))
    json_write_pattern = r'(\(REPORTS / [^)]+\.json[^)]*\)\.write_text\([\s\n]*)(json\.dumps\([^)]+(?:\),[\s\n]*[^)]+)*\))'

    matches = list(re.finditer(json_write_pattern, content))

    for match in reversed(matches):  # Process in reverse to maintain positions
        if "claude_output" in match.group(0) or "claude_output" in content[max(0, match.start()-200):match.end()]:
            # This is likely the Claude output section
            indent = "    "  # Default indent

            # Find the indentation level
            lines_before = content[:match.start()].split('\n')
            if lines_before:
                last_line = lines_before[-1]
                indent = re.match(r'^(\s*)', last_line).group(1)

            # Create the new code block
            new_code = f"""{indent}# Save or output Claude-centric JSON based on args
{indent}json_output = {match.group(2)}

{indent}if args.output in ["file", "both"]:
{indent}    {match.group(1)}{match.group(2)}"""

            # Add stdout output
            new_code += f"""

{indent}if args.output in ["stdout", "both"]:
{indent}    print(json_output)
{indent}    sys.stdout.flush()"""

            content = content[:match.start()] + new_code + content[match.end():]
            modified = True
            break  # Only modify the first Claude output occurrence

    # Pattern 3: Conditionally print status messages
    status_pattern = r'print\(["\'].*(?:done|complete|finished).*["\']\)'
    if re.search(status_pattern, content, re.IGNORECASE):
        # Wrap status messages with if args.output == "file":
        def wrap_status(match):
            indent_match = re.match(r'^(\s*)', match.group(0))
            indent = indent_match.group(1) if indent_match else ""
            return f'{indent}if args.output == "file":\n{indent}    {match.group(0).strip()}'

        content = re.sub(r'^(\s*)' + status_pattern.replace('print\\(', 'print\\('), wrap_status, content, flags=re.MULTILINE)
        modified = True

    if modified:
        file_path.write_text(content, encoding="utf-8")
        print(f"  ✅ Updated {file_path.name}")
        return True

    return False


def main():
    """Add stdout support to all Python tools"""

    tools_dir = Path(__file__).parent

    # List of Python tools to update
    tools = [
        "import_guardian.py",
        "code_surgeon.py",
        "di_binder.py",
        "repo_mover.py",
        "router_splitter.py",
        "struct_weaver.py"
    ]

    print("Adding stdout output support to Python tools...")
    print("=" * 60)

    updated_count = 0
    for tool_name in tools:
        tool_path = tools_dir / tool_name

        if not tool_path.exists():
            print(f"  ⚠️  {tool_name} not found")
            continue

        if add_stdout_support(tool_path):
            updated_count += 1

    print("=" * 60)
    print(f"Updated {updated_count} tools")

    # Special case: build_sentinel_json.py needs different handling
    build_sentinel_json = tools_dir / "build_sentinel_json.py"
    if build_sentinel_json.exists():
        content = build_sentinel_json.read_text(encoding="utf-8")

        if "--output" not in content:
            # Add the argument
            content = content.replace(
                'parser.add_argument("--dart-version"',
                'parser.add_argument("--output", choices=["file", "stdout", "both"], default="stdout",\n                        help="Output destination")\n    parser.add_argument("--dart-version"'
            )

            # Modify the output logic
            content = content.replace(
                'print(json.dumps(output, indent=2))',
                '''json_output = json.dumps(output, indent=2)

    if args.output in ["stdout", "both"]:
        print(json_output)
        sys.stdout.flush()

    if args.output in ["file", "both"]:
        output_file = Path("reports/build_sentinel.json")
        output_file.parent.mkdir(exist_ok=True)
        output_file.write_text(json_output, encoding="utf-8")'''
            )

            build_sentinel_json.write_text(content, encoding="utf-8")
            print(f"  ✅ Updated build_sentinel_json.py")
            updated_count += 1

    print(f"\nTotal: {updated_count} tools updated")


if __name__ == "__main__":
    main()