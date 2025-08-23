# 🔔 Notifications List - 알림 목록 페이지

> Versus Space 앱의 알림 목록을 표시하고 관리하는 페이지입니다. 사용자가 받은 모든 알림을 시간순으로 표시하며, 읽음 상태 관리 및 만료 처리를 지원합니다.

## 📋 개요

Notifications List는 사용자가 받은 모든 알림을 중앙 집중식으로 관리하는 페이지입니다. 투표 요청, 시스템 알림 등 다양한 유형의 알림을 표시하고, 읽음 상태를 실시간으로 업데이트합니다.

### 🎯 주요 목적
- **알림 표시**: 모든 알림을 시간순으로 정렬하여 표시
- **상태 관리**: 읽음/읽지 않음 상태 실시간 업데이트
- **만료 처리**: 만료된 알림 자동 비활성화
- **직관적 UI**: 알림 유형별 아이콘 및 색상 구분

## 🏗️ 디렉토리 구조

```
/lib/pages/notifications_list/
├── notifications_list_widget.dart    # 메인 알림 목록 위젯 (206줄)
├── navigation_example.dart          # 네비게이션 예제 코드 (50줄)
└── README.md                        # 문서 파일
```

### 📊 코드 통계
- **총 코드 라인**: 256줄
- **파일 수**: 2개
- **주요 컴포넌트**: NotificationsListWidget
- **의존성**: 6개 (Firebase Auth, Firestore, AppTheme 등)

## 📐 네이밍 컨벤션

### 파일명
- **패턴**: snake_case (Dart 표준)
- **접미사**: `_widget`, `_example`
- **예시**: `notifications_list_widget.dart`

### 클래스명
- **패턴**: PascalCase
- **접미사**: `Widget`
- **예시**: `NotificationsListWidget`

### 라우팅
- **routeName**: snake_case (`'notificationsList'`)
- **routePath**: camelCase with slash (`'/notifications'`)

### 변수 및 메서드
- **패턴**: camelCase
- **예시**: `scaffoldKey`, `isExpired`

> 참조: [프로젝트 전체 네이밍 컨벤션](../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소

### 1. NotificationsListWidget - 메인 알림 목록 위젯 📱

**사용자의 모든 알림을 표시하는 StatefulWidget입니다.**

#### 라우팅 정보
```dart
static String routeName = 'notificationsList';
static String routePath = '/notifications';
```

#### 주요 UI 구성
- **AppBar**: "알림" 타이틀 중앙 정렬
- **StreamBuilder**: 실시간 알림 데이터 감시
- **ListView**: 알림 목록 표시
- **Empty State**: 알림 없을 때 안내 UI
- **Loading State**: 데이터 로딩 중 표시

### 2. 알림 데이터 스트림 🔄

**Firestore에서 실시간으로 알림 데이터를 가져옵니다.**

```dart
StreamBuilder<List<NotificationsModel>>(
  stream: queryNotificationsModel(
    queryBuilder: (notificationsRecord) => notificationsRecord
        .where('userId', isEqualTo: currentUserUid)
        .orderBy('createdAt', descending: true),
  ),
)
```

#### 쿼리 특징
- **필터링**: 현재 사용자의 알림만 표시
- **정렬**: 최신 알림 우선 (createdAt DESC)
- **실시간**: StreamBuilder로 자동 업데이트

### 3. 알림 아이템 UI 🎨

**각 알림 항목의 표시 구성입니다.**

#### UI 구성요소
```dart
Container(
  padding: EdgeInsets.all(16.0),
  decoration: BoxDecoration(
    color: notification.read 
        ? Colors.transparent 
        : AppTheme.accent1.withValues(alpha: 0.1),  // 읽지 않은 알림 배경색
    border: Border(bottom: BorderSide(...)),
  ),
  child: Row([
    // 알림 아이콘 (투표 아이콘)
    Container(
      width: 48.0,
      height: 48.0,
      decoration: BoxDecoration(
        color: AppTheme.accent1,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.how_to_vote),
    ),
    // 알림 내용
    Expanded(
      child: Column([
        Text('투표 요청' or '알림'),
        Text('이 게시물에 대한 당신의 의견이 필요해요!'),
        Text('MM월 dd일 HH:mm'),
      ]),
    ),
    // 읽지 않음 표시 (빨간 점)
    if (!notification.read && !isExpired)
      Container(
        width: 8.0,
        height: 8.0,
        decoration: BoxDecoration(
          color: AppTheme.error,
          shape: BoxShape.circle,
        ),
      ),
  ])
)
```

### 4. 읽음 상태 관리 ✅

**알림 클릭 시 읽음 처리 로직입니다.**

```dart
onTap: isExpired ? null : () async {
  // 읽음 처리
  if (!notification.read) {
    await notification.reference.update({
      'read': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }
}
```

#### 상태 변경
- **read**: false → true로 업데이트
- **readAt**: 서버 타임스탬프 추가
- **UI 반영**: StreamBuilder로 즉시 반영

### 5. 만료 알림 처리 ⏱️

**만료된 알림의 비활성화 처리입니다.**

```dart
final isExpired = notification.expiryTime != null &&
    notification.expiryTime!.isBefore(DateTime.now());

// 만료된 알림은 투명도 적용
Opacity(
  opacity: notification.read || isExpired ? 0.6 : 1.0,
  child: InkWell(
    onTap: isExpired ? null : () async { ... },  // 만료 시 클릭 비활성화
  ),
)
```

### 6. NavigationExample - 네비게이션 헬퍼 🧭

**알림 목록으로의 네비게이션 예제 코드입니다.**

```dart
class NavigationExample {
  // 단순 네비게이션 (현재 라우트 대체)
  static void navigateToNotificationsList(BuildContext context) {
    context.goNamed(NotificationsListWidget.routeName);
  }
  
  // 스택에 추가 (뒤로가기 가능)
  static void pushNotificationsList(BuildContext context) {
    context.pushNamed(NotificationsListWidget.routeName);
  }
  
  // 인증 체크와 함께 네비게이션
  static void pushWithAuth(BuildContext context, bool mounted) {
    context.pushNamedAuth(
      NotificationsListWidget.routeName,
      mounted,
    );
  }
}
```

## 💡 사용 가이드

### 페이지 진입
```dart
// 앱 내 어디서든 알림 목록으로 이동
context.pushNamed(NotificationsListWidget.routeName);

// 인증 체크와 함께 이동
context.pushNamedAuth(
  NotificationsListWidget.routeName,
  mounted,
);
```

### 알림 아이콘 버튼 예제
```dart
IconButton(
  icon: Icon(Icons.notifications),
  onPressed: () {
    context.pushNamed(NotificationsListWidget.routeName);
  },
)
```

## 🎨 디자인 시스템

### 색상 스킴
| 요소 | 색상 | 용도 |
|------|------|------|
| **배경** | primaryBackground | 메인 배경 |
| **읽지 않은 알림** | accent1 (10% alpha) | 읽지 않은 알림 배경 |
| **알림 아이콘 배경** | accent1 | 원형 아이콘 배경 |
| **읽지 않음 표시** | error | 빨간 점 표시 |
| **테두리** | alternate | 알림 항목 구분선 |

### 텍스트 스타일
- **알림 유형**: bodyLarge (FontWeight.w600)
- **알림 내용**: bodyMedium (secondaryText)
- **시간 표시**: bodySmall (secondaryText)
- **빈 상태 텍스트**: titleLarge (secondaryText)

### 간격 및 크기
| 요소 | 값 | 설명 |
|------|-----|------|
| **아이템 패딩** | 16px | 각 알림 항목 내부 패딩 |
| **아이콘 크기** | 48x48px | 알림 타입 아이콘 |
| **읽지 않음 점** | 8x8px | 읽지 않음 표시 |
| **아이콘 간격** | 12px | 아이콘과 텍스트 사이 |

## 🚀 성능 최적화

### StreamBuilder 활용
- 실시간 데이터 업데이트
- 자동 구독 관리
- 메모리 효율적인 스트림 처리

### 조건부 렌더링
- 읽음 상태에 따른 UI 차별화
- 만료 알림 비활성화
- 빈 상태 별도 처리

### 서버 타임스탬프
- FieldValue.serverTimestamp() 사용
- 클라이언트 시간 차이 문제 방지
- 일관된 시간 기록

## 📚 의존성

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // 날짜 포맷팅
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/core/app_theme.dart';
import '/core/app_utils.dart';
```

## 🔧 개선 사항 (TODO)

### 우선순위 높음
1. **알림 클릭 액션**: 관련 게시물로 이동 구현 필요
   - 현재 SnackBar만 표시 (line 115-120)
   - sourceId를 활용한 네비게이션 필요
2. **알림 타입 확장**: votingRequest 외 다른 타입 지원
3. **일괄 읽음 처리**: 모든 알림 읽음 처리 버튼 추가

### 우선순위 중간
4. **알림 필터링**: 읽음/읽지 않음 필터
5. **알림 그룹화**: 날짜별 그룹화
6. **삭제 기능**: 스와이프하여 삭제

### 우선순위 낮음
7. **애니메이션**: 알림 항목 추가/제거 애니메이션
8. **풀 투 리프레시**: 당겨서 새로고침
9. **페이지네이션**: 대량 알림 처리

## 🐛 알려진 이슈

### 현재 이슈
1. **알림 클릭 미구현**: 알림 클릭 시 관련 게시물로 이동 미구현
   - SnackBar로 임시 처리 중
   - sourceId와 type을 활용한 라우팅 필요

2. **알림 내용 하드코딩**: "이 게시물에 대한 당신의 의견이 필요해요!" 고정
   - NotificationsModel의 message 필드 활용 필요
   - 알림 타입별 다른 메시지 표시 필요

### 해결 방법
- PostsModel과 연결하여 게시물 상세로 이동
- 알림 타입별 라우팅 로직 구현
- 다국어 지원을 위한 메시지 리소스화

## 📅 변경 이력

| 날짜 | 버전 | 변경 내용 | 작업자 |
|------|------|----------|--------|
| 2025-08-23 | v1.0.0 | README 문서 작성 완료 | AI Assistant |
| 2025-08-22 | v0.1.0 | 초기 페이지 생성 | 개발팀 |

## 🔗 관련 문서

- [전체 Pages 구조](../../README.md)
- [NotificationsModel](../../../backend/schema/notifications_model.dart)
- [Firebase Auth 가이드](../../../auth/README.md)
- [Core 유틸리티](../../../core/README.md)
- [GoRouter 네비게이션](../../../core/nav/nav.dart)

---

*이 문서는 Versus Space 앱의 알림 목록 페이지 구현을 상세히 설명합니다.*
*최종 업데이트: 2025-08-23*