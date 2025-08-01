/// 설정 관련 상수
class ConfigConstants {
  // Asset Picker Config
  static const int pickerGridCount = 4;
  static const bool sortByModifiedDate = true;
  static const bool shouldRevertGrid = false;
  
  // Firebase Config
  static const String usersPath = 'users';
  static const String postsPath = 'posts';
  static const String imagesPath = 'images';
  
  // Post Settings
  static const int publicVisibility = 1;
  static const int resultTime = 7; // days
  
  // Media Types
  static const String imageMediaType = 'image';
  static const String videoMediaType = 'video';
  
  // Metadata Keys
  static const String boxMetadataKey = 'box';
  static const String typeMetadataKey = 'type';
  static const String widthMetadataKey = 'width';
  static const String heightMetadataKey = 'height';
  static const String uploadedAtKey = 'uploadedAt';
  static const String uploadedByKey = 'uploadedBy';
  
  // Image Types
  static const String originalType = 'original';
  static const String displayType = 'display';
  static const String thumbnailType = 'thumbnail';
  
  // Layout Types
  static const String horizontalLayout = 'horizontal';
  static const String verticalLayout = 'vertical';
}