# Box Sizing Service

> **Purpose**: Unified box size calculation for A vs B image layouts
> **Primary Use**: Chat messages, notification dialogs, question creation
> **Key Feature**: Container-aware responsive sizing with aspect ratio analysis

---

## 📚 Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [API Reference](#api-reference)
- [Configuration](#configuration)
- [Architecture Patterns](#architecture-patterns)
- [Examples](#examples)
- [Testing](#testing)
- [Performance](#performance)
- [Migration History](#migration-history)
- [Troubleshooting](#troubleshooting)
- [Related Documentation](#related-documentation)

---

## Overview

The Box Sizing Service provides a **unified interface** for calculating optimal box dimensions for A vs B image/media comparisons across different UI contexts.

### Core Problem

When displaying two images side-by-side or stacked (A vs B comparison), we need to:
1. Calculate appropriate box sizes based on container width
2. Handle different image aspect ratios gracefully
3. Apply container-specific constraints (message cards vs dialogs vs full-screen)
4. Unify heights when images have different ratios
5. Support responsive design across devices

### Solution

`UnifiedBoxCalculator` provides a single calculation engine with:
- **3 Container Types**: Message Card, Notification Dialog, Question
- **3 Layout Types**: Horizontal, Vertical, Single
- **Aspect Ratio Analysis**: Optimal layout detection
- **Responsive Breakpoints**: Device-specific sizing
- **Centralized Config**: All magic numbers in config classes

### Core Components

```
box_sizing/
├── unified_box_calculator.dart     # Main calculation engine (555 lines)
├── aspect_ratio_analyzer.dart      # Layout optimization (130 lines)
├── responsive_breakpoints.dart     # Device breakpoints (184 lines)
├── models/
│   └── box_sizes.dart              # Result data structure (3 lines)
└── config/
    ├── box_calculator_config.dart  # Box calculation constants (430 lines)
    └── responsive_config.dart      # Responsive constants (273 lines)
```

**Total**: 1,575 lines of production code

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│          Presentation Layer (Feature-Specific)              │
│  • chat/presentation/screens/chat_message_builder.dart      │
│  • voting/presentation/dialogs/voting_dialog_content.dart   │
│  • creation/presentation/providers/media_selection.dart     │
└──────────────────┬──────────────────────────────────────────┘
                   │ Calls Feature-specific adapter
                   ▼
┌─────────────────────────────────────────────────────────────┐
│            Data Layer (Feature-Specific Adapter)            │
│  • chat/data/adapters/box_calculator_adapter.dart           │
│    → calculateForMessageCard()                              │
│  • voting/data/adapters/box_calculator_adapter.dart         │
│    → calculateForNotificationDialog()                       │
│  • creation/data/adapters/box_calculator_adapter.dart       │
│    → calculateForQuestion()                                 │
└──────────────────┬──────────────────────────────────────────┘
                   │ Wraps UnifiedBoxCalculator (Services)
                   ▼
┌─────────────────────────────────────────────────────────────┐
│              Services Layer (Global Infrastructure)         │
│  • services/box_sizing/unified_box_calculator.dart          │
│    → calculateForMessageCard() [Chat-specific method]       │
│    → calculateForNotificationDialog() [Voting-specific]     │
│    → calculateForQuestion() [Creation-specific]             │
│    → calculate() [General method with containerType]        │
└──────────────────┬──────────────────────────────────────────┘
                   │ References BoxCalculatorConfig
                   ▼
┌─────────────────────────────────────────────────────────────┐
│       Config Layer (Centralized Constants)                  │
│  • services/box_sizing/config/box_calculator_config.dart    │
│    → 34+ constants for all 3 Features                       │
│    → Migrated from layout_constants.dart (917e5aee)         │
└─────────────────────────────────────────────────────────────┘
```

---

## Quick Start

### Basic Usage

```dart
import '/core/utils/ui/box_sizing/unified_box_calculator.dart';

// Calculate for message card (Chat Feature)
final boxSizes = UnifiedBoxCalculator.calculateForMessageCard(
  bubbleWidth: 300,
  layoutType: LayoutType.horizontal,
  aspectRatioA: 1.5,  // Landscape image
  aspectRatioB: 0.8,  // Portrait image
);

print(boxSizes.sizeA);       // Size(147.5, 200.0)
print(boxSizes.sizeB);       // Size(147.5, 200.0)
print(boxSizes.spacing);     // 8.0
print(boxSizes.containerSize); // Size(303.0, 200.0)
```

### Container Types

The service supports 3 container types, each optimized for different UI contexts:

#### 1. Message Card (`calculateForMessageCard`)

**Context**: Chat bubble in messaging UI

**Characteristics**:
- Compact sizing (max 400px)
- 80% width for single images (smaller than other types)
- Optimized for mobile screens
- Frequent usage in Chat Feature

**Constraints**:
```dart
Single Max:     400px
Horizontal Max: 400px (per box)
Vertical Total: 350px (171px per box)
```

**Usage**:
```dart
final boxSizes = UnifiedBoxCalculator.calculateForMessageCard(
  bubbleWidth: 300,
  layoutType: LayoutType.vertical,
  aspectRatioA: 2.0,
  aspectRatioB: 1.8,
);
```

#### 2. Notification Dialog (`calculateForNotificationDialog`)

**Context**: Modal dialog for voting notifications

**Characteristics**:
- Larger sizing (max 500px single)
- 95% width utilization (more breathing room)
- Dialog-optimized constraints
- Used in Voting Feature

**Constraints**:
```dart
Single Max:     500px (+100px vs message)
Horizontal Max: 400px (same as message)
Vertical Total: 350px (same as message)
```

**Usage**:
```dart
final boxSizes = UnifiedBoxCalculator.calculateForNotificationDialog(
  dialogWidth: 400,
  layoutType: LayoutType.horizontal,
  aspectRatioA: 0.6,
  aspectRatioB: 0.7,
);
```

#### 3. Question Container (`calculateForQuestion`)

**Context**: Question creation page (full-screen)

**Characteristics**:
- Maximum space utilization (600px single)
- Flexible constraints
- Full-screen context
- Used in Creation Feature

**Constraints**:
```dart
Single Max:     600px (largest allowed)
Horizontal Max: 500px (+100px vs others)
Vertical Max:   400px (+50px vs others)
```

**Usage**:
```dart
final boxSizes = UnifiedBoxCalculator.calculateForQuestion(
  containerWidth: 360,
  layoutType: LayoutType.single,
  aspectRatioA: 1.33,
);
```

### Layout Types

#### Horizontal Layout
- **Use Case**: Side-by-side display (landscape images)
- **Width**: Each box gets 49.5% of available width (after spacing)
- **Spacing**: 8px between boxes

```dart
┌────────┐ 8px ┌────────┐
│ Box A  │ gap │ Box B  │
│        │     │        │
└────────┘     └────────┘
```

#### Vertical Layout
- **Use Case**: Top-bottom stacking (portrait images)
- **Width**: Each box gets 95% of full width
- **Spacing**: 12px between boxes

```dart
┌──────────────┐
│   Box A      │
└──────────────┘
     12px gap
┌──────────────┐
│   Box B      │
└──────────────┘
```

#### Single Layout
- **Use Case**: One image only
- **Width**: 95% of container (centered)
- **Spacing**: N/A

```dart
   ┌──────────────┐
   │   Box A      │
   │              │
   └──────────────┘
```

---

## API Reference

### UnifiedBoxCalculator

#### `calculateForMessageCard()`

Calculate box sizes for chat message cards.

```dart
static BoxSizes calculateForMessageCard({
  required double bubbleWidth,
  required LayoutType layoutType,
  double? aspectRatioA,
  double? aspectRatioB,
  bool hasImageA = true,
  bool hasImageB = true,
})
```

**Parameters**:
- `bubbleWidth` (required): Width of chat bubble container
- `layoutType` (required): Layout pattern (horizontal/vertical/single)
- `aspectRatioA` (optional): Image A aspect ratio (width / height)
- `aspectRatioB` (optional): Image B aspect ratio (width / height)
- `hasImageA` (default: true): Whether Image A exists
- `hasImageB` (default: true): Whether Image B exists

**Returns**: `BoxSizes` with calculated dimensions

**Constraints Applied**:
- Single max: 400px
- Horizontal max: 400px (per box)
- Vertical total max: 350px (171px per box)
- Default aspect ratio: 1.5 (3:2)

**Example**:
```dart
final boxSizes = UnifiedBoxCalculator.calculateForMessageCard(
  bubbleWidth: 300,
  layoutType: LayoutType.horizontal,
  aspectRatioA: 1.5,
  aspectRatioB: 0.8,
);

print(boxSizes.sizeA);  // Size(147.5, 200.0)
print(boxSizes.sizeB);  // Size(147.5, 200.0) - Unified height
```

---

#### `calculateForNotificationDialog()`

Calculate box sizes for notification dialogs.

```dart
static BoxSizes calculateForNotificationDialog({
  required double dialogWidth,
  required LayoutType layoutType,
  double? aspectRatioA,
  double? aspectRatioB,
  bool hasImageA = true,
  bool hasImageB = true,
})
```

**Parameters**: Same as `calculateForMessageCard()`, except `dialogWidth` instead of `bubbleWidth`

**Constraints Applied**:
- Single max: 500px
- Horizontal max: 400px (per box)
- Vertical total max: 350px (171px per box)
- Default aspect ratio: 1.5 (3:2)

**Example**:
```dart
final boxSizes = UnifiedBoxCalculator.calculateForNotificationDialog(
  dialogWidth: 400,
  layoutType: LayoutType.vertical,
  aspectRatioA: 2.0,
  aspectRatioB: 1.8,
);

print(boxSizes.sizeA);  // Size(380, 171)
print(boxSizes.sizeB);  // Size(380, 171) - Unified height
print(boxSizes.spacing); // 8.0
print(boxSizes.containerSize); // Size(380, 350)
```

---

#### `calculateForQuestion()`

Calculate box sizes for question creation.

```dart
static BoxSizes calculateForQuestion({
  required double containerWidth,
  required LayoutType layoutType,
  double? aspectRatioA,
  double? aspectRatioB,
  bool hasImageA = true,
  bool hasImageB = true,
})
```

**Parameters**: Same as `calculateForMessageCard()`, except `containerWidth` instead of `bubbleWidth`

**Constraints Applied**:
- Single max: 600px (largest)
- Horizontal max: 500px (per box)
- Vertical max: 400px (per box)
- Default aspect ratio: 1.0 (square)

**Example**:
```dart
final boxSizes = UnifiedBoxCalculator.calculateForQuestion(
  containerWidth: 360,
  layoutType: LayoutType.single,
  aspectRatioA: 1.33,
);

print(boxSizes.sizeA);  // Size(342, 257) - 95% width
print(boxSizes.isSingle); // true
```

---

#### `calculate()` (General Method)

General calculation method with explicit container type.

```dart
static BoxSizes calculate({
  required double containerWidth,
  double? containerHeight,
  required String containerType,
  required LayoutType layoutType,
  double? aspectRatioA,
  double? aspectRatioB,
  bool hasImageA = true,
  bool hasImageB = true,
})
```

**Additional Parameters**:
- `containerHeight` (optional): Container height (used for notification dialog)
- `containerType` (required): 'message', 'notification', or 'question'

**Usage**:
```dart
final boxSizes = UnifiedBoxCalculator.calculate(
  containerWidth: 300,
  containerType: BoxCalculatorConfig.containerTypeMessage,
  layoutType: LayoutType.horizontal,
  aspectRatioA: 1.5,
);
```

---

### AspectRatioAnalyzer

#### `getOptimalLayout()`

Determine optimal layout based on image aspect ratios.

```dart
static LayoutType getOptimalLayout(
  double? ratioA,
  double? ratioB,
)
```

**Parameters**:
- `ratioA` (optional): Image A aspect ratio
- `ratioB` (optional): Image B aspect ratio

**Returns**: `LayoutType` (horizontal/vertical/single)

**Decision Logic**:
```
Both landscape (>1.3)  → Vertical layout
Both portrait (<0.75)  → Horizontal layout
Mixed                  → Based on more extreme ratio
One null               → Single layout
```

**Example**:
```dart
final layout = AspectRatioAnalyzer.getOptimalLayout(2.0, 1.8);
print(layout); // LayoutType.vertical (both landscape)

final layout2 = AspectRatioAnalyzer.getOptimalLayout(0.6, 0.7);
print(layout2); // LayoutType.horizontal (both portrait)
```

---

#### `getOrientation()`

Classify image orientation.

```dart
static ImageOrientation getOrientation(double aspectRatio)
```

**Parameters**:
- `aspectRatio` (required): Image aspect ratio (width / height)

**Returns**: `ImageOrientation` enum

**Classification**:
```
≥ 1.3  → ImageOrientation.landscape
≤ 0.75 → ImageOrientation.portrait
else   → ImageOrientation.square
```

---

### ResponsiveBreakpoints

#### `getMaxMessageWidth()`

Get maximum message width for current device.

```dart
static double getMaxMessageWidth(BuildContext context)
```

**Parameters**:
- `context` (required): Build context for MediaQuery

**Returns**: Maximum width in pixels

**Device Breakpoints**:
```
Mobile Small (<320px):  85% of screen
Mobile (320-414px):     80% of screen
Tablet (414-1024px):    500px fixed
Desktop (≥1024px):      600px fixed
Desktop Large (≥1440px):700px fixed
```

**Example**:
```dart
final maxWidth = ResponsiveBreakpoints.getMaxMessageWidth(context);
print(maxWidth); // 500.0 on tablet
```

---

#### `getDeviceType()`

Get current device type.

```dart
static DeviceType getDeviceType(BuildContext context)
```

**Returns**: `DeviceType` enum (mobileSmall, mobile, mobileLarge, tablet, desktop, desktopLarge)

---

### BoxSizes (Result Model)

Result data structure returned by all calculation methods.

```dart
class BoxSizes {
  final Size sizeA;           // Image A size
  final Size sizeB;           // Image B size
  final LayoutType layoutType; // Layout pattern
  final String containerType;  // Container context
  final double spacing;        // Gap between boxes
  final double unifiedHeight;  // Unified box height
  final double boxWidth;       // Box width

  // Computed properties
  bool get isHorizontal;       // Horizontal layout?
  bool get isVertical;         // Vertical layout?
  bool get isSingle;           // Single image?
  Size get containerSize;      // Total container size
  bool get hasUnifiedSize;     // Boxes are same size?
}
```

**Key Properties**:

- `sizeA` / `sizeB`: Calculated box sizes (`Size.zero` if image doesn't exist)
- `layoutType`: Applied layout (horizontal/vertical/single)
- `containerType`: Container context ('message', 'notification', 'question')
- `spacing`: Gap between boxes (8px horizontal, 12px vertical)
- `unifiedHeight`: Final unified height (average of A and B)
- `boxWidth`: Width of each box

**Computed Properties**:

- `isHorizontal` / `isVertical` / `isSingle`: Layout type checks
- `containerSize`: Total size including both boxes and spacing
- `hasUnifiedSize`: True if both boxes have same dimensions (within 1px)

**Example**:
```dart
final boxSizes = UnifiedBoxCalculator.calculateForMessageCard(
  bubbleWidth: 300,
  layoutType: LayoutType.horizontal,
  aspectRatioA: 1.5,
  aspectRatioB: 0.8,
);

print(boxSizes.sizeA);           // Size(147.5, 200.0)
print(boxSizes.isHorizontal);    // true
print(boxSizes.containerSize);   // Size(303.0, 200.0) - includes spacing
print(boxSizes.hasUnifiedSize);  // true - heights are unified
print(boxSizes.shortDescription); // "BoxSizes(message, horizontal, A: 148x200, B: 148x200)"
```

---

## Configuration

All magic numbers are centralized in config classes to maintain Single Source of Truth.

### Key Constants

```dart
// Message Card (Chat)
BoxCalculatorConfig.messageCardSingleMaxHeight = 400.0;
BoxCalculatorConfig.messageCardHorizontalMaxHeight = 400.0;
BoxCalculatorConfig.messageCardVerticalTotalMaxHeight = 350.0;
BoxCalculatorConfig.messageCardSingleWidthRatio = 0.8; // 80%

// Notification Dialog (Voting)
BoxCalculatorConfig.notificationDialogSingleMaxHeight = 500.0; // +100px
BoxCalculatorConfig.notificationDialogHorizontalMaxHeight = 400.0;

// Question Container (Creation)
BoxCalculatorConfig.questionContainerSingleMaxHeight = 600.0; // Largest
BoxCalculatorConfig.questionContainerHorizontalMaxHeight = 500.0;

// Responsive
ResponsiveConfig.mobileMessageWidthRatio = 0.80; // 80%
ResponsiveConfig.tabletMessageMaxWidth = 500.0;
ResponsiveConfig.desktopMessageMaxWidth = 600.0;
```

For complete documentation, see:
- [Box Calculator Config](config/README.md)
- [Responsive Config](config/README.md#responsive-config)

---

## Architecture Patterns

### Adapter Pattern (Clean Architecture)

Features use adapters to maintain Clean Architecture boundaries and enable testability.

**Feature Domain Layer** (Interface):
```dart
// lib/features/chat/domain/services/i_box_calculator_service.dart
abstract interface class IBoxCalculatorService {
  BoxSizesData calculateForMessageCard({
    required double bubbleWidth,
    required LayoutType layoutType,
    double? aspectRatioA,
    double? aspectRatioB,
  });
}
```

**Feature Data Layer** (Adapter):
```dart
// lib/features/chat/data/adapters/box_calculator_adapter.dart
class BoxCalculatorAdapter implements IBoxCalculatorService {
  @override
  BoxSizesData calculateForMessageCard({...}) {
    final result = UnifiedBoxCalculator.calculateForMessageCard(...);
    return _convertToBoxSizesData(result);
  }

  BoxSizesData _convertToBoxSizesData(BoxSizes boxSizes) {
    return BoxSizesData(
      sizeA: boxSizes.sizeA,
      sizeB: boxSizes.sizeB,
      // ... convert to feature-specific data model
    );
  }
}
```

**Feature DI Module**:
```dart
// lib/features/chat/di/chat_di_module.dart
void setupChatDI(GetIt getIt) {
  getIt.registerSingleton<IBoxCalculatorService>(
    BoxCalculatorAdapter(),
  );
}
```

**Benefits**:
- ✅ **Testability**: Mock `IBoxCalculatorService` in unit tests
- ✅ **Separation**: Features don't directly depend on services layer
- ✅ **Flexibility**: Easy to swap implementations

**Features Using This Pattern**:
- Chat Feature: `chat/data/adapters/box_calculator_adapter.dart`
- Creation Feature: `creation/data/adapters/box_calculator_adapter.dart`
- Voting Feature: `voting/data/adapters/box_calculator_adapter.dart`

---

### Direct Usage (Presentation Layer)

Some features import directly from presentation layer for convenience.

```dart
// lib/features/chat/presentation/screens/chat_message_builder.dart
import '/core/utils/ui/box_sizing/unified_box_calculator.dart';

final boxSizes = UnifiedBoxCalculator.calculateForMessageCard(
  bubbleWidth: constraints.maxWidth,
  layoutType: layoutType,
  aspectRatioA: aspectRatioA,
  aspectRatioB: aspectRatioB,
);
```

**Trade-offs**:
- ✅ **Simpler**: No adapter boilerplate
- ✅ **Direct**: Less indirection
- ❌ **Coupling**: Tighter coupling to services layer
- ❌ **Testing**: Harder to mock

---

## Examples

### Example 1: Chat Message with Landscape Images

**Scenario**: Two wide landscape images in vertical layout

```dart
final boxSizes = UnifiedBoxCalculator.calculateForMessageCard(
  bubbleWidth: 300,
  layoutType: LayoutType.vertical,
  aspectRatioA: 2.0,  // Wide image (2:1)
  aspectRatioB: 1.8,  // Wide image (1.8:1)
);

// Calculation Steps:
// 1. Width = 300 * 0.95 = 285px (vertical uses 95%)
// 2. Height A = 285 / 2.0 = 142.5px
// 3. Height B = 285 / 1.8 = 158.3px
// 4. Unified = (142.5 + 158.3) / 2 = 150.4px
// 5. Clamp to max 171px (vertical: 350 total / 2)

// Result:
// sizeA: 285×150.4
// sizeB: 285×150.4
// spacing: 12px (vertical)
// Total: 285×312.8 (150.4 + 12 + 150.4)
```

---

### Example 2: Notification Dialog with Portrait Images

**Scenario**: Two tall portrait images in horizontal layout

```dart
final boxSizes = UnifiedBoxCalculator.calculateForNotificationDialog(
  dialogWidth: 400,
  layoutType: LayoutType.horizontal,
  aspectRatioA: 0.6,  // Tall image (3:5)
  aspectRatioB: 0.7,  // Tall image (7:10)
);

// Calculation Steps:
// 1. Available width = 400 - 8 = 392px
// 2. Box width = 392 * 0.495 = 194px each
// 3. Height A = 194 / 0.6 = 323px
// 4. Height B = 194 / 0.7 = 277px
// 5. Unified = (323 + 277) / 2 = 300px
// 6. Clamp to max 400px (horizontal max)

// Result:
// sizeA: 194×300
// sizeB: 194×300
// spacing: 8px
// Total: 396×300 (194 + 8 + 194)
```

---

### Example 3: Question Creation with Single Image

**Scenario**: One standard photo in creation page

```dart
final boxSizes = UnifiedBoxCalculator.calculateForQuestion(
  containerWidth: 360,
  layoutType: LayoutType.single,
  aspectRatioA: 1.33,  // Standard photo (4:3)
);

// Calculation Steps:
// 1. Width = 360 * 0.95 = 342px (single uses 95%)
// 2. Height = 342 / 1.33 = 257px
// 3. Clamp to max 600px (single max - not needed)

// Result:
// sizeA: 342×257
// sizeB: 0×0 (no second image)
// spacing: 8px
// Total: 342×257
```

---

### Example 4: Automatic Layout Detection

**Scenario**: Let AspectRatioAnalyzer decide optimal layout

```dart
final aspectRatioA = 2.0;  // Landscape
final aspectRatioB = 1.8;  // Landscape

// Step 1: Detect optimal layout
final layoutType = AspectRatioAnalyzer.getOptimalLayout(
  aspectRatioA,
  aspectRatioB,
);
print(layoutType); // LayoutType.vertical (both landscape)

// Step 2: Calculate with detected layout
final boxSizes = UnifiedBoxCalculator.calculateForMessageCard(
  bubbleWidth: 300,
  layoutType: layoutType,  // Use detected layout
  aspectRatioA: aspectRatioA,
  aspectRatioB: aspectRatioB,
);

print(boxSizes.sizeA); // Size(285, 150)
```

---

## Testing

### Unit Tests

```bash
# Run all box sizing tests
flutter test test/core/utils/ui/box_sizing/

# Run specific test file
flutter test test/core/utils/ui/box_sizing/unified_box_calculator_test.dart
```

### Integration Tests

Box sizing is tested through feature integration tests:

```bash
# Chat Feature tests
flutter test test/features/chat/

# Creation Feature tests
flutter test test/features/creation/

# Voting Feature tests
flutter test test/features/voting/
```

### Test Coverage

Current coverage (estimated):
- UnifiedBoxCalculator: 85%
- AspectRatioAnalyzer: 90%
- ResponsiveBreakpoints: 75%

---

## Performance

### Benchmarks

- **Calculation time**: <1ms (pure Dart math, no async)
- **Memory footprint**: ~50 bytes per BoxSizes instance
- **Cache-friendly**: Stateless pure functions

### Optimization Tips

1. **Cache aspect ratios**: Calculate once, reuse
   ```dart
   // ✅ Good
   final aspectRatio = image.width / image.height;
   final boxSizes1 = calculate(..., aspectRatioA: aspectRatio);
   final boxSizes2 = calculate(..., aspectRatioA: aspectRatio);

   // ❌ Bad
   final boxSizes1 = calculate(..., aspectRatioA: image.width / image.height);
   final boxSizes2 = calculate(..., aspectRatioA: image.width / image.height);
   ```

2. **Pre-calculate dimensions**: For fixed-size containers
   ```dart
   // ✅ Good (calculate once in initState)
   late final BoxSizes fixedBoxSizes;

   @override
   void initState() {
     fixedBoxSizes = UnifiedBoxCalculator.calculateForMessageCard(...);
   }
   ```

3. **Avoid repeated MediaQuery**: Cache results
   ```dart
   // ✅ Good
   final screenWidth = MediaQuery.of(context).size.width;
   final boxSizes1 = calculate(containerWidth: screenWidth * 0.8, ...);
   final boxSizes2 = calculate(containerWidth: screenWidth * 0.9, ...);

   // ❌ Bad
   final boxSizes1 = calculate(
     containerWidth: MediaQuery.of(context).size.width * 0.8, ...);
   final boxSizes2 = calculate(
     containerWidth: MediaQuery.of(context).size.width * 0.9, ...);
   ```

---

## Migration History

### Phase 3.1: Box Calculator Config Extraction (2025-11-10)

**Commit**: [Current commit]

Extracted all magic numbers from `UnifiedBoxCalculator` to `BoxCalculatorConfig`.

**Changes**:
- **Before**: 60+ magic numbers scattered in calculation logic
- **After**: 60+ named constants in config class (430 lines)
- **Files Changed**: 2 files (unified_box_calculator.dart, box_calculator_config.dart)

**Benefits**:
- ✅ Single Source of Truth
- ✅ Easy to update constraints
- ✅ Better documentation
- ✅ Type-safe constants

---

### Phase 3.2: Responsive Config Extraction (2025-11-10)

**Commit**: [Current commit]

Extracted all magic numbers from `ResponsiveBreakpoints` to `ResponsiveConfig`.

**Changes**:
- **Before**: 50+ magic numbers in breakpoint logic
- **After**: 50+ named constants in config class (273 lines)
- **Files Changed**: 2 files (responsive_breakpoints.dart, responsive_config.dart)

---

### Directory Rename: services/ui/ → services/box_sizing/ (2025-11-10)

**Commit**: [Current commit]

Renamed directory to better reflect purpose (box size calculation).

**Changes**:
- **Directory**: `services/ui/` → `services/box_sizing/`
- **Files Changed**: 16 files (import updates)
- **Migration Time**: 1-2 hours
- **Breaking Changes**: None (internal refactoring only)

**Benefits**:
- ✅ **Clarity**: Name immediately communicates purpose
- ✅ **Accuracy**: Matches 66% primary content (box calculation)
- ✅ **Discoverability**: Developers instantly understand directory contents

---

### v1.0: Initial Implementation (2025-11)

Unified box calculation logic across 3 features (Chat, Creation, Voting).

**Previous State**: Each feature had its own box calculation logic with duplicated code.

**Changes**:
- Created `UnifiedBoxCalculator` as single calculation engine
- Extracted common logic from 3 features
- Applied Adapter Pattern for Clean Architecture

---

## Troubleshooting

### Issue: Boxes are too small

**Symptoms**: Calculated box sizes are smaller than expected

**Possible Causes**:
1. Aspect ratio < 1.0 with min height constraint
2. Container width too narrow
3. Incorrect layout type selected

**Solutions**:
```dart
// Check min height constraints in BoxCalculatorConfig
BoxCalculatorConfig.messageCardHorizontalMinHeight; // 200px

// Increase container width
final boxSizes = calculate(containerWidth: 400, ...); // instead of 300

// Try different layout type
layoutType: LayoutType.vertical // instead of horizontal
```

---

### Issue: Boxes exceed container

**Symptoms**: Calculated box sizes overflow container

**Cause**: Vertical layout with two tall images

**Solution**: `UnifiedBoxCalculator` automatically scales to 88% of container height

```dart
// Automatic scaling for vertical layout
if (!isHorizontal && hasImageA && hasImageB && containerHeight != null) {
  final totalRequiredHeight = (unifiedHeight * 2) + spacing;
  final maxAvailableHeight = containerHeight * 0.88; // 88% usage

  if (totalRequiredHeight > maxAvailableHeight) {
    final scalingFactor = maxAvailableHeight / totalRequiredHeight;
    unifiedHeight *= scalingFactor;
  }
}
```

**Verify**: Pass `containerHeight` parameter (Notification Dialog only)

---

### Issue: Different box sizes (non-unified)

**Symptoms**: `boxSizes.hasUnifiedSize` returns `false`

**Possible Causes**:
1. Single image mode (`hasImageA` or `hasImageB` is false)
2. Incorrect `hasImageA` / `hasImageB` flags

**Solutions**:
```dart
// Verify flags
final boxSizes = calculate(
  hasImageA: imageA != null,  // ✅ Correct
  hasImageB: imageB != null,  // ✅ Correct
);

// Check result
if (!boxSizes.hasUnifiedSize) {
  print('Box A: ${boxSizes.sizeA}');
  print('Box B: ${boxSizes.sizeB}');
  print('Is single: ${boxSizes.isSingle}');
}
```

---

### Issue: Unexpected layout type

**Symptoms**: Layout is not what you expected (e.g., vertical instead of horizontal)

**Cause**: `AspectRatioAnalyzer` logic may choose different layout

**Solution**: Understand the detection logic or specify layout explicitly

```dart
// Let analyzer decide (may surprise you)
final layout = AspectRatioAnalyzer.getOptimalLayout(ratioA, ratioB);

// Or specify explicitly
final boxSizes = calculate(
  layoutType: LayoutType.horizontal, // Force horizontal
  aspectRatioA: ratioA,
  aspectRatioB: ratioB,
);
```

**Detection Logic**:
```
Both landscape (>1.3)  → Vertical (stack to avoid squishing)
Both portrait (<0.75)  → Horizontal (side-by-side saves space)
Mixed                  → Based on more extreme ratio
```

---

## Contributing

When modifying box sizing logic:

1. **Update config first**: Add/modify constants in config classes
   ```dart
   // lib/core/utils/ui/box_sizing/config/box_calculator_config.dart
   static const double myNewMaxHeight = 450.0;
   ```

2. **Update calculation logic**: Use the new constant
   ```dart
   // lib/core/utils/ui/box_sizing/unified_box_calculator.dart
   maxHeight = BoxCalculatorConfig.myNewMaxHeight;
   ```

3. **Update tests**: Ensure existing tests pass
   ```bash
   flutter test test/core/utils/ui/box_sizing/
   ```

4. **Update adapters**: If API changes, update all 3 feature adapters
   - `chat/data/adapters/box_calculator_adapter.dart`
   - `creation/data/adapters/box_calculator_adapter.dart`
   - `voting/data/adapters/box_calculator_adapter.dart`

5. **Update docs**: Keep this README synchronized
   - API Reference section
   - Examples section
   - Configuration section

---

## Related Documentation

- **[Config README](config/README.md)** - Configuration constants reference
- **[Models README](models/README.md)** - BoxSizes model documentation
- **[CLAUDE.md](../../CLAUDE.md)** - Project architecture overview
- **[Chat Feature](../../features/chat/README.md)** - Chat usage examples
- **[Creation Feature](../../features/creation/README.md)** - Question creation usage
- **[Voting Feature](../../features/voting/README.md)** - Voting dialog usage

---

**Last Updated**: 2025-11-10
**Maintainer**: Services Layer
**Version**: 1.0.0
**Status**: Production Ready ✅
