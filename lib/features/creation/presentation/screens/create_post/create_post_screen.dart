import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import '../../providers/create_post_provider_v2.dart';
import '../../providers/media/media_selection_provider.dart';
import '../../providers/media/media_validation_provider.dart';
import '../../widgets/create_post/image_selection_widget.dart';
import '../../widgets/create_post/text_input_widget.dart';
import '/features/creation/presentation/widgets/components/next_button.dart';
import '/core/utils/error_handler.dart';
import 'package:bot_toast/bot_toast.dart';
import '../../widgets/dialogs/target_audience_dialog.dart';
import '/features/creation/domain/failures/creation_failures.dart';

/// Main screen for post creation
///
/// This screen orchestrates all post creation components using Clean Architecture.
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  static String routeName = 'CreatePostScreen';
  static String routePath = '/createPost';

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
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
    final provider = context.read<CreatePostProviderV2>();

    setState(() {
      _isValidating = true;
    });

    try {
      // Provider의 UseCase를 통한 유효성 검사
      final isValid = await provider.validateFormFields();

      if (!isValid) {
        _triggerShakeAnimation();
        BotToast.showText(
          text: provider.errorMessage ?? '모든 필수 항목을 입력해주세요',
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

      // CreatePostProviderV2를 통해 포스트 생성 (타겟 오디언스 포함)
      // TODO: 현재 userId는 하드코딩되어 있음 - 추후 실제 사용자 정보 연동 필요
      await provider.createPost(
        'test_user',
        targetAudience: targetAudienceData,
      );

      // 성공 - 페이지 닫기
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // 에러 타입별로 다른 메시지 표시
      String errorMessage = '포스트 생성 중 오류가 발생했습니다'; // 기본값

      if (e is FirestoreWriteFailure) {
        errorMessage = e.getUserMessage();
        // '데이터베이스 접근 권한이 없습니다. 다시 로그인해주세요.'
        // '서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요.'
        // '요청한 게시물을 찾을 수 없습니다.'
      } else if (e is AIModerationFailure) {
        errorMessage = e.getUserMessage();
        // 'AI 검열에서 다음 문제가 감지되었습니다: 선정적 콘텐츠, 폭력적 내용'
      } else if (e is MediaProcessingFailure) {
        errorMessage = e.getUserMessage();
        // '이미지 압축 중 오류가 발생했습니다. 다른 이미지를 선택해주세요.'
        // '이미지 업로드에 실패했습니다. 인터넷 연결을 확인해주세요.'
      } else if (e is NetworkFailure) {
        errorMessage = '인터넷 연결을 확인하고 다시 시도해주세요';
      } else if (e is PostValidationFailure) {
        errorMessage = e.getUserMessage();
        // '필수 항목을 입력해주세요: 제목, 설명'
      } else if (e is PostCreationRepositoryFailure) {
        errorMessage = '게시물 저장에 실패했습니다. 잠시 후 다시 시도해주세요.';
      } else if (e is ServerFailure) {
        errorMessage = '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      }

      // 기존 BotToast 패턴 그대로 사용 ✅
      ErrorHandler.handle(e, type: ErrorType.unknown);
      BotToast.showText(
        text: errorMessage, // 구체적 메시지로 교체
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
    return MultiProvider(
      providers: [
        // Phase 5: MediaStateCoordinator 통합된 Provider
        ChangeNotifierProvider(
          create: (_) => GetIt.instance<CreatePostProviderV2>(),
        ),
        // Phase 5: MediaSelectionProvider (UI 상태 관리용)
        ChangeNotifierProvider(
          create: (_) => GetIt.instance<MediaSelectionProvider>(),
        ),
        // Phase 5: MediaValidationProvider (검증 상태 관리용)
        ChangeNotifierProvider(
          create: (_) => GetIt.instance<MediaValidationProvider>(),
        ),
      ],
      child: Scaffold(
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
              final provider = context.read<CreatePostProviderV2>();
              provider.resetForm();
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
                          child: Consumer<CreatePostProviderV2>(
                            builder: (context, provider, child) {
                              return NextButton(
                                showButton: provider.canSubmit,
                                onPressed: provider.canSubmit && !_isValidating
                                    ? _handleSubmit
                                    : null,
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
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