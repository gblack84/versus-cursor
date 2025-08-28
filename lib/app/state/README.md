# 🎯 App State 레이어

> 애플리케이션 전역 상태 관리 시스템  
> 최종 업데이트: 2025-08-28 | 버전: 1.0.0

## 📋 개요

App State는 Versus Space 애플리케이션의 전역 상태 관리를 담당하는 레이어입니다.
Provider 패턴을 사용하여 상태 변화를 구독하고 UI를 업데이트합니다.

## 🏗️ 현재 디렉토리 구조

```
lib/app/state/
├── app_state.dart          # 555줄 - 전역 상태 관리 (⚠️ 리팩토링 필요)
└── providers/              # Provider 패턴 구현체들
    └── navigation_provider.dart  # 185줄 - 네비게이션 상태 관리 (✅ 적절)
```

## 🔍 현재 코드 분석

### 1. app_state.dart (555줄)

#### 핵심 구성요소
```dart
class AppState extends ChangeNotifier {
  // 싱글톤 패턴 구현
  static AppState _instance = AppState._internal();
  
  // 언어 및 사용자 설정
  String selectedLang;       // 선택된 언어
  String displayName;         // 표시 이름
  
  // 콘텐츠 업로드 상태 (A/B 박스)
  String uploadTextA/B;       // 텍스트 콘텐츠
  List<String> uploadImageA/B; // 이미지 URL
  String uploadVideoA/B;      // 비디오 URL
  String uploadYoutubeA/B;    // YouTube 링크
  
  // 질문 작성 상태
  String questionTitle;       // 질문 제목
  String questionDescription; // 질문 설명
  
  // UI 상태
  bool isVerticalLayout;      // 레이아웃 방향
  int uploadImageEditing;     // 편집 중인 이미지 인덱스
  
  // 파일 처리
  List<File> tempImageFilesA/B;  // 임시 파일 저장
  List<double> uploadImageAspectRatioA/B; // 이미지 비율
  List<String> localImagePathsA/B; // 로컬 경로
  List<String> assetEntityIdsA/B;  // Asset ID
}
```

#### 문제점
- ❌ **단일 책임 원칙 위반**: 555줄에 너무 많은 책임
- ❌ **Feature 의존성**: 콘텐츠 생성 로직이 전역 상태에 포함
- ❌ **중복 코드**: A/B 박스 처리 로직이 반복됨
- ❌ **메모리 관리**: 파일 객체들이 적절히 해제되지 않을 위험
- ❌ **테스트 어려움**: 너무 많은 상태가 결합되어 있음

### 2. providers/navigation_provider.dart (185줄)

#### 핵심 구성요소
```dart
// 듀얼 모드 네비게이션 관리
enum NavigationMode { main, chat }

class NavigationProvider extends ChangeNotifier {
  NavigationMode mode;        // 현재 모드
  int mainTabIndex;           // 메인 모드 탭 인덱스
  int chatTabIndex;           // 채팅 모드 탭 인덱스
  
  // 모드별 네비게이션 아이템 정의
  static const mainItems = [...];  // 홈/검색/작성/채팅/유저
  static const chatItems = [...];  // 채팅/친구/검색/홈
}
```

#### 장점
- ✅ **단일 책임**: 네비게이션 상태만 관리
- ✅ **명확한 구조**: 듀얼 모드 시스템이 잘 구현됨
- ✅ **테스트 가능**: 독립적이고 테스트하기 용이

## ⚠️ 현재 문제점 종합

### 1. AppState 과부하
- 555줄에 13개 이상의 서로 다른 책임
- Feature별 상태 분리 필요
- 메모리 누수 위험

### 2. Feature 결합도
- 콘텐츠 생성 로직이 전역 상태에 직접 포함
- UI 상태와 비즈니스 로직 혼재

### 3. 코드 중복
- A/B 박스 처리 로직 중복 (각각 100줄+)
- 리스트 관리 메서드 반복

## 🎯 Feature-First Architecture 리팩토링 계획

### 이상적인 구조
```
lib/
├── app/state/
│   ├── app_state.dart          # 최소한의 전역 상태
│   ├── app_preferences.dart    # 앱 설정 (언어, 테마)
│   └── providers/
│       └── navigation_provider.dart  # 네비게이션 (현재 유지)
│
├── features/
│   ├── posts/
│   │   └── presentation/
│   │       └── providers/
│   │           ├── content_creation_provider.dart  # 콘텐츠 생성 상태
│   │           └── upload_manager_provider.dart    # 업로드 관리
│   │
│   ├── auth/
│   │   └── presentation/
│   │       └── providers/
│   │           └── user_provider.dart  # 사용자 정보
│   │
│   └── media/
│       └── presentation/
│           └── providers/
│               └── media_upload_provider.dart  # 미디어 업로드
```

### 상태 분리 계획

#### 1. 최소 AppState (50줄 이하)
```dart
class AppState extends ChangeNotifier {
  // 앱 전체 설정만
  String selectedLanguage;
  ThemeMode themeMode;
  bool isFirstLaunch;
}
```

#### 2. ContentCreationProvider (posts feature)
```dart
class ContentCreationProvider extends ChangeNotifier {
  // A/B 콘텐츠 관리
  ContentBox boxA = ContentBox();
  ContentBox boxB = ContentBox();
  
  // 질문 정보
  String title;
  String description;
  
  // 레이아웃
  LayoutType layoutType;
}
```

#### 3. MediaUploadProvider (media feature)
```dart
class MediaUploadProvider extends ChangeNotifier {
  // 업로드 상태 관리
  Map<String, UploadTask> uploadTasks;
  List<File> tempFiles;
  
  // 메서드
  Future<String> uploadImage(File file);
  void cancelUpload(String taskId);
}
```

## 📊 리팩토링 우선순위

| 작업 | 우선순위 | 예상 시간 | 난이도 |
|------|---------|----------|--------|
| AppState 분리 | 🔴 높음 | 3일 | 높음 |
| Provider 구조 개선 | 🟡 중간 | 2일 | 중간 |
| 테스트 추가 | 🟡 중간 | 2일 | 낮음 |
| 문서화 | 🟢 낮음 | 1일 | 낮음 |

## 📝 사용 가이드

### 현재 사용 방법
```dart
// 전역 상태 접근
final appState = Provider.of<AppState>(context);
appState.uploadTextA = "새로운 텍스트";

// 네비게이션 상태
final navProvider = Provider.of<NavigationProvider>(context);
navProvider.switchToChatMode();
```

### 리팩토링 후 사용 방법
```dart
// Feature별 상태 접근
final contentProvider = context.watch<ContentCreationProvider>();
contentProvider.updateBoxA(text: "새로운 텍스트");

// 네비게이션 (현재 유지)
final navProvider = context.watch<NavigationProvider>();
navProvider.switchToChatMode();
```

## 🔗 연관 파일 및 의존성

### 직접 의존하는 파일들
- `/lib/main.dart` - Provider 초기화
- `/lib/posts/in_put_post_image/` - 콘텐츠 생성 UI
- `/lib/components/main_navigation_shell.dart` - 네비게이션 UI

### 영향받을 Feature들
- **posts**: 콘텐츠 생성 로직 이동
- **media**: 미디어 업로드 로직 분리
- **auth**: 사용자 정보 분리

## ⏱️ 마이그레이션 타임라인

### Phase 1: 분석 및 계획 (1일)
- [ ] 의존성 매핑
- [ ] 영향 분석
- [ ] 테스트 계획 수립

### Phase 2: Provider 분리 (3일)
- [ ] ContentCreationProvider 생성
- [ ] MediaUploadProvider 생성
- [ ] UserProvider 생성

### Phase 3: 점진적 마이그레이션 (3일)
- [ ] UI 컴포넌트 업데이트
- [ ] 이전 코드 제거
- [ ] 테스트 작성

### Phase 4: 최적화 (2일)
- [ ] 성능 프로파일링
- [ ] 메모리 최적화
- [ ] 문서 업데이트

## ⚡ 성능 고려사항

### 메모리 관리
- File 객체 적절한 해제
- 불필요한 리빌드 방지
- 큰 이미지 파일 처리 최적화

### 상태 업데이트
- 세분화된 notifyListeners() 호출
- Consumer 위젯 최적화
- Selector 패턴 활용

## 🚨 주의사항

1. **점진적 마이그레이션**: 한 번에 모든 것을 변경하지 말 것
2. **하위 호환성**: 기존 코드가 계속 작동하도록 유지
3. **테스트 우선**: 변경 전 테스트 작성
4. **문서화**: 모든 변경사항 문서화

---

*이 문서는 App State 레이어의 현재 상태와 개선 방안을 담고 있습니다.*
*즉시 리팩토링이 필요한 상태입니다.*