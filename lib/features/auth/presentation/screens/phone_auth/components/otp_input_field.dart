import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core_exports.dart';

class OtpInputField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Function(String) onCompleted;
  final String? Function(String?)? validator;

  const OtpInputField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onCompleted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(10.0, 10.0, 10.0, 10.0),
      child: Container(
        decoration: BoxDecoration(),
        child: PinCodeTextField(
          autoDisposeControllers: false,
          appContext: context,
          length: 6,
          textStyle: AppTheme.of(context).bodyLarge.override(
                font: GoogleFonts.plusJakartaSans(
                  fontWeight: AppTheme.of(context).bodyLarge.fontWeight,
                  fontStyle: AppTheme.of(context).bodyLarge.fontStyle,
                ),
                letterSpacing: 0.0,
                fontWeight: AppTheme.of(context).bodyLarge.fontWeight,
                fontStyle: AppTheme.of(context).bodyLarge.fontStyle,
              ),
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          enableActiveFill: false,
          autoFocus: true,
          focusNode: focusNode,
          enablePinAutofill: false,
          errorTextSpace: 16.0,
          showCursor: true,
          cursorColor: AppTheme.of(context).primary,
          obscureText: false,
          hintCharacter: '●',
          keyboardType: TextInputType.number,
          pinTheme: PinTheme(
            fieldHeight: 44.0,
            fieldWidth: 44.0,
            borderWidth: 2.0,
            borderRadius: BorderRadius.circular(12.0),
            shape: PinCodeFieldShape.box,
            activeColor: AppTheme.of(context).primaryText,
            inactiveColor: AppTheme.of(context).alternate,
            selectedColor: AppTheme.of(context).primary,
          ),
          controller: controller,
          onChanged: (_) {},
          onCompleted: onCompleted,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
        ),
      ),
    );
  }
}