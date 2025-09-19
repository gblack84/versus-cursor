# 🔐 Auth Feature – Clean Architecture Migration Overview

> Scope: `lib/features/auth/` (data/domain/presentation)
> Rules: Follow `lib/ARCHITECTURE_RULES.md`
> Style: Mirror the Voting feature’s structure and gating (pattern only, keep current names)

## 🎯 Goals
- Keep file/class names; refactor connections (imports/DI/call sites) first.
- Domain 100% framework‑free; Presentation uses UseCases only; Data hides Firebase details.
- Reduce duplicate “manager/util/service” in data/adapters by routing through repository/datasources.

## 🧭 Phases (Voting‑style, gated)
1) Inventory + Analyze (quick) → create usage maps and import graph
2) Presentation refactor to UseCases (no Firebase imports)
3) Data refactor: managers→datasource/repository funnel
4) Domain usecases expansion (email/social/phone/signout/reset)
5) DI consolidation in app layer
6) Tests + Docs

Gate: Each phase passes `flutter analyze` and key tests before proceeding

## 🔌 DI Boundaries (App Layer)
- Bind domain interfaces (repository/service) to data implementations in `app/di`.
- Presentation classes are created via Providers with UseCase constructor injection.

## 📚 Sub‑Docs
- `data/MIGRATION_PLAN.md`: Data layer funnel + adapters consolidation
- `domain/MIGRATION_PLAN.md`: Domain ports/usecases alignment
- `presentation/MIGRATION_PLAN.md`: UI state → UseCases migration

