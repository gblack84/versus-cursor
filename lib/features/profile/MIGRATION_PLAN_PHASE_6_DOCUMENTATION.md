## 📚 Phase 6: 통합 테스트 및 검증 - 문서화

**완료일**: 2025-01-20
**상태**: ✅ 문서화 완료 (런타임 테스트는 앱 통합 후 진행 예정)

### 📋 작업 배경

전체 앱에 누락된 파일들이 많아 런타임 실행이 불가능한 상황입니다.
하지만 Phase 5에서 flutter analyze로 ProfileModule의 모든 41개 의존성을 검증 완료했습니다.

따라서 Phase 6는 **문서화 중심 검증**으로 전환하여:
1. DI 등록 확인 (완료)
2. 하이브리드 메서드 사용 가이드 작성
3. Widget-Provider 연동 예제 작성
4. Week 7 레거시 제거 로드맵 작성

### 1️⃣ DI 컨테이너 통합 검증 ✅

#### ProfileModule 등록 확인

**파일**: `/lib/app/di/profile_module.dart`
- 41개 의존성 등록 완료 (4 DataSources + 6 Repositories + 25 UseCases + 6 Providers)
- flutter analyze 0 에러 (검증 완료)

**파일**: `/lib/app/di/injection.dart` (Line 26)
```dart
static final List<FeatureModule> _modules = [
  CoreModule(),
  ProfileModule(),  // ✅ 등록 완료
  PostsModule(),
  AuthModule(),
  // ...
];
```

**파일**: `/lib/main.dart` (Line 37-41)
```dart
// Initialize Dependency Injection (Legacy System)
await setupDependencyInjection();

// Initialize Feature Modules (New System - FeatureModule Pattern)
// This registers ProfileModule, PostsModule, etc.
await DIContainer.initialize();
```

#### 검증 결과
- ✅ ProfileModule이 injection.dart에 정상 등록
- ✅ main.dart에서 DIContainer.initialize() 호출 추가
- ✅ flutter analyze로 컴파일 에러 0개 확인

---

### 2️⃣ 하이브리드 메서드 사용 가이드

ProfileProvider에는 4개의 @Deprecated 메서드가 있습니다.
이들은 Phase 4.5에서 레거시 위젯을 무중단으로 전환하기 위해 추가되었습니다.

#### 📌 addExpertiseLegacy / removeExpertiseLegacy

**목적**: Week 3 - Expertise 선택 위젯 (expertise_select_widget.dart)에서 사용

**사용 예제**:
```dart
// expertise_select_widget.dart
final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

// Expertise 추가
await profileProvider.addExpertiseLegacy(
  currentUserReference!,  // DocumentReference<UsersModel>
  selectedExpertise,       // String
);

// Expertise 제거
await profileProvider.removeExpertiseLegacy(
  currentUserReference!,
  expertiseToRemove,
);
```

**동작 방식**:
1. `currentUserDocument.expertise` 배열 가져오기
2. FieldValue.arrayUnion/arrayRemove로 Firestore 업데이트
3. AppState.update() 호출하여 전역 상태 갱신
4. 성공/실패 boolean 반환

#### 📌 addInterestLegacy / removeInterestLegacy

**목적**: Week 4 - Interests/Hobbies 선택 위젯 (hobbies_select_widget.dart, agreed_select_widget.dart)에서 사용

**사용 예제**:
```dart
// hobbies_select_widget.dart
final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

// Interest 추가
await profileProvider.addInterestLegacy(
  currentUserReference!,
  selectedInterest,
);

// Interest 제거
await profileProvider.removeInterestLegacy(
  currentUserReference!,
  interestToRemove,
);
```

**동작 방식**:
1. `currentUserDocument.interests` 배열 가져오기
2. FieldValue.arrayUnion/arrayRemove로 Firestore 업데이트
3. AppState.update() 호출하여 전역 상태 갱신
4. 성공/실패 boolean 반환

#### ⚠️ 중요 사항

1. **DocumentReference 필수**: 모든 메서드는 `DocumentReference<UsersModel>` 파라미터 필요
2. **AppState 의존**: 레거시 위젯이 AppState를 사용하므로 업데이트 필수
3. **Week 7 제거 예정**: 완전 전환 후 이 메서드들은 삭제됩니다

---

### 3️⃣ Widget-Provider 연동 예제

Phase 4.5에서 6개 위젯을 하이브리드 전환했습니다.
각 위젯의 Provider 사용 패턴을 정리합니다.

#### 📌 P0 위젯 #1: profile_page_widget.dart

**전환 내용**: StreamBuilder → Consumer 패턴

**Before (Legacy)**:
```dart
StreamBuilder<UsersModel>(
  stream: UsersModel.getDocument(userRef),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return Center(child: CircularProgressIndicator());
    }
    final userData = snapshot.data!;
    return Text(userData.displayName);
  },
)
```

**After (Clean Architecture)**:
```dart
Consumer<ProfileProvider>(
  builder: (context, profileProvider, _) {
    if (profileProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    final profile = profileProvider.profile;
    if (profile == null) return Text('No profile data');
    return Text(profile.displayName);
  },
)
```

**사용 방법**:
1. initState()에서 `_profileProvider.loadProfile(userId)` 호출
2. Consumer 위젯으로 자동 리빌드
3. `profileProvider.profile`에서 데이터 접근

---

#### 📌 P0 위젯 #2: expertise_select_widget.dart

**전환 내용**: Firestore 직접 쓰기 → ProfileProvider 메서드

**Before (Legacy)**:
```dart
await currentUserReference!.update({
  ...mapToFirestore({
    'expertise': FieldValue.arrayUnion([text]),
  }),
});
```

**After (Clean Architecture)**:
```dart
final _profileProvider = Provider.of<ProfileProvider>(context, listen: false);

final success = await _profileProvider.addExpertiseLegacy(
  currentUserReference!,
  text,
);

if (success) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('전문 분야가 추가되었습니다')),
  );
}
```

**사용 방법**:
1. Provider.of로 ProfileProvider 가져오기
2. addExpertiseLegacy/removeExpertiseLegacy 호출
3. 반환값(boolean)으로 성공/실패 처리

---

#### 📌 P1 위젯 #1: hobbies_select_widget.dart

**전환 내용**: Firestore 직접 쓰기 → ProfileProvider 메서드 (Interests)

**특징**: expertise_select_widget과 동일한 패턴이지만 `interests` 필드 사용

```dart
// 추가
await _profileProvider.addInterestLegacy(currentUserReference!, text);

// 제거
await _profileProvider.removeInterestLegacy(currentUserReference!, text);
```

---

#### 📌 P1 위젯 #2: agreed_select_widget.dart

**전환 내용**: 메서드 재사용 (hobbies와 동일 필드)

**특징**:
- hobbies_select_widget과 동일한 `interests` 필드 사용
- addInterestLegacy/removeInterestLegacy 메서드 재사용
- 작업 시간 50% 단축 (30분 → 15분)

---

#### 📌 P1 위젯 #3: user_info_input_widget.dart

**전환 내용**: AppState 직접 수정 제거 + UseCase 기반 로드

**Before (Legacy - Critical Gap)**:
```dart
// ❌ AppState 직접 수정 (Clean Architecture 위반)
AppState().selectedLang = AppLocalizations.of(context).languageCode;
AppState().displayName = _model.displayNameTextController.text;
```

**After (Clean Architecture)**:
```dart
// ProfileProvider와 AuthUserStreamWidget이 자동으로 상태 업데이트
// UseCase 기반 프로필 로드
await _profileProvider.loadProfile(currentUserUid);
_model.userDocument = _profileProvider.profile;
```

**해결된 Critical Gap**:
- AppState 직접 수정 제거
- ProfileProvider가 상태 관리
- AuthUserStreamWidget이 자동 동기화

---

#### 📌 P2 위젯 #1: character_detail_page_widget.dart

**전환 내용**: CharactersModel 직접 쿼리 → CharactersProvider UseCase

**Before (Legacy)**:
```dart
_model.charactersDocument = await CharactersModel.getDocumentOnce(
  charactersRef
);
```

**After (Clean Architecture)**:
```dart
Consumer<CharactersProvider>(
  builder: (context, charactersProvider, _) {
    // initState에서 loadAvailableCharacters 호출
    final characters = charactersProvider.characters;
    return ListView.builder(...);
  },
)
```

**사용 방법**:
1. initState()에서 `_charactersProvider.loadAvailableCharacters()` 호출
2. Consumer로 리빌드
3. `charactersProvider.characters` 리스트 사용

---

### 4️⃣ Week 7 준비: 레거시 제거 로드맵

#### 📅 완전 전환 일정

**Week 7 (예정)**: @Deprecated 메서드 제거 및 완전 Clean Architecture 전환

#### 🗑️ 제거 대상

1. **ProfileProvider @Deprecated 메서드 (4개)**:
   ```dart
   @Deprecated('Phase 4.5 하이브리드 전용. Week 7에 제거 예정.')
   Future<bool> addExpertiseLegacy(...)

   @Deprecated('Phase 4.5 하이브리드 전용. Week 7에 제거 예정.')
   Future<bool> removeExpertiseLegacy(...)

   @Deprecated('Phase 4.5 하이브리드 전용. Week 7에 제거 예정.')
   Future<bool> addInterestLegacy(...)

   @Deprecated('Phase 4.5 하이브리드 전용. Week 7에 제거 예정.')
   Future<bool> removeInterestLegacy(...)
   ```

2. **레거시 위젯 완전 전환**:
   - expertise_select_widget.dart → 순수 UseCase 기반
   - hobbies_select_widget.dart → 순수 UseCase 기반
   - agreed_select_widget.dart → 순수 UseCase 기반

#### 🔄 전환 전략

**Option 1: 새 UseCase 생성** (권장)
```dart
// UpdateUserExpertiseUseCase 생성
class UpdateUserExpertiseUseCase {
  final IUserRepository repository;

  Future<Result<void>> addExpertise(String userId, String expertise);
  Future<Result<void>> removeExpertise(String userId, String expertise);
}

// Widget에서 사용
final result = await _updateExpertiseUseCase.addExpertise(userId, text);
result.when(
  success: (_) => showSuccessMessage(),
  failure: (error) => showErrorMessage(error),
);
```

**Option 2: 기존 UpdateUserProfileUseCase 확장**
```dart
// ProfileUpdateParams 확장
class ProfileUpdateParams {
  final String? displayName;
  final List<String>? expertiseToAdd;
  final List<String>? expertiseToRemove;
  final List<String>? interestsToAdd;
  final List<String>? interestsToRemove;
}
```

#### ✅ 완전 전환 체크리스트

- [ ] UpdateUserExpertiseUseCase 생성
- [ ] UpdateUserInterestsUseCase 생성
- [ ] expertise_select_widget 순수 UseCase로 전환
- [ ] hobbies_select_widget 순수 UseCase로 전환
- [ ] agreed_select_widget 순수 UseCase로 전환
- [ ] @Deprecated 메서드 4개 제거
- [ ] AppState 의존성 완전 제거
- [ ] 통합 테스트 실행
- [ ] Flutter analyze 0 에러 확인
- [ ] 프로덕션 배포

---

### 📊 Phase 6 성과 요약

| 항목 | 상태 | 비고 |
|------|------|------|
| **DI 컨테이너 검증** | ✅ 완료 | ProfileModule 등록 확인, flutter analyze 통과 |
| **하이브리드 메서드 문서화** | ✅ 완료 | 4개 @Deprecated 메서드 사용 가이드 |
| **Widget-Provider 예제** | ✅ 완료 | 6개 위젯 전환 패턴 정리 |
| **Week 7 로드맵** | ✅ 완료 | 레거시 제거 계획 수립 |
| **런타임 테스트** | ⏳ 보류 | 앱 통합 완료 후 진행 예정 |

### 🎯 다음 단계

**Option A: 앱 통합 완료 후 런타임 테스트**
- 누락된 파일들 해결
- flutter run으로 전체 앱 실행
- ProfileModule 런타임 검증

**Option B: Week 7 완전 전환 시작** (권장)
- @Deprecated 메서드 제거
- 순수 Clean Architecture 전환
- 새 UseCase 생성

---

**작성자**: Profile Feature Migration Team
**태그**: #Phase6 #문서화완료 #DI검증 #하이브리드패턴 #Week7준비
