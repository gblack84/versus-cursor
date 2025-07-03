# Fixed Utility Functions and Extensions

## Summary of Changes to `/lib/core/app_utils.dart`

### Added Missing Imports
1. `import 'dart:convert' show jsonEncode, jsonDecode;` - Fixed undefined jsonEncode function
2. `import 'lat_lng.dart';` - Fixed undefined LatLng type

### Added Missing Extensions

1. **IterableNullableExt** - Extension for `Iterable<T?>`
   - `withoutNulls` getter: Filters out null values and returns `List<T>`
   - Used in: `lib/backend/schema/util/schema_util.dart` for `getColorsList`

2. **DoubleExtension** - Extension for `double`
   - `divide(double divisor)` method: Safe division that returns 0.0 if divisor is 0
   - Provides safe division operations throughout the app

3. **StringCapitalizationExt** - Extension for `String`
   - `toCapitalization(TextCapitalization)` method: Applies text capitalization rules
   - Used in: `lib/createaccount/phoneauth/phone_creat_account/phone_creat_account_widget.dart`
   - Supports: words, sentences, characters, and none capitalization modes

4. **ColorExtension** - Extension for `Color`
   - `applyAlpha(double factor)` method: Applies alpha factor to color (0.0 to 1.0)
   - Used in: `lib/core/upload_data.dart` for UI styling

### Added Missing Utility Functions

1. **fixStatusBarOniOS16AndBelow(BuildContext context)**
   - Fixes status bar appearance issues on iOS 16 and below
   - Used in: `lib/core/nav/nav.dart` during navigation
   - Applies appropriate status bar style based on theme brightness

## Files That Were Fixed
- `/lib/backend/schema/util/schema_util.dart` - withoutNulls for color lists
- `/lib/core/upload_data.dart` - applyAlpha for color opacity
- `/lib/createaccount/phoneauth/phone_creat_account/phone_creat_account_widget.dart` - toCapitalization for text
- `/lib/core/nav/nav.dart` - fixStatusBarOniOS16AndBelow for iOS compatibility

All missing utility functions and extensions have been successfully added to the codebase.