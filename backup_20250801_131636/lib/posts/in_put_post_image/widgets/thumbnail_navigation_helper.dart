import 'dart:io';
import 'package:flutter/material.dart';

/// 썸네일 네비게이션 관련 헬퍼 클래스
class ThumbnailNavigationHelper {
  /// 썸네일 선택 페이지 결과 처리
  static void handleThumbnailResult({
    required BuildContext context,
    required Map<String, dynamic>? result,
    required bool mounted,
    required List<File> files,
    required Function(String action) onBackToPicker,
    required Function({
      required File selectedFile,
      required int currentEditIndex,
      required List<File> allSelectedFiles,
    }) onImageSelected,
    required VoidCallback onCancel,
  }) {
    if (result != null && mounted) {
      // 뒤로가기 액션인 경우 피커로 돌아가기
      if (result['action'] == 'back_to_picker') {
        onBackToPicker('back_to_picker');
      } else if (result['selectedIndex'] != null) {
        // 정상적으로 이미지를 선택한 경우
        final selectedIndex = result['selectedIndex'] as int;
        onImageSelected(
          selectedFile: files[selectedIndex],
          currentEditIndex: selectedIndex,
          allSelectedFiles: files,
        );
      }
    } else {
      // 취소한 경우
      if (mounted) {
        onCancel();
      }
    }
  }
}