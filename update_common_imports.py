#!/usr/bin/env python3
"""
Common Feature 마이그레이션을 위한 Import 경로 업데이트 스크립트
"""

import os
import re
from pathlib import Path

# 프로젝트 루트 경로
PROJECT_ROOT = Path("/Users/g_black/versus-cursor")
LIB_PATH = PROJECT_ROOT / "lib"

# Import 매핑 정의
IMPORT_MAPPINGS = {
    # Utils -> Common/data/services
    r"import '/?utils/app_logger\.dart'": "import '/features/common/data/services/app_logger.dart'",
    r"import '/?utils/file_logger\.dart'": "import '/features/common/data/services/file_logger.dart'",
    r"import '/?utils/content_filter\.dart'": "import '/features/common/data/services/content_filter.dart'",
    r"import '/?utils/responsive_breakpoints\.dart'": "import '/features/common/data/services/responsive_breakpoints.dart'",
    
    # Shared services
    r"import '/?shared/services/unified_box_calculator\.dart'": "import '/features/common/data/services/unified_box_calculator.dart'",
    
    # Shared constants
    r"import '/?shared/constants/layout_constants\.dart'": "import '/features/common/domain/models/layout_constants.dart'",
    
    # Widgets
    r"import '/?widgets/highlighted_text_field\.dart'": "import '/features/common/presentation/widgets/highlighted_text_field.dart'",
    
    # Components -> Common/presentation/widgets
    r"import '/?components/unified_video_player\.dart'": "import '/features/common/presentation/widgets/unified_video_player.dart'",
    r"import '/?components/youtube_player_widget\.dart'": "import '/features/common/presentation/widgets/youtube_player_widget.dart'",
    r"import '/?components/alertempty_widget\.dart'": "import '/features/common/presentation/widgets/alertempty_widget.dart'",
    r"import '/?components/editviedo_widget\.dart'": "import '/features/common/presentation/widgets/editviedo_widget.dart'",
    r"import '/?components/videoplay_widget\.dart'": "import '/features/common/presentation/widgets/videoplay_widget.dart'",
    
    # Components models -> Common/domain/models
    r"import '/?components/alertempty_model\.dart'": "import '/features/common/domain/models/alertempty_model.dart'",
    r"import '/?components/editviedo_model\.dart'": "import '/features/common/domain/models/editviedo_model.dart'",
    r"import '/?components/videoplay_model\.dart'": "import '/features/common/domain/models/videoplay_model.dart'",
    
    # Actions
    r"import '/?actions/actions\.dart'": "import '/features/common/presentation/actions/global_actions.dart'",
    
    # Design System
    r"import '/?design_system/design_system\.dart'": "import '/features/common/presentation/design_system/design_system.dart'",
    r"import '/?design_system/tokens/versus_colors\.dart'": "import '/features/common/presentation/design_system/tokens/versus_colors.dart'",
    r"import '/?design_system/tokens/versus_spacing\.dart'": "import '/features/common/presentation/design_system/tokens/versus_spacing.dart'",
    r"import '/?design_system/tokens/versus_text_styles\.dart'": "import '/features/common/presentation/design_system/tokens/versus_text_styles.dart'",
    r"import '/?design_system/tokens/versus_radius\.dart'": "import '/features/common/presentation/design_system/tokens/versus_radius.dart'",
    r"import '/?design_system/tokens/versus_icons\.dart'": "import '/features/common/presentation/design_system/tokens/versus_icons.dart'",
    r"import '/?design_system/tokens/versus_icon_data\.dart'": "import '/features/common/presentation/design_system/tokens/versus_icon_data.dart'",
    r"import '/?design_system/tokens/versus_tokens\.dart'": "import '/features/common/presentation/design_system/tokens/versus_tokens.dart'",
    r"import '/?design_system/components/versus_button\.dart'": "import '/features/common/presentation/design_system/components/versus_button.dart'",
    r"import '/?design_system/components/versus_dialog\.dart'": "import '/features/common/presentation/design_system/components/versus_dialog.dart'",
    r"import '/?design_system/components/versus_text_field\.dart'": "import '/features/common/presentation/design_system/components/versus_text_field.dart'",
    r"import '/?design_system/components/versus_icon\.dart'": "import '/features/common/presentation/design_system/components/versus_icon.dart'",
    r"import '/?design_system/components/versus_components\.dart'": "import '/features/common/presentation/design_system/components/versus_components.dart'",
    r"import '/?design_system/utils/icon_style_manager\.dart'": "import '/features/common/presentation/design_system/utils/icon_style_manager.dart'",
}

def update_imports_in_file(filepath):
    """파일에서 import 경로를 업데이트합니다."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # 각 매핑에 대해 치환 수행
        for pattern, replacement in IMPORT_MAPPINGS.items():
            content = re.sub(pattern, replacement, content)
        
        # 변경 사항이 있으면 파일 저장
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        return False
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return False

def find_dart_files(directory):
    """디렉토리에서 모든 Dart 파일을 찾습니다."""
    dart_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                dart_files.append(os.path.join(root, file))
    return dart_files

def main():
    """메인 함수"""
    print("Common Feature Import 경로 업데이트 시작...")
    
    # lib 디렉토리의 모든 Dart 파일 찾기
    dart_files = find_dart_files(LIB_PATH)
    
    updated_count = 0
    total_count = len(dart_files)
    
    for i, filepath in enumerate(dart_files, 1):
        if update_imports_in_file(filepath):
            updated_count += 1
            relative_path = os.path.relpath(filepath, PROJECT_ROOT)
            print(f"Updated: {relative_path}")
        
        if i % 100 == 0:
            print(f"Progress: {i}/{total_count} files processed")
    
    print(f"\n완료! 총 {updated_count}개 파일이 업데이트되었습니다.")
    print(f"검사한 파일 수: {total_count}")

if __name__ == "__main__":
    main()