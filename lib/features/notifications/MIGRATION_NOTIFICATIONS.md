# 📦 /lib/features/notifications 디렉토리 마이그레이션 가이드

> Feature-First Architecture - Notifications Feature 독립 모듈 구성

## 🎯 목적

모든 알림 관련 기능을 `/lib/features/notifications` 폴더로 통합하여 확장 가능한 통합 알림 시스템을 구축합니다.

## 🔄 Core/App 마이그레이션 의존성

### FlutterFlow → Native Flutter 변환
이 기능은 다음 Core/App 마이그레이션 항목들과 의존성이 있습니다:

| 변경 사항 | 영향받는 컴포넌트 | 필요 작업 |
|----------|----------------|----------|
| **FFAppState → AppState** | 알림 상태 관리 | `Provider<AppState>` 사용 |
| **flutter_flow/ → core/** | 알림 유틸리티 | Import 경로 변경 |
| **FF 접두사 제거** | 알림 위젯 | `FFAlertDialog` → `AppAlertDialog` |
| **AppTheme 통합** | 알림 UI 테마 | `AppTheme.of(context)` 사용 |

### Import 변경 예시
```dart
// Before (FlutterFlow)
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

// After (Native Flutter)
import '/core/app_theme.dart';
import '/core/utils/app_utils.dart';
```

## 📋 현재 상태 분석

### 알림 관련 디렉토리 현황
| 디렉토리/파일 그룹 | 파일 수 | 설명 |
|-------------------|---------|------|
| `/lib/services/notification_service.dart` | 1개 | 알림 핵심 서비스 |
| `/lib/services/global_notification_manager.dart` | 1개 | 전역 알림 관리 |
| `/lib/services/target_audience_service.dart` | 1개 | 타겟 오디언스 서비스 |
| `/lib/components/notifications/` | 14개 | 알림 UI 컴포넌트 |
| `/lib/backend/schema/notification*` | 2개 | 알림 스키마 |
| `/lib/pages/notifications_list/` | 2개 | 알림 목록 화면 |
| **총합** | **21개** | 알림 관련 전체 파일 |

### 알림 타입 분류
| 타입 | 현재 상태 | 향후 계획 |
|------|----------|----------|
| **투표 알림** | ✅ 구현됨 | 유지 |
| **채팅 알림** | ❌ 미구현 | FCM 통합 필요 |
| **친구 요청 알림** | ❌ 미구현 | 향후 추가 |
| **시스템 알림** | ❌ 미구현 | 향후 추가 |

## 🏗️ Feature-First 구조 매핑

```
/lib/features/notifications/
├── data/
│   ├── datasources/
│   │   ├── local_notification_datasource.dart    # 로컬 알림 데이터
│   │   ├── remote_notification_datasource.dart   # Firebase 알림 데이터
│   │   └── fcm_datasource.dart                  # FCM 푸시 알림 (향후)
│   │
│   ├── repositories/
│   │   ├── notification_repository_impl.dart     # 알림 레포지토리 구현
│   │   └── fcm_repository_impl.dart             # FCM 레포지토리 (향후)
│   │
│   └── services/
│       ├── notification_service.dart             # 알림 서비스
│       ├── global_notification_manager.dart      # 전역 알림 관리
│       ├── fcm_service.dart                     # FCM 서비스 (향후)
│       └── notification_queue_service.dart       # 알림 큐 관리
│
├── domain/
│   ├── models/
│   │   ├── notification_model.dart              # 기본 알림 모델
│   │   ├── vote_notification.dart               # 투표 알림 모델
│   │   ├── chat_notification.dart               # 채팅 알림 모델 (향후)
│   │   ├── friend_notification.dart             # 친구 요청 알림 (향후)
│   │   ├── system_notification.dart             # 시스템 알림 (향후)
│   │   └── notification_type.dart               # 알림 타입 enum
│   │
│   ├── repositories/
│   │   └── notification_repository.dart         # 알림 레포지토리 인터페이스
│   │
│   └── usecases/
│       ├── send_notification_usecase.dart       # 알림 전송
│       ├── mark_as_read_usecase.dart           # 읽음 처리
│       ├── get_unread_count_usecase.dart       # 읽지 않은 개수
│       ├── delete_notification_usecase.dart     # 알림 삭제
│       ├── get_notifications_usecase.dart       # 알림 목록 조회
│       └── subscribe_to_fcm_usecase.dart       # FCM 구독 (향후)
│
└── presentation/
    ├── screens/
    │   ├── notifications_list/                  # 알림 목록 화면
    │   │   ├── notifications_list_widget.dart
    │   │   └── notifications_list_model.dart
    │   │
    │   └── notification_settings/               # 알림 설정 화면 (향후)
    │       ├── notification_settings_widget.dart
    │       └── notification_settings_model.dart
    │
    ├── widgets/
    │   ├── notification_badge.dart              # 알림 뱃지
    │   ├── notification_overlay.dart            # 알림 오버레이
    │   ├── notification_dialog.dart             # 알림 다이얼로그
    │   ├── notification_list_item.dart          # 알림 목록 아이템
    │   ├── notification_image_viewer.dart       # 이미지 뷰어
    │   ├── notification_empty_state.dart        # 빈 상태 표시
    │   └── notification_type_icon.dart          # 타입별 아이콘
    │
    ├── providers/
    │   ├── notification_provider.dart           # 알림 상태 관리
    │   ├── notification_badge_provider.dart     # 뱃지 상태 관리
    │   └── fcm_provider.dart                    # FCM 상태 관리 (향후)
    │
    └── constants/
        ├── notification_constraints.dart         # 알림 제약사항
        ├── notification_strings.dart             # 알림 문자열
        └── notification_styles.dart              # 알림 스타일
```

## 📁 상세 파일 이동 계획

### Phase 0: 준비 작업
```bash
# 현재 상태 저장
git add .
git commit -m "chore: save current state before notifications migration"

# 마이그레이션 브랜치 생성
git checkout -b feature/notifications-migration

# 디렉토리 구조 생성
mkdir -p lib/features/notifications/data/{datasources,repositories,services}
mkdir -p lib/features/notifications/domain/{models,repositories,usecases}
mkdir -p lib/features/notifications/presentation/{screens/notifications_list,widgets,providers,constants}
```

### Phase 1: Services 이동 (data/services/)

```bash
# 알림 서비스 이동
git mv lib/services/notification_service.dart lib/features/notifications/data/services/
git mv lib/services/global_notification_manager.dart lib/features/notifications/data/services/
git mv lib/services/target_audience_service.dart lib/features/notifications/data/services/

# 새로 생성할 서비스
echo "// TODO: Implement notification queue service" > lib/features/notifications/data/services/notification_queue_service.dart
echo "// TODO: Implement FCM service" > lib/features/notifications/data/services/fcm_service.dart

# 커밋
git add .
git commit -m "feat(notifications): migrate services to feature module"
```

### Phase 2: Models 이동 (domain/models/)

```bash
# 알림 모델 이동
git mv lib/backend/schema/notifications_model.dart lib/features/notifications/domain/models/notification_model.dart
git mv lib/backend/schema/notification_model.dart lib/features/notifications/domain/models/notification_item_model.dart

# 새로 생성할 모델
cat > lib/features/notifications/domain/models/notification_type.dart << 'EOF'
enum NotificationType {
  vote,
  chat,
  friend,
  system,
}
EOF

echo "// TODO: Implement vote notification model" > lib/features/notifications/domain/models/vote_notification.dart
echo "// TODO: Implement chat notification model" > lib/features/notifications/domain/models/chat_notification.dart

# 커밋
git add .
git commit -m "feat(notifications): migrate models to domain layer"
```

### Phase 3: Screens 이동 (presentation/screens/)

```bash
# 알림 목록 화면 이동
git mv lib/pages/notifications_list/notifications_list_widget.dart lib/features/notifications/presentation/screens/notifications_list/
git mv lib/pages/notifications_list/notifications_list_model.dart lib/features/notifications/presentation/screens/notifications_list/

# 알림 설정 화면 스켈레톤 생성 (향후 구현)
mkdir -p lib/features/notifications/presentation/screens/notification_settings
echo "// TODO: Implement notification settings" > lib/features/notifications/presentation/screens/notification_settings/notification_settings_widget.dart

# 커밋
git add .
git commit -m "feat(notifications): migrate screens to presentation layer"
```

### Phase 4: Widgets 이동 (presentation/widgets/)

```bash
# 알림 UI 컴포넌트 이동
git mv lib/components/notifications/notification_badge.dart lib/features/notifications/presentation/widgets/
git mv lib/components/notifications/notification_overlay.dart lib/features/notifications/presentation/widgets/
git mv lib/components/notifications/in_app_notification_dialog.dart lib/features/notifications/presentation/widgets/notification_dialog.dart
git mv lib/components/notifications/widgets/notification_image_viewer.dart lib/features/notifications/presentation/widgets/

# 추가 위젯 생성
echo "// TODO: Implement notification list item" > lib/features/notifications/presentation/widgets/notification_list_item.dart
echo "// TODO: Implement empty state" > lib/features/notifications/presentation/widgets/notification_empty_state.dart
echo "// TODO: Implement type icon" > lib/features/notifications/presentation/widgets/notification_type_icon.dart

# Voting 특화 컴포넌트는 Voting Feature에 유지
# - lib/components/notifications/voting_notification_dialog.dart → /features/voting/
# - lib/components/notifications/voting_overlay.dart → /features/voting/
# - lib/components/notifications/versus_notification_box.dart → /features/voting/

# 커밋
git add .
git commit -m "feat(notifications): migrate widgets to presentation layer"
```

### Phase 5: Providers 이동 (presentation/providers/)

```bash
# Provider 파일 이동
git mv lib/components/notifications/notification_badge_provider.dart lib/features/notifications/presentation/providers/

# 새로 생성할 Provider
cat > lib/features/notifications/presentation/providers/notification_provider.dart << 'EOF'
import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  // TODO: Implement notification state management
}
EOF

echo "// TODO: Implement FCM provider" > lib/features/notifications/presentation/providers/fcm_provider.dart

# 커밋
git add .
git commit -m "feat(notifications): migrate providers to presentation layer"
```

### Phase 6: Repository 및 UseCases 생성

```bash
# Repository 인터페이스 생성
cat > lib/features/notifications/domain/repositories/notification_repository.dart << 'EOF'
abstract class NotificationRepository {
  Future<Either<Failure, List<NotificationModel>>> getNotifications({
    required String userId,
    NotificationType? type,
    int? limit,
  });
  
  Future<Either<Failure, void>> markAsRead({
    required String notificationId,
  });
  
  Stream<int> getUnreadCountStream(String userId);
}
EOF

# Repository 구현 생성
cat > lib/features/notifications/data/repositories/notification_repository_impl.dart << 'EOF'
// TODO: Implement repository
class NotificationRepositoryImpl implements NotificationRepository {
  // Implementation
}
EOF

# Datasources 생성
echo "// TODO: Implement local datasource" > lib/features/notifications/data/datasources/local_notification_datasource.dart
echo "// TODO: Implement remote datasource" > lib/features/notifications/data/datasources/remote_notification_datasource.dart

# UseCases 생성
echo "// TODO: Implement send notification usecase" > lib/features/notifications/domain/usecases/send_notification_usecase.dart
echo "// TODO: Implement mark as read usecase" > lib/features/notifications/domain/usecases/mark_as_read_usecase.dart
echo "// TODO: Implement get unread count usecase" > lib/features/notifications/domain/usecases/get_unread_count_usecase.dart

# 커밋
git add .
git commit -m "feat(notifications): create repository and usecases structure"
```

### Phase 7: Import 경로 업데이트 및 테스트

```bash
# Import 경로 일괄 업데이트
echo "📝 Updating import paths..."

# Service imports 업데이트
find lib -type f -name "*.dart" -exec sed -i '' \
  -e "s|import '/services/notification_service.dart'|import '/features/notifications/data/services/notification_service.dart'|g" \
  -e "s|import '/services/global_notification_manager.dart'|import '/features/notifications/data/services/global_notification_manager.dart'|g" {} +

# Widget imports 업데이트
find lib -type f -name "*.dart" -exec sed -i '' \
  -e "s|import '/components/notifications/notification_badge.dart'|import '/features/notifications/presentation/widgets/notification_badge.dart'|g" \
  -e "s|import '/components/notifications/notification_overlay.dart'|import '/features/notifications/presentation/widgets/notification_overlay.dart'|g" {} +

# Model imports 업데이트
find lib -type f -name "*.dart" -exec sed -i '' \
  -e "s|import '/backend/schema/notifications_model.dart'|import '/features/notifications/domain/models/notification_model.dart'|g" \
  -e "s|import '/backend/schema/notification_model.dart'|import '/features/notifications/domain/models/notification_item_model.dart'|g" {} +

# 빌드 테스트
flutter clean
flutter pub get
flutter analyze

# 테스트 실행
flutter test

# 커밋
git add .
git commit -m "feat(notifications): update import paths and verify build"
```

## 📝 Import 경로 업데이트 가이드

### 영향받는 주요 파일들

| 파일 그룹 | 예상 영향 파일 수 | 설명 |
|----------|-----------------|------|
| 홈 화면 | 5개+ | 알림 뱃지 표시 |
| 투표 관련 | 10개+ | 투표 알림 전송 |
| 채팅 관련 | 15개+ | 향후 채팅 알림 통합 |
| 프로필 관련 | 5개+ | 알림 설정 |

### Import 변경 예시

```dart
// Before
import '/services/notification_service.dart';
import '/components/notifications/notification_badge.dart';
import '/backend/schema/notifications_model.dart';

// After
import '/features/notifications/data/services/notification_service.dart';
import '/features/notifications/presentation/widgets/notification_badge.dart';
import '/features/notifications/domain/models/notification_model.dart';
```

## ✅ 검증 체크리스트

### 기능별 테스트

#### 1. 알림 수신
- [ ] 실시간 알림 수신
- [ ] 알림 다이얼로그 표시
- [ ] 알림 오버레이 표시
- [ ] 알림 뱃지 업데이트

#### 2. 알림 관리
- [ ] 알림 목록 조회
- [ ] 읽음/읽지 않음 처리
- [ ] 알림 삭제
- [ ] 알림 필터링

#### 3. 알림 타입별 처리
- [ ] 투표 알림 처리
- [ ] 향후: 채팅 알림
- [ ] 향후: 친구 요청 알림
- [ ] 향후: 시스템 알림

#### 4. FCM 통합 (향후)
- [ ] FCM 토큰 관리
- [ ] 푸시 알림 수신
- [ ] 백그라운드 알림 처리
- [ ] 알림 권한 관리

## 🎯 마이그레이션 체크리스트

### Phase별 완료 확인
- [ ] **Phase 0**: 브랜치 생성 및 디렉토리 구조 준비
- [ ] **Phase 1**: Services 이동 (2개 파일)
- [ ] **Phase 2**: Models 이동 (2개 파일)
- [ ] **Phase 3**: Screens 이동 (2개 파일)
- [ ] **Phase 4**: Widgets 이동 (10개+ 파일)
- [ ] **Phase 5**: Providers 이동 (2개 파일)
- [ ] **Phase 6**: Repository 구조 생성
- [ ] **Phase 7**: Import 경로 업데이트

### 기능 검증
- [ ] 알림 뱃지 표시 정상
- [ ] 알림 오버레이 표시 정상
- [ ] 알림 목록 화면 접근 가능
- [ ] 투표 알림 수신 정상
- [ ] 알림 읽음 처리 정상
- [ ] 알림 삭제 기능 정상

### 성능 검증
- [ ] 빌드 시간 증가 없음
- [ ] 런타임 에러 없음
- [ ] 메모리 사용량 정상

## ⚠️ 주의사항

### 1. Voting Feature와의 분리
- 투표 특화 UI는 Voting Feature에 유지
- 일반 알림 시스템만 Notifications Feature로 이동
- 상호 의존성 최소화

### 2. 확장성 고려
- 다양한 알림 타입 추가 가능한 구조
- FCM 통합을 위한 준비
- 플러그인 방식의 알림 타입 확장

### 3. 성능 최적화
- 알림 큐 관리
- 배치 처리
- 캐싱 전략

### 4. 사용자 경험
- 알림 우선순위 관리
- 중복 알림 방지
- 알림 그룹화

## 📊 예상 영향도

| 구분 | 영향도 | 파일 수 | 설명 |
|------|--------|---------|------|
| **Services** | 높음 | 3개 | 핵심 알림 로직 |
| **Models** | 높음 | 2개+ | 데이터 구조 |
| **Screens** | 중간 | 2개 | 알림 목록 화면 |
| **Widgets** | 높음 | 10개+ | UI 컴포넌트 |
| **Providers** | 높음 | 2개 | 상태 관리 |
| **총 영향** | **높음** | **20개+** | 핵심 기능 |

## 🔄 롤백 계획

```bash
# 문제 발생 시 롤백
git reset --hard HEAD~1
git checkout main

# 또는 백업 브랜치로 복귀
git checkout backup/before-notifications-migration
```

## 📅 예상 소요 시간

| Phase | 작업 내용 | 소요 시간 | 난이도 | 체크포인트 |
|-------|----------|----------|--------|------------|
| Phase 0: 준비 | 백업 및 브랜치 생성 | 10분 | ⭐ | 브랜치 생성 확인 |
| Phase 1: Services | 2개 서비스 이동 | 30분 | ⭐⭐ | Import 에러 없음 |
| Phase 2: Models | 2개 모델 이동 | 30분 | ⭐⭐ | 모델 컴파일 성공 |
| Phase 3: Screens | 2개 화면 이동 | 30분 | ⭐⭐ | 화면 라우팅 정상 |
| Phase 4: Widgets | 10개+ 위젯 이동 | 1시간 | ⭐⭐⭐ | UI 렌더링 정상 |
| Phase 5: Providers | 2개 Provider 이동 | 30분 | ⭐⭐ | 상태 관리 정상 |
| Phase 6: Repository | Repository 구조 생성 | 1시간 | ⭐⭐⭐ | UseCase 연결 확인 |
| Phase 7: 테스트 | Import 업데이트 및 검증 | 40분 | ⭐⭐ | 전체 빌드 성공 |
| **총 소요 시간** | **전체 마이그레이션** | **5-6시간** | ⭐⭐⭐ | 알림 기능 정상 작동 |

## 🔗 Core 마이그레이션 연관성

### Core 파일 의존성
Notifications Feature는 Core 마이그레이션 이후 다음 파일들에 의존합니다:

| Core 원본 | 새 위치 | 사용처 |
|----------|---------|--------|
| `/lib/core/app_utils.dart` | `/lib/features/common/presentation/utils/` | 유틸리티 함수 |
| `/lib/core/app_widgets.dart` | `/lib/features/common/presentation/widgets/` | 공통 위젯 |
| `/lib/core/app_theme.dart` | `/lib/app/theme/` | 테마 스타일 |
| `/lib/core/nav/nav.dart` | `/lib/app/router/` | 라우팅 |

### Import 경로 업데이트 필요
```dart
// Before (Core 사용)
import '/core/app_utils.dart';
import '/core/app_widgets.dart';

// After (Feature 기반)
import '/features/common/presentation/utils/app_utils.dart';
import '/features/common/presentation/widgets/app_widgets.dart';
```

## 🚀 다음 단계

1. **FCM 통합**
   - Firebase Cloud Messaging 설정
   - 푸시 알림 구현
   - 백그라운드 처리

2. **채팅 알림 구현**
   - 새 메시지 알림
   - 읽지 않은 메시지 카운트
   - 채팅방별 알림 설정

3. **알림 설정 화면**
   - 알림 타입별 on/off
   - 알림음 설정
   - 방해 금지 모드

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
   - 문제 발생 시 즉시 중단

3. **검증 단계**
   - Phase 7에서 전체 빌드 테스트
   - 기능 테스트 수행
   - 성능 모니터링

4. **완료 후**
   ```bash
   # PR 생성
   git push origin feature/notifications-migration
   # main 브랜치에 머지 요청
   ```

---

*이 문서는 Feature-First Architecture 마이그레이션의 Notifications Feature 통합 가이드입니다.*
*작성일: 2025-08-24*
*업데이트: Phase별 실행 계획 추가*