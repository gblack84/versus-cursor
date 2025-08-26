# 📦 /lib/core 디렉토리 마이그레이션 가이드

> FlutterFlow 네이티브 마이그레이션 레거시를 Feature-First Architecture로 재구성
> 최종 업데이트: 2025-08-25

## 🎯 목적

FlutterFlow에서 Native Flutter로 마이그레이션할 때 생성된 `/lib/core` 디렉토리의 파일들을 Feature-First Architecture에 맞게 재배치합니다. Core 디렉토리는 역사적 가치가 있지만, 더 나은 모듈화와 관심사 분리를 위해 적절한 Feature로 분산시킵니다.

## 📋 Core 디렉토리 현황 분석

### 전체 파일 목록 및 이동 계획

| 현재 위치 | 파일명 | 용도 | 이동 위치 | 우선순위 |
|-----------|--------|------|-----------|----------|
| `/lib/core/` | app_theme.dart | 테마 시스템 | `/lib/app/theme/` | 1 |
| `/lib/core/` | app_localizations.dart | 다국어 지원 | `/lib/app/localization/` | 1 |
| `/lib/core/` | internationalization.dart | i18n 헬퍼 | `/lib/app/localization/` | 1 |
| `/lib/core/nav/` | nav.dart | GoRouter 설정 | `/lib/app/router/` | 1 |
| `/lib/core/nav/` | serialization_util.dart | 파라미터 직렬화 | `/lib/app/router/` | 1 |
| `/lib/core/` | app_model.dart | 상태 관리 패턴 | `/lib/app/state/` | 2 |
| `/lib/core/` | app_utils.dart | 유틸리티 함수 | `/lib/features/common/presentation/utils/` | 2 |
| `/lib/core/` | app_animations.dart | 애니메이션 유틸 | `/lib/features/common/presentation/utils/` | 3 |
| `/lib/core/` | app_widgets.dart | 공통 위젯 | `/lib/features/common/presentation/widgets/` | 2 |
| `/lib/core/` | app_icon_button.dart | 아이콘 버튼 | `/lib/features/common/presentation/widgets/` | 3 |
| `/lib/core/` | app_toggle_icon.dart | 토글 아이콘 | `/lib/features/common/presentation/widgets/` | 3 |
| `/lib/core/` | form_field_controller.dart | 폼 컨트롤러 | `/lib/features/common/presentation/forms/` | 3 |
| `/lib/core/` | app_video_player.dart | 비디오 플레이어 | `/lib/features/common/presentation/media/` | 3 |
| `/lib/core/` | app_media_display.dart | 미디어 디스플레이 | `/lib/features/common/presentation/media/` | 3 |
| `/lib/core/` | uploaded_file.dart | 파일 업로드 모델 | `/lib/features/common/domain/models/` | 3 |
| `/lib/core/` | lat_lng.dart | 위치 데이터 모델 | `/lib/features/common/domain/models/` | 4 |
| `/lib/core/` | place.dart | 장소 모델 | `/lib/features/common/domain/models/` | 4 |
| `/lib/core/` | custom_functions.dart | 비즈니스 로직 | 각 Feature로 분산 | 4 |

### custom_functions.dart 분산 계획

| 함수명 | 현재 용도 | 이동 위치 | Feature |
|--------|-----------|-----------|---------|
| `isAge13OrAbove()` | 나이 검증 | `/lib/features/auth/domain/validators/age_validator.dart` | Auth |
| `calculateAspectRatio()` | 비율 계산 | `/lib/features/posts/domain/utils/media_utils.dart` | Posts |
| `formatFileSize()` | 파일 크기 포맷 | `/lib/features/common/presentation/utils/format_utils.dart` | Common |
| `isValidEmail()` | 이메일 검증 | `/lib/features/auth/domain/validators/email_validator.dart` | Auth |
| `formatPhoneNumber()` | 전화번호 포맷 | `/lib/features/profile/presentation/utils/phone_formatter.dart` | Profile |
| `dateTimeFormat()` | 날짜 포맷 | `/lib/features/common/presentation/utils/date_utils.dart` | Common |
| `formatNumber()` | 숫자 포맷 | `/lib/features/common/presentation/utils/number_utils.dart` | Common |
| `getJsonField()` | JSON 파싱 | `/lib/features/common/data/utils/json_utils.dart` | Common |
| `launchURL()` | URL 열기 | `/lib/features/common/presentation/actions/url_launcher.dart` | Common |

## 🚨 중요: Import 치환 전략 변경

### ⚠️ 일괄 sed 치환의 위험성
- 주석이나 문자열도 함께 치환될 위험
- 정확한 경로 매핑이 어려움
- 예상치 못한 오류 발생 가능성

### ✅ 권장: 3단계 점진적 치환

#### 1단계: 임시 브리지 파일로 컴파일 유지
```dart
// lib/core_exports.dart - 임시 브리지 파일
// 마이그레이션 완료 후 삭제 예정

// App 관련 exports
export 'app/theme/app_theme.dart';
export 'app/router/router.dart';
export 'app/localization/app_localizations.dart';

// Common 관련 exports  
export 'features/common/presentation/utils/app_utils.dart';
// ... 기타 exports
```

#### 2단계: IDE 리팩터링으로 기능별 교체
- VS Code/IntelliJ의 "Rename Symbol" 기능 활용
- 심볼 기반으로 정확한 경로만 변경
- 파일별, 기능별로 점진적 수행

#### 3단계: 브리지 파일 제거
- 모든 import가 직접 경로로 변경된 후
- core_exports.dart 파일 삭제
- 최종 빌드 및 테스트

## 📁 상세 마이그레이션 계획

### Phase 0: 준비 작업
```bash
# 현재 상태 저장
git add .
git commit -m "chore: save state before core migration"

# 마이그레이션 브랜치 생성
git checkout -b feature/core-migration

# 백업 생성
cp -r lib/core lib/core_backup

# 임시 브리지 파일 생성 (sed 대신)
cat > lib/core_exports.dart << 'EOF'
// 임시 브리지 파일 - 점진적 마이그레이션용
// Phase 3에서 제거 예정

// App 레이어
export 'app/theme/app_theme.dart';
export 'app/router/router.dart';
export 'app/router/serialization_util.dart';
export 'app/localization/app_localizations.dart';
export 'app/localization/internationalization.dart';
export 'app/state/app_model.dart';

// Common Feature
export 'features/common/presentation/utils/app_utils.dart';
export 'features/common/presentation/utils/app_animations.dart';
export 'features/common/presentation/widgets/app_widgets.dart';
export 'features/common/presentation/widgets/app_icon_button.dart';
export 'features/common/presentation/widgets/app_toggle_icon.dart';
export 'features/common/presentation/forms/form_field_controller.dart';
export 'features/common/presentation/media/app_video_player.dart';
export 'features/common/presentation/media/app_media_display.dart';
export 'features/common/domain/models/uploaded_file.dart';
export 'features/common/domain/models/lat_lng.dart';
export 'features/common/domain/models/place.dart';

// Feature별 분산된 함수들
export 'features/auth/domain/validators/age_validator.dart';
export 'features/auth/domain/validators/email_validator.dart';
export 'features/posts/domain/utils/media_utils.dart';
export 'features/profile/presentation/utils/phone_formatter.dart';
export 'features/common/presentation/utils/format_utils.dart';
export 'features/common/presentation/utils/date_utils.dart';
export 'features/common/presentation/utils/number_utils.dart';
export 'features/common/data/utils/json_utils.dart';
export 'features/common/presentation/actions/url_launcher.dart';
EOF

git add lib/core_exports.dart
git commit -m "feat: add temporary bridge file for gradual migration"
```

### Phase 1: App 관련 파일 이동 (우선순위 1)
```bash
# 디렉토리 생성
mkdir -p lib/app/{theme,router,localization,state}

# 테마 시스템 이동
git mv lib/core/app_theme.dart lib/app/theme/app_theme.dart

# 네비게이션 시스템 이동
git mv lib/core/nav/nav.dart lib/app/router/router.dart
git mv lib/core/nav/serialization_util.dart lib/app/router/serialization_util.dart

# 다국어 시스템 이동
git mv lib/core/app_localizations.dart lib/app/localization/app_localizations.dart
git mv lib/core/internationalization.dart lib/app/localization/internationalization.dart

# nav 디렉토리 정리
rm -rf lib/core/nav

# 커밋
git add .
git commit -m "refactor(core): migrate app-level files to app feature"
```

### Phase 2: 상태 관리 이동 (우선순위 2)
```bash
# app_model 이동
git mv lib/core/app_model.dart lib/app/state/app_model.dart

# 커밋
git add .
git commit -m "refactor(core): migrate app model to app state"
```

### Phase 3: Common 유틸리티 이동 (우선순위 2)
```bash
# 디렉토리 생성
mkdir -p lib/features/common/presentation/{utils,widgets}

# 유틸리티 이동
git mv lib/core/app_utils.dart lib/features/common/presentation/utils/app_utils.dart

# 위젯 이동
git mv lib/core/app_widgets.dart lib/features/common/presentation/widgets/app_widgets.dart

# 커밋
git add .
git commit -m "refactor(core): migrate common utilities to common feature"
```

### Phase 4: UI 컴포넌트 이동 (우선순위 3)
```bash
# 디렉토리 생성
mkdir -p lib/features/common/presentation/{widgets,forms,media}

# 애니메이션 유틸리티
git mv lib/core/app_animations.dart lib/features/common/presentation/utils/app_animations.dart

# 위젯 컴포넌트
git mv lib/core/app_icon_button.dart lib/features/common/presentation/widgets/app_icon_button.dart
git mv lib/core/app_toggle_icon.dart lib/features/common/presentation/widgets/app_toggle_icon.dart

# 폼 관련
git mv lib/core/form_field_controller.dart lib/features/common/presentation/forms/form_field_controller.dart

# 미디어 관련
git mv lib/core/app_video_player.dart lib/features/common/presentation/media/app_video_player.dart
git mv lib/core/app_media_display.dart lib/features/common/presentation/media/app_media_display.dart

# 커밋
git add .
git commit -m "refactor(core): migrate UI components to common feature"
```

### Phase 5: 도메인 모델 이동 (우선순위 3-4)
```bash
# 디렉토리 생성
mkdir -p lib/features/common/domain/models

# 모델 이동
git mv lib/core/uploaded_file.dart lib/features/common/domain/models/uploaded_file.dart
git mv lib/core/lat_lng.dart lib/features/common/domain/models/lat_lng.dart
git mv lib/core/place.dart lib/features/common/domain/models/place.dart

# 커밋
git add .
git commit -m "refactor(core): migrate domain models to common feature"
```

### Phase 6: custom_functions.dart 분산 (우선순위 4)
```bash
# 디렉토리 생성
mkdir -p lib/features/auth/domain/validators
mkdir -p lib/features/posts/domain/utils
mkdir -p lib/features/profile/presentation/utils
mkdir -p lib/features/common/presentation/utils
mkdir -p lib/features/common/data/utils
mkdir -p lib/features/common/presentation/actions

# 각 함수를 적절한 파일로 분리 (수동 작업 필요)
# 각 함수별 유닛 테스트도 함께 생성

# custom_functions.dart 삭제
rm lib/core/custom_functions.dart

# 커밋
git add .
git commit -m "refactor(core): distribute custom functions to appropriate features"
```

### Phase 7: Import 경로 점진적 업데이트

#### 7.1: Core import를 브리지로 변경
```bash
# core/* import를 core_exports로 일괄 변경
# VS Code: Ctrl+Shift+H (Find & Replace in Files)
# From: import '.*\/core\/.*\.dart';
# To: import 'package:versus_space/core_exports.dart';

git add .
git commit -m "refactor: replace core imports with bridge file"
```

#### 7.2: 기능별 IDE 리팩터링
```bash
# IDE의 Rename Symbol 기능 사용
# 예시: app_theme.dart
# 1. core_exports.dart에서 해당 export 라인 주석 처리
# 2. 빌드 에러 발생 위치 확인
# 3. IDE로 정확한 경로로 import 수정
# 4. 기능별로 반복

# 커밋 (기능별로)
git add .
git commit -m "refactor: update imports for [feature] from bridge to direct paths"
```

#### 7.3: 브리지 파일 제거
```bash
# 모든 import 업데이트 완료 확인
grep -r "core_exports" lib/ # 결과가 없어야 함

# 브리지 파일 삭제
rm lib/core_exports.dart

# 최종 빌드 테스트
flutter analyze
flutter test

git add .
git commit -m "refactor: remove bridge file after completing migration"
```

### Phase 8: 최종 정리
```bash
# Core 디렉토리 삭제
rm -rf lib/core

# 백업 삭제 (필요시)
rm -rf lib/core_backup

# 의존성 검증 스크립트 실행
# core 경로 잔존 확인
rg "package:versus_space/core/" lib/
# 결과가 없어야 함

# 최종 커밋
git add .
git commit -m "refactor(core): complete core directory migration"
```

## ⏱️ 예상 소요 시간

| Phase | 작업 내용 | 예상 시간 | 체크포인트 |
|-------|-----------|-----------|------------|
| Phase 0 | 준비 작업 (브리지 생성) | 15분 | 백업 및 브리지 파일 |
| Phase 1 | App 파일 이동 | 20분 | 빌드 확인 |
| Phase 2 | 상태 관리 이동 | 10분 | 테스트 실행 |
| Phase 3 | Common 유틸리티 | 15분 | 빌드 확인 |
| Phase 4 | UI 컴포넌트 | 20분 | UI 테스트 |
| Phase 5 | 도메인 모델 | 15분 | 빌드 확인 |
| Phase 6 | 함수 분산 (+ 테스트) | 50분 | 유닛 테스트 |
| Phase 7 | Import 점진적 업데이트 | 40분 | 각 기능별 빌드 |
| Phase 8 | 최종 정리 | 15분 | 통합 테스트 |
| **총합** | **전체 마이그레이션** | **3시간 20분** | **완료** |

## ✅ 마이그레이션 체크리스트

### 사전 준비
- [ ] 현재 상태 커밋
- [ ] 마이그레이션 브랜치 생성
- [ ] Core 디렉토리 백업
- [ ] 임시 브리지 파일 생성 (core_exports.dart)

### 파일 이동
- [ ] App 레벨 파일 이동 완료
- [ ] Common 유틸리티 이동 완료
- [ ] UI 컴포넌트 이동 완료
- [ ] 도메인 모델 이동 완료
- [ ] custom_functions 분산 완료
- [ ] 각 함수별 유닛 테스트 생성

### Import 경로 수정 (점진적)
- [ ] core import → core_exports 변경
- [ ] App 기능 import 직접 경로 변경
- [ ] Common 기능 import 직접 경로 변경
- [ ] Auth 기능 import 직접 경로 변경
- [ ] 기타 Feature import 직접 경로 변경
- [ ] 브리지 파일 제거

### 검증
- [ ] flutter analyze - 0 warnings
- [ ] flutter test - 모든 테스트 통과
- [ ] 앱 정상 실행
- [ ] 성능 이슈 없음
- [ ] core 경로 잔존 검사 통과

### 정리
- [ ] Core 디렉토리 삭제
- [ ] 백업 파일 삭제
- [ ] 문서 업데이트
- [ ] PR 생성

## 🔄 롤백 계획

문제 발생 시:
```bash
# 마이그레이션 취소
git reset --hard HEAD~
git checkout flutterflow

# 백업에서 복구 (필요시)
cp -r lib/core_backup lib/core
rm -rf lib/core_backup
```

## 📝 마이그레이션 후 구조

```
/lib/
├── app/                        # 앱 전역 설정
│   ├── theme/                  # 테마 시스템
│   ├── router/                 # 라우팅
│   ├── localization/           # 다국어
│   └── state/                  # 상태 관리
│
├── features/
│   ├── common/                 # 공통 기능
│   │   ├── presentation/
│   │   │   ├── utils/         # 유틸리티
│   │   │   ├── widgets/       # 공통 위젯
│   │   │   ├── forms/         # 폼 관련
│   │   │   ├── media/         # 미디어
│   │   │   └── actions/       # 액션
│   │   ├── domain/
│   │   │   └── models/        # 공통 모델
│   │   └── data/
│   │       └── utils/         # 데이터 유틸
│   │
│   ├── auth/                   # 인증 기능
│   │   └── domain/
│   │       └── validators/    # 검증 로직
│   │
│   ├── posts/                  # 게시물 기능
│   │   └── domain/
│   │       └── utils/         # 포스트 유틸
│   │
│   └── profile/                # 프로필 기능
│       └── presentation/
│           └── utils/         # 프로필 유틸
│
└── (core 디렉토리 삭제됨)
```

## 💡 주의사항

1. **점진적 Import 변경**: sed 대신 브리지 파일과 IDE 리팩터링 활용
2. **Git 이력 유지**: `git mv` 사용으로 파일 이력 보존
3. **테스트 추가**: custom_functions 분산 시 유닛 테스트 함께 생성
4. **단계별 검증**: 각 Phase마다 빌드 및 테스트 확인
5. **의존성 검증**: rg 명령으로 core 경로 잔존 확인

## 🎯 기대 효과

1. **명확한 관심사 분리**: 각 Feature가 자신의 유틸리티 소유
2. **의존성 감소**: Core에 대한 전역 의존성 제거
3. **모듈화 향상**: Feature별 독립적 개발 가능
4. **유지보수성**: 각 팀이 자신의 Feature 관리
5. **확장성**: 새 Feature 추가 시 Core 수정 불필요

---

*이 문서는 Core 디렉토리 마이그레이션의 완전한 가이드입니다.*
*작성일: 2025-08-25*
*수정일: 2025-08-26 - 점진적 import 치환 전략 추가*