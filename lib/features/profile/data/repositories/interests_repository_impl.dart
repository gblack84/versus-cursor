import 'package:dartz/dartz.dart';
import '../../domain/repositories/i_interests_repository.dart';
import '../../domain/models/interest.dart';
import '../../domain/failures/profile_failures.dart';
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
  Future<Either<ProfileFailure, void>> updateUserInterests(
    String userId,
    List<Interest> interests,
  ) async {
    try {
      // 제약사항 검증
      final expertise =
          interests.where((i) => i.category == 'expertise').toList();
      final hobbies = interests.where((i) => i.category == 'hobby').toList();

      if (expertise.length > 4) {
        return const Left(ValidationFailure(
          message: '전문성은 최대 4개까지 선택할 수 있습니다.',
        ));
      }

      if (hobbies.length > 8) {
        return const Left(ValidationFailure(
          message: '취미는 최대 8개까지 선택할 수 있습니다.',
        ));
      }

      // Interest 리스트를 Firestore interests 배열로 변환
      final interestNames = interests.map((i) => i.name).toList();

      await _dataSource.updateFields(userId, {
        'interests': interestNames,
      });

      return const Right(null);
    } catch (e) {
      return Left(FirestoreWriteFailure(
        message: 'Failed to update user interests: $e',
      ));
    }
  }

  @override
  Future<Either<ProfileFailure, List<Interest>>> getUserInterests(
    String userId,
  ) async {
    try {
      final data = await _dataSource.getProfile(userId);
      if (data == null) {
        return Left(ProfileNotFoundFailure(userId: userId));
      }

      final interests = _convertToInterestList(data);
      return Right(interests);
    } catch (e) {
      return Left(FirestoreReadFailure(
        message: 'Failed to get user interests: $e',
      ));
    }
  }

  @override
  Stream<List<Interest>> watchUserInterests(String userId) {
    return _dataSource.watchProfile(userId).map((data) {
      if (data == null) return <Interest>[];
      return _convertToInterestList(data);
    });
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
