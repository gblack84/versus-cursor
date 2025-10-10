# Profile Feature - Presentation Layer

> 최종 업데이트: 2025-01-26 | 버전: 4.0.0 | Clean Architecture v4.0

## 🎨 개요

Presentation Layer는 Clean Architecture의 최외곽 계층으로, **사용자 인터페이스(UI)와 상태 관리**를 담당합니다. Flutter 위젯, 상태 관리 Provider, UI 모델을 포함하며, Domain Layer의 UseCase를 통해 비즈니스 로직을 실행합니다.

### 📌 현재 구현 상태

- ✅ **화면(Screens)**: 10개 주요 화면 (온보딩, 프로필 정보, 설정)
- ⏳ **위젯(Widgets)**: 구현 예정 (Phase 4)
- ⏳ **Provider**: 구현 예정 (Phase 4.5)
  - ProfileProvider (하이브리드 운영)
  - SettingsProvider
  - OnboardingProvider
- ⏳ **Constants**: 구현 예정 (UI 상수 통합)

### 핵심 특징

- 🔄 **하이브리드 운영** (Phase 4.5): StreamBuilder (레거시) + UseCase (신규) 병존
- 🎯 **Clean Architecture 마이그레이션 중**: AppState 의존성 점진적 제거
- 🎨 **온보딩 플로우**: 6단계 사용자 가이드 완성
- 👤 **프로필 정보 화면**: 사용자 정보 표시 및 편집
- ⚙️ **설정 화면**: 언어, 알림, 프라이버시 설정

---

## 🏗️ 전체 구조도

```
lib/features/profile/presentation/
│
├── 📁 providers/                    # 🔄 상태 관리 (구현 예정)
│   ├── 📄 profile_provider.dart     # 프로필 상태 관리
│   ├── 📄 settings_provider.dart    # 설정 상태 관리
│   ├── 📄 onboarding_provider.dart  # 온보딩 진행 관리
│   └── 📄 README.md                 # Provider 상세 문서
│
├── 📁 screens/                      # 🖼️ UI 화면들 [10개]
│   ├── 📁 onboarding/               # 온보딩 플로우 (6단계)
│   │   ├── 📄 age_agreement_page.dart         # 1. 연령 동의
│   │   └── 📁 interest_selection/   # 관심사 선택
│   │       ├── 📄 job_category_select.dart    # 2. 직업 카테고리
│   │       ├── 📄 expertise_select.dart       # 3. 전문분야 (최대 4개)
│   │       ├── 📄 hobbies_select.dart         # 4. 취미 (최대 8개)
│   │       └── 📄 README.md         # Interest 가이드
│   │
│   ├── 📁 user_info/                # 사용자 정보 화면
│   │   ├── 📄 profile_page.dart              # 프로필 보기
│   │   ├── 📄 profile_edit_page.dart         # 프로필 편집
│   │   ├── 📄 character_detail/              # 캐릭터 상세
│   │   └── 📄 language_selector/             # 언어 선택
│   │
│   └── 📄 README.md                 # Screens 전체 가이드
│
├── 📁 widgets/                      # 🧩 재사용 가능 위젯들 (구현 예정)
│   ├── 📁 profile/                  # 프로필 전용 위젯
│   ├── 📁 onboarding/               # 온보딩 전용 위젯
│   ├── 📁 components/               # 공통 컴포넌트
│   └── 📄 README.md                 # Widgets 전체 가이드
│
└── 📁 constants/                    # 🎨 UI 상수 (구현 예정)
    ├── 📄 onboarding_constants.dart # 온보딩 단계 및 메시지
    ├── 📄 profile_constants.dart    # 프로필 필드 제한
    └── 📄 constants.dart            # 통합 export
```

---

## 📂 디렉토리별 상세 설명

### 1. providers/ - 상태 관리 (구현 예정, Phase 4.5)

Profile Feature는 **하이브리드 Provider 아키텍처**를 적용하여 레거시와 신규 시스템을 점진적으로 전환합니다.

#### 1.1 하이브리드 Provider 전략

```
Week 1-2: Adapter 기반 Provider 생성
    ↓
Week 3-4: StreamBuilder → Consumer + watchProfileLegacy()
    ↓
Week 5-6: UseCase 기반 메서드로 전환
    ↓
Week 7: 레거시 Stream 메서드 완전 제거
```

#### 1.2 ProfileProvider (핵심)

**책임**: 프로필 조회/수정 상태 관리 (하이브리드 운영)

```dart
class ProfileProvider extends ChangeNotifier {
  final GetUserProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UserProfileAdapter _adapter;

  UserProfile? _profile;
  LoadingState _loadingState = LoadingState.idle;
  String? _errorMessage;

  UserProfile? get profile => _profile;
  LoadingState get loadingState => _loadingState;

  // ━━━ 레거시 지원: StreamBuilder 유지 ━━━
  Stream<UserProfile> watchProfileLegacy(String userId) {
    return UsersModel.getDocument(ref).map((usersModel) {
      return _adapter.toDomain(usersModel);
    });
  }

  // ━━━ 신규 방식: UseCase 기반 ━━━
  Future<void> loadProfile(String userId) async {
    _loadingState = LoadingState.loading;
    notifyListeners();

    final result = await _getProfileUseCase.execute(userId: userId);
    result.fold(
      (failure) => _errorMessage = failure.getUserMessage(),
      (profile) => _profile = profile,
    );

    _loadingState = _loadingState == LoadingState.loading
        ? LoadingState.success
        : LoadingState.error;
    notifyListeners();
  }

  Future<void> updateProfile(UpdateProfileParams params) async {
    final result = await _updateProfileUseCase.execute(params: params);
    if (result.isSuccess) {
      await loadProfile(params.userId);
    }
  }
}
```

#### 1.3 SettingsProvider

**책임**: 사용자 설정 관리 (알림, 언어, 프라이버시)

```dart
class SettingsProvider extends ChangeNotifier {
  final ChangeSettingsUseCase _changeSettingsUseCase;

  UserSettings? _settings;
  bool _isLoading = false;

  UserSettings? get settings => _settings;

  Future<void> updateNotificationSetting(String key, bool value) async {
    final updatedSettings = _settings!.copyWith(
      notifyOnVoteRequests: key == 'voteRequests' ? value : _settings!.notifyOnVoteRequests,
      notifyOnComments: key == 'comments' ? value : _settings!.notifyOnComments,
    );

    await _changeSettingsUseCase.execute(
      userId: _settings!.userId,
      settings: updatedSettings,
    );
  }

  Future<void> changeLanguage(String language) async {
    final updatedSettings = _settings!.copyWith(language: language);
    await _changeSettingsUseCase.execute(
      userId: _settings!.userId,
      settings: updatedSettings,
    );
  }
}
```

#### 1.4 OnboardingProvider

**책임**: 온보딩 진행 상태 관리

```dart
class OnboardingProvider extends ChangeNotifier {
  final CompleteOnboardingStepUseCase _completeStepUseCase;

  OnboardingStep _currentStep = OnboardingStep.ageAgreement;
  Map<String, dynamic> _tempData = {};
  bool _isComplete = false;

  OnboardingStep get currentStep => _currentStep;
  double get progressPercentage =>
      (_currentStep.index + 1) / OnboardingStep.values.length * 100;

  Future<void> completeStep(OnboardingStep step, Map<String, dynamic> data) async {
    final params = CompleteOnboardingStepParams(
      userId: currentUserId,
      step: step,
      data: data,
    );

    final result = await _completeStepUseCase.execute(params: params);
    if (result.isSuccess) {
      _goToNextStep();
    }
  }

  void _goToNextStep() {
    if (_currentStep == OnboardingStep.profileSetup) {
      _isComplete = true;
    } else {
      _currentStep = OnboardingStep.values[_currentStep.index + 1];
    }
    notifyListeners();
  }
}
```

---

### 2. screens/ - UI 화면

Profile Feature는 **10개 주요 화면**으로 구성됩니다:

#### 2.1 onboarding/ - 온보딩 플로우 (6단계)

##### 📄 age_agreement_page.dart (1단계)
**책임**: 13세 이상 연령 확인

```dart
class AgeAgreementPage extends StatefulWidget {
  static String routeName = 'AgeAgreementPage';
}

// UI: 체크박스 + "13세 이상입니다" 확인
// 검증: age >= 13
// 완료: OnboardingProvider.completeStep(ageAgreement, {age: 13})
```

##### 📄 job_category_select.dart (2단계)
**책임**: 직업 카테고리 및 직업명 선택

```dart
class JobCategorySelect extends StatefulWidget {
  // 1. 직업 카테고리 선택 (리스트)
  // 2. 카테고리별 직업명 선택 (하위 리스트)
  // 완료: OnboardingProvider.completeStep(jobSelection, {
  //   jobCategory: '개발자',
  //   jobName: '백엔드 개발자',
  // })
}
```

##### 📄 expertise_select.dart (3단계)
**책임**: 전문분야 선택 (최대 4개)

```dart
class ExpertiseSelect extends StatefulWidget {
  // GridView 전문분야 선택
  // 최대 4개 제한
  // 완료: OnboardingProvider.completeStep(expertiseSelection, {
  //   expertise: ['Flutter', 'Dart', 'Firebase'],
  // })
}
```

##### 📄 hobbies_select.dart (4단계)
**책임**: 취미 선택 (최대 8개)

```dart
class HobbiesSelect extends StatefulWidget {
  // GridView 취미 선택
  // 최대 8개 제한
  // 완료: OnboardingProvider.completeStep(hobbySelection, {
  //   hobbies: ['독서', '영화', '게임', '여행'],
  // })
}
```

##### 📄 character_creation.dart (5단계)
**책임**: 캐릭터/아바타 선택

```dart
class CharacterCreationPage extends StatefulWidget {
  // 캐릭터 템플릿 선택 (GridView)
  // 커스터마이징 (색상, 스타일)
  // 완료: OnboardingProvider.completeStep(characterCreation, {
  //   characterId: 'char123',
  //   characterUrl: 'https://...',
  // })
}
```

##### 📄 profile_setup.dart (6단계)
**책임**: 프로필 기본 정보 입력

```dart
class ProfileSetupPage extends StatefulWidget {
  // displayName 입력 (필수)
  // bio 입력 (선택, 150자 제한)
  // 완료: OnboardingProvider.completeStep(profileSetup, {
  //   displayName: '사용자',
  //   bio: '안녕하세요',
  // })
  // → isOnboardingComplete = true
}
```

#### 2.2 user_info/ - 사용자 정보 화면

##### 📄 profile_page.dart
**책임**: 프로필 보기 (본인 + 타인)

```dart
class ProfilePage extends StatelessWidget {
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(provider.profile?.displayName ?? ''),
            actions: [
              if (isMyProfile)
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => Navigator.pushNamed(
                    context,
                    ProfileEditPage.routeName,
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              // 프로필 사진
              CircleAvatar(
                radius: 50,
                backgroundImage: provider.profile?.photoUrl != null
                    ? CachedNetworkImageProvider(provider.profile!.photoUrl!)
                    : null,
              ),

              // 표시 이름
              Text(provider.profile?.displayName ?? ''),

              // 자기소개
              Text(provider.profile?.bio ?? ''),

              // 포인트 정보
              Row(
                children: [
                  Text('답변 포인트: ${provider.profile?.pointsA}'),
                  Text('질문 포인트: ${provider.profile?.pointsQ}'),
                ],
              ),

              // 직업 정보
              Text('${provider.profile?.jobCategory} - ${provider.profile?.jobName}'),

              // 전문분야/취미
              Wrap(
                children: [
                  ...provider.profile?.expertise.map((e) => Chip(label: Text(e))) ?? [],
                  ...provider.profile?.hobbies.map((h) => Chip(label: Text(h))) ?? [],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
```

##### 📄 profile_edit_page.dart
**책임**: 프로필 편집

```dart
class ProfileEditPage extends StatefulWidget {
  static String routeName = 'ProfileEditPage';

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('프로필 편집')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // 프로필 사진 업로드
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(radius: 50),
            ),

            // 표시 이름
            TextFormField(
              controller: _displayNameController,
              decoration: InputDecoration(labelText: '표시 이름'),
              maxLength: 50,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '표시 이름은 필수입니다';
                }
                return null;
              },
            ),

            // 자기소개
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(labelText: '자기소개'),
              maxLength: 150,
              maxLines: 3,
            ),

            // 저장 버튼
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('저장'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProfileProvider>();
    final params = UpdateProfileParams(
      userId: currentUserId,
      displayName: _displayNameController.text,
      bio: _bioController.text,
    );

    await provider.updateProfile(params);
    Navigator.pop(context);
  }
}
```

##### 📄 language_selector/
**책임**: 언어 선택 화면

```dart
class LanguageSelector extends StatelessWidget {
  final languages = ['en', 'de'];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: languages.length,
      itemBuilder: (context, index) {
        final language = languages[index];
        return ListTile(
          title: Text(_getLanguageName(language)),
          trailing: Icon(Icons.check, color: isSelected ? Colors.blue : null),
          onTap: () async {
            final provider = context.read<SettingsProvider>();
            await provider.changeLanguage(language);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      default:
        return code;
    }
  }
}
```

---

### 3. widgets/ - 재사용 가능 위젯 (구현 예정, Phase 4)

#### 3.1 profile/ - 프로필 전용 위젯

```
📁 profile/
├── 📄 profile_avatar.dart          # 프로필 사진 위젯
├── 📄 profile_stats_card.dart      # 포인트/랭킹 표시 카드
├── 📄 profile_info_card.dart       # 프로필 정보 카드
└── 📄 expertise_chip_list.dart     # 전문분야/취미 칩 리스트
```

#### 3.2 onboarding/ - 온보딩 전용 위젯

```
📁 onboarding/
├── 📄 onboarding_progress_bar.dart  # 진행률 표시
├── 📄 interest_grid.dart            # 관심사 선택 그리드
├── 📄 character_selector.dart       # 캐릭터 선택 위젯
└── 📄 onboarding_navigation.dart    # 이전/다음 버튼
```

#### 3.3 components/ - 공통 컴포넌트

```
📁 components/
├── 📄 setting_list_tile.dart       # 설정 리스트 타일
├── 📄 notification_toggle.dart     # 알림 토글 스위치
├── 📄 avatar_upload_button.dart    # 아바타 업로드 버튼
└── 📄 profile_text_field.dart      # 프로필 입력 필드
```

---

### 4. constants/ - UI 상수 (구현 예정)

#### 4.1 onboarding_constants.dart

```dart
class OnboardingConstants {
  // 단계별 메시지
  static const Map<OnboardingStep, String> stepMessages = {
    OnboardingStep.ageAgreement: '13세 이상인지 확인해주세요',
    OnboardingStep.jobSelection: '직업을 선택해주세요',
    OnboardingStep.expertiseSelection: '전문분야를 최대 4개 선택해주세요',
    OnboardingStep.hobbySelection: '취미를 최대 8개 선택해주세요',
    OnboardingStep.characterCreation: '캐릭터를 선택해주세요',
    OnboardingStep.profileSetup: '프로필을 작성해주세요',
  };

  // 제한
  static const int maxExpertise = 4;
  static const int maxHobbies = 8;
  static const int minAge = 13;
}
```

#### 4.2 profile_constants.dart

```dart
class ProfileConstants {
  // 필드 제한
  static const int displayNameMaxLength = 50;
  static const int bioMaxLength = 150;

  // 이미지 크기
  static const int profileImageSize = 200;
  static const int characterImageSize = 300;

  // 캐시
  static const Duration profileCacheDuration = Duration(hours: 6);
}
```

---

## 🔄 데이터 플로우

### 1. 프로필 조회 플로우

```
[ProfilePage]
  ↓ userId
Consumer<ProfileProvider>
  ↓
ProfileProvider.loadProfile(userId)
  ↓
GetUserProfileUseCase.execute(userId)
  ↓
UserRepository.getUser(userId)
  ↓ 3-Layer Cache
  ├─ L1: Memory (<10ms)
  ├─ L2: Hive (10-30ms)
  └─ L3: Firestore (300-500ms)
  ↓
UserProfile 반환
  ↓
UI 업데이트
```

### 2. 프로필 수정 플로우

```
[ProfileEditPage]
  ↓ UpdateProfileParams
ProfileProvider.updateProfile(params)
  ↓
UpdateProfileUseCase.execute(params)
  ├─ 1. 입력 검증
  ├─ 2. 권한 확인
  ├─ 3. 이미지 업로드 (있을 경우)
  └─ 4. UserProfile 업데이트
  ↓
UserRepository.updateUser(user)
  ↓
Firestore 업데이트
  ↓
캐시 무효화
  ↓
ProfileProvider.loadProfile(userId)
  ↓
UI 업데이트
```

### 3. 온보딩 완료 플로우

```
[OnboardingPage]
  ↓ OnboardingStep, data
OnboardingProvider.completeStep(step, data)
  ↓
CompleteOnboardingStepUseCase.execute(params)
  ├─ 1. 단계 순서 검증
  ├─ 2. 데이터 검증 (age >= 13, expertise <= 4 등)
  ├─ 3. OnboardingProgress 업데이트
  └─ 4. 단계 완료 후처리 (보너스 지급 등)
  ↓
UserRepository.updateUser({ onboardingCompleted: true })
  ↓
다음 단계로 이동 or 온보딩 완료
```

---

## 🧪 테스트 전략

### 1. Provider Tests (Unit)

```dart
group('ProfileProvider', () {
  late MockGetUserProfileUseCase mockGetProfileUseCase;
  late MockUpdateProfileUseCase mockUpdateProfileUseCase;
  late ProfileProvider provider;

  test('loadProfile - 성공 시 profile 업데이트', () async {
    // Given
    final userProfile = UserProfile(userId: 'user123', displayName: 'Test');
    when(mockGetProfileUseCase.execute(userId: 'user123'))
      .thenAnswer((_) async => ResultSuccess(userProfile));

    // When
    await provider.loadProfile('user123');

    // Then
    expect(provider.profile, userProfile);
    expect(provider.loadingState, LoadingState.success);
  });
});
```

### 2. Widget Tests

```dart
group('ProfilePage', () {
  testWidgets('프로필 정보 표시', (tester) async {
    // Given
    final userProfile = UserProfile(
      userId: 'user123',
      displayName: 'Test User',
      bio: 'Hello',
    );

    // When
    await tester.pumpWidget(
      MaterialApp(
        home: ProfilePage(userId: 'user123'),
      ),
    );

    // Then
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
  });
});
```

---

## 🔗 관련 문서

### Profile Feature 문서
- [Data Layer README](../data/README.md) - Data Layer 아키텍처
- [Domain Layer README](../domain/README.md) - Domain Layer 아키텍처
- [MIGRATION_PLAN.md](../MIGRATION_PLAN.md) - Clean Architecture 마이그레이션 계획

### Presentation 서브디렉토리 문서
- [Providers README](./providers/README.md) - Provider 상세
- [Screens README](./screens/README.md) - 화면 상세
- [Widgets README](./widgets/README.md) - 위젯 상세

### 참고 문서
- [Creation Feature Presentation Layer](../../creation/presentation/README.md) - Creation 참고 구조
- [Auth Feature Presentation Layer](../../auth/presentation/README.md) - Auth 참고 구조
- [Clean Architecture v4.0](../../../docs/architecture/clean_architecture_v4.md)
- [Provider Pattern Guide](../../../docs/patterns/provider_pattern.md)

---

*이 문서는 Feature-First Architecture의 Profile 기능 Presentation Layer 가이드입니다.*
*Phase 1 마이그레이션 작업 중 생성됨 (2025-01-26)*
