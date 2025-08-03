#!/bin/bash

# Script to remove unused imports from Dart files

echo "=== Phase 4: 미사용 import 제거 ==="

# Array of files with unused imports
declare -a files_with_unused_imports=(
    "lib/pages/chat/chat_search/chat_search_widget.dart:/core/app_utils.dart"
    "lib/posts/in_put_post_image/helpers/media_box_callbacks.dart:../utils/debug_helper.dart"
    "lib/posts/in_put_post_image/in_put_post_image_widget.dart:/services/target_audience_service.dart"
    "lib/posts/in_put_post_image/services/image_upload_orchestrator.dart:/services/cloud_image_moderation_service.dart"
    "lib/posts/in_put_post_image/services/selection_result_processor.dart:media_upload_service.dart"
    "lib/posts/in_put_post_image/services/selection_result_processor.dart:../helpers/image_cache_helper.dart"
    "lib/posts/in_put_post_image/widgets/dialogs/target_audience_dialog.dart:/auth/firebase_auth/auth_util.dart"
    "lib/posts/in_put_post_image/widgets/media_selection_flow_widget.dart:/app_state.dart"
    "lib/posts/in_put_post_image/widgets/media_selection_flow_widget.dart:../services/selection_result_processor.dart"
    "lib/utils/chat_message_converter.dart:/auth/firebase_auth/auth_util.dart"
    "lib/services/chat_media_upload_service.dart:package:path/path.dart"
)

# Function to remove specific import from file
remove_import() {
    local file=$1
    local import=$2
    
    # Escape special characters for sed
    escaped_import=$(echo "$import" | sed 's/[[\.*^$()+?{|]/\\&/g')
    
    # Remove the import line
    sed -i '' "/^import.*$escaped_import/d" "$file"
}

# Process each file
for entry in "${files_with_unused_imports[@]}"; do
    IFS=':' read -r file import <<< "$entry"
    
    if [ -f "$file" ]; then
        echo "Removing unused import from: $file"
        echo "  - Removing: import '$import';"
        remove_import "$file" "$import"
    fi
done

# Also remove unnecessary imports (where elements are provided by other imports)
echo ""
echo "=== 불필요한 import 제거 (다른 import에서 이미 제공됨) ==="

# Remove unnecessary dart:ui import
sed -i '' '/^import.*dart:ui/d' lib/posts/in_put_post_image/services/selection_result_processor.dart
echo "✓ Removed dart:ui from selection_result_processor.dart"

# Remove unnecessary /core/app_utils.dart from friends_list_widget.dart
sed -i '' '/^import.*\/core\/app_utils.dart/d' lib/pages/chat/friends_list/friends_list_widget.dart
echo "✓ Removed /core/app_utils.dart from friends_list_widget.dart"

# Remove unnecessary cloud_firestore import from notification_service.dart
sed -i '' '/^import.*package:cloud_firestore\/cloud_firestore.dart/d' lib/services/notification_service.dart
echo "✓ Removed cloud_firestore from notification_service.dart"

echo ""
echo "✅ Phase 4-1: 미사용 및 불필요한 import 제거 완료"