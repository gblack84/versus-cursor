# 📦 /lib/features/common 디렉토리 마이그레이션 가이드

> Feature-First Architecture - Common/Shared 기능 통합  
> 최종 업데이트: 2025-08-26 | ✅ 마이그레이션 완료

## 🎯 목적

여러 feature에서 공통으로 사용되는 유틸리티, 위젯, 서비스를 `/lib/features/common` 폴더로 통합하여 재사용성을 높입니다.

## 🔄 Core/App 마이그레이션 의존성

### FlutterFlow → Native Flutter 변환
이 기능은 다음 Core/App 마이그레이션 항목들과 의존성이 있습니다:

| 변경 사항 | 영향받는 컴포넌트 | 필요 작업 |
|----------|----------------|----------|
| **FFAppState → AppState** | 전역 상태 관리 | `Provider<AppState>` 사용 |
| **flutter_flow/ → core/** | 모든 유틸리티 | Import 경로 변경 |
| **FF 접두사 제거** | 공통 위젯 | `FFButtonWidget` → `AppButton` |
| **AppTheme 통합** | 디자인 시스템 | `AppTheme.of(context)` 사용 |

### Import 변경 예시
```dart
// Before (FlutterFlow)
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_util.dart';

// After (Native Flutter)
import '/core/app_theme.dart';
import '/core/widgets/app_button.dart';
import '/core/utils/app_utils.dart';
```

## 📚 하위 디렉토리 문서

모든 하위 디렉토리에 상세한 README 문서가 작성되었습니다:

### Data Layer 문서
- 📄 [data/services/README.md](./data/services/README.md) - 공통 서비스 구현
- 📄 [data/repositories/README.md](./data/repositories/README.md) - 공통 리포지토리

### Domain Layer 문서
- 📄 [domain/models/README.md](./domain/models/README.md) - 공통 도메인 모델
- 📄 [domain/validators/README.md](./domain/validators/README.md) - 검증 로직
- 📄 [domain/usecases/README.md](./domain/usecases/README.md) - 공통 유스케이스

### Presentation Layer 문서
- 📄 [presentation/widgets/README.md](./presentation/widgets/README.md) - 재사용 위젯
- 📄 [presentation/design_system/README.md](./presentation/design_system/README.md) - 디자인 시스템
- 📄 [presentation/utils/README.md](./presentation/utils/README.md) - UI 유틸리티
- 📄 [presentation/actions/README.md](./presentation/actions/README.md) - 전역 액션

## 📋 현재 상태 분석

### 공통 기능 디렉토리 현황
| 디렉토리/파일 | 파일 수 | 설명 |
|----------------|---------|------|
| `/lib/shared/` | 5개+ | 공유 상수, 서비스, 위젯 |
| `/lib/widgets/` | 1개 | 전역 커스텀 위젯 |
| `/lib/utils/` | 5개 | 유틸리티 함수 (로거, 필터, 헬퍼) |
| `/lib/actions/` | 1개 | 앱 전역 액션 |
| `/lib/design_system/` | 15개+ | 디자인 시스템 (토큰, 컴포넌트) |
| `/lib/components/` | 10개+ | 재사용 가능한 UI 컴포넌트 |
| `/lib/core/` (일부) | 11개 | Core에서 Common으로 이동할 파일들 |
| **총합** | **48개+** | 공통 기능 전체 파일 |

## 🏗️ Feature-First 구조 매핑

```
/lib/features/common/
├── data/
│   ├── repositories/
│   │   └── storage_repository.dart      # 공통 스토리지 접근
│   │
│   └── services/
│       ├── unified_box_calculator.dart  # 박스 크기 계산
│       ├── app_logger.dart             # 로깅 서비스
│       ├── file_logger.dart            # 파일 로깅
│       ├── content_filter.dart         # 콘텐츠 필터링
│       └── responsive_breakpoints.dart # 반응형 브레이크포인트
│
├── domain/
│   ├── models/
│   │   ├── layout_constants.dart       # 레이아웃 상수
│   │   ├── uploaded_file.dart          # from /lib/core/
│   │   ├── lat_lng.dart                # from /lib/core/
│   │   └── place.dart                   # from /lib/core/
│   │
│   └── usecases/
│       └── validate_content_usecase.dart # 콘텐츠 검증
│
└── presentation/
    ├── widgets/
    │   ├── highlighted_text_field.dart  # 커스텀 텍스트 필드
    │   ├── unified_video_player.dart    # 통합 비디오 플레이어
    │   ├── youtube_player_widget.dart   # YouTube 플레이어
    │   ├── alertempty_widget.dart      # 빈 알림 위젯
    │   ├── editviedo_widget.dart       # 비디오 편집 위젯
    │   ├── videoplay_widget.dart       # 비디오 재생 위젯
    │   ├── app_widgets.dart            # from /lib/core/
    │   ├── app_icon_button.dart        # from /lib/core/
    │   └── app_toggle_icon.dart        # from /lib/core/
    │
    ├── design_system/
    │   ├── tokens/                      # 디자인 토큰
    │   │   ├── versus_colors.dart
    │   │   ├── versus_spacing.dart
    │   │   ├── versus_text_styles.dart
    │   │   ├── versus_radius.dart
    │   │   ├── versus_icons.dart
    │   │   └── versus_icon_data.dart
    │   │
    │   └── components/                  # UI 컴포넌트
    │       ├── versus_button.dart
    │       ├── versus_dialog.dart
    │       ├── versus_text_field.dart
    │       └── versus_icon.dart
    │
    ├── utils/
    │   ├── app_utils.dart              # from /lib/core/
    │   └── app_animations.dart         # from /lib/core/
    │
    ├── forms/
    │   └── form_field_controller.dart  # from /lib/core/
    │
    ├── media/
    │   ├── app_video_player.dart       # from /lib/core/
    │   └── app_media_display.dart      # from /lib/core/
    │
    └── actions/
        └── global_actions.dart          # 전역 액션
```

## 📁 상세 파일 이동 계획

### Phase 0: 준비 작업
```bash
# 현재 상태 저장
git add .
git commit -m "chore: save current state before common migration"

# 마이그레이션 브랜치 생성
git checkout -b feature/common-migration

# 디렉토리 구조 생성
mkdir -p lib/features/common/data/{repositories,services}
mkdir -p lib/features/common/domain/{models,usecases}
mkdir -p lib/features/common/presentation/{widgets,design_system/{tokens,components},actions}
```

### Phase 1: Utils 이동 (data/services/ & presentation/utils/)

```bash
# 유틸리티 서비스
git mv lib/utils/app_logger.dart lib/features/common/data/services/
git mv lib/utils/file_logger.dart lib/features/common/data/services/
git mv lib/utils/content_filter.dart lib/features/common/data/services/
git mv lib/utils/responsive_breakpoints.dart lib/features/common/data/services/
git mv lib/utils/vote_message_helper.dart lib/features/voting/data/services/

# 공유 서비스
git mv lib/shared/services/unified_box_calculator.dart lib/features/common/data/services/

# Core 유틸리티 이동
git mv lib/core/app_utils.dart lib/features/common/presentation/utils/
git mv lib/core/app_animations.dart lib/features/common/presentation/utils/

# 커밋
git add .
git commit -m "refactor(common): migrate utility services and core utils to feature-first structure"
```

### Phase 2: Widgets 이동 (presentation/widgets/)

```bash
# 커스텀 위젯
git mv lib/widgets/highlighted_text_field.dart lib/features/common/presentation/widgets/

# 컴포넌트 위젯
git mv lib/components/unified_video_player.dart lib/features/common/presentation/widgets/
git mv lib/components/youtube_player_widget.dart lib/features/common/presentation/widgets/
git mv lib/components/alertempty_widget.dart lib/features/common/presentation/widgets/
git mv lib/components/editviedo_widget.dart lib/features/common/presentation/widgets/
git mv lib/components/videoplay_widget.dart lib/features/common/presentation/widgets/

# Core 위젯 이동
git mv lib/core/app_widgets.dart lib/features/common/presentation/widgets/
git mv lib/core/app_icon_button.dart lib/features/common/presentation/widgets/
git mv lib/core/app_toggle_icon.dart lib/features/common/presentation/widgets/

# 커밋
git add .
git commit -m "refactor(common): migrate common widgets and core components to presentation layer"
```

### Phase 3: Design System 이동 (presentation/design_system/)

```bash
# 디자인 토큰
git mv lib/design_system/tokens/* lib/features/common/presentation/design_system/tokens/

# UI 컴포넌트
git mv lib/design_system/components/* lib/features/common/presentation/design_system/components/

# 유틸리티
git mv lib/design_system/utils/* lib/features/common/presentation/design_system/utils/

# 커밋
git add .
git commit -m "refactor(common): migrate design system to presentation layer"
```

### Phase 4: Actions 이동 (presentation/actions/)

```bash
# 전역 액션
git mv lib/actions/actions.dart lib/features/common/presentation/actions/global_actions.dart

# 커밋
git add .
git commit -m "refactor(common): migrate global actions to presentation layer"
```

### Phase 5: Core 폼/미디어 컴포넌트 이동

```bash
# 디렉토리 생성
mkdir -p lib/features/common/presentation/{forms,media}

# 폼 관련 이동
git mv lib/core/form_field_controller.dart lib/features/common/presentation/forms/

# 미디어 관련 이동
git mv lib/core/app_video_player.dart lib/features/common/presentation/media/
git mv lib/core/app_media_display.dart lib/features/common/presentation/media/

# 커밋
git add .
git commit -m "refactor(common): migrate core form and media components"
```

### Phase 6: Constants 및 Models 이동 (domain/models/)

```bash
# 레이아웃 상수
git mv lib/shared/constants/layout_constants.dart lib/features/common/domain/models/

# Core 모델 이동
git mv lib/core/uploaded_file.dart lib/features/common/domain/models/
git mv lib/core/lat_lng.dart lib/features/common/domain/models/
git mv lib/core/place.dart lib/features/common/domain/models/

# 커밋
git add .
git commit -m "refactor(common): migrate constants and core models to domain layer"
```

### Phase 7: Import 경로 일괄 수정

```bash
# VS Code의 경우
# 1. Cmd+Shift+F (전체 찾기/바꾸기)
# 2. 정규식 모드 활성화
# 3. 다음 패턴으로 일괄 변경:

# 찾기: import '/?utils/
# 바꾸기: import '/features/common/data/services/

# 찾기: import '/?design_system/
# 바꾸기: import '/features/common/presentation/design_system/

# 찾기: import '/?widgets/
# 바꾸기: import '/features/common/presentation/widgets/

# 찾기: import '/?actions/
# 바꾸기: import '/features/common/presentation/actions/

# 찾기: import '/?shared/constants/
# 바꾸기: import '/features/common/domain/models/

# Core 파일들의 import 경로 수정
# 찾기: import '/?core/app_utils\.dart
# 바꾸기: import '/features/common/presentation/utils/app_utils.dart

# 찾기: import '/?core/app_widgets\.dart
# 바꾸기: import '/features/common/presentation/widgets/app_widgets.dart

# 찾기: import '/?core/uploaded_file\.dart
# 바꾸기: import '/features/common/domain/models/uploaded_file.dart
```

### Phase 8: 검증 및 테스트

```bash
# 빌드 테스트
flutter clean
flutter pub get
flutter build ios --debug

# 단위 테스트 실행
flutter test

# 분석 실행
flutter analyze
```

## 📝 Import 경로 업데이트

### 영향받는 주요 파일들

| 파일 그룹 | 예상 영향 파일 수 | 설명 |
|----------|-----------------|------|
| 로거 사용 | 50개+ | app_logger 사용 파일 |
| 디자인 시스템 | 100개+ | VersusColors, VersusSpacing 등 |
| 비디오 플레이어 | 10개+ | 비디오 재생 관련 |
| 필터 사용 | 20개+ | content_filter 사용 |

### Import 변경 예시

```dart
// Before
import '/utils/app_logger.dart';
import '/design_system/tokens/versus_colors.dart';
import '/widgets/highlighted_text_field.dart';

// After
import '/features/common/data/services/app_logger.dart';
import '/features/common/presentation/design_system/tokens/versus_colors.dart';
import '/features/common/presentation/widgets/highlighted_text_field.dart';
```

## ✅ 검증 체크리스트

### 기능별 테스트

#### 1. 로깅 시스템
- [ ] 로그 파일 생성
- [ ] 로그 레벨 필터링
- [ ] 디버그 모드 확인

#### 2. 디자인 시스템
- [ ] 색상 테마 적용
- [ ] 간격 일관성
- [ ] 타이포그래피 표시
- [ ] 커스텀 아이콘 렌더링

#### 3. 비디오 재생
- [ ] 로컬 비디오 재생
- [ ] YouTube 비디오 재생
- [ ] 컨트롤 동작

#### 4. 콘텐츠 필터
- [ ] 텍스트 필터링
- [ ] 금지어 검출

## ⚠️ 주의사항

### 1. 디자인 시스템
- 모든 feature가 사용하므로 신중하게 이동
- 테마 적용 확인 필수

### 2. 로거
- 파일 경로 하드코딩 확인
- 로그 레벨 설정 유지

### 3. 비디오 플레이어
- 플랫폼별 호환성 테스트
- 메모리 관리 확인

## 📊 예상 영향도

| 구분 | 영향도 | 파일 수 | 설명 |
|------|--------|---------|------|
| **Utils** | 높음 | 5개 | 전역 유틸리티 |
| **Design System** | 매우 높음 | 15개+ | 모든 UI 영향 |
| **Widgets** | 중간 | 6개 | 특정 기능만 사용 |
| **Actions** | 낮음 | 1개 | 제한적 사용 |
| **총 영향** | **매우 높음** | **200개+** | 전체 앱 영향 |

## 🔄 롤백 계획

```bash
# 문제 발생 시 롤백
git reset --hard HEAD~1
git checkout main

# 또는 백업 브랜치로 복귀
git checkout backup/before-common-migration
```

## 📅 예상 소요 시간 (상세)

| Phase | 작업 내용 | 소요 시간 | 난이도 | 체크포인트 |
|-------|-----------|----------|--------|------------|
| Phase 0: 준비 | 백업 및 브랜치 생성 | 10분 | ⭐ | 브랜치 생성 확인 |
| Phase 1: Utils | 유틸리티 + Core utils | 40분 | ⭐⭐ | Import 에러 없음 |
| Phase 2: Widgets | 위젯 + Core 위젯 | 1시간 | ⭐⭐⭐ | UI 렌더링 정상 |
| Phase 3: Design System | 15개+ 디자인 파일 이동 | 2시간 | ⭐⭐⭐⭐ | 테마 적용 확인 |
| Phase 4: Actions | 전역 액션 이동 | 15분 | ⭐ | 액션 동작 확인 |
| Phase 5: Core 폼/미디어 | Core 컴포넌트 | 30분 | ⭐⭐ | 컴포넌트 동작 확인 |
| Phase 6: Models | 상수 + Core 모델 | 30분 | ⭐⭐ | 모델 참조 정상 |
| Phase 7: Import 수정 | 전체 Import 경로 수정 | 2시간 | ⭐⭐⭐⭐ | 컴파일 성공 |
| Phase 8: 테스트 | 통합 테스트 및 검증 | 30분 | ⭐⭐ | 모든 기능 동작 |
| **총 소요 시간** | **전체 마이그레이션** | **7시간** | ⭐⭐⭐ | 프로덕션 준비 완료 |

## 🚀 실행 가이드

### 1단계: 준비 작업
```bash
# 현재 상태 저장
git add .
git commit -m "chore: save current state before common migration"

# 마이그레이션 브랜치 생성  
git checkout -b feature/common-migration

# 디렉토리 구조 생성
bash << 'EOF'
mkdir -p lib/features/common/{data/{repositories,services},domain/{models,usecases},presentation/{widgets,design_system/{tokens,components},actions}}
EOF
```

### 2단계: Phase별 실행 명령어

모든 파일 이동은 각 Phase별로 진행하고 커밋:
- Phase 1: Utils (5개 파일)
- Phase 2: Widgets (6개 파일)  
- Phase 3: Design System (15개+ 파일)
- Phase 4: Actions (1개 파일)
- Phase 5: Constants (1개 파일)

### 3단계: 최종 커밋 및 PR
```bash
# 최종 커밋
git add .
git commit -m "refactor(common): complete feature-first architecture migration"

# PR 생성
git push origin feature/common-migration
# GitHub에서 PR 생성 및 리뷰 요청
```

## 📊 마이그레이션 체크리스트

### Pre-Migration
- [ ] 현재 코드 백업 완료
- [ ] feature/common-migration 브랜치 생성
- [ ] 팀원들에게 마이그레이션 공지

### Migration Progress  
- [ ] Phase 0: 준비 작업 완료 (10분)
- [ ] Phase 1: Utils + Core utils 이동 완료 (40분)
- [ ] Phase 2: Widgets + Core widgets 이동 완료 (1시간)
- [ ] Phase 3: Design System 이동 완료 (2시간)
- [ ] Phase 4: Actions 이동 완료 (15분)
- [ ] Phase 5: Core 폼/미디어 이동 완료 (30분)
- [ ] Phase 6: Models + Core models 이동 완료 (30분)
- [ ] Phase 7: Import 경로 수정 완료 (2시간)
- [ ] Phase 8: 테스트 통과 (30분)

### Post-Migration
- [ ] 모든 기능 수동 테스트
- [ ] 성능 벤치마크 실행
- [ ] 문서 업데이트
- [ ] PR 리뷰 및 머지
- [ ] 프로덕션 배포

## 🚀 다음 단계

1. **디자인 시스템 분리**
   - 독립적인 패키지로 분리 고려
   - Storybook 통합

2. **로거 고도화**
   - 원격 로깅 시스템 통합
   - 에러 추적 서비스 연동

3. **비디오 플레이어 최적화**
   - 캐싱 전략 구현
   - 스트리밍 최적화

## 📌 Core 마이그레이션 연동

**Core 분산 통합 완료**: Core 디렉토리의 파일들이 Common과 App으로 분산 마이그레이션됩니다:

### Common으로 이동하는 Core 파일들 (11개)
- `app_utils.dart` → `presentation/utils/` (Phase 1)
- `app_animations.dart` → `presentation/utils/` (Phase 1)
- `app_widgets.dart` → `presentation/widgets/` (Phase 2)
- `app_icon_button.dart` → `presentation/widgets/` (Phase 2)
- `app_toggle_icon.dart` → `presentation/widgets/` (Phase 2)
- `form_field_controller.dart` → `presentation/forms/` (Phase 5)
- `app_video_player.dart` → `presentation/media/` (Phase 5)
- `app_media_display.dart` → `presentation/media/` (Phase 5)
- `uploaded_file.dart` → `domain/models/` (Phase 6)
- `lat_lng.dart` → `domain/models/` (Phase 6)
- `place.dart` → `domain/models/` (Phase 6)

### App으로 이동하는 Core 파일들 (9개)
- `/nav/` 디렉토리 전체 → `/app/router/`
- `app_theme.dart` → `/app/theme/`
- `app_localizations.dart` → `/app/localization/`
- `internationalization.dart` → `/app/localization/`
- 기타 앱 전역 설정 파일들

**참고**: 상세 Core 마이그레이션은 `/lib/core/CORE_MIGRATION.md` 및 `/lib/app/MIGRATION_APP.md` 참조

---

*이 문서는 Feature-First Architecture 마이그레이션의 Common Feature 통합 가이드입니다.*
*작성일: 2025-08-25*
*버전: 2.1 (Core 분산 통합 반영)*