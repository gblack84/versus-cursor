import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/datasources/i_post_creation_datasource.dart';

/// Firebase implementation of Post Creation DataSource
/// This is the ONLY place where Firebase dependencies should exist for Post Creation
class FirebasePostCreationDataSource implements IPostCreationDataSource {
  final FirebaseFirestore _firestore;

  FirebasePostCreationDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>> createPost(Map<String, dynamic> postData) async {
    try {
      // Add server timestamp if not provided
      if (!postData.containsKey('createdAt')) {
        postData['createdAt'] = FieldValue.serverTimestamp();
      }

      // Add the post to Firestore
      final docRef = await _firestore.collection('posts').add(postData);

      // Get the created document to return complete data
      final doc = await docRef.get();
      final data = doc.data() as Map<String, dynamic>;

      return {
        'id': doc.id,
        ...data,
        // Convert server timestamp to DateTime for consistency
        'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
      };
    } catch (e) {
      print('Error creating post: $e');
      throw Exception('Failed to create post: $e');
    }
  }

  @override
  Future<void> updatePost(String postId, Map<String, dynamic> postData) async {
    try {
      // Add update timestamp
      postData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('posts').doc(postId).update(postData);
    } catch (e) {
      print('Error updating post: $e');
      throw Exception('Failed to update post: $e');
    }
  }

  @override
  Future<String> uploadPostMetadata(Map<String, dynamic> metadata) async {
    try {
      // Store metadata in a separate collection for complex workflows
      final docRef = await _firestore.collection('postMetadata').add({
        ...metadata,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error uploading post metadata: $e');
      throw Exception('Failed to upload post metadata: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getPostCreationStatus(String statusId) async {
    try {
      final doc = await _firestore.collection('postCreationStatus').doc(statusId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        ...data,
      };
    } catch (e) {
      print('Error getting post creation status: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> validatePostContent(Map<String, dynamic> content) async {
    try {
      // This could call a Firebase Function or perform client-side validation
      // For now, we'll do basic validation and return results

      final validationResult = <String, dynamic>{
        'isValid': true,
        'errors': <String>[],
        'warnings': <String>[],
      };

      // Check required fields
      if (content['title'] == null || (content['title'] as String).isEmpty) {
        validationResult['isValid'] = false;
        (validationResult['errors'] as List).add('Title is required');
      }

      if (content['description'] == null || (content['description'] as String).isEmpty) {
        validationResult['isValid'] = false;
        (validationResult['errors'] as List).add('Description is required');
      }

      // Check content length limits
      if (content['title'] != null && (content['title'] as String).length > 100) {
        validationResult['isValid'] = false;
        (validationResult['errors'] as List).add('Title must be less than 100 characters');
      }

      if (content['description'] != null && (content['description'] as String).length > 500) {
        validationResult['isValid'] = false;
        (validationResult['errors'] as List).add('Description must be less than 500 characters');
      }

      // Add warnings for optional improvements
      if (content['tags'] == null || (content['tags'] as List?)?.isEmpty == true) {
        (validationResult['warnings'] as List).add('Adding tags can improve discoverability');
      }

      return validationResult;
    } catch (e) {
      print('Error validating post content: $e');
      throw Exception('Failed to validate post content: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> batchCreatePosts(List<Map<String, dynamic>> postsData) async {
    try {
      final batch = _firestore.batch();
      final docRefs = <DocumentReference>[];

      for (final postData in postsData) {
        // Add server timestamp to each post
        if (!postData.containsKey('createdAt')) {
          postData['createdAt'] = FieldValue.serverTimestamp();
        }

        final docRef = _firestore.collection('posts').doc();
        batch.set(docRef, postData);
        docRefs.add(docRef);
      }

      // Commit the batch
      await batch.commit();

      // Fetch the created documents
      final createdPosts = <Map<String, dynamic>>[];
      for (final docRef in docRefs) {
        final doc = await docRef.get();
        final data = doc.data() as Map<String, dynamic>;
        createdPosts.add({
          'id': doc.id,
          ...data,
        });
      }

      return createdPosts;
    } catch (e) {
      print('Error batch creating posts: $e');
      throw Exception('Failed to batch create posts: $e');
    }
  }

  @override
  Future<void> deleteDraft(String draftId) async {
    try {
      await _firestore.collection('drafts').doc(draftId).delete();
    } catch (e) {
      print('Error deleting draft: $e');
      throw Exception('Failed to delete draft: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getUserDrafts(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('drafts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error getting user drafts: $e');
      return [];
    }
  }
}