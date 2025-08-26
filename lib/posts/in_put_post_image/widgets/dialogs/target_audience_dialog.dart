import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core_exports.dart';
import '../../models/target_audience_model.dart';
import '../../constants/target_audience_constants.dart';
import 'target_audience_steps/collection_type_selector.dart';
import 'target_audience_steps/target_count_selector.dart';
import 'target_audience_steps/detailed_target_selector.dart';

/// 타겟 오디언스 설정 다이얼로그
class TargetAudienceDialog extends StatefulWidget {
  const TargetAudienceDialog({super.key});

  @override
  State<TargetAudienceDialog> createState() => _TargetAudienceDialogState();

  /// 다이얼로그 표시 헬퍼 메서드
  static Future<Map<String, dynamic>?> show(BuildContext context) async {
    debugPrint('[TargetAudienceDialog] 다이얼로그 표시 요청');
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const TargetAudienceDialog(),
    );
    debugPrint('[TargetAudienceDialog] 다이얼로그 닫힘, 결과: $result');
    return result;
  }
}

class _TargetAudienceDialogState extends State<TargetAudienceDialog> 
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    debugPrint('[TargetAudienceDialog] initState() - 다이얼로그 초기화');
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _goToNextStep(TargetAudienceModel model) {
    debugPrint('[TargetAudienceDialog] 다음 단계로 이동 요청');
    debugPrint('[TargetAudienceDialog]   - 현재 단계: ${model.currentStep}');
    debugPrint('[TargetAudienceDialog]   - 수집 방식: ${model.collectionType}');
    
    if (model.currentStep < 2) {
      // Custom이 아니고 Step 2에서는 완료
      if (model.collectionType != 'custom' && model.currentStep == 1) {
        debugPrint('[TargetAudienceDialog] Custom이 아니므로 설정 완료');
        _completeSetup(model);
        return;
      }
      
      model.currentStep = model.currentStep + 1;
      debugPrint('[TargetAudienceDialog] 단계 ${model.currentStep}로 이동');
      _pageController.animateToPage(
        model.currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      debugPrint('[TargetAudienceDialog] 마지막 단계 완료');
      _completeSetup(model);
    }
  }

  void _goToPreviousStep(TargetAudienceModel model) {
    if (model.currentStep > 0) {
      model.currentStep = model.currentStep - 1;
      _pageController.animateToPage(
        model.currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeSetup(TargetAudienceModel model) {
    final result = model.toMap();
    
    debugPrint('[TargetAudienceDialog] ========== 설정 완료 ==========');
    debugPrint('[TargetAudienceDialog] 최종 결과:');
    debugPrint('[TargetAudienceDialog]   - 수집 방식: ${result['type']}');
    debugPrint('[TargetAudienceDialog]   - 목표 수: ${result['targetCount']}');
    debugPrint('[TargetAudienceDialog]   - 관심사: ${result['interests']}');
    debugPrint('[TargetAudienceDialog]   - 연령대: ${result['ageGroup']}');
    debugPrint('[TargetAudienceDialog]   - 성별: ${result['gender']}');
    debugPrint('[TargetAudienceDialog] =====================================');
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TargetAudienceModel(),
      child: Consumer<TargetAudienceModel>(
        builder: (context, model, child) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: TargetAudienceConstants.dialogWidth,
                constraints: BoxConstraints(
                  maxHeight: TargetAudienceConstants.dialogMaxHeight,
                  maxWidth: TargetAudienceConstants.dialogWidth,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 상단 스텝 인디케이터
                    _buildStepIndicator(model),
                    
                    // 컨텐츠 영역
                    Flexible(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (index) {
                          model.currentStep = index;
                        },
                        children: [
                          CollectionTypeSelector(
                            onTypeSelected: (type) {
                              model.collectionType = type;
                            },
                          ),
                          TargetCountSelector(
                            onCountChanged: (count) {
                              model.targetCount = count;
                            },
                            onPremiumChanged: (isPremium) {
                              model.isPremium = isPremium;
                            },
                          ),
                          const DetailedTargetSelector(),
                        ],
                      ),
                    ),
                    
                    // 하단 버튼 영역
                    _buildBottomButtons(model),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator(TargetAudienceModel model) {
    final totalSteps = model.collectionType == 'custom' ? 3 : 2;
    
    return Container(
      height: TargetAudienceConstants.stepIndicatorHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isActive = index <= model.currentStep;
          final isCompleted = index < model.currentStep;
          
          return Expanded(
            child: Row(
              children: [
                // 스텝 원
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isActive 
                        ? AppTheme.of(context).primary 
                        : AppTheme.of(context).secondaryText.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            Icons.check,
                            size: 16,
                            color: AppTheme.of(context).primaryBackground,
                          )
                        : Text(
                            '${index + 1}',
                            style: AppTheme.of(context).bodySmall.override(
                              color: isActive 
                                  ? AppTheme.of(context).primaryBackground
                                  : AppTheme.of(context).secondaryText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                // 연결선
                if (index < totalSteps - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: isCompleted
                          ? AppTheme.of(context).primary
                          : AppTheme.of(context).secondaryText.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomButtons(TargetAudienceModel model) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // 이전 버튼
          if (model.currentStep > 0)
            TextButton(
              onPressed: () => _goToPreviousStep(model),
              child: Text(
                '이전',
                style: AppTheme.of(context).bodyMedium.override(
                  color: AppTheme.of(context).secondaryText,
                ),
              ),
            )
          else
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                '취소',
                style: AppTheme.of(context).bodyMedium.override(
                  color: AppTheme.of(context).secondaryText,
                ),
              ),
            ),
          
          const Spacer(),
          
          // 다음/완료 버튼
          ElevatedButton(
            onPressed: model.canGoNext 
                ? () => _goToNextStep(model)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.of(context).primary,
              foregroundColor: AppTheme.of(context).primaryBackground,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              model.isFinalStep ? '설정 완료' : '다음',
              style: AppTheme.of(context).bodyMedium.override(
                color: AppTheme.of(context).primaryBackground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}