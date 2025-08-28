# 📦 /lib/features/profile 디렉토리 마이그레이션 가이드

> Feature-First Architecture - Profile Feature 완전 통합

## 🎯 목적

사용자 프로필 및 설정 관련 모든 기능을 `/lib/features/profile` 폴더로 통합하여 독립적이고 재사용 가능한 프로필 모듈을 구성합니다.

## 📋 현재 상태 분석

### 프로필 관련 디렉토리 현황
| 디렉토리 | 파일 수 | 설명 |
|---------|---------|------|
| `/lib/pages/profile/` | 1개 | 프로필 페이지 |
| `/lib/pages/user_info/` | 4개 | 캐릭터 상세, 언어 선택 |
| `/lib/pages/user_info_input/` | 2개 | 사용자 정보 입력 |
| `/lib/pages/jop/` | 6개 | 나이 동의, 전문분야, 취미 선택 |
| `/lib/backend/schema/` | 관련 모델 | 사용자 관련 스키마 |
| `/lib/services/user_cache_service.dart` | 1개 | 사용자 캐싱 |
| **총합** | **13개+** | 프로필 관련 실제 파일 |

## 🔄 Core/App 마이그레이션 의존성

### FlutterFlow → Native Flutter 변환
이 기능은 다음 Core/App 마이그레이션 항목들과 의존성이 있습니다:

| 변경 사항 | 영향받는 컴포넌트 | 필요 작업 |
|----------|----------------|----------|
| **FFAppState → AppState** | 프로필 상태 관리 | `Provider<AppState>` 사용 |
| **flutter_flow/ → core/** | 프로필 유틸리티 | Import 경로 변경 |
| **FF 접두사 제거** | 프로필 위젯 | `FFUploadButton` → `AppUploadButton` |
| **AppTheme 통합** | 프로필 UI 테마 | `AppTheme.of(context)` 사용 |
| **FFLocalizations → AppLocalizations** | 다국어 지원 | `AppLocalizations.of(context)` 사용 |

### Import 변경 예시
```dart
// Before (FlutterFlow)
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/upload_data.dart';

// After (Native Flutter)
import '/core/app_theme.dart';
import '/core/widgets/app_button.dart';
import '/core/utils/upload_util.dart';
```

## 🏗️ Feature-First 구조 매핑

```
/lib/features/profile/
├── data/
│   ├── repositories/
│   │   ├── profile_repository.dart       # 프로필 데이터 접근 추상화
│   │   ├── settings_repository.dart      # 설정 데이터 관리
│   │   └── character_repository.dart     # 캐릭터 데이터 관리
│   │
│   └── services/
│       ├── profile_service.dart          # 프로필 CRUD 서비스
│       ├── user_cache_service.dart       # 사용자 캐싱
│       ├── character_service.dart        # 캐릭터 관리
│       ├── interest_service.dart         # 관심사 관리
│       ├── job_service.dart              # 직업 정보 관리
│       ├── friends_service.dart          # 친구 관리
│       └── premium_service.dart          # 프리미엄 관리
│
├── domain/
│   ├── models/
│   │   ├── profile_model.dart           # 프로필 데이터 모델
│   │   ├── character_model.dart         # 캐릭터 모델
│   │   ├── interest_model.dart          # 관심사 모델
│   │   ├── job_category_model.dart      # 직업 카테고리
│   │   ├── job_name_model.dart          # 직업명 모델
│   │   ├── expertise_model.dart         # 전문분야 모델
│   │   ├── friends_list_model.dart      # 친구 목록
│   │   └── settings_model.dart          # 설정 모델
│   │
│   └── usecases/
│       ├── update_profile_usecase.dart  # 프로필 수정
│       ├── upload_avatar_usecase.dart   # 아바타 업로드
│       ├── change_settings_usecase.dart # 설정 변경
│       ├── add_friend_usecase.dart      # 친구 추가
│       ├── update_interests_usecase.dart # 관심사 수정
│       └── upgrade_premium_usecase.dart # 프리미엄 업그레이드
│
└── presentation/
    ├── screens/
    │   ├── profile_main/                # 프로필 메인 화면
    │   │   ├── profile_page_widget.dart
    │   │   └── profile_page_model.dart
    │   │
    │   ├── profile_edit/                # 프로필 편집 화면
    │   │   ├── profile_edit_widget.dart
    │   │   └── profile_edit_model.dart
    │   │
    │   ├── user_info/                   # 사용자 정보 화면
    │   │   ├── user_info_widget.dart
    │   │   ├── user_info_model.dart
    │   │   ├── character_detail/        # 캐릭터 상세
    │   │   │   ├── character_detail_widget.dart
    │   │   │   └── character_detail_model.dart
    │   │   └── language_selector/       # 언어 선택
    │   │       ├── language_selector_widget.dart
    │   │       └── language_selector_model.dart
    │   │
    │   ├── user_info_input/             # 정보 입력 화면
    │   │   ├── user_info_input_widget.dart
    │   │   └── user_info_input_model.dart
    │   │
    │   ├── onboarding/                  # 온보딩 플로우
    │   │   ├── job_selection/           # 직업 선택
    │   │   │   ├── job_select_widget.dart
    │   │   │   └── job_select_model.dart
    │   │   │
    │   │   ├── interest_selection/      # 관심사 선택
    │   │   │   ├── agreed_select/       # 나이 동의
    │   │   │   │   ├── agreed_select_widget.dart
    │   │   │   │   └── agreed_select_model.dart
    │   │   │   ├── expertise_select/    # 전문분야
    │   │   │   │   ├── expertise_select_widget.dart
    │   │   │   │   └── expertise_select_model.dart
    │   │   │   └── hobbies_select/      # 취미 선택
    │   │   │       ├── hobbies_select_widget.dart
    │   │   │       └── hobbies_select_model.dart
    │   │   │
    │   │   └── character_creation/      # 캐릭터 생성
    │   │       ├── character_creation_widget.dart
    │   │       └── character_creation_model.dart
    │   │
    │   ├── settings/                    # 설정 화면
    │   │   ├── settings_widget.dart
    │   │   ├── settings_model.dart
    │   │   ├── privacy_settings/       # 개인정보 설정
    │   │   ├── notification_settings/  # 알림 설정
    │   │   └── language_settings/      # 언어 설정
    │   │
    │   └── premium/                     # 프리미엄 화면
    │       ├── premium_widget.dart
    │       └── premium_model.dart
    │
    ├── widgets/
    │   ├── profile_header.dart          # 프로필 헤더
    │   ├── avatar_selector.dart         # 아바타 선택기
    │   ├── character_card.dart          # 캐릭터 카드
    │   ├── stats_display.dart           # 통계 표시
    │   ├── points_badge.dart            # 포인트 뱃지
    │   ├── ranking_display.dart         # 순위 표시
    │   ├── interest_chip.dart           # 관심사 칩
    │   ├── job_selector.dart            # 직업 선택기
    │   ├── hobby_grid.dart              # 취미 그리드
    │   └── premium_badge.dart           # 프리미엄 뱃지
    │
    ├── providers/
    │   ├── profile_provider.dart        # 프로필 상태 관리
    │   ├── settings_provider.dart       # 설정 상태 관리
    │   └── onboarding_provider.dart     # 온보딩 상태 관리
    │
    └── constants/
        ├── profile_strings.dart          # 프로필 문자열
        ├── onboarding_steps.dart         # 온보딩 단계
        └── character_options.dart        # 캐릭터 옵션
```

## 📁 상세 파일 이동 계획

### Phase 0: 준비 작업
```bash
# 현재 상태 저장
git add .
git commit -m "chore: save current state before profile migration"

# 마이그레이션 브랜치 생성
git checkout -b feature/profile-migration

# 디렉토리 구조 생성
mkdir -p lib/features/profile/data/{repositories,services}
mkdir -p lib/features/profile/domain/{models,usecases}
mkdir -p lib/features/profile/presentation/{screens/{profile_main,profile_edit,user_info,onboarding,settings,premium},widgets,providers,constants}
```

### Phase 1: Services 이동 (data/services/)

```bash
# 사용자 캐싱 서비스 이동
git mv lib/services/user_cache_service.dart lib/features/profile/data/services/

# 새로 생성할 서비스들
echo "// TODO: Implement profile service" > lib/features/profile/data/services/profile_service.dart
echo "// TODO: Implement character service" > lib/features/profile/data/services/character_service.dart
echo "// TODO: Implement interest service" > lib/features/profile/data/services/interest_service.dart
echo "// TODO: Implement job service" > lib/features/profile/data/services/job_service.dart
echo "// TODO: Implement friends service" > lib/features/profile/data/services/friends_service.dart
echo "// TODO: Implement premium service" > lib/features/profile/data/services/premium_service.dart

# 커밋
git add .
git commit -m "feat(profile): migrate services to feature module"
```

### Phase 2: Models 이동 (domain/models/)

```bash
# 사용자 관련 모델 이동
git mv lib/backend/schema/characters_model.dart lib/features/profile/domain/models/character_model.dart
git mv lib/backend/schema/interest_model.dart lib/features/profile/domain/models/interest_model.dart
git mv lib/backend/schema/jops_category_model.dart lib/features/profile/domain/models/job_category_model.dart
git mv lib/backend/schema/jops_name_model.dart lib/features/profile/domain/models/job_name_model.dart
git mv lib/backend/schema/friends_list_model.dart lib/features/profile/domain/models/friends_list_model.dart
git mv lib/backend/schema/chat_interest_jops_model.dart lib/features/profile/domain/models/expertise_model.dart

# 추가 모델 생성
echo "// TODO: Implement profile model" > lib/features/profile/domain/models/profile_model.dart
echo "// TODO: Implement settings model" > lib/features/profile/domain/models/settings_model.dart

# 커밋
git add .
git commit -m "feat(profile): migrate models to domain layer"
```

### Phase 3: Screens 이동 (presentation/screens/)

```bash
# 프로필 메인 화면 이동
git mv lib/pages/profile/profile_page_widget.dart lib/features/profile/presentation/screens/profile_main/
git mv lib/pages/profile/profile_page_model.dart lib/features/profile/presentation/screens/profile_main/

# 사용자 정보 화면 이동
git mv lib/pages/user_info/user_info_widget.dart lib/features/profile/presentation/screens/user_info/
git mv lib/pages/user_info/user_info_model.dart lib/features/profile/presentation/screens/user_info/

# 사용자 정보 입력 화면 이동
git mv lib/pages/user_info_input/user_info_input_widget.dart lib/features/profile/presentation/screens/user_info_input/
git mv lib/pages/user_info_input/user_info_input_model.dart lib/features/profile/presentation/screens/user_info_input/

# 온보딩 - 나이 동의 화면 이동
mkdir -p lib/features/profile/presentation/screens/onboarding/interest_selection/agreed_select
git mv lib/pages/jop/agreed_select/* lib/features/profile/presentation/screens/onboarding/interest_selection/agreed_select/

# 온보딩 - 전문분야 선택 화면 이동
mkdir -p lib/features/profile/presentation/screens/onboarding/interest_selection/expertise_select
git mv lib/pages/jop/expertise_select/* lib/features/profile/presentation/screens/onboarding/interest_selection/expertise_select/

# 온보딩 - 취미 선택 화면 이동
mkdir -p lib/features/profile/presentation/screens/onboarding/interest_selection/hobbies_select
git mv lib/pages/jop/hobbies_select/* lib/features/profile/presentation/screens/onboarding/interest_selection/hobbies_select/

# 캐릭터 상세 화면 이동
mkdir -p lib/features/profile/presentation/screens/user_info/character_detail
git mv lib/pages/user_info/character_detail_page/* lib/features/profile/presentation/screens/user_info/character_detail/

# 언어 선택 화면 이동
mkdir -p lib/features/profile/presentation/screens/user_info/language_selector
git mv lib/pages/user_info/language_selector/* lib/features/profile/presentation/screens/user_info/language_selector/

# 커밋
git add .
git commit -m "feat(profile): migrate screens to presentation layer"
```

### Phase 4: Widgets 생성 (presentation/widgets/)

```bash
# 재사용 가능한 위젯들 생성
echo "// TODO: Implement profile header" > lib/features/profile/presentation/widgets/profile_header.dart
echo "// TODO: Implement avatar selector" > lib/features/profile/presentation/widgets/avatar_selector.dart
echo "// TODO: Implement character card" > lib/features/profile/presentation/widgets/character_card.dart
echo "// TODO: Implement stats display" > lib/features/profile/presentation/widgets/stats_display.dart
echo "// TODO: Implement points badge" > lib/features/profile/presentation/widgets/points_badge.dart
echo "// TODO: Implement ranking display" > lib/features/profile/presentation/widgets/ranking_display.dart
echo "// TODO: Implement interest chip" > lib/features/profile/presentation/widgets/interest_chip.dart
echo "// TODO: Implement job selector" > lib/features/profile/presentation/widgets/job_selector.dart
echo "// TODO: Implement hobby grid" > lib/features/profile/presentation/widgets/hobby_grid.dart
echo "// TODO: Implement premium badge" > lib/features/profile/presentation/widgets/premium_badge.dart

# 커밋
git add .
git commit -m "feat(profile): create reusable widgets"
```

### Phase 5: Repository 및 UseCases 생성

```bash
# Repository 생성
cat > lib/features/profile/data/repositories/profile_repository.dart << 'EOF'
class ProfileRepository {
  // TODO: Implement profile repository
}
EOF

echo "// TODO: Implement settings repository" > lib/features/profile/data/repositories/settings_repository.dart
echo "// TODO: Implement character repository" > lib/features/profile/data/repositories/character_repository.dart

# UseCases 생성
echo "// TODO: Implement update profile usecase" > lib/features/profile/domain/usecases/update_profile_usecase.dart
echo "// TODO: Implement upload avatar usecase" > lib/features/profile/domain/usecases/upload_avatar_usecase.dart
echo "// TODO: Implement change settings usecase" > lib/features/profile/domain/usecases/change_settings_usecase.dart
echo "// TODO: Implement add friend usecase" > lib/features/profile/domain/usecases/add_friend_usecase.dart
echo "// TODO: Implement update interests usecase" > lib/features/profile/domain/usecases/update_interests_usecase.dart
echo "// TODO: Implement upgrade premium usecase" > lib/features/profile/domain/usecases/upgrade_premium_usecase.dart

# Providers 생성
echo "// TODO: Implement profile provider" > lib/features/profile/presentation/providers/profile_provider.dart
echo "// TODO: Implement settings provider" > lib/features/profile/presentation/providers/settings_provider.dart
echo "// TODO: Implement onboarding provider" > lib/features/profile/presentation/providers/onboarding_provider.dart

# 커밋
git add .
git commit -m "feat(profile): create repository and usecases structure"
```

### Phase 6: Import 경로 업데이트 및 테스트

```bash
# Import 경로 일괄 업데이트
echo "📝 Updating import paths..."

# Service imports 업데이트
find lib -type f -name "*.dart" -exec sed -i '' \
  -e "s|import '/services/user_cache_service.dart'|import '/features/profile/data/services/user_cache_service.dart'|g" {} +

# Screen imports 업데이트
find lib -type f -name "*.dart" -exec sed -i '' \
  -e "s|import '/pages/profile/profile_page_widget.dart'|import '/features/profile/presentation/screens/profile_main/profile_page_widget.dart'|g" \
  -e "s|import '/pages/user_info/user_info_widget.dart'|import '/features/profile/presentation/screens/user_info/user_info_widget.dart'|g" {} +

# Model imports 업데이트
find lib -type f -name "*.dart" -exec sed -i '' \
  -e "s|import '/backend/schema/characters_model.dart'|import '/features/profile/domain/models/character_model.dart'|g" \
  -e "s|import '/backend/schema/interest_model.dart'|import '/features/profile/domain/models/interest_model.dart'|g" {} +

# Core → App/Common 마이그레이션 대응
# Core 파일들이 App과 Common으로 이동함에 따른 import 업데이트
find lib -type f -name "*.dart" -exec sed -i '' \
  -e "s|import '/core/app_theme.dart'|import '/app/theme/app_theme.dart'|g" \
  -e "s|import '/core/app_utils.dart'|import '/features/common/presentation/utils/app_utils.dart'|g" \
  -e "s|import '/core/app_localizations.dart'|import '/app/localization/app_localizations.dart'|g" {} +

# 빌드 테스트
flutter clean
flutter pub get
flutter analyze

# 테스트 실행
flutter test

# 커밋
git add .
git commit -m "feat(profile): update import paths and verify build"
```

## 📝 Import 경로 업데이트

### 영향받는 주요 파일들

| 파일 그룹 | 예상 영향 파일 수 | 설명 |
|----------|-----------------|------|
| 네비게이션 관련 | 15개+ | 프로필 페이지 접근 |
| 인증 관련 | 10개+ | 회원가입 후 프로필 설정 |
| 게시물 관련 | 5개+ | 작성자 프로필 표시 |
| 채팅 관련 | 5개+ | 사용자 정보 표시 |

### Import 변경 예시

```dart
// Before
import '/pages/profile/profile_page_widget.dart';
import '/pages/user_info/user_info_widget.dart';
import '/backend/schema/characters_model.dart';

// After
import '/features/profile/presentation/screens/profile_main/profile_page_widget.dart';
import '/features/profile/presentation/screens/user_info/user_info_widget.dart';
import '/features/profile/domain/models/character_model.dart';
```

## ✅ 검증 체크리스트

### 기능별 테스트

#### 1. 프로필 표시
- [ ] 프로필 페이지 로딩
- [ ] 사용자 정보 표시
- [ ] 캐릭터 표시
- [ ] 포인트/순위 표시
- [ ] 프리미엄 상태

#### 2. 프로필 편집
- [ ] 기본 정보 수정
- [ ] 프로필 사진 변경
- [ ] 캐릭터 변경
- [ ] 관심사 수정
- [ ] 직업 정보 변경

#### 3. 온보딩 플로우
- [ ] 나이 동의 (13세 이상)
- [ ] 직업 선택
- [ ] 전문분야 선택 (최대 4개)
- [ ] 취미 선택 (최대 8개)
- [ ] 캐릭터 생성

#### 4. 설정 관리
- [ ] 언어 변경
- [ ] 알림 설정
- [ ] 개인정보 설정
- [ ] 계정 관리

#### 5. 소셜 기능
- [ ] 친구 목록
- [ ] 친구 추가/삭제
- [ ] 프로필 공유

## 🎯 마이그레이션 체크리스트

### Phase별 완료 확인
- [ ] **Phase 0**: 브랜치 생성 및 디렉토리 구조 준비
- [ ] **Phase 1**: Services 이동/생성 (7개 파일)
- [ ] **Phase 2**: Models 이동 (6개 파일)
- [ ] **Phase 3**: Screens 이동 (15개+ 파일)
- [ ] **Phase 4**: Widgets 생성 (10개 파일)
- [ ] **Phase 5**: Repository/UseCases 구조 생성
- [ ] **Phase 6**: Import 경로 업데이트

### 기능 검증
- [ ] 프로필 페이지 접근 가능
- [ ] 사용자 정보 표시 정상
- [ ] 프로필 편집 기능 정상
- [ ] 온보딩 플로우 작동
- [ ] 캐릭터 표시 정상
- [ ] 관심사/직업 선택 정상
- [ ] 언어 설정 변경 가능

### 성능 검증
- [ ] 빌드 시간 증가 없음
- [ ] 런타임 에러 없음
- [ ] 캐싱 정상 작동

## ⚠️ 주의사항

### 1. Core/App 마이그레이션 연관성
- Core 파일들이 App과 Common으로 분산됨
- import 경로 변경 필수
- 예: `/core/app_theme.dart` → `/app/theme/app_theme.dart`
- 예: `/core/app_utils.dart` → `/features/common/presentation/utils/app_utils.dart`

### 2. 캐싱 전략
- UserCacheService 통합 유지
- 프로필 정보 캐싱
- 이미지 캐싱 처리

### 3. 온보딩 플로우
- 단계별 진행 상태 관리
- 필수/선택 항목 구분
- 진행률 표시

### 4. 다국어 지원
- 프로필 관련 텍스트 i18n
- 언어 설정 저장
- 기본 언어 폴백

### 5. 데이터 검증
- 나이 제한 (13세 이상)
- 관심사 개수 제한
- 프로필 이미지 크기 제한

## 📊 예상 영향도

| 구분 | 영향도 | 파일 수 | 설명 |
|------|--------|---------|------|
| **Services** | 중간 | 1개 | 기존 서비스 이동 |
| **Models** | 중간 | 관련 모델 | 데이터 구조 |
| **Screens** | 높음 | 13개 | 화면 구성 |
| **Widgets** | 중간 | 생성 예정 | UI 컴포넌트 |
| **총 영향** | **중간** | **13개+** | 보조 기능 |

## 🔄 롤백 계획

```bash
# 문제 발생 시 롤백
git reset --hard HEAD~1
git checkout main

# 또는 백업 브랜치로 복귀
git checkout backup/before-profile-migration
```

## 📅 예상 소요 시간

| Phase | 작업 내용 | 소요 시간 | 난이도 | 체크포인트 |
|-------|----------|----------|--------|------------|
| Phase 0: 준비 | 백업 및 브랜치 생성 | 10분 | ⭐ | 브랜치 생성 확인 |
| Phase 1: Services | 1개 서비스 이동 | 20분 | ⭐⭐ | Import 에러 없음 |
| Phase 2: Models | 모델 이동 | 30분 | ⭐⭐ | 모델 컴파일 성공 |
| Phase 3: Screens | 13개 화면 이동 | 1.5시간 | ⭐⭐⭐ | 화면 라우팅 정상 |
| Phase 4: Widgets | 위젯 생성 | 30분 | ⭐⭐ | UI 렌더링 정상 |
| Phase 5: Repository | Repository/UseCases 골격 생성 | 30분 | ⭐⭐ | 구조 확인 |
| Phase 6: 테스트 | Import 업데이트 및 검증 | 30분 | ⭐⭐ | 전체 빌드 성공 |
| **총 소요 시간** | **전체 마이그레이션** | **3.5시간** | ⭐⭐ | 프로필 기능 정상 작동 |

## 🚀 다음 단계

1. **온보딩 플로우 검증**
   - 단계별 진행 테스트
   - 데이터 저장 확인

2. **캐싱 최적화**
   - 프로필 캐싱 전략
   - 이미지 최적화

3. **다국어 지원 확인**
   - 번역 키 매핑
   - 언어 전환 테스트

## 🚀 실행 가이드

### 단계별 실행 방법

1. **준비 단계**
   ```bash
   # 현재 브랜치 확인
   git status
   # Phase 0 실행
   ```

2. **순차 실행**
   - 각 Phase를 순서대로 실행
   - Phase 완료 후 커밋 확인
   - 온보딩 화면들 이동 시 주의

3. **검증 단계**
   - Phase 6에서 전체 빌드 테스트
   - 온보딩 플로우 테스트
   - 프로필 기능 테스트

4. **완료 후**
   ```bash
   # PR 생성
   git push origin feature/profile-migration
   # main 브랜치에 머지 요청
   ```

---

*이 문서는 Feature-First Architecture 마이그레이션의 Profile Feature 통합 가이드입니다.*
*작성일: 2025-08-24*
*업데이트: Phase별 실행 계획 추가*