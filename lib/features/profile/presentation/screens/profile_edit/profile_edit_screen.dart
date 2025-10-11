import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core_exports.dart';
import '/features/profile/presentation/providers/profile_edit_provider.dart';

/// 프로필 편집 화면
///
/// **Clean Architecture v4.0 준수**:
/// - Provider 패턴으로 상태 관리
/// - UseCase 통해 비즈니스 로직 처리
/// - UI와 비즈니스 로직 완전 분리
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  static String routeName = 'profile_edit';
  static String routePath = '/profile/edit';

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
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
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.of(context).primary,
                ),
              ),
            );
          }

          // 에러 상태
          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.of(context).error,
                  ),
                  SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: AppTheme.of(context).bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadProfile(widget.userId),
                    child: Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          // 프로필 로드 완료
          final profile = provider.profile;
          if (profile == null) {
            return Center(child: Text('프로필을 찾을 수 없습니다'));
          }

          // 초기값 설정 (한 번만)
          if (_displayNameController.text.isEmpty && profile.displayName.isNotEmpty) {
            _displayNameController.text = profile.displayName;
          }
          if (_shortDescriptionController.text.isEmpty && profile.shortDescription.isNotEmpty) {
            _shortDescriptionController.text = profile.shortDescription;
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
                          backgroundImage: profile.photoUrl.isNotEmpty
                              ? NetworkImage(profile.photoUrl)
                              : null,
                          child: profile.photoUrl.isEmpty
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
                              onPressed: () {
                                // TODO: 이미지 업로드 기능 구현
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('이미지 업로드 기능은 추후 구현 예정'),
                                  ),
                                );
                              },
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '표시 이름을 입력해주세요';
                      }
                      if (value.length > 20) {
                        return '20자 이내로 입력해주세요';
                      }
                      return null;
                    },
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
                    maxLength: 100,
                    validator: (value) {
                      if (value != null && value.length > 100) {
                        return '100자 이내로 입력해주세요';
                      }
                      return null;
                    },
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
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.of(context).primary,
                        ),
                      ),
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
}
