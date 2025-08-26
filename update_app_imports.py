#!/usr/bin/env python3
"""Update import paths for App Feature migration."""

import os
import re
import sys
from pathlib import Path

# Define the project root
PROJECT_ROOT = Path("/Users/g_black/versus-cursor")

# Define import mappings for App Feature files
IMPORT_MAPPINGS = {
    # State management files
    r"import ['\"]/?app_state\.dart['\"]": "import '/app/state/app_state.dart'",
    r"import ['\"]package:versus_space/app_state\.dart['\"]": "import 'package:versus_space/app/state/app_state.dart'",
    
    # Index file
    r"import ['\"]/?index\.dart['\"]": "import '/app/widgets/index.dart'",
    r"import ['\"]package:versus_space/index\.dart['\"]": "import 'package:versus_space/app/widgets/index.dart'",
    
    # Navigation provider
    r"import ['\"]/?providers/navigation_provider\.dart['\"]": "import '/app/state/providers/navigation_provider.dart'",
    r"import ['\"]package:versus_space/providers/navigation_provider\.dart['\"]": "import 'package:versus_space/app/state/providers/navigation_provider.dart'",
    
    # Router files (existing ones)
    r"import ['\"]/?core/nav/nav\.dart['\"]": "import '/app/router/navigation/nav.dart'",
    r"import ['\"]package:versus_space/core/nav/nav\.dart['\"]": "import 'package:versus_space/app/router/navigation/nav.dart'",
    
    r"import ['\"]/?core/nav/serialization_util\.dart['\"]": "import '/app/router/navigation/serialization_util.dart'",
    r"import ['\"]package:versus_space/core/nav/serialization_util\.dart['\"]": "import 'package:versus_space/app/router/navigation/serialization_util.dart'",
}

def update_imports_in_file(file_path):
    """Update imports in a single file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        modified = False
        
        # Apply all import mappings
        for pattern, replacement in IMPORT_MAPPINGS.items():
            new_content = re.sub(pattern, replacement, content)
            if new_content != content:
                content = new_content
                modified = True
                print(f"  Updated: {pattern} -> {replacement}")
        
        # Write back if modified
        if modified:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✅ Updated: {file_path.relative_to(PROJECT_ROOT)}")
            return True
        
        return False
        
    except Exception as e:
        print(f"❌ Error processing {file_path}: {e}")
        return False

def find_dart_files():
    """Find all Dart files in the project."""
    dart_files = []
    for root, dirs, files in os.walk(PROJECT_ROOT / "lib"):
        # Skip certain directories
        if any(skip in root for skip in ['.dart_tool', 'build', '.git']):
            continue
        
        for file in files:
            if file.endswith('.dart'):
                dart_files.append(Path(root) / file)
    
    return dart_files

def main():
    print("🔄 Updating App Feature import paths...")
    print(f"Project root: {PROJECT_ROOT}")
    
    # Find all Dart files
    dart_files = find_dart_files()
    print(f"Found {len(dart_files)} Dart files")
    
    # Update imports
    updated_count = 0
    for file_path in dart_files:
        if update_imports_in_file(file_path):
            updated_count += 1
    
    print(f"\n✨ Updated {updated_count} files")
    
    # Also need to update main.dart specifically
    main_file = PROJECT_ROOT / "lib" / "main.dart"
    if main_file.exists():
        print("\n📝 Updating main.dart...")
        with open(main_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Update AppState reference
        content = re.sub(r'AppState\(\)', 'AppState()', content)
        
        # Add import if not present
        if "import 'app/state/app_state.dart';" not in content and "import '/app/state/app_state.dart';" not in content:
            # Find a good place to add the import
            content = re.sub(
                r"(import 'core_exports\.dart';)",
                r"\1\nimport 'app/state/app_state.dart';",
                content
            )
        
        with open(main_file, 'w', encoding='utf-8') as f:
            f.write(content)
        print("✅ Updated main.dart")

if __name__ == "__main__":
    main()