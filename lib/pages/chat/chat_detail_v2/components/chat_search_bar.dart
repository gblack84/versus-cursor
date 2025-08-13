import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import '/design_system/design_system.dart';

/// 채팅 검색 바 컴포넌트
/// 
/// 메시지 검색 기능을 제공하는 UI 컴포넌트입니다.
class ChatSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function() onClose;
  final List<core.Message> searchResults;
  final int currentSearchIndex;
  final Function(bool) onNavigate;
  
  const ChatSearchBar({
    super.key,
    required this.onSearch,
    required this.onClose,
    required this.searchResults,
    required this.currentSearchIndex,
    required this.onNavigate,
  });
  
  @override
  State<ChatSearchBar> createState() => _ChatSearchBarState();
}

class _ChatSearchBarState extends State<ChatSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    // Auto-focus on search field when opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: VersusColors.backgroundSecondary,
        border: Border(
          bottom: BorderSide(
            color: VersusColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: VersusColors.textPrimary,
            ),
            onPressed: widget.onClose,
          ),
          
          // Search field
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: widget.onSearch,
              style: VersusTextStyles.bodyMedium.copyWith(
                color: VersusColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '메시지 검색...',
                hintStyle: VersusTextStyles.bodyMedium.copyWith(
                  color: VersusColors.textSecondary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
          
          // Search results count
          if (widget.searchResults.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: VersusColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.currentSearchIndex + 1}/${widget.searchResults.length}',
                style: VersusTextStyles.labelSmall.copyWith(
                  color: VersusColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // Navigation buttons
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_up,
                color: VersusColors.textPrimary,
              ),
              onPressed: widget.searchResults.isNotEmpty
                  ? () => widget.onNavigate(false)
                  : null,
            ),
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: VersusColors.textPrimary,
              ),
              onPressed: widget.searchResults.isNotEmpty
                  ? () => widget.onNavigate(true)
                  : null,
            ),
          ],
          
          // Clear button
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear,
                color: VersusColors.textSecondary,
              ),
              onPressed: () {
                _searchController.clear();
                widget.onSearch('');
              },
            ),
        ],
      ),
    );
  }
}

/// AI 검색 입력 위젯
class ChatAISearchInput extends StatefulWidget {
  final Function(String) onSubmit;
  final VoidCallback onClose;
  
  const ChatAISearchInput({
    super.key,
    required this.onSubmit,
    required this.onClose,
  });
  
  @override
  State<ChatAISearchInput> createState() => _ChatAISearchInputState();
}

class _ChatAISearchInputState extends State<ChatAISearchInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    // Auto-focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VersusColors.backgroundSecondary,
        border: Border(
          top: BorderSide(
            color: VersusColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // AI Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  VersusColors.primary,
                  VersusColors.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text(
                'AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Input field
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: VersusColors.backgroundPrimary,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: VersusColors.borderLight,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          widget.onSubmit(text);
                          _controller.clear();
                        }
                      },
                      style: VersusTextStyles.bodyMedium.copyWith(
                        color: VersusColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'AI에게 질문하기...',
                        hintStyle: VersusTextStyles.bodyMedium.copyWith(
                          color: VersusColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  
                  // Send button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final text = _controller.text.trim();
                        if (text.isNotEmpty) {
                          widget.onSubmit(text);
                          _controller.clear();
                        }
                      },
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(22),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.send,
                          color: _controller.text.trim().isNotEmpty
                              ? VersusColors.primary
                              : VersusColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Close button
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.close,
              color: VersusColors.textSecondary,
            ),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }
}