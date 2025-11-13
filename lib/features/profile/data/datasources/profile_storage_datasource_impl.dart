import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'profile_storage_datasource.dart';

/// Profile 이미지 Storage DataSource 구현체
///
/// **책임**:
/// - Firebase Storage를 활용한 프로필 이미지 업로드
/// - 이미지 경로: `users/{userId}/profile.jpg`
/// - Firebase Storage 직접 사용 (Clean Architecture)
///
/// **마이그레이션** (2025-11-10):
/// - ❌ 글로벌 `uploadData()` 함수 제거
/// - ✅ Firebase Storage 직접 사용
/// - ✅ Creation/Chat Feature와 동일한 패턴
class ProfileStorageDataSourceImpl implements IProfileStorageDataSource {
  final FirebaseStorage _storage;

  ProfileStorageDataSourceImpl({
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;
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

      // 3. Firebase Storage 직접 업로드 (uploadData 대체)
      final storageRef = _storage.ref().child(path);
      final metadata = SettableMetadata(contentType: lookupMimeType(path));
      final uploadTask = await storageRef.putData(imageBytes, metadata);

      // 4. 업로드 상태 확인
      if (uploadTask.state != TaskState.success) {
        throw Exception('Upload failed with state: ${uploadTask.state}');
      }

      // 5. Download URL 반환
      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Firebase Storage error: ${e.message}');
    } catch (e) {
      throw Exception('Storage upload failed: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadFileBytes({
    required String path,
    required List<int> bytes,
  }) async {
    try {
      // 1. Uint8List로 변환
      final Uint8List data = Uint8List.fromList(bytes);

      // 2. Firebase Storage 업로드
      final storageRef = _storage.ref().child(path);
      final metadata = SettableMetadata(contentType: lookupMimeType(path));
      final uploadTask = await storageRef.putData(data, metadata);

      // 3. 업로드 상태 확인
      if (uploadTask.state != TaskState.success) {
        throw Exception('Upload failed with state: ${uploadTask.state}');
      }

      // 4. Download URL 반환
      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Firebase Storage error: ${e.message}');
    } catch (e) {
      throw Exception('File upload failed: ${e.toString()}');
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
