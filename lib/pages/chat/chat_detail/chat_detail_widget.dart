import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import '/core/app_utils.dart';
import '/design_system/design_system.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/utils/chat_message_converter.dart';
import '/services/chat_media_upload_service.dart';
import '/components/chat/vote_card_message.dart';
import '/components/notifications/voting_notification_dialog.dart';
import '/services/chat_image_cache_service.dart';
import '/posts/in_put_post_image/utils/debug_helper.dart';
import '/services/vote_status_service.dart';
import 'chat_detail_model.dart';
export 'chat_detail_model.dart';

class ChatDetailWidget extends StatefulWidget {
  const ChatDetailWidget({
    super.key,
    required this.chatDocument,
  });

  static const String routeName = 'ChatDetail';
  static const String routePath = '/chat-detail';

  final ChatsModel? chatDocument;

  @override
  State<ChatDetailWidget> createState() => _ChatDetailWidgetState();
}

class _ChatDetailWidgetState extends State<ChatDetailWidget> {
  late ChatDetailModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late types.User _currentUser;
  UsersModel? _currentUserRecord; // 현재 사용자 정보 저장
  Map<String, UsersModel> _usersMap = {};
  bool _isLoadingUsers = true;
  final ChatMediaUploadService _mediaUploadService = ChatMediaUploadService();
  bool _isUploadingMedia = false;
  
  // 스크롤 컨트롤러 (프리로딩 최적화용)
  final ScrollController _scrollController = ScrollController();
  
  // 이전 user_votes 상태를 추적하기 위한 맵
  final Map<String, Map<String, dynamic>?> _previousUserVotes = {};

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ChatDetailModel());
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // 현재 사용자 설정
    if (currentUserReference != null) {
      final currentUserDoc = await currentUserReference!.get();
      final currentUserRecord = UsersModel.fromSnapshot(currentUserDoc);
      _currentUserRecord = currentUserRecord; // 저장
      _currentUser = ChatMessageConverter.convertCurrentUser(currentUserRecord);
    }

    // 채팅 참가자들의 사용자 정보 로드
    if (widget.chatDocument != null) {
      final participantIds = widget.chatDocument!.participantIds;
      _usersMap = await ChatMessageConverter.fetchUsersMap(participantIds);
    }

    setState(() {
      _isLoadingUsers = false;
    });
  }

  @override
  void dispose() {
    _model.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSendPressed(types.PartialText message) async {
    if (widget.chatDocument == null) return;

    final messageId = const Uuid().v4();
    
    // Firestore에 메시지 저장
    await MessagesModel.createDoc(widget.chatDocument!.reference)
        .set(createMessagesModelData(
      messageId: messageId,
      content: message.text,
      senderId: currentUserUid,
      timeStamp: getCurrentTimestamp(),
    ));

    // 채팅방 정보 업데이트
    await widget.chatDocument!.reference.update({
      ...createChatsModelData(
        lastMessageContent: message.text,
        lastMessageAt: getCurrentTimestamp(),
      ),
      'participantIds': FieldValue.arrayUnion([currentUserUid]),
    });
  }

  void _handleAttachmentPressed() async {
    // 미디어 타입 선택 바텀시트 표시
    showModalBottomSheet(
      context: context,
      backgroundColor: VersusColors.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(VersusSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: VersusSpacing.md),
              decoration: BoxDecoration(
                color: VersusColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              '미디어 선택',
              style: VersusTextStyles.headingSmall,
            ),
            const SizedBox(height: VersusSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMediaOption(
                  icon: Icons.photo_library,
                  label: '갤러리',
                  onTap: () {
                    Navigator.pop(context);
                    _pickMedia(RequestType.image);
                  },
                ),
                _buildMediaOption(
                  icon: Icons.camera_alt,
                  label: '카메라',
                  onTap: () {
                    Navigator.pop(context);
                    _pickCamera();
                  },
                ),
                _buildMediaOption(
                  icon: Icons.videocam,
                  label: '동영상',
                  onTap: () {
                    Navigator.pop(context);
                    _pickMedia(RequestType.video);
                  },
                ),
              ],
            ),
            const SizedBox(height: VersusSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(VersusSpacing.md),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: VersusColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 28,
                color: VersusColors.primary,
              ),
            ),
            const SizedBox(height: VersusSpacing.xs),
            Text(
              label,
              style: VersusTextStyles.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMedia(RequestType type) async {
    try {
      final List<AssetEntity>? assets = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: type == RequestType.image ? 9 : 1,
          requestType: type,
          textDelegate: const KoreanAssetPickerTextDelegate(),
          themeColor: VersusColors.primary,
        ),
      );

      if (assets != null && assets.isNotEmpty) {
        setState(() => _isUploadingMedia = true);
        
        for (final asset in assets) {
          await _uploadAndSendMedia(asset, type);
        }
        
        setState(() => _isUploadingMedia = false);
      }
    } catch (e) {
      setState(() => _isUploadingMedia = false);
      BotToast.showText(text: '미디어 선택 실패: $e');
    }
  }

  Future<void> _pickCamera() async {
    try {
      final AssetEntity? asset = await CameraPicker.pickFromCamera(
        context,
        pickerConfig: const CameraPickerConfig(
          enableRecording: true,
          textDelegate: CameraPickerTextDelegate(),
        ),
      );

      if (asset != null) {
        setState(() => _isUploadingMedia = true);
        
        final type = asset.type == AssetType.video 
            ? RequestType.video 
            : RequestType.image;
        await _uploadAndSendMedia(asset, type);
        
        setState(() => _isUploadingMedia = false);
      }
    } catch (e) {
      setState(() => _isUploadingMedia = false);
      BotToast.showText(text: '카메라 오류: $e');
    }
  }

  Future<void> _uploadAndSendMedia(AssetEntity asset, RequestType type) async {
    try {
      final File? file = await asset.file;
      if (file == null) return;

      final messageId = const Uuid().v4();
      final chatId = widget.chatDocument!.reference.id;

      if (type == RequestType.image) {
        // 이미지 업로드
        final result = await _mediaUploadService.uploadChatImage(
          chatId: chatId,
          messageId: messageId,
          imageFile: file,
        );

        // Firestore에 이미지 메시지 저장
        await widget.chatDocument!.reference.collection('messages').add(
          createMessagesModelData(
            messageId: messageId,
            senderId: currentUserUid,
            content: '',
            timeStamp: DateTime.now(),
            isRead: false,
            mediaType: 'image',
            imageUrl: result['url'],
            mediaSize: result['size'],
            mediaWidth: result['width'],
            mediaHeight: result['height'],
          ),
        );
      } else {
        // 비디오 업로드
        final result = await _mediaUploadService.uploadChatVideo(
          chatId: chatId,
          messageId: messageId,
          videoFile: file,
        );

        // Firestore에 비디오 메시지 저장
        await widget.chatDocument!.reference.collection('messages').add(
          createMessagesModelData(
            messageId: messageId,
            senderId: currentUserUid,
            content: '',
            timeStamp: DateTime.now(),
            isRead: false,
            mediaType: 'video',
            videoUrl: result['url'],
            thumbnailUrl: result['thumbnailUrl'],
            mediaSize: result['size'],
          ),
        );
      }

      BotToast.showText(text: '미디어 전송 완료');
    } catch (e) {
      BotToast.showText(text: '업로드 실패: $e');
    }
  }

  Widget _customMessageBuilder(types.CustomMessage message, {required int messageWidth}) {
    final metadata = message.metadata ?? {};
    
    // 투표 메시지 (투표 요청 및 투표 생성)
    if (metadata['type'] == 'vote_request' || metadata['type'] == 'vote_created') {
      // Firestore에서 추가 데이터 가져오기
      // vote_post_id로 검색하여 메시지 찾기
      final postId = metadata['postId'] ?? '';
      
      // AI 채팅인지 일반 채팅인지 확인
      Stream<QuerySnapshot>? messageStream;
      if (widget.chatDocument != null) {
        // 일반 채팅
        messageStream = widget.chatDocument!.reference
            .collection('messages')
            .where('vote_post_id', isEqualTo: postId)
            .where('message_type', isEqualTo: metadata['type'])
            .limit(1)
            .snapshots();
      } else {
        // AI 채팅
        final aiChatId = 'ai_assistant_$currentUserUid';
        messageStream = FirebaseFirestore.instance
            .collection('chats')
            .doc(aiChatId)
            .collection('messages')
            .where('vote_post_id', isEqualTo: postId)
            .where('message_type', isEqualTo: metadata['type'])
            .limit(1)
            .snapshots();
      }
      
      return StreamBuilder<QuerySnapshot>(
        stream: messageStream,
        builder: (context, snapshot) {
          final messageData = snapshot.data?.docs.firstOrNull?.data() as Map<String, dynamic>?;
          
          // description 필드 직접 사용
          final description = messageData?['vote_description'] ?? metadata['description'];
          
          // aspectRatio 데이터 추출 (강화된 파싱)
          dynamic rawAspectRatioA = messageData?['vote_aspect_ratio_a'] ?? metadata['aspectRatioA'];
          dynamic rawAspectRatioB = messageData?['vote_aspect_ratio_b'] ?? metadata['aspectRatioB'];
          
          // 타입 변환 및 null 체크
          double? aspectRatioA;
          double? aspectRatioB;
          
          if (rawAspectRatioA != null) {
            if (rawAspectRatioA is num) {
              aspectRatioA = rawAspectRatioA.toDouble();
            } else if (rawAspectRatioA is String) {
              aspectRatioA = double.tryParse(rawAspectRatioA);
            }
          }
          
          if (rawAspectRatioB != null) {
            if (rawAspectRatioB is num) {
              aspectRatioB = rawAspectRatioB.toDouble();
            } else if (rawAspectRatioB is String) {
              aspectRatioB = double.tryParse(rawAspectRatioB);
            }
          }
          
          // 디버깅 로그
          if (rawAspectRatioA != null || rawAspectRatioB != null) {
            debugPrint('[ChatDetail] AspectRatio 파싱:');
            debugPrint('  - rawAspectRatioA: $rawAspectRatioA (${rawAspectRatioA.runtimeType})');
            debugPrint('  - rawAspectRatioB: $rawAspectRatioB (${rawAspectRatioB.runtimeType})');
            debugPrint('  - aspectRatioA: $aspectRatioA');
            debugPrint('  - aspectRatioB: $aspectRatioB');
          }
          
          // 현재 사용자의 투표 상태 확인
          final userVotes = messageData?['user_votes'] as Map<String, dynamic>?;
          final currentUserVote = userVotes?[currentUserUid] as Map<String, dynamic>?;
          final hasUserVoted = currentUserVote != null;
          final userVoteOption = currentUserVote?['option'] as String?;
          
          // 투표 상태 디버깅 - user_votes가 변경된 경우에만 로그 출력
          String? userVotesStr;
          String? previousVotesStr;
          
          if (messageData != null) {
            userVotesStr = messageData['user_votes']?.toString();
            previousVotesStr = _previousUserVotes[postId]?.toString();
            
            if (userVotesStr != previousVotesStr) {
              DebugHelper.debug('[VoteStatus] 투표 상태 변경 감지!', tag: 'Vote');
              DebugHelper.debug('[VoteStatus] postId=$postId, hasUserVoted=$hasUserVoted, userVoteOption=$userVoteOption', tag: 'Vote');
              DebugHelper.debug('[VoteStatus] user_votes 전체: ${messageData['user_votes']}', tag: 'Vote');
              DebugHelper.debug('[VoteStatus] 현재 사용자 UID: $currentUserUid', tag: 'Vote');
              DebugHelper.debug('[VoteStatus] widget.chatDocument: ${widget.chatDocument != null ? "있음" : "null (AI 채팅)"}', tag: 'Vote');
              DebugHelper.debug('[VoteStatus] cardStatus: ${messageData?['card_status']}', tag: 'Vote');
              DebugHelper.debug('[VoteStatus] messageType: ${metadata['type']}', tag: 'Vote');
              
              // 현재 상태를 이전 상태로 저장
              _previousUserVotes[postId] = Map<String, dynamic>.from(messageData['user_votes'] ?? {});
            }
          }
          
          // 이미지 프리로딩
          final imageA = metadata['optionAImage'];
          final imageB = metadata['optionBImage'];
          final imagesA = messageData?['vote_option_a_images'] != null 
              ? List<String>.from(messageData!['vote_option_a_images']) 
              : null;
          final imagesB = messageData?['vote_option_b_images'] != null 
              ? List<String>.from(messageData!['vote_option_b_images']) 
              : null;
          
          // 비동기로 이미지 프리로딩 (UI 차단하지 않음)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ChatImageCacheService.instance.preloadVoteMessageImages(
              context,
              imageUrlA: imageA,
              imageUrlB: imageB,
              imageUrlsA: imagesA,
              imageUrlsB: imagesB,
            );
          });
          
          // vote_request 타입은 VoteCardMessage 사용
          if (metadata['type'] == 'vote_request') {
            return VoteCardMessage(
                  postId: metadata['postId'] ?? '',
                  title: metadata['title'] ?? '',
                  description: description,
                  optionAText: metadata['optionAText'] ?? '',
                  optionBText: metadata['optionBText'] ?? '',
                  optionAImage: metadata['optionAImage']?.isNotEmpty == true ? metadata['optionAImage'] : null,
                  optionBImage: metadata['optionBImage']?.isNotEmpty == true ? metadata['optionBImage'] : null,
                  optionAImages: imagesA ?? (metadata['optionAImages'] != null 
                      ? List<String>.from(metadata['optionAImages']) 
                      : null),
                  optionBImages: imagesB ?? (metadata['optionBImages'] != null 
                      ? List<String>.from(metadata['optionBImages']) 
                      : null),
                  aspectRatioA: aspectRatioA,
                  aspectRatioB: aspectRatioB,
                  currentUserName: _currentUserRecord?.displayName,
                  cardStatus: messageData?['card_status'] ?? metadata['cardStatus'] ?? 'voting_request',
                  messageType: 'vote_request',
                  isMe: message.author.id == _currentUser.id,
                  timestamp: DateTime.fromMillisecondsSinceEpoch(message.createdAt ?? 0),
                  voteEndTime: messageData?['vote_end_time'] != null
                      ? (messageData!['vote_end_time'] as Timestamp).toDate()
                      : (metadata['voteEndTime'] != null ? metadata['voteEndTime'] as DateTime : null),
                  userVotes: messageData?['user_votes'] as Map<String, dynamic>? ?? metadata['userVotes'] as Map<String, dynamic>?,
                  voteResults: messageData?['vote_results_a'] != null ? {
                    'votesA': messageData?['vote_results_a'],
                    'votesB': messageData?['vote_results_b'],
                    'percentageA': (messageData?['vote_percent_a'] as num?)?.toDouble(),
                    'percentageB': (messageData?['vote_percent_b'] as num?)?.toDouble(),
                  } : (metadata['voteCountA'] != null ? {
                    'votesA': metadata['voteCountA'],
                    'votesB': metadata['voteCountB'],
                    'percentageA': metadata['votePercentageA'],
                    'percentageB': metadata['votePercentageB'],
                  } : null),
                  messageId: snapshot.data?.docs.firstOrNull?.id ?? message.id,
                  chatId: widget.chatDocument?.reference.id,
            );
          } else if (metadata['type'] == 'vote_created') {
            // vote_created 타입은 VoteCardMessage 사용
            // vote_created 메시지를 VoteCardMessage로 처리 로그 제거됨
            return VoteCardMessage(
              postId: metadata['postId'] ?? '',
              title: metadata['title'] ?? '',
              description: description,
              optionAText: metadata['optionAText'] ?? '',
              optionBText: metadata['optionBText'] ?? '',
              optionAImage: metadata['optionAImage']?.isNotEmpty == true ? metadata['optionAImage'] : null,
              optionBImage: metadata['optionBImage']?.isNotEmpty == true ? metadata['optionBImage'] : null,
              optionAImages: messageData?['vote_option_a_images'] != null 
                  ? List<String>.from(messageData!['vote_option_a_images']) 
                  : null,
              optionBImages: messageData?['vote_option_b_images'] != null 
                  ? List<String>.from(messageData!['vote_option_b_images']) 
                  : null,
              aspectRatioA: aspectRatioA,
              aspectRatioB: aspectRatioB,
              currentUserName: _currentUserRecord?.displayName,
              cardStatus: messageData?['card_status'] ?? 'in_progress',
              messageType: 'vote_created',
              isMe: message.author.id == _currentUser.id,
              timestamp: DateTime.fromMillisecondsSinceEpoch(message.createdAt ?? 0),
              voteEndTime: messageData?['vote_end_time'] != null
                  ? (messageData!['vote_end_time'] as Timestamp).toDate()
                  : (metadata['voteEndTime'] != null ? metadata['voteEndTime'] as DateTime : null),
              userVotes: messageData?['user_votes'] as Map<String, dynamic>? ?? metadata['userVotes'] as Map<String, dynamic>?,
              voteResults: messageData?['vote_results_a'] != null ? {
                'votesA': messageData?['vote_results_a'],
                'votesB': messageData?['vote_results_b'],
                'percentageA': (messageData?['vote_percent_a'] as num?)?.toDouble(),
                'percentageB': (messageData?['vote_percent_b'] as num?)?.toDouble(),
              } : (metadata['voteCountA'] != null ? {
                'votesA': metadata['voteCountA'],
                'votesB': metadata['voteCountB'],
                'percentageA': metadata['votePercentageA'],
                'percentageB': metadata['votePercentageB'],
              } : null),
              messageId: snapshot.data?.docs.firstOrNull?.id ?? message.id,
              chatId: widget.chatDocument?.reference.id,
            );
          }
          
          // 기본값 처리
          return const SizedBox.shrink();
        },
      );
    }
    
    // 알 수 없는 커스텀 메시지 타입
    return Container(
      padding: const EdgeInsets.all(VersusSpacing.md),
      child: Text(
        '알 수 없는 메시지 타입',
        style: VersusTextStyles.bodySmall.copyWith(
          color: VersusColors.textSecondary,
        ),
      ),
    );
  }

  void _handleLinkPressed(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        BotToast.showText(text: '링크를 열 수 없습니다: $url');
      }
    } catch (e) {
      BotToast.showText(text: '링크 열기 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: VersusColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: VersusColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.chatDocument?.chatName ?? '채팅',
          style: VersusTextStyles.headingMedium.copyWith(
            color: Colors.white,
            fontSize: 22.0,
          ),
        ),
        centerTitle: true,
        elevation: 2.0,
      ),
      body: SafeArea(
        top: true,
        child: _isLoadingUsers
            ? Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      VersusColors.primary,
                    ),
                  ),
                ),
              )
            : widget.chatDocument != null
                ? StreamBuilder<List<MessagesModel>>(
                    stream: queryMessagesModel(
                      parent: widget.chatDocument?.reference,
                      queryBuilder: (messagesRecord) => messagesRecord
                          .orderBy('time_stamp', descending: true),
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: SizedBox(
                            width: 50.0,
                            height: 50.0,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                VersusColors.primary,
                              ),
                            ),
                          ),
                        );
                      }

                      // 전체 메시지 수 확인
                      // 로그 제거됨 - 중복 로그 방지
                      
                      final messages = <types.Message>[];
                      for (final message in snapshot.data!) {
                        
                        // AI 사용자 특별 처리
                        if (message.senderId == 'ai_assistant') {
                          // AI 메시지 감지 로그 제거됨
                          
                          // vote_created 타입 처리 (로그 제거됨)
                          if (message.messageType == 'vote_created') {
                            // vote_created 메시지 발견 로그 제거됨
                          }
                          
                          // AI 사용자 정보 하드코딩
                          final aiUser = UsersModel.getDocumentFromData({
                            'uid': 'ai_assistant',
                            'display_name': 'AI 피클',
                            'photo_url': '', // AI 아바타 이미지 경로 (필요시 추가)
                            'email': 'ai@pikle.app',
                          }, FirebaseFirestore.instance.collection('users').doc('ai_assistant'));
                          
                          final convertedMessage = ChatMessageConverter.convertToMessage(
                            message,
                            senderUser: aiUser,
                          );
                          // AI 메시지 변환 완료 로그 제거됨
                          
                          messages.add(convertedMessage);
                        } else {
                          // 일반 사용자 처리
                          final senderUser = _usersMap[message.senderId];
                          if (senderUser != null) {
                            messages.add(ChatMessageConverter.convertToMessage(
                              message,
                              senderUser: senderUser,
                            ));
                          }
                        }
                      }

                      return Stack(
                        children: [
                          Chat(
                            messages: messages,
                            onSendPressed: _handleSendPressed,
                            onAttachmentPressed: _handleAttachmentPressed,
                            user: _currentUser,
                            theme: _buildChatTheme(),
                            l10n: const ChatL10nKo(), // 한국어 지원
                            inputOptions: const InputOptions(
                              sendButtonVisibilityMode: SendButtonVisibilityMode.always,
                            ),
                            customMessageBuilder: _customMessageBuilder,
                            textMessageOptions: TextMessageOptions(
                              onLinkPressed: (url) => _handleLinkPressed(url),
                              isTextSelectable: true,
                            ),
                            usePreviewData: true,
                            showUserAvatars: true,
                            emptyState: Center(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 64,
                                      color: VersusColors.textSecondary,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '아직 메시지가 없습니다',
                                      style: VersusTextStyles.bodyLarge.copyWith(
                                        color: VersusColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '첫 메시지를 보내보세요!',
                                      style: VersusTextStyles.bodyMedium.copyWith(
                                        color: VersusColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (_isUploadingMedia)
                            Positioned(
                              bottom: 80,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: VersusSpacing.md,
                                    vertical: VersusSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: VersusColors.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: VersusSpacing.xs),
                                      Text(
                                        '미디어 업로드 중...',
                                        style: VersusTextStyles.labelSmall.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  )
                : Center(
                    child: Text(
                      '채팅을 선택해주세요',
                      style: VersusTextStyles.bodyLarge,
                    ),
                  ),
      ),
    );
  }

  void _showVotingDialog({
    required String postId,
    required String title,
    required String? description,
    required String optionAText,
    required String optionBText,
    String? optionAImage,
    String? optionBImage,
    List<String>? imageUrlsA,
    List<String>? imageUrlsB,
    double? aspectRatioA,
    double? aspectRatioB,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.92,
          ),
          child: VotingNotificationDialog(
            question: title,
            optionA: optionAText,
            optionB: optionBText,
            imageUrlA: optionAImage,
            imageUrlB: optionBImage,
            imageUrlsA: imageUrlsA,
            imageUrlsB: imageUrlsB,
            description: description,
            authorName: '',
            aspectRatioA: aspectRatioA,
            aspectRatioB: aspectRatioB,
            onVote: (option) async {
              Navigator.of(context).pop();
              await _handleVoteFromMessage(
                postId: postId,
                option: option,
              );
            },
            onDismiss: (hasVoted) {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleVoteFromMessage({
    required String postId,
    required String option,
  }) async {
    try {
      DebugHelper.debug('=== 투표 처리 시작 ===', tag: 'Vote');
      DebugHelper.debug('postId: $postId, option: $option', tag: 'Vote');
      DebugHelper.debug('widget.chatDocument: ${widget.chatDocument != null ? "있음" : "null"}', tag: 'Vote');
      DebugHelper.debug('currentUserUid: $currentUserUid', tag: 'Vote');
      
      // 투표 처리 로직 - 보안 규칙에 맞게 수정
      final voteData = {
        'user': currentUserReference,
        'option': option,
        'created_at': FieldValue.serverTimestamp(),
        'from_chat': true,
      };
      
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('votes')
          .add(voteData);
      
      // 투표 수 업데이트
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final postRef = FirebaseFirestore.instance
            .collection('posts')
            .doc(postId);
        
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) {
          throw Exception('게시물을 찾을 수 없습니다');
        }
        
        final currentData = postDoc.data() as Map<String, dynamic>;
        final voteCountField = option == 'A' ? 'vote_count_a' : 'vote_count_b';
        final votedUsersField = option == 'A' ? 'votedUserIDsA' : 'votedUserIDsB';
        final votesField = option == 'A' ? 'votes_a' : 'votes_b';
        final currentCount = (currentData[voteCountField] ?? 0) as int;
        
        transaction.update(postRef, {
          voteCountField: currentCount + 1,
          votedUsersField: FieldValue.arrayUnion([currentUserUid]),
          votesField: FieldValue.increment(1),
          'total_votes': FieldValue.increment(1),
          'last_vote_at': FieldValue.serverTimestamp(),
        });
      });
      
      // 채팅 메시지의 투표 상태 업데이트
      if (widget.chatDocument != null) {
        // 일반 채팅의 경우
        DebugHelper.debug('일반 채팅 메시지 업데이트 시작: postId=$postId', tag: 'Vote');
        
        final messageQuery = await widget.chatDocument!.reference
            .collection('messages')
            .where('vote_post_id', isEqualTo: postId)
            .where('message_type', isEqualTo: 'vote_request')
            .limit(1)
            .get();
        
        DebugHelper.debug('쿼리 결과: ${messageQuery.docs.length}개 메시지 발견', tag: 'Vote');
        
        if (messageQuery.docs.isNotEmpty) {
          final messageDoc = messageQuery.docs.first;
          DebugHelper.debug('메시지 ID: ${messageDoc.id}', tag: 'Vote');
          
          // 개별 사용자의 투표 정보를 저장할 맵 가져오기 또는 생성
          final currentUserVotes = Map<String, dynamic>.from(
            messageDoc.data()['user_votes'] ?? {}
          );
          
          // 현재 사용자의 투표 정보 추가
          currentUserVotes[currentUserUid] = {
            'option': option,
            'voted_at': FieldValue.serverTimestamp(),
          };
          
          // 메시지 문서 업데이트
          await messageDoc.reference.update({
            'user_votes': currentUserVotes,
            // 전체 투표 상태도 업데이트 (모든 사용자가 투표했는지 확인 필요)
            'vote_status': 'participated', // 최소 한 명이 투표한 상태
            'last_vote_update': FieldValue.serverTimestamp(),
          });
          
          DebugHelper.debug('메시지 업데이트 완료', tag: 'Vote');
        } else {
          DebugHelper.warning('해당 postId의 메시지를 찾을 수 없음', tag: 'Vote');
        }
      } else {
        // AI 채팅의 경우
        DebugHelper.debug('AI 채팅 메시지 업데이트 시작: postId=$postId', tag: 'Vote');
        
        // AI 채팅방 ID 생성
        final aiChatId = 'ai_assistant_$currentUserUid';
        DebugHelper.debug('AI 채팅방 ID: $aiChatId', tag: 'Vote');
        
        final aiChatRef = FirebaseFirestore.instance.collection('chats').doc(aiChatId);
        
        // 먼저 채팅방이 존재하는지 확인
        final chatExists = await aiChatRef.get();
        DebugHelper.debug('AI 채팅방 존재 여부: ${chatExists.exists}', tag: 'Vote');
        
        if (!chatExists.exists) {
          DebugHelper.warning('AI 채팅방이 존재하지 않음', tag: 'Vote');
          return;
        }
        
        // 모든 vote_request 메시지를 가져와서 확인
        final allMessagesQuery = await aiChatRef
            .collection('messages')
            .where('message_type', isEqualTo: 'vote_request')
            .get();
        
        DebugHelper.debug('전체 vote_request 메시지 수: ${allMessagesQuery.docs.length}', tag: 'Vote');
        
        for (final doc in allMessagesQuery.docs) {
          final data = doc.data();
          DebugHelper.debug('메시지 확인 - ID: ${doc.id}, vote_post_id: ${data['vote_post_id']}', tag: 'Vote');
        }
        
        final messageQuery = await aiChatRef
            .collection('messages')
            .where('vote_post_id', isEqualTo: postId)
            .where('message_type', isEqualTo: 'vote_request')
            .limit(1)
            .get();
        
        DebugHelper.debug('AI 채팅 쿼리 결과: ${messageQuery.docs.length}개 메시지 발견', tag: 'Vote');
        
        if (messageQuery.docs.isNotEmpty) {
          final messageDoc = messageQuery.docs.first;
          final messageData = messageDoc.data();
          DebugHelper.debug('AI 채팅 메시지 ID: ${messageDoc.id}', tag: 'Vote');
          DebugHelper.debug('현재 user_votes: ${messageData['user_votes']}', tag: 'Vote');
          
          // 개별 사용자의 투표 정보를 저장할 맵 가져오기 또는 생성
          final currentUserVotes = Map<String, dynamic>.from(
            messageDoc.data()['user_votes'] ?? {}
          );
          
          // 현재 사용자의 투표 정보 추가
          currentUserVotes[currentUserUid] = {
            'option': option,
            'voted_at': FieldValue.serverTimestamp(),
          };
          
          DebugHelper.debug('업데이트할 user_votes: $currentUserVotes', tag: 'Vote');
          
          // 메시지 문서 업데이트
          await messageDoc.reference.update({
            'user_votes': currentUserVotes,
            'vote_status': 'participated',
            'last_vote_update': FieldValue.serverTimestamp(),
          });
          
          DebugHelper.debug('AI 채팅 메시지 업데이트 완료', tag: 'Vote');
          
          // 업데이트 확인
          final updatedDoc = await messageDoc.reference.get();
          final updatedData = updatedDoc.data();
          DebugHelper.debug('업데이트 후 user_votes: ${updatedData?['user_votes']}', tag: 'Vote');
        } else {
          DebugHelper.warning('AI 채팅에서 해당 postId의 메시지를 찾을 수 없음', tag: 'Vote');
        }
      }
      
      BotToast.showText(text: '투표가 완료되었습니다!');
    } catch (e) {
      BotToast.showText(text: '투표 처리 중 오류가 발생했습니다: $e');
    }
  }

  ChatTheme _buildChatTheme() {
    return DefaultChatTheme(
      backgroundColor: VersusColors.backgroundPrimary,
      primaryColor: VersusColors.backgroundSecondary,
      secondaryColor: VersusColors.backgroundSecondary,
      inputBackgroundColor: VersusColors.backgroundSecondary,
      inputTextColor: VersusColors.textPrimary,
      inputTextDecoration: InputDecoration(
        filled: true,
        fillColor: VersusColors.backgroundPrimary,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: VersusColors.borderLight,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: VersusColors.borderLight,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: VersusColors.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        hintText: '메시지를 입력하세요...',
        hintStyle: VersusTextStyles.bodyMedium.copyWith(
          color: VersusColors.textSecondary,
        ),
      ),
      emptyChatPlaceholderTextStyle: VersusTextStyles.bodyLarge.copyWith(
        color: VersusColors.textSecondary,
      ),
      inputTextStyle: VersusTextStyles.bodyMedium,
      dateDividerTextStyle: VersusTextStyles.labelSmall.copyWith(
        color: VersusColors.textSecondary,
      ),
      messageBorderRadius: 20,
      messageInsetsHorizontal: 16,
      messageInsetsVertical: 12,
      receivedMessageBodyTextStyle: VersusTextStyles.bodyMedium.copyWith(
        color: VersusColors.textPrimary,
      ),
      receivedMessageCaptionTextStyle: VersusTextStyles.labelSmall.copyWith(
        color: VersusColors.textSecondary,
      ),
      receivedMessageLinkDescriptionTextStyle: VersusTextStyles.bodySmall.copyWith(
        color: VersusColors.textSecondary,
      ),
      receivedMessageLinkTitleTextStyle: VersusTextStyles.bodySmall.copyWith(
        color: VersusColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      sentMessageBodyTextStyle: VersusTextStyles.bodyMedium.copyWith(
        color: Colors.white,
      ),
      sentMessageCaptionTextStyle: VersusTextStyles.labelSmall.copyWith(
        color: Colors.white70,
      ),
      sentMessageLinkDescriptionTextStyle: VersusTextStyles.bodySmall.copyWith(
        color: Colors.white70,
      ),
      sentMessageLinkTitleTextStyle: VersusTextStyles.bodySmall.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      userAvatarNameColors: [
        VersusColors.primary,
        VersusColors.success,
        VersusColors.warning,
        VersusColors.error,
      ],
      userAvatarTextStyle: VersusTextStyles.labelMedium.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      userNameTextStyle: VersusTextStyles.labelSmall.copyWith(
        fontWeight: FontWeight.w600,
      ),
      sendButtonIcon: const Icon(
        Icons.send_rounded,
        color: Colors.white,
      ),
      attachmentButtonIcon: const Icon(
        Icons.attach_file,
        color: Colors.white,
      ),
      inputBorderRadius: BorderRadius.circular(24),
      sendButtonMargin: EdgeInsets.zero,
      attachmentButtonMargin: const EdgeInsets.only(right: 8),
      inputMargin: const EdgeInsets.all(12),
      inputPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      inputContainerDecoration: BoxDecoration(
        color: VersusColors.backgroundSecondary,
        boxShadow: [
          BoxShadow(
            blurRadius: 3.0,
            color: const Color(0x33000000),
            offset: const Offset(0.0, -1.0),
          ),
        ],
      ),
    );
  }
}

/// 한국어 지원을 위한 L10n 클래스
class ChatL10nKo extends ChatL10n {
  const ChatL10nKo() : super(
    attachmentButtonAccessibilityLabel: '첨부파일 추가',
    emptyChatPlaceholder: '아직 메시지가 없습니다',
    fileButtonAccessibilityLabel: '파일',
    inputPlaceholder: '메시지를 입력하세요...',
    sendButtonAccessibilityLabel: '전송',
    unreadMessagesLabel: '읽지 않은 메시지',
    and: '님과',
    isTyping: '님이 입력 중...',
    others: '외',
  );
}

/// 한국어 Asset Picker 텍스트 델리게이트
class KoreanAssetPickerTextDelegate extends AssetPickerTextDelegate {
  const KoreanAssetPickerTextDelegate();

  @override
  String get languageCode => 'ko';

  @override
  String get confirm => '확인';

  @override
  String get cancel => '취소';

  @override
  String get edit => '편집';

  @override
  String get gifIndicator => 'GIF';

  @override
  String get loadFailed => '로드 실패';

  @override
  String get original => '원본';

  @override
  String get preview => '미리보기';

  @override
  String get select => '선택';

  @override
  String get emptyList => '빈 목록';

  @override
  String get unSupportedAssetType => '지원하지 않는 파일 형식입니다.';

  @override
  String get unableToAccessAll => '모든 미디어에 접근할 수 없습니다';

  @override
  String get viewingLimitedAssetsTip => '앱이 접근할 수 있는 미디어만 볼 수 있습니다.';

  @override
  String get changeAccessibleLimitedAssets => '접근 가능한 미디어를 업데이트하려면 클릭하세요';

  @override
  String get accessAllTip => '앱이 일부 미디어에만 접근할 수 있습니다. 시스템 설정으로 이동하여 모든 미디어에 대한 접근을 허용하세요.';

  @override
  String get goToSystemSettings => '시스템 설정으로 이동';

  @override
  String get accessLimitedAssets => '제한된 접근으로 계속하기';

  @override
  String get accessiblePathName => '접근 가능한 미디어';

  @override
  String get sTypeAudioLabel => '오디오';

  @override
  String get sTypeImageLabel => '이미지';

  @override
  String get sTypeVideoLabel => '비디오';

  @override
  String get sTypeOtherLabel => '기타';

  @override
  String get sActionPlayHint => '재생';

  @override
  String get sActionPreviewHint => '미리보기';

  @override
  String get sActionSelectHint => '선택';

  @override
  String get sActionSwitchPathLabel => '경로 변경';

  @override
  String get sActionUseCameraHint => '카메라 사용';

  @override
  String get sNameDurationLabel => '재생 시간';

  @override
  String get sUnitAssetCountLabel => '개수';
}