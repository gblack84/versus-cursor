/// 설정 DataSource 인터페이스
///
/// **책임**: Firestore 'users/{userId}/settings' 서브컬렉션 통신
abstract class ISettingsDataSource {
  /// 사용자 설정 조회
  Future<Map<String, dynamic>?> getSettings(String userId);

  /// 사용자 설정 업데이트
  Future<void> updateSettings(String userId, Map<String, dynamic> data);

  /// 사용자 설정 실시간 감시
  Stream<Map<String, dynamic>?> watchSettings(String userId);
}
