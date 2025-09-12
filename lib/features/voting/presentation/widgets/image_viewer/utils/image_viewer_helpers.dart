/// 이미지 뷰어 헬퍼 유틸리티
///
/// URL 관리 및 데이터 변환을 위한 유틸리티 함수들입니다.
class ImageViewerHelpers {
  /// 박스별 효과적인 이미지 URL 리스트 반환
  ///
  /// 멀티이미지가 있으면 우선 사용, 없으면 단일 이미지 사용
  static List<String> getEffectiveImageUrls({
    required String boxType,
    List<String>? imageUrlsA,
    List<String>? imageUrlsB,
    String? imageUrlA,
    String? imageUrlB,
  }) {
    if (boxType == 'A') {
      if (imageUrlsA != null && imageUrlsA.isNotEmpty) {
        return imageUrlsA;
      }
      if (imageUrlA != null) {
        return [imageUrlA];
      }
    } else if (boxType == 'B') {
      if (imageUrlsB != null && imageUrlsB.isNotEmpty) {
        return imageUrlsB;
      }
      if (imageUrlB != null) {
        return [imageUrlB];
      }
    }
    return [];
  }

  /// 초기 박스 타입과 인덱스 계산
  static ({String boxType, int indexA, int indexB}) calculateInitialPosition({
    required int initialIndex,
    required List<String> urlsA,
    required List<String> urlsB,
  }) {
    if (initialIndex >= urlsA.length) {
      // B박스에서 시작
      return (
        boxType: 'B',
        indexA: 0,
        indexB: initialIndex - urlsA.length,
      );
    } else {
      // A박스에서 시작
      return (
        boxType: 'A',
        indexA: initialIndex,
        indexB: 0,
      );
    }
  }
}

/// 현재 이미지 데이터를 나타내는 레코드 타입
typedef ImageData = ({
  String? imageUrl,
  String title,
  String? description,
  String boxType,
  int imageIndex,
  int totalInBox,
});