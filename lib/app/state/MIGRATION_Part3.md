# 🔄 App State 마이그레이션 계획 Part 3

> AppState 리팩토링 및 Feature-First Architecture 적용  
> 작성일: 2025-08-28 | 예상 기간: 2주

## 📌 Executive Summary

**현재 상황**: 555줄의 거대한 AppState 클래스가 13개 이상의 서로 다른 책임을 담당  
**목표**: Feature별로 상태를 분리하여 유지보수성과 테스트 가능성 향상  
**방법**: 점진적 마이그레이션으로 기능 유지하며 리팩토링

## 🎯 마이그레이션 목표

### Before (현재)
```
lib/app/state/
├── app_state.dart (555줄 - 모든 것)
└── providers/
    └── navigation_provider.dart (185줄)
```

### After (목표)
```
lib/
├── app/state/
│   ├── app_state.dart (50줄 - 최소 전역 상태)
│   ├── app_preferences.dart (100줄 - 설정)
│   └── providers/
│       ├── navigation_provider.dart (현재 유지)
│       └── app_config_provider.dart (신규)
│
├── features/
│   ├── posts/presentation/providers/
│   │   ├── content_creation_provider.dart (200줄)
│   │   └── content_box_model.dart (100줄)
│   │
│   ├── media/presentation/providers/
│   │   ├── media_upload_provider.dart (150줄)
│   │   └── image_processing_provider.dart (100줄)
│   │
│   └── auth/presentation/providers/
│       └── user_provider.dart (80줄)
```

## 📊 현재 AppState 분석 및 분리 계획

### 1. 언어 및 사용자 설정 (30줄)
```dart
// 현재 위치: app_state.dart
String selectedLang;
String displayName;

// 이동 위치: app/state/app_preferences.dart
class AppPreferences extends ChangeNotifier {
  String language;
  String displayName;
  ThemeMode theme;
}
```

### 2. 콘텐츠 생성 상태 (300줄)
```dart
// 현재 위치: app_state.dart
String uploadTextA/B;
List<String> uploadImageA/B;
String uploadVideoA/B;
String uploadYoutubeA/B;
String questionTitle;
String questionDescription;

// 이동 위치: features/posts/presentation/providers/content_creation_provider.dart
class ContentCreationProvider extends ChangeNotifier {
  ContentBox boxA = ContentBox();
  ContentBox boxB = ContentBox();
  QuestionData question = QuestionData();
}
```

### 3. 미디어 처리 상태 (150줄)
```dart
// 현재 위치: app_state.dart
List<File> tempImageFilesA/B;
List<double> uploadImageAspectRatioA/B;
List<String> localImagePathsA/B;
List<String> assetEntityIdsA/B;

// 이동 위치: features/media/presentation/providers/media_upload_provider.dart
class MediaUploadProvider extends ChangeNotifier {
  MediaQueue uploadQueue;
  Map<String, MediaMetadata> metadata;
  Map<String, File> tempFiles;
}
```

### 4. UI 상태 (75줄)
```dart
// 현재 위치: app_state.dart
bool isVerticalLayout;
int uploadImageEditing;
int uploadTextEditing;

// 이동 위치: features/posts/presentation/providers/ui_state_provider.dart
class PostCreationUIState extends ChangeNotifier {
  LayoutType layout;
  EditingState editing;
  ValidationState validation;
}
```

## 📝 상세 마이그레이션 단계

### Step 1: 새로운 Provider 구조 생성 (Day 1-2)

#### 1.1 ContentBox 모델 생성
```dart
// features/posts/domain/models/content_box.dart
class ContentBox {
  String? text;
  List<String> imageUrls = [];
  String? videoUrl;
  String? youtubeUrl;
  String? linkUrl;
  
  // 헬퍼 메서드
  bool get isEmpty => ...;
  bool get hasMedia => ...;
  void clear() => ...;
}
```

#### 1.2 ContentCreationProvider 생성
```dart
// features/posts/presentation/providers/content_creation_provider.dart
class ContentCreationProvider extends ChangeNotifier {
  ContentBox _boxA = ContentBox();
  ContentBox _boxB = ContentBox();
  
  String _title = '';
  String _description = '';
  
  ContentBox get boxA => _boxA;
  ContentBox get boxB => _boxB;
  
  void updateBoxA({String? text, List<String>? images}) {
    // 업데이트 로직
    notifyListeners();
  }
}
```

### Step 2: 점진적 UI 마이그레이션 (Day 3-5)

#### 2.1 새 Provider와 기존 AppState 동시 지원
```dart
// 임시 브리지 패턴
class ContentCreationBridge {
  final AppState appState;
  final ContentCreationProvider newProvider;
  
  void syncToNew() {
    newProvider.updateBoxA(
      text: appState.uploadTextA,
      images: appState.uploadImageA,
    );
  }
  
  void syncToOld() {
    appState.uploadTextA = newProvider.boxA.text;
    appState.uploadImageA = newProvider.boxA.imageUrls;
  }
}
```

#### 2.2 UI 컴포넌트 점진적 업데이트
```dart
// Phase 1: 읽기만 새 Provider 사용
final content = context.watch<ContentCreationProvider>();
Text(content.boxA.text ?? '');

// Phase 2: 쓰기도 새 Provider 사용
content.updateBoxA(text: newText);

// Phase 3: 기존 AppState 참조 제거
// appState.uploadTextA 제거
```

### Step 3: 미디어 처리 분리 (Day 6-8)

#### 3.1 MediaUploadProvider 생성
```dart
class MediaUploadProvider extends ChangeNotifier {
  final _uploadTasks = <String, UploadTask>{};
  final _tempFiles = <String, File>{};
  
  Future<String> uploadImage(File file, {
    required String box, // 'A' or 'B'
    required int index,
  }) async {
    final taskId = generateTaskId();
    _tempFiles[taskId] = file;
    
    // Firebase Storage 업로드
    final url = await uploadToStorage(file);
    
    _tempFiles.remove(taskId);
    notifyListeners();
    
    return url;
  }
}
```

### Step 4: 기존 코드 제거 (Day 9-10)

#### 4.1 Deprecated 마킹
```dart
@deprecated
class AppState extends ChangeNotifier {
  @deprecated
  String get uploadTextA => '';
  // ...
}
```

#### 4.2 단계별 제거
1. 사용하지 않는 메서드 제거
2. 중복 필드 제거
3. 브리지 코드 제거
4. 최종 정리

### Step 5: 테스트 작성 (Day 11-12)

#### 5.1 단위 테스트
```dart
// test/features/posts/providers/content_creation_provider_test.dart
void main() {
  group('ContentCreationProvider', () {
    test('should update box A text', () {
      final provider = ContentCreationProvider();
      provider.updateBoxA(text: 'New text');
      expect(provider.boxA.text, 'New text');
    });
  });
}
```

#### 5.2 통합 테스트
```dart
// test/integration/post_creation_test.dart
testWidgets('Post creation flow', (tester) async {
  // 전체 플로우 테스트
});
```

## 🚀 실행 계획

### Week 1: 준비 및 구조 생성
- [ ] Day 1: Provider 구조 설계
- [ ] Day 2: 모델 클래스 생성
- [ ] Day 3: ContentCreationProvider 구현
- [ ] Day 4: MediaUploadProvider 구현
- [ ] Day 5: 브리지 패턴 구현

### Week 2: 마이그레이션 및 테스트
- [ ] Day 6-7: UI 컴포넌트 업데이트
- [ ] Day 8: 기존 코드 정리
- [ ] Day 9-10: 테스트 작성
- [ ] Day 11: 성능 테스트
- [ ] Day 12: 문서 업데이트

## 📈 성공 지표

### 정량적 지표
- ✅ AppState 크기: 555줄 → 50줄 이하
- ✅ Provider 수: 1개 → 5개+
- ✅ 테스트 커버리지: 0% → 80%+
- ✅ 빌드 시간: 변화 없음

### 정성적 지표
- ✅ 코드 가독성 향상
- ✅ 유지보수성 개선
- ✅ Feature 독립성 확보
- ✅ 테스트 가능성 향상

## ⚠️ 리스크 및 대응 방안

### Risk 1: 기능 손상
**대응**: 브리지 패턴으로 점진적 마이그레이션

### Risk 2: 성능 저하
**대응**: 프로파일링 및 최적화

### Risk 3: 사용자 영향
**대응**: Feature 플래그로 롤백 가능하도록

## 🔄 롤백 계획

### 즉시 롤백 가능한 구조
```dart
// feature_flags.dart
class FeatureFlags {
  static bool useNewContentProvider = false;
}

// UI에서
final provider = FeatureFlags.useNewContentProvider
    ? context.watch<ContentCreationProvider>()
    : context.watch<AppState>();
```

## 📚 참고 자료

- [Provider 패키지 문서](https://pub.dev/packages/provider)
- [Flutter 상태 관리 가이드](https://flutter.dev/docs/development/data-and-backend/state-mgmt)
- [Feature-First Architecture](../../FEATURE_ARCHITECTURE.md)

## 🏁 체크리스트

### 마이그레이션 전
- [ ] 현재 상태 백업
- [ ] 테스트 계획 수립
- [ ] 영향 분석 완료

### 마이그레이션 중
- [ ] 일일 진행상황 체크
- [ ] 기능 테스트
- [ ] 성능 모니터링

### 마이그레이션 후
- [ ] 전체 테스트 실행
- [ ] 문서 업데이트
- [ ] 팀 공유

---

*이 문서는 AppState 리팩토링의 구체적인 실행 계획입니다.*
*2주간의 점진적 마이그레이션으로 안전하게 진행됩니다.*