import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../domain/repositories/i_characters_repository.dart';
import '../../domain/models/character.dart';
import '../../domain/failures/profile_failures.dart';
import '../datasources/interfaces/i_profile_datasource.dart';

/// CharactersRepository 구현
///
/// **책임**:
/// - 'characters' 컬렉션에서 이용 가능한 캐릭터 조회
/// - users/{userId}/characterId 필드로 사용자 캐릭터 관리
/// - CharactersModel ↔ Character 도메인 모델 변환
class CharactersRepositoryImpl implements ICharactersRepository {
  final IProfileDataSource _dataSource;
  final FirebaseFirestore _firestore;

  CharactersRepositoryImpl({
    required IProfileDataSource dataSource,
    FirebaseFirestore? firestore,
  })  : _dataSource = dataSource,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // ============= 사용자 캐릭터 관리 =============

  @override
  Future<Either<ProfileFailure, Character?>> getUserCharacter(
      String userId) async {
    try {
      final data = await _dataSource.getProfile(userId);
      if (data == null) {
        return Left(ProfileNotFoundFailure(userId: userId));
      }

      final characterId = data['characterId'] as String?;
      if (characterId == null || characterId.isEmpty) {
        return const Right(null);
      }

      // 'characters' 컬렉션에서 캐릭터 정보 조회
      final characterDoc =
          await _firestore.collection('characters').doc(characterId).get();

      if (!characterDoc.exists) {
        return const Right(null);
      }

      final character = _convertToCharacter(characterDoc);
      return Right(character);
    } catch (e) {
      return Left(FirestoreReadFailure(
        message: 'Failed to get user character: $e',
      ));
    }
  }

  @override
  Future<Either<ProfileFailure, void>> setUserCharacter(
    String userId,
    String characterId,
  ) async {
    try {
      // 캐릭터가 존재하는지 확인
      final characterDoc =
          await _firestore.collection('characters').doc(characterId).get();

      if (!characterDoc.exists) {
        return const Left(ValidationFailure(
          message: '존재하지 않는 캐릭터입니다.',
        ));
      }

      await _dataSource.updateField(userId, 'characterId', characterId);
      return const Right(null);
    } catch (e) {
      return Left(FirestoreWriteFailure(
        message: 'Failed to set user character: $e',
      ));
    }
  }

  @override
  Future<Either<ProfileFailure, void>> clearUserCharacter(
      String userId) async {
    try {
      await _dataSource.updateField(userId, 'characterId', null);
      return const Right(null);
    } catch (e) {
      return Left(FirestoreWriteFailure(
        message: 'Failed to clear user character: $e',
      ));
    }
  }

  @override
  Stream<Character?> watchUserCharacter(String userId) {
    return _dataSource.watchProfile(userId).asyncMap((data) async {
      if (data == null) return null;

      final characterId = data['characterId'] as String?;
      if (characterId == null || characterId.isEmpty) {
        return null;
      }

      final characterDoc =
          await _firestore.collection('characters').doc(characterId).get();

      if (!characterDoc.exists) {
        return null;
      }

      return _convertToCharacter(characterDoc);
    });
  }

  // ============= 이용 가능한 캐릭터 조회 =============

  @override
  Future<Either<ProfileFailure, List<Character>>> getAvailableCharacters() async {
    try {
      final snapshot = await _firestore
          .collection('characters')
          .where('isActive', isEqualTo: true)
          .get();

      final characters = snapshot.docs
          .map((doc) => _convertToCharacter(doc))
          .toList();

      return Right(characters);
    } catch (e) {
      return Left(FirestoreReadFailure(
        message: 'Failed to get available characters: $e',
      ));
    }
  }

  // ============= 헬퍼 메서드 =============

  /// Firestore DocumentSnapshot을 Character 도메인 모델로 변환
  Character _convertToCharacter(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Character(
      characterId: doc.id,
      name: data['CharactersName'] as String? ?? '',
      imageUrl: data['CharactersImageUrl'] as String? ?? '',
      description: data['description'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      characterType: data['characterType'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
