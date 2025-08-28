# 📋 Core Actions 레이어

> 애플리케이션 전역 액션 및 커맨드 관리 레이어  
> 최종 업데이트: 2025-08-28 | 버전: 1.0.0

## 📋 개요

Core Actions는 Versus Space 애플리케이션의 전역 액션과 시스템 상호작용을 관리하는 레이어입니다. 
현재는 최소한의 액션만 구현되어 있으며, Feature-First Architecture에 따라 체계적인 확장이 필요한 상태입니다.

## 🏗️ 현재 디렉토리 구조

```
lib/core/actions/
├── README.md                 # 250줄 - 상세 문서 (이미 존재)
└── global_actions.dart       # 14줄 - 언어 선택 액션 (최소 구현)
```

## 🔍 현재 코드 분석

### global_actions.dart (14줄)

#### 현재 구현
```dart
import '/features/auth/data/services/auth_util.dart';
import '/backend/backend.dart';
import '/core_exports.dart';
import 'package:flutter/material.dart';

Future selectedLanguage(
  BuildContext context, {
  String? language,
}) async {
  await currentUserReference!.update(createUsersModelData(
    language: valueOrDefault(currentUserDocument?.language, ''),
  ));
}
```

#### 문제점
1. **최소 구현**: 단 하나의 액션만 존재 (언어 선택)
2. **잘못된 의존성**: features 레이어에 직접 의존 (`/features/auth/data/services/auth_util.dart`)
3. **하드코딩**: currentUserReference 직접 참조
4. **에러 처리 없음**: null 체크나 예외 처리 부재
5. **이상한 로직**: 현재 언어를 다시 저장하는 무의미한 로직

## 📊 실제 필요한 구조 vs 현재 상태

### 기존 README.md에 명시된 이상적 구조
```
actions/
├── app_actions.dart        # 앱 전역 시스템 제어
├── url_actions.dart        # URL 및 딥링크 처리
├── share_actions.dart      # 콘텐츠 공유 기능
├── clipboard_actions.dart  # 클립보드 관리
├── file_actions.dart       # 파일 시스템 접근
├── permission_actions.dart # 시스템 권한 관리
├── error_actions.dart      # 에러 처리 및 피드백
├── analytics_actions.dart  # 분석 이벤트 추적
└── notification_actions.dart # 사용자 알림 표시
```

### 실제 현재 상태
```
actions/
└── global_actions.dart     # 14줄, 언어 선택만 구현
```

**구현율**: 1/9 = **11%** 😱

## ⚠️ 현재 문제점 종합

### 1. 아키텍처 문제
- **계층 위반**: Core가 Features에 의존 (역방향 의존성)
- **단일 책임 위반**: 너무 적은 기능으로 디렉토리 존재 의미 없음
- **추상화 부재**: 인터페이스나 추상 클래스 없음

### 2. 구현 문제
- **8개 액션 클래스 미구현**: 계획만 있고 실제 코드 없음
- **에러 처리 없음**: try-catch, null check 전무
- **테스트 불가능**: 직접 의존으로 인한 테스트 어려움

### 3. 문서와 코드 불일치
- README.md는 250줄의 상세한 계획
- 실제 코드는 14줄의 최소 구현
- **문서-코드 괴리도: 95%**

## 🎯 Feature-First Architecture 적용 방안

### 1. 올바른 계층 구조
```
lib/
├── core/
│   ├── actions/          # 추상 인터페이스만
│   │   ├── interfaces/   # 액션 인터페이스 정의
│   │   └── models/       # 액션 관련 모델
│   │
├── services/             # 실제 구현
│   └── actions/
│       ├── app_actions_service.dart
│       ├── url_actions_service.dart
│       ├── share_actions_service.dart
│       └── ...
│
└── features/
    └── [각 feature]/
        └── actions/      # Feature별 전용 액션
```

### 2. 의존성 방향 수정
```dart
// ❌ 현재: Core → Features (잘못됨)
import '/features/auth/data/services/auth_util.dart';

// ✅ 개선: Features → Core (올바름)
// core/actions/interfaces/language_action.dart
abstract class ILanguageAction {
  Future<void> updateLanguage(String language);
}

// features/auth/actions/language_action_impl.dart
class LanguageActionImpl implements ILanguageAction {
  @override
  Future<void> updateLanguage(String language) async {
    // 구현
  }
}
```

### 3. DI를 통한 의존성 주입
```dart
// app/di/injection.dart
@module
abstract class ActionModule {
  @lazySingleton
  ILanguageAction get languageAction => LanguageActionImpl();
  
  @lazySingleton
  IUrlAction get urlAction => UrlActionImpl();
  
  // ... 나머지 액션들
}
```

## 📊 리팩토링 우선순위

| 작업 | 우선순위 | 예상 시간 | 난이도 | 영향도 |
|------|---------|----------|--------|--------|
| 의존성 방향 수정 | 🔴 매우 높음 | 2시간 | 중간 | 높음 |
| 인터페이스 분리 | 🔴 매우 높음 | 3시간 | 중간 | 높음 |
| 핵심 액션 구현 | 🟡 중간 | 2일 | 높음 | 높음 |
| 테스트 작성 | 🟡 중간 | 1일 | 중간 | 중간 |
| 나머지 액션 구현 | 🟢 낮음 | 3일 | 중간 | 낮음 |

## 🚀 구현 로드맵

### Phase 1: 아키텍처 수정 (1일)
```dart
// 1. 인터페이스 정의
// core/actions/interfaces/i_app_action.dart
abstract class IAppAction {
  Future<void> setLanguage(String language);
  Future<void> setTheme(ThemeMode theme);
  // ...
}

// 2. 모델 정의
// core/actions/models/action_result.dart
class ActionResult<T> {
  final bool success;
  final T? data;
  final String? error;
  // ...
}
```

### Phase 2: 핵심 액션 구현 (2일)
- AppActions: 앱 전역 제어
- UrlActions: URL 처리
- ErrorActions: 에러 처리
- NotificationActions: 알림 표시

### Phase 3: 추가 액션 구현 (3일)
- ShareActions: 공유 기능
- ClipboardActions: 클립보드
- FileActions: 파일 처리
- PermissionActions: 권한 관리
- AnalyticsActions: 분석 추적

### Phase 4: 테스트 및 문서화 (1일)
- 단위 테스트 작성
- 통합 테스트 작성
- 사용 가이드 업데이트

## 📝 즉시 필요한 수정사항

### 1. global_actions.dart 수정
```dart
// 현재 (문제 있음)
Future selectedLanguage(
  BuildContext context, {
  String? language,
}) async {
  await currentUserReference!.update(createUsersModelData(
    language: valueOrDefault(currentUserDocument?.language, ''),
  ));
}

// 개선안
Future<ActionResult> updateLanguage(String language) async {
  try {
    if (language.isEmpty) {
      return ActionResult.failure('Language cannot be empty');
    }
    
    await getIt<IUserRepository>().updateUserLanguage(language);
    
    return ActionResult.success();
  } catch (e) {
    return ActionResult.failure(e.toString());
  }
}
```

## 🔗 연관 파일 및 의존성

### 현재 잘못된 의존성
- `/features/auth/data/services/auth_util.dart` ❌
- `/backend/backend.dart` ⚠️

### 올바른 의존성 방향
- `/core/interfaces/` ✅
- `/core/models/` ✅
- `/services/` (구현부) ✅

### 영향받을 Feature들
- Auth Feature: 언어 설정 기능
- Settings Feature: 앱 설정 관련
- 모든 Feature: 공통 액션 사용

## 📋 체크리스트

### 즉시 수정 필요
- [ ] Features 의존성 제거
- [ ] 인터페이스 분리
- [ ] 에러 처리 추가
- [ ] null safety 개선

### 단기 목표 (1주일)
- [ ] 핵심 4개 액션 구현
- [ ] DI 통합
- [ ] 기본 테스트 작성

### 장기 목표 (2주일)
- [ ] 9개 액션 전체 구현
- [ ] 완전한 테스트 커버리지
- [ ] 문서 일치화

## 💡 핵심 개선 포인트

### 1. 계층 분리
```
Core (인터페이스) → Services (구현) → Features (사용)
```

### 2. 테스트 가능성
```dart
// 모든 액션을 테스트 가능하게
class MockUrlAction extends Mock implements IUrlAction {}
```

### 3. 에러 처리
```dart
// 일관된 에러 처리 패턴
try {
  // 액션 수행
} on ActionException catch (e) {
  // 처리
}
```

## ⚡ 성능 고려사항

- **Lazy Loading**: 필요한 액션만 초기화
- **캐싱**: 권한 상태 등 캐싱
- **배치 처리**: 분석 이벤트 배치 전송

## 🚨 주의사항

1. **Breaking Change**: 의존성 방향 변경은 큰 변경사항
2. **Feature 영향**: 모든 Feature가 액션 사용 시 영향
3. **마이그레이션**: 점진적 마이그레이션 전략 필요
4. **테스트**: 각 단계별 철저한 테스트 필수

---

*이 문서는 Core Actions 레이어의 현재 상태와 개선 방안을 담고 있습니다.*  
*현재 11% 구현으로 대대적인 개발이 필요한 상황입니다.*