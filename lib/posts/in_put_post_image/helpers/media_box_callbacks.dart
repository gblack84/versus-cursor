import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/app/state/app_state.dart';
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
    // 레이아웃 재계산 트리거
    updateLayout();
    
    // 디버그 로그
    print('[MediaBoxCallbacks] B박스 표시 - 레이아웃 재계산 실행');
  }

  /// 이미지 추가 처리
  Future<void> handleAddImage(String box, int currentIndex) async {
    if (box == 'B' && appState.tempImageFilesA.isEmpty) {
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
    print('A박스 이미지 삭제 실행 - 인덱스: $index, 현재 이미지 개수: ${appState.tempImageFilesA.length}');
    
    // tempImageFiles 사용 여부 확인
    if (appState.tempImageFilesA.isNotEmpty) {
      if (index < appState.tempImageFilesA.length) {
        // tempImageFiles에서 제거
        appState.removeAtIndexFromTempImageFilesA(index);
        if (index < appState.uploadImageAspectRatioA.length) {
          appState.removeAtIndexFromUploadImageAspectRatioA(index);
        }
        if (index < appState.assetEntityIdsA.length) {
          appState.removeAtIndexFromAssetEntityIdsA(index);
        }
        
        // currentIndex 조정
        if (appState.tempImageFilesA.isNotEmpty) {
          model.currentImageIndexA = model.currentImageIndexA.clamp(0, appState.tempImageFilesA.length - 1);
        } else {
          model.currentImageIndexA = 0;
        }
      }
    } else {
      print('삭제 실패 - 인덱스가 범위를 벗어남');
    }
  }

  void _deleteFromB(int index) {
    // tempImageFiles 사용 여부 확인
    if (appState.tempImageFilesB.isNotEmpty) {
      if (index < appState.tempImageFilesB.length) {
        // tempImageFiles에서 제거
        appState.removeAtIndexFromTempImageFilesB(index);
        if (index < appState.uploadImageAspectRatioB.length) {
          appState.removeAtIndexFromUploadImageAspectRatioB(index);
        }
        if (index < appState.assetEntityIdsB.length) {
          appState.removeAtIndexFromAssetEntityIdsB(index);
        }
        
        // currentIndex 조정
        if (appState.tempImageFilesB.isNotEmpty) {
          model.currentImageIndexB = model.currentImageIndexB.clamp(0, appState.tempImageFilesB.length - 1);
        } else {
          model.currentImageIndexB = 0;
        }
      } else {
        // B박스에 이미지가 없을 때 X 클릭 시 B박스 숨기기
        setState(() {
          model.absellected = true;
        });
      }
    } else {
      // B박스에 이미지가 없을 때 X 클릭 시 B박스 숨기기
      setState(() {
        model.absellected = true;
      });
    }
  }
}