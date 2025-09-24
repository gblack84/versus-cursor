// ============================================
// Auth Feature Presentation Layer Exports
// ============================================
// This file exports all public-facing presentation components
// from the Auth Feature, following Clean Architecture principles
// ============================================

// Main Screens
export 'screens/login/login_page/login_page_widget.dart' show LoginPageWidget;
export 'screens/signup/create_account/create_account_widget.dart' show CreateAccountWidget;
export 'screens/forgot_password/forgot_password/forgot_password_widget.dart' show ForgotPasswordWidget;
export 'screens/start/start_page/start_page_widget.dart' show StartPageWidget;

// Phone Authentication Screens
export 'screens/phone_auth/phone_creat_account/phone_creat_account_widget.dart' show PhoneCreatAccountWidget;
export 'screens/phone_auth/phonelogeinpincode_widget.dart' show PhonelogeinpincodeWidget;
export 'screens/phone_auth/phonemaximum/phonemaximum_widget.dart' show PhonemaximumWidget;

// Email Verification Screens
export 'screens/email_verification/popup_timer_email/popup_timer_email_widget.dart' show PopupTimerEmailWidget;

// Providers (for DI and State Management)
export 'providers/auth_provider.dart' show AuthProvider;

// Note: Models are intentionally not exported to maintain encapsulation
// Only widgets and providers that need to be accessed from outside
// the Auth feature are exported here