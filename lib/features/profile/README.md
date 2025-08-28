# 👤 Profile Feature

> Feature-First Architecture 기반 프로필 관리 모듈

## 📋 개요

Profile Feature는 사용자 프로필, 개인 설정, 관심사 관리 등을 담당합니다.
사용자 온보딩부터 프로필 커스터마이징까지 모든 프로필 관련 기능을 제공합니다.

## 🏗️ 아키텍처

```
profile/
├── data/                  # 데이터 레이어
│   ├── datasources/      # Firestore 프로필 데이터
│   ├── repositories/     # ProfileRepository 구현
│   └── services/         # 프로필 관련 서비스
│
├── domain/               # 도메인 레이어
│   ├── models/          # UserProfile, Interest 모델
│   ├── repositories/    # ProfileRepository 인터페이스
│   └── usecases/        # 프로필 업데이트, 관심사 설정
│
└── presentation/         # 프레젠테이션 레이어
    ├── screens/         # 프로필, 설정, 온보딩 화면
    │   └── onboarding/  # 관심사 선택 플로우
    ├── widgets/         # 프로필 카드, 아바타 등
    └── providers/       # ProfileProvider 상태 관리
```

## 🎯 주요 기능

### 프로필 관리
- **기본 정보**: 이름, 프로필 사진, 소개
- **캐릭터 아바타**: 사용자 캐릭터 선택 및 관리
- **포인트 시스템**: points_A (답변), points_Q (질문)
- **랭킹 시스템**: 사용자 활동 기반 랭킹

### 온보딩 플로우
- **직업 카테고리**: 직종 선택 (jops_category)
- **전문 분야**: 최대 4개 선택 (expertise)
- **취미**: 최대 8개 선택 (hobbies)
- **관심사 가중치**: 사용자별 관심사 점수

### 설정 관리
- **언어 설정**: 한국어, 영어, 독일어
- **알림 설정**: 푸시 알림 관리
- **프라이버시**: 공개 범위 설정
- **계정 관리**: 프로필 수정, 계정 삭제

## 📦 의존성

### 전역 레이어 사용
- `core/design_system`: 디자인 토큰
- `core/widgets`: 공통 UI 컴포넌트
- `backend/models/user`: User 모델
- `services/cache`: 프로필 캐싱

### 외부 패키지
```yaml
image_picker: ^1.1.2
cached_network_image: ^3.4.1
```

## 🔄 상태 관리

### ProfileProvider
```dart
class ProfileProvider extends ChangeNotifier {
  UserProfile? _profile;
  List<Interest> _interests = [];
  
  // 프로필 정보
  UserProfile? get profile => _profile;
  
  // 관심사 목록
  List<Interest> get interests => _interests;
  
  // 프로필 업데이트
  Future<void> updateProfile(UserProfile profile) async {
    // 구현
  }
}
```

## 🔀 다른 Feature와의 통신

### 공유 Repository 사용
```dart
// backend/repositories/UserRepository 사용
final userProfile = await userRepository.getUserProfile(userId);
```

### 이벤트 발행
```dart
// 프로필 업데이트 이벤트
eventBus.fire(ProfileUpdatedEvent(userId));
```

## 📋 API 레퍼런스

### UseCases
- `GetProfileUseCase`: 프로필 조회
- `UpdateProfileUseCase`: 프로필 수정
- `SetInterestsUseCase`: 관심사 설정
- `UploadAvatarUseCase`: 프로필 사진 업로드
- `UpdateCharacterUseCase`: 캐릭터 변경

### Models
- `UserProfile`: 사용자 프로필 정보
- `Interest`: 관심사 모델
- `Character`: 캐릭터 정보
- `JobCategory`: 직업 카테고리

## 🧪 테스트

```bash
# 유닛 테스트
flutter test test/features/profile/domain/

# 위젯 테스트
flutter test test/features/profile/presentation/
```

## 📝 변경 이력

### v1.0.0 (2025-08-27)
- Feature-First Architecture 마이그레이션 완료
- 온보딩 플로우 개선
- 캐릭터 시스템 통합