import '/services/storage/firebase_storage_service.dart';
import '/core_exports.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'character_detail_page_model.dart';
export 'character_detail_page_model.dart';

// Phase 3: Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/features/profile/presentation/providers/profile_providers.dart';
import '/features/profile/domain/models/user_profile.dart';
// Phase 4: Contract 패턴으로 Feature 간 의존성 제거
import '/app/contracts/auth_contract.dart';
import 'package:get_it/get_it.dart';

/// 캐릭터 선택 화면 (Riverpod)
///
/// **Clean Architecture v4.0 + Riverpod**:
/// - ✅ ConsumerStatefulWidget으로 전환
/// - ✅ charactersProvider 사용
/// - ✅ ProfileActions.updateProfile() 사용
class CharacterDetailPageWidget extends ConsumerStatefulWidget {
  const CharacterDetailPageWidget({super.key});

  @override
  ConsumerState<CharacterDetailPageWidget> createState() =>
      _CharacterDetailPageWidgetState();
}

class _CharacterDetailPageWidgetState extends ConsumerState<CharacterDetailPageWidget> {
  late CharacterDetailPageModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CharacterDetailPageModel());

    // Phase 3: Riverpod - 캐릭터 목록은 charactersProvider가 자동 로드
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 1.0),
      child: Container(
        width: double.infinity,
        height: 450.0,
        decoration: BoxDecoration(
          color: Color(0xFFECECEC),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(6.0),
              child: Container(
                width: 380.0,
                height: 300.0,
                decoration: BoxDecoration(
                  color: Color(0xFFECECEC),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                  border: Border.all(
                    color: Color(0xFF989EA7),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(),
                          // Phase 3: Riverpod - charactersProvider 사용
                          child: Consumer(
                            builder: (context, ref, _) {
                              final charactersState = ref.watch(charactersProvider);

                              return charactersState.when(
                                loading: () => Center(
                                  child: SizedBox(
                                    width: 50.0,
                                    height: 50.0,
                                    child: SpinKitRing(
                                      color: Color(0xFFE7E6E6),
                                      size: 50.0,
                                    ),
                                  ),
                                ),
                                error: (error, stackTrace) => Center(
                                  child: Text(
                                    '캐릭터 목록을 불러올 수 없습니다',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                                data: (gridViewCharactersModelList) {
                                  return GridView.builder(
                                padding: EdgeInsets.fromLTRB(
                                  0,
                                  10.0,
                                  0,
                                  10.0,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 10.0,
                                  mainAxisSpacing: 10.0,
                                  childAspectRatio: 1.0,
                                ),
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: gridViewCharactersModelList.length,
                                itemBuilder: (context, gridViewIndex) {
                                  final gridViewCharactersModel =
                                      gridViewCharactersModelList[
                                          gridViewIndex];
                                  return Container(
                                    width: 100.0,
                                    height: 100.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _model.selectedCharacterUrl ==
                                                gridViewCharactersModel
                                                    .imageUrl
                                            ? Color(0xFF6E6E6E)
                                            : Color(0x00FFFFFF),
                                      ),
                                    ),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        _model.selectedCharacterId =
                                            gridViewCharactersModel
                                                .characterId;
                                        _model.selectedCharacterUrl =
                                            gridViewCharactersModel
                                                .imageUrl;
                                        setState(() {});
                                      },
                                      child: Container(
                                        width: 200.0,
                                        height: 200.0,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                        ),
                                        child: CachedNetworkImage(
                                          fadeInDuration:
                                              Duration(milliseconds: 500),
                                          fadeOutDuration:
                                              Duration(milliseconds: 500),
                                          imageUrl:
                                              '${gridViewCharactersModel.imageUrl}',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                                },  // data callback closing
                              );    // when() closing
                            },      // Consumer builder closing
                          ),        // Consumer widget closing
                        ),          // Container closing
                      ),            // Padding closing
                    ],
                  ),
                ),
              ),
            ),
            AppButtonWidget(
              onPressed: () async {
                await _updateProfileCharacter(
                  characterId: _model.selectedCharacterId,
                  photoUrl: '${_model.selectedCharacterUrl}',
                );
                Navigator.pop(context);
              },
              text: AppLocalizations.of(context).getText(
                '5dgi9ixf' /* Apply */,
              ),
              options: AppButtonOptions(
                height: 40.0,
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: Colors.black,
                textStyle: AppTheme.of(context).titleSmall.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: AppTheme.of(context).titleSmall.fontWeight,
                        fontStyle: AppTheme.of(context).titleSmall.fontStyle,
                      ),
                      color: Colors.white,
                      letterSpacing: 0.0,
                      fontWeight: AppTheme.of(context).titleSmall.fontWeight,
                      fontStyle: AppTheme.of(context).titleSmall.fontStyle,
                    ),
                elevation: 10.0,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
              child: AppButtonWidget(
                onPressed: () async {
                  final selectedMedia = await selectMediaWithSourceBottomSheet(
                    context: context,
                    maxWidth: 800.00,
                    maxHeight: 800.00,
                    imageQuality: 70,
                    allowPhoto: true,
                    pickerFontFamily: 'Plus Jakarta Sans',
                  );
                  if (selectedMedia != null &&
                      selectedMedia.every(
                          (m) => validateFileFormat(m.storagePath, context))) {
                    setState(() =>
                        _model.isDataUploading_userUploadProfileImage = true);
                    var selectedUploadedFiles = <AppUploadedFile>[];

                    var downloadUrls = <String>[];
                    try {
                      selectedUploadedFiles = selectedMedia
                          .map((m) => AppUploadedFile(
                                name: m.storagePath.split('/').last,
                                bytes: m.bytes,
                                height: m.dimensions?.height,
                                width: m.dimensions?.width,
                                blurHash: m.blurHash,
                              ))
                          .toList();

                      downloadUrls = (await Future.wait(
                        selectedMedia.map(
                          (m) async => await uploadData(m.storagePath, m.bytes),
                        ),
                      ))
                          .where((u) => u != null)
                          .map((u) => u!)
                          .toList();
                    } finally {
                      _model.isDataUploading_userUploadProfileImage = false;
                    }
                    if (selectedUploadedFiles.length == selectedMedia.length &&
                        downloadUrls.length == selectedMedia.length) {
                      setState(() {
                        _model.uploadedLocalFile_userUploadProfileImage =
                            selectedUploadedFiles.first;
                        _model.uploadedFileUrl_userUploadProfileImage =
                            downloadUrls.first;
                      });
                    } else {
                      setState(() {});
                      return;
                    }
                  }

                  await _updateProfileCharacter(
                    characterId: null,  // 사용자가 직접 업로드한 이미지는 characterId 없음
                    photoUrl: _model.uploadedFileUrl_userUploadProfileImage,
                  );
                  Navigator.pop(context);
                },
                text: AppLocalizations.of(context).getText(
                  'jtczffcg' /* Gallery / Camera */,
                ),
                options: AppButtonOptions(
                  height: 40.0,
                  padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                  iconPadding:
                      EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: Colors.black,
                  textStyle: AppTheme.of(context).titleSmall.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight:
                              AppTheme.of(context).titleSmall.fontWeight,
                          fontStyle: AppTheme.of(context).titleSmall.fontStyle,
                        ),
                        color: Colors.white,
                        letterSpacing: 0.0,
                        fontWeight: AppTheme.of(context).titleSmall.fontWeight,
                        fontStyle: AppTheme.of(context).titleSmall.fontStyle,
                      ),
                  elevation: 10.0,
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Phase 3: Riverpod - ProfileActions.updateProfile() 사용
  Future<void> _updateProfileCharacter({
    required String? characterId,
    required String photoUrl,
  }) async {
    // AuthContract에서 현재 userId 가져오기
    final authContract = GetIt.instance<AuthContract>();
    final userId = authContract.getCurrentUserId();

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다')),
        );
      }
      return;
    }

    // 현재 프로필 가져오기
    final profileState = ref.read(profileStreamProvider(
      ProfileStreamParams(userId: userId),
    ));

    // AsyncValue에서 현재 프로필 추출
    UserProfile? currentProfile;
    profileState.when(
      loading: () => currentProfile = null,
      error: (error, stackTrace) => currentProfile = null,
      data: (profile) => currentProfile = profile,
    );

    if (currentProfile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필을 불러올 수 없습니다')),
        );
      }
      return;
    }

    // copyWith()로 업데이트된 프로필 생성 (null 체크 완료)
    final updatedProfile = currentProfile!.copyWith(
      characterId: characterId,
      photoUrl: photoUrl,
    );

    // ProfileActions.updateProfile() 호출
    await ProfileActions.updateProfile(
      ref: ref,
      userId: userId,
      updatedProfile: updatedProfile,
      onSuccess: () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('프로필이 업데이트되었습니다')),
          );
        }
      },
      onError: (message) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      },
    );
  }
}
