/// Generic content model interface
///
/// This interface abstracts content-related data structures
/// to avoid cross-feature dependencies
abstract class IContentModel {
  String get id;
  String get userid;
  String get content;
  DateTime? get createdAt;
  DateTime? get updatedAt;
  
  /// Content metadata
  int get likecount;
  int get commentcount;
  int? get interestcount;
  
  /// Location data if available
  dynamic get location; // Can be LatLng or null
  
  /// Generic data access
  Map<String, dynamic> toMap();
  
  /// Content type identification
  String get contentType => 'generic';
  
  /// Check if content has specific fields
  bool hasField(String fieldName);
  
  /// Get field value safely
  T? getFieldValue<T>(String fieldName);
}