<!--
Sync Impact Report
==================
Version change: 1.0.0 → 2.0.0
Modified principles:
  - Added: Clean Architecture Principles (5 new principles)
  - Added: Migration Methodology (4 new principles)
  - Added: Quality Assurance (3 new principles)
  - Added: Sub-agent Orchestration (2 new principles)
Added sections:
  - Architecture Constraints
  - Migration Workflow
  - Quality Gates
Removed sections: None
Templates requiring updates:
  - ✅ plan-template.md (pending review)
  - ✅ spec-template.md (pending review)
  - ✅ tasks-template.md (pending review)
  - ✅ agent commands (pending review)
Follow-up TODOs: None
-->

# Versus Space Constitution

## Core Principles

### I. Feature-First Architecture
Every feature must be a self-contained module with clear boundaries. Features must be independently testable, deployable, and maintainable. No organizational-only modules are permitted - each feature must provide clear business value. Features follow the 3-layer Clean Architecture pattern: Presentation → Domain → Data.

### II. Clean Architecture Compliance
**Decompose & Reorganize**: Legacy code must be decomposed into small UseCases and reorganized into Clean Architecture. Core layer contains only interfaces and utilities - no implementations. Feature layers respect unidirectional dependency flow. App layer assembles all implementations through dependency injection.

### III. Direct Migration Strategy (v4.0)
Migrations must follow Direct Migration without Facade patterns. No bridge or deprecated wrapper code - immediate complete transition. Each migration must be atomic with full rollback capability. Legacy code must be completely removed in the same commit.

### IV. Test-First Development (NON-NEGOTIABLE)
TDD is mandatory: Tests written → User approved → Tests fail → Then implement. Red-Green-Refactor cycle strictly enforced. Minimum 80% test coverage for all new code. Integration tests required for all feature boundaries and contract changes.

### V. Dependency Rules
**Core has no implementations** - only interfaces and pure utilities. **Features cannot depend on each other** - each feature is completely independent. **No reverse dependencies** - dependencies flow inward only (Presentation → Domain → Data → Core interfaces). Only app/di.dart may import feature implementations for DI assembly.

### VI. UseCase Granularity
One UseCase = One File = One Responsibility. Files exceeding 300 lines must be decomposed. Mixed responsibilities must be separated into distinct UseCases. Each UseCase must have a corresponding unit test file.

### VII. Repository Pattern
Domain layer defines repository interfaces. Data layer implements repository interfaces. DTOs must maintain 1:1 mapping with Firebase schema. Mappers handle DTO ↔ Domain model transformations in data layer.

### VIII. Sub-agent Orchestration
Feature migration follows: InventoryScout → RepoMover → StructWeaver → DIBinder → ImportGuardian → BuildSentinel. Each loop must maintain a buildable state. Dry-run mode required before apply mode. All patches must be reviewed before application.

### IX. Import Hygiene
No cross-feature imports allowed except through Core interfaces. Presentation layer cannot import from Data layer directly. Core cannot import from Features. Import violations must be fixed immediately upon detection.

### X. Quality Gates
Every migration must pass: static analysis (flutter analyze), unit tests (80%+ coverage), integration tests, import violation check (0 violations), and build verification. BuildSentinel must report green before proceeding. Rollback plan required for all migrations.

### XI. Atomic Commits
Each feature migration must be a single atomic commit. All references must be updated in the same commit. Tests must pass before and after the commit. Legacy code removal must be complete - no partial migrations.

### XII. Documentation as Code
Migration manifests (YAML) required for each feature. Architecture decisions documented in ADR format. Sub-agent execution logs preserved in reports/. All commands and their outcomes tracked for reproducibility.

### XIII. Firebase Schema Integrity
DTO fields must match Firebase field names exactly (1:1). No new fields without explicit approval and justification. CamelCase for Firestore fields, snake_case for file names. Existing Firebase data structures must be preserved.

### XIV. Observability & Monitoring
All sub-agents must produce structured logs and reports. Cache hit rates and performance metrics must be tracked. Migration progress must be measurable and reportable. Error scenarios must have clear recovery paths.

## Architecture Constraints

**3-Layer Structure**:
- `lib/app/` - Application assembly and DI configuration
- `lib/core/` - Shared interfaces and utilities (no implementations)
- `lib/features/` - Feature modules with Clean Architecture layers

**Migration Targets**:
- Current: 85% Clean Architecture compliance
- Target: 95%+ compliance by 2025-01-31
- Legacy `/backend` removal deadline: 2025-06-30

**Performance Requirements**:
- 3-Layer cache (Memory → Hive → Firestore) for <10ms response
- Sub-agent execution under 60 seconds per feature
- Build time not to exceed pre-migration baseline by >10%

## Migration Workflow

**Standard Feature Migration Pipeline**:
1. **Inventory**: Scan with InventoryScout for violations and large files
2. **Move**: RepoMover transfers `/backend` → `/features/*/data`
3. **Decompose**: StructWeaver splits global mappers/state
4. **Wire**: DIBinder registers Port ↔ Adapter bindings
5. **Fix**: ImportGuardian generates violation patches
6. **Verify**: BuildSentinel validates quality gates
7. **Commit**: Atomic commit with complete migration

**Rollback Procedures**:
- Pre-apply: Review all patches in dry-run mode
- Post-apply: `git apply -R <patch>` or restore from commit
- Emergency: Full git reset to last stable commit

## Governance

The Constitution supersedes all other project practices and guidelines. Amendments require documentation in ADR format, team approval with justification, migration plan for affected code, and version increment following semantic versioning.

**Amendment Procedure**:
1. Propose change with rationale and impact analysis
2. Team review and discussion (minimum 48 hours)
3. Approval requires 2/3 majority or technical lead override
4. Update constitution with new version and amendment date
5. Propagate changes to all dependent artifacts

**Compliance Review**:
- All PRs must verify constitution compliance
- Sub-agent reports serve as compliance evidence
- Architecture score must improve or maintain with each PR
- Violations must be addressed before merge

**Version Policy**:
- MAJOR: Removal or redefinition of core principles
- MINOR: Addition of new principles or sections
- PATCH: Clarifications and non-semantic improvements

**Version**: 2.0.0 | **Ratified**: 2025-01-05 | **Last Amended**: 2025-01-19