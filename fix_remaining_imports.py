#!/usr/bin/env python3
"""Fix remaining import issues after App Feature migration."""

import os
import re
from pathlib import Path

# Define the project root
PROJECT_ROOT = Path("/Users/g_black/versus-cursor")

# Files to fix
FILES_TO_FIX = [
    "lib/features/common/presentation/widgets/alertempty_widget.dart",
    "lib/features/common/presentation/widgets/videoplay_widget.dart",
    "lib/features/common/utils/app_utils.dart",
    "lib/pages/pro_image_editor/pro_image_editor_page.dart",
    "lib/pages/user_info_input/user_info_input_widget.dart",
    "lib/posts/in_put_post_image/in_put_post_image_widget.dart",
]

def fix_app_utils():
    """Fix app_utils.dart specifically."""
    file_path = PROJECT_ROOT / "lib/features/common/utils/app_utils.dart"
    if not file_path.exists():
        print(f"❌ File not found: {file_path}")
        return
    
    print(f"🔧 Fixing: {file_path.name}")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix the import path
    content = re.sub(
        r"import ['\"]/?app_state\.dart['\"];?",
        "import '/app/state/app_state.dart';",
        content
    )
    
    # Fix MyApp.of() calls to use VersusApp instead
    content = re.sub(
        r"MyApp\.of\(context\)",
        "VersusApp.of(context)",
        content
    )
    
    # Add import for VersusApp if needed
    if "VersusApp" in content and "import '/app/app.dart'" not in content:
        # Add after core_exports import
        content = re.sub(
            r"(import ['\"]/?core_exports\.dart['\"];)",
            r"\1\nimport '/app/app.dart';",
            content
        )
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"  ✅ Fixed {file_path.name}")

def add_app_state_import(file_path):
    """Add AppState import to files that need it."""
    print(f"🔧 Checking: {file_path.name}")
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check if AppState is used
    if 'AppState' not in content:
        print(f"  - Doesn't use AppState")
        return False
    
    # Check if import already exists
    if "import '/app/state/app_state.dart'" in content or \
       "import 'package:versus_space/app/state/app_state.dart'" in content:
        print(f"  ✓ Already has AppState import")
        return False
    
    # Add import after core_exports
    if "import '/core_exports.dart'" in content:
        content = re.sub(
            r"(import ['\"]/?core_exports\.dart['\"];)",
            r"\1\nimport '/app/state/app_state.dart';",
            content
        )
    else:
        # Add at the beginning of imports
        import_match = re.search(r'^import\s+', content, re.MULTILINE)
        if import_match:
            insert_pos = import_match.start()
            content = (
                content[:insert_pos] + 
                "import '/app/state/app_state.dart';\n" +
                content[insert_pos:]
            )
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"  ✅ Added AppState import to {file_path.name}")
    return True

def main():
    print("🔧 Fixing remaining import issues...")
    print()
    
    # Fix app_utils.dart first
    fix_app_utils()
    print()
    
    # Fix other files
    for file_rel_path in FILES_TO_FIX:
        if "app_utils" in file_rel_path:
            continue  # Already handled
        
        file_path = PROJECT_ROOT / file_rel_path
        if not file_path.exists():
            print(f"❌ File not found: {file_rel_path}")
            continue
        
        add_app_state_import(file_path)
        print()
    
    print("✨ Done!")

if __name__ == "__main__":
    main()