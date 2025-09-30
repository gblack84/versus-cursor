import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/datasources/i_post_display_datasource.dart';

/// Firebase implementation of Post Display DataSource
/// This is the ONLY place where Firebase dependencies should exist for Post Display
class FirebasePostDisplayDataSource implements IPostDisplayDataSource {
  final FirebaseFirestore _firestore;

  FirebasePostDisplayDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Map<String, dynamic>>> queryPosts({
    required Map<String, dynamic> Function(Map<String, dynamic>) queryBuilder,
    int? limit,
  }) {
    // Start with posts collection
    Query query = _firestore.collection('posts');

    // Convert Map-based query builder to Firebase Query
    // This is a simplified version - in production, you'd have more sophisticated mapping
    final queryParams = queryBuilder({});

    // Apply common query parameters
    if (queryParams.containsKey('orderBy')) {
      final orderByField = queryParams['orderBy'] as String;
      final descending = queryParams['descending'] ?? false;
      query = query.orderBy(orderByField, descending: descending);
    }

    if (queryParams.containsKey('where')) {
      final whereConditions = queryParams['where'] as Map<String, dynamic>;
      whereConditions.forEach((field, value) {
        if (value is Map && value.containsKey('operator')) {
          // Handle complex operators
          final operator = value['operator'];
          final operand = value['value'];

          switch (operator) {
            case 'isEqualTo':
              query = query.where(field, isEqualTo: operand);
              break;
            case 'isGreaterThan':
              query = query.where(field, isGreaterThan: operand);
              break;
            case 'isLessThan':
              query = query.where(field, isLessThan: operand);
              break;
            case 'arrayContains':
              query = query.where(field, arrayContains: operand);
              break;
            default:
              query = query.where(field, isEqualTo: value);
          }
        } else {
          // Simple equality
          query = query.where(field, isEqualTo: value);
        }
      });
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    // Convert Firebase snapshots to Map data
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Include the document ID
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  @override
  Future<Map<String, dynamic>?> getPost(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        ...data,
      };
    } catch (e) {
      print('Error getting post: $e');
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPostsByIds(List<String> postIds) async {
    if (postIds.isEmpty) {
      return [];
    }

    try {
      // Firebase has a limit of 10 for 'whereIn' queries, so we need to batch
      final List<Map<String, dynamic>> allPosts = [];

      for (int i = 0; i < postIds.length; i += 10) {
        final batch = postIds.skip(i).take(10).toList();

        final querySnapshot = await _firestore
            .collection('posts')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        final posts = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();

        allPosts.addAll(posts);
      }

      return allPosts;
    } catch (e) {
      print('Error getting posts by IDs: $e');
      return [];
    }
  }

  @override
  Future<void> updatePostMetrics(String postId, Map<String, dynamic> metrics) async {
    try {
      // Convert custom increment format to Firebase FieldValue
      final updateData = <String, dynamic>{};

      for (final entry in metrics.entries) {
        if (entry.value is Map && entry.value['increment'] != null) {
          // Handle increment operation
          updateData[entry.key] = FieldValue.increment(entry.value['increment']);
        } else {
          // Regular update
          updateData[entry.key] = entry.value;
        }
      }

      await _firestore.collection('posts').doc(postId).update(updateData);
    } catch (e) {
      print('Error updating post metrics: $e');
      throw Exception('Failed to update post metrics: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      print('Error deleting post: $e');
      throw Exception('Failed to delete post: $e');
    }
  }
}