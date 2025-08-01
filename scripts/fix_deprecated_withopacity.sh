#!/bin/bash

# Script to fix deprecated withOpacity usage

echo "=== Phase 4: deprecated withOpacity 사용 수정 ==="

# List of files with withOpacity usage
files=(
    "lib/components/chat/vote_request_message.dart"
    "lib/pages/chat/chat_list/chat_list_widget.dart"
    "lib/posts/in_put_post_image/widgets/dialogs/target_audience_dialog.dart"
)

# Function to fix withOpacity in a file
fix_withopacity() {
    local file=$1
    echo "Fixing deprecated withOpacity in: $file"
    
    # Replace .withOpacity(value) with .withValues(alpha: value)
    # This handles various formats like color.withOpacity(0.5)
    sed -i '' 's/\.withOpacity(\([0-9.]*\))/.withValues(alpha: \1)/g' "$file"
    
    echo "  ✓ Replaced withOpacity with withValues"
}

# Process each file
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        fix_withopacity "$file"
    fi
done

echo ""
echo "✅ Phase 4-2: deprecated withOpacity 수정 완료"