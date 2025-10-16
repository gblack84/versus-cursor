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

  // ============= 이용 가능한 캐릭터 조회 =============
  // Phase 6 Cleanup: getUserCharacter, setUserCharacter, clearUserCharacter, watchUserCharacter 삭제

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
