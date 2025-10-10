import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../interfaces/i_storage_datasource.dart';

/// Firebase Storage DataSource 구현
class FirebaseStorageDataSource implements IStorageDataSource {
  final FirebaseStorage _storage;

  FirebaseStorageDataSource({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadProfileImage({
    required String userId,
    required List<int> imageBytes,
    required String fileName,
  }) async {
    final ref = _storage.ref().child('profile_images/$userId/$fileName');

    final uploadTask = ref.putData(
      Uint8List.fromList(imageBytes),
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  @override
  Future<void> deleteProfileImage(String imageUrl) async {
    final ref = _storage.refFromURL(imageUrl);
    await ref.delete();
  }
}
