# Box Sizing Models

Data models for box size calculation results.

## 📋 Table of Contents

- [Overview](#-overview)
- [BoxSizes Class](#-boxsizes-class)
  - [Properties](#properties)
  - [Getters](#getters)
  - [Methods](#methods)
- [Usage Examples](#-usage-examples)
- [Backward Compatibility](#-backward-compatibility)

---

## 🎯 Overview

This directory contains the data models returned by box size calculation operations. Currently, there is one primary model:

**`BoxSizes`**: Immutable data class containing calculated box dimensions, layout information, and helper methods.

---

## 📦 BoxSizes Class

**File**: `box_sizes.dart` (re-exports from `unified_box_calculator.dart`)

**Purpose**: Encapsulates the complete result of a box size calculation, including dimensions for both A and B boxes, layout metadata, and convenience accessors.

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `sizeA` | `Size` | Calculated dimensions for Box A (width × height) |
| `sizeB` | `Size` | Calculated dimensions for Box B (width × height) |
| `layoutType` | `LayoutType` | Layout arrangement (horizontal/vertical/single) |
| `containerType` | `String` | Container type ("message"/"notification"/"question") |
| `spacing` | `double` | Gap between boxes in pixels |
| `unifiedHeight` | `double` | Unified height used for both boxes in pixels |
| `boxWidth` | `double` | Width of boxes in pixels |

**Constructor**:
```dart
const BoxSizes({
  required this.sizeA,
  required this.sizeB,
  required this.layoutType,
  required this.containerType,
  required this.spacing,
  required this.unifiedHeight,
  required this.boxWidth,
});
```

---

### Getters

#### Layout Checks

| Getter | Return Type | Description |
|--------|-------------|-------------|
| `isHorizontal` | `bool` | Returns `true` if layout is horizontal |
| `isVertical` | `bool` | Returns `true` if layout is vertical |
| `isSingle` | `bool` | Returns `true` if single image or one box is Size.zero |

**Example**:
```dart
final boxSizes = UnifiedBoxCalculator.calculateForMessageCard(...);

if (boxSizes.isHorizontal) {
  // Render boxes side-by-side
} else if (boxSizes.isVertical) {
  // Stack boxes vertically
} else {
  // Show single box
}
```

#### Convenience Accessors

| Getter | Return Type | Description | Equivalent To |
|--------|-------------|-------------|---------------|
| `boxWidthA` | `double` | Width of Box A | `sizeA.width` |
| `boxHeightA` | `double` | Height of Box A | `sizeA.height` |
| `boxWidthB` | `double` | Width of Box B | `sizeB.width` |
| `boxHeightB` | `double` | Height of Box B | `sizeB.height` |

**Example**:
```dart
// Direct property access
print('Box A: ${boxSizes.sizeA.width} × ${boxSizes.sizeA.height}');

// Convenience getter (equivalent)
print('Box A: ${boxSizes.boxWidthA} × ${boxSizes.boxHeightA}');
```

#### Legacy Getters (Backward Compatibility)

| Getter | Return Type | Replacement | Status |
|--------|-------------|-------------|--------|
| `boxA` | `Size` | `sizeA` | Deprecated, use `sizeA` |
| `boxB` | `Size` | `sizeB` | Deprecated, use `sizeB` |

#### Calculated Getters

##### `containerSize` → `Size`

Returns the total container size including both boxes and spacing.

**Calculation Logic**:
- **Single Layout**: Returns `sizeA` (or `sizeB` if A is zero)
- **Horizontal Layout**: `Size(sizeA.width + sizeB.width + spacing, unifiedHeight)`
- **Vertical Layout**: `Size(boxWidth, sizeA.height + sizeB.height + spacing)`

**Example**:
```dart
final boxSizes = UnifiedBoxCalculator.calculateForMessageCard(
  bubbleWidth: 300,
  layoutType: LayoutType.horizontal,
  aspectRatioA: 1.5,
  aspectRatioB: 1.5,
);

print(boxSizes.containerSize);
// Output: Size(303.0, 200.0)
// Calculation: (147.5 + 147.5 + 8.0, 200.0)
```

##### `hasUnifiedSize` → `bool`

Returns `true` if both boxes have the same dimensions (within 1 pixel tolerance).

**Calculation Logic**:
- If either box is `Size.zero`: Returns `true` (only one box, so unified)
- Otherwise: Checks if height and width differences are <1.0 pixel

**Example**:
```dart
// Case 1: Unified heights (both landscape 2:1)
final boxSizes1 = UnifiedBoxCalculator.calculateForMessageCard(
  bubbleWidth: 300,
  layoutType: LayoutType.horizontal,
  aspectRatioA: 2.0,
  aspectRatioB: 2.0,
);
print(boxSizes1.hasUnifiedSize); // true (both are 147.5 × 73.75)

// Case 2: Different aspect ratios
final boxSizes2 = UnifiedBoxCalculator.calculateForMessageCard(
  bubbleWidth: 300,
  layoutType: LayoutType.horizontal,
  aspectRatioA: 2.0,  // Landscape
  aspectRatioB: 0.5,  // Portrait
);
print(boxSizes2.hasUnifiedSize); // true (unified height algorithm applied)
```

---

### Methods

#### `toString()` → `String`

Returns detailed debug information about box sizes.

**Output Format**:
```
BoxSizes(
  Container: message
  Layout: horizontal
  SizeA: 147.5 x 200.0
  SizeB: 147.5 x 200.0
  Unified: true
  Container Size: 303.0 x 200.0
)
```

**Example**:
```dart
final boxSizes = UnifiedBoxCalculator.calculateForMessageCard(...);
print(boxSizes); // Prints formatted debug info
```

#### `shortDescription` → `String`

Returns concise one-line description of box sizes.

**Output Format**: `BoxSizes(containerType, layoutName, A: WxH, B: WxH)`

**Example**:
```dart
final boxSizes = UnifiedBoxCalculator.calculateForMessageCard(...);
print(boxSizes.shortDescription);
// Output: "BoxSizes(message, horizontal, A: 148x200, B: 148x200)"
```

---

## 💡 Usage Examples

### Example 1: Chat Message with Two Images

```dart
final boxSizes = UnifiedBoxCalculator.calculateForMessageCard(
  bubbleWidth: 300,
  layoutType: LayoutType.horizontal,
  aspectRatioA: 1.5,  // Landscape (3:2)
  aspectRatioB: 0.8,  // Portrait (4:5)
);

// Access dimensions
print('Box A: ${boxSizes.sizeA}'); // Size(147.5, 200.0)
print('Box B: ${boxSizes.sizeB}'); // Size(147.5, 200.0)

// Layout checks
print('Is horizontal? ${boxSizes.isHorizontal}'); // true

// Container info
print('Total container size: ${boxSizes.containerSize}'); // Size(303.0, 200.0)
print('Spacing between boxes: ${boxSizes.spacing}'); // 8.0
```

### Example 2: Voting Dialog with Single Image

```dart
final boxSizes = UnifiedBoxCalculator.calculateForNotificationDialog(
  dialogWidth: 350,
  layoutType: LayoutType.single,
  aspectRatioA: 1.77, // 16:9 video
  hasImageA: true,
  hasImageB: false,
);

// Single image check
print('Is single? ${boxSizes.isSingle}'); // true
print('Box A: ${boxSizes.sizeA}'); // Size(332.5, 187.9)
print('Box B: ${boxSizes.sizeB}'); // Size.zero
print('Container: ${boxSizes.containerSize}'); // Size(332.5, 187.9)
```

### Example 3: Creation Page with Vertical Layout

```dart
final boxSizes = UnifiedBoxCalculator.calculateForQuestion(
  containerWidth: 400,
  layoutType: LayoutType.vertical,
  aspectRatioA: 2.0,  // Wide image
  aspectRatioB: 1.5,  // Standard image
);

// Vertical layout
print('Is vertical? ${boxSizes.isVertical}'); // true
print('Box A: ${boxSizes.sizeA}'); // Size(380.0, 190.0)
print('Box B: ${boxSizes.sizeB}'); // Size(380.0, 190.0)
print('Total height: ${boxSizes.containerSize.height}'); // 392.0 (190 + 190 + 12)
```

### Example 4: Debugging with toString()

```dart
final boxSizes = UnifiedBoxCalculator.calculateForMessageCard(
  bubbleWidth: 300,
  layoutType: LayoutType.vertical,
  aspectRatioA: 1.0,  // Square
  aspectRatioB: 1.0,  // Square
);

// Full debug output
print(boxSizes);
// Output:
// BoxSizes(
//   Container: message
//   Layout: vertical
//   SizeA: 285.0 x 171.0
//   SizeB: 285.0 x 171.0
//   Unified: true
//   Container Size: 285.0 x 354.0
// )

// Short description
print(boxSizes.shortDescription);
// Output: "BoxSizes(message, vertical, A: 285x171, B: 285x171)"
```

---

## 🔄 Backward Compatibility

### Legacy Getters

The following getters are provided for backward compatibility with older code:

```dart
// ❌ Old code (deprecated but still works)
final boxA = boxSizes.boxA; // Returns sizeA
final boxB = boxSizes.boxB; // Returns sizeB

// ✅ New code (preferred)
final boxA = boxSizes.sizeA;
final boxB = boxSizes.sizeB;
```

### Migration Path

If you're updating old code that uses `boxA` and `boxB`:

1. Search for `.boxA` usage: `grep -r "\.boxA" lib/`
2. Replace with `.sizeA`
3. Search for `.boxB` usage: `grep -r "\.boxB" lib/`
4. Replace with `.sizeB`

---

## 🔗 Related Documentation

- **[Main README](../README.md)**: Complete box sizing service overview
- **[Config README](../config/README.md)**: Configuration constants reference
- **[UnifiedBoxCalculator](../unified_box_calculator.dart)**: Box size calculation engine

---

**Last Updated**: 2025-11-10
**Version**: v1.0.0
**Status**: Stable
