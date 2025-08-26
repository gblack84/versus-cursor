#!/usr/bin/env python3
"""Fix missing Firestore imports in backend/schema files."""

import os
import re
from pathlib import Path

# Define the project root
PROJECT_ROOT = Path("/Users/g_black/versus-cursor")
SCHEMA_DIR = PROJECT_ROOT / "lib" / "backend" / "schema"

def needs_firestore_import(content):
    """Check if file needs Firestore import."""
    firestore_types = [
        'CollectionReference',
        'DocumentReference',
        'DocumentSnapshot',
        'Query',
        'QuerySnapshot',
        'FirebaseFirestore',
        'FieldValue',
        'Timestamp'
    ]
    
    for type_name in firestore_types:
        if type_name in content:
            return True
    return False

def has_firestore_import(content):
    """Check if file already has cloud_firestore import."""
    patterns = [
        r"import\s+['\"]package:cloud_firestore/cloud_firestore\.dart['\"]",
        r"import\s+'package:cloud_firestore/cloud_firestore\.dart'",
        r'import\s+"package:cloud_firestore/cloud_firestore\.dart"'
    ]
    
    for pattern in patterns:
        if re.search(pattern, content):
            return True
    return False

def add_firestore_import(file_path):
    """Add cloud_firestore import to a file if needed."""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check if import is needed
        if not needs_firestore_import(content):
            return False
            
        # Check if import already exists
        if has_firestore_import(content):
            print(f"  ✓ Already has import: {file_path.name}")
            return False
        
        # Find the right place to add the import
        # Look for the first import statement
        import_match = re.search(r'^import\s+', content, re.MULTILINE)
        
        if import_match:
            # Add cloud_firestore import at the beginning of imports
            insert_pos = import_match.start()
            new_content = (
                content[:insert_pos] + 
                "import 'package:cloud_firestore/cloud_firestore.dart';\n" +
                content[insert_pos:]
            )
        else:
            # If no imports found, add at the beginning of file
            new_content = "import 'package:cloud_firestore/cloud_firestore.dart';\n\n" + content
        
        # Write back the modified content
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print(f"  ✅ Added import to: {file_path.name}")
        return True
        
    except Exception as e:
        print(f"  ❌ Error processing {file_path.name}: {e}")
        return False

def main():
    print("🔧 Fixing Firestore imports in backend/schema files...")
    print(f"Schema directory: {SCHEMA_DIR}")
    
    if not SCHEMA_DIR.exists():
        print("❌ Schema directory not found!")
        return
    
    # Find all Dart files in schema directory
    dart_files = list(SCHEMA_DIR.glob("*.dart"))
    print(f"Found {len(dart_files)} Dart files in schema directory")
    
    # Process each file
    fixed_count = 0
    already_ok_count = 0
    
    for file_path in dart_files:
        print(f"\nProcessing: {file_path.name}")
        
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        if needs_firestore_import(content):
            if has_firestore_import(content):
                print(f"  ✓ Already has import")
                already_ok_count += 1
            else:
                if add_firestore_import(file_path):
                    fixed_count += 1
        else:
            print(f"  - Doesn't need Firestore import")
    
    print(f"\n✨ Summary:")
    print(f"  - Fixed: {fixed_count} files")
    print(f"  - Already OK: {already_ok_count} files")
    print(f"  - Total processed: {len(dart_files)} files")
    
    # Special handling for messages_model.dart - it uses Timestamp
    messages_file = SCHEMA_DIR / "messages_model.dart"
    if messages_file.exists():
        print(f"\n🔍 Checking messages_model.dart for Timestamp usage...")
        with open(messages_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        if 'Timestamp' in content and not has_firestore_import(content):
            print("  Adding cloud_firestore import for Timestamp...")
            add_firestore_import(messages_file)

if __name__ == "__main__":
    main()