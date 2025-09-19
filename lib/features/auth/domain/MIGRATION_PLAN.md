# Auth Domain Layer – Migration Plan (No-Rename)

Applies to: `lib/features/auth/domain/`
Reference: `lib/ARCHITECTURE_RULES.md`, Voting feature README

## 0) Current Inventory (as-is)
- services/i_auth_service.dart (domain port)
- repositories/i_auth_repository.dart
- usecases/
  - get_current_user_usecase.dart, auth_state_usecase.dart
- models/
  - auth_user.dart, premium_users_model.dart, user_contents_model.dart, etc.

Pain points
- Minimal usecases; UI may call repository/service directly in places
- Port naming is service-centric; acceptable if treated as domain port (no framework deps)

## 1) Target Pattern (Voting-style, keep names)
- Domain exposes ports (interfaces) and usecases only; no Firebase/Flutter imports
- Expand usecases to cover flows: sign-in(email/social/phone), sign-up, sign-out, reset, verify
- Keep existing file names; add only what’s needed

## 2) Phased Steps (Gated)
Phase A – Usecase Coverage
- Add missing usecases alongside existing ones (names aligned to current naming style)
  - sign_in_with_email_usecase.dart
  - sign_up_with_email_usecase.dart
  - sign_out_usecase.dart
  - reset_password_usecase.dart
  - sign_in_with_google_usecase.dart
  - sign_in_with_apple_usecase.dart
  - (optional) phone/anonymous as needed

Phase B – Port Purity Check
- Ensure `i_auth_service.dart` and `i_auth_repository.dart` are dependency-free
- Any Firebase types leak → abstract them into domain types

Phase C – Wiring Contracts
- Define minimal DTO/Params types for usecases (Params objects)
- Ensure repository methods are sufficient; if not, extend interface minimally

Gate per phase: `flutter analyze` green + unit tests for new usecases

## 3) Interaction Rules
- Presentation calls UseCases only; UseCases depend on domain ports (service/repo)
- Data implements ports; DI resolves bindings

## 4) Tests
- Unit tests for each new usecase (happy/failure paths)
- Contract tests (mock data layer) to enforce interface behavior

