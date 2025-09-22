import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core_exports.dart';

class SignupForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final FocusNode passwordConfirmFocusNode;
  final bool passwordVisibility;
  final bool passwordConfirmVisibility;
  final VoidCallback onPasswordVisibilityToggle;
  final VoidCallback onPasswordConfirmVisibilityToggle;
  final String? Function(String?)? emailValidator;
  final String? Function(String?)? passwordValidator;
  final String? Function(String?)? passwordConfirmValidator;

  const SignupForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.passwordConfirmController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.passwordConfirmFocusNode,
    required this.passwordVisibility,
    required this.passwordConfirmVisibility,
    required this.onPasswordVisibilityToggle,
    required this.onPasswordConfirmVisibilityToggle,
    this.emailValidator,
    this.passwordValidator,
    this.passwordConfirmValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title
        Container(
          decoration: BoxDecoration(),
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
              child: Text(
                AppLocalizations.of(context).getText(
                  'r6bw196y', /* Create an account */
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: Colors.black,
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        // Subtitle
        Container(
          decoration: BoxDecoration(),
          child: Align(
            alignment: AlignmentDirectional(0.0, 0.0),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 24.0),
              child: Text(
                AppLocalizations.of(context).getText(
                  'vyjbjx7u', /* Let's get started by filling o... */
                ),
                textAlign: TextAlign.center,
                style: AppTheme.of(context).labelMedium.override(
                      font: GoogleFonts.plusJakartaSans(),
                      color: AppTheme.of(context).secondaryText,
                    ),
              ),
            ),
          ),
        ),
        // Email Field
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 16.0),
          child: Container(
            width: 370.0,
            child: TextFormField(
              controller: emailController,
              focusNode: emailFocusNode,
              autofocus: true,
              autofillHints: [AutofillHints.email],
              obscureText: false,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).getText('b4wuzum8', /* Email */),
                labelStyle: AppTheme.of(context).labelMedium,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.of(context).primary,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.of(context).error,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.of(context).error,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: Colors.black,
                  ),
              validator: emailValidator,
            ),
          ),
        ),
        // Password Field
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
          child: Container(
            width: 370.0,
            child: TextFormField(
              controller: passwordController,
              focusNode: passwordFocusNode,
              autofocus: true,
              autofillHints: [AutofillHints.password],
              obscureText: !passwordVisibility,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).getText('h5546n6k', /* Password */),
                labelStyle: AppTheme.of(context).labelMedium,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.of(context).primary,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.of(context).error,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.of(context).error,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: InkWell(
                  onTap: onPasswordVisibilityToggle,
                  focusNode: FocusNode(skipTraversal: true),
                  child: Icon(
                    passwordVisibility
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.of(context).secondaryText,
                    size: 24.0,
                  ),
                ),
              ),
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: Colors.black,
                  ),
              validator: passwordValidator,
            ),
          ),
        ),
        // Password Confirm Field
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
          child: Container(
            width: 370.0,
            child: TextFormField(
              controller: passwordConfirmController,
              focusNode: passwordConfirmFocusNode,
              autofocus: true,
              autofillHints: [AutofillHints.password],
              obscureText: !passwordConfirmVisibility,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).getText('3ytevuxh', /* Confirm Password */),
                labelStyle: AppTheme.of(context).labelMedium,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.of(context).primary,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.of(context).error,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppTheme.of(context).error,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: InkWell(
                  onTap: onPasswordConfirmVisibilityToggle,
                  focusNode: FocusNode(skipTraversal: true),
                  child: Icon(
                    passwordConfirmVisibility
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.of(context).secondaryText,
                    size: 24.0,
                  ),
                ),
              ),
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: Colors.black,
                  ),
              validator: passwordConfirmValidator,
            ),
          ),
        ),
      ],
    );
  }
}