#!/bin/bash

# Script to fix ALL remaining *Record references in schema files

echo "=== Fixing ALL remaining *Record references in schema files ==="

# Find all schema files that still contain *Record references
cd lib/backend/schema

for file in *.dart; do
    if grep -q "Record" "$file"; then
        echo "Fixing: $file"
        
        # Get the base name
        base_name=$(basename "$file" .dart | sed 's/_model$//')
        
        # Convert to PascalCase
        class_name=$(echo "$base_name" | awk -F_ '{for(i=1;i<=NF;i++){$i=toupper(substr($i,1,1))substr($i,2)}}1' | tr -d ' ')
        
        # Replace all Record references with Model
        sed -i '' "s/${class_name}Record/${class_name}Model/g" "$file"
        
        # Count replacements
        count=$(grep -c "${class_name}Model" "$file" 2>/dev/null || echo 0)
        if [ "$count" -gt 0 ]; then
            echo "  ✓ Replaced ${class_name}Record → ${class_name}Model ($count occurrences)"
        fi
    fi
done

cd ../../..

echo
echo "=== Now fixing remaining references in other files ==="

# Also fix the reference in in_put_post_image_widget.dart
if grep -q "PollDetailsRecord" lib/posts/in_put_post_image/in_put_post_image_widget.dart; then
    echo "Fixing: lib/posts/in_put_post_image/in_put_post_image_widget.dart"
    sed -i '' "s/PollDetailsRecord/PollDetailsModel/g" lib/posts/in_put_post_image/in_put_post_image_widget.dart
    echo "  ✓ Replaced PollDetailsRecord → PollDetailsModel"
fi

echo
echo "✅ All remaining *Record references have been fixed"