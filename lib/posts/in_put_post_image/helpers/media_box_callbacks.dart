import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/app_state.dart';
import '/services/storage_service.dart';
import '../in_put_post_image_model.dart';
import '../utils/debug_helper.dart';

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
      // Storage에서 삭제할 이미지 URL 캡처
      final imageUrl = appState.uploadImageA[index];
      print('삭제 전 이미지 URL: $imageUrl');
      
      // AppState에서 제거
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
      
      // Firebase Storage에서 비동기로 삭제 (UI 블로킹 없이)
      _deleteFromStorage(imageUrl, 'A');
    } else {
      print('삭제 실패 - 인덱스가 범위를 벗어남');
    }
  }

  void _deleteFromB(int index) {
    if (index < appState.uploadImageB.length) {
      // Storage에서 삭제할 이미지 URL 캡처
      final imageUrl = appState.uploadImageB[index];
      
      // AppState에서 제거
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
      
      // Firebase Storage에서 비동기로 삭제 (UI 블로킹 없이)
      _deleteFromStorage(imageUrl, 'B');
    } else {
      // B박스에 이미지가 없을 때 X 클릭 시 B박스 숨기기
      setState(() {
        model.absellected = true;
      });
    }
  }
  
  /// Firebase Storage에서 이미지 삭제 (백그라운드에서 처리)
  Future<void> _deleteFromStorage(String imageUrl, String box) async {
    try {
      DebugHelper.log('[MediaBoxCallbacks] $box 박스 이미지 Storage 삭제 시작: $imageUrl');
      
      // Storage에서 삭제
      final success = await StorageService.deleteImageFromUrl(imageUrl);
      
      if (success) {
        DebugHelper.log('[MediaBoxCallbacks] $box 박스 이미지 Storage 삭제 성공');
        
        // 편집 모드일 때만 Firestore 업데이트
        if (model.isEditMode && model.existingPostRef != null) {
          await _updateFirestoreImageUrls(imageUrl, box);
        }
      } else {
        DebugHelper.log('[MediaBoxCallbacks] $box 박스 이미지 Storage 삭제 실패');
      }
    } catch (e) {
      DebugHelper.logError('$box 박스 이미지 Storage 삭제 중 오류', e);
    }
  }
  
  /// Firestore에서 이미지 URL 제거
  Future<void> _updateFirestoreImageUrls(String deletedUrl, String box) async {
    try {
      final postRef = model.existingPostRef!;
      
      // 현재 AppState의 이미지 URL 목록 가져오기
      final updatedUrls = box == 'A' 
          ? List<String>.from(appState.uploadImageA)
          : List<String>.from(appState.uploadImageB);
      
      // 필드 이름 결정
      final optionField = box == 'A' ? 'optionA' : 'optionB';
      final pollOptionField = box == 'A' ? 'option_1_media_urls' : 'option_2_media_urls';
      
      // 트랜잭션으로 원자성 보장
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // posts_record 업데이트
        transaction.update(postRef, {
          '$optionField.mediaUrls': updatedUrls,
        });
        
        // poll_details 서브컬렉션 업데이트
        final pollDetailsQuery = await postRef
            .collection('poll_details')
            .limit(1)
            .get();
            
        if (pollDetailsQuery.docs.isNotEmpty) {
          final pollDetailsRef = pollDetailsQuery.docs.first.reference;
          transaction.update(pollDetailsRef, {
            pollOptionField: updatedUrls,
            // 첫 번째 이미지 URL도 업데이트 (단일 URL 필드)
            '${pollOptionField.replaceAll('_urls', '_url')}': updatedUrls.isNotEmpty ? updatedUrls.first : '',
          });
        }
      });
      
      DebugHelper.log('[MediaBoxCallbacks] Firestore 업데이트 성공 - $box 박스');
    } catch (e) {
      DebugHelper.logError('Firestore 업데이트 중 오류', e);
      // 에러가 발생해도 사용자 경험은 방해하지 않음
    }
  }
}