# Design System Architecture - Part 3: Directory Structure & Migration

> **Documentation**: Part 3 of 14
> **Previous**: [Part 2: Modern Methodologies](DESIGN_SYSTEM_01_MODERN_METHODOLOGIES.md)
> **Next**: [Part 4: Feature Post](DESIGN_SYSTEM_03_FEATURE_POST.md)
> **Last Updated**: 2025-11-10
> **Audience**: All developers

---

## 📋 Table of Contents

- [Overview](#overview)
- [Before vs After Comparison](#before-vs-after-comparison)
- [Top-Level Directory Structure](#top-level-directory-structure)
- [Design System Directory](#design-system-directory)
- [File Migration Plan](#file-migration-plan)
- [Import Path Changes](#import-path-changes)
- [Breaking Changes](#breaking-changes)
- [Migration Scripts](#migration-scripts)
- [Rollback Procedures](#rollback-procedures)
- [Testing Strategy](#testing-strategy)

---

## 🎯 Overview

### Why Restructure?

**Current Problems**:
1. ❌ **Hidden Design System**: `/lib/core/design_system/` buried under core/
2. ❌ **Zero Adoption**: Developers don't notice components exist (0% adoption)
3. ❌ **Widget Confusion**: 20 files in `/lib/core/widgets/` need categorization
4. ❌ **Scattered Utilities**: Text sizing, theme, widgets spread across core/
5. ❌ **No Documentation**: No README at component level

**Solution Benefits**:
1. ✅ **Visibility**: `/lib/design_system/` at top level (same as features/)
2. ✅ **Discoverability**: Clear Atomic Design structure (atoms/ molecules/ organisms/)
3. ✅ **Clear Hierarchy**: Component organization by complexity level
4. ✅ **Documentation**: README.md at every level
5. ✅ **Scalability**: Easy to add new components

### Migration Impact

**Scope**:
- **Files to Move**: 14 files (design_system only)
- **Import Changes**: ~385 import statements across 249 presentation files
- **Breaking Changes**: All old import paths deprecated
- **Estimated Time**: 6 hours (1 developer)
- **Risk Level**: Medium (automated migration reduces risk)

**Phases**:
- **Phase 1.1**: Create new directories with READMEs (1 hour)
- **Phase 1.2**: Move design system files (2 hours)
- **Phase 1.3**: Update all imports (2 hours, automated)
- **Phase 1.4**: Testing & validation (1 hour)

---

## 📊 Before vs After Comparison

### Before (Current Structure)

```
/lib/
├── core/
│   ├── design_system/                    # ❌ Hidden under core/
│   │   ├── components/                   # ❌ No README (5 files)
│   │   │   ├── versus_button.dart        # 292 lines, 0% adoption
│   │   │   ├── versus_components.dart    # 715 bytes, barrel file
│   │   │   ├── versus_dialog.dart        # 347 lines, 0% adoption
│   │   │   ├── versus_icon.dart          # 726 bytes, icon component
│   │   │   └── versus_text_field.dart    # 405 lines, 0% adoption
│   │   ├── tokens/                       # ❌ No README (7 files)
│   │   │   ├── versus_colors.dart        # 47 lines, 5-100% adoption
│   │   │   ├── versus_icon_data.dart     # 808 bytes, icon data
│   │   │   ├── versus_icons.dart         # 5,315 bytes, icon constants
│   │   │   ├── versus_radius.dart        # 58 lines, 5-100% adoption
│   │   │   ├── versus_spacing.dart       # 73 lines, 5-100% adoption
│   │   │   ├── versus_text_styles.dart   # 160 lines, 5-100% adoption
│   │   │   └── versus_tokens.dart        # 722 bytes, barrel file
│   │   └── utils/
│   │       └── icon_style_manager.dart   # Icon utilities
│   │
│   ├── widgets/                          # ✅ Keep in core/ (20 files total)
│   │
│   ├── theme/
│   │   └── app_theme.dart                # 394 lines → integrate with design_system/theme/
│   │
│   ├── utils/
│   │   ├── text_sizing/                  # 8 files, 1,007 lines
│   │   │   └── ...                       # → integrate with typography tokens
│   │   └── ...                           # Keep in core/utils/
│   │
│   ├── localization/                     # ✅ Keep in core/
│   ├── nav/                              # ✅ Keep in core/
│   └── models/                           # ✅ Keep in core/
│
├── features/                             # ✅ Unchanged
├── services/                             # ✅ Unchanged
└── app/                                  # ✅ Unchanged
```

**Problems**:
1. Design system hidden 3 levels deep: `/lib/core/design_system/`
2. No documentation (0 README files in design_system/)
3. Flat structure doesn't reflect Atomic Design hierarchy
4. Text sizing utilities duplicate typography token functionality

### After (New Structure)

```
/lib/
├── design_system/                        # 🆕 Top level, visible
│   ├── README.md                         # 🆕 Comprehensive guide (500+ lines)
│   ├── GETTING_STARTED.md                # 🆕 Quick start (150 lines)
│   ├── MIGRATION_GUIDE.md                # 🆕 Migration from old patterns (300 lines)
│   │
│   ├── tokens/                           # ✅ Design tokens
│   │   ├── README.md                     # 🆕 Token usage guide (200 lines)
│   │   ├── versus_colors.dart            # ✅ Moved from core/design_system/tokens/
│   │   ├── versus_spacing.dart           # ✅ Moved
│   │   ├── versus_radius.dart            # ✅ Moved
│   │   ├── versus_text_styles.dart       # ✅ Moved
│   │   ├── versus_shadows.dart           # 🆕 Shadow elevation styles
│   │   ├── versus_durations.dart         # 🆕 Animation durations
│   │   └── tokens.json                   # 🆕 Source of truth for tooling
│   │
│   ├── atoms/                            # 🆕 Atomic Design Level 1
│   │   ├── README.md                     # 🆕 Atoms guide (100 lines)
│   │   ├── buttons/
│   │   │   ├── README.md                 # 🆕 Button usage guide
│   │   │   ├── versus_button.dart        # ✅ Moved from components/
│   │   │   ├── versus_icon_button.dart   # 🆕 Icon button variant
│   │   │   └── versus_text_button.dart   # 🆕 Text button variant
│   │   ├── inputs/
│   │   │   ├── README.md
│   │   │   ├── versus_text_field.dart    # ✅ Moved from components/
│   │   │   ├── versus_checkbox.dart      # 🆕
│   │   │   ├── versus_radio.dart         # 🆕
│   │   │   └── versus_switch.dart        # 🆕
│   │   ├── typography/
│   │   │   ├── README.md
│   │   │   ├── versus_text.dart          # 🆕 Text widget wrapper
│   │   │   └── versus_rich_text.dart     # 🆕
│   │   ├── icons/
│   │   │   ├── README.md
│   │   │   ├── versus_icon.dart          # 🆕
│   │   │   └── versus_avatar.dart        # ✅ Moved from core/widgets/
│   │   └── indicators/
│   │       ├── README.md
│   │       ├── versus_loading_indicator.dart # ✅ Moved from core/widgets/
│   │       ├── versus_progress_bar.dart  # 🆕
│   │       └── versus_badge.dart         # 🆕
│   │
│   ├── molecules/                        # 🆕 Atomic Design Level 2
│   │   ├── README.md                     # 🆕 Molecules guide (100 lines)
│   │   ├── cards/
│   │   │   ├── README.md
│   │   │   ├── versus_card.dart          # ✅ Moved from components/
│   │   │   ├── versus_info_card.dart     # 🆕
│   │   │   └── versus_stat_card.dart     # 🆕
│   │   ├── dialogs/
│   │   │   ├── README.md
│   │   │   ├── versus_dialog.dart        # ✅ Moved from components/
│   │   │   ├── versus_bottom_sheet.dart  # 🆕
│   │   │   └── versus_snackbar.dart      # 🆕
│   │   ├── forms/
│   │   │   ├── README.md
│   │   │   ├── versus_form_field.dart    # 🆕
│   │   │   ├── versus_search_bar.dart    # 🆕 Extract from features
│   │   │   └── versus_filter_chip.dart   # 🆕
│   │   └── lists/
│   │       ├── README.md
│   │       ├── versus_list_tile.dart     # 🆕
│   │       └── versus_expandable_tile.dart # 🆕
│   │
│   ├── organisms/                        # 🆕 Atomic Design Level 3
│   │   ├── README.md                     # 🆕 Organisms guide (150 lines)
│   │   ├── navigation/
│   │   │   ├── README.md
│   │   │   ├── versus_app_bar.dart       # 🆕
│   │   │   ├── versus_bottom_nav.dart    # 🆕
│   │   │   └── versus_drawer.dart        # 🆕
│   │   ├── forms/
│   │   │   ├── README.md
│   │   │   ├── versus_login_form.dart    # 🆕 Extract from Auth
│   │   │   └── versus_signup_form.dart   # 🆕 Extract from Auth
│   │   └── lists/
│   │       ├── README.md
│   │       ├── versus_post_list.dart     # 🆕 Extract from Post
│   │       └── versus_chat_list.dart     # 🆕 Extract from Chat
│   │
│   ├── templates/                        # 🆕 Atomic Design Level 4
│   │   ├── README.md                     # 🆕 Templates guide (100 lines)
│   │   ├── layouts/
│   │   │   ├── README.md
│   │   │   ├── versus_scaffold.dart      # 🆕 Standard page layout
│   │   │   ├── versus_tabbed_layout.dart # 🆕
│   │   │   └── versus_split_layout.dart  # 🆕
│   │   └── patterns/
│   │       ├── README.md
│   │       ├── empty_state_template.dart  # 🆕
│   │       ├── error_state_template.dart  # 🆕
│   │       └── loading_state_template.dart # 🆕
│   │
│   └── theme/                            # 🆕 Theme integration
│       ├── README.md                     # 🆕 Theme guide (150 lines)
│       ├── versus_theme.dart             # 🆕 Unified theme (integrates app_theme.dart)
│       ├── versus_theme_data.dart        # 🆕 Material ThemeData
│       ├── versus_theme_extensions.dart  # 🆕 Custom theme extensions
│       └── color_schemes/
│           ├── light_color_scheme.dart   # 🆕
│           └── dark_color_scheme.dart    # 🆕 (future)
│
├── core/                                 # ✅ Slim down (keep essentials only)
│   ├── localization/                     # ✅ Keep (i18n)
│   ├── nav/                              # ✅ Keep (navigation)
│   ├── models/                           # ✅ Keep (core models: LatLng, UploadedFile)
│   └── utils/                            # ✅ Keep (core utils, remove text_sizing/)
│
├── features/                             # ✅ Unchanged (8 features)
├── services/                             # ✅ Unchanged (global services)
└── app/                                  # ✅ Unchanged (entry point)
```

**Benefits**:
1. ✅ Design system at top level (same visibility as features/)
2. ✅ Clear Atomic Design hierarchy (atoms/ molecules/ organisms/ templates/)
3. ✅ Component organization by complexity level
4. ✅ Documentation at every level (15+ README files)
5. ✅ Scalable structure (easy to add new components)

---

## 🏗 Top-Level Directory Structure

### New Top-Level Directories

```
/lib/
├── design_system/    # 🆕 Design System (atoms to templates)
├── features/         # ✅ Existing (8 features)
├── core/             # ✅ Existing (slimmed down, widgets stay here)
├── services/         # ✅ Existing (global services)
├── app/              # ✅ Existing (entry point)
└── gen/              # ✅ Existing (FlutterGen assets)
```

### Why Top-Level?

**Rationale**: Design system deserves the same visibility as features.

**Before** (Hidden):
```
/lib/core/design_system/  ← 3 levels deep, low visibility
```

**After** (Visible):
```
/lib/design_system/       ← 1 level deep, high visibility
```

**Developer Experience**:
- **Before**: "Where are the design components?" → Navigate to core/design_system/components/
- **After**: "Design system is right there!" → Navigate to design_system/atoms/buttons/

**IDE Autocomplete**:
- **Before**: Type `import 'package:versus_space/core/design_system/components/...` (long path)
- **After**: Type `import 'package:versus_space/design_system/atoms/...` (shorter, clearer)

**Discoverability**:
- **Before**: New developers don't notice design system exists
- **After**: Design system is immediately visible alongside features/

---

## 📁 Design System Directory

### Detailed Structure

```
/lib/design_system/
│
├── README.md                 # 🆕 500+ lines
│   ├── What is this design system?
│   ├── Atomic Design pattern overview
│   ├── How to use tokens
│   ├── How to use components
│   ├── Migration guide from old patterns
│   ├── Contributing guide
│   └── FAQ
│
├── GETTING_STARTED.md        # 🆕 150 lines
│   ├── Quick start (5 minutes)
│   ├── Common tasks
│   ├── Examples
│   └── Debugging tips
│
├── MIGRATION_GUIDE.md        # 🆕 300 lines
│   ├── From hardcoded values to tokens
│   ├── From raw Flutter widgets to design system components
│   ├── Feature-by-feature migration checklist
│   └── Breaking changes reference
│
├── tokens/                   # Design tokens (source of truth)
│   ├── README.md             # 🆕 200 lines
│   │   ├── What are design tokens?
│   │   ├── Token categories (color, spacing, radius, typography, shadow, duration)
│   │   ├── Naming conventions
│   │   ├── Usage examples
│   │   └── How to add new tokens
│   │
│   ├── versus_colors.dart    # ✅ 47 lines, 18 tokens
│   ├── versus_spacing.dart   # ✅ 73 lines, 10 tokens
│   ├── versus_radius.dart    # ✅ 58 lines, 5 tokens
│   ├── versus_text_styles.dart # ✅ 160 lines, 23 tokens
│   ├── versus_shadows.dart   # 🆕 ~60 lines, 5 tokens
│   ├── versus_durations.dart # 🆕 ~40 lines, 6 tokens
│   └── tokens.json           # 🆕 Source of truth for Style Dictionary
│
├── atoms/                    # Atomic Design Level 1
│   ├── README.md             # 🆕 100 lines
│   │   ├── What are atoms?
│   │   ├── List of all atoms
│   │   ├── Usage guidelines
│   │   └── Best practices
│   │
│   ├── buttons/
│   │   ├── README.md         # 🆕 Usage guide with examples
│   │   ├── versus_button.dart          # ✅ 292 lines (from components/)
│   │   ├── versus_icon_button.dart     # 🆕 ~80 lines
│   │   └── versus_text_button.dart     # 🆕 ~70 lines
│   │
│   ├── inputs/
│   │   ├── README.md
│   │   ├── versus_text_field.dart      # ✅ 405 lines (from components/)
│   │   ├── versus_checkbox.dart        # 🆕 ~100 lines
│   │   ├── versus_radio.dart           # 🆕 ~90 lines
│   │   └── versus_switch.dart          # 🆕 ~80 lines
│   │
│   ├── typography/
│   │   ├── README.md
│   │   ├── versus_text.dart            # 🆕 Text wrapper with tokens
│   │   └── versus_rich_text.dart       # 🆕 RichText wrapper
│   │
│   ├── icons/
│   │   ├── README.md
│   │   ├── versus_icon.dart            # 🆕 Icon wrapper
│   │   └── versus_avatar.dart          # ✅ (from core/widgets/avatar_widget.dart)
│   │
│   └── indicators/
│       ├── README.md
│       ├── versus_loading_indicator.dart  # ✅ (from core/widgets/loading_indicator_widget.dart)
│       ├── versus_progress_bar.dart    # 🆕 Progress bar atom
│       └── versus_badge.dart           # 🆕 Badge indicator
│
├── molecules/                # Atomic Design Level 2
│   ├── README.md             # 🆕 100 lines
│   │
│   ├── cards/
│   │   ├── README.md
│   │   ├── versus_card.dart            # ✅ 189 lines (from components/)
│   │   ├── versus_info_card.dart       # 🆕 Card with icon + text
│   │   └── versus_stat_card.dart       # 🆕 Card with stats display
│   │
│   ├── dialogs/
│   │   ├── README.md
│   │   ├── versus_dialog.dart          # ✅ 347 lines (from components/)
│   │   ├── versus_bottom_sheet.dart    # 🆕 Bottom sheet molecule
│   │   └── versus_snackbar.dart        # 🆕 Snackbar molecule
│   │
│   ├── forms/
│   │   ├── README.md
│   │   ├── versus_form_field.dart      # 🆕 Form field with label + error
│   │   ├── versus_search_bar.dart      # 🆕 Search bar (extract from features)
│   │   └── versus_filter_chip.dart     # 🆕 Filter chip molecule
│   │
│   └── lists/
│       ├── README.md
│       ├── versus_list_tile.dart       # 🆕 Standard list item
│       └── versus_expandable_tile.dart # 🆕 Expandable list item
│
├── organisms/                # Atomic Design Level 3
│   ├── README.md             # 🆕 150 lines
│   │
│   ├── navigation/
│   │   ├── README.md
│   │   ├── versus_app_bar.dart         # 🆕 Standard app bar
│   │   ├── versus_bottom_nav.dart      # 🆕 Bottom navigation
│   │   └── versus_drawer.dart          # 🆕 Navigation drawer
│   │
│   ├── forms/
│   │   ├── README.md
│   │   ├── versus_login_form.dart      # 🆕 Login form organism (extract from Auth)
│   │   └── versus_signup_form.dart     # 🆕 Signup form organism
│   │
│   └── lists/
│       ├── README.md
│       ├── versus_post_list.dart       # 🆕 Post list organism
│       └── versus_chat_list.dart       # 🆕 Chat list organism
│
├── templates/                # Atomic Design Level 4
│   ├── README.md             # 🆕 100 lines
│   │
│   ├── layouts/
│   │   ├── README.md
│   │   ├── versus_scaffold.dart        # 🆕 Standard page scaffold
│   │   ├── versus_tabbed_layout.dart   # 🆕 Tabbed layout
│   │   └── versus_split_layout.dart    # 🆕 Split layout
│   │
│   └── patterns/
│       ├── README.md
│       ├── empty_state_template.dart   # 🆕 Empty state pattern
│       ├── error_state_template.dart   # 🆕 Error state pattern
│       └── loading_state_template.dart # 🆕 Loading state pattern
│
└── theme/                    # Theme integration
    ├── README.md             # 🆕 150 lines
    ├── versus_theme.dart     # 🆕 Unified theme (integrates app_theme.dart)
    ├── versus_theme_data.dart # 🆕 Material ThemeData builder
    ├── versus_theme_extensions.dart # 🆕 Custom theme extensions
    └── color_schemes/
        ├── light_color_scheme.dart # 🆕 Light theme colors
        └── dark_color_scheme.dart  # 🆕 Dark theme colors (future)
```

**Total Files**:
- **Existing**: 14 files (moved from core/design_system/)
- **New**: 40+ files (atoms, molecules, organisms, templates, READMEs)
- **Total**: 54+ files

---

## 🔄 File Migration Plan

### Phase 1.1: Create New Directories (1 hour)

**Tasks**:
1. Create `/lib/design_system/` directory structure
2. Write all README.md files (15+ READMEs)

**Commands**:
```bash
# Create design_system directories
mkdir -p lib/design_system/{tokens,atoms,molecules,organisms,templates,theme}
mkdir -p lib/design_system/atoms/{buttons,inputs,typography,icons,indicators}
mkdir -p lib/design_system/molecules/{cards,dialogs,forms,lists}
mkdir -p lib/design_system/organisms/{navigation,forms,lists}
mkdir -p lib/design_system/templates/{layouts,patterns}
mkdir -p lib/design_system/theme/color_schemes

# Create README files (content written separately)
touch lib/design_system/README.md
touch lib/design_system/GETTING_STARTED.md
touch lib/design_system/MIGRATION_GUIDE.md
touch lib/design_system/tokens/README.md
touch lib/design_system/atoms/README.md
# ... (15+ total READMEs)
```

### Phase 1.2: Move Design System Files (2 hours)

**Token Files** (5 files):
```bash
# Move existing tokens
mv lib/core/design_system/tokens/versus_colors.dart \
   lib/design_system/tokens/

mv lib/core/design_system/tokens/versus_spacing.dart \
   lib/design_system/tokens/

mv lib/core/design_system/tokens/versus_radius.dart \
   lib/design_system/tokens/

mv lib/core/design_system/tokens/versus_text_styles.dart \
   lib/design_system/tokens/
```

**Component Files** (4 files → Atoms/Molecules):
```bash
# Move VersusButton to atoms/buttons/
mv lib/core/design_system/components/versus_button.dart \
   lib/design_system/atoms/buttons/

# Move VersusTextField to atoms/inputs/
mv lib/core/design_system/components/versus_text_field.dart \
   lib/design_system/atoms/inputs/

# Move VersusDialog to molecules/dialogs/
mv lib/core/design_system/components/versus_dialog.dart \
   lib/design_system/molecules/dialogs/
```

**Note**: versus_card.dart, avatar_widget.dart, and loading_indicator_widget.dart do not exist in current codebase and are not migrated.

**Theme Integration** (1 file):
```bash
# Copy app_theme.dart (will be integrated into versus_theme.dart)
cp lib/core/theme/app_theme.dart \
   lib/design_system/theme/app_theme_legacy.dart
# Note: Keep original for now (deprecation period)
```

**Clean Up Empty Directories**:
```bash
# Remove empty core/design_system/ directories
rmdir lib/core/design_system/components/
rmdir lib/core/design_system/tokens/
rmdir lib/core/design_system/
```

### Phase 1.3: Update All Imports (2 hours, automated)

**Total Import Changes**: ~385 import statements across 249 presentation files

**Import Mapping**:

```dart
// Tokens (5 files)
// OLD:
import 'package:versus_space/core/design_system/tokens/versus_colors.dart';
// NEW:
import 'package:versus_space/design_system/tokens/versus_colors.dart';

// Components → Atoms/Molecules (3 files)
// OLD:
import 'package:versus_space/core/design_system/components/versus_button.dart';
// NEW:
import 'package:versus_space/design_system/atoms/buttons/versus_button.dart';
```

**Automated Migration Script** (see Migration Scripts section below)

### Phase 1.4: Testing & Validation (1 hour)

**Validation Checklist**:
- [ ] All imports compile without errors
- [ ] flutter analyze shows 0 errors
- [ ] All tests pass (flutter test)
- [ ] Visual regression tests pass (golden tests)
- [ ] No runtime exceptions in development
- [ ] All features work as before

**Commands**:
```bash
# 1. Check compilation
flutter pub get
flutter analyze

# 2. Run tests
flutter test

# 3. Run golden tests (visual regression)
flutter test --update-goldens  # First run: generate baselines
flutter test                   # Second run: compare against baselines

# 4. Manual testing
flutter run
# Test all 8 features manually
```

---

## 🔗 Import Path Changes

### Complete Import Mapping Table

| Old Path | New Path | File Count | Notes |
|----------|----------|------------|-------|
| `core/design_system/tokens/versus_colors.dart` | `design_system/tokens/versus_colors.dart` | ~120 imports | All features use colors |
| `core/design_system/tokens/versus_spacing.dart` | `design_system/tokens/versus_spacing.dart` | ~95 imports | All features use spacing |
| `core/design_system/tokens/versus_radius.dart` | `design_system/tokens/versus_radius.dart` | ~60 imports | Most features use radius |
| `core/design_system/tokens/versus_text_styles.dart` | `design_system/tokens/versus_text_styles.dart` | ~110 imports | All features use typography |
| `core/design_system/components/versus_button.dart` | `design_system/atoms/buttons/versus_button.dart` | 0 imports | 0% adoption (needs Phase 3) |
| `core/design_system/components/versus_text_field.dart` | `design_system/atoms/inputs/versus_text_field.dart` | 0 imports | 0% adoption (needs Phase 3) |
| `core/design_system/components/versus_dialog.dart` | `design_system/molecules/dialogs/versus_dialog.dart` | 0 imports | 0% adoption (needs Phase 3) |

**Total Import Changes**: ~385 imports across 249 presentation files (primarily token imports)

**Note**:
- versus_card.dart, avatar_widget.dart, loading_indicator_widget.dart do not exist in current codebase
- Other `core/widgets/` files (~130 imports) remain in current location and will be refactored separately

### Import Update Examples

**Example 1: Auth Feature - Login Screen**

```dart
// File: lib/features/auth/presentation/screens/login/login_page_widget.dart

// ❌ OLD imports (before Phase 1)
import 'package:versus_space/core/design_system/tokens/versus_colors.dart';
import 'package:versus_space/core/design_system/tokens/versus_spacing.dart';
import 'package:versus_space/core/design_system/tokens/versus_text_styles.dart';
import 'package:versus_space/core/widgets/social_login_button.dart';

// ✅ NEW imports (after Phase 1)
import 'package:versus_space/design_system/tokens/versus_colors.dart';
import 'package:versus_space/design_system/tokens/versus_spacing.dart';
import 'package:versus_space/design_system/tokens/versus_text_styles.dart';

// Note: social_login_button remains in core/widgets/
// (not part of design system migration, will be refactored separately)
```

**Example 2: Profile Feature - User Info**

```dart
// File: lib/features/profile/presentation/screens/user_info/user_info_page.dart

// ❌ OLD imports
import 'package:versus_space/core/design_system/tokens/versus_colors.dart';
import 'package:versus_space/core/design_system/tokens/versus_spacing.dart';

// ✅ NEW imports
import 'package:versus_space/design_system/tokens/versus_colors.dart';
import 'package:versus_space/design_system/tokens/versus_spacing.dart';

// Note: Avatar/loading widgets exist in features/ (profile_avatar.dart, loading_indicator.dart)
// not in core/widgets/, so they are not part of this migration
```

**Example 3: Creation Feature - Media Upload**

```dart
// File: lib/features/creation/presentation/screens/media_selection/media_selection_screen.dart

// ❌ OLD imports
import 'package:versus_space/core/design_system/tokens/versus_colors.dart';
import 'package:versus_space/core/design_system/tokens/versus_radius.dart';

// ✅ NEW imports
import 'package:versus_space/design_system/tokens/versus_colors.dart';
import 'package:versus_space/design_system/tokens/versus_radius.dart';

// Note: media_upload_box and image_picker_button remain in core/widgets/
// (not part of design system migration, will be refactored separately)
```

---

## ⚠️ Breaking Changes

### Breaking Change 1: Import Paths

**Impact**: ~385 imports need updating
**Migration**: Automated script (see Migration Scripts)
**Rollback**: Keep old paths as deprecated exports (2-week grace period)

**Deprecation Strategy**:
```dart
// File: lib/core/design_system/tokens/versus_colors.dart (deprecated)

@deprecated('Use design_system/tokens/versus_colors.dart instead')
export 'package:versus_space/design_system/tokens/versus_colors.dart';
```

**Grace Period**: 2 weeks (14 days)
- **Week 1**: Both old and new paths work, warnings in logs
- **Week 2**: Old paths work, errors in `flutter analyze`
- **After Week 2**: Old paths removed, imports break

### Breaking Change 2: Component Reorganization

**Impact**: 3 component files will be reorganized into Atomic Design structure

**Changes**:
```
core/design_system/components/versus_button.dart → design_system/atoms/buttons/versus_button.dart
core/design_system/components/versus_text_field.dart → design_system/atoms/inputs/versus_text_field.dart
core/design_system/components/versus_dialog.dart → design_system/molecules/dialogs/versus_dialog.dart
```

**Note**: versus_card.dart, avatar_widget.dart, and loading_indicator_widget.dart do not exist in current codebase

**Migration**: Automated script updates import paths

**Validation**: Ensure all imports compile without errors

---

## 🔧 Migration Scripts

### Script 1: Automated Import Updater

**File**: `scripts/migrate_imports.dart`

```dart
import 'dart:io';

void main() async {
  print('🚀 Starting import migration...\n');

  // Define import mappings
  final Map<String, String> importMappings = {
    // Tokens (4 files)
    "core/design_system/tokens/versus_colors.dart":
        "design_system/tokens/versus_colors.dart",
    "core/design_system/tokens/versus_spacing.dart":
        "design_system/tokens/versus_spacing.dart",
    "core/design_system/tokens/versus_radius.dart":
        "design_system/tokens/versus_radius.dart",
    "core/design_system/tokens/versus_text_styles.dart":
        "design_system/tokens/versus_text_styles.dart",

    // Components → Atoms/Molecules (3 files)
    "core/design_system/components/versus_button.dart":
        "design_system/atoms/buttons/versus_button.dart",
    "core/design_system/components/versus_text_field.dart":
        "design_system/atoms/inputs/versus_text_field.dart",
    "core/design_system/components/versus_dialog.dart":
        "design_system/molecules/dialogs/versus_dialog.dart",

    // Note: versus_card.dart, avatar_widget.dart, loading_indicator_widget.dart
    // do not exist in current codebase and are not included
  };

  // Find all Dart files in features/ and lib/
  final files = await _findDartFiles('lib/');

  int totalFiles = 0;
  int totalUpdates = 0;

  for (final file in files) {
    final updates = await _updateImports(file, importMappings);
    if (updates > 0) {
      totalFiles++;
      totalUpdates += updates;
      print('✅ Updated $updates imports in ${file.path}');
    }
  }

  print('\n🎉 Migration complete!');
  print('   Files updated: $totalFiles');
  print('   Total imports updated: $totalUpdates');
}

Future<List<File>> _findDartFiles(String directory) async {
  final dir = Directory(directory);
  final files = <File>[];

  await for (final entity in dir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      // Skip generated files
      if (!entity.path.contains('.g.dart') &&
          !entity.path.contains('.freezed.dart')) {
        files.add(entity);
      }
    }
  }

  return files;
}

Future<int> _updateImports(
  File file,
  Map<String, String> mappings,
) async {
  final content = await file.readAsString();
  String newContent = content;
  int updateCount = 0;

  for (final entry in mappings.entries) {
    final oldPath = entry.key;
    final newPath = entry.value;

    final oldImport = "import 'package:versus_space/$oldPath'";
    final newImport = "import 'package:versus_space/$newPath'";

    if (newContent.contains(oldImport)) {
      newContent = newContent.replaceAll(oldImport, newImport);
      updateCount++;
    }
  }

  if (updateCount > 0) {
    await file.writeAsString(newContent);
  }

  return updateCount;
}
```

**Usage**:
```bash
# Run migration script
dart scripts/migrate_imports.dart

# Expected output:
# 🚀 Starting import migration...
#
# ✅ Updated 4 imports in lib/features/auth/presentation/screens/login/login_page_widget.dart
# ✅ Updated 3 imports in lib/features/profile/presentation/screens/user_info/user_info_page.dart
# ...
#
# 🎉 Migration complete!
#    Files updated: 182
#    Total imports updated: 515
```

### Script 2: Validation Script

**File**: `scripts/validate_migration.dart`

```dart
import 'dart:io';

void main() async {
  print('🔍 Validating migration...\n');

  // Check for old import paths
  final oldPaths = [
    'core/design_system/',
    'core/widgets/',
  ];

  final files = await _findDartFiles('lib/');
  final errors = <String>[];

  for (final file in files) {
    final content = await file.readAsString();

    for (final oldPath in oldPaths) {
      if (content.contains("import 'package:versus_space/$oldPath")) {
        errors.add('${file.path}: Still uses old import path: $oldPath');
      }
    }
  }

  if (errors.isEmpty) {
    print('✅ All imports successfully migrated!');
    print('   No old import paths found.\n');
  } else {
    print('❌ Migration incomplete:');
    for (final error in errors) {
      print('   $error');
    }
    print('');
    exit(1);
  }

  // Run flutter analyze
  print('🔍 Running flutter analyze...');
  final result = await Process.run('flutter', ['analyze']);
  if (result.exitCode == 0) {
    print('✅ flutter analyze passed!\n');
  } else {
    print('❌ flutter analyze failed:');
    print(result.stdout);
    print(result.stderr);
    exit(1);
  }

  print('🎉 Validation complete! Migration successful.');
}

Future<List<File>> _findDartFiles(String directory) async {
  // Same as migrate_imports.dart
  // ...
}
```

**Usage**:
```bash
# Run validation after migration
dart scripts/validate_migration.dart

# Expected output:
# 🔍 Validating migration...
#
# ✅ All imports successfully migrated!
#    No old import paths found.
#
# 🔍 Running flutter analyze...
# ✅ flutter analyze passed!
#
# 🎉 Validation complete! Migration successful.
```

---

## 🔄 Rollback Procedures

### Rollback Strategy

**If migration fails**, follow these steps to rollback:

**Step 1: Git Rollback** (Recommended)
```bash
# Rollback to commit before migration
git log --oneline  # Find commit hash before migration
git reset --hard <commit-hash>

# Or rollback specific files
git checkout HEAD~1 lib/
```

**Step 2: Manual Rollback** (If needed)
```bash
# Move files back to original locations
mv lib/design_system/tokens/* lib/core/design_system/tokens/
mv lib/design_system/atoms/buttons/versus_button.dart lib/core/design_system/components/
# ... (reverse of migration steps)

# Delete new directory
rm -rf lib/design_system/
```

**Step 3: Restore Imports**
```bash
# Run reverse migration script
dart scripts/rollback_imports.dart
```

**Step 4: Validation**
```bash
flutter pub get
flutter analyze
flutter test
```

### Rollback Script

**File**: `scripts/rollback_imports.dart`

```dart
import 'dart:io';

void main() async {
  print('🔄 Rolling back import migration...\n');

  // Reverse mappings (new → old)
  final Map<String, String> reverseMappings = {
    "design_system/tokens/versus_colors.dart":
        "core/design_system/tokens/versus_colors.dart",
    "design_system/tokens/versus_spacing.dart":
        "core/design_system/tokens/versus_spacing.dart",
    // ... (all reverse mappings)
  };

  final files = await _findDartFiles('lib/');
  int totalFiles = 0;
  int totalUpdates = 0;

  for (final file in files) {
    final updates = await _updateImports(file, reverseMappings);
    if (updates > 0) {
      totalFiles++;
      totalUpdates += updates;
      print('✅ Rolled back $updates imports in ${file.path}');
    }
  }

  print('\n🎉 Rollback complete!');
  print('   Files updated: $totalFiles');
  print('   Total imports rolled back: $totalUpdates');
}

// Same helper functions as migrate_imports.dart
```

---

## ✅ Testing Strategy

### Pre-Migration Testing

**Baseline Tests** (Before migration):
```bash
# 1. Run all tests to establish baseline
flutter test

# 2. Generate golden test baselines
flutter test --update-goldens

# 3. Run flutter analyze
flutter analyze

# 4. Manual testing checklist
# - Test all 8 features
# - Take screenshots of key screens
# - Note any existing issues
```

### Post-Migration Testing

**Validation Tests** (After migration):
```bash
# 1. Verify compilation
flutter pub get
flutter analyze  # Should show 0 errors

# 2. Run unit tests
flutter test

# 3. Run golden tests (visual regression)
flutter test  # Compare against baseline

# 4. Integration tests
flutter test integration_test/

# 5. Manual testing
flutter run
# Test all 8 features, compare with baseline screenshots
```

### Test Checklist

**Automated Tests**:
- [ ] All unit tests pass (flutter test)
- [ ] All golden tests pass (no visual regressions)
- [ ] flutter analyze shows 0 errors, 0 warnings
- [ ] All integration tests pass

**Manual Tests** (8 Features):
- [ ] **Auth**: Login, signup, forgot password work
- [ ] **Profile**: View profile, edit profile, character customization work
- [ ] **Chat**: Chat list, message send/receive work
- [ ] **Notifications**: Notification list, badge counts work
- [ ] **Creation**: Post creation wizard, media upload work
- [ ] **Voting**: Vote submission, vote results work
- [ ] **Post**: Post list, post detail work
- [ ] **Search**: Search functionality, filters work

**Visual Checks**:
- [ ] All colors match design (no visual regressions)
- [ ] All spacing/padding consistent
- [ ] All typography correct
- [ ] All border radius consistent
- [ ] No layout shifts or UI glitches

---

## 📝 Summary

### Migration Checklist

**Phase 1.1: Create Directories** (1 hour)
- [ ] Create `/lib/design_system/` structure
- [ ] Write all 15+ README files

**Phase 1.2: Move Design System Files** (2 hours)
- [ ] Move 5 token files
- [ ] Move 4 component files to atoms/molecules
- [ ] Move 2 widget files to atoms (avatar, loading_indicator)
- [ ] Copy app_theme.dart for integration

**Phase 1.3: Update Imports** (2 hours, automated)
- [ ] Run `dart scripts/migrate_imports.dart`
- [ ] Verify ~385 imports updated
- [ ] Run `dart scripts/validate_migration.dart`

**Phase 1.4: Testing** (1 hour)
- [ ] Run flutter analyze (0 errors)
- [ ] Run flutter test (all pass)
- [ ] Run golden tests (no regressions)
- [ ] Manual test all 8 features

**Total Time**: 6 hours (1 developer)

---

**Continue Reading**: [Part 4: Feature Post](DESIGN_SYSTEM_03_FEATURE_POST.md) →

---

**Document Navigation**: Part 3 of 14
**Previous**: [Part 2: Modern Methodologies](DESIGN_SYSTEM_01_MODERN_METHODOLOGIES.md)
**Next**: [Part 4: Feature Post](DESIGN_SYSTEM_03_FEATURE_POST.md)
