import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/firebase_auth/auth_util.dart';

import '../core_exports.dart';
import 'schema/util/firestore_util.dart';

import 'schema/users_model.dart';
import 'schema/notification_model.dart';
import 'schema/settings_model.dart';
import 'schema/posts_model.dart';
import 'schema/images_model.dart';
import 'schema/votecounts_model.dart';
import 'schema/video_model.dart';
import 'schema/vote_expansion_requests_model.dart';
import 'schema/comments_model.dart';
import 'schema/likes_model.dart';
import 'schema/dislikes_model.dart';
import 'schema/chats_model.dart';
import 'schema/friends_list_model.dart';
import 'schema/messages_model.dart';
import 'schema/group_chats_model.dart';
import 'schema/group_messages_model.dart';
import 'schema/rankings_model.dart';
import 'schema/ranked_posts_model.dart';
import '/features/search/domain/models/search_history_model.dart';
import 'schema/notifications_model.dart';
import 'schema/interest_model.dart';
import 'schema/weights_model.dart';
import 'schema/user_contents_model.dart';
import 'schema/poll_details_model.dart';
import 'schema/feed_details_model.dart';
import 'schema/content_comments_model.dart';
import 'schema/contents_likes_model.dart';
import 'schema/contents_interests_model.dart';
import 'schema/contents_shares_model.dart';
import 'schema/point_model.dart';
import 'schema/premium_users_model.dart';
import 'schema/transactions_model.dart';
import 'schema/client_model.dart';
import 'schema/jops_name_model.dart';
import 'schema/jops_category_model.dart';
import 'schema/chat_interest_jops_model.dart';
import 'schema/chat_history_model.dart';
import 'schema/characters_model.dart';
import 'schema/encodings_model.dart';

export 'dart:async' show StreamSubscription;
export 'package:cloud_firestore/cloud_firestore.dart' hide Order;
export 'package:firebase_core/firebase_core.dart';
export 'schema/index.dart';
export 'schema/util/firestore_util.dart';
export 'schema/util/schema_util.dart';

export 'schema/users_model.dart';
export 'schema/notification_model.dart';
export 'schema/settings_model.dart';
export 'schema/posts_model.dart';
export 'schema/images_model.dart';
export 'schema/votecounts_model.dart';
export 'schema/video_model.dart';
export 'schema/vote_expansion_requests_model.dart';
export 'schema/comments_model.dart';
export 'schema/likes_model.dart';
export 'schema/dislikes_model.dart';
export 'schema/chats_model.dart';
export 'schema/friends_list_model.dart';
export 'schema/messages_model.dart';
export 'schema/group_chats_model.dart';
export 'schema/group_messages_model.dart';
export 'schema/rankings_model.dart';
export 'schema/ranked_posts_model.dart';
export '/features/search/domain/models/search_history_model.dart';
export 'schema/notifications_model.dart';
export 'schema/interest_model.dart';
export 'schema/weights_model.dart';
export 'schema/user_contents_model.dart';
export 'schema/poll_details_model.dart';
export 'schema/feed_details_model.dart';
export 'schema/content_comments_model.dart';
export 'schema/contents_likes_model.dart';
export 'schema/contents_interests_model.dart';
export 'schema/contents_shares_model.dart';
export 'schema/point_model.dart';
export 'schema/premium_users_model.dart';
export 'schema/transactions_model.dart';
export 'schema/client_model.dart';
export 'schema/jops_name_model.dart';
export 'schema/jops_category_model.dart';
export 'schema/chat_interest_jops_model.dart';
export 'schema/chat_history_model.dart';
export 'schema/characters_model.dart';
export 'schema/encodings_model.dart';
export 'schema/image_moderation_model.dart';

/// Functions to query UsersModels (as a Stream and as a Future).
Future<int> queryUsersModelCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      UsersModel.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<UsersModel>> queryUsersModel({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      UsersModel.collection,
      UsersModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<UsersModel>> queryUsersModelOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      UsersModel.collection,
      UsersModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query NotificationRecords (as a Stream and as a Future).
Future<int> queryNotificationModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      NotificationModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<NotificationModel>> queryNotificationModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      NotificationModel.collection(parent),
      NotificationModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<NotificationModel>> queryNotificationModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      NotificationModel.collection(parent),
      NotificationModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query SettingsRecords (as a Stream and as a Future).
Future<int> querySettingsModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      SettingsModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<SettingsModel>> querySettingsModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      SettingsModel.collection(parent),
      SettingsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<SettingsModel>> querySettingsModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      SettingsModel.collection(parent),
      SettingsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query PostsModels (as a Stream and as a Future).
Future<int> queryPostsModelCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      PostsModel.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<PostsModel>> queryPostsModel({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      PostsModel.collection,
      PostsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<PostsModel>> queryPostsModelOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      PostsModel.collection,
      PostsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query ImagesRecords (as a Stream and as a Future).
Future<int> queryImagesModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      ImagesModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<ImagesModel>> queryImagesModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      ImagesModel.collection(parent),
      ImagesModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<ImagesModel>> queryImagesModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      ImagesModel.collection(parent),
      ImagesModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query VotecountsRecords (as a Stream and as a Future).
Future<int> queryVotecountsModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      VotecountsModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<VotecountsModel>> queryVotecountsModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      VotecountsModel.collection(parent),
      VotecountsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<VotecountsModel>> queryVotecountsModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      VotecountsModel.collection(parent),
      VotecountsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query VideoRecords (as a Stream and as a Future).
Future<int> queryVideoModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      VideoModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<VideoModel>> queryVideoModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      VideoModel.collection(parent),
      VideoModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<VideoModel>> queryVideoModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      VideoModel.collection(parent),
      VideoModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query VoteExpansionRequestsRecords (as a Stream and as a Future).
Future<int> queryVoteExpansionRequestsModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      VoteExpansionRequestsModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<VoteExpansionRequestsModel>> queryVoteExpansionRequestsModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      VoteExpansionRequestsModel.collection(parent),
      VoteExpansionRequestsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<VoteExpansionRequestsModel>> queryVoteExpansionRequestsModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      VoteExpansionRequestsModel.collection(parent),
      VoteExpansionRequestsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query CommentsModels (as a Stream and as a Future).
Future<int> queryCommentsModelCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      CommentsModel.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<CommentsModel>> queryCommentsModel({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      CommentsModel.collection,
      CommentsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<CommentsModel>> queryCommentsModelOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      CommentsModel.collection,
      CommentsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query LikesModels (as a Stream and as a Future).
Future<int> queryLikesModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      LikesModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<LikesModel>> queryLikesModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      LikesModel.collection(parent),
      LikesModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<LikesModel>> queryLikesModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      LikesModel.collection(parent),
      LikesModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query DislikesModels (as a Stream and as a Future).
Future<int> queryDislikesModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      DislikesModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<DislikesModel>> queryDislikesModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      DislikesModel.collection(parent),
      DislikesModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<DislikesModel>> queryDislikesModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      DislikesModel.collection(parent),
      DislikesModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query ChatsModels (as a Stream and as a Future).
Future<int> queryChatsModelCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      ChatsModel.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<ChatsModel>> queryChatsModel({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      ChatsModel.collection,
      ChatsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<ChatsModel>> queryChatsModelOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      ChatsModel.collection,
      ChatsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query FriendsListModels (as a Stream and as a Future).
Future<int> queryFriendsListModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      FriendsListModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<FriendsListModel>> queryFriendsListModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      FriendsListModel.collection(parent),
      FriendsListModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<FriendsListModel>> queryFriendsListModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      FriendsListModel.collection(parent),
      FriendsListModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query MessagesModels (as a Stream and as a Future).
Future<int> queryMessagesModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      MessagesModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<MessagesModel>> queryMessagesModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      MessagesModel.collection(parent),
      MessagesModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<MessagesModel>> queryMessagesModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      MessagesModel.collection(parent),
      MessagesModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query GroupChatsModels (as a Stream and as a Future).
Future<int> queryGroupChatsModelCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      GroupChatsModel.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<GroupChatsModel>> queryGroupChatsModel({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      GroupChatsModel.collection,
      GroupChatsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<GroupChatsModel>> queryGroupChatsModelOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      GroupChatsModel.collection,
      GroupChatsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query GroupMessagesModels (as a Stream and as a Future).
Future<int> queryGroupMessagesModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      GroupMessagesModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<GroupMessagesModel>> queryGroupMessagesModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      GroupMessagesModel.collection(parent),
      GroupMessagesModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<GroupMessagesModel>> queryGroupMessagesModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      GroupMessagesModel.collection(parent),
      GroupMessagesModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query RankingsModels (as a Stream and as a Future).
Future<int> queryRankingsModelCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      RankingsModel.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<RankingsModel>> queryRankingsModel({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      RankingsModel.collection,
      RankingsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<RankingsModel>> queryRankingsModelOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      RankingsModel.collection,
      RankingsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query RankedPostsModels (as a Stream and as a Future).
Future<int> queryRankedPostsModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      RankedPostsModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<RankedPostsModel>> queryRankedPostsModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      RankedPostsModel.collection(parent),
      RankedPostsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<RankedPostsModel>> queryRankedPostsModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      RankedPostsModel.collection(parent),
      RankedPostsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query SearchesModels (as a Stream and as a Future).
Future<int> querySearchesModelCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      SearchesModel.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<SearchesModel>> querySearchesModel({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      SearchesModel.collection,
      SearchesModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<SearchesModel>> querySearchesModelOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      SearchesModel.collection,
      SearchesModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query NotificationsModels (as a Stream and as a Future).
Future<int> queryNotificationsModelCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      NotificationsModel.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<NotificationsModel>> queryNotificationsModel({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      NotificationsModel.collection,
      NotificationsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<NotificationsModel>> queryNotificationsModelOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      NotificationsModel.collection,
      NotificationsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query InterestModels (as a Stream and as a Future).
Future<int> queryInterestModelCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      InterestModel.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<InterestModel>> queryInterestModel({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      InterestModel.collection,
      InterestModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<InterestModel>> queryInterestModelOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      InterestModel.collection,
      InterestModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query WeightsRecords (as a Stream and as a Future).
Future<int> queryWeightsModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      WeightsModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<WeightsModel>> queryWeightsModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      WeightsModel.collection(parent),
      WeightsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<WeightsModel>> queryWeightsModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      WeightsModel.collection(parent),
      WeightsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query UserContentsModels (as a Stream and as a Future).
Future<int> queryUserContentsModelCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      UserContentsModel.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<UserContentsModel>> queryUserContentsModel({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      UserContentsModel.collection,
      UserContentsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<UserContentsModel>> queryUserContentsModelOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      UserContentsModel.collection,
      UserContentsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query PollDetailsRecords (as a Stream and as a Future).
Future<int> queryPollDetailsModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      PollDetailsModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<PollDetailsModel>> queryPollDetailsModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      PollDetailsModel.collection(parent),
      PollDetailsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<PollDetailsModel>> queryPollDetailsModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      PollDetailsModel.collection(parent),
      PollDetailsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query FeedDetailsRecords (as a Stream and as a Future).
Future<int> queryFeedDetailsModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      FeedDetailsModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<FeedDetailsModel>> queryFeedDetailsModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      FeedDetailsModel.collection(parent),
      FeedDetailsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<FeedDetailsModel>> queryFeedDetailsModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      FeedDetailsModel.collection(parent),
      FeedDetailsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query ContentCommentsModels (as a Stream and as a Future).
Future<int> queryContentCommentsModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      ContentCommentsModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<ContentCommentsModel>> queryContentCommentsModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      ContentCommentsModel.collection(parent),
      ContentCommentsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<ContentCommentsModel>> queryContentCommentsModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      ContentCommentsModel.collection(parent),
      ContentCommentsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query ContentsLikesModels (as a Stream and as a Future).
Future<int> queryContentsLikesModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      ContentsLikesModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<ContentsLikesModel>> queryContentsLikesModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      ContentsLikesModel.collection(parent),
      ContentsLikesModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<ContentsLikesModel>> queryContentsLikesModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      ContentsLikesModel.collection(parent),
      ContentsLikesModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query ContentsInterestsRecords (as a Stream and as a Future).
Future<int> queryContentsInterestsModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      ContentsInterestsModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<ContentsInterestsModel>> queryContentsInterestsModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      ContentsInterestsModel.collection(parent),
      ContentsInterestsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<ContentsInterestsModel>> queryContentsInterestsModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      ContentsInterestsModel.collection(parent),
      ContentsInterestsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query ContentsSharesRecords (as a Stream and as a Future).
Future<int> queryContentsSharesModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      ContentsSharesModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<ContentsSharesModel>> queryContentsSharesModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      ContentsSharesModel.collection(parent),
      ContentsSharesModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<ContentsSharesModel>> queryContentsSharesModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      ContentsSharesModel.collection(parent),
      ContentsSharesModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query PointModels (as a Stream and as a Future).
Future<int> queryPointModelCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      PointModel.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<PointModel>> queryPointModel({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      PointModel.collection,
      PointModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<PointModel>> queryPointModelOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      PointModel.collection,
      PointModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query PremiumUsersModels (as a Stream and as a Future).
Future<int> queryPremiumUsersModelCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      PremiumUsersModel.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<PremiumUsersModel>> queryPremiumUsersModel({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      PremiumUsersModel.collection,
      PremiumUsersModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<PremiumUsersModel>> queryPremiumUsersModelOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      PremiumUsersModel.collection,
      PremiumUsersModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query TransactionsModels (as a Stream and as a Future).
Future<int> queryTransactionsModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      TransactionsModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<TransactionsModel>> queryTransactionsModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      TransactionsModel.collection(parent),
      TransactionsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<TransactionsModel>> queryTransactionsModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      TransactionsModel.collection(parent),
      TransactionsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query ClientRecords (as a Stream and as a Future).
Future<int> queryClientModelCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      ClientModel.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<ClientModel>> queryClientModel({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      ClientModel.collection,
      ClientModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<ClientModel>> queryClientModelOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      ClientModel.collection,
      ClientModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query JopsNameModels (as a Stream and as a Future).
Future<int> queryJopsNameModelCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      JopsNameModel.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<JopsNameModel>> queryJopsNameModel({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      JopsNameModel.collection,
      JopsNameModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<JopsNameModel>> queryJopsNameModelOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      JopsNameModel.collection,
      JopsNameModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query JopsCategoryModels (as a Stream and as a Future).
Future<int> queryJopsCategoryModelCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      JopsCategoryModel.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<JopsCategoryModel>> queryJopsCategoryModel({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      JopsCategoryModel.collection,
      JopsCategoryModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<JopsCategoryModel>> queryJopsCategoryModelOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      JopsCategoryModel.collection,
      JopsCategoryModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query ChatInterestJopsRecords (as a Stream and as a Future).
Future<int> queryChatInterestJopsModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      ChatInterestJopsModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<ChatInterestJopsModel>> queryChatInterestJopsModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      ChatInterestJopsModel.collection(parent),
      ChatInterestJopsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<ChatInterestJopsModel>> queryChatInterestJopsModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      ChatInterestJopsModel.collection(parent),
      ChatInterestJopsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query ChatHistoryRecords (as a Stream and as a Future).
Future<int> queryChatHistoryModelCount({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      ChatHistoryModel.collection(parent),
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<ChatHistoryModel>> queryChatHistoryModel({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      ChatHistoryModel.collection(parent),
      ChatHistoryModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<ChatHistoryModel>> queryChatHistoryModelOnce({
  DocumentReference? parent,
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      ChatHistoryModel.collection(parent),
      ChatHistoryModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query CharactersModels (as a Stream and as a Future).
Future<int> queryCharactersModelCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      CharactersModel.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<CharactersModel>> queryCharactersModel({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      CharactersModel.collection,
      CharactersModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<CharactersModel>> queryCharactersModelOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      CharactersModel.collection,
      CharactersModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// Functions to query EncodingsModels (as a Stream and as a Future).
Future<int> queryEncodingsModelCount({
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) =>
    queryCollectionCount(
      EncodingsModel.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<EncodingsModel>> queryEncodingsModel({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      EncodingsModel.collection,
      EncodingsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<EncodingsModel>> queryEncodingsModelOnce({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollectionOnce(
      EncodingsModel.collection,
      EncodingsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<int> queryCollectionCount(
  Query collection, {
  Query Function(Query)? queryBuilder,
  int limit = -1,
}) {
  final builder = queryBuilder ?? (q) => q;
  var query = builder(collection);
  if (limit > 0) {
    query = query.limit(limit);
  }

  return query.count().get().then((value) => value.count!).catchError((err) {
    print('Error querying $collection: $err');
    return 0;
  });
}

Stream<List<T>> queryCollection<T>(
  Query collection,
  RecordBuilder<T> recordBuilder, {
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) {
  final builder = queryBuilder ?? (q) => q;
  var query = builder(collection);
  if (limit > 0 || singleRecord) {
    query = query.limit(singleRecord ? 1 : limit);
  }
  return query.snapshots().handleError((err) {
    print('Error querying $collection: $err');
  }).map((s) => s.docs
      .map(
        (d) => safeGet(
          () => recordBuilder(d),
          (e) => print('Error serializing doc ${d.reference.path}:\n$e'),
        ),
      )
      .where((d) => d != null)
      .map((d) => d!)
      .toList());
}

Future<List<T>> queryCollectionOnce<T>(
  Query collection,
  RecordBuilder<T> recordBuilder, {
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) {
  final builder = queryBuilder ?? (q) => q;
  var query = builder(collection);
  if (limit > 0 || singleRecord) {
    query = query.limit(singleRecord ? 1 : limit);
  }
  return query.get().then((s) => s.docs
      .map(
        (d) => safeGet(
          () => recordBuilder(d),
          (e) => print('Error serializing doc ${d.reference.path}:\n$e'),
        ),
      )
      .where((d) => d != null)
      .map((d) => d!)
      .toList());
}

Filter filterIn(String field, List? list) => (list?.isEmpty ?? true)
    ? Filter(field, whereIn: null)
    : Filter(field, whereIn: list);

Filter filterArrayContainsAny(String field, List? list) =>
    (list?.isEmpty ?? true)
        ? Filter(field, arrayContainsAny: null)
        : Filter(field, arrayContainsAny: list);

extension QueryExtension on Query {
  Query whereIn(String field, List? list) => (list?.isEmpty ?? true)
      ? where(field, whereIn: null)
      : where(field, whereIn: list);

  Query whereNotIn(String field, List? list) => (list?.isEmpty ?? true)
      ? where(field, whereNotIn: null)
      : where(field, whereNotIn: list);

  Query whereArrayContainsAny(String field, List? list) =>
      (list?.isEmpty ?? true)
          ? where(field, arrayContainsAny: null)
          : where(field, arrayContainsAny: list);
}

class AppFirestorePage<T> {
  final List<T> data;
  final Stream<List<T>>? dataStream;
  final QueryDocumentSnapshot? nextPageMarker;

  AppFirestorePage(this.data, this.dataStream, this.nextPageMarker);
}

Future<AppFirestorePage<T>> queryCollectionPage<T>(
  Query collection,
  RecordBuilder<T> recordBuilder, {
  Query Function(Query)? queryBuilder,
  DocumentSnapshot? nextPageMarker,
  required int pageSize,
  required bool isStream,
}) async {
  final builder = queryBuilder ?? (q) => q;
  var query = builder(collection).limit(pageSize);
  if (nextPageMarker != null) {
    query = query.startAfterDocument(nextPageMarker);
  }
  Stream<QuerySnapshot>? docSnapshotStream;
  QuerySnapshot docSnapshot;
  if (isStream) {
    docSnapshotStream = query.snapshots();
    docSnapshot = await docSnapshotStream.first;
  } else {
    docSnapshot = await query.get();
  }
  final getDocs = (QuerySnapshot s) => s.docs
      .map(
        (d) => safeGet(
          () => recordBuilder(d),
          (e) => print('Error serializing doc ${d.reference.path}:\n$e'),
        ),
      )
      .where((d) => d != null)
      .map((d) => d!)
      .toList();
  final data = getDocs(docSnapshot);
  final dataStream = docSnapshotStream?.map(getDocs);
  final nextPageToken = docSnapshot.docs.isEmpty ? null : docSnapshot.docs.last;
  return AppFirestorePage(data, dataStream, nextPageToken);
}

// Creates a Firestore document representing the logged in user if it doesn't yet exist
Future maybeCreateUser(User user) async {
  final userRecord = UsersModel.collection.doc(user.uid);
  final userExists = await userRecord.get().then((u) => u.exists);
  if (userExists) {
    currentUserDocument = await UsersModel.getDocumentOnce(userRecord);
    return;
  }

  final userData = createUsersModelData(
    email: user.email ??
        FirebaseAuth.instance.currentUser?.email ??
        user.providerData.firstOrNull?.email,
    displayName:
        user.displayName ?? FirebaseAuth.instance.currentUser?.displayName,
    photoUrl: user.photoURL,
    uid: user.uid,
    phoneNumber: user.phoneNumber,
    createdTime: getCurrentTimestamp(),
  );

  await userRecord.set(userData);
  currentUserDocument = UsersModel.getDocumentFromData(userData, userRecord);
}

Future updateUserDocument({String? email}) async {
  await currentUserDocument?.reference
      .update(createUsersModelData(email: email));
}
