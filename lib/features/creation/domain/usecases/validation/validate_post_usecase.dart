import 'package:fpdart/fpdart.dart';
import 'package:versus_space/features/creation/domain/failures/creation_failures.dart';

/// ValidatePostUseCase - 게시물 유효성 검증
///
/// 게시물 생성 전 모든 검증 로직을 처리
class ValidatePostUseCase {
  const ValidatePostUseCase();

  /// 게시물 텍스트 검증
  Future<Either<Failure, Unit>> validateText(String text) async {
    if (text.trim().isEmpty) {
      return left(
        const CreationValidationFailure(
          '텍스트가 비어있습니다',
          code: 'EMPTY_TEXT',
        ),
      );
    }

    if (text.length > 500) {
      return left(
        const CreationValidationFailure(
          '텍스트가 너무 깁니다',
          code: 'TEXT_TOO_LONG',
        ),
      );
    }

    return right(unit);
  }

  /// 이미지 유효성 검증
  Future<Either<Failure, Unit>> validateImage(String imagePath) async {
    // TODO: 이미지 검증 로직 구현
    return right(unit);
  }

  /// 전체 게시물 유효성 검증
  Future<Either<Failure, Unit>> validatePost({
    required String optionA,
    required String optionB,
    List<String>? imageUrls,
  }) async {
    final textAResult = await validateText(optionA);
    if (textAResult.isLeft()) return textAResult;

    final textBResult = await validateText(optionB);
    if (textBResult.isLeft()) return textBResult;

    return right(unit);
  }
}
