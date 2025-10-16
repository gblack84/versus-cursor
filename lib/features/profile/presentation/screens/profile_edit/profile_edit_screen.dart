import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '/core_exports.dart';
import '/features/profile/presentation/providers/profile_edit_provider.dart';
import '/app/di.dart';
import '/features/profile/domain/usecases/profile/update_user_profile_usecase.dart';
import '/features/profile/domain/usecases/profile/get_user_profile_usecase.dart';
import '/features/profile/domain/usecases/profile/upload_profile_image_usecase.dart';
import '/features/profile/presentation/widgets/common/loading_indicator.dart';
import '/features/profile/presentation/widgets/common/error_message.dart';
import '/features/profile/presentation/constants/validation_rules.dart';
import '/features/profile/presentation/constants/profile_constants.dart';

/// 프로필 편집 화면 Wrapper
///
/// **Clean Architecture v4.0 준수**:
/// - Provider 패턴으로 상태 관리
/// - UseCase 통해 비즈니스 로직 처리
/// - UI와 비즈니스 로직 완전 분리
/// - GetIt을 통한 의존성 주입
class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  static String routeName = 'profile_edit';
  static String routePath = '/profile/edit';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileEditProvider(
        updateProfileUseCase: getIt<UpdateUserProfileUseCase>(),
        getUserProfileUseCase: getIt<GetUserProfileUseCase>(),
        uploadImageUseCase: getIt<UploadProfileImageUseCase>(),
      ),
      child: _ProfileEditScreenContent(userId: userId),
    );
  }
}

/// 프로필 편집 화면 내용
class _ProfileEditScreenContent extends StatefulWidget {
  const _ProfileEditScreenContent({
    required this.userId,
  });

  final String userId;

  @override
  State<_ProfileEditScreenContent> createState() => _ProfileEditScreenContentState();
}

class _ProfileEditScreenContentState extends State<_ProfileEditScreenContent> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _displayNameController;
  late TextEditingController _shortDescriptionController;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _shortDescriptionController = TextEditingController();

    // Provider에서 프로필 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfileEditProvider>();
      provider.loadProfile(widget.userId);
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _shortDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).getText('profile_edit' /* 프로필 편집 */),
          style: AppTheme.of(context).headlineSmall,
        ),
        actions: [
          Consumer<ProfileEditProvider>(
            builder: (context, provider, _) {
              return TextButton(
                onPressed: provider.isLoading ? null : () => _saveProfile(provider),
                child: Text(
                  AppLocalizations.of(context).getText('save' /* 저장 */),
                  style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProfileEditProvider>(
        builder: (context, provider, _) {
          // 로딩 상태
          if (provider.isLoading && provider.profile == null) {
            return ProfileLoadingIndicator(
              size: LoadingSize.medium,
            );
          }

          // 에러 상태
          if (provider.errorMessage != null) {
            return ProfileErrorMessage(
              message: provider.errorMessage!,
              onRetry: () => provider.loadProfile(widget.userId),
            );
          }

          // 프로필 로드 완료
          final profile = provider.profile;
          if (profile == null) {
            return Center(child: Text('프로필을 찾을 수 없습니다'));
          }

          // 초기값 설정 (한 번만)
          if (_displayNameController.text.isEmpty && profile.displayName?.isNotEmpty == true) {
            _displayNameController.text = profile.displayName ?? '';
          }
          if (_shortDescriptionController.text.isEmpty && profile.shortDescription?.isNotEmpty == true) {
            _shortDescriptionController.text = profile.shortDescription ?? '';
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 프로필 이미지
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppTheme.of(context).primaryBackground,
                          backgroundImage: profile.photoUrl?.isNotEmpty == true
                              ? NetworkImage(profile.photoUrl!)
                              : null,
                          child: profile.photoUrl?.isEmpty ?? true
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppTheme.of(context).secondaryText,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: AppTheme.of(context).primary,
                            radius: 20,
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                              onPressed: () => _pickAndUploadImage(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),

                  // 표시 이름
                  Text(
                    AppLocalizations.of(context).getText('display_name' /* 표시 이름 */),
                    style: AppTheme.of(context).bodyMedium.override(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _displayNameController,
                    decoration: InputDecoration(
                      hintText: '이름을 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppTheme.of(context).secondaryBackground,
                    ),
                    maxLength: ProfileConstants.maxDisplayNameLength,
                    validator: ValidationRules.validateDisplayName,
                  ),
                  SizedBox(height: 24),

                  // 한 줄 소개
                  Text(
                    AppLocalizations.of(context).getText('short_description' /* 한 줄 소개 */),
                    style: AppTheme.of(context).bodyMedium.override(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _shortDescriptionController,
                    decoration: InputDecoration(
                      hintText: '자신을 소개해보세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppTheme.of(context).secondaryBackground,
                    ),
                    maxLines: 3,
                    maxLength: ProfileConstants.maxShortDescriptionLength,
                    validator: ValidationRules.validateShortDescription,
                  ),
                  SizedBox(height: 24),

                  // 성별
                  Text(
                    AppLocalizations.of(context).getText('gender' /* 성별 */),
                    style: AppTheme.of(context).bodyMedium.override(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: [
                      ChoiceChip(
                        label: Text('남성'),
                        selected: profile.gender == 'Male',
                        onSelected: (selected) {
                          if (selected) {
                            provider.updateGender('Male');
                          }
                        },
                      ),
                      ChoiceChip(
                        label: Text('여성'),
                        selected: profile.gender == 'Female',
                        onSelected: (selected) {
                          if (selected) {
                            provider.updateGender('Female');
                          }
                        },
                      ),
                      ChoiceChip(
                        label: Text('기타'),
                        selected: profile.gender == 'Other',
                        onSelected: (selected) {
                          if (selected) {
                            provider.updateGender('Other');
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 32),

                  // 로딩 인디케이터
                  if (provider.isLoading)
                    ProfileLoadingIndicator(
                      size: LoadingSize.small,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveProfile(ProfileEditProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await provider.saveProfile(
      displayName: _displayNameController.text.trim(),
      shortDescription: _shortDescriptionController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('프로필이 저장되었습니다'),
          backgroundColor: AppTheme.of(context).success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted && provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: AppTheme.of(context).error,
        ),
      );
    }
  }

  /// 이미지 선택 및 업로드
  ///
  /// **Phase 3.1 구현**: ImagePicker를 통한 이미지 선택 및 업로드
  Future<void> _pickAndUploadImage(BuildContext context) async {
    final provider = context.read<ProfileEditProvider>();

    // 1. 이미지 소스 선택 다이얼로그
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('프로필 사진 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('카메라로 촬영'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('갤러리에서 선택'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    // 2. 이미지 선택
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image == null) return;

    // 3. 파일 변환 및 업로드
    final File imageFile = File(image.path);

    // 4. Provider를 통해 업로드
    final success = await provider.uploadProfileImage(imageFile);

    // 5. 결과 메시지 표시
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필 사진이 업데이트되었습니다'),
            backgroundColor: AppTheme.of(context).success,
          ),
        );
      } else if (provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: AppTheme.of(context).error,
          ),
        );
      }
    }
  }
}
