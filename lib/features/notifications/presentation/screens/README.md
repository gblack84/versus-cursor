# 📦 Notifications Presentation Screens Layer

> Feature-First Architecture - 알림 프레젠테이션 화면 레이어

## 📋 개요

알림 기능의 주요 화면들을 구현하는 스크린 레이어입니다. 각 화면은 독립적인 기능을 담당하며, Provider를 통해 상태를 관리합니다.

## 🏗️ 디렉토리 구조

```
presentation/screens/
├── notifications_list/                  # 알림 목록 화면
│   ├── notifications_list_widget.dart
│   ├── notifications_list_model.dart
│   └── components/
│       ├── notification_list_item.dart
│       ├── notification_filter_bar.dart
│       └── empty_notifications.dart
│
├── notification_detail/                 # 알림 상세 화면
│   ├── notification_detail_widget.dart
│   ├── notification_detail_model.dart
│   └── components/
│       ├── notification_actions.dart
│       └── notification_content.dart
│
└── notification_settings/               # 알림 설정 화면
    ├── notification_settings_widget.dart
    ├── notification_settings_model.dart
    └── components/
        ├── notification_type_settings.dart
        ├── do_not_disturb_settings.dart
        └── sound_vibration_settings.dart
```

## 🔑 주요 화면

### 1. NotificationsList - 알림 목록 화면

**역할**: 사용자의 모든 알림을 목록 형태로 표시하고 관리하는 메인 화면

**주요 기능**:
- 알림 목록 표시 (페이지네이션 지원)
- 필터링 기능 (타입, 우선순위, 읽음 상태 등)
- 읽음/읽지 않은 상태 관리
- 알림 삭제 기능
- Pull-to-refresh 지원
- 무한 스크롤 구현

**사용 Provider**:
- `NotificationProvider`: 알림 데이터 관리
- `NotificationBadgeProvider`: 뱃지 카운트 관리
- `NotificationFilterProvider`: 필터 상태 관리

**UI 구성**:
- AppBar: 제목, 설정 버튼, 모두 읽음 버튼
- FilterBar: 필터 옵션 표시
- ListView: 알림 목록 (separated)
- EmptyState: 알림이 없을 때 표시
- LoadingIndicator: 로딩 상태 표시

**Navigation**:
- `/notifications/settings`: 설정 화면으로 이동
- `/notifications/detail/{id}`: 상세 화면으로 이동

**Components**:
- `NotificationListItem`: 개별 알림 아이템
- `NotificationFilterBar`: 필터 바
- `EmptyNotifications`: 빈 상태 컴포넌트

### 2. NotificationDetail - 알림 상세 화면

**역할**: 개별 알림의 상세 내용을 표시하고 관련 액션을 제공하는 화면

**Props**:
- `notification`: NotificationModel (필수)

**UI 구성**:
- **Header Section**:
  - 알림 타입 배지 (색상 구분)
  - 알림 제목
  - 알림 메시지
  - 받은 시간 / 읽은 시간 표시

- **Content Section**:
  - 알림 타입별 상세 내용
  - 이미지/미디어 표시 (있을 경우)
  - 추가 데이터 표시

- **Action Section**:
  - 알림 타입별 액션 버튼
  - 외부 링크 연결
  - 관련 화면 이동

**Components**:
- `NotificationContent`: 알림 내용 표시 컴포넌트
- `NotificationActions`: 액션 버튼 컴포넌트

**타입별 색상 매핑**:
- 투표 관련: Blue
- 채팅: Green
- 친구: Purple
- 게시물: Orange
- 시스템: Grey
- 프로모션: Red
- 업적: Amber

### 3. NotificationSettings - 알림 설정 화면

**역할**: 사용자가 알림 관련 설정을 관리할 수 있는 화면

**사용 Provider**:
- `NotificationSettingsProvider`: 설정 상태 관리

**설정 섹션**:

1. **알림 유형 설정**:
   - 각 알림 타입별 on/off 토글
   - 투표, 채팅, 친구, 게시물 등 개별 설정

2. **사운드 및 진동 설정**:
   - 알림음 on/off
   - 진동 on/off
   - 사운드 선택 (향후)

3. **방해 금지 모드**:
   - 방해 금지 모드 활성화
   - 시작/종료 시간 설정
   - 예외 설정 (향후)

4. **전체 설정**:
   - 모든 알림 일괄 on/off
   - 설정 초기화 버튼

**Components**:
- `NotificationTypeSettings`: 타입별 설정 컴포넌트
- `SoundVibrationSettings`: 사운드/진동 설정 컴포넌트
- `DoNotDisturbSettings`: 방해 금지 설정 컴포넌트

**기능**:
- 설정 자동 저장 (SharedPreferences)
- 설정 초기화 확인 다이얼로그
- 실시간 설정 반영

## 🧪 테스트 전략

### Widget 테스트

**NotificationsList 테스트**:
- 알림 목록 표시 확인
- 필터 적용 동작 확인
- 페이지네이션 동작 확인
- Pull-to-refresh 동작 확인
- 빈 상태 표시 확인
- 에러 상태 처리 확인

**NotificationDetail 테스트**:
- 알림 상세 정보 표시
- 타입별 색상 표시
- 액션 버튼 표시/숨김
- 시간 정보 포맷팅

**NotificationSettings 테스트**:
- 설정 로드 및 저장
- 토글 스위치 동작
- 초기화 다이얼로그 표시
- 방해 금지 시간 설정

## ✅ 체크리스트

### 구현 완료
- [x] NotificationsList 화면
- [x] NotificationDetail 화면
- [x] NotificationSettings 화면
- [x] 관련 컴포넌트들

### 향후 구현
- [ ] NotificationHistory 화면 (알림 이력)
- [ ] NotificationStatistics 화면 (통계)
- [ ] NotificationPreview 화면 (미리보기)

## 📚 참고 자료

- [Flutter Navigation](https://flutter.dev/docs/development/ui/navigation)
- [GoRouter](https://pub.dev/packages/go_router)
- [Provider Pattern](https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple)

---

*이 문서는 Feature-First Architecture의 일부로 작성되었습니다.*
*최종 업데이트: 2025-08-24*