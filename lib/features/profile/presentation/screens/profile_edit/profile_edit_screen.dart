import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '/core_exports.dart';
import '/features/profile/domain/entities/user_profile.dart';
import '/features/profile/presentation/providers/profile_notifiers.dart';
import '/features/profile/presentation/widgets/common/loading_indicator.dart';
import '/features/profile/presentation/widgets/common/error_message.dart';
import '/features/profile/presentation/constants/validation_rules.dart';
import '/features/profile/presentation/constants/profile_constants.dart';
import '/core/constants/app_constants.dart';

/// 프로필 편집 화면 (Phase 3: Riverpod 마이그레이션 완료)
///
/// **Clean Architecture v4.0 + Riverpod 3.x**:
/// - ConsumerStatefulWidget으로 로컬 상태 관리 (Form)
/// - ProfileNotifier로 업데이트 실행
/// - StreamProvider로 실시간 동기화
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  static String routeName = 'profile_edit';
  static String routePath = '/profile/edit';

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _displayNameController;
  late TextEditingController _shortDescriptionController;

  // 로컬 상태: 성별 선택
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _shortDescriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _shortDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Riverpod: StreamProvider로 실시간 프로필 동기화
    final profileAsync = ref.watch(
      profileStreamProvider(widget.userId),
    );

    // 로딩 상태 체크 (Riverpod 3.x ProfileUIProvider)
    final isLoading = ref.watch(profileUIProvider.select((state) => state.isLoading));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).getText('profile_edit' /* 프로필 편집 */),
          style: AppTheme.of(context).headlineSmall,
        ),
        actions: [
          profileAsync.when(
            loading: () => SizedBox(),
            error: (_, __) => SizedBox(),
            data: (profile) => TextButton(
              onPressed: isLoading || profile == null
                  ? null
                  : () => _saveProfile(profile),
              child: Text(
                AppLocalizations.of(context).getText('save' /* 저장 */),
                style: AppTheme.of(context).bodyMedium.override(
                  color: AppTheme.of(context).primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => ProfileLoadingIndicator(
          size: LoadingSize.medium,
        ),
        error: (error, stackTrace) => ProfileErrorMessage(
          message: error.toString(),
          onRetry: () {
            // Riverpod: Stream 재시작
            ref.invalidate(profileStreamProvider);
          },
        ),
        data: (profile) {
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
          // 성별 초기값 설정
          _selectedGender ??= profile.gender;

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
                            radius: AppConstants.profileAvatarRadius,
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                              onPressed: () => _pickAndUploadImage(profile),
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
                        selected: _selectedGender == 'Male',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedGender = 'Male';
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: Text('여성'),
                        selected: _selectedGender == 'Female',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedGender = 'Female';
                            });
                          }
                        },
                      ),
                      ChoiceChip(
                        label: Text('기타'),
                        selected: _selectedGender == 'Other',
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedGender = 'Other';
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 32),

                  // 로딩 인디케이터
                  if (isLoading)
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

  Future<void> _saveProfile(UserProfile currentProfile) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 업데이트된 프로필 생성
    final updatedProfile = currentProfile.copyWith(
      displayName: _displayNameController.text.trim(),
      shortDescription: _shortDescriptionController.text.trim(),
      gender: _selectedGender,
    );

    // Riverpod 3.x ProfileNotifier로 업데이트 실행
    try {
      await ref.read(profileProvider.notifier).updateProfile(
        profile: updatedProfile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필이 저장되었습니다'),
            backgroundColor: AppTheme.of(context).success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필 저장 실패: $e'),
            backgroundColor: AppTheme.of(context).error,
          ),
        );
      }
    }
  }

  /// 이미지 선택 및 업로드
  ///
  /// **Riverpod 3.x**: ProfileNotifier를 통한 이미지 선택 및 업로드
  Future<void> _pickAndUploadImage(UserProfile currentProfile) async {
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

    // 3. 파일 변환
    final File imageFile = File(image.path);

    // 4. Riverpod 3.x ProfileNotifier로 업로드
    try {
      await ref.read(profileProvider.notifier).uploadProfileImage(
        userId: widget.userId,
        imageFile: imageFile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필 사진이 업데이트되었습니다'),
            backgroundColor: AppTheme.of(context).success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필 사진 업로드 실패: $e'),
            backgroundColor: AppTheme.of(context).error,
          ),
        );
      }
    }
  }
}
