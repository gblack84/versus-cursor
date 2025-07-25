# Home Page Widget

## 개요

홈 페이지는 Versus Space 앱의 메인 피드 화면으로, 사용자들이 작성한 A vs B 형식의 투표 게시물들을 볼 수 있는 중심 페이지입니다.

## 주요 기능

### 1. 실시간 피드
- Firebase Firestore의 실시간 스트림을 통해 최신 게시물 표시
- 최근 작성 순으로 정렬 (createdAt descending)
- 최대 20개 게시물 표시 (성능 최적화)

### 2. 게시물 카드 디자인
- **사용자 정보**: 프로필 사진, 이름, 작성 시간
- **질문 제목**: 최대 2줄까지 표시
- **A vs B 옵션**: 시각적으로 구분된 선택지
  - A 옵션: 빨간색 테마 (VersusColors.primary)
  - B 옵션: 초록색 테마 (VersusColors.secondary)
- **상호작용 정보**: 투표 참여자 수, 댓글 수, 좋아요 수

### 3. 알림 배지
- NotificationBadgeProvider를 통한 읽지 않은 알림 표시
- 앱바 우측에 알림 아이콘과 배지

## 디자인 시스템 적용

### 색상
- **배경**: `VersusColors.backgroundPrimary` (베이지색)
- **카드 배경**: `VersusColors.backgroundSecondary` (연한 베이지)
- **텍스트**: `VersusColors.textPrimary`, `VersusColors.textSecondary`

### 간격
- **카드 패딩**: `VersusSpacing.paddingMD` (16px)
- **카드 간격**: `VersusSpacing.sm` (8px)
- **내부 간격**: `VersusSpacing.gapMD`, `VersusSpacing.gapSM`

### 텍스트 스타일
- **제목**: `VersusTextStyles.headingMedium`
- **본문**: `VersusTextStyles.bodyMedium`
- **레이블**: `VersusTextStyles.bodySmall`

### Border Radius
- **카드**: `VersusRadius.radiusMedium` (16px)
- **옵션 박스**: `VersusRadius.radiusSmall` (8px)

## 기술 구현

### Firebase 연동
```dart
StreamBuilder<List<PostsRecord>>(
  stream: FirebaseFirestore.instance
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .limit(20)
      .snapshots()
      .map((snapshot) => 
          snapshot.docs.map((doc) => PostsRecord.fromSnapshot(doc)).toList()),
  builder: (context, snapshot) { ... }
)
```

### 빈 상태 처리
게시물이 없을 때 친근한 메시지와 함께 첫 질문 작성을 유도하는 UI 표시

### 성능 최적화
- 스트림 빌더를 통한 효율적인 데이터 업데이트
- 제한된 수의 게시물만 로드 (limit: 20)
- 이미지 캐싱 (NetworkImage 사용)

## 향후 개선 사항

1. **무한 스크롤**: 페이지네이션 구현
2. **필터링**: 카테고리별, 인기순 정렬
3. **검색**: 게시물 검색 기능
4. **풀 투 리프레시**: 수동 새로고침

## 파일 위치
- Widget: `/lib/pages/home/home_page_widget.dart`
- Model: `/lib/pages/home/home_page_model.dart`

## 라우팅
- Route Name: `home_page`
- Route Path: `/home`

## 업데이트 이력
- 2025-07-25: 디자인 시스템 적용 완료
- 2025-07-25: Firebase Firestore 실시간 피드 구현