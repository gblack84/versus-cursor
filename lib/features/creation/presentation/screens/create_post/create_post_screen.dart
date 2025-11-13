import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/create_post_notifier.dart';
import '../../widgets/create_post/image_selection_widget.dart';
import '../../widgets/create_post/text_input_widget.dart';
import '/features/creation/presentation/widgets/components/next_button.dart';
import '/services/error/error_handler_service.dart';
import 'package:bot_toast/bot_toast.dart';
import '../../widgets/dialogs/target_audience_dialog.dart';
import '/features/creation/domain/failures/creation_failure.dart';
import '/features/creation/domain/failures/creation_failure_extensions.dart'; // Extension for getUserMessage()
import '/features/auth/presentation/providers/auth_providers.dart';

/// Main screen for post creation
///
/// This screen orchestrates all post creation components using Clean Architecture.
/// Migrated to Riverpod 3.x (Phase 2-6)
class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  static String routeName = 'CreatePostScreen';
  static String routePath = '/createPost';

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _validationSessionId = '';
  bool _showNextButton = false;
  bool _isValidating = false;
  bool _absellected = false;

  // Animation
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _validationSessionId = '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch.toString().substring(10)}';

    // Animation setup
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _shakeAnimation = Tween(begin: 0.0, end: 8.0)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_shakeController);

    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels > 50 && !_showNextButton) {
      setState(() {
        _showNextButton = true;
      });
    }
  }

  Future<void> _handleSubmit() async {
    final notifier = ref.read(createPostProvider.notifier);

    setState(() {
      _isValidating = true;
    });

    try {
      // Provider의 UseCase를 통한 유효성 검사
      final isValid = await notifier.validateFormFields();

      if (!isValid) {
        _triggerShakeAnimation();
        final errorMessage = ref.read(createPostProvider).errorMessage;
        BotToast.showText(
          text: errorMessage ?? '모든 필수 항목을 입력해주세요',
          duration: const Duration(seconds: 3),
          contentColor: Colors.red.shade600,
          textStyle: const TextStyle(color: Colors.white),
        );
        return;
      }

      // TargetAudienceDialog 표시
      final targetAudienceData = await TargetAudienceDialog.show(context);

      // 사용자가 취소한 경우 중단
      if (targetAudienceData == null) {
        return;
      }

      // CreatePostNotifier를 통해 포스트 생성 (타겟 오디언스 포함)
      // ✅ Clean Architecture: Provider를 통한 간접 접근
      final currentUserId = await ref.read(currentUserIdProvider.future);
      if (currentUserId == null) {
        BotToast.showText(text: '로그인이 필요합니다');
        return;
      }

      await notifier.createPost(
        currentUserId,
        targetAudience: targetAudienceData,
      );

      // 성공 - AI 채팅방으로 자동 이동 (투표 카드 즉시 표시)
      if (mounted) {
        final chatId = 'ai_assistant_$currentUserId';

        // AI 채팅방으로 이동
        context.go('/chatDetail?chatId=$chatId');

        // 성공 토스트
        BotToast.showText(text: '질문이 등록되었습니다');
      }
    } catch (e) {
      // 에러 타입별로 다른 메시지 표시
      String errorMessage = '포스트 생성 중 오류가 발생했습니다'; // 기본값

      if (e is FirestoreWriteFailed) {
        errorMessage = e.getUserMessage();
      } else if (e is AIModerationFailed) {
        errorMessage = e.getUserMessage();
      } else if (e is MediaProcessingFailed) {
        errorMessage = e.getUserMessage();
      } else if (e is PostValidationFailed) {
        errorMessage = e.getUserMessage();
      } else if (e is PostCreationRepositoryFailed) {
        errorMessage = '게시물 저장에 실패했습니다. 잠시 후 다시 시도해주세요.';
      }

      ErrorHandler.handle(e, type: ErrorType.unknown);
      BotToast.showText(
        text: errorMessage,
        duration: const Duration(seconds: 3),
        contentColor: Colors.red.shade600,
        textStyle: const TextStyle(color: Colors.white),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isValidating = false;
        });
      }
    }
  }

  void _triggerShakeAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the create post state
    final createPostState = ref.watch(createPostProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            size: 30,
          ),
          onPressed: () async {
            // 데이터 정리
            ref.read(createPostProvider.notifier).resetForm();
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          '질문 작성',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // 텍스트 입력 섹션
                    TextInputWidget(
                      showOptionB: !_absellected,
                      validationSessionId: _validationSessionId,
                      onTitleChanged: (text) {
                        setState(() {
                          // 버튼 표시 업데이트
                        });
                      },
                      onDescriptionChanged: (text) {
                        setState(() {
                          // 버튼 표시 업데이트
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // 이미지 선택 섹션
                    ImageSelectionWidget(
                      absellected: _absellected,
                      isDynamic: true,
                      validationSessionId: _validationSessionId,
                      onImagesSelected: (images, box) {
                        setState(() {
                          // 이미지 선택 후 UI 업데이트
                        });
                      },
                    ),

                    const SizedBox(height: 24),

                    // A/B 모드 토글
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text('B 옵션 숨기기'),
                          const SizedBox(width: 8),
                          Switch(
                            value: _absellected,
                            onChanged: (value) {
                              setState(() {
                                _absellected = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 하단 버튼
            if (_showNextButton)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: NextButton(
                          showButton: createPostState.canSubmit,
                          onPressed: createPostState.canSubmit && !_isValidating
                              ? _handleSubmit
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _shakeController.dispose();
    super.dispose();
  }
}
