import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core_exports.dart';
import '/features/creation/presentation/providers/creation_providers.dart';
import '/features/creation/presentation/constants/target_audience_ui_constants.dart';
import 'target_audience_steps/collection_type_selector.dart';
import 'target_audience_steps/target_count_selector.dart';
import 'target_audience_steps/detailed_target_selector.dart';

/// 타겟 오디언스 설정 다이얼로그 - Riverpod 3.x (Phase 2-7)
///
/// **Migration**: ChangeNotifierProvider → Riverpod ConsumerStatefulWidget
/// **Provider**: targetAudienceProvider (Notifier)
class TargetAudienceDialog extends ConsumerStatefulWidget {
  const TargetAudienceDialog({super.key});

  @override
  ConsumerState<TargetAudienceDialog> createState() =>
      _TargetAudienceDialogState();

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

class _TargetAudienceDialogState extends ConsumerState<TargetAudienceDialog>
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

    // Riverpod: Reset state when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(targetAudienceProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    final state = ref.read(targetAudienceProvider);
    final notifier = ref.read(targetAudienceProvider.notifier);

    debugPrint('[TargetAudienceDialog] 다음 단계로 이동 요청');
    debugPrint('[TargetAudienceDialog]   - 현재 단계: ${state.currentStep}');
    debugPrint('[TargetAudienceDialog]   - 수집 방식: ${state.collectionType}');

    if (state.currentStep < 2) {
      // Custom이 아니고 Step 2에서는 완료
      if (state.collectionType != 'custom' && state.currentStep == 1) {
        debugPrint('[TargetAudienceDialog] Custom이 아니므로 설정 완료');
        _completeSetup();
        return;
      }

      notifier.nextStep();
      debugPrint('[TargetAudienceDialog] 단계 ${state.currentStep + 1}로 이동');
      _pageController.animateToPage(
        state.currentStep + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      debugPrint('[TargetAudienceDialog] 마지막 단계 완료');
      _completeSetup();
    }
  }

  void _goToPreviousStep() {
    final state = ref.read(targetAudienceProvider);
    final notifier = ref.read(targetAudienceProvider.notifier);

    if (state.currentStep > 0) {
      notifier.previousStep();
      _pageController.animateToPage(
        state.currentStep - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeSetup() {
    final notifier = ref.read(targetAudienceProvider.notifier);
    final result = notifier.toFirestoreMap();

    debugPrint('[TargetAudienceDialog] ========== 설정 완료 ==========');
    debugPrint('[TargetAudienceDialog] 최종 결과:');
    debugPrint('[TargetAudienceDialog]   - 수집 방식: ${result['type']}');
    debugPrint('[TargetAudienceDialog]   - 목표 수: ${result['targetCount']}');
    debugPrint(
      '[TargetAudienceDialog]   - 관심사: ${result['criteria']?['interests']}',
    );
    debugPrint(
      '[TargetAudienceDialog]   - 연령대: ${result['criteria']?['ageGroup']}',
    );
    debugPrint(
      '[TargetAudienceDialog]   - 성별: ${result['criteria']?['gender']}',
    );
    debugPrint('[TargetAudienceDialog] =====================================');
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(targetAudienceProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 24.0,
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: TargetAudienceUIConstants.dialogWidth,
          constraints: BoxConstraints(
            maxHeight: TargetAudienceUIConstants.dialogMaxHeight,
            maxWidth: TargetAudienceUIConstants.dialogWidth,
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
              _buildStepIndicator(state),

              // 컨텐츠 영역
              Flexible(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  // onPageChanged 제거 - 버튼에서 이미 상태를 관리하고 있음
                  // Riverpod 빌드 중 상태 변경 에러 방지
                  children: const [
                    CollectionTypeSelector(),
                    TargetCountSelector(),
                    DetailedTargetSelector(),
                  ],
                ),
              ),

              // 하단 버튼 영역
              _buildBottomButtons(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(state) {
    final totalSteps = state.collectionType == 'custom' ? 3 : 2;

    return Container(
      height: TargetAudienceUIConstants.stepIndicatorHeight,
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
          final isActive = index <= state.currentStep;
          final isCompleted = index < state.currentStep;

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
                        : AppTheme.of(
                            context,
                          ).secondaryText.withValues(alpha: 0.3),
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
                          : AppTheme.of(
                              context,
                            ).secondaryText.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomButtons(state) {
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
          if (state.currentStep > 0)
            TextButton(
              onPressed: _goToPreviousStep,
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
            onPressed: state.canGoNext ? _goToNextStep : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.of(context).primary,
              foregroundColor: AppTheme.of(context).primaryBackground,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              state.isFinalStep ? '설정 완료' : '다음',
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
