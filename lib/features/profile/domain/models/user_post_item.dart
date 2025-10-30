import 'package:cloud_firestore/cloud_firestore.dart';

/// Profile Feature 전용 사용자 게시물 항목 모델
///
/// **Feature Isolation 원칙**:
/// - ✅ Profile Feature 독립적으로 관리
/// - ✅ Post Feature에 의존하지 않음
/// - ✅ Firebase posts 컬렉션에서 필요한 필드만 추출
///
/// **용도**: Profile 화면의 게시물 목록 표시용 (간단한 DTO)
class UserPostItem {
  final String id;
  final String questionTitle;
  final int totalVotes;
  final int commentCount;
  final DateTime createdAt;

  const UserPostItem({
    required this.id,
    required this.questionTitle,
    required this.totalVotes,
    required this.commentCount,
    required this.createdAt,
  });

  /// Firebase Firestore DocumentSnapshot에서 변환
  ///
  /// **Firebase 직접 접근**:
  /// - posts 컬렉션 문서에서 필요한 필드만 추출
  /// - Post Feature의 모델을 사용하지 않음
  factory UserPostItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('UserPostItem: Document data is null');
    }

    return UserPostItem(
      id: doc.id,
      questionTitle: data['questionTitle'] as String? ?? '',
      totalVotes: data['totalVotes'] as int? ?? 0,
      commentCount: data['commentCount'] as int? ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPostItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserPostItem(id: $id, questionTitle: $questionTitle, totalVotes: $totalVotes, commentCount: $commentCount, createdAt: $createdAt)';
  }
}
