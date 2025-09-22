import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core_exports.dart';

class EmailLoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final bool passwordVisibility;
  final VoidCallback onPasswordVisibilityToggle;
  final String? Function(String?)? emailValidator;
  final String? Function(String?)? passwordValidator;

  const EmailLoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.passwordVisibility,
    required this.onPasswordVisibilityToggle,
    this.emailValidator,
    this.passwordValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Email Input Field
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
          child: Container(
            width: double.infinity,
            child: TextFormField(
              controller: emailController,
              focusNode: emailFocusNode,
              autofocus: true,
              autofillHints: [AutofillHints.email],
              obscureText: false,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).getText(
                  'b6l0k8k2', // Email
                ),
                labelStyle: AppTheme.of(context).labelMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500,
                      ),
                      color: Color(0xFF57636C),
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                    ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFE0E3E7),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF4B39EF),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFFF5963),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFFF5963),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(24.0),
              ),
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w500,
                    ),
                    color: Colors.black,
                    fontSize: 14.0,
                    letterSpacing: 0.0,
                  ),
              keyboardType: TextInputType.emailAddress,
              validator: emailValidator,
            ),
          ),
        ),
        // Password Input Field
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
          child: Container(
            width: double.infinity,
            child: TextFormField(
              controller: passwordController,
              focusNode: passwordFocusNode,
              autofocus: false,
              autofillHints: [AutofillHints.password],
              obscureText: !passwordVisibility,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).getText(
                  'r9kvd7pf', // Password
                ),
                labelStyle: AppTheme.of(context).labelMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500,
                      ),
                      color: Color(0xFF57636C),
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                    ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFE0E3E7),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF4B39EF),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFFF5963),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFFFF5963),
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(24.0),
                suffixIcon: InkWell(
                  onTap: onPasswordVisibilityToggle,
                  focusNode: FocusNode(skipTraversal: true),
                  child: Icon(
                    passwordVisibility
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Color(0xFF57636C),
                    size: 24.0,
                  ),
                ),
              ),
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w500,
                    ),
                    color: Colors.black,
                    fontSize: 14.0,
                    letterSpacing: 0.0,
                  ),
              keyboardType: TextInputType.visiblePassword,
              validator: passwordValidator,
            ),
          ),
        ),
      ],
    );
  }
}