import '/core/types/result.dart';
import '../../domain/repositories/i_interests_repository.dart';
import '../../domain/models/interest.dart';
import '../../domain/failures/profile_failure.dart';
import '../datasources/interfaces/i_profile_datasource.dart';

/// InterestsRepository 구현
///
/// **책임**:
/// - DataSource를 통한 관심사 데이터 접근
/// - List<String> ↔ List<Interest> 변환
/// - 제약사항 검증 (expertise 최대 4개, hobbies 최대 8개)
class InterestsRepositoryImpl implements IInterestsRepository {
  final IProfileDataSource _dataSource;

  InterestsRepositoryImpl({
    required IProfileDataSource dataSource,
  }) : _dataSource = dataSource;

  // ============= 관심사 관리 =============

  @override
  Future<Result<void>> updateUserInterests(
    String userId,
    List<Interest> interests,
  ) async {
    try {
      // 제약사항 검증
      final expertise =
          interests.where((i) => i.category == 'expertise').toList();
      final hobbies = interests.where((i) => i.category == 'hobby').toList();

      if (expertise.length > 4) {
        return ResultFailure(ValidationFailure('expertise'));
      }

      if (hobbies.length > 8) {
        return ResultFailure(ValidationFailure('hobbies'));
      }

      // Interest 리스트를 Firestore interests 배열로 변환
      final interestNames = interests.map((i) => i.name).toList();

      await _dataSource.updateFields(userId, {
        'interests': interestNames,
      });

      return const Success(null);
    } on ProfileFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(FirestoreWrite('Failed to update user interests: $e'));
    }
  }

  @override
  Future<Result<List<Interest>>> getUserInterests(
    String userId,
  ) async {
    try {
      final data = await _dataSource.getProfile(userId);
      if (data == null) {
        return ResultFailure(ProfileNotFound(userId: userId));
      }

      final interests = _convertToInterestList(data);
      return Success(interests);
    } on ProfileFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(FirestoreRead('Failed to get user interests: $e'));
    }
  }

  // Phase 6 Cleanup: watchUserInterests 삭제 (Stream 미사용)

  @override
  Future<Result<void>> addInterest({
    required String userId,
    required Interest interest,
  }) async {
    try {
      // 레거시 패턴: expertise_select_widget.dart line 370-380
      // await currentUserReference!.update({
      //   'expertise': FieldValue.arrayUnion([text])
      // });

      final field = interest.category == 'expertise' ? 'expertise' : 'interests';

      await _dataSource.arrayUnion(userId, field, [interest.name]);

      return const Success(null);
    } on ProfileFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(FirestoreWrite('Failed to add interest: $e'));
    }
  }

  @override
  Future<Result<void>> removeInterest({
    required String userId,
    required Interest interest,
  }) async {
    try {
      // 레거시 패턴: expertise_select_widget.dart line 559-569
      // await currentUserReference!.update({
      //   'expertise': FieldValue.arrayRemove([authenticatedUserItem])
      // });

      final field = interest.category == 'expertise' ? 'expertise' : 'interests';

      await _dataSource.arrayRemove(userId, field, [interest.name]);

      return const Success(null);
    } on ProfileFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(FirestoreWrite('Failed to remove interest: $e'));
    }
  }

  // ============= 헬퍼 메서드 =============

  /// Firestore 데이터를 Interest 리스트로 변환
  ///
  /// **Note**: Firestore에는 interests가 List<String>으로 저장되어 있음
  /// Category 분류 로직이 필요한 경우 별도 컬렉션 참조 필요
  List<Interest> _convertToInterestList(Map<String, dynamic> data) {
    final interestNames = data['interests'];
    if (interestNames is! List) return <Interest>[];

    final interests = <Interest>[];

    for (final name in interestNames) {
      if (name is! String) continue;

      // TODO: Phase 5에서 'interest' 컬렉션 조회하여 category, weight 등 가져오기
      // 현재는 name만으로 간단한 Interest 객체 생성
      interests.add(Interest(
        id: name.toLowerCase().replaceAll(' ', '_'),
        name: name,
        category: 'hobby', // 기본값
        weight: 0.5,
        selectedAt: DateTime.now(),
      ));
    }

    return interests;
  }
}
