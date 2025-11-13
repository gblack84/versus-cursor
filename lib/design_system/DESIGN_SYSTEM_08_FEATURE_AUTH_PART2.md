# DESIGN_SYSTEM_08_FEATURE_AUTH_PART2.md

> **Part 9-2: Auth Feature - 컴포넌트 도입 및 구현 가이드**
>
> **최종 업데이트**: 2025-11-10
> **문서 버전**: 1.0.0
> **담당 Feature**: Auth (인증)
> **우선순위**: 🔴 **URGENT** (#1 Rank)
> **문서 분량**: ~750줄 (Part 2/2)
> **이전 문서**: Part 9-1 (현황 분석 및 토큰 마이그레이션)

---

## 📋 목차

- [컴포넌트 소개](#-컴포넌트-소개)
- [Phase 2: 컴포넌트 도입](#-phase-2-컴포넌트-도입)
- [Before/After 코드 예시](#-beforeafter-코드-예시)
- [Phase 3: 품질 보증](#-phase-3-품질-보증)
- [Best Practices](#-best-practices)
- [완료 체크리스트](#-완료-체크리스트)

---

## 🧩 컴포넌트 소개

### 1. VersusTextField (우선순위: CRITICAL ⭐⭐⭐⭐⭐)

**설명**: 모든 텍스트 입력 폼을 위한 범용 TextField 컴포넌트

**사용 현황**:
- Auth Feature: 20 usages (Email×2, Password×2, Name, etc.)
- Profile Feature: 8 usages (프로필 수정 폼)
- Creation Feature: 12 usages (제목, 설명, 태그)
- Chat Feature: 15+ usages (메시지 입력)
- **전체: 55+ usages**

**Before/After**:
```dart
// ❌ BEFORE: email_input_widget.dart (178 lines)
class EmailInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),  // Hardcoded
      decoration: BoxDecoration(
        color: Color(0xFFF5F5F5),  // Hardcoded
        borderRadius: BorderRadius.circular(12),  // Hardcoded
        border: Border.all(
          color: errorText != null
              ? Color(0xFFFF3B30)  // Hardcoded
              : Color(0xFFE0E0E0),  // Hardcoded
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
          fontSize: 16,  // Hardcoded
          color: Color(0xFF14142B),  // Hardcoded
        ),
        decoration: InputDecoration(
          hintText: 'Email',
          hintStyle: TextStyle(
            fontSize: 16,  // Hardcoded
            color: Color(0xFF6B7280),  // Hardcoded
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.email,
            color: Color(0xFF6B4EFF),  // Hardcoded
          ),
          suffixIcon: errorText != null
              ? Icon(
                  Icons.error,
                  color: Color(0xFFFF3B30),  // Hardcoded
                )
              : null,
        ),
      ),
    );

    // Error message (34 lines)
    if (errorText != null)
      Padding(
        padding: EdgeInsets.only(left: 16, top: 8),  // Hardcoded
        child: Text(
          errorText!,
          style: TextStyle(
            fontSize: 14,  // Hardcoded
            color: Color(0xFFFF3B30),  // Hardcoded
          ),
        ),
      ),
  }
}

// Password input widget (189 lines) - 거의 동일한 코드 중복!

// ✅ AFTER: VersusTextField component
VersusTextField(
  controller: emailController,
  label: 'Email',
  hintText: 'Enter your email',
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icons.email,
  errorText: emailError,
  validator: (value) => EmailValidator.validate(value),
)

VersusTextField(
  controller: passwordController,
  label: 'Password',
  hintText: 'Enter your password',
  obscureText: true,
  prefixIcon: Icons.lock,
  suffixIcon: Icons.visibility,
  onSuffixIconTap: () => _togglePasswordVisibility(),
  errorText: passwordError,
  validator: (value) => PasswordValidator.validate(value),
)
```

**코드 감소**:
- Email + Password input: 367 lines (178+189) → 8 lines (4+4) = **98% 감소**
- 전체 20 usages: 2,200 lines → 80 lines = **96% 감소**

**VersusTextField Features**:
```dart
class VersusTextField extends StatelessWidget {
  // Required
  final TextEditingController controller;
  final String label;

  // Optional - Common
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final FormFieldValidator<String>? validator;

  // Optional - Icons
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;

  // Optional - Callbacks
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;

  // Optional - Styling
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;

  // ... Auto design token usage
}
```

---

### 2. VersusButton (우선순위: HIGH ⭐⭐⭐⭐)

**설명**: 모든 버튼 액션을 위한 범용 Button 컴포넌트

**사용 현황**:
- Auth Feature: 18 usages (로그인, 회원가입, 비밀번호 재설정)
- Profile Feature: 18 usages (프로필 수정, 설정)
- Creation Feature: 32 usages (게시물 생성, 미디어 업로드)
- Voting Feature: 24 usages (투표 제출)
- **전체: 92+ usages**

**Before/After**:
```dart
// ❌ BEFORE: auth_button.dart (267 lines)
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,  // Hardcoded
      decoration: BoxDecoration(
        gradient: onPressed != null
            ? LinearGradient(
                colors: [
                  Color(0xFF6B4EFF),  // Hardcoded
                  Color(0xFF8B5FFF),  // Hardcoded
                ],
              )
            : null,
        color: onPressed == null ? Color(0xFFE0E0E0) : null,  // Hardcoded
        borderRadius: BorderRadius.circular(12),  // Hardcoded
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: Color(0xFF6B4EFF).withOpacity(0.3),  // Hardcoded
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),  // Hardcoded
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,  // Hardcoded
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: 18,  // Hardcoded
                      fontWeight: FontWeight.w600,
                      color: Colors.white,  // Hardcoded
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ✅ AFTER: VersusButton component
VersusButton(
  text: 'Sign In',
  onPressed: _handleSignIn,
  isLoading: isSigningIn,
  fullWidth: true,
)

VersusButton(
  text: 'Sign Up',
  onPressed: _handleSignUp,
  variant: VersusButtonVariant.secondary,
  fullWidth: true,
)
```

**코드 감소**: 267 lines → 4 lines per usage = **98% 감소**

---

### 3. VersusSocialLoginButton (우선순위: MEDIUM ⭐⭐⭐)

**설명**: Apple/Google/Email 소셜 로그인 버튼

**사용 현황**:
- Auth Feature: 6 usages (Apple×2, Google×2, Email×2)
- Profile Feature: 2 usages (계정 연결)
- **전체: 8+ usages**

**Before/After**:
```dart
// ❌ BEFORE: social_login_button.dart (189 lines)
class SocialLoginButton extends StatelessWidget {
  final String provider;  // 'apple', 'google', 'email'
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,  // Hardcoded
      decoration: BoxDecoration(
        color: _getBackgroundColor(provider),  // Hardcoded logic
        borderRadius: BorderRadius.circular(12),  // Hardcoded
        border: Border.all(
          color: Color(0xFFE0E0E0),  // Hardcoded
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),  // Hardcoded
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _getProviderIcon(provider),  // Custom logic
              SizedBox(width: 12),  // Hardcoded
              Text(
                _getProviderText(provider),  // Custom logic
                style: TextStyle(
                  fontSize: 16,  // Hardcoded
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF14142B),  // Hardcoded
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(String provider) {
    switch (provider) {
      case 'apple':
        return Colors.black;  // Hardcoded
      case 'google':
        return Colors.white;  // Hardcoded
      default:
        return Color(0xFFF5F5F5);  // Hardcoded
    }
  }

  // ... 100+ lines of custom logic
}

// ✅ AFTER: VersusSocialLoginButton component
VersusSocialLoginButton.apple(
  onPressed: _signInWithApple,
)

VersusSocialLoginButton.google(
  onPressed: _signInWithGoogle,
)

VersusSocialLoginButton.email(
  onPressed: _signInWithEmail,
)
```

**코드 감소**: 189 lines → 3 lines per usage = **98% 감소**

---

## 🚀 Phase 2: 컴포넌트 도입

### Phase 2 개요 (16시간, 2일)

```
Phase 2: 컴포넌트 도입
├─ Day 3 (PM) + Day 4 (AM): VersusTextField 도입 (8시간)
│   ├─ 컴포넌트 정의 (2시간)
│   ├─ 20개 사용처 교체 (4시간)
│   └─ 테스트 (2시간)
│
└─ Day 4 (PM) + Day 5 (AM): VersusButton 도입 (8시간)
    ├─ VersusButton 정의 (2시간)
    ├─ 18개 사용처 교체 (3시간)
    ├─ VersusSocialLoginButton 정의 (1시간)
    ├─ 6개 사용처 교체 (1시간)
    └─ 테스트 (1시간)
```

---

### VersusTextField 도입 (8시간)

**1단계: 컴포넌트 정의** (2시간)

파일: `lib/core/design_system/components/atoms/versus_text_field.dart`

```dart
import 'package:flutter/material.dart';
import 'package:versus_space/core/design_system/tokens/versus_colors.dart';
import 'package:versus_space/core/design_system/tokens/versus_spacing.dart';
import 'package:versus_space/core/design_system/tokens/versus_radius.dart';
import 'package:versus_space/core/design_system/tokens/versus_typography.dart';

class VersusTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;

  const VersusTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.errorText,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  State<VersusTextField> createState() => _VersusTextFieldState();
}

class _VersusTextFieldState extends State<VersusTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label,
          style: VersusTypography.labelMedium.copyWith(
            color: VersusColors.textSecondary,
          ),
        ),
        SizedBox(height: VersusSpacing.xs),

        // TextField
        Container(
          decoration: BoxDecoration(
            color: widget.enabled
                ? VersusColors.surface
                : VersusColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(VersusRadius.md),
            border: Border.all(
              color: hasError
                  ? VersusColors.error
                  : _isFocused
                      ? VersusColors.primary
                      : VersusColors.border,
              width: _isFocused ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            onChanged: widget.onChanged,
            onEditingComplete: widget.onEditingComplete,
            onSubmitted: widget.onSubmitted,
            style: VersusTypography.bodyMedium.copyWith(
              color: VersusColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: VersusTypography.bodyMedium.copyWith(
                color: VersusColors.textTertiary,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: VersusSpacing.md,
                vertical: VersusSpacing.sm,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? VersusColors.primary
                          : VersusColors.textTertiary,
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? IconButton(
                      icon: Icon(
                        widget.suffixIcon,
                        color: VersusColors.textTertiary,
                      ),
                      onPressed: widget.onSuffixIconTap,
                    )
                  : hasError
                      ? Icon(
                          Icons.error,
                          color: VersusColors.error,
                        )
                      : null,
            ),
          ),
        ),

        // Error message
        if (hasError) ...[
          SizedBox(height: VersusSpacing.xs),
          Text(
            widget.errorText!,
            style: VersusTypography.bodySmall.copyWith(
              color: VersusColors.error,
            ),
          ),
        ],
      ],
    );
  }
}
```

**2단계: 20개 사용처 교체** (4시간)

```bash
# Auth Feature에서 TextField 사용처 검색
grep -r "TextField\|TextFormField\|email_input_widget\|password_input_widget" \
  lib/features/auth/presentation/

# 예상 사용처:
# 1. sign_in_page.dart (Email, Password) - 2회
# 2. sign_up_page.dart (Name, Email, Password, Confirm Password) - 4회
# 3. password_reset_page.dart (Email) - 1회
# 4. edit_profile_page.dart (Name, Bio, Location) - 3회
# ... 총 20회
```

**교체 예시**:

```dart
// ❌ BEFORE: sign_in_page.dart (456 lines)
Column(
  children: [
    EmailInputWidget(
      controller: _emailController,
      errorText: _emailError,
    ),
    SizedBox(height: 16),
    PasswordInputWidget(
      controller: _passwordController,
      errorText: _passwordError,
    ),
  ],
)

// ✅ AFTER: sign_in_page.dart (178 lines)
Column(
  children: [
    VersusTextField(
      controller: _emailController,
      label: 'Email',
      hintText: 'Enter your email',
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email,
      errorText: _emailError,
    ),
    SizedBox(height: VersusSpacing.md),
    VersusTextField(
      controller: _passwordController,
      label: 'Password',
      hintText: 'Enter your password',
      obscureText: !_passwordVisible,
      prefixIcon: Icons.lock,
      suffixIcon: _passwordVisible ? Icons.visibility : Icons.visibility_off,
      onSuffixIconTap: () => setState(() => _passwordVisible = !_passwordVisible),
      errorText: _passwordError,
    ),
  ],
)
```

---

## 📝 Before/After 코드 예시

### 예시 1: start_page_widget.dart (완전한 파일 변환)

#### Before (892 lines, 56 hardcoding) ← WORST FILE

```dart
// lib/features/auth/presentation/screens/start/start_page_widget.dart
import 'package:flutter/material.dart';

class StartPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8E8E8),  // ❌ Hardcoded
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),  // ❌ Hardcoded
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section (234 lines)
              Container(
                width: 120,  // ❌ Hardcoded
                height: 120,  // ❌ Hardcoded
                decoration: BoxDecoration(
                  color: Colors.white,  // ❌ Hardcoded
                  borderRadius: BorderRadius.circular(24),  // ❌ Hardcoded
                ),
                child: Center(
                  child: Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 48,  // ❌ Hardcoded
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B4EFF),  // ❌ Hardcoded
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),  // ❌ Hardcoded

              // Title
              Text(
                'Welcome to\nVersus Space',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,  // ❌ Hardcoded
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF14142B),  // ❌ Hardcoded
                  height: 1.2,
                ),
              ),
              SizedBox(height: 16),  // ❌ Hardcoded

              // Subtitle
              Text(
                'Join the community and\nmake your voice heard',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,  // ❌ Hardcoded
                  color: Color(0xFF6B7280),  // ❌ Hardcoded
                  height: 1.5,
                ),
              ),
              SizedBox(height: 48),  // ❌ Hardcoded

              // Login Buttons (330 lines)
              _buildSocialLoginButton(
                context,
                provider: 'apple',
                icon: Icons.apple,
                text: 'Sign in with Apple',
              ),
              SizedBox(height: 16),  // ❌ Hardcoded
              _buildSocialLoginButton(
                context,
                provider: 'google',
                icon: Icons.g_mobiledata,
                text: 'Sign in with Google',
              ),
              SizedBox(height: 16),  // ❌ Hardcoded
              _buildEmailLoginButton(context),

              SizedBox(height: 24),  // ❌ Hardcoded

              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Color(0xFFE0E0E0),  // ❌ Hardcoded
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),  // ❌ Hardcoded
                    child: Text(
                      'or',
                      style: TextStyle(
                        fontSize: 14,  // ❌ Hardcoded
                        color: Color(0xFF6B7280),  // ❌ Hardcoded
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Color(0xFFE0E0E0),  // ❌ Hardcoded
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24),  // ❌ Hardcoded

              // Sign Up Button
              _buildSignUpButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButton(
    BuildContext context, {
    required String provider,
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      height: 56,  // ❌ Hardcoded
      decoration: BoxDecoration(
        color: provider == 'apple' ? Colors.black : Colors.white,  // ❌ Hardcoded
        borderRadius: BorderRadius.circular(12),  // ❌ Hardcoded
        border: Border.all(
          color: Color(0xFFE0E0E0),  // ❌ Hardcoded
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleSocialLogin(context, provider),
          borderRadius: BorderRadius.circular(12),  // ❌ Hardcoded
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: provider == 'apple' ? Colors.white : Colors.black,  // ❌ Hardcoded
              ),
              SizedBox(width: 12),  // ❌ Hardcoded
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,  // ❌ Hardcoded
                  fontWeight: FontWeight.w600,
                  color: provider == 'apple' ? Colors.white : Color(0xFF14142B),  // ❌ Hardcoded
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... 500+ more lines
}
```

#### After (245 lines, 0 hardcoding) - **73% 감소**

```dart
// lib/features/auth/presentation/screens/start/start_page_widget.dart
import 'package:flutter/material.dart';
import 'package:versus_space/core/design_system/tokens/versus_colors.dart';
import 'package:versus_space/core/design_system/tokens/versus_spacing.dart';
import 'package:versus_space/core/design_system/tokens/versus_radius.dart';
import 'package:versus_space/core/design_system/tokens/versus_typography.dart';
import 'package:versus_space/core/design_system/components/atoms/versus_button.dart';
import 'package:versus_space/core/design_system/components/molecules/versus_social_login_button.dart';

class StartPageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VersusColors.backgroundSecondary,  // ✅ Token
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(VersusSpacing.lg),  // ✅ Token
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section - VersusAppLogo component
              VersusAppLogo(size: VersusLogoSize.large),

              SizedBox(height: VersusSpacing.xxl),  // ✅ Token

              // Title
              Text(
                'Welcome to\nVersus Space',
                textAlign: TextAlign.center,
                style: VersusTypography.displayMedium.copyWith(  // ✅ Token
                  color: VersusColors.textPrimary,  // ✅ Token
                ),
              ),
              SizedBox(height: VersusSpacing.md),  // ✅ Token

              // Subtitle
              Text(
                'Join the community and\nmake your voice heard',
                textAlign: TextAlign.center,
                style: VersusTypography.bodyLarge.copyWith(  // ✅ Token
                  color: VersusColors.textSecondary,  // ✅ Token
                ),
              ),
              SizedBox(height: VersusSpacing.xxxl),  // ✅ Token

              // Login Buttons - VersusSocialLoginButton components
              VersusSocialLoginButton.apple(
                onPressed: () => _handleSocialLogin(context, 'apple'),
              ),
              SizedBox(height: VersusSpacing.md),  // ✅ Token

              VersusSocialLoginButton.google(
                onPressed: () => _handleSocialLogin(context, 'google'),
              ),
              SizedBox(height: VersusSpacing.md),  // ✅ Token

              VersusSocialLoginButton.email(
                onPressed: () => _navigateToSignIn(context),
              ),

              SizedBox(height: VersusSpacing.lg),  // ✅ Token

              // Divider
              VersusDivider(text: 'or'),  // ✅ Component

              SizedBox(height: VersusSpacing.lg),  // ✅ Token

              // Sign Up Button
              VersusButton(
                text: 'Create Account',
                onPressed: () => _navigateToSignUp(context),
                variant: VersusButtonVariant.secondary,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSocialLogin(BuildContext context, String provider) {
    // Navigation logic
  }

  void _navigateToSignIn(BuildContext context) {
    // Navigation logic
  }

  void _navigateToSignUp(BuildContext context) {
    // Navigation logic
  }
}
```

**개선 요약**:

| 메트릭 | Before | After | 개선율 |
|--------|--------|-------|--------|
| **총 라인 수** | 892 | 245 | 73% 감소 |
| **하드코딩** | 56 instances | 0 instances | 100% 제거 |
| **커스텀 위젯** | 3개 (330줄) | 0개 (컴포넌트 사용) | 100% 제거 |
| **토큰 사용** | 0% | 100% | - |
| **컴포넌트 재사용** | 0 | 8 (Logo, Button×4, Divider) | - |

---

## ✅ Phase 3: 품질 보증

### 테스트 전략 (4시간)

#### 1. E2E 로그인 플로우 테스트 (2시간)

```dart
// test/features/auth/integration/auth_e2e_test.dart
void main() {
  group('Auth E2E Flow', () {
    testWidgets('Complete sign-in flow', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: StartPageWidget()),
        ),
      );

      // 1. Start page displayed
      expect(find.byType(StartPageWidget), findsOneWidget);
      expect(find.text('Welcome to\nVersus Space'), findsOneWidget);

      // 2. Tap "Sign in with Email"
      await tester.tap(find.text('Sign in with Email'));
      await tester.pumpAndSettle();

      // 3. Sign-in page displayed
      expect(find.byType(SignInPage), findsOneWidget);

      // 4. Enter email
      await tester.enterText(
        find.byType(VersusTextField).first,
        'test@example.com',
      );

      // 5. Enter password
      await tester.enterText(
        find.byType(VersusTextField).last,
        'password123',
      );

      // 6. Tap sign-in button
      await tester.tap(find.widgetWithText(VersusButton, 'Sign In'));
      await tester.pumpAndSettle();

      // 7. Main app displayed (after successful auth)
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('Validation errors display correctly', (tester) async {
      // Test email/password validation
    });
  });
}
```

#### 2. Golden 테스트 (1시간)

```dart
// test/features/auth/presentation/screens/start_page_golden_test.dart
void main() {
  group('StartPageWidget Golden Tests', () {
    testWidgets('matches golden file - default state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: StartPageWidget()),
      );

      await expectLater(
        find.byType(StartPageWidget),
        matchesGoldenFile('goldens/start_page_default.png'),
      );
    });
  });
}
```

#### 3. 보안 테스트 (1시간)

```dart
// test/features/auth/security/security_test.dart
void main() {
  group('Security Tests', () {
    test('No hardcoded API keys', () {
      // Scan code for potential API key patterns
      final authFiles = Directory('lib/features/auth')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));

      for (final file in authFiles) {
        final content = file.readAsStringSync();

        // Check for potential API keys
        expect(
          content.contains(RegExp(r'AIza[0-9A-Za-z-_]{35}')),
          isFalse,
          reason: 'Found potential Google API key in ${file.path}',
        );

        // Check for hardcoded tokens
        expect(
          content.contains(RegExp(r'sk_[a-zA-Z0-9]{48}')),
          isFalse,
          reason: 'Found potential secret token in ${file.path}',
        );
      }
    });

    test('Password fields use obscureText', () {
      // Verify all password TextFields use obscureText=true
    });
  });
}
```

---

## 💡 Best Practices

### 1. VersusTextField 범용 패턴

**재사용 가능한 모든 Feature**:
- Auth: Email, Password, Name (20 usages)
- Profile: 프로필 수정 폼 (8 usages)
- Creation: 제목, 설명, 태그 (12 usages)
- Chat: 메시지 입력 (15+ usages)

**Form Validation 패턴**:
```dart
class SignInPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          VersusTextField(
            controller: _emailController,
            label: 'Email',
            hintText: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email,
            errorText: _emailError,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!EmailValidator.validate(value)) {
                return 'Invalid email format';
              }
              return null;
            },
            onChanged: (value) {
              setState(() => _emailError = null);
            },
          ),

          VersusTextField(
            controller: _passwordController,
            label: 'Password',
            hintText: 'Enter your password',
            obscureText: !_passwordVisible,
            prefixIcon: Icons.lock,
            suffixIcon: _passwordVisible
                ? Icons.visibility
                : Icons.visibility_off,
            onSuffixIconTap: () => setState(
              () => _passwordVisible = !_passwordVisible
            ),
            errorText: _passwordError,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
            onChanged: (value) {
              setState(() => _passwordError = null);
            },
          ),

          SizedBox(height: VersusSpacing.lg),

          VersusButton(
            text: 'Sign In',
            onPressed: _handleSignIn,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await ref.read(
      signInUseCaseProvider
    ).call(
      _emailController.text,
      _passwordController.text,
    );

    result.fold(
      (failure) {
        setState(() {
          if (failure is InvalidCredentials) {
            _emailError = 'Invalid email or password';
            _passwordError = 'Invalid email or password';
          }
        });
      },
      (user) {
        // Navigate to home
      },
    );
  }
}
```

### 2. 보안 하드코딩 체크리스트

```
□ API 키
  □ Firebase API 키는 firebase_options.dart에만 존재
  □ Google Client ID는 환경 변수로 관리
  □ Apple Team ID는 .env 파일에서 로드

□ 인증 토큰
  □ JWT 토큰은 SecureStorage에 저장
  □ Refresh token은 암호화하여 저장
  □ 코드 내 토큰 하드코딩 없음

□ 비밀번호
  □ 모든 password 필드는 obscureText: true
  □ 비밀번호는 평문 저장 금지
  □ 비밀번호 검증은 서버 측에서만

□ 사용자 데이터
  □ PII (개인식별정보)는 암호화
  □ 로컬 DB (Hive)는 암호화 키 사용
  □ 민감 데이터 로그 출력 금지
```

### 3. 로그인 폼 표준화 전략

**일관성 가이드**:
```dart
// ✅ GOOD: 표준화된 폼 구조
Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    // 1. Title (h2)
    Text(
      'Sign In',
      style: VersusTypography.h2,
    ),
    SizedBox(height: VersusSpacing.lg),

    // 2. Form fields (VersusTextField)
    VersusTextField(label: 'Email', ...),
    SizedBox(height: VersusSpacing.md),
    VersusTextField(label: 'Password', ...),

    // 3. Forgot password link (right-aligned)
    Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _navigateToForgotPassword,
        child: Text('Forgot password?'),
      ),
    ),
    SizedBox(height: VersusSpacing.lg),

    // 4. Primary action button (VersusButton)
    VersusButton(
      text: 'Sign In',
      onPressed: _handleSignIn,
      fullWidth: true,
    ),

    // 5. Divider
    SizedBox(height: VersusSpacing.lg),
    VersusDivider(text: 'or'),
    SizedBox(height: VersusSpacing.lg),

    // 6. Social login buttons
    VersusSocialLoginButton.apple(...),
    SizedBox(height: VersusSpacing.sm),
    VersusSocialLoginButton.google(...),
  ],
)
```

---

## ✅ 완료 체크리스트

### Phase 2 완료 조건

```
□ VersusTextField 도입
  □ 컴포넌트 정의 (120 lines)
  □ 20개 사용처 교체
  □ Widget 테스트 작성
  □ Form validation 테스트

□ VersusButton 도입
  □ 컴포넌트 정의 (80 lines)
  □ 18개 사용처 교체
  □ Widget 테스트 작성

□ VersusSocialLoginButton 도입
  □ 컴포넌트 정의 (60 lines)
  □ 6개 사용처 교체 (Apple, Google, Email)
  □ Widget 테스트 작성
```

### Phase 3 완료 조건

```
□ E2E 로그인 플로우 테스트
  □ Start page → Sign-in → Home
  □ Validation error handling
  □ Social login flows

□ Golden 테스트
  □ start_page_widget_golden_test.dart
  □ sign_in_page_golden_test.dart
  □ sign_up_page_golden_test.dart

□ 보안 테스트
  □ 하드코딩 API 키 스캔
  □ 비밀번호 필드 obscureText 확인
  □ 민감 데이터 로그 출력 체크

□ 코드 리뷰
  □ 모든 하드코딩 제거 확인
  □ 토큰 사용 100% 확인
  □ 컴포넌트 일관성 확인
  □ 보안 체크리스트 검증
```

### 최종 검증

```
□ 메트릭 검증
  □ 토큰 채택률: 95%
  □ 하드코딩: <10 instances
  □ 코드 감소: 2,500줄 (34.5%)
  □ 컴포넌트 재사용: 44회 (TextField×20, Button×18, SocialButton×6)

□ 성능 검증
  □ 로그인 플로우 속도 유지 (<2초)
  □ 폼 입력 반응성 (<50ms)

□ 품질 검증
  □ flutter analyze (0 errors)
  □ flutter test (모든 테스트 통과)
  □ E2E 테스트 통과
  □ 보안 스캔 통과

□ 문서화
  □ README 업데이트
  □ Component 문서 작성 (VersusTextField 핵심)
  □ Security 가이드 작성
```

---

## 🔗 다음 단계

**Part 10: Feature Notifications 문서**
- Notifications Feature: 5% → 95% 토큰 채택
- 11 files, 3,456 lines
- 35 hardcoding instances
- Badge UI 최적화

**Part 11: Feature Chat 문서**
- Chat Feature: 0% → 95% 토큰 채택
- 19 files, 5,678 lines
- 45 hardcoding instances
- flutter_chat_ui 통합

---

**Part 9-2 문서 종료** (Auth Feature 컴포넌트 도입 및 구현 가이드)

→ **다음**: Part 10 (Notifications Feature)
