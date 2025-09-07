import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/firebase/firestore/utils/firestore_util.dart';
import '/backend/backend.dart' show queryCollection, queryCollectionOnce, queryCollectionCount;
import '/features/voting/domain/models/votecounts_model.dart';
import '/features/voting/domain/models/vote_expansion_requests_model.dart';
import '/features/voting/domain/models/rankings_model.dart';
import '/backend/models/post/ranked_posts_model.dart';
import '/features/voting/domain/models/weights_model.dart';

/// Implementation of voting repository with migrated backend query functions
class VotingRepositoryImpl {
  static VotingRepositoryImpl? _instance;
  static VotingRepositoryImpl get instance => _instance ??= VotingRepositoryImpl._();
  
  VotingRepositoryImpl._();

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

  // MIGRATED: RankedPosts queries (lines 724-762 from backend.dart)
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