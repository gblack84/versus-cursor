#!/bin/bash

# Script to update Flutter models from snake_case to camelCase
# This script will update field references in all model files

echo "Updating Flutter models to use camelCase field names..."

# List of model files to update
models=(
  "client_model.dart"
  "comments_model.dart"
  "content_comments_model.dart"
  "contents_interests_model.dart"
  "contents_likes_model.dart"
  "contents_shares_model.dart"
  "dislikes_model.dart"
  "feed_details_model.dart"
  "friends_list_model.dart"
  "group_chats_model.dart"
  "interest_model.dart"
  "jops_category_model.dart"
  "jops_name_model.dart"
  "likes_model.dart"
  "notifications_model.dart"
  "point_model.dart"
  "premium_users_model.dart"
  "rankings_model.dart"
  "searches_model.dart"
  "subscribtion_model.dart"
  "user_contents_model.dart"
  "users_model.dart"
  "votes_model.dart"
)

# Common field mappings
declare -A field_mappings=(
  ["user_id"]="userId"
  ["post_id"]="postId"
  ["created_at"]="createdAt"
  ["updated_at"]="updatedAt"
  ["created_by"]="createdBy"
  ["updated_by"]="updatedBy"
  ["is_active"]="isActive"
  ["is_deleted"]="isDeleted"
  ["display_name"]="displayName"
  ["photo_url"]="photoUrl"
  ["last_active"]="lastActive"
  ["phone_number"]="phoneNumber"
  ["created_time"]="createdTime"
  ["is_premium"]="isPremium"
  ["user_name"]="userName"
  ["comment_id"]="commentId"
  ["parent_id"]="parentId"
  ["content_id"]="contentId"
  ["content_type"]="contentType"
  ["is_read"]="isRead"
  ["notification_id"]="notificationId"
  ["notification_type"]="notificationType"
  ["target_audience"]="targetAudience"
  ["expiry_time"]="expiryTime"
  ["interaction_type"]="interactionType"
  ["source_id"]="sourceId"
  ["voted_at"]="votedAt"
  ["vote_choice"]="voteChoice"
  ["image_url"]="imageUrl"
  ["video_url"]="videoUrl"
  ["option_a"]="optionA"
  ["option_b"]="optionB"
)

for model in "${models[@]}"; do
  file="lib/backend/schema/$model"
  
  if [ -f "$file" ]; then
    echo "Processing $model..."
    
    # Check if file contains snake_case field references
    if grep -q "snapshotData\['[a-z_]*_[a-z_]*'\]" "$file"; then
      echo "  Found snake_case fields in $model"
      
      # Count fields that need updating
      count=$(grep -o "snapshotData\['[a-z_]*_[a-z_]*'\]" "$file" | wc -l)
      echo "  Found $count snake_case field references"
      
      # List unique fields
      fields=$(grep -o "snapshotData\['[a-z_]*_[a-z_]*'\]" "$file" | sed "s/snapshotData\['//" | sed "s/'\]//" | sort -u)
      echo "  Fields to update:"
      for field in $fields; do
        echo "    - $field"
      done
    else
      echo "  No snake_case fields found in $model (already migrated or uses camelCase)"
    fi
    echo ""
  fi
done

echo "Summary complete. Run the migration script to update all models."