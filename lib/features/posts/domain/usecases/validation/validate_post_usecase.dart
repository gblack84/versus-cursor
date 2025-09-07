/// ValidatePostUseCase - 게시물 유효성 검증
/// 
/// 게시물 생성 전 모든 검증 로직을 처리
class ValidatePostUseCase {
  const ValidatePostUseCase();
  
  /// 게시물 텍스트 검증
  Future<ValidationResult> validateText(String text) async {
    if (text.trim().isEmpty) {
      return ValidationResult.failed('텍스트가 비어있습니다');
    }
    
    if (text.length > 500) {
      return ValidationResult.failed('텍스트가 너무 깁니다');
    }
    
    return ValidationResult.success();
  }
  
  /// 이미지 유효성 검증
  Future<ValidationResult> validateImage(String imagePath) async {
    // TODO: 이미지 검증 로직 구현
    return ValidationResult.success();
  }
  
  /// 전체 게시물 유효성 검증
  Future<ValidationResult> validatePost({
    required String optionA,
    required String optionB,
    List<String>? imageUrls,
  }) async {
    final textAResult = await validateText(optionA);
    if (!textAResult.isValid) return textAResult;
    
    final textBResult = await validateText(optionB);
    if (!textBResult.isValid) return textBResult;
    
    return ValidationResult.success();
  }
}

/// 검증 결과 모델
class ValidationResult {
  
  const ValidationResult._(this.isValid, this.errorMessage);
  
  factory ValidationResult.success() => const ValidationResult._(true, null);
  factory ValidationResult.failed(String message) => ValidationResult._(false, message);
  final bool isValid;
  final String? errorMessage;
}