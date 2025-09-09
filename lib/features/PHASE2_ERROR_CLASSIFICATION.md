# Phase 2 - Build Error Classification

## Error Summary
**Total Errors**: 453  
**Categories**: 6 main types  
**Estimated Fix Time**: 4-6 hours

## Error Categories

### 1. Missing Model Exports (30 errors)
**Primary Issue**: PostsModel not exported/imported properly

```
17x Undefined name 'PostsModel'
13x Undefined class 'PostsModel'
```

**Fix Strategy**:
- Add PostsModel export to appropriate barrel file
- Update imports in affected files
- Location: `/lib/backend/models/posts_model.dart`

### 2. Missing Type Definitions (26 errors)
**Primary Issues**: LayoutType and BoxSizes not accessible

```
11x Undefined name 'LayoutType'
4x Undefined class 'LayoutType'
4x Undefined class 'BoxSizes'
```

**Fix Strategy**:
- Export LayoutType from posts feature
- Export BoxSizes from appropriate location
- Update barrel exports

### 3. Dependency Injection Issues (11 errors)
**Primary Issue**: Injection class not imported

```
11x Undefined name 'Injection'
```

**Fix Strategy**:
- Import GetIt package where needed
- Or use GetIt.instance directly
- Update DI references

### 4. Missing Widget/Screen Imports (10 errors)
**Primary Issue**: ProfilePageWidget not found

```
10x The function 'ProfilePageWidget' isn't defined
```

**Fix Strategy**:
- Add proper imports for presentation widgets
- Check barrel exports in features

### 5. Method Signature Mismatches (~100 errors)
**Primary Issues**: Interface/Implementation misalignment

```
8x Too many positional arguments
6x The named parameter 'type' isn't defined
6x The named parameter 'content' isn't defined
5x The method 'getUserByUid' isn't defined
```

**Fix Strategy**:
- Align repository implementations with new interfaces
- Add missing methods to implementations
- Fix parameter mismatches

### 6. Type Conversion Issues (~50 errors)
**Primary Issues**: Null safety and type mismatches

```
8x The argument type 'String?' can't be assigned to 'String'
6x The argument type 'Null' can't be assigned to 'String'
6x Query type mismatches
```

**Fix Strategy**:
- Add null checks and default values
- Fix query builder types
- Handle nullable types properly

## Quick Fix Priority

### Priority 1 - Export/Import Fixes (1 hour)
Fix missing exports/imports to resolve ~100 errors:
1. Export PostsModel from `/lib/backend/models/`
2. Export LayoutType from posts feature
3. Export BoxSizes from appropriate location
4. Fix ProfilePageWidget import
5. Add Injection/GetIt imports

### Priority 2 - Repository Methods (2 hours)
Add missing methods to implementations:
1. Add getUserByUid to UserRepositoryImpl
2. Fix voting repository methods (votesA, votesB)
3. Align all implementations with interfaces

### Priority 3 - Type Issues (1-2 hours)
Fix type mismatches and null safety:
1. Handle nullable strings
2. Fix Query type parameters
3. Add null checks where needed

### Priority 4 - Constructor/Parameters (1 hour)
Fix constructor and parameter issues:
1. UserProfile constructor
2. Named parameter additions
3. Positional argument fixes

## File Hotspots
Files with most errors (focus areas):

1. `/lib/app/di.dart` - DI configuration
2. `/lib/features/posts/` - Posts feature
3. `/lib/features/profile/` - Profile feature  
4. `/lib/features/voting/` - Voting feature
5. `/lib/core/actions/global_actions.dart` - Core actions

## Next Steps

1. **Start with exports** - This will eliminate ~30% of errors quickly
2. **Fix repository methods** - Align implementations with interfaces
3. **Handle type issues** - Add null safety handling
4. **Test incrementally** - Run `flutter analyze` after each category

## Success Metrics

- [ ] PostsModel accessible everywhere needed
- [ ] All repository methods implemented
- [ ] Type safety enforced
- [ ] DI properly configured
- [ ] 0 build errors

---

*This classification provides a roadmap for Phase 2 implementation fixes*