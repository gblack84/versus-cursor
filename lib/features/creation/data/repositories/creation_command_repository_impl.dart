import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/post_creation.dart';
import '../../domain/models/post_core.dart';
import '../../domain/models/post_content.dart';
import '../../domain/repositories/i_creation_command_repository.dart';
import '../../domain/datasources/i_storage_datasource.dart';
import '../utils/firestore_util.dart';

/// Implementation of creation command repository
/// 게시물 생성/수정/삭제 명령 처리 구현체
class CreationCommandRepositoryImpl implements ICreationCommandRepository {
  final FirebaseFirestore _firestore;
  final IStorageDataSource? _storageDataSource;

  static const String _collection = 'posts';

  CreationCommandRepositoryImpl({
    FirebaseFirestore? firestore,
    IStorageDataSource? storageDataSource,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storageDataSource = storageDataSource;

  CollectionReference get _postsCollection =>
      _firestore.collection(_collection);

  @override
  Future<String> createContent(PostCreation post) async {
    try {
      // Directly create post using Firestore
      final data = PostsFirestoreUtil.mapToFirestore(post.toJson());
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _postsCollection.add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create content: $e');
    }
  }

  @override
  Future<void> updateContent(String contentId, PostCreation post) async {
    try {
      final data = PostsFirestoreUtil.mapToFirestore(post.toJson());
      await _postsCollection.doc(contentId).update(data);
    } catch (e) {
      throw Exception('Failed to update content: $e');
    }
  }

  @override
  Future<void> deleteContent(String contentId) async {
    try {
      // Delete associated images if any
      final doc = await _postsCollection.doc(contentId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        // Delete images from storage
        final imageUrlsA = List<String>.from(data['imageUrlsA'] ?? []);
        final imageUrlsB = List<String>.from(data['imageUrlsB'] ?? []);

        for (final url in [...imageUrlsA, ...imageUrlsB]) {
          try {
            await _storageDataSource.deleteImage(url);
          } catch (e) {
            // Log but don't fail the deletion
            print('Failed to delete image: $url');
          }
        }
      }

      // Delete the post document
      await _postsCollection.doc(contentId).delete();
    } catch (e) {
      throw Exception('Failed to delete content: $e');
    }
  }

  @override
  Future<void> publishContent(String contentId) async {
    try {
      await _postsCollection.doc(contentId).update({
        'visibility': 0, // public
        'publishedAt': FieldValue.serverTimestamp(),
        'isDraft': false,
      });
    } catch (e) {
      throw Exception('Failed to publish content: $e');
    }
  }

  @override
  Future<void> saveDraft(String contentId, PostCreation post) async {
    try {
      final data = PostsFirestoreUtil.mapToFirestore(post.toJson());
      data['isDraft'] = true;
      data['visibility'] = 2; // private

      if (contentId.isEmpty) {
        // Create new draft
        await _postsCollection.add(data);
      } else {
        // Update existing draft
        await _postsCollection.doc(contentId).update(data);
      }
    } catch (e) {
      throw Exception('Failed to save draft: $e');
    }
  }

  @override
  Future<void> updateContentCore(String contentId, PostCore core) async {
    try {
      final data = {
        'questionTitle': core.questionTitle,
        'description': core.description,
        'category': core.category,
        'tags': core.tags,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _postsCollection.doc(contentId).update(data);
    } catch (e) {
      throw Exception('Failed to update content core: $e');
    }
  }

  @override
  Future<void> updateContentBody(String contentId, PostContent content) async {
    try {
      final data = {
        'optionA': content.optionA.toJson(),
        'optionB': content.optionB.toJson(),
        'imageUrlsA': content.optionA.imageUrls,
        'imageUrlsB': content.optionB.imageUrls,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _postsCollection.doc(contentId).update(data);
    } catch (e) {
      throw Exception('Failed to update content body: $e');
    }
  }
}