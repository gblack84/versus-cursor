# UsersModel Migration Plan - Profile Feature

**Migration Date**: 2025-01-07
**Mode**: dry-run  
**Feature**: profile
**Source**: `/lib/backend/models/user/users_model.dart`

## Executive Summary

Migration of UsersModel from backend-centric to feature-first architecture within the profile feature module. The model contains comprehensive user data including profile information, social features, and ranking systems.

## Current Analysis

### Source File Analysis
- **Location**: `/lib/backend/models/user/users_model.dart`
- **Size**: 485 lines
- **Type**: Firestore model extending FirestoreRecord
- **Fields**: 32 primary fields including profile, social, and ranking data

### Key Dependencies
- `cloud_firestore/cloud_firestore.dart`
- `dart:async`
- `collection/collection.dart`
- `/backend/firebase/firestore/utils/firestore_util.dart`
- `/backend/firebase/firestore/utils/schema_util.dart`
- `/core_exports.dart`

### Current Usage Analysis
Found **57 files** referencing UsersModel across the codebase:

**Critical Import Files**:
- `/lib/backend/backend.dart` - Central backend export file
- Multiple profile presentation screens
- Chat services and authentication utilities
- Cache services and global actions

## Proposed Migration Structure

### Target Directory Structure
```
lib/features/profile/
├── data/
│   ├── models/
│   │   └── users_model.dart              # ← Migrated from backend
│   └── repositories/
│       └── profile_repository_impl.dart  # Implementation using UsersModel
├── domain/
│   ├── entities/
│   │   └── user_profile.dart            # Clean domain entity
│   └── repositories/
│       └── i_profile_repository.dart    # Repository interface
└── presentation/ (existing screens remain)
```

### Migration Steps

#### Phase 1: Data Layer Migration (Day 1)
1. **Move Model File**:
   ```bash
   git mv lib/backend/models/user/users_model.dart lib/features/profile/data/models/
   ```

2. **Create Domain Entity** - `lib/features/profile/domain/entities/user_profile.dart`:
   - Clean domain model without Firestore dependencies
   - Core user profile properties only
   - No Firebase-specific logic

3. **Create Repository Interface** - `lib/features/profile/domain/repositories/i_profile_repository.dart`:
   - Define profile data operations
   - Return domain entities, not Firestore models

#### Phase 2: Repository Implementation (Day 1-2)
4. **Implement Repository** - `lib/features/profile/data/repositories/profile_repository_impl.dart`:
   - Use UsersModel for Firestore operations
   - Convert between data models and domain entities
   - Handle caching and error management

#### Phase 3: Import Updates (Day 2)
5. **Update Import References** (57 files):
   - Update `/lib/backend/backend.dart` export
   - Fix imports in presentation screens
   - Update cache and service imports

#### Phase 4: Dependency Injection (Day 2)
6. **Register Repository**:
   - Add to DI container
   - Ensure proper scoping and lifecycle management

## Import Reference Updates Required

### High Priority Files (Must Update)
```
/lib/backend/backend.dart                           # Central export
/lib/features/profile/presentation/screens/         # 8+ screen files
/lib/features/chat/data/services/                   # Chat integration
/lib/features/auth/data/services/auth_util.dart    # Authentication
/lib/services/cache/unified_cache_service.dart     # Caching
/lib/core/actions/global_actions.dart              # Global actions
```

### Medium Priority Files (Feature Integration)
```
/lib/features/posts/presentation/providers/        # Post creation
/lib/features/chat/presentation/screens/           # Chat screens  
/lib/features/search/presentation/screens/         # Search integration
```

### Low Priority Files (Documentation/Testing)
```
Various README.md files and test files
Legacy migration documentation
```

## Risk Assessment

### High Risk Areas
- **Central Backend Export**: `/lib/backend/backend.dart` is imported widely
- **Cache Integration**: Unified cache service depends on UsersModel serialization
- **Cross-Feature Dependencies**: Chat, posts, and auth features use user data

### Mitigation Strategies
1. **Backward Compatibility**: Maintain export alias in backend.dart during transition
2. **Phased Migration**: Update imports incrementally by feature area
3. **Testing**: Verify user profile screens and cache functionality
4. **Rollback Plan**: Keep original location until all references updated

## Dependencies That Need Resolution

### Firestore Utilities
- `firestore_util.dart` - May need to remain in backend or move to core
- `schema_util.dart` - Shared utility, likely stays in backend

### Core Exports
- `/core_exports.dart` - Already accessible from profile feature

## Validation Checklist

### Pre-Migration
- [ ] Backup current UsersModel location
- [ ] Identify all 57 referencing files
- [ ] Verify profile feature structure exists
- [ ] Ensure DI container is ready for repository registration

### Post-Migration  
- [ ] All imports resolve correctly
- [ ] Profile screens still function
- [ ] User authentication flows work
- [ ] Cache serialization/deserialization intact
- [ ] Chat user data loading functional
- [ ] No circular dependencies introduced

## Benefits of Migration

### Architecture Benefits
- **Feature Isolation**: Profile data contained within profile feature
- **Clean Architecture**: Separation of data, domain, and presentation concerns  
- **Testability**: Easier to unit test profile-specific logic
- **Maintainability**: Clearer ownership and modification boundaries

### Development Benefits
- **Team Ownership**: Profile team owns complete user data flow
- **Reduced Coupling**: Less dependency on central backend module
- **Scalability**: Profile feature can evolve independently

## Estimated Timeline

- **Day 1**: Phase 1-2 (Model migration, repository creation)
- **Day 2**: Phase 3-4 (Import updates, DI registration)
- **Day 3**: Testing, validation, and documentation updates

## Next Steps

1. **Execute Dry Run**: Verify all file locations and dependencies
2. **Create Backup Branch**: Safe fallback point
3. **Begin Phase 1**: Move model and create repository structure
4. **Iterative Testing**: Validate each phase before proceeding

---

**Migration Status**: READY FOR EXECUTION
**Approval Required**: Architecture team review recommended due to central model migration
