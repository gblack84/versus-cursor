/// FriendsList pure domain model (Clean Architecture v4.0)
///
/// **변경사항** (2025-01-20):
/// - FirestoreRecord 상속 제거 → 순수 Dart 클래스
/// - Private 필드 + Getter → Final public 필드
/// - has*() 메서드 제거 → Null check 직접 사용
/// - fromSnapshot(), collection 등 Firebase 메서드 제거 → DTO로 이동
/// - createFriendsListModelData() 제거 → FriendsListDto.toFirestore()로 이동
/// - FriendsListModelDocumentEquality 제거 → == operator 사용
/// - parentReference 제거 (Firebase-specific)
///
/// Represents a friend relationship with status and metadata
class FriendsList {
  // ============= Core Fields =============
  final String friendsId;
  final String status;
  final bool following;
  final bool follower;
  final bool isBlocked;
  final DateTime? lastInteraction;

  const FriendsList({
    required this.friendsId,
    this.status = '',
    this.following = false,
    this.follower = false,
    this.isBlocked = false,
    this.lastInteraction,
  });

  /// Create a copy of this FriendsList with updated fields
  FriendsList copyWith({
    String? friendsId,
    String? status,
    bool? following,
    bool? follower,
    bool? isBlocked,
    DateTime? lastInteraction,
  }) {
    return FriendsList(
      friendsId: friendsId ?? this.friendsId,
      status: status ?? this.status,
      following: following ?? this.following,
      follower: follower ?? this.follower,
      isBlocked: isBlocked ?? this.isBlocked,
      lastInteraction: lastInteraction ?? this.lastInteraction,
    );
  }

  @override
  String toString() => 'FriendsList('
      'friendsId: $friendsId, '
      'status: $status, '
      'following: $following, '
      'follower: $follower, '
      'isBlocked: $isBlocked'
      ')';

  @override
  int get hashCode => Object.hash(
        friendsId,
        status,
        following,
        follower,
        isBlocked,
        lastInteraction,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendsList &&
          runtimeType == other.runtimeType &&
          friendsId == other.friendsId &&
          status == other.status &&
          following == other.following &&
          follower == other.follower &&
          isBlocked == other.isBlocked &&
          lastInteraction == other.lastInteraction;
}

// Backward compatibility aliases
@Deprecated('Use FriendsList instead')
typedef FriendsListModel = FriendsList;
