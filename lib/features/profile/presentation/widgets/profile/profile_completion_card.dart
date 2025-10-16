import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';

/// 프로필 완성도 카드 위젯
///
/// **기능**:
/// - 프로필 완성도 퍼센티지 표시 (0-100%)
/// - 색상 코딩으로 직관적 시각화
/// - 미완성 항목 체크리스트
/// - 프로필 편집 페이지로 빠른 이동
///
/// **색상 기준**:
/// - 빨간색 (< 50%): 기본 정보 부족
/// - 주황색 (50-80%): 추가 정보 필요
/// - 초록색 (80%+): 거의 완성
class ProfileCompletionCard extends StatelessWidget {
  final String userId;
  final VoidCallback? onCompletePressed;

  const ProfileCompletionCard({
    Key? key,
    required this.userId,
    this.onCompletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        final percentage = provider.completionPercentage;
        final isLoading = provider.isLoadingCompletion;

        if (isLoading) {
          return _buildLoadingCard(context);
        }

        if (percentage == null) {
          return _buildErrorCard(context);
        }

        return _buildCompletionCard(context, percentage, provider);
      },
    );
  }

  /// 로딩 중 카드
  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('프로필 완성도 확인 중...'),
          ],
        ),
      ),
    );
  }

  /// 에러 카드
  Widget _buildErrorCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 16),
            const Expanded(
              child: Text('프로필 완성도를 불러올 수 없습니다'),
            ),
            TextButton(
              onPressed: () {
                context.read<ProfileProvider>().getProfileCompletion(userId);
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  /// 완성도 카드
  Widget _buildCompletionCard(
    BuildContext context,
    double percentage,
    ProfileProvider provider,
  ) {
    final color = _getColorForPercentage(percentage);
    final missingItems = _getMissingItems(provider.profile);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 및 퍼센티지
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '프로필 완성도',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${percentage.toInt()}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 진행 바
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 16),

            // 미완성 항목 (있을 경우만)
            if (missingItems.isNotEmpty) ...[
              const Text(
                '완성되지 않은 항목:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ...missingItems.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_box_outline_blank,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 12),
            ],

            // 완성하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCompletePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  '완성하기',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 완성도에 따른 색상 반환
  Color _getColorForPercentage(double percentage) {
    if (percentage < 50) {
      return Colors.red;
    } else if (percentage < 80) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  /// 미완성 항목 목록 생성
  List<String> _getMissingItems(dynamic profile) {
    if (profile == null) return [];

    final missingItems = <String>[];

    // displayName 체크
    if (profile.displayName == null || profile.displayName.isEmpty) {
      missingItems.add('표시 이름');
    }

    // photoUrl 체크
    if (profile.photoUrl == null || profile.photoUrl.isEmpty) {
      missingItems.add('프로필 사진');
    }

    // shortDescription 체크
    if (profile.shortDescription == null || profile.shortDescription.isEmpty) {
      missingItems.add('자기소개');
    }

    // gender 체크
    if (profile.gender == null || profile.gender.isEmpty) {
      missingItems.add('성별');
    }

    // dateOfBirth 체크
    if (profile.dateOfBirth == null) {
      missingItems.add('생년월일');
    }

    // location 체크
    if (profile.location == null) {
      missingItems.add('위치');
    }

    // interests 체크
    if (profile.interests == null || profile.interests.isEmpty) {
      missingItems.add('관심사');
    }

    // expertise 체크
    if (profile.expertise == null || profile.expertise.isEmpty) {
      missingItems.add('전문 분야');
    }

    // language 체크
    if (profile.language == null || profile.language.isEmpty) {
      missingItems.add('사용 언어');
    }

    return missingItems;
  }
}
