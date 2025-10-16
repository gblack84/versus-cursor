import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'profile_storage_datasource.dart';
import '/services/storage/firebase_storage_service.dart';

/// Profile 이미지 Storage DataSource 구현체
///
/// **책임**:
/// - Firebase Storage를 활용한 프로필 이미지 업로드
/// - 이미지 경로: `users/{userId}/profile.jpg`
/// - 기존 `uploadData()` 함수 활용
class ProfileStorageDataSourceImpl implements IProfileStorageDataSource {
  @override
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // 1. 파일을 Uint8List로 읽기
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // 2. Storage 경로 생성
      final String path = 'users/$userId/profile.jpg';

      // 3. 기존 uploadData() 함수 활용
      final String? downloadUrl = await uploadData(path, imageBytes);

      if (downloadUrl == null) {
        throw Exception('Failed to upload profile image');
      }

      return downloadUrl;
    } catch (e) {
      throw Exception('Storage upload failed: ${e.toString()}');
    }
  }

  @override
  Future<bool> deleteProfileImage(String imageUrl) async {
    try {
      // Firebase Storage URL에서 ref 추출
      final Reference ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      // 파일이 이미 없으면 성공으로 간주
      if (e is FirebaseException && e.code == 'object-not-found') {
        return true;
      }
      throw Exception('Storage delete failed: ${e.toString()}');
    }
  }
}
