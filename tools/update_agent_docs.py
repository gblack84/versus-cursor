#!/usr/bin/env python3
"""
Update all agent .md files to be Claude-centric
Phase 2 of the refactoring plan
"""

import re
from pathlib import Path

# Agents directory
AGENTS_DIR = Path("/Users/g_black/versus-cursor/.claude/agents")

# Replacement patterns
REPLACEMENTS = [
    # General pattern: Change "You are X, an expert..." to "You are X, that generates structured data for Claude..."
    (
        r"You are (\w+), an? (?:expert |specialized |elite )?(.+?)(?:specialist|assembler|scanner|runner|extractor|splitter|weaver)(.+?)\. Your (?:mission|role|expertise|focus) is to (.+?)\.",
        r"You are \1, a \2 tool that generates structured data for Claude. You \4 and produce JSON output for orchestration without user interaction."
    ),

    # Remove user-facing language
    (
        r"(?:report|suggest|recommend|tell|inform|notify|explain) (?:to )?the user",
        r"generate structured data for Claude"
    ),

    # Change output format references
    (
        r"provide (?:a )?(?:clear |detailed )?(?:summary|report|explanation)",
        r"generate JSON data"
    ),

    # Update next steps references
    (
        r"next[_\s]?steps:\s*\n(?:\s*-[^\n]+\n)+",
        r"""next_action:
  recommended_agent: "agent-name"
  params: {}
  priority: "high"
  reason: "Automated decision"
"""
    ),

    # Update best practices
    (
        r"(?:Focus on |Provide |Generate )(?:practical |clear |actionable )(?:advice|recommendations|guidance)",
        r"Generate only structured JSON data"
    ),

    # Mission statements
    (
        r"Your (?:mission|goal|objective) is to (?:help|assist|guide|support) (?:users|developers)",
        r"You generate structured JSON data for Claude to process"
    )
]

def update_agent_file(file_path: Path):
    """Update a single agent .md file"""
    if not file_path.exists():
        print(f"  ⚠️  File not found: {file_path}")
        return False

    try:
        content = file_path.read_text(encoding='utf-8')
        original = content

        # Apply replacements
        for pattern, replacement in REPLACEMENTS:
            content = re.sub(pattern, replacement, content, flags=re.MULTILINE | re.IGNORECASE)

        # Additional specific replacements
        # Add JSON output emphasis
        if "reports/" in content and ".json" not in content:
            content = re.sub(
                r"(reports/[\w_]+)\.(?:yml|yaml|txt)",
                r"\1.json",
                content
            )

        # Save if changed
        if content != original:
            file_path.write_text(content, encoding='utf-8')
            return True
        return False

    except Exception as e:
        print(f"  ❌ Error processing {file_path.name}: {e}")
        return False

def main():
    """Process all agent .md files"""
    print("🔄 Phase 2: Updating agent documents to Claude-centric format\n")

    # List of agents to update
    agents = [
        "inventory-scout.md",
        "build-sentinel.md",
        "code-surgeon.md",
        "import-guardian.md",
        "di-binder.md",
        "repo-mover.md",
        "router-splitter.md",
        "struct-weaver.md"
    ]

    updated = 0
    for agent_file in agents:
        file_path = AGENTS_DIR / agent_file
        print(f"📝 Processing {agent_file}...")

        if update_agent_file(file_path):
            print(f"  ✅ Updated successfully")
            updated += 1
        else:
            print(f"  ⏭️  No changes needed or already updated")

    print(f"\n✨ Phase 2 Summary:")
    print(f"  - Total files processed: {len(agents)}")
    print(f"  - Files updated: {updated}")
    print(f"  - Files unchanged: {len(agents) - updated}")

    # Additional manual edits needed notification
    if updated > 0:
        print("\n⚠️  Note: Some files may need manual review for:")
        print("  - Complex output format sections")
        print("  - Specific example updates")
        print("  - Workflow descriptions")

if __name__ == "__main__":
    main()