# 📦 Posts Presentation Screens

> Posts Feature의 화면 컴포넌트 - UI 및 사용자 인터랙션 레이어

## 📋 개요

이 디렉토리는 Posts Feature의 주요 화면들을 포함합니다. 각 화면은 독립적인 디렉토리로 구성되며, 화면별 위젯과 컨트롤러를 포함합니다.

### 🎯 목적
- **화면 구성**: 사용자가 상호작용하는 주요 화면 관리
- **사용자 경험**: 직관적이고 반응적인 UI 제공
- **네비게이션**: 화면 간 원활한 전환
- **상태 연결**: Provider와 화면 컴포넌트 연결

## 🏗️ 디렉토리 구조

```
presentation/screens/
├── create_post/                 # 게시물 작성 화면
│   ├── create_post_screen.dart
│   ├── create_post_controller.dart
│   └── steps/
│       ├── media_selection/
│       ├── content_input/
│       └── target_audience/
├── feed/                        # 피드 화면
│   ├── feed_screen.dart
│   ├── feed_controller.dart
│   └── components/
│       ├── post_card.dart
│       └── feed_shimmer.dart
├── post_detail/                 # 게시물 상세 화면
│   ├── post_detail_screen.dart
│   ├── post_detail_controller.dart
│   └── components/
│       ├── vote_section.dart
│       └── comment_section.dart
├── editor/                      # 에디터 화면들
│   ├── image_editor_screen.dart
│   ├── video_editor_screen.dart
│   └── components/
└── thumbnail/                   # 썸네일 선택 화면
    ├── thumbnail_selection_screen.dart
    └── thumbnail_selection_controller.dart
```

## 📝 주요 화면 사양

### 1. CreatePostScreen

**책임**: 새로운 게시물 작성 워크플로우 관리

**주요 기능**:
- 4단계 작성 프로세스 (내용 → 미디어 → 타겟 → 미리보기)
- 진행률 표시 및 단계별 유효성 검사
- 미디어 선택 및 편집 통합
- AI 콘텐츠 검열 피드백
- 임시저장 기능

**화면 구성**:
- Step 1: 콘텐츠 입력 (질문, 설명, A/B 옵션)
- Step 2: 미디어 선택 (이미지, 비디오, YouTube)
- Step 3: 타겟 오디언스 설정
- Step 4: 최종 미리보기 및 게시

**상태 관리**: CreatePostProvider와 연동

### 2. FeedScreen

**책임**: 게시물 피드 표시 및 상호작용

**주요 기능**:
- 무한 스크롤 페이지네이션
- 실시간 피드 업데이트
- 필터링 옵션 (전체, 인기, 최신, 투표중, 완료)
- Pull-to-refresh 지원
- 투표 인터랙션

**컴포넌트**:
- PostCard: 개별 게시물 카드
- FeedShimmer: 로딩 스켈레톤
- FilterChips: 필터 선택 UI
- EmptyState: 빈 상태 표시

**상태 관리**: FeedProvider와 연동

### 3. PostDetailScreen

**책임**: 게시물 상세 정보 표시

**주요 기능**:
- 전체 콘텐츠 표시
- 실시간 투표 현황
- 댓글 시스템
- 좋아요/공유 기능
- 작성자 정보 표시

**섹션 구성**:
- 헤더: 작성자 정보, 작성 시간
- 콘텐츠: 질문, 설명, A/B 옵션
- 투표: 실시간 투표 현황 및 타이머
- 상호작용: 좋아요, 댓글, 공유
- 댓글: 댓글 목록 및 작성

**상태 관리**: PostProvider와 연동

### 4. ImageEditorScreen

**책임**: 이미지 편집 기능 제공

**주요 기능**:
- ProImageEditor 통합
- 필터, 텍스트, 스티커 추가
- 크롭 및 회전
- 그리기 도구
- 편집 이력 관리

**편집 옵션**:
- 기본 편집: 크롭, 회전, 플립
- 필터: 다양한 이미지 필터
- 텍스트: 텍스트 오버레이
- 그리기: 펜, 도형 도구
- 스티커: 이모지 및 스티커

### 5. VideoEditorScreen

**책임**: 비디오 편집 기능 제공

**주요 기능**:
- 비디오 트리밍
- 썸네일 선택
- 시작/종료 시간 설정
- 미리보기 재생
- 압축 설정

**편집 옵션**:
- 트리밍: 시작/종료 지점 설정
- 썸네일: 대표 이미지 선택
- 품질: 압축 레벨 선택
- 미리보기: 편집 결과 확인

### 6. ThumbnailSelectionScreen

**책임**: 멀티 이미지 중 대표 이미지 선택

**주요 기능**:
- 그리드 뷰 표시
- 드래그 앤 드롭 순서 변경
- 대표 이미지 표시
- 이미지별 편집 옵션

## 🎨 UI/UX 가이드라인

### 디자인 원칙
- **다크 테마**: 검은색 배경 기본
- **고대비**: 명확한 시각적 계층
- **반응형**: 다양한 화면 크기 지원
- **접근성**: WCAG 2.1 AA 준수

### 애니메이션
- **전환**: 300ms ease-in-out
- **페이드**: 150ms 페이드 인/아웃
- **스켈레톤**: 로딩 시 shimmer 효과
- **피드백**: 즉각적인 시각적 피드백

### 에러 처리
- **인라인 검증**: 필드별 에러 메시지
- **토스트**: 일반 알림 메시지
- **다이얼로그**: 중요한 확인 요청
- **빈 상태**: 콘텐츠 없을 때 안내

## 🔄 마이그레이션 체크리스트

### Phase 1: 기본 화면
- [ ] CreatePostScreen 마이그레이션
- [ ] FeedScreen 마이그레이션
- [ ] PostDetailScreen 구현

### Phase 2: 에디터 화면
- [ ] ImageEditorScreen 마이그레이션
- [ ] VideoEditorScreen 구현
- [ ] ThumbnailSelectionScreen 마이그레이션

### Phase 3: 컴포넌트 분리
- [ ] 각 화면의 컴포넌트 분리
- [ ] 재사용 가능한 위젯 추출
- [ ] 공통 레이아웃 구현

### Phase 4: 최적화
- [ ] 성능 프로파일링
- [ ] 메모리 사용 최적화
- [ ] 애니메이션 최적화

## ⚠️ 주의사항

1. **상태 관리**: Provider 패턴으로 상태 관리
2. **네비게이션**: GoRouter 사용하여 라우팅
3. **성능**: AutomaticKeepAliveClientMixin 활용
4. **에러 처리**: 사용자 친화적 에러 표시
5. **접근성**: 스크린 리더 지원 필수

---

*이 문서는 Posts Feature의 Presentation Screens 레이어 사양입니다.*