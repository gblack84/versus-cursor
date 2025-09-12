import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/ports/i_notification_data_port.dart';

/// Implementation of INotificationDataPort that handles
/// notification data access through Firebase
class NotificationDataAdapter implements INotificationDataPort {
  final FirebaseFirestore _firestore;
  
  NotificationDataAdapter({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;
  
  @override
  Future<Map<String, dynamic>?> getPostData(String postId) async {
    try {
      final doc = await _firestore
          .collection('posts')
          .doc(postId)
          .get();
      
      if (!doc.exists) {
        return null;
      }
      
      return doc.data();
    } catch (e) {
      return null;
    }
  }
  
  @override
  Map<String, dynamic>? parseNotificationContent(String content) {
    if (content.isEmpty) {
      return null;
    }
    
    try {
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}