#!/usr/bin/env node

/**
 * Migration Analysis Script
 * Analyzes the codebase to determine migration order and impact
 */

const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);

// Load field mappings
const mappingsPath = path.join(__dirname, '../migration_analysis/field_mappings.json');
const mappingData = JSON.parse(fs.readFileSync(mappingsPath, 'utf8'));
const fieldMappings = mappingData.mappings;

// Categories of files for phased migration
const MIGRATION_PHASES = {
  'Phase 1: Configuration': {
    patterns: ['firebase/firestore.rules', 'firebase/firestore.indexes.json'],
    critical: true,
    description: 'Security rules and database indexes'
  },
  'Phase 2: Backend Functions': {
    patterns: ['firebase/functions/**/*.js'],
    critical: true,
    description: 'Firebase Cloud Functions'
  },
  'Phase 3: Data Models': {
    patterns: ['lib/backend/schema/**/*_model.dart'],
    critical: true,
    description: 'Flutter data model definitions'
  },
  'Phase 4: Services': {
    patterns: ['lib/services/**/*.dart'],
    critical: false,
    description: 'Service layer implementations'
  },
  'Phase 5: UI Components': {
    patterns: ['lib/components/**/*.dart', 'lib/pages/**/*.dart'],
    critical: false,
    description: 'UI components and pages'
  }
};

// Analyze field usage in a file
async function analyzeFile(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    const usedFields = new Set();
    const needsMigration = new Set();
    
    // Check each snake_case field
    Object.keys(fieldMappings).forEach(snakeField => {
      // Create regex to match field usage
      const regex = new RegExp(`\\b${snakeField}\\b`, 'g');
      const matches = content.match(regex);
      
      if (matches) {
        usedFields.add(snakeField);
        // Check if camelCase version already exists
        const camelField = fieldMappings[snakeField];
        const camelRegex = new RegExp(`\\b${camelField}\\b`, 'g');
        const camelMatches = content.match(camelRegex);
        
        // If snake_case exists but not camelCase, needs migration
        if (!camelMatches || camelMatches.length < matches.length) {
          needsMigration.add(snakeField);
        }
      }
    });
    
    return {
      filePath,
      usedFields: Array.from(usedFields),
      needsMigration: Array.from(needsMigration),
      hasMixedConventions: usedFields.size > 0 && needsMigration.size < usedFields.size
    };
  } catch (error) {
    return {
      filePath,
      error: error.message,
      usedFields: [],
      needsMigration: []
    };
  }
}

// Find files matching pattern
async function findFiles(pattern) {
  try {
    const { stdout } = await execPromise(
      `find . -path "${pattern}" -type f ! -path "*/node_modules/*" ! -path "*/.dart_tool/*" 2>/dev/null | head -100`
    );
    return stdout.split('\n').filter(line => line.trim());
  } catch (error) {
    return [];
  }
}

// Analyze migration impact
async function analyzeMigrationImpact() {
  console.log('🔍 Migration Impact Analysis');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  
  const report = {
    timestamp: new Date().toISOString(),
    totalFields: Object.keys(fieldMappings).length,
    phases: {}
  };
  
  // Analyze each phase
  for (const [phaseName, phaseConfig] of Object.entries(MIGRATION_PHASES)) {
    console.log(`\n📋 ${phaseName}`);
    console.log(`   ${phaseConfig.description}`);
    
    const phaseResults = {
      files: [],
      totalFiles: 0,
      filesNeedingMigration: 0,
      totalFieldOccurrences: 0,
      criticalFields: new Set(),
      summary: {}
    };
    
    // Find and analyze files for this phase
    for (const pattern of phaseConfig.patterns) {
      const files = await findFiles(pattern);
      
      for (const file of files) {
        const analysis = await analyzeFile(file);
        if (analysis.needsMigration.length > 0) {
          phaseResults.files.push(analysis);
          phaseResults.filesNeedingMigration++;
          phaseResults.totalFieldOccurrences += analysis.needsMigration.length;
          
          // Track critical fields
          analysis.needsMigration.forEach(field => {
            phaseResults.criticalFields.add(field);
          });
        }
        phaseResults.totalFiles++;
      }
    }
    
    // Generate phase summary
    phaseResults.summary = {
      totalFiles: phaseResults.totalFiles,
      filesNeedingMigration: phaseResults.filesNeedingMigration,
      uniqueFieldsToMigrate: phaseResults.criticalFields.size,
      critical: phaseConfig.critical
    };
    
    // Display summary
    console.log(`   Files to migrate: ${phaseResults.filesNeedingMigration}/${phaseResults.totalFiles}`);
    console.log(`   Unique fields: ${phaseResults.criticalFields.size}`);
    
    if (phaseResults.criticalFields.size > 0) {
      console.log(`   Top fields: ${Array.from(phaseResults.criticalFields).slice(0, 5).join(', ')}`);
    }
    
    report.phases[phaseName] = phaseResults;
  }
  
  return report;
}

// Generate migration order recommendation
function generateMigrationOrder(report) {
  console.log('\n📊 Recommended Migration Order');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  
  const criticalPhases = [];
  const nonCriticalPhases = [];
  
  Object.entries(report.phases).forEach(([phaseName, phaseData]) => {
    if (phaseData.summary.filesNeedingMigration > 0) {
      const phase = {
        name: phaseName,
        ...phaseData.summary
      };
      
      if (phase.critical) {
        criticalPhases.push(phase);
      } else {
        nonCriticalPhases.push(phase);
      }
    }
  });
  
  console.log('\n🔴 Critical (Must migrate first):');
  criticalPhases.forEach((phase, index) => {
    console.log(`${index + 1}. ${phase.name}`);
    console.log(`   - ${phase.filesNeedingMigration} files`);
    console.log(`   - ${phase.uniqueFieldsToMigrate} unique fields`);
  });
  
  console.log('\n🟡 Non-Critical (Can migrate later):');
  nonCriticalPhases.forEach((phase, index) => {
    console.log(`${criticalPhases.length + index + 1}. ${phase.name}`);
    console.log(`   - ${phase.filesNeedingMigration} files`);
    console.log(`   - ${phase.uniqueFieldsToMigrate} unique fields`);
  });
}

// Generate detailed migration report
function generateDetailedReport(report) {
  const reportPath = path.join(__dirname, '../migration_analysis/MIGRATION_PLAN.md');
  
  let markdown = `# Migration Plan\n`;
  markdown += `Generated: ${report.timestamp}\n\n`;
  markdown += `## Overview\n`;
  markdown += `Total snake_case fields to migrate: ${report.totalFields}\n\n`;
  
  Object.entries(report.phases).forEach(([phaseName, phaseData]) => {
    markdown += `## ${phaseName}\n`;
    markdown += `- Total files: ${phaseData.summary.totalFiles}\n`;
    markdown += `- Files needing migration: ${phaseData.summary.filesNeedingMigration}\n`;
    markdown += `- Unique fields: ${phaseData.summary.uniqueFieldsToMigrate}\n`;
    markdown += `- Critical: ${phaseData.summary.critical ? '🔴 Yes' : '🟡 No'}\n\n`;
    
    if (phaseData.files.length > 0) {
      markdown += `### Files to Migrate\n`;
      phaseData.files.slice(0, 10).forEach(file => {
        markdown += `#### ${file.filePath}\n`;
        markdown += `- Fields to migrate: ${file.needsMigration.join(', ')}\n`;
        if (file.hasMixedConventions) {
          markdown += `- ⚠️ Has mixed conventions (partially migrated)\n`;
        }
        markdown += `\n`;
      });
      
      if (phaseData.files.length > 10) {
        markdown += `_... and ${phaseData.files.length - 10} more files_\n\n`;
      }
    }
  });
  
  markdown += `## Migration Commands\n\n`;
  markdown += `### Phase 1: Backup\n`;
  markdown += `\`\`\`bash\n`;
  markdown += `git add -A && git commit -m "Pre-migration backup"\n`;
  markdown += `git checkout -b camelcase-migration\n`;
  markdown += `\`\`\`\n\n`;
  
  markdown += `### Phase 2: Run Migration\n`;
  markdown += `\`\`\`bash\n`;
  markdown += `# Run migration scripts in order\n`;
  markdown += `node scripts/migrate_firestore_rules.js\n`;
  markdown += `node scripts/migrate_firebase_functions.js\n`;
  markdown += `node scripts/migrate_flutter_models.js\n`;
  markdown += `\`\`\`\n\n`;
  
  markdown += `### Phase 3: Test\n`;
  markdown += `\`\`\`bash\n`;
  markdown += `# Run tests\n`;
  markdown += `flutter test\n`;
  markdown += `cd firebase/functions && npm test\n`;
  markdown += `\`\`\`\n\n`;
  
  markdown += `### Phase 4: Deploy\n`;
  markdown += `\`\`\`bash\n`;
  markdown += `# Deploy Firebase rules and functions\n`;
  markdown += `firebase deploy --only firestore:rules\n`;
  markdown += `firebase deploy --only firestore:indexes\n`;
  markdown += `firebase deploy --only functions\n`;
  markdown += `\`\`\`\n`;
  
  fs.writeFileSync(reportPath, markdown);
  console.log(`\n📄 Detailed report saved to: ${reportPath}`);
}

// Main execution
async function main() {
  try {
    // Check if mappings exist
    if (!fs.existsSync(mappingsPath)) {
      console.error('❌ Error: field_mappings.json not found. Run generate_mappings.js first.');
      process.exit(1);
    }
    
    // Analyze migration impact
    const report = await analyzeMigrationImpact();
    
    // Generate migration order
    generateMigrationOrder(report);
    
    // Save detailed report
    generateDetailedReport(report);
    
    // Save JSON report
    const jsonReportPath = path.join(__dirname, '../migration_analysis/migration_analysis.json');
    fs.writeFileSync(jsonReportPath, JSON.stringify(report, null, 2));
    console.log(`📊 Analysis data saved to: ${jsonReportPath}`);
    
    console.log('\n✅ Migration analysis complete!');
    console.log('Review MIGRATION_PLAN.md for detailed migration steps.');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

// Run the analysis
main();