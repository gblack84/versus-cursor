#!/usr/bin/env node

/**
 * Snake Case to CamelCase Mapping Generator
 * Generates comprehensive field mappings with special case handling
 */

const fs = require('fs');
const path = require('path');

// Special case mappings that need manual handling
const SPECIAL_CASES = {
  // IDs and URLs
  'user_id': 'userId',
  'post_id': 'postId',
  'chat_id': 'chatId',
  'notification_id': 'notificationId',
  'photo_url': 'photoUrl',
  'image_url': 'imageUrl',
  'action_url': 'actionUrl',
  'image_url_a': 'imageUrlA',
  'image_url_b': 'imageUrlB',
  'image_urls_a': 'imageUrlsA',
  'image_urls_b': 'imageUrlsB',
  
  // Abbreviations
  'ai_assistant': 'aiAssistant',
  'ai_helper': 'aiHelper',
  'is_read': 'isRead',
  'is_premium_user': 'isPremiumUser',
  'is_notification_enabled': 'isNotificationEnabled',
  
  // Vote related
  'voted_user_ids_a': 'votedUserIdsA',
  'voted_user_ids_b': 'votedUserIdsB',
  'votes_a': 'votesA',
  'votes_b': 'votesB',
  'vote_count_a': 'voteCountA',
  'vote_count_b': 'voteCountB',
  'display_votes_a': 'displayVotesA',
  'display_votes_b': 'displayVotesB',
  'display_percent_a': 'displayPercentA',
  'display_percent_b': 'displayPercentB',
  'actual_votes_a': 'actualVotesA',
  'actual_votes_b': 'actualVotesB',
  
  // Options
  'option_a': 'optionA',
  'option_b': 'optionB',
  
  // Special collections
  'poll_details': 'pollDetails',
  'friends_list': 'friendsList',
  'group_messages': 'groupMessages',
  'group_chats': 'groupChats',
  'premium_users': 'premiumUsers',
  'user_contents': 'userContents',
  'ranked_posts': 'rankedPosts',
  'feed_details': 'feedDetails',
  'content_comments': 'contentComments',
  'contents_likes': 'contentsLikes',
  'contents_interests': 'contentsInterests',
  'contents_shares': 'contentsShares',
  
  // Jobs/Categories
  'jops_name': 'jopsName',
  'jops_category': 'jopsCategory',
  'chat_interest_jops': 'chatInterestJops',
  'chat_history': 'chatHistory',
};

// Convert snake_case to camelCase
function snakeToCamel(str) {
  // Check special cases first
  if (SPECIAL_CASES[str]) {
    return SPECIAL_CASES[str];
  }
  
  // Handle special patterns
  // Keep URLs as URL (uppercase)
  str = str.replace(/_url/g, '_URL');
  
  // Keep IDs as Id
  str = str.replace(/_id/g, '_ID');
  
  // Keep 'is_' prefix pattern
  if (str.startsWith('is_')) {
    return 'is' + str.slice(3).replace(/_([a-z])/g, (m, p1) => p1.toUpperCase());
  }
  
  // Standard conversion
  let camel = str.replace(/_([a-z])/g, (m, p1) => p1.toUpperCase());
  
  // Fix URL and ID
  camel = camel.replace(/URL/g, 'Url');
  camel = camel.replace(/ID/g, 'Id');
  
  return camel;
}

// Read unique fields from scanner output
function readUniqueFields() {
  const filePath = path.join(__dirname, '../migration_analysis/unique_snake_fields.txt');
  
  if (!fs.existsSync(filePath)) {
    console.error('❌ Error: unique_snake_fields.txt not found. Run scan_snake_case.sh first.');
    process.exit(1);
  }
  
  const content = fs.readFileSync(filePath, 'utf8');
  return content.split('\n').filter(line => line.trim());
}

// Generate comprehensive mapping
function generateMappings(fields) {
  const mappings = {};
  const conflicts = [];
  const stats = {
    total: fields.length,
    specialCases: 0,
    standardConversions: 0,
    conflicts: 0
  };
  
  fields.forEach(field => {
    const camelCase = snakeToCamel(field);
    
    // Check for special case
    if (SPECIAL_CASES[field]) {
      stats.specialCases++;
    } else {
      stats.standardConversions++;
    }
    
    // Check for conflicts (different snake_case mapping to same camelCase)
    const existing = Object.entries(mappings).find(([k, v]) => v === camelCase && k !== field);
    if (existing) {
      conflicts.push({
        field1: existing[0],
        field2: field,
        camelCase: camelCase
      });
      stats.conflicts++;
    }
    
    mappings[field] = camelCase;
  });
  
  return { mappings, conflicts, stats };
}

// Generate migration script for a specific file type
function generateMigrationScript(mappings, fileType) {
  let script = '';
  
  switch(fileType) {
    case 'js':
      script = `// JavaScript Migration Script\n`;
      script += `const fieldMappings = ${JSON.stringify(mappings, null, 2)};\n\n`;
      script += `function migrateFields(obj) {\n`;
      script += `  const migrated = {};\n`;
      script += `  for (const [key, value] of Object.entries(obj)) {\n`;
      script += `    const newKey = fieldMappings[key] || key;\n`;
      script += `    migrated[newKey] = value;\n`;
      script += `  }\n`;
      script += `  return migrated;\n`;
      script += `}\n\n`;
      script += `module.exports = { fieldMappings, migrateFields };\n`;
      break;
      
    case 'dart':
      script = `// Dart Migration Script\n`;
      script += `final Map<String, String> fieldMappings = {\n`;
      Object.entries(mappings).forEach(([snake, camel]) => {
        script += `  '${snake}': '${camel}',\n`;
      });
      script += `};\n\n`;
      script += `Map<String, dynamic> migrateFields(Map<String, dynamic> data) {\n`;
      script += `  final migrated = <String, dynamic>{};\n`;
      script += `  data.forEach((key, value) {\n`;
      script += `    final newKey = fieldMappings[key] ?? key;\n`;
      script += `    migrated[newKey] = value;\n`;
      script += `  });\n`;
      script += `  return migrated;\n`;
      script += `}\n`;
      break;
  }
  
  return script;
}

// Main execution
function main() {
  console.log('🔄 Field Mapping Generator');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  
  // Read fields
  console.log('📖 Reading unique fields...');
  const fields = readUniqueFields();
  console.log(`Found ${fields.length} unique snake_case fields`);
  
  // Generate mappings
  console.log('\n🔄 Generating mappings...');
  const { mappings, conflicts, stats } = generateMappings(fields);
  
  // Display stats
  console.log('\n📊 Statistics:');
  console.log(`• Total fields: ${stats.total}`);
  console.log(`• Special cases: ${stats.specialCases}`);
  console.log(`• Standard conversions: ${stats.standardConversions}`);
  console.log(`• Conflicts: ${stats.conflicts}`);
  
  // Display conflicts if any
  if (conflicts.length > 0) {
    console.log('\n⚠️  Mapping Conflicts Detected:');
    conflicts.forEach(conflict => {
      console.log(`  ${conflict.field1} → ${conflict.camelCase}`);
      console.log(`  ${conflict.field2} → ${conflict.camelCase} (conflict!)`);
      console.log('  ---');
    });
  }
  
  // Create output directory
  const outputDir = path.join(__dirname, '../migration_analysis');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }
  
  // Save JSON mapping
  const jsonPath = path.join(outputDir, 'field_mappings.json');
  fs.writeFileSync(jsonPath, JSON.stringify({
    generated: new Date().toISOString(),
    stats: stats,
    conflicts: conflicts,
    mappings: mappings
  }, null, 2));
  console.log(`\n✅ JSON mapping saved to: ${jsonPath}`);
  
  // Generate migration scripts
  const jsScript = generateMigrationScript(mappings, 'js');
  const jsPath = path.join(outputDir, 'migrate_fields.js');
  fs.writeFileSync(jsPath, jsScript);
  console.log(`✅ JavaScript migration script: ${jsPath}`);
  
  const dartScript = generateMigrationScript(mappings, 'dart');
  const dartPath = path.join(outputDir, 'migrate_fields.dart');
  fs.writeFileSync(dartPath, dartScript);
  console.log(`✅ Dart migration script: ${dartPath}`);
  
  // Generate detailed report
  const reportPath = path.join(outputDir, 'MAPPING_REPORT.md');
  let report = `# Field Mapping Report\n`;
  report += `Generated: ${new Date().toISOString()}\n\n`;
  report += `## Statistics\n`;
  report += `- Total fields: ${stats.total}\n`;
  report += `- Special cases: ${stats.specialCases}\n`;
  report += `- Standard conversions: ${stats.standardConversions}\n`;
  report += `- Conflicts: ${stats.conflicts}\n\n`;
  
  if (conflicts.length > 0) {
    report += `## ⚠️ Conflicts\n`;
    conflicts.forEach(conflict => {
      report += `- **${conflict.field1}** and **${conflict.field2}** both map to **${conflict.camelCase}**\n`;
    });
    report += `\n`;
  }
  
  report += `## Mappings\n\n`;
  report += `| Snake Case | Camel Case | Type |\n`;
  report += `|------------|------------|------|\n`;
  
  // Sort by frequency of use (we'll approximate by field importance)
  const sortedFields = Object.entries(mappings).sort((a, b) => {
    // Priority fields come first
    const priority = ['user_id', 'post_id', 'created_at', 'display_name'];
    const aIndex = priority.indexOf(a[0]);
    const bIndex = priority.indexOf(b[0]);
    
    if (aIndex !== -1 && bIndex === -1) return -1;
    if (aIndex === -1 && bIndex !== -1) return 1;
    if (aIndex !== -1 && bIndex !== -1) return aIndex - bIndex;
    
    return a[0].localeCompare(b[0]);
  });
  
  sortedFields.forEach(([snake, camel]) => {
    const type = SPECIAL_CASES[snake] ? '⭐ Special' : 'Standard';
    report += `| ${snake} | ${camel} | ${type} |\n`;
  });
  
  fs.writeFileSync(reportPath, report);
  console.log(`✅ Detailed report: ${reportPath}`);
  
  console.log('\n✨ Mapping generation complete!');
}

// Run the generator
main();