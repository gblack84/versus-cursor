# 👤 Profile Page - 사용자 프로필 페이지

> Versus Space 앱의 사용자 프로필 정보를 표시하고 관리하는 핵심 페이지입니다. 사용자의 개인 정보, 포인트 시스템, 활동 내역을 실시간으로 표시합니다.

## 📋 개요

Profile 페이지는 로그인된 사용자의 정보를 포괄적으로 표시하는 개인화된 페이지입니다. Firebase Auth와 Firestore를 활용하여 실시간으로 사용자 데이터를 동기화하며, 디자인 시스템을 완전히 적용하여 일관된 UI/UX를 제공합니다.

### 🎯 주요 목적
- **사용자 정보 표시**: 프로필 이미지, 이름, 이메일 등 기본 정보
- **포인트 시스템**: 답변 포인트(A)와 질문 포인트(Q) 표시
- **프로필 관리**: 설정 페이지 연결 및 로그아웃 기능
- **활동 정보**: 가입일, 전문분야, 관심사 등 상세 정보

## 🏗️ 디렉토리 구조

```
/lib/pages/profile/
├── profile_page_widget.dart    # 메인 프로필 페이지 위젯 (280줄)
└── README.md                    # 문서 파일
```

### 📊 코드 통계
- **총 코드 라인**: 280줄
- **파일 수**: 1개
- **주요 컴포넌트**: ProfilePageWidget
- **의존성**: 5개 (Flutter, Auth, Backend, Utils, Design System)

## 📐 네이밍 컨벤션

### 파일명
- **패턴**: snake_case (Dart 표준)
- **접미사**: `_widget`, `_page`
- **예시**: `profile_page_widget.dart`

### 클래스명
- **패턴**: PascalCase
- **접미사**: `Widget`, `State`
- **예시**: `ProfilePageWidget`, `_ProfilePageWidgetState`

### 라우팅
- **routeName**: camelCase with snake_case (`'profile_page'`)
- **routePath**: camelCase with slash (`'/profile'`)

### 변수 및 메서드
- **패턴**: camelCase
- **private**: 언더스코어 접두사 (`_`)
- **예시**: `currentUser`, `_buildPointInfo`, `_buildInfoRow`

> 참조: [프로젝트 전체 네이밍 컨벤션](../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소

### 1. ProfilePageWidget - 메인 프로필 페이지 👤

**사용자 프로필 정보를 표시하는 StatefulWidget입니다.**

#### 라우팅 정보
```dart
static String routeName = 'profile_page';
static String routePath = '/profile';
```

#### 주요 UI 구성
- **AppBar**: 제목 "프로필", 설정 아이콘 버튼
- **Body**: 조건부 렌더링 (로그인/비로그인)
- **SafeArea**: 안전 영역 보장

### 2. 로그인 상태 관리 시스템 🔐

**Firebase Auth를 통한 사용자 인증 상태 처리입니다.**

```dart
// 비로그인 상태
if (currentUser == null) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('로그인이 필요합니다'),
        VersusButton.primary(
          text: '로그인',
          onPressed: () => context.pushNamed('login_page'),
        ),
      ],
    ),
  );
}

// 로그인 상태
StreamBuilder<UsersModel>(
  stream: UsersModel.getDocument(currentUserReference!),
  builder: (context, snapshot) { ... }
)
```

#### 특징
- **실시간 동기화**: StreamBuilder로 사용자 정보 실시간 업데이트
- **조건부 렌더링**: 로그인 상태에 따른 적절한 UI 표시
- **에러 핸들링**: 데이터 로딩 중 CircularProgressIndicator 표시

### 3. 프로필 헤더 섹션 📊

**사용자의 핵심 정보를 표시하는 카드 컴포넌트입니다.**

```dart
Container(
  padding: VersusSpacing.paddingLG,
  decoration: BoxDecoration(
    color: VersusColors.backgroundSecondary,
    borderRadius: VersusRadius.radiusMedium,
    boxShadow: [...],
  ),
  child: Column(
    children: [
      CircleAvatar(...),        // 프로필 이미지
      Text(user.displayName),   // 사용자 이름
      Text(user.email),         // 이메일
      Row([...])                // 포인트 정보
    ],
  ),
)
```

#### 구성 요소
- **프로필 이미지**: 50px 반경의 CircleAvatar
- **기본 정보**: 이름, 이메일 표시
- **포인트 시스템**: A/Q 포인트 시각화

### 4. 포인트 시스템 💎

**사용자의 활동 포인트를 표시합니다.**

```dart
Widget _buildPointInfo(BuildContext context, String label, String value, Color color) {
  return Column(
    children: [
      Text(value, style: VersusTextStyles.headingLarge.copyWith(color: color)),
      Text(label, style: VersusTextStyles.bodySmall),
    ],
  );
}
```

#### 포인트 종류
- **답변 포인트 (pointsA)**: 빨간색 (`VersusColors.primary`)
  - 다른 사용자 질문에 답변 시 획득
  - 투표 참여 시 획득
- **질문 포인트 (pointsQ)**: 초록색 (`VersusColors.secondary`)
  - 질문 작성 시 획득
  - 콘텐츠 생성 시 획득

### 5. 상세 프로필 정보 섹션 📝

**사용자의 추가 정보를 표시합니다.**

```dart
Container(
  child: Column(
    children: [
      Text('프로필 정보'),
      if (user.gender.isNotEmpty) _buildInfoRow('성별', user.gender),
      if (user.createdTime != null) _buildInfoRow('가입일', ...),
      if (user.expertise.isNotEmpty) _buildInfoRow('전문분야', ...),
      if (user.interests.isNotEmpty) _buildInfoRow('관심사', ...),
    ],
  ),
)
```

#### 표시 정보
- **성별**: 사용자 설정 성별
- **가입일**: `yMMMd` 형식 (예: 2025년 8월 23일)
- **전문분야**: 최대 4개 전문 분야 (쉼표 구분)
- **관심사**: 최대 8개 관심사 (쉼표 구분)

### 6. 헬퍼 메서드 🛠️

**UI 구성을 위한 재사용 가능한 메서드입니다.**

#### _buildInfoRow
```dart
Widget _buildInfoRow(BuildContext context, String label, String value) {
  return Padding(
    padding: EdgeInsets.only(bottom: VersusSpacing.sm),
    child: Row(
      children: [
        SizedBox(width: 80, child: Text(label)),  // 고정 너비 레이블
        Expanded(child: Text(value)),             // 유동 너비 값
      ],
    ),
  );
}
```

### 7. 로그아웃 기능 🚪

**Firebase Auth 로그아웃 처리입니다.**

```dart
VersusButton.error(
  text: '로그아웃',
  isFullWidth: true,
  size: VersusButtonSize.large,
  onPressed: () async {
    await authManager.signOut();
    context.goNamed('startPage');
  },
)
```

#### 처리 과정
1. `authManager.signOut()` 호출
2. Firebase Auth 세션 종료
3. `startPage`로 네비게이션
4. 앱 초기 화면으로 이동

## 💡 사용 가이드

### 페이지 진입
```dart
// 바텀 네비게이션에서
context.pushNamed('profile_page');

// 또는 직접 경로
context.go('/profile');
```

### 설정 페이지 이동
```dart
// AppBar 설정 아이콘 클릭 시
IconButton(
  icon: Icon(Icons.settings),
  onPressed: () => context.pushNamed('user_info_input'),
)
```

### 로그인 페이지 이동
```dart
// 비로그인 상태에서
VersusButton.primary(
  text: '로그인',
  onPressed: () => context.pushNamed('login_page'),
)
```

## 🎨 디자인 시스템

### 색상 팔레트
- **배경**: `VersusColors.backgroundPrimary` (메인 배경)
- **카드 배경**: `VersusColors.backgroundSecondary` (섹션 배경)
- **포인트 A**: `VersusColors.primary` (빨간색)
- **포인트 Q**: `VersusColors.secondary` (초록색)
- **텍스트 보조**: `VersusColors.textSecondary` (회색)
- **그림자**: `VersusColors.blackWithAlpha(0.05)` (연한 그림자)

### 간격 시스템
- **전체 패딩**: `VersusSpacing.paddingMD` (16px)
- **카드 패딩**: `VersusSpacing.paddingLG` (20px)
- **섹션 간격**: `VersusSpacing.gapLG` (20px)
- **요소 간격**: `VersusSpacing.gapMD` (12px)
- **최소 간격**: `VersusSpacing.gapXS` (4px)

### 타이포그래피
- **페이지 제목**: `VersusTextStyles.headingSmall`
- **포인트 숫자**: `VersusTextStyles.headingLarge`
- **섹션 제목**: `VersusTextStyles.headingMedium`
- **본문**: `VersusTextStyles.bodyMedium`
- **레이블**: `VersusTextStyles.bodySmall`

### 컴포넌트
- **로그인 버튼**: `VersusButton.primary`
- **로그아웃 버튼**: `VersusButton.error`
- **버튼 크기**: `VersusButtonSize.large`
- **테두리 반경**: `VersusRadius.radiusMedium`

## 🚀 성능 최적화

### StreamBuilder 최적화
- 사용자 문서 단일 스트림 구독
- 데이터 변경 시에만 리빌드
- 로딩 상태 명확한 표시

### 조건부 렌더링
- 빈 데이터 필드 자동 숨김
- 불필요한 위젯 생성 방지
- 효율적인 레이아웃 구성

### 메모리 관리
- StatefulWidget dispose 처리
- 스트림 자동 정리
- 이미지 캐싱 활용

## 📚 의존성

```dart
import 'package:flutter/material.dart';
import '/core/app_utils.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/design_system/design_system.dart';
```

### 핵심 의존성
- **Flutter Material**: UI 프레임워크
- **Firebase Auth**: 사용자 인증
- **Firestore**: 데이터베이스
- **Design System**: UI 컴포넌트
- **App Utils**: 유틸리티 함수

## 🔧 개선 사항 (TODO)

### 우선순위 높음
1. **프로필 편집**: 인라인 편집 기능 추가
2. **이미지 업로드**: 프로필 사진 변경 기능
3. **활동 내역**: 최근 활동 타임라인 표시

### 우선순위 중간
4. **통계 대시보드**: 활동 통계 시각화
5. **뱃지 시스템**: 업적 뱃지 표시
6. **팔로우 기능**: 친구 관계 표시

### 우선순위 낮음
7. **테마 설정**: 다크모드 지원
8. **프로필 공유**: 소셜 미디어 공유
9. **백업/복원**: 프로필 데이터 백업

## 🐛 알려진 이슈

### 현재 이슈
1. **이미지 로딩**: 프로필 이미지 로딩 시 깜빡임
   - CachedNetworkImage 적용 필요
   - placeholder 이미지 추가 필요

2. **긴 텍스트 처리**: 관심사/전문분야 텍스트 오버플로우
   - TextOverflow.ellipsis 적용 필요
   - 툴팁으로 전체 텍스트 표시

### 해결 방법
- 이미지 캐싱 라이브러리 도입
- 텍스트 줄바꿈 및 말줄임 처리
- 반응형 레이아웃 개선

## 📅 변경 이력

| 날짜 | 버전 | 변경 내용 | 작업자 |
|------|------|----------|--------|
| 2025-08-23 | v1.0.0 | README 문서 작성 완료 | AI Assistant |
| 2025-07-25 | v0.2.0 | 디자인 시스템 적용 | 개발팀 |
| 2025-07-25 | v0.1.0 | 초기 페이지 생성 | 개발팀 |

## 🔗 관련 문서

- [전체 Pages 구조](../../README.md)
- [디자인 시스템](../../design_system/README.md)
- [Firebase Auth 가이드](../../auth/README.md)
- [Backend 스키마](../../backend/schema/README.md)
- [네이밍 컨벤션](../../NAMING_CONVENTION.md)
- [사용자 정보 입력](../user_info_input/README.md)

---

*이 문서는 Versus Space 앱의 프로필 페이지 구현을 상세히 설명합니다.*
*최종 업데이트: 2025-08-23*