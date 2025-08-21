#!/usr/bin/env python3

import re
import sys

# Field mappings for UsersModel
field_mappings = {
    'display_name': 'displayName',
    'created_time': 'createdTime',
    'photo_url': 'photoUrl',
    'phone_number': 'phoneNumber',
    'is_premium_user': 'isPremiumUser',
    'is_prmium_user': 'isPremiumUser',  # Typo in original
    'anonymous_posts_count': 'anonymousPostsCount',
    'anonymous_comments_count': 'anonymousCommentsCount',
    'current_rank': 'currentRank',
    'current_title': 'currentTitle',
    'rank_history': 'rankHistory',
    'title_history': 'titleHistory',
    'rank_change_date': 'rankChangeDate',
    'title_change_date': 'titleChangeDate',
    'rank_evaluation_count': 'rankEvaluationCount',
    'is_rank_eligible': 'isRankEligible',
    'total_q_points': 'totalQPoints',
    'total_a_points': 'totalAPoints',
    'last_active_time': 'lastActiveTime',
    'date_of_birth': 'dateOfBirth',
    'active_chats': 'activeChats',
    'group_chats': 'groupChats',
}

def update_field_comments(content):
    """Update field comments from snake_case to camelCase"""
    for snake, camel in field_mappings.items():
        # Update field comments
        content = content.replace(f'// "{snake}" field.', f'// "{camel}" field.')
        content = content.replace(f'// \\"{snake}\\" field.', f'// "{camel}" field.')
    return content

def update_initialize_fields(content):
    """Update _initializeFields method to support both naming conventions"""
    lines = content.split('\n')
    new_lines = []
    in_init = False
    
    for line in lines:
        if 'void _initializeFields()' in line:
            in_init = True
            new_lines.append(line)
            new_lines.append('    // Support both snake_case (legacy) and camelCase (new) field names')
        elif in_init and line.strip().startswith('}'):
            in_init = False
            new_lines.append(line)
        elif in_init:
            # Check if this line reads from snapshotData
            match = re.search(r"snapshotData\['([^']+)'\]", line)
            if match:
                field_name = match.group(1)
                # Check if this is a snake_case field we need to update
                if field_name in field_mappings:
                    camel_name = field_mappings[field_name]
                    # Replace with fallback pattern
                    line = re.sub(
                        rf"snapshotData\['{field_name}'\]",
                        f"(snapshotData['{camel_name}'] ?? snapshotData['{field_name}'])",
                        line
                    )
            new_lines.append(line)
        else:
            new_lines.append(line)
    
    return '\n'.join(new_lines)

def update_create_function(content):
    """Update createUsersModelData function to write camelCase fields"""
    lines = content.split('\n')
    new_lines = []
    in_create = False
    
    for line in lines:
        if 'final firestoreData = mapToFirestore(' in line:
            in_create = True
        elif in_create and '}.withoutNulls' in line:
            in_create = False
        elif in_create:
            # Check if this line writes to Firestore
            match = re.search(r"'([^']+)':\s*([^,]+)", line)
            if match:
                field_name = match.group(1)
                # Check if this is a snake_case field we need to update
                if field_name in field_mappings:
                    camel_name = field_mappings[field_name]
                    line = line.replace(f"'{field_name}':", f"'{camel_name}':")
        new_lines.append(line)
    
    return '\n'.join(new_lines)

def main():
    file_path = 'lib/backend/schema/users_model.dart'
    
    # Read the file
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Apply updates
    content = update_field_comments(content)
    content = update_initialize_fields(content)
    content = update_create_function(content)
    
    # Write back
    with open(file_path, 'w') as f:
        f.write(content)
    
    print(f"Updated {file_path}")
    print(f"- Updated {len(field_mappings)} field mappings")
    print("- Added backwards compatibility support")
    print("- Updated createUsersModelData function")

if __name__ == '__main__':
    main()