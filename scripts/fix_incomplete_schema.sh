#!/bin/bash

# Script to fix incomplete schema refactoring
# Fixes files where class name is *Record but constructor is *Model

echo "=== Fixing incomplete schema refactoring ==="

# Files to fix
files=(
    "lib/backend/schema/contents_shares_model.dart"
    "lib/backend/schema/feed_details_model.dart"
    "lib/backend/schema/video_model.dart"
    "lib/backend/schema/settings_model.dart"
    "lib/backend/schema/notification_model.dart"
    "lib/backend/schema/poll_details_model.dart"
    "lib/backend/schema/images_model.dart"
    "lib/backend/schema/vote_expansion_requests_model.dart"
    "lib/backend/schema/votecounts_model.dart"
    "lib/backend/schema/weights_model.dart"
)

# Fix each file
for file in "${files[@]}"; do
    echo "Fixing: $file"
    
    # Extract the base name for the class
    base_name=$(basename "$file" .dart | sed 's/_model$//')
    
    # Convert to PascalCase for class name
    class_name=$(echo "$base_name" | awk -F_ '{for(i=1;i<=NF;i++){$i=toupper(substr($i,1,1))substr($i,2)}}1' | tr -d ' ')
    
    # Replace class declaration
    sed -i '' "s/class ${class_name}Record extends/class ${class_name}Model extends/g" "$file"
    
    # Replace all remaining Record references with Model
    sed -i '' "s/${class_name}Record/${class_name}Model/g" "$file"
    
    echo "  ✓ Changed ${class_name}Record → ${class_name}Model"
done

echo
echo "✅ All incomplete schema files have been fixed"