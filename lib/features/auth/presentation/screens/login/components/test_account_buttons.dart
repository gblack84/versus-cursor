import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core_exports.dart';

class TestAccountButtons extends StatelessWidget {
  final Future<void> Function({
    required String email,
    required String password,
    required String displayName,
    required String role,
    String? platform,
  }) onTestAccountLogin;

  const TestAccountButtons({
    super.key,
    required this.onTestAccountLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: 400.0,
      ),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Test Accounts',
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.plusJakartaSans(),
                    letterSpacing: 0.0,
                  ),
            ),
            SizedBox(height: 12.0),
            // 첫 번째 줄: 관리자, iOS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 관리자 계정
                AppButtonWidget(
                  onPressed: () async {
                    await onTestAccountLogin(
                      email: 'admin@versus.test',
                      password: 'test1234!',
                      displayName: '관리자',
                      role: 'admin',
                    );
                  },
                  text: '관리자',
                  options: AppButtonOptions(
                    width: 100.0,
                    height: 40.0,
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: AppTheme.of(context).primary,
                    textStyle: AppTheme.of(context).titleSmall.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: Colors.white,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        ),
                    elevation: 3.0,
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                SizedBox(width: 12.0),
                // iOS 테스트 계정
                AppButtonWidget(
                  onPressed: () async {
                    await onTestAccountLogin(
                      email: 'tester-ios@versus.test',
                      password: 'test1234!',
                      displayName: '테스터 (아이폰 16 프로)',
                      role: 'tester',
                      platform: 'ios',
                    );
                  },
                  text: '아이폰 16 프로',
                  options: AppButtonOptions(
                    width: 120.0,
                    height: 40.0,
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: AppTheme.of(context).secondary,
                    textStyle: AppTheme.of(context).titleSmall.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: Colors.white,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        ),
                    elevation: 3.0,
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.0),
            // 두 번째 줄: Android, macOS, 웹앱
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Android 테스트 계정
                AppButtonWidget(
                  onPressed: () async {
                    await onTestAccountLogin(
                      email: 'tester-android@versus.test',
                      password: 'test1234!',
                      displayName: '테스터 (갤럭시 S24)',
                      role: 'tester',
                      platform: 'android',
                    );
                  },
                  text: '갤럭시 S24',
                  options: AppButtonOptions(
                    width: 100.0,
                    height: 40.0,
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: AppTheme.of(context).tertiary,
                    textStyle: AppTheme.of(context).titleSmall.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: Colors.white,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        ),
                    elevation: 3.0,
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                SizedBox(width: 8.0),
                // macOS 테스트 계정
                AppButtonWidget(
                  onPressed: () async {
                    await onTestAccountLogin(
                      email: 'tester-mac@versus.test',
                      password: 'test1234!',
                      displayName: '테스터 (맥북)',
                      role: 'tester',
                      platform: 'macos',
                    );
                  },
                  text: '맥북',
                  options: AppButtonOptions(
                    width: 75.0,
                    height: 40.0,
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: AppTheme.of(context).accent1,
                    textStyle: AppTheme.of(context).titleSmall.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: Colors.white,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        ),
                    elevation: 3.0,
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                SizedBox(width: 8.0),
                // Web 테스트 계정
                AppButtonWidget(
                  onPressed: () async {
                    await onTestAccountLogin(
                      email: 'tester-web@versus.test',
                      password: 'test1234!',
                      displayName: '테스터 (웹앱)',
                      role: 'tester',
                      platform: 'web',
                    );
                  },
                  text: '웹앱',
                  options: AppButtonOptions(
                    width: 75.0,
                    height: 40.0,
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    iconPadding:
                        EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                    color: AppTheme.of(context).accent2,
                    textStyle: AppTheme.of(context).titleSmall.override(
                          font: GoogleFonts.plusJakartaSans(),
                          color: Colors.white,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        ),
                    elevation: 3.0,
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}