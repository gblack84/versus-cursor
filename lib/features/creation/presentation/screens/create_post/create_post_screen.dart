import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import '/core_exports.dart';
import '../../providers/create_post_provider_v2.dart';
import '../../adapters/create_post_adapter.dart';
import '../../../domain/usecases/create_post_usecase.dart';
import '../../../domain/usecases/moderate_content_usecase.dart';
import '../../widgets/create_post/image_selection_widget.dart';
import '../../widgets/create_post/text_input_widget.dart';
import '/features/creation/presentation/screens/create_post/in_put_post_image_model.dart';
import '/features/creation/presentation/widgets/components/next_button.dart';
import '/services/validation/validation_service.dart';
import '/core/utils/error_handler.dart';
import 'package:bot_toast/bot_toast.dart';

/// Main screen for post creation
///
/// This screen orchestrates all post creation components using Clean Architecture.
/// It bridges legacy code with new Clean Architecture implementation through the adapter pattern.
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  static String routeName = 'CreatePostScreen';
  static String routePath = '/createPost';

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with SingleTickerProviderStateMixin {
  late InPutPostImageModel _model;
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
    _model = InPutPostImageModel();
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
    final appState = context.read<AppState>();
    final cleanProvider = context.read<CreatePostProviderV2>();
    final adapter = CreatePostAdapter(
      cleanProvider: cleanProvider,
      legacyState: appState,
    );

    // 유효성 검사
    if (!_areRequiredFieldsFilled(appState)) {
      _triggerShakeAnimation();
      BotToast.showText(
        text: '모든 필수 항목을 입력해주세요',
        duration: const Duration(seconds: 3),
        contentColor: Colors.red.shade600,
        textStyle: const TextStyle(color: Colors.white),
      );
      return;
    }

    setState(() {
      _isValidating = true;
    });

    try {
      // 이미지가 있으면 업로드
      if (appState.tempImageFilesA.isNotEmpty || appState.tempImageFilesB.isNotEmpty) {
        // 검열 및 업로드는 Provider에서 처리
        await cleanProvider.validateAndModerate();

        if (cleanProvider.errorMessage != null) {
          BotToast.showText(
            text: cleanProvider.errorMessage!,
            duration: const Duration(seconds: 3),
            contentColor: Colors.red.shade600,
            textStyle: const TextStyle(color: Colors.white),
          );
          return;
        }
      }

      // 포스트 생성
      await cleanProvider.createPost();

      if (cleanProvider.createdPost != null) {
        // 성공 - 페이지 닫기
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else if (cleanProvider.errorMessage != null) {
        BotToast.showText(
          text: cleanProvider.errorMessage!,
          duration: const Duration(seconds: 3),
          contentColor: Colors.red.shade600,
          textStyle: const TextStyle(color: Colors.white),
        );
      }
    } catch (e) {
      ErrorHandler.logError('CreatePostScreen._handleSubmit', e);
      BotToast.showText(
        text: '포스트 생성 중 오류가 발생했습니다',
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

  bool _areRequiredFieldsFilled(AppState appState) {
    // 제목과 설명은 필수
    if (appState.questionTitle.isEmpty || appState.questionDescription.isEmpty) {
      return false;
    }

    // A박스에 컨텐츠가 있어야 함 (이미지 또는 텍스트)
    final hasContentA = appState.tempImageFilesA.isNotEmpty ||
                        appState.uploadImageA.isNotEmpty ||
                        appState.uploadTextA.isNotEmpty;

    if (!hasContentA) {
      return false;
    }

    // B박스는 absellected가 false일 때만 체크
    if (!_absellected) {
      final hasContentB = appState.tempImageFilesB.isNotEmpty ||
                          appState.uploadImageB.isNotEmpty ||
                          appState.uploadTextB.isNotEmpty;

      if (!hasContentB) {
        return false;
      }
    }

    return true;
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
        ChangeNotifierProvider(
          create: (_) => CreatePostProviderV2(
            createPostUseCase: GetIt.I<CreatePostUseCase>(),
            moderateContentUseCase: GetIt.I<ModerateContentUseCase>(),
          ),
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
              final appState = context.read<AppState>();
              final cleanProvider = context.read<CreatePostProviderV2>();
              final adapter = CreatePostAdapter(
                cleanProvider: cleanProvider,
                legacyState: appState,
              );

              adapter.clearAll();
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
                          child: Consumer<AppState>(
                            builder: (context, appState, child) {
                              final isValid = _areRequiredFieldsFilled(appState);

                              return NextButton(
                                onPressed: isValid && !_isValidating
                                    ? _handleSubmit
                                    : null,
                                text: _isValidating ? '처리 중...' : '게시하기',
                                isEnabled: isValid && !_isValidating,
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