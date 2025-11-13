# Box Sizing Configuration Guide

Complete reference for all box sizing configuration constants used in the Versus Space app.

## 📋 Table of Contents

- [Overview](#-overview)
- [BoxCalculatorConfig Reference](#-boxcalculatorconfig-reference)
  - [Message Card (Chat) Constants](#message-card-chat-constants)
  - [Notification Dialog (Voting) Constants](#notification-dialog-voting-constants)
  - [Question Container (Creation) Constants](#question-container-creation-constants)
  - [Common Layout Constants](#common-layout-constants)
  - [Helper Methods](#helper-methods)
- [ResponsiveConfig Reference](#-responsiveconfig-reference)
  - [Message Width Constants](#message-width-constants)
  - [Message Margins](#message-margins)
  - [VS Box Heights](#vs-box-heights)
- [How to Add New Constants](#-how-to-add-new-constants)
- [Best Practices](#-best-practices)
- [Naming Conventions](#-naming-conventions)
- [Migration History](#-migration-history)

---

## 🎯 Overview

This directory contains two configuration classes that centralize all magic numbers used in box size calculations:

**BoxCalculatorConfig** (`box_calculator_config.dart`)
- 34+ constants for box sizing calculations
- 3 container types: Message Card, Notification Dialog, Question Container
- Helper methods for container-aware constant retrieval

**ResponsiveConfig** (`responsive_config.dart`)
- 50+ constants for responsive design
- 6 device types: Mobile Small, Mobile, Mobile Large, Tablet, Desktop, Desktop Large
- Breakpoints, margins, and VS box heights

### Design Principles

1. **Component-Based Grouping**: Constants organized by container type and feature
2. **Meaningful Naming**: Names clearly indicate purpose and context
3. **Unit Specification**: Pixels vs ratios explicitly distinguished
4. **Documentation**: Every constant has usage examples and purpose

---

## 📐 BoxCalculatorConfig Reference

### Message Card (Chat) Constants

Used by `UnifiedBoxCalculator.calculateForMessageCard()` for chat message bubbles.

#### Width Ratios

| Constant | Value | Purpose | Usage |
|----------|-------|---------|-------|
| `messageCardSingleWidthRatio` | 0.8 (80%) | Single image box width in chat bubble | `boxWidth = bubbleWidth * 0.8` |
| `messageCardHorizontalWidthRatio` | 0.495 (49.5%) | Each box width in horizontal layout (after spacing) | `boxWidth = (bubbleWidth - spacing) * 0.495` |
| `messageCardVerticalWidthRatio` | 0.95 (95%) | Box width in vertical layout (5% left/right margin) | `boxWidth = bubbleWidth * 0.95` |

**Example**:
```dart
// Chat bubble width: 300px
// Single layout:
final boxWidth = 300 * 0.8; // 240px

// Horizontal layout:
final spacing = 8.0;
final boxWidth = (300 - spacing) * 0.495; // 144.54px each

// Vertical layout:
final boxWidth = 300 * 0.95; // 285px
```

#### Spacing

| Constant | Value | Purpose |
|----------|-------|---------|
| `messageCardSpacing` | 8.0 | Gap between boxes in horizontal/vertical layouts |

#### Heights - Single Layout

| Constant | Value | Purpose |
|----------|-------|---------|
| `messageCardSingleMaxHeight` | 400.0 | Maximum height for single image box |
| `messageCardSingleMinHeight` | 100.0 | Minimum height for single image box (prevents too small boxes) |

**Calculation Logic**:
```dart
// Single layout height calculation:
1. Calculate aspect-ratio-based height: height = boxWidth / aspectRatio
2. Clamp to range: clamp(height, 100.0, 400.0)
```

#### Heights - Horizontal Layout

| Constant | Value | Purpose |
|----------|-------|---------|
| `messageCardHorizontalMaxHeight` | 400.0 | Maximum height for each box in horizontal layout |
| `messageCardHorizontalMinHeight` | 200.0 | Minimum height for each box (maintains readability) |

**Unified Height Algorithm**:
```dart
// Horizontal layout with two boxes:
1. Calculate heightA = boxWidth / aspectRatioA
2. Calculate heightB = boxWidth / aspectRatioB
3. Unified height = average(heightA, heightB)
4. Clamp to range: clamp(unified, 200.0, 400.0)
```

#### Heights - Vertical Layout

| Constant | Value | Purpose |
|----------|-------|---------|
| `messageCardVerticalTotalMaxHeight` | 350.0 | Total maximum height (both boxes + spacing) |
| `messageCardVerticalMinHeightTwoBoxes` | 100.0 | Minimum height for each box when two boxes present |
| `messageCardVerticalMaxHeightSingleBox` | 350.0 | Maximum height when only one box present |
| `messageCardVerticalMinHeightSingleBox` | 200.0 | Minimum height when only one box present |

**Calculation Logic**:
```dart
// Vertical layout with two boxes:
1. Max height per box = (350 - spacing) / 2 = 171px
2. Calculate aspect-ratio-based heights
3. Clamp each to range: clamp(height, 100.0, 171.0)

// Vertical layout with one box:
1. Max height = 350px (full space)
2. Clamp to range: clamp(height, 200.0, 350.0)
```

#### Default Aspect Ratio

| Constant | Value | Purpose |
|----------|-------|---------|
| `messageCardDefaultAspectRatio` | 1.5 | Fallback ratio when aspect ratio unknown (3:2, landscape) |

**Usage**:
```dart
final height = boxWidth / (aspectRatio ?? 1.5);
```

---

### Notification Dialog (Voting) Constants

Used by `UnifiedBoxCalculator.calculateForNotificationDialog()` for voting dialogs.

#### Width Ratios

| Constant | Value | Purpose |
|----------|-------|---------|
| `notificationDialogSingleWidthRatio` | 0.95 (95%) | Single box width in dialog (maximizes space usage) |
| `notificationDialogVerticalWidthRatio` | 0.95 (95%) | Box width in vertical layout |

#### Spacing & Padding

| Constant | Value | Purpose |
|----------|-------|---------|
| `notificationDialogSpacing` | 8.0 | Gap between boxes |
| `notificationDialogHorizontalPadding` | 16.0 | Total left+right padding in horizontal layout (8px each side) |

**Horizontal Layout Width Calculation**:
```dart
// Dialog width: 350px
// Available width = 350 - spacing - padding
//                 = 350 - 8 - 16 = 326px
// Each box width = 326 / 2 = 163px
```

#### Heights - Single Layout

| Constant | Value | Purpose |
|----------|-------|---------|
| `notificationDialogSingleMaxHeight` | 500.0 | Maximum height (dialog has more vertical space than chat) |
| `notificationDialogSingleMinHeight` | 150.0 | Minimum height |

#### Heights - Horizontal Layout

| Constant | Value | Purpose |
|----------|-------|---------|
| `notificationDialogHorizontalMaxHeight` | 400.0 | Maximum height for each box |
| `notificationDialogHorizontalMinHeight` | 150.0 | Minimum height for each box |

#### Heights - Vertical Layout

| Constant | Value | Purpose |
|----------|-------|---------|
| `notificationDialogVerticalTotalMaxHeight` | 350.0 | Total maximum height (both boxes + spacing) |
| `notificationDialogVerticalMinHeightTwoBoxes` | 100.0 | Minimum height per box when two boxes |
| `notificationDialogVerticalMaxHeightSingleBox` | 350.0 | Maximum height when one box |
| `notificationDialogVerticalMinHeightSingleBox` | 150.0 | Minimum height when one box |

#### Default Aspect Ratio

| Constant | Value | Purpose |
|----------|-------|---------|
| `notificationDialogDefaultAspectRatio` | 1.5 | Fallback ratio (3:2, landscape) |

---

### Question Container (Creation) Constants

Used by `UnifiedBoxCalculator.calculateForQuestion()` for post creation screen.

#### Width Ratio

| Constant | Value | Purpose |
|----------|-------|---------|
| `questionContainerWidthRatio` | 1.0 (100%) | Full container width usage (no margins) |

#### Heights

| Constant | Value | Purpose |
|----------|-------|---------|
| `questionContainerHorizontalMaxHeight` | 500.0 | Maximum height in horizontal layout |
| `questionContainerHorizontalMinHeight` | 150.0 | Minimum height in horizontal layout |
| `questionContainerVerticalMaxHeight` | 400.0 | Maximum height in vertical layout |
| `questionContainerVerticalMinHeight` | 120.0 | Minimum height in vertical layout |
| `questionContainerSingleMaxHeight` | 600.0 | Maximum height for single image (largest allowance) |

**Why Different Heights?**
- **Horizontal**: More width available, so taller boxes acceptable (500px)
- **Vertical**: Stacked vertically, so shorter boxes to prevent overflow (400px)
- **Single**: Full screen real estate, so largest height (600px)

---

### Common Layout Constants

Used across all container types for general layout calculations.

#### Spacing

| Constant | Value | Purpose |
|----------|-------|---------|
| `horizontalSpacing` | 8.0 | Gap between boxes in horizontal layout |
| `verticalSpacing` | 12.0 | Gap between boxes in vertical layout (slightly larger) |

**Why Different Spacing?**
- Vertical spacing is 50% larger (12px vs 8px) because vertical stacking benefits from more breathing room

#### Box Width Ratios

| Constant | Value | Purpose |
|----------|-------|---------|
| `horizontalBoxWidthRatio` | 0.495 (49.5%) | Each box width in horizontal layout (after spacing: 49.5% × 2 + gap = ~100%) |
| `verticalBoxWidthRatio` | 0.95 (95%) | Box width in vertical layout (5% margin for spacing) |
| `singleBoxWidthRatio` | 0.95 (95%) | Single box width (5% margin) |

#### Defaults

| Constant | Value | Purpose |
|----------|-------|---------|
| `defaultBoxHeight` | 350.0 | Fallback height when no aspect ratio available |
| `defaultAspectRatio` | 1.0 | Fallback ratio (1:1, square) |
| `containerHeightUsageRatio` | 0.88 (88%) | Vertical layout uses 88% of container height (12% for top/bottom margins) |

#### Container Type Identifiers

| Constant | Value | Purpose |
|----------|-------|---------|
| `containerTypeQuestion` | "question" | Identifies question/creation container |
| `containerTypeNotification` | "notification" | Identifies notification/voting dialog |
| `containerTypeMessage` | "message" | Identifies message/chat bubble |

---

### Helper Methods

#### `getMaxHeight()`

**Purpose**: Returns maximum box height based on container type and layout.

```dart
static double getMaxHeight({
  required String containerType,
  required bool isHorizontal,
  bool isSingle = false,
  double? screenHeight,
})
```

**Returns**:

| Container | Horizontal | Vertical | Single |
|-----------|------------|----------|--------|
| **Question** | 500px | 400px | 600px |
| **Notification** | 90% screen | 88% screen | 500px |
| **Message** | 400px | 350px | 400px |

**Example**:
```dart
// Question container, horizontal layout
final maxHeight = BoxCalculatorConfig.getMaxHeight(
  containerType: BoxCalculatorConfig.containerTypeQuestion,
  isHorizontal: true,
); // Returns 500.0

// Notification dialog, vertical layout
final maxHeight = BoxCalculatorConfig.getMaxHeight(
  containerType: BoxCalculatorConfig.containerTypeNotification,
  isHorizontal: false,
  screenHeight: 800.0, // Required for notification
); // Returns 704.0 (800 * 0.88)
```

#### `getMinHeight()`

**Purpose**: Returns minimum box height based on container type and layout.

```dart
static double getMinHeight({
  required String containerType,
  required bool isHorizontal,
  bool isSingle = false,
})
```

**Returns**:

| Container | Horizontal | Vertical | Single |
|-----------|------------|----------|--------|
| **Question** | 150px | 120px | 150px |
| **Notification** | 150px | 150px | 150px |
| **Message** | 200px | 200px | 100px |

**Example**:
```dart
final minHeight = BoxCalculatorConfig.getMinHeight(
  containerType: BoxCalculatorConfig.containerTypeMessage,
  isHorizontal: false,
); // Returns 200.0
```

#### `getWidthRatio()`

**Purpose**: Returns box width ratio based on container type and layout.

```dart
static double getWidthRatio({
  required String containerType,
  required bool isHorizontal,
  required bool isSingle,
})
```

**Returns**:

| Container | Single | Horizontal | Vertical |
|-----------|--------|------------|----------|
| **Question** | 0.95 | 0.95 | 1.0 |
| **Notification** | 0.95 | 0.95 | 0.95 |
| **Message** | 0.95 | 0.95 | 0.95 |

**Note**: All containers use 95% width (5% margin) except Question which uses 100% in some cases.

**Example**:
```dart
final widthRatio = BoxCalculatorConfig.getWidthRatio(
  containerType: BoxCalculatorConfig.containerTypeNotification,
  isHorizontal: false,
  isSingle: false,
); // Returns 0.95
```

#### `getSpacing()`

**Purpose**: Returns spacing between boxes based on layout direction.

```dart
static double getSpacing(bool isHorizontal)
```

**Returns**:
- Horizontal: 8.0
- Vertical: 12.0

**Example**:
```dart
final spacing = BoxCalculatorConfig.getSpacing(true); // 8.0 (horizontal)
final spacing = BoxCalculatorConfig.getSpacing(false); // 12.0 (vertical)
```

#### `getBoxWidthRatio()`

**Purpose**: Returns box width ratio based on layout type.

```dart
static double getBoxWidthRatio({
  required bool isHorizontal,
  required bool isSingle,
})
```

**Returns**:
- Single: 0.95 (95%)
- Horizontal: 0.495 (49.5%)
- Vertical: 0.95 (95%)

**Example**:
```dart
final ratio = BoxCalculatorConfig.getBoxWidthRatio(
  isHorizontal: true,
  isSingle: false,
); // Returns 0.495
```

---

## 📱 ResponsiveConfig Reference

### Message Width Constants

#### Ratios (Small Screens)

| Constant | Value | Device | Purpose |
|----------|-------|--------|---------|
| `mobileSmallMessageWidthRatio` | 0.85 (85%) | <360px | Maximum message width for very small phones |
| `mobileMessageWidthRatio` | 0.80 (80%) | 360-599px | Maximum message width for mobile devices |

**Usage**:
```dart
// Screen width: 320px (iPhone SE)
final maxWidth = 320 * 0.85; // 272px

// Screen width: 400px (Standard mobile)
final maxWidth = 400 * 0.80; // 320px
```

#### Absolute Widths (Large Screens)

| Constant | Value | Device | Purpose |
|----------|-------|--------|---------|
| `tabletMessageMaxWidth` | 500.0 | 600-1023px | Fixed message width for tablets |
| `desktopMessageMaxWidth` | 600.0 | 1024-1439px | Fixed message width for desktop |
| `desktopLargeMessageMaxWidth` | 700.0 | ≥1440px | Fixed message width for large desktop |

**Why Fixed Widths?**
- On large screens, percentage-based widths would create excessively wide messages
- Fixed widths maintain comfortable reading width (optimal: 500-700px)

---

### Message Margins

Margins control message alignment (left-aligned for others, right-aligned for mine).

#### Mobile Small & Mobile (320-599px)

| Constant | Value | Purpose |
|----------|-------|---------|
| `mobileMessageMarginMyLeft` | 40.0 | Push "my" message to right |
| `mobileMessageMarginMyRight` | 12.0 | Right edge spacing |
| `mobileMessageMarginOtherLeft` | 12.0 | Left edge spacing |
| `mobileMessageMarginOtherRight` | 40.0 | Push "other" message to left |
| `mobileMessageMarginBottom` | 8.0 | Vertical spacing between messages |

**Visual Representation**:
```
┌────────────────────────────────────┐
│ [12px] Other's message [40px]     │ ← Left-aligned
│                                    │
│ [40px] My message [12px]          │ ← Right-aligned
│                                    │
│ [Gap: 8px]                         │
└────────────────────────────────────┘
```

#### Mobile Large (600-767px)

| Constant | Value | Change from Mobile |
|----------|-------|--------------------|
| `mobileLargeMessageMarginMyLeft` | 50.0 | +10px (more spacing) |
| `mobileLargeMessageMarginMyRight` | 16.0 | +4px |
| `mobileLargeMessageMarginOtherLeft` | 16.0 | +4px |
| `mobileLargeMessageMarginOtherRight` | 50.0 | +10px |
| `mobileLargeMessageMarginBottom` | 8.0 | (same) |

#### Tablet (768-1023px)

| Constant | Value | Change from Mobile Large |
|----------|-------|--------------------------|
| `tabletMessageMarginMyLeft` | 100.0 | +50px (much more spacing) |
| `tabletMessageMarginMyRight` | 20.0 | +4px |
| `tabletMessageMarginOtherLeft` | 20.0 | +4px |
| `tabletMessageMarginOtherRight` | 100.0 | +50px |
| `tabletMessageMarginBottom` | 12.0 | +4px (larger gap) |

#### Desktop & Desktop Large (≥1024px)

| Constant | Value | Change from Tablet |
|----------|-------|--------------------|
| `desktopMessageMarginMyLeft` | 150.0 | +50px (maximum spacing) |
| `desktopMessageMarginMyRight` | 24.0 | +4px |
| `desktopMessageMarginOtherLeft` | 24.0 | +4px |
| `desktopMessageMarginOtherRight` | 150.0 | +50px |
| `desktopMessageMarginBottom` | 12.0 | (same) |

**Margin Scaling Pattern**:
```
Mobile:        40px ←→ 12px
Mobile Large:  50px ←→ 16px (+25%)
Tablet:       100px ←→ 20px (+100%)
Desktop:      150px ←→ 24px (+50%)
```

---

### VS Box Heights

Heights for voting boxes in chat messages, with base (collapsed) and expanded states.

#### Base Image Height (Collapsed with Image)

| Device | Constant | Value |
|--------|----------|-------|
| Mobile Small | `mobileBaseImageHeight` | 200.0 |
| Mobile | `mobileBaseImageHeight` | 200.0 |
| Mobile Large | `mobileLargeBaseImageHeight` | 200.0 |
| Tablet | `tabletBaseImageHeight` | 240.0 |
| Desktop | `desktopBaseImageHeight` | 280.0 |
| Desktop Large | `desktopBaseImageHeight` | 280.0 |

**Scaling Pattern**: +20% per device tier (200 → 240 → 280)

#### Expanded Image Height (Expanded with Image)

| Device | Constant | Value | Growth |
|--------|----------|-------|--------|
| Mobile Small | `mobileExpandedImageHeight` | 300.0 | +50% |
| Mobile | `mobileExpandedImageHeight` | 300.0 | +50% |
| Mobile Large | `mobileLargeExpandedImageHeight` | 300.0 | +50% |
| Tablet | `tabletExpandedImageHeight` | 360.0 | +50% |
| Desktop | `desktopExpandedImageHeight` | 420.0 | +50% |
| Desktop Large | `desktopExpandedImageHeight` | 420.0 | +50% |

**Growth Rule**: Expanded = Base × 1.5 (consistent 50% growth)

#### Base Text Height (Collapsed Text-Only)

| Device | Constant | Value | Ratio |
|--------|----------|-------|-------|
| Mobile Small | `mobileBaseTextHeight` | 140.0 | 70% of image |
| Mobile | `mobileBaseTextHeight` | 140.0 | 70% of image |
| Mobile Large | `mobileLargeBaseTextHeight` | 140.0 | 70% of image |
| Tablet | `tabletBaseTextHeight` | 168.0 | 70% of image |
| Desktop | `desktopBaseTextHeight` | 196.0 | 70% of image |
| Desktop Large | `desktopBaseTextHeight` | 196.0 | 70% of image |

**Calculation**: Text Height = Image Height × 0.7

#### Expanded Text Height (Expanded Text-Only)

| Device | Constant | Value | Ratio |
|--------|----------|-------|-------|
| Mobile Small | `mobileExpandedTextHeight` | 210.0 | 70% of expanded image |
| Mobile | `mobileExpandedTextHeight` | 210.0 | 70% of expanded image |
| Mobile Large | `mobileLargeExpandedTextHeight` | 210.0 | 70% of expanded image |
| Tablet | `tabletExpandedTextHeight` | 252.0 | 70% of expanded image |
| Desktop | `desktopExpandedTextHeight` | 294.0 | 70% of expanded image |
| Desktop Large | `desktopExpandedTextHeight` | 294.0 | 70% of expanded image |

**Calculation**: Expanded Text = Expanded Image × 0.7

#### Text-to-Image Ratio Helper

| Constant | Value | Purpose |
|----------|-------|---------|
| `textToImageHeightRatio` | 0.7 (70%) | Text-only boxes are 30% shorter than image boxes |

**Usage**:
```dart
final textHeight = imageHeight * ResponsiveConfig.textToImageHeightRatio;
```

---

## 🆕 How to Add New Constants

### Step 1: Identify the Need

**Questions to Ask**:
- Which container type needs this constant? (Message/Notification/Question)
- Which layout type uses it? (Horizontal/Vertical/Single)
- Is it device-specific? (If yes, add to ResponsiveConfig)
- What's the unit? (Pixel or ratio?)

### Step 2: Choose the Right File

```
BoxCalculatorConfig.dart → Container/layout-specific constants
ResponsiveConfig.dart    → Device-specific constants
```

### Step 3: Add to Appropriate Group

**Example: Adding a new Message Card constant**

```dart
// lib/services/box_sizing/config/box_calculator_config.dart

class BoxCalculatorConfig {
  // ============================================================================
  // Message Card (Chat Bubble) - calculateForMessageCard()
  // ============================================================================

  // ... existing constants ...

  // ===== New Section =====

  /// Message card new feature value (pixels)
  ///
  /// Detailed description of what this constant controls and why
  /// Usage: `result = baseValue * messageCardNewFeatureValue`
  static const double messageCardNewFeatureValue = 42.0;
}
```

### Step 4: Update Helper Methods (if applicable)

If your constant affects helper method logic, update the method:

```dart
static double getMaxHeight({
  required String containerType,
  required bool isHorizontal,
  bool isSingle = false,
  double? screenHeight,
}) {
  switch (containerType) {
    case containerTypeMessage:
      // Add your new logic here
      if (someCondition) {
        return messageCardNewFeatureValue;
      }
      return isHorizontal
          ? messageCardHorizontalMaxHeight
          : messageCardVerticalTotalMaxHeight;
    // ... other cases ...
  }
}
```

### Step 5: Update Documentation

1. Add to this README in appropriate section
2. Update main `box_sizing/README.md` if it affects API
3. Add usage examples

---

## ✅ Best Practices

### 1. Single Source of Truth

❌ **Bad**: Hardcoding values in feature code
```dart
// In voting feature:
final maxHeight = 500.0; // Magic number!
```

✅ **Good**: Using config constants
```dart
final maxHeight = BoxCalculatorConfig.notificationDialogSingleMaxHeight;
```

### 2. Meaningful Names

❌ **Bad**: Generic or abbreviated names
```dart
static const double mcw = 0.8;  // What is "mcw"?
static const double max = 400.0; // Max of what?
```

✅ **Good**: Descriptive, self-documenting names
```dart
static const double messageCardSingleWidthRatio = 0.8;
static const double messageCardSingleMaxHeight = 400.0;
```

### 3. Unit Specification

Always make the unit clear in the name:

```dart
// Ratios (0-1 range):
static const double messageCardSingleWidthRatio = 0.8;  // ← "Ratio" suffix

// Pixels (absolute values):
static const double messageCardSpacing = 8.0;           // ← No suffix = pixels
static const double tabletMessageMaxWidth = 500.0;     // ← "Width"/"Height" = pixels
```

### 4. Documentation Format

Every constant must have:

```dart
/// Brief one-line summary
///
/// Detailed explanation of:
/// - What this constant controls
/// - Why this specific value was chosen
/// - How it's used in calculations
/// - Any constraints or relationships with other constants
///
/// Usage: `result = input * constantName`
/// Related: [OtherRelevantConstant]
static const double constantName = 42.0;
```

### 5. Grouping and Organization

Group related constants together:

```dart
// ===== Width Ratios =====
static const double singleWidthRatio = 0.95;
static const double horizontalWidthRatio = 0.495;
static const double verticalWidthRatio = 0.95;

// ===== Heights =====
static const double maxHeight = 400.0;
static const double minHeight = 100.0;

// ===== Spacing =====
static const double horizontalSpacing = 8.0;
static const double verticalSpacing = 12.0;
```

### 6. Helper Method Consistency

When adding helper methods:
- Always include `required` for mandatory parameters
- Use named parameters for clarity
- Include default values where appropriate
- Document return values with examples

```dart
/// Returns the maximum height based on container type
///
/// **Returns**:
/// - Question: 500px (horizontal), 400px (vertical)
/// - Message: 400px (horizontal), 350px (vertical)
static double getMaxHeight({
  required String containerType,
  required bool isHorizontal,
  bool isSingle = false,  // ← Default value
})
```

---

## 🏷 Naming Conventions

### Pattern: `[context]_[feature]_[property]_[unit]`

**Examples**:

```dart
// Message Card (Chat)
messageCardSingleWidthRatio          // context_feature_property_unit
messageCardHorizontalMaxHeight       // context_layout_bound_property
messageCardSpacing                   // context_property

// Notification Dialog (Voting)
notificationDialogVerticalWidthRatio
notificationDialogSingleMaxHeight
notificationDialogHorizontalPadding

// Question Container (Creation)
questionContainerHorizontalMaxHeight
questionContainerWidthRatio

// Responsive (Device-specific)
mobileSmallMessageWidthRatio         // device_feature_property_unit
tabletMessageMaxWidth                // device_feature_bound_property
desktopExpandedImageHeight           // device_state_property
```

### Suffix Conventions

| Suffix | Meaning | Range | Example |
|--------|---------|-------|---------|
| `Ratio` | Percentage (0-1) | 0.0-1.0 | `widthRatio = 0.8` (80%) |
| `Width` | Pixel width | ≥0 | `maxWidth = 500.0` |
| `Height` | Pixel height | ≥0 | `maxHeight = 400.0` |
| `Spacing` | Pixel gap | ≥0 | `spacing = 8.0` |
| `Padding` | Pixel padding | ≥0 | `padding = 16.0` |
| `Margin` | Pixel margin | ≥0 | `margin = 12.0` |

### Prefix Conventions

| Prefix | Meaning | Example |
|--------|---------|---------|
| `max` | Maximum bound | `maxHeight` |
| `min` | Minimum bound | `minHeight` |
| `default` | Fallback value | `defaultAspectRatio` |
| `base` | Collapsed/initial state | `baseImageHeight` |
| `expanded` | Expanded state | `expandedImageHeight` |

### Device Prefixes (ResponsiveConfig)

| Prefix | Breakpoint | Screen Width |
|--------|-----------|--------------|
| `mobileSmall` | <360px | Very small phones |
| `mobile` | 360-599px | Standard mobile |
| `mobileLarge` | 600-767px | Large phones |
| `tablet` | 768-1023px | Tablets |
| `desktop` | 1024-1439px | Desktop |
| `desktopLarge` | ≥1440px | Large desktop |

---

## 📈 Migration History

### Phase 3.1: Magic Numbers → BoxCalculatorConfig (2025-11-10)

**Migrated From**: `unified_box_calculator.dart` hardcoded values

**Changes**:
- Extracted 34+ constants to `BoxCalculatorConfig`
- Added 6 helper methods
- Eliminated 90% code duplication across 3 container types
- Improved maintainability and testability

**Commit**: `917e5aee` (Phase 3 Completion)

### Phase 3.2: Magic Numbers → ResponsiveConfig (2025-11-10)

**Migrated From**: `responsive_breakpoints.dart` hardcoded values

**Changes**:
- Extracted 50+ constants to `ResponsiveConfig`
- Organized by device tier (6 device types)
- Added text-to-image ratio helper constant
- Centralized all device-specific measurements

**Commit**: `917e5aee` (Phase 3 Completion)

---

## 🔗 Related Documentation

- **[Main README](../README.md)**: Complete box sizing service overview
- **[Models README](../models/README.md)**: BoxSizes data class reference
- **[CLAUDE.md](../../../CLAUDE.md)**: Project architecture and patterns

---

**Last Updated**: 2025-11-10
**Maintainer**: Versus Space Development Team
**Config Version**: v1.0.0
