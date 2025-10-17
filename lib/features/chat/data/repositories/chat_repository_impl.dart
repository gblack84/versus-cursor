import 'dart:io';

import '../../domain/repositories/i_chat_repository.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../datasources/i_chat_remote_datasource.dart';
import '../dto/chat_dto.dart';
import '../dto/message_dto.dart';

/// Implementation of chat repository with Clean Architecture v4.0
///
/// **Dependency Inversion Principle**:
/// - Repository depends on Datasource interface (not implementation)
/// - Datasource handles all Firestore interactions
/// - Repository only handles DTO ↔ Domain conversion
///
/// **Migration from v3.0**:
/// - Removed Singleton pattern → DI manages instance
/// - Removed Firestore direct access → Datasource layer
/// - Simplified to DTO ↔ Domain conversion only
class ChatRepositoryImpl implements IChatRepository {
  final IChatRemoteDatasource _remoteDatasource;

  ChatRepositoryImpl({
    required IChatRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  // MIGRATED: Chats queries (Clean Architecture v4.0)
  @override
  Future<int> queryChatsCount({
    required String userId,
    int limit = -1,
  }) =>
      _remoteDatasource.queryChatsCount(
        userId: userId,
        limit: limit,
      );

  @override
  Stream<List<Chat>> queryChats({
    required String userId,
    int limit = 50,
    String? orderBy,
    bool descending = true,
  }) =>
      _remoteDatasource
          .queryChats(
            userId: userId,
            limit: limit,
            orderBy: orderBy,
            descending: descending,
          )
          .map((dtos) => dtos.map((dto) => dto.toDomain()).toList());

  // MIGRATED: Messages queries (Clean Architecture v4.0)
  @override
  Future<int> queryMessagesCount({
    required String chatId,
    int limit = -1,
  }) =>
      _remoteDatasource.queryMessagesCount(
        chatId: chatId,
        limit: limit,
      );

  /// Query messages by chatId (Clean Architecture v4.0)
  ///
  /// Repository에서 DTO → Domain 변환만 수행
  /// Firestore 접근은 Datasource에 위임
  @override
  Stream<List<Message>> queryMessagesByChatId({
    required String chatId,
    int limit = 30,
    String? orderBy,
    bool descending = true,
  }) =>
      _remoteDatasource
          .queryMessagesByChatId(
            chatId: chatId,
            limit: limit,
            orderBy: orderBy,
            descending: descending,
          )
          .map((dtos) => dtos.map((dto) => dto.toDomain()).toList());

  /// Load more messages before a specific message (Clean Architecture v4.0)
  ///
  /// 페이지네이션: messageId 이전의 메시지들을 로드
  /// Datasource에서 DocumentSnapshot 처리, Repository는 변환만 수행
  @override
  Future<List<Message>> queryMessagesBeforeMessageId({
    required String chatId,
    required String lastMessageId,
    int limit = 30,
  }) async {
    final messageDtos = await _remoteDatasource.queryMessagesBeforeMessageId(
      chatId: chatId,
      lastMessageId: lastMessageId,
      limit: limit,
    );

    return messageDtos.map((dto) => dto.toDomain()).toList();
  }

  // CRUD operations (Clean Architecture v4.0: DTO ↔ Domain conversion)
  @override
  Future<Chat?> getChat(String chatId) async {
    final chatDto = await _remoteDatasource.getChat(chatId);
    return chatDto?.toDomain();
  }

  @override
  Future<void> createChat(Chat chat) async {
    final chatDto = ChatDto.fromDomain(chat);
    await _remoteDatasource.createChat(chatDto);
  }

  @override
  Future<void> updateChat(Chat chat) async {
    final chatDto = ChatDto.fromDomain(chat);
    await _remoteDatasource.updateChat(chatDto);
  }

  @override
  Future<void> deleteChat(String chatId) async {
    await _remoteDatasource.deleteChat(chatId);
  }

  // Message operations (Clean Architecture v4.0: DTO ↔ Domain conversion)
  @override
  Future<void> sendMessage(String chatId, Message message) async {
    final messageDto = MessageDto.fromDomain(message);
    await _remoteDatasource.sendMessage(chatId, messageDto);
  }

  @override
  Future<void> deleteMessage(String chatId, String messageId) async {
    await _remoteDatasource.deleteMessage(chatId, messageId);
  }

  // Media upload operations (Clean Architecture v4.0)
  @override
  Future<String> uploadMedia({
    required String chatId,
    required String messageId,
    required File file,
    required String mediaType,
  }) async {
    return await _remoteDatasource.uploadMedia(
      chatId: chatId,
      messageId: messageId,
      file: file,
      mediaType: mediaType,
    );
  }
}
