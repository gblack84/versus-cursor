# 🎯 Core Layer 상세 문서

> Feature-First Architecture의 핵심 공통 레이어  
> 최종 업데이트: 2025-08-28 | 버전: 3.0.0

## 📋 개요

Core Layer는 Versus Space 애플리케이션 전체에서 재사용되는 공통 요소들을 관리합니다.
디자인 시스템, 유틸리티, 위젯, 테마 등 모든 Feature가 공유하는 핵심 구성 요소들의 중앙 저장소입니다.

## 🚀 마이그레이션 현황

**통합 마이그레이션 문서가 작성되었습니다**: [MIGRATION_CORE_ORDER_RULES.md](./MIGRATION_CORE_ORDER_RULES.md)

### 마이그레이션 문서 구조
- **통합 규칙 문서**: `MIGRATION_CORE_ORDER_RULES.md` - 전체 실행 순서와 규칙
- **Actions**: `actions/MIGRATION_Part3.md` - 액션 시스템 구축 (14줄 → 500줄)
- **Animations**: `animations/MIGRATION_Part3.md` - 애니메이션 시스템 (11개 파일)
- **Constants**: `constants/MIGRATION_Part3.md` - 상수 관리 체계화
- **Design System**: `design_system/MIGRATION_Part3.md` - 컴포넌트 라이브러리
- **Localization**: `localization/MIGRATION_Part3.md` - 다국어 지원
- **Models**: `models/MIGRATION_Part3.md` - 데이터 모델 (3개 파일)
- **Theme**: `theme/MIGRATION_Part3.md` - 테마 시스템 (6개 파일)
- **Utils**: `utils/MIGRATION_Part3.md` - 유틸리티 함수 (26개 파일)
- **Widgets**: `widgets/MIGRATION_Part3.md` - 공통 위젯 (18개 파일)

## 🏗️ 현재 디렉토리 구조

```
lib/core/
├── actions/                    # 전역 액션 시스템 (14줄, 89% 미구현)
│   ├── global_actions.dart    # 언어 설정만 구현
│   └── README.md               # 250줄 계획 문서
├── animations/                 # 애니메이션 시스템 (Complete ✅)
│   ├── animations.dart        # 커브 정의 (50줄)
│   ├── effects/               # 11개 애니메이션 효과
│   └── README.md
├── constants/                  # 상수 정의 (Complete ✅)
│   ├── icon_constants.dart   # 아이콘 상수 (26줄)
│   └── README.md
├── design_system/              # 디자인 시스템 (In Progress 🔄)
│   ├── components/            # UI 컴포넌트 라이브러리
│   ├── tokens/                # 디자인 토큰 (색상, 간격, 타이포)
│   └── README.md
├── internationalization/       # 다국어 지원 (Legacy ⚠️)
│   └── lang/                  # 번역 파일 (en.json만 존재)
├── localization/               # 새 다국어 시스템 (Complete ✅)
│   ├── app_localizations.dart # 16개 언어 지원 (2419줄)
│   └── README.md
├── models/                     # 데이터 모델
│   ├── action.dart           # 액션 모델 (26줄)
│   ├── data_map_model.dart   # 맵 모델 (81줄)
│   ├── uploaded_file.dart    # 업로드 파일 (186줄)
│   └── README.md
├── nav/                        # 네비게이션 (App Layer로 이동 필요 ❌)
│   └── nav.dart              # 미사용 네비게이션 코드
├── theme/                      # 테마 시스템 (Complete ✅)
│   ├── app_theme.dart        # 메인 테마 (6개 파일)
│   └── README.md
├── utils/                      # 유틸리티 함수 (Complete ✅)
│   ├── util.dart             # 26개 유틸리티 파일
│   └── README.md
├── widgets/                    # 공통 위젯 (In Progress 🔄)
│   ├── 18개 위젯 파일
│   └── README.md
├── core_exports.dart          # 전체 export (172줄)
└── index.dart                 # 레거시 export (21줄)
```

## 🔍 현재 코드 분석

### 디렉토리별 상태 평가

| 디렉토리 | 파일 수 | 총 줄 수 | 상태 | 우선순위 |
|---------|--------|---------|------|---------|
| **actions** | 1 | 14 | 🔴 미구현 (89%) | Critical |
| **animations** | 11 | 2,083 | 🟢 완성 | Low |
| **constants** | 1 | 26 | 🟢 완성 | Low |
| **design_system** | 15 | 3,412 | 🟡 진행중 | High |
| **localization** | 1 | 2,419 | 🟢 완성 | Low |
| **models** | 3 | 293 | 🟡 개선 필요 | Medium |
| **theme** | 6 | 892 | 🟢 완성 | Low |
| **utils** | 26 | 3,547 | 🟢 완성 | Low |
| **widgets** | 18 | 2,941 | 🟡 진행중 | High |

### 핵심 문제점

#### 1. 계층 위반 (Critical)
```dart
// core/actions/global_actions.dart
import '/features/auth/data/services/auth_util.dart';  // ❌ Core가 Feature에 의존
```

#### 2. 구현 부족 (High)
- Actions: 9개 계획, 1개 구현 (11% 구현율)
- Widgets: 테스트 0%, 구조화 필요
- Design System: 컴포넌트 라이브러리 미완성

#### 3. 네이밍 불일치 (Medium)
- FF/FlutterFlow 접두사 → App 접두사 (완료)
- App 접두사 → Versus 접두사 (진행 필요)
- 파일명 철자 오류: editviedo → editvideo

#### 4. 중복 및 레거시 (Low)
- 비디오 플레이어 3개 중복
- internationalization vs localization 중복
- nav.dart 미사용 코드

## 🛠️ Feature-First Architecture 개선 방안

### 1. 즉시 개선 필요 (Critical)

#### Actions 시스템 재구축
```dart
// 현재: Core가 Feature에 의존
core/actions/global_actions.dart → auth_util.dart 

// 개선안: 인터페이스 기반 설계
// lib/core/actions/interfaces/i_app_action.dart
abstract class IAppAction {
  Future<ActionResult> execute(ActionContext context);
}

// lib/services/actions/app_actions_service.dart
class AppActionsService implements IAppAction {
  final AuthService _authService;
  
  AppActionsService(this._authService);
  
  @override
  Future<ActionResult> execute(ActionContext context) {
    // 실제 구현
  }
}
```

#### Widgets 카테고리화
```dart
// 현재: 모든 위젯이 한 디렉토리에
core/widgets/
├── app_widgets.dart
├── app_icon_button.dart
├── highlighted_text_field.dart
└── ... (18개 파일)

// 개선안: 카테고리별 정리
core/widgets/
├── buttons/
│   ├── versus_button.dart
│   └── versus_icon_button.dart
├── inputs/
│   ├── versus_text_field.dart
│   └── highlighted_text_field.dart
├── media/
│   ├── versus_video_player.dart
│   └── youtube_player_widget.dart
└── feedback/
    ├── versus_loading.dart
    └── versus_empty_state.dart
```

### 2. 중기 개선 사항

#### Design System 완성
```dart
// lib/core/design_system/components/
├── buttons/
│   ├── primary_button.dart
│   ├── secondary_button.dart
│   └── text_button.dart
├── cards/
│   ├── content_card.dart
│   └── versus_card.dart
└── forms/
    ├── form_field.dart
    └── form_validators.dart
```

#### 테스트 커버리지 구축
```dart
// test/core/
├── actions/        # 목표: 95%
├── animations/     # 목표: 80%
├── widgets/        # 목표: 90%
└── utils/          # 목표: 85%
```

### 3. 파일 이동 계획

#### 삭제 필요
| 파일 | 이유 |
|------|------|
| `core/nav/nav.dart` | 미사용, App Layer에 있음 |
| `core/internationalization/` | localization으로 통합 |
| `core/index.dart` | core_exports.dart로 통합 |

#### 이동 필요
| 현재 위치 | 이동 대상 | 이유 |
|---------|----------|------|
| `core/models/action.dart` | `core/actions/models/` | 액션 관련 |
| 비디오 플레이어 중복 | 단일 통합 플레이어 | 중복 제거 |

## 📊 현재 상태 평가

### 강점
- ✅ 완성된 시스템: animations, constants, localization, theme, utils
- ✅ 다국어 지원 16개 언어
- ✅ 애니메이션 효과 11개
- ✅ 유틸리티 함수 26개

### 약점
- ❌ Actions 시스템 89% 미구현
- ❌ Core → Feature 의존성 위반
- ❌ 위젯 테스트 0%
- ❌ Design System 미완성

### 기회
- 🔄 Actions를 인터페이스 기반으로 재설계
- 🔄 Widgets 카테고리화로 관리 개선
- 🔄 Design System 완성으로 일관성 향상
- 🔄 테스트 추가로 안정성 확보

## 🎯 마이그레이션 액션 플랜

### 전체 일정: 3주

#### Week 1: Actions & Design System
- **Day 1-2**: Actions 인터페이스 설계 및 구현
- **Day 3-4**: Design System 컴포넌트 라이브러리 구축
- **Day 5**: 테스트 작성 및 문서화

#### Week 2: Widgets 리팩토링
- **Day 1**: 디렉토리 구조 재편성
- **Day 2-3**: App → Versus 네이밍 변경
- **Day 4**: 중복 제거 및 통합
- **Day 5**: 위젯 테스트 작성

#### Week 3: 정리 및 최적화
- **Day 1-2**: Models 정리 및 이동
- **Day 3**: 레거시 코드 제거
- **Day 4-5**: 통합 테스트 및 성능 최적화

### 상세 실행 계획은 [MIGRATION_CORE_ORDER_RULES.md](./MIGRATION_CORE_ORDER_RULES.md) 참조

## 📝 코드 예시

### 개선된 Actions 구조
```dart
// lib/core/actions/interfaces/i_action.dart
abstract interface class IAction<T> {
  Future<ActionResult<T>> execute(ActionContext context);
  bool canExecute(ActionContext context);
  void undo();
}

// lib/core/actions/models/action_result.dart
class ActionResult<T> {
  final bool success;
  final T? data;
  final String? error;
  final Duration executionTime;
  
  const ActionResult({
    required this.success,
    this.data,
    this.error,
    required this.executionTime,
  });
}

// lib/services/actions/language_action_service.dart
class LanguageActionService implements IAction<String> {
  final SharedPreferences _prefs;
  final LocalizationService _localization;
  
  @override
  Future<ActionResult<String>> execute(ActionContext context) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final language = context.params['language'] as String;
      await _prefs.setString('selectedLanguage', language);
      await _localization.setLanguage(language);
      
      return ActionResult(
        success: true,
        data: language,
        executionTime: stopwatch.elapsed,
      );
    } catch (e) {
      return ActionResult(
        success: false,
        error: e.toString(),
        executionTime: stopwatch.elapsed,
      );
    }
  }
}
```

## ⚠️ 마이그레이션 주의사항

### 핵심 원칙
1. **계층 무결성**: Core는 Feature에 절대 의존하지 않음
2. **점진적 마이그레이션**: 기능 유지하며 단계별 진행
3. **테스트 우선**: 변경 전 테스트 작성
4. **문서화**: 모든 변경사항 즉시 문서화
5. **백업 필수**: 각 단계별 체크포인트 생성

### 백업 전략
```bash
# 마이그레이션 시작 전
git checkout -b migration/core-layer-$(date +%Y%m%d)
git tag -a backup/core-pre-migration -m "Before core layer migration"

# 각 디렉토리별 체크포인트
git tag -a checkpoint/core-actions -m "Actions migration complete"
git tag -a checkpoint/core-widgets -m "Widgets migration complete"
```

### 상세 규칙은 [MIGRATION_CORE_ORDER_RULES.md](./MIGRATION_CORE_ORDER_RULES.md) 참조

## 📚 참고 자료

### 마이그레이션 문서
- [통합 마이그레이션 규칙](./MIGRATION_CORE_ORDER_RULES.md)
- [Actions 마이그레이션](./actions/MIGRATION_Part3.md)
- [Animations 마이그레이션](./animations/MIGRATION_Part3.md)
- [Constants 마이그레이션](./constants/MIGRATION_Part3.md)
- [Design System 마이그레이션](./design_system/MIGRATION_Part3.md)
- [Localization 마이그레이션](./localization/MIGRATION_Part3.md)
- [Models 마이그레이션](./models/MIGRATION_Part3.md)
- [Theme 마이그레이션](./theme/MIGRATION_Part3.md)
- [Utils 마이그레이션](./utils/MIGRATION_Part3.md)
- [Widgets 마이그레이션](./widgets/MIGRATION_Part3.md)

### 아키텍처 문서
- [Feature-First Architecture Guide](/FEATURE_ARCHITECTURE.md)
- [Global Layers Documentation](/GLOBAL_LAYERS.md)
- [Development Rules](/DEVELOPMENT_RULES.md)

---

*이 문서는 Core Layer의 현재 상태와 마이그레이션 계획을 담고 있습니다.*
*마지막 업데이트: 2025-08-28*