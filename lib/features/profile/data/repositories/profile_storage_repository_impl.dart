import 'dart:io';
import '../../domain/repositories/i_profile_storage_repository.dart';
import '../datasources/profile_storage_datasource.dart';

/// Profile Storage Repository Implementation (Clean Architecture v4.0)
///
/// **Repository Layer** - Domain Port 구현체
///
/// **책임**:
/// - Domain Port(IProfileStorageRepository)를 Data Layer에서 구현
/// - DataSource에 작업 위임
/// - 비즈니스 로직 레이어 (필요시 추가 가능)
///
/// **의존성**:
/// - IProfileStorageDataSource: 실제 Storage 작업 수행
///
/// **아키텍처**:
/// - Domain Layer (Port) ← Repository Impl ← DataSource
/// - UseCase → Repository Interface → Repository Impl → DataSource
class ProfileStorageRepositoryImpl implements IProfileStorageRepository {
  final IProfileStorageDataSource _dataSource;

  ProfileStorageRepositoryImpl({
    required IProfileStorageDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    // DataSource에 위임 (현재는 추가 비즈니스 로직 없음)
    return await _dataSource.uploadProfileImage(
      userId: userId,
      imageFile: imageFile,
    );
  }

  @override
  Future<bool> deleteProfileImage(String imageUrl) async {
    // DataSource에 위임 (현재는 추가 비즈니스 로직 없음)
    return await _dataSource.deleteProfileImage(imageUrl);
  }
}
