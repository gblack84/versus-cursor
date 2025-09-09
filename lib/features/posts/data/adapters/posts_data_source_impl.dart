import 'package:cloud_firestore/cloud_firestore.dart';
import '/features/voting/domain/repositories/i_voting_repository.dart';
import '../models/ranked_posts_model.dart';

/// Implementation of PostsDataSource for voting feature
/// 
/// This adapter provides ranked posts data to voting feature
/// without exposing Posts feature's internal data models
class PostsDataSourceImpl implements PostsDataSource {
  static PostsDataSourceImpl? _instance;
  static PostsDataSourceImpl get instance => _instance ??= PostsDataSourceImpl._();
  
  PostsDataSourceImpl._();

  @override
  Stream<List<RankedPostsData>> getRankedPosts({
    String? category,
    int? limit,
  }) {
    Query<Map<String, dynamic>> query = RankedPostsModel.collection();
    
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    
    if (limit != null && limit > 0) {
      query = query.limit(limit);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final model = RankedPostsModel.fromSnapshot(doc);
        return _toRankedPostsData(model);
      }).toList();
    });
  }

  @override
  Future<RankedPostsData?> getRankedPostById(String postId) async {
    final query = RankedPostsModel.collection()
        .where('postId', isEqualTo: postId)
        .limit(1);
    
    final snapshot = await query.get();
    if (snapshot.docs.isEmpty) {
      return null;
    }
    
    final model = RankedPostsModel.fromSnapshot(snapshot.docs.first);
    return _toRankedPostsData(model);
  }

  /// Convert internal model to domain interface model
  RankedPostsData _toRankedPostsData(RankedPostsModel model) {
    return RankedPostsData(
      postId: model.postId,
      rank: model.rank,
      score: model.score,
      votesA: model.votesA,
      votesB: model.votesB,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      category: model.category,
    );
  }
}