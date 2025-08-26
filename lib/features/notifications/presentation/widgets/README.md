# 📦 Notifications Presentation Widgets Layer

> Feature-First Architecture - 알림 프레젠테이션 위젯 레이어

## 📋 개요

알림 기능의 재사용 가능한 UI 컴포넌트들을 구현하는 위젯 레이어입니다. 각 위젯은 독립적으로 동작하며, 다양한 화면에서 재사용됩니다.

## 🏗️ 디렉토리 구조

```
presentation/widgets/
├── notification_badge.dart              # 알림 뱃지
├── notification_overlay.dart            # 알림 오버레이
├── notification_dialog.dart             # 알림 다이얼로그
├── notification_list_item.dart          # 목록 아이템
├── notification_image_viewer.dart       # 이미지 뷰어
├── notification_empty_state.dart        # 빈 상태 표시
├── notification_type_icon.dart          # 타입별 아이콘
├── notification_filter_chip.dart        # 필터 칩
├── notification_time_display.dart       # 시간 표시
└── notification_action_button.dart      # 액션 버튼
```

## 🔑 주요 위젯

### 1. NotificationBadge - 알림 뱃지

**역할**: 알림 개수를 시각적으로 표시하는 뱃지 위젯

**Props**:
- `child`: 뱃지를 부착할 위젯 (필수)
- `badgeColor`: 뱃지 배경색 (기본값: Red)
- `textColor`: 텍스트 색상 (기본값: White)
- `size`: 뱃지 크기 (기본값: 20)
- `padding`: 내부 패딩
- `showZero`: 0일 때도 표시 여부 (기본값: false)

**기능**:
- NotificationBadgeProvider와 연동하여 자동 업데이트
- 자식 위젯에 Stack으로 뱃지 오버레이
- 99 초과 시 "99+" 표시
- AnimatedContainer로 부드러운 나타남/사라짐

### 2. NotificationOverlay - 알림 오버레이

**역할**: 화면 상단에 일시적으로 표시되는 알림 오버레이

**Props**:
- `notification`: NotificationModel (필수)
- `onTap`: 탭 시 콜백
- `onDismiss`: 닫기 시 콜백
- `displayDuration`: 표시 시간 (기본값: 5초)
- `autoDismiss`: 자동 닫기 여부 (기본값: true)

**기능**:
- Overlay API를 사용한 화면 위 표시
- SlideTransition + FadeTransition 애니메이션
- 자동 dismiss Timer 관리
- 상단 safe area 고려
- 탭/닫기 액션 처리

**Static Method**:
- `show()`: Context에 오버레이 표시

### 3. NotificationDialog - 알림 다이얼로그

**역할**: 모달 형태로 표시되는 알림 다이얼로그

**Props**:
- `notification`: NotificationModel (필수)
- `onAccept`: 수락 버튼 콜백
- `onDecline`: 거절 버튼 콜백
- `onDismiss`: 닫기 버튼 콜백

**UI 구성**:
- **Header**: 타입 아이콘, 제목, 타입명, 닫기 버튼
- **Content**: 메시지, 이미지, 투표 컨텐츠 등
- **Actions**: 수락/거절 버튼

**기능**:
- showDialog API 사용
- barrierDismissible: false (배경 터치 방지)
- VoteNotification 특별 처리
- 92% 화면 너비 사용
- 최대 너비 500px 제한

**Static Method**:
- `show()`: Context에 다이얼로그 표시

### 4. NotificationListItem - 목록 아이템

**역할**: 알림 목록에 표시되는 개별 알림 아이템

**Props**:
- `notification`: NotificationModel (필수)
- `onTap`: 탭 시 콜백
- `onDelete`: 삭제 시 콜백
- `showActions`: 액션 표시 여부 (기본값: true)

**UI 구성**:
- **왼쪽**: NotificationTypeIcon
- **중앙**: 제목, 메시지, 우선순위 배지
- **오른쪽**: 시간 표시, 읽지 않음 점

**기능**:
- Dismissible로 스와이프 삭제
- 읽음/읽지 않음 시각적 구분
- timeago로 상대 시간 표시
- 우선순위별 배지 표시
- InkWell로 터치 효과

### 5. NotificationTypeIcon - 타입별 아이콘

**역할**: 알림 타입에 따른 아이콘과 색상을 표시하는 위젯

**Props**:
- `type`: NotificationType (필수)
- `size`: 아이콘 크기 (기본값: 24)
- `color`: 커스텀 색상 (optional)

**아이콘 매핑**:
- 투표 요청: how_to_vote
- 투표 결과: poll
- 채팅 메시지: chat_bubble
- 친구 요청: person_add
- 친구 수락: person
- 좋아요: thumb_up
- 댓글: comment
- 시스템 업데이트: system_update
- 프로모션: local_offer
- 업적: emoji_events

**색상 매핑**:
- 투표: Blue
- 채팅: Green
- 친구: Purple
- 게시물: Orange
- 시스템: Grey
- 프로모션: Red
- 업적: Amber

**기능**:
- 원형 배경에 아이콘 표시
- 배경색 20% 투명도
- 아이콘 크기는 컨테이너의 60%

## 🧪 테스트 전략

### Widget 테스트

**NotificationBadge 테스트**:
- 카운트 표시 확인
- 99+ 포맷팅 확인
- showZero 옵션 테스트
- 애니메이션 동작 확인

**NotificationOverlay 테스트**:
- 오버레이 표시/숨김
- 자동 dismiss 타이머
- 탭/닫기 액션
- 애니메이션 동작

**NotificationDialog 테스트**:
- 다이얼로그 표시
- 액션 버튼 동작
- VoteNotification 특별 처리
- 닫기 방지 확인

**NotificationListItem 테스트**:
- 읽음/읽지 않음 표시
- 스와이프 삭제
- 우선순위 배지
- 시간 포맷팅

**NotificationTypeIcon 테스트**:
- 타입별 아이콘 매핑
- 색상 표시 확인
- 크기 조절 테스트

## ✅ 체크리스트

### 구현 완료
- [x] NotificationBadge
- [x] NotificationOverlay
- [x] NotificationDialog
- [x] NotificationListItem
- [x] NotificationTypeIcon

### 향후 구현
- [ ] NotificationImageViewer
- [ ] NotificationEmptyState
- [ ] NotificationFilterChip
- [ ] NotificationTimeDisplay
- [ ] NotificationActionButton

## 📚 참고 자료

- [Flutter Widgets](https://flutter.dev/docs/development/ui/widgets)
- [Material Design](https://material.io/design)
- [Flutter Animation](https://flutter.dev/docs/development/ui/animations)

---

*이 문서는 Feature-First Architecture의 일부로 작성되었습니다.*
*최종 업데이트: 2025-08-24*