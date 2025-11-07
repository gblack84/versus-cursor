import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core_exports.dart';
import '/features/profile/presentation/providers/profile_notifiers.dart';
import '/features/profile/presentation/widgets/settings/settings_section.dart';
import '/features/profile/presentation/widgets/settings/settings_toggle.dart';
import '/features/profile/presentation/widgets/settings/settings_list_tile.dart';
import '/features/profile/presentation/widgets/common/loading_indicator.dart';
import '/features/profile/presentation/widgets/common/error_message.dart';

/// 설정 화면 (Riverpod 3.x 마이그레이션 완료)
///
/// **Clean Architecture v4.0 + Riverpod 3.x**:
/// - StreamProvider로 실시간 동기화
/// - ProfileNotifier로 업데이트 실행
/// - UI와 비즈니스 로직 완전 분리
/// - GetIt + Riverpod 통합
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  static String routeName = 'settings_screen';
  static String routePath = '/settings';

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    // Riverpod 3.x: StreamProvider로 실시간 동기화 (direct parameter)
    final settingsAsync = ref.watch(settingsStreamProvider(widget.userId));

    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: Text(
          '설정',
          style: AppTheme.of(context).headlineSmall.override(
                color: Colors.black,
              ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: settingsAsync.when(
        loading: () => ProfileLoadingIndicator(
          size: LoadingSize.medium,
        ),
        error: (error, stackTrace) => ProfileErrorMessage(
          message: error.toString(),
          onRetry: () {
            // 재시도: Stream을 다시 구독하도록 강제
            ref.invalidate(settingsStreamProvider(widget.userId));
          },
        ),
        data: (settings) {
          if (settings == null) {
            return Center(child: Text('설정을 찾을 수 없습니다'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium 상태 (읽기 전용)
                if (settings.isPremiumUser) ...[
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.of(context).primary,
                          AppTheme.of(context).secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: Colors.white, size: 32),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Premium 회원',
                                style: AppTheme.of(context).headlineSmall.override(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '모든 프리미엄 기능을 사용할 수 있습니다',
                                style: AppTheme.of(context).bodySmall.override(
                                      color: Colors.white70,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                ],

                // 알림 설정 섹션
                SettingsSection(
                  title: '알림 설정',
                  description: '받고 싶은 알림을 선택하세요',
                  children: [
                    SettingsToggle(
                      icon: Icons.emoji_events,
                      title: '랭크 업데이트',
                      description: '내 랭크가 변경되면 알림을 받습니다',
                      value: settings.receiveRankUpdateNotifications,
                      onChanged: (value) async {
                        final newSettings = {
                          'receiveRankUpdateNotifications': value,
                        };
                        try {
                          await ref.read(profileProvider.notifier).updateSettings(
                            userId: widget.userId,
                            settings: newSettings,
                          );
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('설정 업데이트 실패: $e')),
                            );
                          }
                        }
                      },
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16),
                    SettingsToggle(
                      icon: Icons.military_tech,
                      title: '칭호 업데이트',
                      description: '새로운 칭호를 획득하면 알림을 받습니다',
                      value: settings.receiveTitleUpdateNotifications,
                      onChanged: (value) async {
                        try {
                          await ref.read(profileProvider.notifier).updateSettings(
                            userId: widget.userId,
                            settings: {'receiveTitleUpdateNotifications': value},
                          );
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('설정 업데이트 실패: $e')),
                            );
                          }
                        };
                      },
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16),
                    SettingsToggle(
                      icon: Icons.how_to_vote,
                      title: '투표 알림',
                      description: '내 게시물에 새로운 투표가 있으면 알림을 받습니다',
                      value: settings.receiveVoteNotifications,
                      onChanged: (value) async {
                        try {
                          await ref.read(profileProvider.notifier).updateSettings(
                            userId: widget.userId,
                            settings: {'receiveVoteNotifications': value},
                          );
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('설정 업데이트 실패: $e')),
                            );
                          }
                        };
                      },
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16),
                    SettingsToggle(
                      icon: Icons.comment,
                      title: '댓글 알림',
                      description: '내 게시물에 새로운 댓글이 달리면 알림을 받습니다',
                      value: settings.receiveCommentNotifications,
                      onChanged: (value) async {
                        try {
                          await ref.read(profileProvider.notifier).updateSettings(
                            userId: widget.userId,
                            settings: {'receiveCommentNotifications': value},
                          );
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('설정 업데이트 실패: $e')),
                            );
                          }
                        };
                      },
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16),
                    SettingsToggle(
                      icon: Icons.people,
                      title: '친구 알림',
                      description: '친구 요청 및 활동 알림을 받습니다',
                      value: settings.receiveFriendNotifications,
                      onChanged: (value) async {
                        try {
                          await ref.read(profileProvider.notifier).updateSettings(
                            userId: widget.userId,
                            settings: {'receiveFriendNotifications': value},
                          );
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('설정 업데이트 실패: $e')),
                            );
                          }
                        };
                      },
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // 계정 섹션
                SettingsSection(
                  title: '계정',
                  children: [
                    SettingsListTile(
                      icon: Icons.person,
                      title: '프로필 편집',
                      onTap: () {
                        // ProfileEditScreen으로 이동
                        context.pop(); // 설정 화면 닫고
                        // 프로필 편집은 이미 Settings 버튼에서 접근 가능
                      },
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16),
                    SettingsListTile(
                      icon: Icons.language,
                      title: '언어',
                      trailing: Text(
                        '한국어',
                        style: AppTheme.of(context).bodyMedium.override(
                              color: AppTheme.of(context).secondaryText,
                            ),
                      ),
                      onTap: () {
                        // TODO: 언어 선택 화면으로 이동
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('언어 선택 기능은 준비 중입니다')),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16),
                    SettingsListTile(
                      icon: Icons.delete_forever,
                      title: '계정 삭제',
                      onTap: () => _showDeleteConfirmationDialog(context, widget.userId),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // 정보 섹션
                SettingsSection(
                  title: '정보',
                  children: [
                    SettingsListTile(
                      icon: Icons.info_outline,
                      title: '버전 정보',
                      trailing: Text(
                        'v2.1.0',
                        style: AppTheme.of(context).bodyMedium.override(
                              color: AppTheme.of(context).secondaryText,
                            ),
                      ),
                      onTap: null,
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16),
                    SettingsListTile(
                      icon: Icons.privacy_tip_outlined,
                      title: '개인정보 처리방침',
                      onTap: () {
                        // TODO: 개인정보 처리방침 화면으로 이동
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('준비 중입니다')),
                        );
                      },
                    ),
                    Divider(height: 1, indent: 16, endIndent: 16),
                    SettingsListTile(
                      icon: Icons.description_outlined,
                      title: '이용약관',
                      onTap: () {
                        // TODO: 이용약관 화면으로 이동
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('준비 중입니다')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 계정 삭제 확인 다이얼로그
  void _showDeleteConfirmationDialog(
    BuildContext context,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('계정을 삭제하시겠습니까?'),
        content: Text(
          '모든 데이터가 영구적으로 삭제되며 복구할 수 없습니다.\n\n이 작업은 되돌릴 수 없습니다.',
          style: AppTheme.of(context).bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              '취소',
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
          ),
          TextButton(
            onPressed: () async {
              // 다이얼로그 닫기
              Navigator.of(dialogContext).pop();

              // 계정 삭제 실행 (Riverpod 3.x ProfileNotifier)
              try {
                await ref.read(profileProvider.notifier).deleteProfile(
                  userId: userId,
                );

                if (context.mounted) {
                  // 성공 메시지
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('계정이 삭제되었습니다'),
                      backgroundColor: AppTheme.of(context).success,
                    ),
                  );

                  // startPage로 이동
                  context.goNamed('startPage');
                }
              } catch (e) {
                if (context.mounted) {
                  // 에러 메시지
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('계정 삭제 실패: $e'),
                      backgroundColor: AppTheme.of(context).error,
                    ),
                  );
                }
              }
            },
            child: Text(
              '삭제',
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).error,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
