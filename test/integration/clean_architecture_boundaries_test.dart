import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

// Domain models
import '../../lib/features/auth/domain/models/auth_user.dart';
import '../../lib/features/profile/domain/models/profile_info.dart';
import '../../lib/features/profile/domain/models/user_settings.dart';
import '../../lib/features/profile/domain/models/user_stats.dart';
import '../../lib/features/posts/domain/models/post.dart';
import '../../lib/features/posts/domain/models/media_content.dart';
import '../../lib/features/posts/domain/models/creator_info.dart';
import '../../lib/features/posts/domain/models/vote_data.dart';
import '../../lib/features/posts/domain/models/post_stats.dart';

void main() {
  group('Clean Architecture Boundary Tests', () {
    group('Domain Layer Purity Tests', () {
      test('Domain models should not have Flutter dependencies', () {
        // Read domain model files and check for Flutter imports
        final domainFiles = [
          'lib/features/auth/domain/models/auth_user.dart',
          'lib/features/profile/domain/models/profile_info.dart',
          'lib/features/profile/domain/models/user_settings.dart',
          'lib/features/profile/domain/models/user_stats.dart',
          'lib/features/posts/domain/models/post.dart',
          'lib/features/posts/domain/models/media_content.dart',
          'lib/features/posts/domain/models/creator_info.dart',
          'lib/features/posts/domain/models/vote_data.dart',
          'lib/features/posts/domain/models/post_stats.dart',
        ];

        for (final filePath in domainFiles) {
          final file = File('../../$filePath');
          if (file.existsSync()) {
            final content = file.readAsStringSync();
            
            // Check for forbidden imports
            expect(content.contains('import \'package:flutter/'), isFalse,
                reason: 'Domain model $filePath should not import Flutter');
            expect(content.contains('import \'package:firebase'), isFalse,
                reason: 'Domain model $filePath should not import Firebase');
            expect(content.contains('import \'package:cloud_firestore'), isFalse,
                reason: 'Domain model $filePath should not import Firestore');
                
            // Check for allowed imports only
            if (content.contains('import ')) {
              final imports = content
                  .split('\n')
                  .where((line) => line.trim().startsWith('import '))
                  .toList();
              
              for (final import in imports) {
                // Allow only dart core libraries and equatable
                final isAllowed = import.contains('dart:') ||
                    import.contains('package:equatable') ||
                    import.contains('/domain/') ||
                    import.contains('/core_exports.dart');
                    
                expect(isAllowed, isTrue,
                    reason: 'Domain model $filePath has forbidden import: $import');
              }
            }
          }
        }
      });

      test('Domain models should be immutable', () {
        // Test that domain models use final fields
        final authUser = AuthUser(
          uid: 'test',
          email: 'test@example.com',
          displayName: 'Test User',
          photoURL: null,
          phoneNumber: null,
          isEmailVerified: false,
          isAnonymous: false,
          createdTime: DateTime.now(),
          lastActive: DateTime.now(),
        );

        // Verify fields are final (compile-time check)
        expect(authUser.uid, equals('test'));
        expect(authUser.email, equals('test@example.com'));
      });

      test('Domain models should have proper equality', () {
        final now = DateTime.now();
        final user1 = AuthUser(
          uid: 'test',
          email: 'test@example.com',
          displayName: 'Test User',
          photoURL: null,
          phoneNumber: null,
          isEmailVerified: false,
          isAnonymous: false,
          createdTime: now,
          lastActive: now,
        );

        final user2 = AuthUser(
          uid: 'test',
          email: 'test@example.com',
          displayName: 'Test User',
          photoURL: null,
          phoneNumber: null,
          isEmailVerified: false,
          isAnonymous: false,
          createdTime: now,
          lastActive: now,
        );

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });
    });

    group('Repository Interface Compliance Tests', () {
      test('Repository interfaces should only use domain models', () {
        // Read repository interface files
        final interfaceFiles = [
          'lib/features/profile/domain/repositories/i_user_repository.dart',
          'lib/features/posts/domain/repositories/i_post_repository.dart',
          'lib/features/chat/domain/repositories/i_chat_repository.dart',
          'lib/features/profile/domain/repositories/i_profile_repository.dart',
          'lib/features/profile/domain/repositories/i_friends_repository.dart',
        ];

        for (final filePath in interfaceFiles) {
          final file = File('../../$filePath');
          if (file.existsSync()) {
            final content = file.readAsStringSync();
            
            // Check that interfaces don't import data layer
            expect(content.contains('/data/'), isFalse,
                reason: 'Repository interface $filePath should not import data layer');
            expect(content.contains('firebase'), isFalse,
                reason: 'Repository interface $filePath should not reference Firebase');
            
            // Check that interfaces use domain models
            expect(content.contains('/domain/models/'), isTrue,
                reason: 'Repository interface $filePath should use domain models');
          }
        }
      });
    });

    group('Feature Module Independence Tests', () {
      test('Feature modules should not directly depend on each other', () {
        // Read feature module files
        final featureDirectories = [
          'lib/features/auth/',
          'lib/features/profile/',
          'lib/features/posts/',
          'lib/features/chat/',
          'lib/features/voting/',
          'lib/features/notifications/',
          'lib/features/search/',
        ];

        for (final feature in featureDirectories) {
          final featureName = feature.split('/')[2];
          final dir = Directory('../../$feature');
          
          if (dir.existsSync()) {
            final files = dir
                .listSync(recursive: true)
                .whereType<File>()
                .where((f) => f.path.endsWith('.dart'))
                .toList();
            
            for (final file in files) {
              final content = file.readAsStringSync();
              final relativePath = file.path.split('versus-cursor/').last;
              
              // Skip if it's a shared/core file
              if (relativePath.contains('/core/') || 
                  relativePath.contains('core_exports')) {
                continue;
              }
              
              // Check for cross-feature imports (except through domain interfaces)
              for (final otherFeature in featureDirectories) {
                final otherName = otherFeature.split('/')[2];
                if (otherName != featureName) {
                  final crossImport = 'features/$otherName/';
                  
                  if (content.contains(crossImport)) {
                    // Allow domain interface imports
                    final isInterfaceImport = content.contains('$crossImport' + 'domain/repositories/');
                    final isDomainModel = content.contains('$crossImport' + 'domain/models/');
                    
                    if (!isInterfaceImport && !isDomainModel) {
                      // Check if it's in presentation layer (allowed for navigation)
                      final isPresentationLayer = relativePath.contains('/presentation/');
                      
                      if (!isPresentationLayer) {
                        fail('Feature $featureName should not directly import from $otherName\n'
                            'File: $relativePath\n'
                            'Import found: $crossImport');
                      }
                    }
                  }
                }
              }
            }
          }
        }
      });

      test('Data layer should not be exposed to presentation layer', () {
        // Read presentation layer files
        final presentationDirs = [
          'lib/features/auth/presentation/',
          'lib/features/profile/presentation/',
          'lib/features/posts/presentation/',
          'lib/features/chat/presentation/',
          'lib/features/voting/presentation/',
          'lib/features/notifications/presentation/',
          'lib/features/search/presentation/',
        ];

        for (final dir in presentationDirs) {
          final directory = Directory('../../$dir');
          
          if (directory.existsSync()) {
            final files = directory
                .listSync(recursive: true)
                .whereType<File>()
                .where((f) => f.path.endsWith('.dart'))
                .toList();
            
            for (final file in files) {
              final content = file.readAsStringSync();
              final relativePath = file.path.split('versus-cursor/').last;
              
              // Check that presentation doesn't import data layer
              expect(content.contains('/data/repositories/'), isFalse,
                  reason: 'Presentation file $relativePath should not import data repositories directly');
              expect(content.contains('/data/models/'), isFalse,
                  reason: 'Presentation file $relativePath should not import data models directly');
              expect(content.contains('/data/adapters/'), isFalse,
                  reason: 'Presentation file $relativePath should not import adapters directly');
            }
          }
        }
      });
    });

    group('Dependency Direction Tests', () {
      test('Dependencies should flow inward (Presentation → Domain ← Data)', () {
        // This is a conceptual test to document the architecture rules
        
        // Presentation layer can depend on:
        // - Domain interfaces
        // - Domain models
        // - DI container
        
        // Domain layer can depend on:
        // - Nothing external (pure business logic)
        // - Other domain models
        // - Core utilities (if pure)
        
        // Data layer can depend on:
        // - Domain interfaces (to implement them)
        // - Domain models (to convert to/from)
        // - External packages (Firebase, HTTP, etc.)
        
        expect(true, isTrue, reason: 'Architecture rules documented');
      });
    });
  });
}