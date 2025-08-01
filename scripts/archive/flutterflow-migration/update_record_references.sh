#!/bin/bash

# Script to update all remaining *Record references to *Model
# This completes Phase 3 of FlutterFlow remnants removal

echo "=== Updating all *Record references to *Model ==="

# Array of all Record to Model mappings
declare -a replacements=(
    "UsersRecord:UsersModel"
    "PostsRecord:PostsModel"
    "ChatsRecord:ChatsModel"
    "MessagesRecord:MessagesModel"
    "NotificationsRecord:NotificationsModel"
    "CharactersRecord:CharactersModel"
    "JopsCategoryRecord:JopsCategoryModel"
    "JopsNameRecord:JopsNameModel"
    "FriendsListRecord:FriendsListModel"
    "ImageModerationRecord:ImageModerationModel"
    "InterestRecord:InterestModel"
    "RankingsRecord:RankingsModel"
    "RankTitlesRecord:RankTitlesModel"
    "CommentsRecord:CommentsModel"
    "GroupChatsRecord:GroupChatsModel"
    "PremiumUsersRecord:PremiumUsersModel"
    "UserContentsRecord:UserContentsModel"
    "EncodingsRecord:EncodingsModel"
    "LikesRecord:LikesModel"
    "DislikesRecord:DislikesModel"
    "PointRecord:PointModel"
    "SearchesRecord:SearchesModel"
    "SearchCharacterRecord:SearchCharacterModel"
    "InterestWeightRecord:InterestWeightModel"
    "ItemCategoriesRecord:ItemCategoriesModel"
    "ItemDetailsRecord:ItemDetailsModel"
    "TransactionsRecord:TransactionsModel"
    "PurchasedItemsRecord:PurchasedItemsModel"
    "PointProductsRecord:PointProductsModel"
    "CoinProductsRecord:CoinProductsModel"
    "NotificationsSettingsRecord:NotificationsSettingsModel"
    "InterestPreferencesRecord:InterestPreferencesModel"
    "UserJopsRecord:UserJopsModel"
    "SearchUsersRecord:SearchUsersModel"
    "LatestStoriesRecord:LatestStoriesModel"
    "PersonalityTestRecord:PersonalityTestModel"
    "TestQuestionsRecord:TestQuestionsModel"
    "TestAnswersRecord:TestAnswersModel"
    "TestResultsRecord:TestResultsModel"
    "LatestAnswersRecord:LatestAnswersModel"
    "VotesRecord:VotesModel"
)

# Function to update references in a file
update_file() {
    local file=$1
    local changes_made=false
    
    for replacement in "${replacements[@]}"; do
        IFS=':' read -r old new <<< "$replacement"
        
        # Check if the file contains the old reference
        if grep -q "$old" "$file"; then
            # Update the reference
            sed -i '' "s/$old/$new/g" "$file"
            changes_made=true
            echo "  Updated: $old → $new"
        fi
    done
    
    if [ "$changes_made" = true ]; then
        echo "✓ Updated: $file"
    fi
}

# Find all Dart files in lib directory (excluding backup if exists)
echo "Finding all Dart files to update..."
files=$(find lib -name "*.dart" -type f | grep -v "backup")

total_files=$(echo "$files" | wc -l | tr -d ' ')
echo "Found $total_files Dart files to check"
echo

# Update each file
updated_count=0
for file in $files; do
    if update_file "$file"; then
        ((updated_count++))
        echo
    fi
done

echo "=== Summary ==="
echo "Total files checked: $total_files"
echo "Files updated: $updated_count"
echo
echo "✅ All *Record references have been updated to *Model"