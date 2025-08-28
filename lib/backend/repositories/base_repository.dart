/// Base Repository Abstract Class
/// 
/// 모든 Repository의 기본이 되는 추상 클래스입니다.
/// Repository Pattern의 기본 인터페이스를 정의합니다.
/// 
/// TODO: Week 1에 구현 예정
abstract class BaseRepository<T> {
  /// 단일 항목 조회
  Future<T?> get(String id);
  
  /// 전체 목록 조회
  Future<List<T>> getAll();
  
  /// 페이지네이션 조회
  Future<List<T>> getPage({
    required int page,
    required int pageSize,
  });
  
  /// 생성
  Future<T> create(T item);
  
  /// 업데이트
  Future<T> update(T item);
  
  /// 삭제
  Future<bool> delete(String id);
  
  /// 실시간 스트림
  Stream<T?> stream(String id);
  
  /// 전체 실시간 스트림
  Stream<List<T>> streamAll();
}