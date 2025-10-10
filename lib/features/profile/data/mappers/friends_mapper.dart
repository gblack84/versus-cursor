import '../../domain/models/friends_list_model.dart';
import '../dto/friend_dto.dart';

/// FriendsList Mapper
///
/// **책임**: DTO와 Domain Model 간 양방향 변환
class FriendsMapper {
  /// DTO → Domain Model
  ///
  /// **Note**: FriendsListModel은 현재 FirestoreRecord를 상속하므로
  /// Phase 6에서 변환 로직이 개선될 예정입니다.
  static FriendsListModel toDomain(FriendDto dto) {
    // TODO: Phase 6에서 FriendsListModel이 순수 Dart 클래스로 변환되면
    // 직접 생성자 사용 가능
    throw UnimplementedError(
      'FriendsMapper.toDomain은 Phase 6에서 구현됩니다',
    );
  }

  /// Domain Model → DTO
  static FriendDto fromDomain(FriendsListModel friendsList) {
    // TODO: Phase 6에서 FriendsListModel 필드 확인 후 완전 구현
    throw UnimplementedError(
      'FriendsMapper.fromDomain은 Phase 6에서 구현됩니다',
    );
  }

  /// DTO List → Domain Model List
  static List<FriendsListModel> toDomainList(List<FriendDto> dtoList) {
    return dtoList.map((dto) => toDomain(dto)).toList();
  }

  /// Domain Model List → DTO List
  static List<FriendDto> fromDomainList(List<FriendsListModel> modelList) {
    return modelList.map((model) => fromDomain(model)).toList();
  }
}
