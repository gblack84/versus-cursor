/// 문자열 상수
class StringConstants {
  // Error Messages
  static const String userNotLoggedIn = '사용자가 로그인되어 있지 않습니다.';
  static const String imageDecodeError = '이미지를 디코딩할 수 없습니다.';
  static const String imageLoadError = '이미지를 불러올 수 없습니다: ';
  static const String imageSelectionError = '이미지 선택 중 오류가 발생했습니다: ';
  static const String imageUploadError = '이미지 업로드 실패: ';
  static const String imageProcessingError = '이미지 처리 중 오류가 발생했습니다.';
  static const String unknownError = '알 수 없는 오류';
  static const String noInputText = '입력된 텍스트가 없습니다.';
  static const String textValidationError = '텍스트 검증 중 오류가 발생했습니다.';
  static const String loginRequired = '로그인이 필요합니다.';
  static const String uploadFailure = '저장 중 오류가 발생했습니다.';
  static const String downloadError = '이미지 다운로드 실패';
  static const String editError = '이미지 편집 실패';
  
  // Success Messages
  static const String imageModified = '이미지가 수정되었습니다.';
  static const String postSaved = '게시물이 성공적으로 저장되었습니다!';
  static const String uploadComplete = '업로드 완료';
  
  // Warning Messages
  static const String addImageToAFirst = 'A 먼저 이미지를 추가해주세요';
  static const String inappropriateContent = '부적절한 내용 감지';
  static const String modifyAndRetry = '내용을 수정한 후 다시 시도해주세요.';
  static const String exitEditorWarning = '변경사항을 저장하지 않고 나가시겠습니까?';
  static const String communityGuidelineViolation = '커뮤니티 가이드라인 위반';
  
  // Loading Messages
  static const String safetyCheck = '안전성 검사중 입니다...';
  static const String loading = '처리중...';
  static const String uploading = '업로드중...';
  
  // Label Messages
  static const String cancel = '취소';
  static const String confirm = '확인';
  static const String gallery = '갤러리';
  static const String thumbnail = '썸네일';
  static const String back = '뒤로';
  static const String edit = '편집';
  static const String delete = '삭제';
  
  // Field Names
  static const String questionTitleField = 'Question Title';
  static const String descriptionField = 'Description';
  static const String aTitleField = 'A title';
  static const String bTitleField = 'B title';
  
  // Validation Categories
  static const String profanityCategory = '욕설 감지';
  static const String threatCategory = '위협적 표현';
  static const String insultCategory = '모욕적 표현';
  static const String toxicityCategory = '독성 콘텐츠';
  static const String inappropriateCategory = '부적절한 내용';
  static const String sexuallyExplicitCategory = '선정적 콘텐츠';
  static const String violentContentCategory = '폭력적 콘텐츠';
}