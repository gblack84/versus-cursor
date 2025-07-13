import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/app_state.dart';
import '../in_put_post_image_model.dart';

/// MediaSelectionBox의 콜백을 관리하는 헬퍼 클래스
class MediaBoxCallbacks {
  final BuildContext context;
  final InPutPostImageModel model;
  final VoidCallback showBBoxWarning;
  final Function(BuildContext, String, {bool isAddMode, int? currentIndex}) openAssetsPicker;
  final VoidCallback showSnackBar;
  final VoidCallback updateLayout;
  final void Function(VoidCallback) setState;

  MediaBoxCallbacks({
    required this.context,
    required this.model,
    required this.showBBoxWarning,
    required this.openAssetsPicker,
    required this.showSnackBar,
    required this.updateLayout,
    required this.setState,
  });

  AppState get appState => Provider.of<AppState>(context, listen: false);

  /// 박스 표시 토글
  void toggleBoxVisibility() {
    setState(() {
      model.absellected = false;
    });
  }

  /// 이미지 추가 처리
  Future<void> handleAddImage(String box, int currentIndex) async {
    if (box == 'B' && appState.uploadImageA.isEmpty) {
      showBBoxWarning();
    } else {
      // 추가 모드로 피커 열기
      await openAssetsPicker(context, box, isAddMode: true, currentIndex: currentIndex);
    }
  }

  /// 현재 인덱스 업데이트
  void updateCurrentIndex(String box, int index) {
    setState(() {
      if (box == 'A') {
        model.currentImageIndexA = index;
      } else {
        model.currentImageIndexB = index;
      }
    });
  }

  /// 이미지 삭제 처리 (단순화)
  void deleteImage(String box, int index) {
    setState(() {
      if (box == 'A') {
        _deleteFromA(index);
      } else {
        _deleteFromB(index);
      }
    });
    updateLayout();
  }

  void _deleteFromA(int index) {
    print('A박스 이미지 삭제 실행 - 인덱스: $index, 현재 이미지 개수: ${appState.uploadImageA.length}');
    if (index < appState.uploadImageA.length) {
      print('삭제 전 이미지 URL: ${appState.uploadImageA[index]}');
      appState.removeAtIndexFromUploadImageA(index);
      if (index < appState.uploadImageAspectRatioA.length) {
        appState.removeAtIndexFromUploadImageAspectRatioA(index);
      }
      if (index < appState.assetEntityIdsA.length) {
        appState.removeAtIndexFromAssetEntityIdsA(index);
      }
      print('삭제 후 남은 이미지 개수: ${appState.uploadImageA.length}');
      
      // currentIndex 조정
      if (appState.uploadImageA.isNotEmpty) {
        model.currentImageIndexA = model.currentImageIndexA.clamp(0, appState.uploadImageA.length - 1);
      } else {
        model.currentImageIndexA = 0;
      }
    } else {
      print('삭제 실패 - 인덱스가 범위를 벗어남');
    }
  }

  void _deleteFromB(int index) {
    if (index < appState.uploadImageB.length) {
      appState.removeAtIndexFromUploadImageB(index);
      if (index < appState.uploadImageAspectRatioB.length) {
        appState.removeAtIndexFromUploadImageAspectRatioB(index);
      }
      if (index < appState.assetEntityIdsB.length) {
        appState.removeAtIndexFromAssetEntityIdsB(index);
      }
      
      // currentIndex 조정
      if (appState.uploadImageB.isNotEmpty) {
        model.currentImageIndexB = model.currentImageIndexB.clamp(0, appState.uploadImageB.length - 1);
      } else {
        model.currentImageIndexB = 0;
      }
    } else {
      // B박스에 이미지가 없을 때 X 클릭 시 B박스 숨기기
      setState(() {
        model.absellected = true;
      });
    }
  }
}