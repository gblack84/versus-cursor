import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/firebase/firestore/utils/firestore_util.dart';
import '/backend/backend.dart' show queryCollection, queryCollectionOnce, queryCollectionCount;
import '/features/voting/domain/models/votecounts_model.dart';
import '/features/voting/domain/models/vote_expansion_requests_model.dart';
import '/features/voting/domain/models/rankings_model.dart';
import '/features/voting/domain/repositories/posts_data_source.dart';
import '/features/voting/domain/models/weights_model.dart';

/// Implementation of voting repository with migrated backend query functions
class VotingRepositoryImpl {
  static VotingRepositoryImpl? _instance;
  static VotingRepositoryImpl get instance => _instance ??= VotingRepositoryImpl._();
  
  final PostsDataSource? _postsDataSource;
  
  VotingRepositoryImpl._() : _postsDataSource = null;
  
  // Constructor for dependency injection
  VotingRepositoryImpl.withDataSource(this._postsDataSource);

  // MIGRATED: Votecounts queries (lines 256-294 from backend.dart)
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

  // MIGRATED: VoteExpansionRequests queries (lines 336-374 from backend.dart)
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

  // MIGRATED: Rankings queries (lines 687-722 from backend.dart)
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

  // MIGRATED: RankedPosts queries - Now using PostsDataSource interface
  // These methods now delegate to PostsDataSource to avoid direct dependency
  // on Posts feature's data layer
  
  Stream<List<RankedPostsData>> getRankedPosts({
    String? category,
    int? limit,
  }) {
    if (_postsDataSource != null) {
      return _postsDataSource!.getRankedPosts(
        category: category,
        limit: limit,
      );
    }
    // Fallback to empty stream if data source not provided
    return Stream.value([]);
  }
  
  Future<RankedPostsData?> getRankedPostById(String postId) async {
    if (_postsDataSource != null) {
      return _postsDataSource!.getRankedPostById(postId);
    }
    return null;
  }

  // MIGRATED: Weights queries (lines 875-913 from backend.dart)
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
}