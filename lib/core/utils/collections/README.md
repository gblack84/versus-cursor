# Collection Extensions - Core Utils

Extensions for List, Map, Iterable, String, Double, Color, and other Dart types.

## 📋 Table of Contents

- [Overview](#overview)
- [List Extensions](#list-extensions)
- [Map Extensions](#map-extensions)
- [Iterable Extensions](#iterable-extensions)
- [TextEditingController Extension](#texteditingcontroller-extension)
- [Firestore Extension](#firestore-extension)
- [Double Extensions](#double-extensions)
- [String Extensions](#string-extensions)
- [Color Extension](#color-extension)
- [Performance Characteristics](#performance-characteristics)
- [Real-World Examples](#real-world-examples)
- [Testing](#testing)
- [See Also](#see-also)

---

## Overview

### Purpose

The `collections/` directory provides extension methods for Dart and Flutter core types, enabling more expressive and functional code patterns. These extensions eliminate boilerplate and provide common operations out of the box.

### Statistics

- **File**: `collection_extensions.dart` (267 lines)
- **Total Extensions**: 15 methods across 9 types
- **Usage**: ~10 occurrences across features (grid layouts, serialization, sorting)

### Quick Reference

| Type | Extensions | Use Cases |
|------|-----------|-----------|
| **List** | filterList, chunk, divide, addToStart, addToEnd, sortedList | Grid layouts, pagination, separators |
| **Map** | withoutNulls | JSON serialization, API responses |
| **Iterable** | sortedList, mapIndexed, withoutNulls | Sorting, indexing, filtering |
| **TextEditingController** | text getter/setter | Safe null handling |
| **Firestore** | ref (DEPRECATED) | Document references |
| **Double** | toStringAsFixedNoZero, divide | Formatting, safe math |
| **String** | toCapitalization | Text formatting |
| **Color** | applyAlpha | Color opacity |

---

## List Extensions

### Overview

**6 extension methods** for `List<T>` manipulation:
1. `filterList` - Filter with predicate
2. `chunk` - Split into chunks
3. `divide` - Insert separators
4. `addToStart` - Prepend item
5. `addToEnd` - Append item
6. `sortedList` - Sort by key (inherited from Iterable)

---

### filterList()

```dart
List<T> filterList(bool Function(T element) filter)
```

**Purpose**: Filter list elements using a predicate function.

**Returns**: New list with elements that satisfy the predicate.

**Example**:
```dart
final numbers = [1, 2, 3, 4, 5];
final evens = numbers.filterList((n) => n % 2 == 0);
// Returns: [2, 4]

final users = [user1, user2, user3];
final admins = users.filterList((u) => u.isAdmin);
// Returns: [user1, user3] (if user1, user3 are admins)
```

**Alternative**: Use `where().toList()` directly (this is a convenience wrapper)
```dart
// filterList is equivalent to:
final result = list.where((e) => filter(e)).toList();
```

---

### chunk()

```dart
List<List<T>> chunk(int chunkSize)
```

**Purpose**: Split list into chunks of specified size (useful for grid layouts, pagination).

**Parameters**:
- `chunkSize`: Size of each chunk

**Returns**: List of lists (chunks)

**Example**:
```dart
final items = [1, 2, 3, 4, 5, 6, 7];
final chunks = items.chunk(3);
// Returns: [[1, 2, 3], [4, 5, 6], [7]]

// Real-world: Grid layout with 2 columns
final widgets = [widget1, widget2, widget3, widget4, widget5];
final rows = widgets.chunk(2);
// Returns: [[widget1, widget2], [widget3, widget4], [widget5]]

Column(
  children: rows.map((row) {
    return Row(
      children: row,
    );
  }).toList(),
)
```

**Performance**: O(n) time, O(n) space

---

### divide()

```dart
List<T> divide(T separator)
```

**Purpose**: Insert separator between all elements (useful for UI separators).

**Parameters**:
- `separator`: Element to insert between items

**Returns**: New list with separators inserted

**Example**:
```dart
final items = [1, 2, 3];
final withSeparator = items.divide(0);
// Returns: [1, 0, 2, 0, 3]

// Real-world: Insert dividers between widgets
final widgets = [widget1, widget2, widget3];
final withDividers = widgets.divide(Divider());
// Returns: [widget1, Divider(), widget2, Divider(), widget3]

Column(
  children: withDividers,
)
```

**Edge Case**: Empty list returns empty list
```dart
[].divide(0);  // Returns: []
```

**Performance**: O(n) time, O(n) space

---

### addToStart()

```dart
List<T> addToStart(T item)
```

**Purpose**: Prepend item to list (returns new list, does not mutate).

**Parameters**:
- `item`: Element to prepend

**Returns**: New list with item at start

**Example**:
```dart
final list = [2, 3, 4];
final result = list.addToStart(1);
// Returns: [1, 2, 3, 4]
// Original list unchanged: [2, 3, 4]

// Real-world: Add "All" option to filter list
final categories = ['Sports', 'Tech', 'Music'];
final withAll = categories.addToStart('All');
// Returns: ['All', 'Sports', 'Tech', 'Music']
```

**Alternative**: Use spread operator directly
```dart
final result = [item, ...list];
```

**Performance**: O(n) time, O(n) space

---

### addToEnd()

```dart
List<T> addToEnd(T item)
```

**Purpose**: Append item to list (returns new list, does not mutate).

**Parameters**:
- `item`: Element to append

**Returns**: New list with item at end

**Example**:
```dart
final list = [1, 2, 3];
final result = list.addToEnd(4);
// Returns: [1, 2, 3, 4]

// Real-world: Add "Other" option to dropdown
final options = ['Option 1', 'Option 2'];
final withOther = options.addToEnd('Other');
// Returns: ['Option 1', 'Option 2', 'Other']
```

**Alternative**: Use spread operator directly
```dart
final result = [...list, item];
```

**Performance**: O(n) time, O(n) space

---

## Map Extensions

### withoutNulls

```dart
Map<String, dynamic> get withoutNulls
```

**Purpose**: Remove null values from map (useful for JSON serialization, Firestore writes).

**Returns**: New map with null values removed

**Example**:
```dart
final userData = {
  'name': 'John',
  'age': 30,
  'email': null,
  'city': 'Seoul',
  'phone': null,
};

final clean = userData.withoutNulls;
// Returns: {'name': 'John', 'age': 30, 'city': 'Seoul'}

// Real-world: Clean JSON before API call
final requestBody = {
  'title': 'My Post',
  'description': userInput,  // May be null
  'tags': selectedTags,      // May be null
}.withoutNulls;

// Send only non-null fields
await api.post('/posts', body: requestBody);
```

**Firestore Usage**:
```dart
// Before: Sends null fields to Firestore (wastes space)
await firestore.collection('users').doc(userId).set({
  'displayName': 'John',
  'email': null,  // Unnecessary field
  'photoURL': null,  // Unnecessary field
});

// After: Only sends non-null fields
await firestore.collection('users').doc(userId).set({
  'displayName': 'John',
  'email': email,
  'photoURL': photoURL,
}.withoutNulls);
```

**Performance**: O(n) time, O(n) space

---

## Iterable Extensions

### sortedList()

```dart
List<T> sortedList<S extends Comparable>({
  S Function(T)? keyOf,
  bool desc = false,
})
```

**Purpose**: Sort iterable by key function (immutable, returns new list).

**Parameters**:
- `keyOf` (optional): Function to extract comparable key from element
- `desc` (optional): Sort in descending order. Default: false (ascending)

**Returns**: New sorted list

**Example**:
```dart
// Sort numbers
final numbers = [3, 1, 4, 1, 5];
final sorted = numbers.sortedList();
// Returns: [1, 1, 3, 4, 5]

// Sort by key (user age)
final users = [user1, user2, user3];
final sortedByAge = users.sortedList(keyOf: (u) => u.age);
// Returns: users sorted by age ascending

// Sort descending
final sortedDesc = users.sortedList(keyOf: (u) => u.age, desc: true);
// Returns: users sorted by age descending

// Sort by string (name)
final sortedByName = users.sortedList(keyOf: (u) => u.name);
// Returns: users sorted by name alphabetically
```

**Real-World Example**:
```dart
// Sort posts by creation date (newest first)
final posts = [post1, post2, post3];
final sortedPosts = posts.sortedList(
  keyOf: (p) => p.createdAt.millisecondsSinceEpoch,
  desc: true,
);
```

**Performance**: O(n log n) time (QuickSort), O(n) space

---

### mapIndexed()

```dart
List<S> mapIndexed<S>(S Function(int index, T element) func)
```

**Purpose**: Map with index (useful for numbered lists, indexed operations).

**Parameters**:
- `func`: Function that takes index and element, returns transformed value

**Returns**: New list of transformed elements

**Example**:
```dart
final items = ['a', 'b', 'c'];
final indexed = items.mapIndexed((i, e) => '$i: $e');
// Returns: ['0: a', '1: b', '2: c']

// Real-world: Numbered list
final tasks = ['Buy groceries', 'Clean room', 'Study'];
final numberedTasks = tasks.mapIndexed((i, task) => '${i + 1}. $task');
// Returns: ['1. Buy groceries', '2. Clean room', '3. Study']

// Real-world: Row with alternating colors
final rows = items.mapIndexed((i, item) {
  return Container(
    color: i % 2 == 0 ? Colors.grey[200] : Colors.white,
    child: Text(item),
  );
});
```

**Performance**: O(n) time, O(n) space

---

### withoutNulls (Iterable)

```dart
List<T> get withoutNulls  // on Iterable<T?>
```

**Purpose**: Remove null values from nullable iterable (casts to non-nullable).

**Returns**: New list with nulls removed, cast to `List<T>` (non-nullable)

**Example**:
```dart
final items = [1, null, 2, null, 3];
final cleaned = items.withoutNulls;
// Returns: [1, 2, 3] (type: List<int>)

// Real-world: Filter null users from query
final userIds = ['uid1', 'uid2', 'uid3'];
final users = await Future.wait(
  userIds.map((id) => getUserOrNull(id)),  // May return null
);
// users type: List<User?>

final validUsers = users.withoutNulls;
// validUsers type: List<User> (non-nullable!)
```

**Performance**: O(n) time, O(n) space

---

## TextEditingController Extension

### text getter/setter

```dart
String get text  // on TextEditingController?
set text(String newText)
```

**Purpose**: Safe access to text property on nullable `TextEditingController`.

**Returns**:
- Getter: Text value, or empty string if controller is null
- Setter: Sets text value, or no-op if controller is null

**Example**:
```dart
TextEditingController? controller;  // May be null

// Without extension (unsafe):
// final text = controller.text;  // ERROR: Null check operator used on null
// controller.text = 'New text';  // ERROR: Null check operator used on null

// With extension (safe):
final text = controller.text;  // Returns: ''
controller.text = 'New text';  // No-op if null

// Real-world: Safe form field access
class MyForm extends StatefulWidget {
  @override
  State<MyForm> createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  TextEditingController? _nameController;

  @override
  void initState() {
    super.initState();
    // Controller may not be initialized yet
  }

  void _onSubmit() {
    final name = _nameController.text;  // Safe! Returns '' if null
    if (name.isNotEmpty) {
      submitForm(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _nameController,
      onChanged: (_) => _onSubmit(),
    );
  }
}
```

**Performance**: O(1) time, O(1) space

---

## Firestore Extension

### ref (DEPRECATED)

```dart
@Deprecated('Use FirebaseFirestore.instance.doc() directly')
DocumentReference get ref  // on String
```

**Purpose**: Convert string path to Firestore DocumentReference.

**⚠️ DEPRECATED**: Use `FirebaseFirestore.instance.doc()` directly instead.

**Example (Deprecated)**:
```dart
// Old way (deprecated):
final ref = 'users/123'.ref;
// Returns: DocumentReference

// New way (recommended):
final ref = FirebaseFirestore.instance.doc('users/123');
```

**Migration**:
```dart
// Before:
final userRef = 'users/$userId'.ref;
await userRef.set(userData);

// After:
final userRef = FirebaseFirestore.instance.doc('users/$userId');
await userRef.set(userData);
```

**Deprecation Date**: 2025-11-11
**Removal Date**: 2026-02-01 (3 months)

---

## Double Extensions

### toStringAsFixedNoZero()

```dart
String toStringAsFixedNoZero(int fractionDigits)
```

**Purpose**: Convert double to fixed decimal string, removing trailing zeros.

**Parameters**:
- `fractionDigits`: Number of decimal places

**Returns**: String with no trailing zeros

**Example**:
```dart
1.50.toStringAsFixedNoZero(2);  // Returns: "1.5"
1.00.toStringAsFixedNoZero(2);  // Returns: "1"
1.23.toStringAsFixedNoZero(2);  // Returns: "1.23"

// Real-world: Display price without unnecessary zeros
final price = 9.00;
Text('$${price.toStringAsFixedNoZero(2)}');
// Displays: "$9" (not "$9.00")

final price2 = 9.99;
Text('$${price2.toStringAsFixedNoZero(2)}');
// Displays: "$9.99"
```

**Performance**: O(1) time, O(1) space

---

### divide()

```dart
double divide(double divisor)
```

**Purpose**: Safe division with zero-check (prevents divide-by-zero errors).

**Parameters**:
- `divisor`: Number to divide by

**Returns**: `this / divisor` if divisor != 0, otherwise 0.0

**Example**:
```dart
10.0.divide(2.0);  // Returns: 5.0
10.0.divide(0.0);  // Returns: 0.0 (safe! no exception)

// Real-world: Calculate average
final sum = 100.0;
final count = 0;  // May be zero!

final average = sum.divide(count.toDouble());
// Returns: 0.0 (safe, no crash)

// Without divide():
// final average = sum / count;  // ERROR: Division by zero!
```

**Performance**: O(1) time, O(1) space

---

## String Extensions

### toCapitalization()

```dart
String toCapitalization(TextCapitalization capitalization)
```

**Purpose**: Apply Flutter's `TextCapitalization` enum to string.

**Parameters**:
- `capitalization`: TextCapitalization enum value
  - `TextCapitalization.words`: Capitalize first letter of each word
  - `TextCapitalization.sentences`: Capitalize first letter of string
  - `TextCapitalization.characters`: All uppercase
  - `TextCapitalization.none`: No change

**Returns**: Capitalized string

**Example**:
```dart
// Words capitalization
'hello world'.toCapitalization(TextCapitalization.words);
// Returns: "Hello World"

// Sentences capitalization
'hello world'.toCapitalization(TextCapitalization.sentences);
// Returns: "Hello world"

// Characters capitalization
'hello world'.toCapitalization(TextCapitalization.characters);
// Returns: "HELLO WORLD"

// No capitalization
'HELLO WORLD'.toCapitalization(TextCapitalization.none);
// Returns: "HELLO WORLD" (unchanged)

// Real-world: Format user input
final userInput = 'john doe';
final formattedName = userInput.toCapitalization(TextCapitalization.words);
// Returns: "John Doe"
```

**Edge Cases**:
```dart
''.toCapitalization(TextCapitalization.words);  // Returns: ''
'a'.toCapitalization(TextCapitalization.words);  // Returns: "A"
```

**Performance**: O(n) time, O(n) space

---

## Color Extension

### applyAlpha()

```dart
Color applyAlpha(double factor)
```

**Purpose**: Apply alpha (opacity) factor to color.

**Parameters**:
- `factor`: Alpha multiplier (0.0-1.0)

**Returns**: New color with modified alpha

**Example**:
```dart
Colors.red.applyAlpha(0.5);  // 50% opacity
Colors.blue.applyAlpha(0.8);  // 80% opacity
Colors.green.applyAlpha(0.0);  // Fully transparent

// Real-world: Hover effect
Container(
  color: isHovered
      ? Colors.blue.applyAlpha(0.8)
      : Colors.blue,
  child: Text('Hover me'),
)

// Real-world: Overlay
Container(
  color: Colors.black.applyAlpha(0.3),  // 30% black overlay
  child: Stack(
    children: [
      Image.network(imageUrl),
      // Overlay content
    ],
  ),
)
```

**Performance**: O(1) time, O(1) space

---

## Performance Characteristics

### Time Complexity

| Extension | Time Complexity | Notes |
|-----------|-----------------|-------|
| **filterList** | O(n) | Linear scan |
| **chunk** | O(n) | Single pass |
| **divide** | O(n) | Single pass |
| **addToStart/addToEnd** | O(n) | Creates new list |
| **sortedList** | O(n log n) | QuickSort algorithm |
| **mapIndexed** | O(n) | Single pass |
| **withoutNulls** | O(n) | Filter + cast |
| **toStringAsFixedNoZero** | O(1) | String manipulation |
| **divide** | O(1) | Arithmetic |
| **toCapitalization** | O(n) | String scanning |
| **applyAlpha** | O(1) | Color manipulation |

### Space Complexity

All extensions create new collections (immutable), so space complexity is **O(n)** for collection operations, **O(1)** for scalar operations.

### Immutability

**All extensions are immutable** - they return new objects without modifying originals.

```dart
// Original list unchanged
final list = [1, 2, 3];
final chunked = list.chunk(2);
// list: [1, 2, 3] (unchanged)
// chunked: [[1, 2], [3]] (new)
```

---

## Real-World Examples

### Example 1: Grid Layout with chunk()

**Scenario**: Display items in a 2-column grid

```dart
import '/core/utils/app_utils.dart';

class GridView extends StatelessWidget {
  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    // Chunk items into rows of 2
    final rows = items.chunk(2);

    return Column(
      children: rows.map((row) {
        return Row(
          children: row.map((item) {
            return Expanded(
              child: ItemCard(item: item),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

// Result:
// [item1] [item2]
// [item3] [item4]
// [item5]
```

---

### Example 2: Clean JSON with withoutNulls

**Scenario**: Submit form data to API, excluding null fields

```dart
import '/core/utils/app_utils.dart';

class CreatePostForm extends StatefulWidget {
  @override
  State<CreatePostForm> createState() => _CreatePostFormState();
}

class _CreatePostFormState extends State<CreatePostForm> {
  String? title;
  String? description;
  List<String>? tags;

  Future<void> _onSubmit() async {
    // Build request body
    final requestBody = {
      'title': title,
      'description': description,
      'tags': tags,
      'createdAt': DateTime.now().toIso8601String(),
    }.withoutNulls;  // Remove null fields

    // Send only non-null fields
    await FirebaseFirestore.instance
        .collection('posts')
        .add(requestBody);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: (value) => title = value.isEmpty ? null : value,
          decoration: InputDecoration(labelText: 'Title'),
        ),
        TextField(
          onChanged: (value) => description = value.isEmpty ? null : value,
          decoration: InputDecoration(labelText: 'Description (optional)'),
        ),
        ElevatedButton(
          onPressed: _onSubmit,
          child: Text('Submit'),
        ),
      ],
    );
  }
}

// Result:
// If description is empty:
// requestBody = {
//   'title': 'My Post',
//   'createdAt': '2025-11-13T12:00:00.000Z',
// }
// (description excluded)
```

---

### Example 3: Sort Users with sortedList()

**Scenario**: Display users sorted by age descending

```dart
import '/core/utils/app_utils.dart';

class UserListWidget extends StatelessWidget {
  final List<User> users;

  @override
  Widget build(BuildContext context) {
    // Sort by age descending (oldest first)
    final sortedUsers = users.sortedList(
      keyOf: (u) => u.age,
      desc: true,
    );

    return ListView.builder(
      itemCount: sortedUsers.length,
      itemBuilder: (context, index) {
        final user = sortedUsers[index];
        return ListTile(
          title: Text(user.name),
          subtitle: Text('Age: ${user.age}'),
        );
      },
    );
  }
}

// Result:
// John (50)
// Jane (35)
// Bob (28)
```

---

## Testing

### Unit Tests

**Location**: `test/core/utils/collections/`

**Test File**: `collection_extensions_test.dart`

**Example Tests**:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/core/utils/collections/collection_extensions.dart';

void main() {
  group('List Extensions', () {
    test('chunk divides list correctly', () {
      final list = [1, 2, 3, 4, 5];
      final result = list.chunk(2);
      expect(result, [[1, 2], [3, 4], [5]]);
    });

    test('chunk handles empty list', () {
      final list = <int>[];
      final result = list.chunk(2);
      expect(result, []);
    });

    test('divide inserts separator', () {
      final list = [1, 2, 3];
      final result = list.divide(0);
      expect(result, [1, 0, 2, 0, 3]);
    });
  });

  group('Map Extensions', () {
    test('withoutNulls removes null values', () {
      final map = {'a': 1, 'b': null, 'c': 3};
      final result = map.withoutNulls;
      expect(result, {'a': 1, 'c': 3});
    });
  });

  group('Iterable Extensions', () {
    test('sortedList sorts by key', () {
      final users = [
        User(name: 'John', age: 30),
        User(name: 'Jane', age: 25),
        User(name: 'Bob', age: 35),
      ];
      final result = users.sortedList(keyOf: (u) => u.age);
      expect(result.map((u) => u.age), [25, 30, 35]);
    });

    test('mapIndexed provides index', () {
      final list = ['a', 'b', 'c'];
      final result = list.mapIndexed((i, e) => '$i: $e');
      expect(result, ['0: a', '1: b', '2: c']);
    });
  });
}
```

---

## See Also

### Related Documentation

- 📄 [/lib/core/utils/README.md](../README.md) - Core utils overview
- 📄 [/lib/core/utils/datetime/README.md](../datetime/README.md) - DateTime utilities *(Phase 2.2 - Next)*
- 📄 [/lib/core/utils/helpers/README.md](../helpers/README.md) - Debounce, FormFieldController ✅

### Dart/Flutter Documentation

- [Dart Extensions](https://dart.dev/guides/language/extension-methods) - Official Dart extension methods guide
- [List Class](https://api.dart.dev/stable/dart-core/List-class.html) - Dart List API
- [Map Class](https://api.dart.dev/stable/dart-core/Map-class.html) - Dart Map API
- [Iterable Class](https://api.dart.dev/stable/dart-core/Iterable-class.html) - Dart Iterable API

---

**Last Updated**: 2025-11-13
**Maintainer**: Core Utils Layer
**Version**: 1.0.0
**Status**: Production Ready ✅ (Phase 2.1 Complete)

**Summary**:
- 📚 **15 Extension Methods** across 9 types
- 🎯 **Most Used**: chunk (grid layouts), withoutNulls (JSON), sortedList (sorting)
- ⚡ **Performance**: O(n) for collections, O(1) for scalars
- 🔒 **Immutability**: All extensions return new objects
- ⚠️ **Deprecated**: Firestore `ref` extension (use FirebaseFirestore.instance.doc())
