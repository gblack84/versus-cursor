# Profile Page Widget

## 개요

프로필 페이지는 사용자의 개인 정보, 포인트, 활동 내역을 표시하는 페이지입니다. 로그인된 사용자의 정보를 실시간으로 표시하며, 로그아웃 기능을 제공합니다.

## 주요 기능

### 1. 사용자 정보 표시
- **프로필 이미지**: CircleAvatar (50px radius)
- **기본 정보**: 이름, 이메일
- **포인트 시스템**:
  - 답변 포인트 (points_A): 다른 사용자의 질문에 답변할 때 획득
  - 질문 포인트 (points_Q): 질문을 작성할 때 획득

### 2. 상세 프로필 정보
- **성별**: 사용자가 설정한 성별
- **가입일**: 계정 생성 날짜 (yMMMd 형식)
- **전문분야**: 최대 4개까지 선택한 전문 분야
- **관심사**: 최대 8개까지 선택한 관심사

### 3. 액션 기능
- **설정 버튼**: 앱바 우측의 설정 아이콘 (user_info_input 페이지로 이동)
- **로그아웃 버튼**: 하단의 빨간색 버튼으로 로그아웃 처리

## 디자인 시스템 적용

### 색상
- **배경**: `VersusColors.backgroundPrimary`
- **카드 배경**: `VersusColors.backgroundSecondary`
- **포인트 색상**: 
  - 답변 포인트: `VersusColors.primary` (빨간색)
  - 질문 포인트: `VersusColors.secondary` (초록색)

### 컴포넌트
- **로그아웃 버튼**: `VersusButton.error` 컴포넌트 사용
  - 전체 너비 (isFullWidth: true)
  - 큰 사이즈 (VersusButtonSize.large)

### 간격
- **전체 패딩**: `VersusSpacing.paddingMD` (16px)
- **카드 내부 패딩**: `VersusSpacing.paddingLG` (20px)
- **섹션 간격**: `VersusSpacing.gapLG` (20px)

### 텍스트 스타일
- **이름**: `VersusTextStyles.headingSmall`
- **포인트 수치**: `VersusTextStyles.headingLarge`
- **레이블**: `VersusTextStyles.bodySmall`
- **정보 텍스트**: `VersusTextStyles.bodyMedium`

## 기술 구현

### Firebase Auth 연동
```dart
StreamBuilder<UsersRecord>(
  stream: UsersRecord.getDocument(currentUserReference!),
  builder: (context, snapshot) { ... }
)
```

### 로그인 상태 처리
- 로그인하지 않은 경우: 로그인 유도 메시지와 버튼 표시
- 로그인한 경우: 사용자 정보 스트림으로 실시간 업데이트

### 로그아웃 처리
```dart
await authManager.signOut();
context.goNamed('start_page');
```

## 헬퍼 메서드

### _buildPointInfo
포인트 정보를 표시하는 위젯 생성
- 큰 숫자와 작은 레이블로 구성
- 색상 커스터마이징 가능

### _buildInfoRow
프로필 정보를 레이블-값 형태로 표시
- 80px 고정 너비의 레이블
- 나머지 공간을 차지하는 값

## 파일 위치
- Widget: `/lib/pages/profile/profile_page_widget.dart`

## 라우팅
- Route Name: `profile_page`
- Route Path: `/profile`

## 업데이트 이력
- 2025-07-25: 디자인 시스템 적용 완료
- 2025-07-25: VersusButton 컴포넌트로 로그아웃 버튼 교체