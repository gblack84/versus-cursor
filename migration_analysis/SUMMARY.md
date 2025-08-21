# Snake Case Migration Analysis Report
Generated: Thu Aug 21 21:42:29 KST 2025

## 📊 Statistics

| Category | Count |
|----------|-------|
| Total unique snake_case fields |      765 |
| JavaScript files affected |     8001 |
| Dart files affected |      272 |
| Configuration files affected |      314 |

## 🔝 Top 10 Most Frequent Fields

- **node_modules** → nodeUmodules (606 occurrences)
- **app_utils** → appUutils (116 occurrences)
- **app_theme** → appUtheme (52 occurrences)
- **firebase_auth** → firebaseUauth (49 occurrences)
- **user_id** → userUid (43 occurrences)
- **firestore_util** → firestoreUutil (42 occurrences)
- **auth_util** → authUutil (35 occurrences)
- **google_fonts** → googleUfonts (33 occurrences)
- **design_system** → designUsystem (29 occurrences)
- **created_at** → createdUat (29 occurrences)

## 📁 Output Files

- `unique_snake_fields.txt` - All unique snake_case fields
- `field_mappings.txt` - Snake to camel mappings
- `frequency_analysis.txt` - Usage frequency analysis
- `location_report.txt` - Detailed file locations
- `js_patterns.txt` - JavaScript occurrences
- `dart_patterns.txt` - Dart model occurrences

## 🚀 Next Steps

1. Review the field mappings in `field_mappings.txt`
2. Run the migration scripts in order:
   - Phase 1: Firestore Rules
   - Phase 2: Firestore Indexes
   - Phase 3: Firebase Functions
   - Phase 4: Flutter Models
3. Validate with the test suite
