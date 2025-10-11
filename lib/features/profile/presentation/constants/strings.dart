/// 프로필 기능 문자열 상수
///
/// **Clean Architecture v4.0 준수**:
/// - 하드코딩된 문자열 제거
/// - i18n 준비 (AppLocalizations 키 참조)
/// - 일관된 메시지 관리
class ProfileStrings {
  ProfileStrings._();

  // 에러 메시지
  static const String errorLoadingProfile = 'Failed to load profile';
  static const String errorUpdatingProfile = 'Failed to update profile';
  static const String errorUploadingImage = 'Failed to upload image';
  static const String errorNetworkConnection = 'No internet connection';
  static const String errorUnknown = 'An unknown error occurred';
  static const String errorProfileNotFound = 'Profile not found';

  // 성공 메시지
  static const String successProfileUpdated = 'Profile updated successfully';
  static const String successImageUploaded = 'Image uploaded successfully';
  static const String successFriendRequestSent = 'Friend request sent';
  static const String successFriendRequestAccepted = 'Friend request accepted';
  static const String successInterestsSaved = 'Interests saved successfully';

  // 확인 메시지
  static const String confirmDeleteFriend = 'Are you sure you want to remove this friend?';
  static const String confirmRejectRequest = 'Are you sure you want to reject this request?';
  static const String confirmLogout = 'Are you sure you want to logout?';
  static const String confirmDeleteAccount = 'Are you sure you want to delete your account?';

  // 유효성 검사 메시지
  static const String validationDisplayNameRequired = 'Display name is required';
  static const String validationDisplayNameTooLong = 'Display name must be 20 characters or less';
  static const String validationDescriptionTooLong = 'Description must be 100 characters or less';
  static const String validationEmailInvalid = 'Please enter a valid email';
  static const String validationPhoneInvalid = 'Please enter a valid phone number';

  // 플레이스홀더 텍스트
  static const String placeholderDisplayName = 'Enter your display name';
  static const String placeholderShortDescription = 'Tell us about yourself';
  static const String placeholderBio = 'Write your bio here';
  static const String placeholderEmail = 'your@email.com';
  static const String placeholderPhone = '+1234567890';

  // 빈 상태 메시지
  static const String emptyFriendsList = 'You have no friends yet';
  static const String emptyFriendsDescription = 'Find new friends to connect with';
  static const String emptyInterests = 'No interests selected';
  static const String emptyInterestsDescription = 'Add your interests to personalize your profile';
  static const String emptyRequests = 'No friend requests';
  static const String emptyRequestsDescription = 'You have no pending friend requests';

  // 버튼 텍스트
  static const String buttonSave = 'Save';
  static const String buttonCancel = 'Cancel';
  static const String buttonEdit = 'Edit';
  static const String buttonDelete = 'Delete';
  static const String buttonConfirm = 'Confirm';
  static const String buttonRetry = 'Retry';
  static const String buttonAddFriend = 'Add Friend';
  static const String buttonMessage = 'Message';
  static const String buttonAccept = 'Accept';
  static const String buttonReject = 'Reject';
  static const String buttonFindFriends = 'Find Friends';

  // 섹션 제목
  static const String sectionBasicInfo = 'Basic Information';
  static const String sectionInterests = 'Interests';
  static const String sectionExpertise = 'Expertise';
  static const String sectionHobbies = 'Hobbies';
  static const String sectionFriends = 'Friends';
  static const String sectionSettings = 'Settings';
  static const String sectionNotifications = 'Notifications';
  static const String sectionPrivacy = 'Privacy';
  static const String sectionAccount = 'Account';

  // 로딩 메시지
  static const String loadingProfile = 'Loading profile...';
  static const String loadingFriends = 'Loading friends...';
  static const String loadingInterests = 'Loading interests...';
  static const String savingChanges = 'Saving changes...';
  static const String uploadingImage = 'Uploading image...';
}
