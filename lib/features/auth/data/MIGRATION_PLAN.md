# Auth Data Layer – Migration Plan (No-Rename)

Applies to: `lib/features/auth/data/`
Reference: `lib/ARCHITECTURE_RULES.md`, Voting feature README

## 0) Current Inventory (as-is)
- adapters/
  - auth_service_impl.dart, auth_util.dart, firebase_auth_manager.dart,
    google_auth.dart, email_auth.dart, apple_auth.dart, github_auth.dart,
    anonymous_auth.dart, firebase_user_provider.dart, base_auth_user_provider.dart,
    user_service_impl.dart
- repositories/
  - auth_repository_impl.dart
- datasources/
  - README.md (interfaces/impls not fully realized)
- exports/
  - auth_models.dart

Pain points
- Multiple “manager/service/util” files acting as ad-hoc datasources
- Firebase usage spread across adapters
- Repository exists, but logic is split with managers/util

## 1) Target Pattern (Voting-style, keep names)
- Centralize external calls behind a clear funnel:
  - Repository (auth_repository_impl.dart) coordinates
  - Adapters act as per-provider helpers used only by repository/datasources
  - Datasources directory holds the integration points (remote/local)
- Domain owns interfaces; Data implements them (no Flutter/Firebase in domain)

## 2) Phased Steps (Gated)
Phase A – Usage Map (detect)
- Map all imports of adapters/* from outside data layer (should be 0)
- Identify Firebase calls spread across adapters (mark for funneling)

Phase B – Repository Funnel
- Move sign-in/up/out/reset flows into auth_repository_impl.dart by calling existing helpers in adapters/*
- Ensure repository is the only entry for auth flows from UseCases

Phase C – Datasources Realization
- Introduce concrete remote/local objects under datasources/ (keep names consistent), then internally call existing helpers
- Keep filenames; only add new impls if missing

Phase D – Clean Adapters Surface
- Restrict adapters/* to be used only by repository/datasources
- Remove any presentation/domain direct imports to adapters

Phase E – Error handling
- Standardize Firebase exception mapping via a single handler (co-locate under data/handlers if needed)

Gate per phase: `flutter analyze` green + affected tests green

## 3) DI Wiring
- App DI binds domain interfaces to data implementations (repository + datasources)
- Presentation must not construct adapters directly

## 4) Tests
- Repository integration tests cover email/social/anonymous sign-in, sign-out, reset
- Mock adapters in unit tests; use emulator infra in integration tests if present

## 5) Docs
- Update data/datasources/README.md with concrete entry points
- Keep this plan up to date as flows are funneled into repository

