import 'package:flutter/material.dart';

/// Versus Space 간격 시스템
///
/// 기존 코드에서 자주 사용되는 패딩/마진 값들을 표준화했습니다.
/// EdgeInsetsDirectional.fromSTEB(20.0, 2.0, 20.0, 0.0) 같은
/// 하드코딩된 값들을 대체합니다.
class VersusSpacing {
  // 기본 간격 단위 (4px 기반)
  static const double xs = 4.0; // 매우 작은 간격
  static const double sm = 8.0; // 작은 간격
  static const double md = 16.0; // 기본 간격 (가장 많이 사용)
  static const double lg = 20.0; // 큰 간격 (기존 코드에서 많이 사용)
  static const double xl = 32.0; // 매우 큰 간격
  static const double xxl = 48.0; // 섹션 구분용

  // 자주 사용되는 패딩 값들 (기존 패턴 기반)
  static const double cardPadding = md; // 카드 내부 패딩
  static const double screenPadding = lg; // 화면 양쪽 패딩 (20px)
  static const double buttonPadding = sm; // 버튼 내부 패딩
  static const double dialogPadding = md; // 다이얼로그 패딩

  // EdgeInsets 헬퍼 메서드
  static EdgeInsets get paddingXS => const EdgeInsets.all(xs);
  static EdgeInsets get paddingSM => const EdgeInsets.all(sm);
  static EdgeInsets get paddingMD => const EdgeInsets.all(md);
  static EdgeInsets get paddingLG => const EdgeInsets.all(lg);
  static EdgeInsets get paddingXL => const EdgeInsets.all(xl);

  // 방향별 패딩 (기존 EdgeInsetsDirectional.fromSTEB 패턴 대체)
  static EdgeInsets horizontal(double value) =>
      EdgeInsets.symmetric(horizontal: value);
  static EdgeInsets vertical(double value) =>
      EdgeInsets.symmetric(vertical: value);

  // 기존 코드에서 자주 사용되는 패턴들
  static EdgeInsets get screenHorizontal =>
      horizontal(screenPadding); // 좌우 20px
  static EdgeInsets get cardInternal => paddingMD; // 카드 내부 16px
  static EdgeInsets get buttonInternal => const EdgeInsets.symmetric(
      // 버튼 내부
      horizontal: md,
      vertical: sm);

  // 커스텀 패딩 생성기
  static EdgeInsets custom({
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) =>
      EdgeInsets.only(
        top: top ?? 0,
        bottom: bottom ?? 0,
        left: left ?? 0,
        right: right ?? 0,
      );

  // 기존 EdgeInsetsDirectional.fromSTEB 스타일 대체
  static EdgeInsetsDirectional fromSTEB(
          double start, double top, double end, double bottom) =>
      EdgeInsetsDirectional.fromSTEB(start, top, end, bottom);

  // SizedBox 간격 헬퍼
  static Widget get gapXS => const SizedBox(height: xs);
  static Widget get gapSM => const SizedBox(height: sm);
  static Widget get gapMD => const SizedBox(height: md);
  static Widget get gapLG => const SizedBox(height: lg);
  static Widget get gapXL => const SizedBox(height: xl);

  static Widget gapH(double width) => SizedBox(width: width);
  static Widget gapV(double height) => SizedBox(height: height);
}
