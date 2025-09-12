import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 투표 UI 상태를 관리하는 Provider
/// 
/// 주요 책임:
/// - 다이얼로그 표시 상태 관리
/// - 애니메이션 상태 관리
/// - UI 레이아웃 모드 관리
/// - 사용자 인터랙션 상태 추적
class VotingUIProvider extends ChangeNotifier {
  // Dialog 관련 상태
  bool _isDialogVisible = false;
  bool _isFullScreenMode = false;
  
  // Animation 관련 상태
  bool _isAnimating = false;
  double _animationProgress = 0.0;
  
  // Layout 관련 상태
  bool _isHorizontalLayout = false;
  bool _isCompactMode = false;
  
  // Interaction 관련 상태
  String? _hoveredOption;
  String? _selectedOption;
  bool _isInteractionEnabled = true;
  
  // Image viewer 관련 상태
  int _currentImageIndex = 0;
  bool _isImageViewerOpen = false;
  
  // Error display 관련 상태
  bool _showErrorBanner = false;
  String? _errorBannerMessage;
  Duration _errorBannerDuration = const Duration(seconds: 3);

  // Getters
  bool get isDialogVisible => _isDialogVisible;
  bool get isFullScreenMode => _isFullScreenMode;
  bool get isAnimating => _isAnimating;
  double get animationProgress => _animationProgress;
  bool get isHorizontalLayout => _isHorizontalLayout;
  bool get isCompactMode => _isCompactMode;
  String? get hoveredOption => _hoveredOption;
  String? get selectedOption => _selectedOption;
  bool get isInteractionEnabled => _isInteractionEnabled;
  int get currentImageIndex => _currentImageIndex;
  bool get isImageViewerOpen => _isImageViewerOpen;
  bool get showErrorBanner => _showErrorBanner;
  String? get errorBannerMessage => _errorBannerMessage;

  /// 다이얼로그 표시/숨기기
  void toggleDialog() {
    _isDialogVisible = !_isDialogVisible;
    notifyListeners();
  }

  /// 다이얼로그 열기
  void openDialog() {
    _isDialogVisible = true;
    _resetInteractionState();
    notifyListeners();
  }

  /// 다이얼로그 닫기
  void closeDialog() {
    _isDialogVisible = false;
    _resetInteractionState();
    notifyListeners();
  }

  /// 전체화면 모드 토글
  void toggleFullScreenMode() {
    _isFullScreenMode = !_isFullScreenMode;
    notifyListeners();
  }

  /// 레이아웃 모드 설정
  void setLayoutMode({required bool horizontal}) {
    if (_isHorizontalLayout != horizontal) {
      _isHorizontalLayout = horizontal;
      notifyListeners();
    }
  }

  /// 컴팩트 모드 설정
  void setCompactMode(bool compact) {
    if (_isCompactMode != compact) {
      _isCompactMode = compact;
      notifyListeners();
    }
  }

  /// 화면 크기에 따른 자동 레이아웃 조정
  void updateLayoutBasedOnScreenSize(Size screenSize) {
    final aspectRatio = screenSize.width / screenSize.height;
    
    // 화면 비율에 따라 자동으로 레이아웃 결정
    setLayoutMode(horizontal: aspectRatio > 1.2);
    
    // 작은 화면에서는 컴팩트 모드 활성화
    setCompactMode(screenSize.width < 360 || screenSize.height < 600);
  }

  /// 옵션 호버 상태 설정
  void setHoveredOption(String? option) {
    if (_hoveredOption != option) {
      _hoveredOption = option;
      notifyListeners();
    }
  }

  /// 옵션 선택
  void selectOption(String option) {
    if (_isInteractionEnabled && _selectedOption != option) {
      _selectedOption = option;
      notifyListeners();
    }
  }

  /// 선택 초기화
  void clearSelection() {
    _selectedOption = null;
    _hoveredOption = null;
    notifyListeners();
  }

  /// 인터랙션 활성화/비활성화
  void setInteractionEnabled(bool enabled) {
    _isInteractionEnabled = enabled;
    if (!enabled) {
      _hoveredOption = null;
    }
    notifyListeners();
  }

  /// 애니메이션 시작
  void startAnimation() {
    _isAnimating = true;
    _animationProgress = 0.0;
    notifyListeners();
  }

  /// 애니메이션 진행률 업데이트
  void updateAnimationProgress(double progress) {
    _animationProgress = progress.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// 애니메이션 완료
  void completeAnimation() {
    _isAnimating = false;
    _animationProgress = 1.0;
    notifyListeners();
  }

  /// 이미지 뷰어 열기
  void openImageViewer(int initialIndex) {
    _isImageViewerOpen = true;
    _currentImageIndex = initialIndex;
    notifyListeners();
  }

  /// 이미지 뷰어 닫기
  void closeImageViewer() {
    _isImageViewerOpen = false;
    notifyListeners();
  }

  /// 이미지 인덱스 변경
  void setImageIndex(int index) {
    if (_currentImageIndex != index) {
      _currentImageIndex = index;
      notifyListeners();
    }
  }

  /// 다음 이미지로 이동
  void nextImage(int totalImages) {
    if (_currentImageIndex < totalImages - 1) {
      _currentImageIndex++;
      notifyListeners();
    }
  }

  /// 이전 이미지로 이동
  void previousImage() {
    if (_currentImageIndex > 0) {
      _currentImageIndex--;
      notifyListeners();
    }
  }

  /// 에러 배너 표시
  void showError(String message, {Duration? duration}) {
    _errorBannerMessage = message;
    _errorBannerDuration = duration ?? const Duration(seconds: 3);
    _showErrorBanner = true;
    notifyListeners();

    // 자동으로 배너 숨기기
    Future.delayed(_errorBannerDuration, () {
      hideError();
    });
  }

  /// 에러 배너 숨기기
  void hideError() {
    _showErrorBanner = false;
    _errorBannerMessage = null;
    notifyListeners();
  }

  /// 투표 완료 애니메이션 트리거
  void triggerVoteCompleteAnimation(String selectedOption) {
    _selectedOption = selectedOption;
    startAnimation();
    
    // 애니메이션 시뮬레이션
    Future.delayed(const Duration(milliseconds: 50), () {
      for (int i = 1; i <= 20; i++) {
        Future.delayed(Duration(milliseconds: i * 50), () {
          updateAnimationProgress(i / 20);
          if (i == 20) {
            completeAnimation();
          }
        });
      }
    });
  }

  /// 상호작용 상태 초기화
  void _resetInteractionState() {
    _hoveredOption = null;
    _selectedOption = null;
    _currentImageIndex = 0;
  }

  /// 모든 UI 상태 초기화
  void reset() {
    _isDialogVisible = false;
    _isFullScreenMode = false;
    _isAnimating = false;
    _animationProgress = 0.0;
    _isHorizontalLayout = false;
    _isCompactMode = false;
    _hoveredOption = null;
    _selectedOption = null;
    _isInteractionEnabled = true;
    _currentImageIndex = 0;
    _isImageViewerOpen = false;
    _showErrorBanner = false;
    _errorBannerMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    reset();
    super.dispose();
  }
}