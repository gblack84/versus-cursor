# Auth Presentation Layer – Migration Plan (No-Rename)

Applies to: `lib/features/auth/presentation/`
Reference: `lib/ARCHITECTURE_RULES.md`, Voting feature README

## 0) Current Inventory (as-is)
- Screens: login, signup, start, forgot_password, email_verification, phone_auth
- Controllers: multiple `*_model.dart` under screens
- Providers: providers/README.md (no central provider class committed)

Pain points
- Phone auth screens likely import Firebase directly
- State management scattered across screen-specific models

## 1) Target Pattern (Voting-style, keep names)
- Central Provider (e.g., `presentation/providers/auth_provider.dart`) consumes UseCases
- Screens/controllers call Provider only; no Firebase/Repository direct imports
- Phone auth flows call UseCases/Service port via Provider

## 2) Phased Steps (Gated)
Phase A – Provider Introduction
- Add `AuthProvider` under `presentation/providers/` (constructor inject UseCases)
- Expose: signInWithEmail, signUpWithEmail, signOut, resetPassword, watchAuthState

Phase B – Screen Refactor
- login/signup/forgot_password/email_verification: replace direct calls with Provider methods
- phone_auth/*: remove `package:firebase_auth/firebase_auth.dart` imports; use Provider/UseCases

Phase C – Navigation Compliance
- Use navigation via app layer adapters (no BuildContext in domain ports)
- Ensure back navigation is handled by app router/adapters

Gate per phase: `flutter analyze` green + widget/integration tests green

## 3) DI Wiring (App Layer)
- Bind UseCases via GetIt and register `ChangeNotifierProvider<AuthProvider>`
- Screens obtain Provider via context.read/watch

## 4) Tests
- Widget tests for login/signup (Provider-driven)
- Integration tests for phone auth flow with emulator/mocks

