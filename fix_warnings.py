#!/usr/bin/env python3
"""
Flutter 프로젝트의 경고 수정 스크립트
1. backend/schema 파일들에서 사용하지 않는 /app/widgets/index.dart import 제거
2. core_exports.dart에 이미 포함된 중복 import 제거
"""

import os
import re

def remove_unused_imports(file_path, unused_imports):
    """파일에서 사용하지 않는 import 제거"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        for import_line in unused_imports:
            # import 문 제거
            pattern = re.compile(rf'^{re.escape(import_line)}\n', re.MULTILINE)
            content = pattern.sub('', content)
        
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        return False
    except Exception as e:
        print(f"  ✗ 에러 발생: {e}")
        return False

def fix_backend_schema_imports():
    """backend/schema 파일들에서 사용하지 않는 index.dart import 제거"""
    print("🔧 Backend 스키마 파일들에서 사용하지 않는 import 제거...")
    
    schema_dir = '/Users/g_black/versus-cursor/lib/backend/schema'
    files_to_fix = [
        'characters_model.dart', 'chat_history_model.dart', 'chat_interest_jops_model.dart',
        'chats_model.dart', 'client_model.dart', 'comments_model.dart',
        'content_comments_model.dart', 'contents_interests_model.dart', 'contents_likes_model.dart',
        'contents_shares_model.dart', 'dislikes_model.dart', 'encodings_model.dart',
        'feed_details_model.dart', 'friends_list_model.dart', 'group_chats_model.dart',
        'group_messages_model.dart', 'images_model.dart', 'interest_model.dart',
        'jops_category_model.dart', 'jops_name_model.dart', 'likes_model.dart',
        'messages_model.dart', 'notification_model.dart', 'notifications_model.dart',
        'point_model.dart', 'poll_details_model.dart', 'posts_model.dart',
        'premium_users_model.dart', 'ranked_posts_model.dart', 'rankings_model.dart',
        'searches_model.dart', 'settings_model.dart', 'transactions_model.dart',
        'user_contents_model.dart', 'users_model.dart', 'video_model.dart',
        'vote_expansion_requests_model.dart', 'votecounts_model.dart', 'votes_model.dart',
        'weights_model.dart'
    ]
    
    updated_count = 0
    for file_name in files_to_fix:
        file_path = os.path.join(schema_dir, file_name)
        if os.path.exists(file_path):
            if remove_unused_imports(file_path, ["import '/app/widgets/index.dart';"]):
                print(f"  ✓ {file_name}")
                updated_count += 1
        else:
            print(f"  ⚠️  {file_name} 파일을 찾을 수 없음")
    
    print(f"  → {updated_count}개 파일 수정 완료\n")
    return updated_count

def fix_unnecessary_imports():
    """core_exports.dart에 이미 포함된 중복 import 제거"""
    print("🔧 중복 import 제거...")
    
    files_to_fix = [
        ('/Users/g_black/versus-cursor/lib/backend/api_requests/api_manager.dart', 
         ["import 'dart:typed_data';"]),
        ('/Users/g_black/versus-cursor/lib/backend/schema/image_moderation_model.dart',
         ["import 'package:cloud_firestore/cloud_firestore.dart';"]),
        ('/Users/g_black/versus-cursor/lib/features/common/presentation/widgets/alertempty_widget.dart',
         ["import '/app/state/app_state.dart';"]),
        ('/Users/g_black/versus-cursor/lib/features/common/presentation/widgets/app_choice_chips.dart',
         ["import '/features/common/domain/models/form_field_controller.dart';"]),
        ('/Users/g_black/versus-cursor/lib/features/common/presentation/widgets/videoplay_widget.dart',
         ["import '/app/state/app_state.dart';"]),
        ('/Users/g_black/versus-cursor/lib/main.dart',
         ["import 'app/state/app_state.dart';"]),
        ('/Users/g_black/versus-cursor/lib/pages/notifications_list/notifications_list_widget.dart',
         ["import 'package:intl/intl.dart';"]),
        ('/Users/g_black/versus-cursor/lib/pages/pro_image_editor/pro_image_editor_page.dart',
         ["import '/app/state/app_state.dart';"]),
        ('/Users/g_black/versus-cursor/lib/pages/user_info_input/user_info_input_widget.dart',
         ["import '/app/state/app_state.dart';"]),
        ('/Users/g_black/versus-cursor/lib/posts/in_put_post_image/in_put_post_image_widget.dart',
         ["import '/app/state/app_state.dart';"]),
        ('/Users/g_black/versus-cursor/lib/posts/in_put_post_image/services/image_editor_callback_handler.dart',
         ["import 'dart:typed_data';", "import '/app/state/app_state.dart';"]),
        ('/Users/g_black/versus-cursor/lib/posts/in_put_post_image/services/validation_service.dart',
         ["import '/app/state/app_state.dart';"]),
        ('/Users/g_black/versus-cursor/lib/services/global_notification_manager.dart',
         ["import 'dart:convert';"])
    ]
    
    updated_count = 0
    for file_path, imports_to_remove in files_to_fix:
        if os.path.exists(file_path):
            if remove_unused_imports(file_path, imports_to_remove):
                print(f"  ✓ {os.path.basename(file_path)}")
                updated_count += 1
        else:
            print(f"  ⚠️  {file_path} 파일을 찾을 수 없음")
    
    print(f"  → {updated_count}개 파일 수정 완료\n")
    return updated_count

def fix_override_warning():
    """vote_card_message.dart의 override 경고 수정"""
    print("🔧 Override 경고 수정...")
    
    file_path = '/Users/g_black/versus-cursor/lib/components/chat/vote_card_message.dart'
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # @override 어노테이션 제거 (line 71 근처)
        # customBottomWidget getter의 @override 제거
        pattern = re.compile(r'(\s*)@override\s*\n(\s*Widget\? get customBottomWidget)', re.MULTILINE)
        new_content = pattern.sub(r'\1// @override removed - not overriding any parent getter\n\2', content)
        
        if new_content != content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"  ✓ {os.path.basename(file_path)}")
            return 1
        else:
            print(f"  ⚠️  이미 수정됨 또는 패턴을 찾을 수 없음")
            return 0
    except Exception as e:
        print(f"  ✗ 에러 발생: {e}")
        return 0

def main():
    print("=" * 60)
    print("Flutter 경고 수정 스크립트")
    print("=" * 60 + "\n")
    
    total_fixed = 0
    
    # 1. Backend 스키마 파일들의 unused import 제거
    total_fixed += fix_backend_schema_imports()
    
    # 2. 중복 import 제거
    total_fixed += fix_unnecessary_imports()
    
    # 3. Override 경고 수정
    total_fixed += fix_override_warning()
    
    print("=" * 60)
    print(f"✨ 총 {total_fixed}개 파일 수정 완료!")
    print("=" * 60)
    
    print("\n💡 다음 명령으로 결과를 확인하세요:")
    print("   flutter analyze")

if __name__ == "__main__":
    main()