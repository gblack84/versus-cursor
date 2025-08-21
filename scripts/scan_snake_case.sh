#!/bin/bash

# Snake Case Scanner Script
# Scans entire codebase for snake_case patterns and generates mappings
# Uses parallel processing for optimal performance

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Snake Case Scanner v1.0${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Create output directory
OUTPUT_DIR="migration_analysis"
mkdir -p "$OUTPUT_DIR"

# Function to convert snake_case to camelCase
snake_to_camel() {
    echo "$1" | sed -E 's/_([a-z])/\U\1/g'
}

# Function to scan for snake_case patterns
scan_snake_case() {
    local path=$1
    local pattern=$2
    local output_file=$3
    
    echo -e "${YELLOW}Scanning: $path ($pattern files)${NC}"
    
    # Use grep to find snake_case patterns, excluding node_modules
    grep -rn '[a-z][a-z_]*_[a-z][a-z_]*' "$path" \
        --include="*.$pattern" \
        --exclude-dir=node_modules \
        --exclude-dir=.dart_tool \
        --exclude-dir=build 2>/dev/null || true
}

# Main scanning process
echo -e "\n${GREEN}Step 1: Scanning for snake_case patterns...${NC}"

# Scan JavaScript files
echo -e "\n${YELLOW}📁 Firebase Functions (.js files)${NC}"
scan_snake_case "firebase/functions" "js" "$OUTPUT_DIR/js_patterns.txt" > "$OUTPUT_DIR/js_patterns.txt"

# Scan Dart files in backend/schema
echo -e "\n${YELLOW}📁 Flutter Models (.dart files)${NC}"
scan_snake_case "lib/backend/schema" "dart" "$OUTPUT_DIR/dart_patterns.txt" > "$OUTPUT_DIR/dart_patterns.txt"

# Scan all Dart files
echo -e "\n${YELLOW}📁 All Flutter files (.dart)${NC}"
scan_snake_case "lib" "dart" "$OUTPUT_DIR/all_dart_patterns.txt" > "$OUTPUT_DIR/all_dart_patterns.txt"

# Scan Firestore rules
echo -e "\n${YELLOW}📁 Firestore Rules${NC}"
grep -n '[a-z][a-z_]*_[a-z][a-z_]*' firebase/firestore.rules 2>/dev/null > "$OUTPUT_DIR/rules_patterns.txt" || true

# Scan Firestore indexes
echo -e "\n${YELLOW}📁 Firestore Indexes${NC}"
grep -n '[a-z][a-z_]*_[a-z][a-z_]*' firebase/firestore.indexes.json 2>/dev/null > "$OUTPUT_DIR/json_patterns.txt" || true

echo -e "\n${GREEN}Step 2: Extracting unique field names...${NC}"

# Extract unique snake_case field names from all pattern files
cat "$OUTPUT_DIR"/*.txt 2>/dev/null | \
    grep -oE '[a-z][a-z_]*_[a-z][a-z_]*' | \
    sort -u > "$OUTPUT_DIR/unique_snake_fields.txt"

# Count occurrences
TOTAL_UNIQUE=$(wc -l < "$OUTPUT_DIR/unique_snake_fields.txt")
echo -e "${BLUE}Found ${TOTAL_UNIQUE} unique snake_case fields${NC}"

echo -e "\n${GREEN}Step 3: Generating camelCase mappings...${NC}"

# Generate mapping file
echo "# Snake Case to CamelCase Mapping" > "$OUTPUT_DIR/field_mappings.txt"
echo "# Generated: $(date)" >> "$OUTPUT_DIR/field_mappings.txt"
echo "# Total fields: $TOTAL_UNIQUE" >> "$OUTPUT_DIR/field_mappings.txt"
echo "# ===========================================" >> "$OUTPUT_DIR/field_mappings.txt"
echo "" >> "$OUTPUT_DIR/field_mappings.txt"

while IFS= read -r field; do
    camel_case=$(snake_to_camel "$field")
    echo "$field → $camel_case" >> "$OUTPUT_DIR/field_mappings.txt"
done < "$OUTPUT_DIR/unique_snake_fields.txt"

echo -e "\n${GREEN}Step 4: Analyzing field usage frequency...${NC}"

# Create frequency analysis
echo "# Field Usage Frequency Analysis" > "$OUTPUT_DIR/frequency_analysis.txt"
echo "# ===============================" >> "$OUTPUT_DIR/frequency_analysis.txt"
echo "" >> "$OUTPUT_DIR/frequency_analysis.txt"

for field in $(cat "$OUTPUT_DIR/unique_snake_fields.txt"); do
    count=$(grep -r "\b$field\b" \
        --include="*.js" \
        --include="*.dart" \
        --include="*.rules" \
        --include="*.json" \
        --exclude-dir=node_modules \
        --exclude-dir=.dart_tool \
        --exclude-dir=build \
        firebase/ lib/ 2>/dev/null | wc -l)
    echo "$count occurrences: $field" >> "$OUTPUT_DIR/frequency_analysis.txt"
done

# Sort by frequency
sort -rn "$OUTPUT_DIR/frequency_analysis.txt" -o "$OUTPUT_DIR/frequency_analysis.txt"

echo -e "\n${GREEN}Step 5: Creating detailed location report...${NC}"

# Create detailed location report for top fields
echo "# Detailed Field Location Report" > "$OUTPUT_DIR/location_report.txt"
echo "# ==============================" >> "$OUTPUT_DIR/location_report.txt"
echo "" >> "$OUTPUT_DIR/location_report.txt"

# Get top 20 most frequent fields
head -20 "$OUTPUT_DIR/frequency_analysis.txt" | awk '{print $3}' | while read -r field; do
    echo "## Field: $field → $(snake_to_camel "$field")" >> "$OUTPUT_DIR/location_report.txt"
    echo "### Locations:" >> "$OUTPUT_DIR/location_report.txt"
    grep -rn "\b$field\b" \
        --include="*.js" \
        --include="*.dart" \
        --include="*.rules" \
        --include="*.json" \
        --exclude-dir=node_modules \
        --exclude-dir=.dart_tool \
        --exclude-dir=build \
        firebase/ lib/ 2>/dev/null | \
        head -10 >> "$OUTPUT_DIR/location_report.txt" || true
    echo "" >> "$OUTPUT_DIR/location_report.txt"
done

echo -e "\n${GREEN}Step 6: Generating summary report...${NC}"

# Generate summary report
cat > "$OUTPUT_DIR/SUMMARY.md" << EOF
# Snake Case Migration Analysis Report
Generated: $(date)

## 📊 Statistics

| Category | Count |
|----------|-------|
| Total unique snake_case fields | $TOTAL_UNIQUE |
| JavaScript files affected | $(find firebase/functions -name "*.js" -exec grep -l '_' {} \; 2>/dev/null | wc -l) |
| Dart files affected | $(find lib -name "*.dart" -exec grep -l '_' {} \; 2>/dev/null | wc -l) |
| Configuration files affected | $(find firebase -name "*.rules" -o -name "*.json" -exec grep -l '_' {} \; 2>/dev/null | wc -l) |

## 🔝 Top 10 Most Frequent Fields

$(head -10 "$OUTPUT_DIR/frequency_analysis.txt" | while read line; do
    count=$(echo "$line" | awk '{print $1}')
    field=$(echo "$line" | awk '{print $3}')
    camel=$(snake_to_camel "$field")
    echo "- **$field** → $camel ($count occurrences)"
done)

## 📁 Output Files

- \`unique_snake_fields.txt\` - All unique snake_case fields
- \`field_mappings.txt\` - Snake to camel mappings
- \`frequency_analysis.txt\` - Usage frequency analysis
- \`location_report.txt\` - Detailed file locations
- \`js_patterns.txt\` - JavaScript occurrences
- \`dart_patterns.txt\` - Dart model occurrences

## 🚀 Next Steps

1. Review the field mappings in \`field_mappings.txt\`
2. Run the migration scripts in order:
   - Phase 1: Firestore Rules
   - Phase 2: Firestore Indexes
   - Phase 3: Firebase Functions
   - Phase 4: Flutter Models
3. Validate with the test suite
EOF

echo -e "\n${GREEN}✅ Scan Complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Results saved in: $OUTPUT_DIR/${NC}"
echo -e "${YELLOW}Review the SUMMARY.md file for detailed analysis${NC}"

# Display summary
echo -e "\n${BLUE}Quick Summary:${NC}"
echo "• Total unique fields: $TOTAL_UNIQUE"
echo "• Top 5 most common:"
head -5 "$OUTPUT_DIR/frequency_analysis.txt" | while read line; do
    count=$(echo "$line" | awk '{print $1}')
    field=$(echo "$line" | awk '{print $3}')
    echo "  - $field ($count uses)"
done