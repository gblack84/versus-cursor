/// Interest selection category configuration
///
/// Defines the behavior and constraints for each interest selection type
enum InterestCategory {
  /// 전문분야 (Expertise) - Maximum 4 selections
  expertise,

  /// 취미 (Hobbies) - Maximum 8 selections
  hobbies,

  /// 동의 (Agreed/Interests) - Maximum 8 selections
  agrred;

  /// Maximum number of selections allowed for this category
  int get maxSelections {
    switch (this) {
      case InterestCategory.expertise:
        return 4;
      case InterestCategory.hobbies:
      case InterestCategory.agrred:
        return 8;
    }
  }

  /// Firestore field name for this category
  String get firestoreField {
    switch (this) {
      case InterestCategory.expertise:
        return 'expertise';
      case InterestCategory.hobbies:
      case InterestCategory.agrred:
        return 'interests';
    }
  }

  /// Display name for UI labels and error messages
  String get displayName {
    switch (this) {
      case InterestCategory.expertise:
        return '전문분야';
      case InterestCategory.hobbies:
        return '취미';
      case InterestCategory.agrred:
        return '관심사';
    }
  }

  /// Route name for navigation
  String get routeName {
    switch (this) {
      case InterestCategory.expertise:
        return 'expertise_select';
      case InterestCategory.hobbies:
        return 'hobbies_select';
      case InterestCategory.agrred:
        return 'agrred_select';
    }
  }

  /// Route path for GoRouter
  String get routePath {
    switch (this) {
      case InterestCategory.expertise:
        return '/jopsSelect01';
      case InterestCategory.hobbies:
        return '/hobbiesSelect';
      case InterestCategory.agrred:
        return '/agrredSelect'; // Fixed: was '/hobbiesSelectCopy'
    }
  }

  /// Next route to navigate after completion
  String get nextRoute {
    switch (this) {
      case InterestCategory.expertise:
        return InterestCategory.hobbies.routeName;
      case InterestCategory.hobbies:
        return InterestCategory.agrred.routeName;
      case InterestCategory.agrred:
        return 'agreePage'; // Final step
    }
  }

  /// Title text for the selection screen
  String get titleText {
    switch (this) {
      case InterestCategory.expertise:
        return '당신의 전문분야를 선택해주세요';
      case InterestCategory.hobbies:
        return '취미를 선택해 주세요';
      case InterestCategory.agrred:
        return '관심사를 선택해 주세요';
    }
  }

  /// Subtitle text for the selection screen
  String get subtitleText {
    switch (this) {
      case InterestCategory.expertise:
        return '최대 ${maxSelections}개 까지 선택 가능합니다';
      case InterestCategory.hobbies:
      case InterestCategory.agrred:
        return '최대 ${maxSelections}개까지 선택 가능합니다';
    }
  }

  /// Error message when no items are selected
  String get noSelectionError {
    return '최소 1개의 $displayName를 선택해주세요';
  }

  /// Error message when maximum selection is exceeded
  String get maxSelectionError {
    return '$displayName는 최대 $maxSelections개까지 선택 가능합니다';
  }
}
