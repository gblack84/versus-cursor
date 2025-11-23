# File Size Utility Service

> **Purpose**: File size validation and formatting for Firebase Storage integration
> **Pattern**: Singleton Utility (Silent Failure for UX)
> **Layer**: Service Layer (Infrastructure - Storage Utilities)
> **Used by**: Creation Feature (Image/Video Upload), Chat Feature (Media Messages)
> **Last Updated**: 2025-11-23

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Architecture](#architecture)
4. [API Reference](#api-reference)
5. [URL Format Support](#url-format-support)
6. [DI Registration](#di-registration)
7. [Troubleshooting](#troubleshooting)
8. [Related Documentation](#related-documentation)

---

## 🎯 Overview

### What is FileSizeUtils?

**Purpose**: Validate file sizes before upload and format file sizes for human-readable display.

**Key Features**:
- ✅ **Local File Validation**: Check file size before upload (prevent 10MB+ uploads)
- ✅ **Storage File Size**: Query Firebase Storage metadata for remote file sizes
- ✅ **URL Parsing**: Extract storage paths from 3 URL formats (gs://, https://, download URLs)
- ✅ **Human-Readable Formatting**: Convert bytes to B/KB/MB/GB
- ✅ **Silent Failure**: Returns 0 on errors (better UX than throwing exceptions)

### Use Cases

| Feature | Use Case | Method |
|---------|----------|--------|
| **Creation** | Validate image before upload (<10MB) | `checkFileSize()` |
| **Creation** | Validate video before upload (<50MB) | `checkFileSize(maxSizeInBytes: 52428800)` |
| **Chat** | Display media file sizes in chat UI | `calculateMediaSize()` + `formatFileSize()` |
| **Profile** | Check profile image size (<5MB) | `checkFileSize(maxSizeInBytes: 5242880)` |

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                  Creation Feature                           │
│  User selects image → FileSizeUtils.checkFileSize()         │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │   Local File System          │
        │   File.length() → bytes      │
        └──────────────┬───────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │   Size Validation            │
        │   bytes <= 10MB? (10485760)  │
        └──────────────┬───────────────┘
                       │
           ┌───────────┴───────────┐
           │                       │
           ▼                       ▼
       ✅ Pass                  ❌ Fail
    Upload allowed          Show error
                           "File too large"


┌─────────────────────────────────────────────────────────────┐
│                    Chat Feature                             │
│  Display media size → FileSizeUtils.calculateMediaSize()    │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │   URL Type Detection         │
        │   gs:// | https:// | local   │
        └──────────────┬───────────────┘
                       │
           ┌───────────┴───────────┐
           │                       │
           ▼                       ▼
    Remote URL              Local File
    │                            │
    ├─ gs://bucket/path          ├─ /data/image.jpg
    ├─ https://.../o/path        └─ File.length()
    └─ Firebase Storage
       getMetadata() → size
                │
                ▼
        ┌──────────────────────────────┐
        │   Human-Readable Format      │
        │   1024 → "1.0 KB"            │
        │   1048576 → "1.0 MB"         │
        └──────────────────────────────┘
```

---

## 🚀 Quick Start

### Scenario 1: Validate File Before Upload (Most Common)

```dart
import '/services/storage/file_size_utils.dart';

class MediaUploadService {
  final FileSizeUtils _fileSizeUtils = FileSizeUtils();

  Future<bool> validateImage(File imageFile) async {
    // Check if file size <= 10MB (10485760 bytes)
    final isValidSize = await _fileSizeUtils.checkFileSize(
      imageFile,
      maxSizeInBytes: 10 * 1024 * 1024, // 10MB
    );

    if (!isValidSize) {
      throw Exception('Image must be less than 10MB');
    }

    return true;
  }

  Future<bool> validateVideo(File videoFile) async {
    // Check if file size <= 50MB
    final isValidSize = await _fileSizeUtils.checkFileSize(
      videoFile,
      maxSizeInBytes: 50 * 1024 * 1024, // 50MB
    );

    if (!isValidSize) {
      throw Exception('Video must be less than 50MB');
    }

    return true;
  }
}
```

**Common Size Limits**:
```dart
// Standard limits
const int maxImageSize = 10 * 1024 * 1024;      // 10MB
const int maxVideoSize = 50 * 1024 * 1024;      // 50MB
const int maxProfileImage = 5 * 1024 * 1024;    // 5MB
const int maxDocument = 25 * 1024 * 1024;       // 25MB
```

---

### Scenario 2: Display File Size in UI

```dart
import '/services/storage/file_size_utils.dart';

class ChatMessageWidget extends StatelessWidget {
  final Message message;
  final FileSizeUtils _fileSizeUtils = FileSizeUtils();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _fileSizeUtils.calculateMediaSize(message.mediaUrl),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final sizeStr = _fileSizeUtils.formatFileSize(snapshot.data!);
          return Text('File size: $sizeStr');
          // Example outputs:
          // "File size: 1.2 MB"
          // "File size: 850.5 KB"
          // "File size: 3.4 GB"
        }
        return Text('Calculating...');
      },
    );
  }
}
```

---

### Scenario 3: Get Firebase Storage File Size

```dart
import '/services/storage/file_size_utils.dart';

class StorageAnalytics {
  final FileSizeUtils _fileSizeUtils = FileSizeUtils();

  Future<void> logUploadedMediaSize(String storageUrl) async {
    // Works with all URL formats:
    // - gs://bucket-name/path/to/file.jpg
    // - https://firebasestorage.googleapis.com/v0/b/bucket/o/path%2Fto%2Ffile.jpg
    // - Download URLs with tokens

    final sizeBytes = await _fileSizeUtils.getStorageFileSize(storageUrl);
    final sizeFormatted = _fileSizeUtils.formatFileSize(sizeBytes);

    print('Uploaded file size: $sizeFormatted');
    // Example: "Uploaded file size: 2.3 MB"
  }
}
```

---

## 🏗 Architecture

### File Size Calculation Strategy

**Decision Tree**:
```
Is URL provided?
│
├─ No URL (null/empty)
│  └─ Return 0
│
└─ Yes → What format?
   │
   ├─ Local file path
   │  (not starting with http/gs://)
   │  └─ File.length()
   │
   └─ Remote URL
      │
      ├─ gs://bucket/path
      │  └─ Extract path → Storage.ref(path).getMetadata().size
      │
      ├─ https://firebasestorage.googleapis.com/.../o/path
      │  └─ Parse URL → Extract encoded path → Storage.ref(path).getMetadata().size
      │
      └─ Download URL (with token)
         └─ Regex match → Extract path → Storage.ref(path).getMetadata().size
```

### URL Parsing Strategy

**3 URL Formats Supported**:

1. **gs:// URL** (Storage URI):
   ```
   gs://my-bucket/images/profile.jpg
   ```
   - Parsed using `Uri.parse()`
   - Path extraction: `uri.path.substring(1)` (remove leading /)

2. **HTTPS Storage URL** (Encoded):
   ```
   https://firebasestorage.googleapis.com/v0/b/my-bucket/o/images%2Fprofile.jpg
   ```
   - Find 'o' segment in path
   - Get next segment (encoded path)
   - `Uri.decodeComponent()` to get actual path

3. **Download URL** (With Token):
   ```
   https://storage.googleapis.com/my-bucket/images/profile.jpg?token=abc123
   ```
   - Regex: `/b/[^/]+/o/(.+)\?`
   - Extract path from match group
   - Decode URI components

### Silent Failure Design

**Philosophy**: Better UX than throwing exceptions

```dart
Future<int> getLocalFileSize(String localPath) async {
  try {
    final file = File(localPath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;  // ✅ Silent failure (file not found)
  } catch (e) {
    return 0;    // ✅ Silent failure (permission error, etc.)
  }
}
```

**Rationale**:
- ❌ Throwing exception: Crashes app, shows error dialog
- ✅ Returning 0: UI shows "Size unknown" or hides size label gracefully

---

## 📚 API Reference

### Core Methods

#### `Future<int> getLocalFileSize(String localPath)`

**Purpose**: Get file size from local file system

**Parameters**:
- `localPath` (String): Absolute file path (e.g., `/data/user/0/.../image.jpg`)

**Returns**: `Future<int>` - File size in bytes (0 if error)

**Example**:
```dart
final sizeBytes = await fileSizeUtils.getLocalFileSize('/data/image.jpg');
print(sizeBytes);  // 1048576 (1MB)
```

**Error Handling**: Returns 0 on:
- File not found
- Permission denied
- Any other IO error

---

#### `Future<bool> checkFileSize(File file, {int maxSizeInBytes = 10485760})`

**Purpose**: Validate file size against limit

**Parameters**:
- `file` (File): File object to check
- `maxSizeInBytes` (int): Maximum allowed size (default: 10MB = 10485760)

**Returns**: `Future<bool>` - True if within limit, false otherwise

**Example**:
```dart
final file = File('/data/image.jpg');

// Default 10MB limit
final isValid = await fileSizeUtils.checkFileSize(file);
print(isValid);  // true or false

// Custom 5MB limit
final isValidCustom = await fileSizeUtils.checkFileSize(
  file,
  maxSizeInBytes: 5 * 1024 * 1024,
);
```

**Error Handling**: Returns false on:
- File not found
- File size exceeds limit
- Any IO error

---

#### `Future<int> getStorageFileSize(String url)`

**Purpose**: Get file size from Firebase Storage using URL

**Parameters**:
- `url` (String): Firebase Storage URL (gs://, https://, or download URL)

**Returns**: `Future<int>` - File size in bytes (0 if error)

**Example**:
```dart
// Works with all URL formats:
final url1 = 'gs://my-bucket/images/profile.jpg';
final url2 = 'https://firebasestorage.googleapis.com/v0/b/my-bucket/o/images%2Fprofile.jpg';

final size1 = await fileSizeUtils.getStorageFileSize(url1);
final size2 = await fileSizeUtils.getStorageFileSize(url2);

print(size1);  // 1048576 (1MB)
print(size2);  // 1048576 (same file)
```

**Error Handling**: Returns 0 on:
- Invalid URL format
- File not found in Storage
- Network error
- Permission denied

---

#### `String extractStoragePathFromUrl(String url)`

**Purpose**: Extract Firebase Storage path from URL

**Parameters**:
- `url` (String): Any Firebase Storage URL format

**Returns**: `String` - Storage path (empty string if error)

**Example**:
```dart
// gs:// URL
final path1 = fileSizeUtils.extractStoragePathFromUrl(
  'gs://my-bucket/images/profile.jpg',
);
print(path1);  // "images/profile.jpg"

// HTTPS URL
final path2 = fileSizeUtils.extractStoragePathFromUrl(
  'https://firebasestorage.googleapis.com/v0/b/my-bucket/o/images%2Fprofile.jpg',
);
print(path2);  // "images/profile.jpg"

// Download URL
final path3 = fileSizeUtils.extractStoragePathFromUrl(
  'https://storage.googleapis.com/my-bucket/images/profile.jpg?token=abc',
);
print(path3);  // "images/profile.jpg"
```

**Error Handling**: Returns empty string on:
- Invalid URL format
- Missing path segments
- Parsing errors

---

#### `Future<int> calculateMediaSize(String? mediaUrl)`

**Purpose**: Calculate media size (auto-detects local vs remote)

**Parameters**:
- `mediaUrl` (String?): Local file path or remote URL (null-safe)

**Returns**: `Future<int>` - File size in bytes (0 if null or error)

**Example**:
```dart
// Local file
final localSize = await fileSizeUtils.calculateMediaSize('/data/image.jpg');

// Remote URL
final remoteSize = await fileSizeUtils.calculateMediaSize(
  'gs://bucket/path/file.jpg',
);

// Null safety
final nullSize = await fileSizeUtils.calculateMediaSize(null);
print(nullSize);  // 0
```

**Auto-Detection Logic**:
```dart
if (mediaUrl == null || mediaUrl.isEmpty) return 0;
if (!mediaUrl.startsWith('http') && !mediaUrl.startsWith('gs://')) {
  return getLocalFileSize(mediaUrl);  // Local
}
return getStorageFileSize(mediaUrl);  // Remote
```

---

#### `String formatFileSize(int bytes)`

**Purpose**: Convert bytes to human-readable string

**Parameters**:
- `bytes` (int): File size in bytes

**Returns**: `String` - Formatted size with unit

**Example**:
```dart
print(fileSizeUtils.formatFileSize(500));           // "500 B"
print(fileSizeUtils.formatFileSize(1536));          // "1.5 KB"
print(fileSizeUtils.formatFileSize(1048576));       // "1.0 MB"
print(fileSizeUtils.formatFileSize(1073741824));    // "1.00 GB"
print(fileSizeUtils.formatFileSize(2147483648));    // "2.00 GB"
```

**Formatting Rules**:
- `< 1KB`: Show exact bytes (e.g., "500 B")
- `< 1MB`: Show KB with 1 decimal (e.g., "1.5 KB")
- `< 1GB`: Show MB with 1 decimal (e.g., "2.3 MB")
- `>= 1GB`: Show GB with 2 decimals (e.g., "1.50 GB")

---

## 🔗 URL Format Support

### Format 1: gs:// URI (Storage Reference)

**Example**:
```
gs://my-project-bucket/images/users/profile_12345.jpg
```

**Parsing**:
```dart
final uri = Uri.parse('gs://my-project-bucket/images/users/profile_12345.jpg');
final bucketName = uri.host;       // "my-project-bucket"
final filePath = uri.path.substring(1);  // "images/users/profile_12345.jpg"
```

**Use Cases**:
- Internal Firebase SDK URLs
- Storage emulator references
- Direct Storage API calls

---

### Format 2: HTTPS Encoded URL (Public Access)

**Example**:
```
https://firebasestorage.googleapis.com/v0/b/my-project-bucket/o/images%2Fusers%2Fprofile_12345.jpg
```

**Parsing**:
```dart
final uri = Uri.parse(url);
final segments = uri.pathSegments;
final oIndex = segments.indexOf('o');  // Find 'o' segment
final encodedPath = segments[oIndex + 1];  // Next segment
final decodedPath = Uri.decodeComponent(encodedPath);
// "images/users/profile_12345.jpg"
```

**Use Cases**:
- Public-accessible URLs
- Sharing via links
- CDN-cached content

---

### Format 3: Download URL (With Access Token)

**Example**:
```
https://storage.googleapis.com/my-project-bucket/images/users/profile_12345.jpg?GoogleAccessId=...&Expires=...&Signature=...
```

**Parsing**:
```dart
final regex = RegExp(r'/b/[^/]+/o/(.+)\?');
final match = regex.firstMatch(url);
final encodedPath = match.group(1)!;
final decodedPath = Uri.decodeComponent(encodedPath);
// "images/users/profile_12345.jpg"
```

**Use Cases**:
- Temporary download links
- Signed URLs with expiration
- Mobile app content delivery

---

## 🔧 DI Registration

**Location**: `/lib/app/di.dart`

```dart
Future<void> setupDependencyInjection() async {
  // ... other services

  // FileSizeUtils (Singleton - Firebase Storage 파일 크기 유틸)
  // Note: 현재 di.dart에 등록 안 됨 (Singleton pattern 자체 관리)
  // 필요 시 직접 인스턴스화:
  // final fileSizeUtils = FileSizeUtils();

  // ... other services
}
```

**Registered as**: Not registered in GetIt (uses Singleton pattern internally)
**Reason**: Stateless utility class, no external dependencies needed
**Usage**: Direct instantiation

```dart
// Direct instantiation (recommended)
final fileSizeUtils = FileSizeUtils();

// Or access singleton
final fileSizeUtils = FileSizeUtils();  // Always returns same instance
```

### Usage in Features

```dart
// Creation Feature
class MediaUploadService {
  final FileSizeUtils _fileSizeUtils = FileSizeUtils();

  Future<void> validateMedia(File file) async {
    final isValid = await _fileSizeUtils.checkFileSize(file);
    // ...
  }
}

// Chat Feature
class ChatMessageWidget extends StatelessWidget {
  final FileSizeUtils _fileSizeUtils = FileSizeUtils();

  Widget build(BuildContext context) {
    // Use _fileSizeUtils.calculateMediaSize()
  }
}
```

---

## 🐛 Troubleshooting

### Issue 1: `checkFileSize()` Always Returns False

**Symptom**: File validation fails even for small files

**Possible Causes**:
1. File doesn't exist at provided path
2. Permission denied (iOS/Android)
3. Path is relative instead of absolute

**Debug Steps**:
```dart
final file = File('/data/image.jpg');

// Check if file exists
final exists = await file.exists();
print('File exists: $exists');

// Get actual size
final size = await file.length();
print('File size: ${fileSizeUtils.formatFileSize(size)}');

// Check against limit
final limit = 10 * 1024 * 1024;
print('Within limit: ${size <= limit}');
```

---

### Issue 2: `getStorageFileSize()` Returns 0

**Symptom**: Remote file size is always 0

**Possible Causes**:
1. Invalid URL format
2. File doesn't exist in Storage
3. Network error
4. Storage permissions issue

**Debug Steps**:
```dart
final url = 'gs://bucket/path/file.jpg';

// Step 1: Extract path
final path = fileSizeUtils.extractStoragePathFromUrl(url);
print('Extracted path: $path');
// If empty, URL parsing failed

// Step 2: Try direct Storage API
try {
  final ref = FirebaseStorage.instance.ref(path);
  final metadata = await ref.getMetadata();
  print('File size: ${metadata.size}');
} catch (e) {
  print('Storage error: $e');
  // Check Firebase Storage rules
  // Check network connectivity
}
```

---

### Issue 3: Wrong Size Formatting

**Symptom**: `formatFileSize()` shows "1024 B" instead of "1.0 KB"

**Cause**: Bug in byte thresholds (fixed in current version)

**Verification**:
```dart
// Test all thresholds
print(fileSizeUtils.formatFileSize(1023));        // "1023 B" ✅
print(fileSizeUtils.formatFileSize(1024));        // "1.0 KB" ✅
print(fileSizeUtils.formatFileSize(1048575));     // "1024.0 KB" ✅
print(fileSizeUtils.formatFileSize(1048576));     // "1.0 MB" ✅
print(fileSizeUtils.formatFileSize(1073741824));  // "1.00 GB" ✅
```

---

## 📖 Related Documentation

### Feature Integration

- **[Creation Feature README](/lib/features/creation/README.md)** - Media upload validation
- **[Chat Feature README](/lib/features/chat/README.md)** - Media message size display
- **[Profile Feature README](/lib/features/profile/README.md)** - Profile image validation

### Firebase Storage

- **[Firebase Storage Rules](/firebase/storage.rules)** - Security rules and size limits
- **[Firebase Functions README](/firebase/functions/README.md)** - Storage triggers and cleanup

### Architecture

- **[CLAUDE.md](/CLAUDE.md)** - Project architecture overview
- **[Services README](/lib/services/README.md)** - Service layer documentation

### External Resources

- **[Firebase Storage Documentation](https://firebase.google.com/docs/storage)** - Official Firebase guide
- **[File Size Limits](https://firebase.google.com/docs/storage/quotas-pricing)** - Storage quotas and pricing
- **[Best Practices](https://firebase.google.com/docs/storage/best-practices)** - Storage optimization

---

**Grade**: ⭐⭐⭐⭐ (Production-Ready)
**Last Updated**: 2025-11-23
**Maintained by**: Infrastructure Team
