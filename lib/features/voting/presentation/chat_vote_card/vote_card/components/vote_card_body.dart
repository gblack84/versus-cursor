import 'package:flutter/material.dart';
import '/core/design_system/design_system.dart';
import '/features/voting/domain/entities/chat/vote_state.dart';
import '/services/ui/models/box_sizes.dart';
import '../vote_options_widget.dart';
import '../vote_results_widget.dart';
import '../utils/vote_card_helpers.dart';

/// 투표 카드 본문 컴포넌트
/// 제목, 설명, 투표 옵션 또는 결과를 표시합니다
class VoteCardBody extends StatelessWidget {
  const VoteCardBody({
    super.key,
    required this.title,
    this.description,
    this.searchQuery,
    required this.state,
    required this.optionAText,
    required this.optionBText,
    required this.optionAImages,
    required this.optionBImages,
    required this.boxSizes,
    required this.isHorizontal,
    this.voteResults,
    this.currentUserName,
  });

  final String title;
  final String? description;
  final String? searchQuery;
  final VoteState state;
  final String optionAText;
  final String optionBText;
  final List<String> optionAImages;
  final List<String> optionBImages;
  final BoxSizes boxSizes;
  final bool isHorizontal;
  final Map<String, dynamic>? voteResults;
  final String? currentUserName;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목
        _buildTitle(),
        
        // 설명 (있는 경우에만)
        if (description != null) ...[
          const SizedBox(height: VersusSpacing.xs),
          _buildDescription(),
        ],
        
        const SizedBox(height: VersusSpacing.md),
        
        // 투표 옵션 또는 결과
        _buildContent(),
      ],
    );
  }

  Widget _buildTitle() {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return Text(
        title,
        style: VersusTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.bold,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    // 검색어 하이라이팅 적용
    return VoteCardHelpers.highlightText(
      text: title,
      searchQuery: searchQuery!,
      baseStyle: VersusTextStyles.bodyLarge.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDescription() {
    if (description == null) return const SizedBox.shrink();

    // 검색어 하이라이팅 지원
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      return VoteCardHelpers.highlightText(
        text: description!,
        searchQuery: searchQuery!,
        baseStyle: VersusTextStyles.bodySmall.copyWith(
          color: VersusColors.textSecondary,
        ),
      );
    }

    return Text(
      description!,
      style: VersusTextStyles.bodySmall.copyWith(
        color: VersusColors.textSecondary,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildContent() {
    // 완료 상태이고 결과가 있으면 결과 표시
    if (state == VoteState.completed && voteResults != null) {
      return VoteResultsWidget(
        currentUserName: currentUserName,
        state: state,
        voteResults: voteResults,
      );
    }
    
    // 그 외의 경우 투표 옵션 표시
    return VoteOptionsWidget(
      optionAText: optionAText,
      optionBText: optionBText,
      optionAImages: optionAImages,
      optionBImages: optionBImages,
      boxSizes: boxSizes,
      isHorizontal: isHorizontal,
    );
  }
}