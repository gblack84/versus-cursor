# Media Utilities

이 디렉토리는 **순수 유틸리티**만 포함합니다.

## ✅ 사용 가능한 유틸리티

### 1. ImageDownloadService
- **파일**: `image_download_service.dart`
- **용도**: 이미지 URL을 File로 다운로드
- **사용처**: Creation Feature (2곳)
- **사용법**:
  ```dart
  final file = await ImageDownloadService.downloadImage(imageUrl);
  ```

### 2. AssetPickerService
- **파일**: `asset_picker_service.dart`
- **용도**: wechat_assets_picker 설정 제공
- **사용법**:
  ```dart
  final config = AssetPickerService.getPickerConfig(
    maxAssets: 10,
    requestType: RequestType.image,
  );
  ```

### 3. MediaSelectionService
- **파일**: `media_selection_service.dart`
- **용도**: AssetEntity를 File로 변환
- **사용법**:
  ```dart
  final files = await MediaSelectionService.convertToFiles(assets);
  ```

### 4. EncodingsModel
- **파일**: `encodings_model.dart`
- **용도**: 비디오 인코딩 상태 추적 (향후 비디오 기능용)
- **상태**: 보존 (비디오 업로드 기능 구현 시 참고용)

---

## 🚀 Feature별 미디어 처리

각 Feature는 자체 미디어 서비스를 구현합니다:

### Chat Feature
```
lib/features/chat/data/services/chat_media_upload_service.dart
- 188 LOC
- FirebaseStorage 직접 사용
- 10MB 제한, 빠른 전송
- 압축 없음
```

### Creation Feature
```
lib/features/creation/data/repositories/media_repository_impl.dart
- 696 LOC
- Riverpod 3.x Notifiers 사용
- 50MB 제한, AI 검열, 트리밍, 압축
```

### Profile Feature
```
lib/features/profile/data/repositories/profile_storage_repository_impl.dart
- 독립적인 Storage Repository
- 50MB 제한
```

---

## 💡 새 Feature에서 미디어 추가 방법

### 패턴: Feature별 독립 구현 (권장)

```dart
// lib/features/your_feature/data/services/your_feature_media_service.dart

import 'package:firebase_storage/firebase_storage.dart';

class YourFeatureMediaService {
  final FirebaseStorage _storage;

  YourFeatureMediaService(this._storage);

  Future<String> uploadImage({
    required File imageFile,
    required String storagePath,
  }) async {
    // 1. Feature별 검증 (크기, 형식 등)
    if (await imageFile.length() > maxSize) {
      throw Exception('File too large');
    }

    // 2. Firebase Storage 직접 업로드
    final ref = _storage.ref().child(storagePath);
    await ref.putFile(imageFile);

    // 3. URL 반환
    return await ref.getDownloadURL();
  }
}
```

### 유틸리티 사용 (선택)

```dart
// services/media/ 유틸리티를 필요 시 사용
import 'package:versus_space/services/media/image_download_service.dart';
import 'package:versus_space/services/media/asset_picker_service.dart';

// 예: 이미지 편집 전 다운로드
final file = await ImageDownloadService.downloadImage(imageUrl);
```

---

## 📜 아키텍처 원칙

### Large App (8 Features) 패턴
이 프로젝트는 **Feature-First Architecture**를 따릅니다.

**왜 Feature별 독립 구현?**
- ✅ 각 Feature의 요구사항이 다름 (10MB vs 50MB, 트리밍 유무)
- ✅ Feature 독립성 유지 (Clean Architecture v4.0)
- ✅ 억지로 공유하면 복잡도만 증가
- ✅ Slack, Notion, Discord도 같은 패턴 사용

---

## 📜 변경 이력

### 2025-11-10: 대규모 정리
**삭제된 파일** (죽은 코드):
- ❌ `image_editor_callback_handler.dart` (286 LOC) - 미사용
- ❌ `selection_result_processor.dart` (333 LOC) - 미사용
- ❌ `media_upload_service.dart` (550 LOC) - 미사용

**이유**:
- Creation Feature가 Riverpod 3.x Notifiers로 완전 마이그레이션됨
- 각 Feature가 자체 미디어 서비스 구현
- 순수 유틸리티만 남김 (80% 감소)

**유지된 파일**:
- ✅ `asset_picker_service.dart` (119 LOC) - 유틸리티
- ✅ `image_download_service.dart` (58 LOC) - 사용 중
- ✅ `media_selection_service.dart` (79 LOC) - 유틸리티
- ✅ `encodings_model.dart` (39 LOC) - 비디오 기능용 보존

---

## 📊 통계

- **Before**: 1,464 LOC (7 files)
- **After**: 295 LOC (4 files)
- **감소**: 80% (1,169 LOC 삭제)
- **역할**: 순수 유틸리티 디렉토리
