import '/core_exports.dart';
import '/app/di.dart';
import '/features/profile/data/datasources/profile_storage_datasource.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';

// Phase 10: Riverpod 3.x Migration
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/features/auth/presentation/providers/auth_providers.dart';
import '/features/profile/presentation/providers/profile_notifiers.dart';
import '/features/profile/presentation/providers/usecase_providers.dart';
import '/features/profile/domain/entities/user_profile.dart';
import 'character_detail_page_provider.dart';
export 'character_detail_page_state.dart';

/// 캐릭터 선택 화면 (Riverpod 3.x)
///
/// **Clean Architecture v4.0 + Riverpod 3.x**:
/// - ✅ ConsumerStatefulWidget으로 전환
/// - ✅ charactersProvider 사용
/// - ✅ ProfileNotifier.updateProfile() 사용
/// - ✅ Phase 10: characterDetailPageProvider (AppModel 제거)
class CharacterDetailPageWidget extends ConsumerStatefulWidget {
  const CharacterDetailPageWidget({super.key});

  @override
  ConsumerState<CharacterDetailPageWidget> createState() =>
      _CharacterDetailPageWidgetState();
}

class _CharacterDetailPageWidgetState extends ConsumerState<CharacterDetailPageWidget> {
  @override
  void initState() {
    super.initState();
    // Phase 10: Riverpod 3.x - characterDetailPageProvider로 상태 관리
    // 캐릭터 목록은 charactersProvider가 자동 로드
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
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
                                  // Phase 10: characterDetailPageProvider 사용
                                  final state = ref.watch(characterDetailPageProvider);

                                  return Container(
                                    width: 100.0,
                                    height: 100.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: state.selectedCharacterUrl ==
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
                                        ref.read(characterDetailPageProvider.notifier)
                                            .updateSelectedCharacterId(
                                          gridViewCharactersModel.characterId,
                                        );
                                        ref.read(characterDetailPageProvider.notifier)
                                            .updateSelectedCharacterUrl(
                                          gridViewCharactersModel.imageUrl,
                                        );
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
                // Phase 10: characterDetailPageProvider 사용
                final state = ref.read(characterDetailPageProvider);
                await _updateProfileCharacter(
                  characterId: state.selectedCharacterId,
                  photoUrl: state.selectedCharacterUrl,
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
                  // Phase C-2: currentUserIdProvider 사용
                  final currentUserId = ref.read(currentUserIdProvider).value;
                  if (currentUserId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('로그인이 필요합니다')),
                    );
                    return;
                  }

                  // 1. 미디어 선택 (Gallery)
                  final selectMediaResult = await ref.read(selectMediaUseCaseProvider).execute(
                    userId: currentUserId,
                    allowPhoto: true,
                    maxWidth: 800.0,
                    maxHeight: 800.0,
                    imageQuality: 70,
                  );

                  // Either 패턴 처리
                  final selectedFiles = selectMediaResult.fold(
                    (failure) {
                      // 선택 취소 시 null 반환 (기존 동작 유지)
                      return null;
                    },
                    (files) => files,
                  );

                  if (selectedFiles == null || selectedFiles.isEmpty) {
                    return; // 사용자가 취소함
                  }

                  // 2. 파일 포맷 검증
                  final filePaths = selectedFiles.map((f) => f.path).toList();
                  final validateResult = await ref.read(validateMediaUseCaseProvider).execute(filePaths);

                  final isValid = validateResult.fold(
                    (failure) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(failure.message)),
                      );
                      return false;
                    },
                    (_) => true,
                  );

                  if (!isValid) {
                    return; // 검증 실패
                  }

                  // 3. 기존 업로드 로직 실행 (File → AppUploadedFile → uploadData)
                  // Phase 10: characterDetailPageProvider 사용
                  if (selectedFiles.isNotEmpty) {
                    ref.read(characterDetailPageProvider.notifier)
                        .updateUploadProgress(true);
                    var selectedUploadedFiles = <AppUploadedFile>[];

                    var downloadUrls = <String>[];
                    try {
                      // File → bytes 변환
                      final fileBytes = await Future.wait(
                        selectedFiles.map((file) => file.readAsBytes()),
                      );

                      // AppUploadedFile 생성
                      selectedUploadedFiles = selectedFiles.asMap().entries.map((entry) {
                        final index = entry.key;
                        final file = entry.value;
                        final bytes = fileBytes[index];

                        return AppUploadedFile(
                          name: file.path.split('/').last,
                          bytes: bytes,
                          // height, width, blurHash는 uploadData가 자동 처리
                        );
                      }).toList();

                      // Firebase Storage 업로드
                      final storagePaths = selectedFiles.map((file) {
                        final timestamp = DateTime.now().microsecondsSinceEpoch;
                        final ext = file.path.split('.').last;
                        return 'users/$currentUserId/uploads/$timestamp.$ext';
                      }).toList();

                      // DataSource를 통한 업로드 (Clean Architecture)
                      final dataSource = getIt<IProfileStorageDataSource>();

                      downloadUrls = await Future.wait(
                        storagePaths.asMap().entries.map((entry) async {
                          final index = entry.key;
                          final path = entry.value;
                          final bytes = fileBytes[index];
                          return await dataSource.uploadFileBytes(
                            path: path,
                            bytes: bytes,
                          );
                        }),
                      );
                    } finally {
                      ref.read(characterDetailPageProvider.notifier)
                          .updateUploadProgress(false);
                    }

                    if (selectedUploadedFiles.length == selectedFiles.length &&
                        downloadUrls.length == selectedFiles.length) {
                      ref.read(characterDetailPageProvider.notifier)
                          .updateUploadedLocalFile(selectedUploadedFiles.first);
                      ref.read(characterDetailPageProvider.notifier)
                          .updateUploadedFileUrl(downloadUrls.first);
                    } else {
                      return;
                    }
                  }

                  // Phase 10: characterDetailPageProvider 사용
                  final uploadedUrl = ref.read(characterDetailPageProvider).uploadedFileUrl;
                  await _updateProfileCharacter(
                    characterId: null,  // 사용자가 직접 업로드한 이미지는 characterId 없음
                    photoUrl: uploadedUrl,
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

  /// Riverpod 3.x - ProfileNotifier.updateProfile() 사용
  Future<void> _updateProfileCharacter({
    required String? characterId,
    required String photoUrl,
  }) async {
    // Phase C-2: currentUserIdProvider 사용
    final userId = ref.read(currentUserIdProvider).value;

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다')),
        );
      }
      return;
    }

    // 현재 프로필 가져오기
    final profileState = ref.read(profileStreamProvider(userId));

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

    // Riverpod 3.x ProfileNotifier.updateProfile() 호출
    try {
      await ref.read(profileProvider.notifier).updateProfile(
        profile: updatedProfile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프로필이 업데이트되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('프로필 업데이트 실패: $e')),
        );
      }
    }
  }
}
