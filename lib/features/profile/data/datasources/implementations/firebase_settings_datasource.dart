import 'package:cloud_firestore/cloud_firestore.dart';
import '../interfaces/i_settings_datasource.dart';

/// Firebase Firestore 설정 DataSource 구현
class FirebaseSettingsDataSource implements ISettingsDataSource {
  final FirebaseFirestore _firestore;

  FirebaseSettingsDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>?> getSettings(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();
    if (data == null) return null;

    // UserSettings 필드만 추출 (users 문서에 직접 저장됨)
    return {
      'userId': data['userId'],
      'receiveRankUpdateNotifications': data['receiveRankUpdateNotifications'],
      'receiveTitleUpdateNotifications':
          data['receiveTitleUpdateNotifications'],
      'receiveVoteNotifications': data['receiveVoteNotifications'],
      'receiveCommentNotifications': data['receiveCommentNotifications'],
      'receiveFriendNotifications': data['receiveFriendNotifications'],
    };
  }

  @override
  Future<void> updateSettings(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  @override
  Stream<Map<String, dynamic>?> watchSettings(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;

      return {
        'userId': data['userId'],
        'receiveRankUpdateNotifications':
            data['receiveRankUpdateNotifications'],
        'receiveTitleUpdateNotifications':
            data['receiveTitleUpdateNotifications'],
        'receiveVoteNotifications': data['receiveVoteNotifications'],
        'receiveCommentNotifications': data['receiveCommentNotifications'],
        'receiveFriendNotifications': data['receiveFriendNotifications'],
      };
    });
  }
}
