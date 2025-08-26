# 📦 Posts Presentation Widgets

> Posts Feature의 재사용 가능한 위젯 컴포넌트

## 📋 개요

이 디렉토리는 Posts Feature에서 사용되는 재사용 가능한 UI 컴포넌트들을 포함합니다. 각 위젯은 특정 기능을 담당하며, 여러 화면에서 재사용됩니다.

### 🎯 목적
- **재사용성**: 여러 화면에서 공통으로 사용되는 UI 컴포넌트
- **일관성**: 통일된 디자인 시스템 구현
- **모듈화**: 독립적이고 테스트 가능한 위젯
- **유지보수**: 중앙 집중식 위젯 관리

## 🏗️ 디렉토리 구조

```
presentation/widgets/
├── media/                       # 미디어 관련 위젯
│   ├── media_selection_box.dart
│   ├── media_viewer.dart
│   ├── video_player_widget.dart
│   └── image_carousel.dart
├── input/                       # 입력 필드 위젯
│   ├── validated_text_field.dart
│   ├── character_counter.dart
│   └── multi_line_input.dart
├── buttons/                     # 버튼 컴포넌트
│   ├── next_button.dart
│   ├── vote_button.dart
│   └── action_button.dart
├── cards/                       # 카드 컴포넌트
│   ├── post_card.dart
│   ├── versus_box.dart
│   └── comment_card.dart
├── dialogs/                     # 다이얼로그
│   ├── target_audience_dialog.dart
│   ├── moderation_dialog.dart
│   └── confirmation_dialog.dart
├── feedback/                    # 피드백 위젯
│   ├── loading_indicator.dart
│   ├── error_widget.dart
│   └── empty_state.dart
└── navigation/                  # 네비게이션 관련
    ├── step_indicator.dart
    └── tab_selector.dart
```

## 📝 주요 위젯 사양

### 1. PostCard Widget

**책임**: 게시물 카드 UI 렌더링 및 상호작용

**주요 기능**:
- 사용자 정보 표시 (아바타, 이름, 시간)
- 질문 및 설명 텍스트 표시
- A/B 옵션 콘텐츠 렌더링
- 투표 상태 및 타이머 표시
- 좋아요, 댓글, 공유 액션

**Props**:
- post: PostModel 데이터
- onTap: 카드 탭 콜백
- onVote: 투표 액션 콜백
- onLike: 좋아요 액션 콜백
- onComment: 댓글 액션 콜백
- onShare: 공유 액션 콜백
- showActions: 액션 버튼 표시 여부

**상태 관리**:
- 투표 애니메이션 컨트롤러
- 좋아요 애니메이션 컨트롤러
- 투표 상태 추적

### 2. VersusBox Widget

**책임**: A/B 옵션 박스 렌더링

**주요 기능**:
- 미디어 콘텐츠 표시 (이미지, 비디오, YouTube)
- 텍스트 콘텐츠 표시
- 투표 진행률 시각화
- 투표 퍼센티지 표시
- 선택 상태 피드백

**Props**:
- option: 'A' 또는 'B' 레이블
- content: 콘텐츠 Map (text, images, video, youtube)
- color: 테마 색상 (파란색/빨간색)
- votes: 현재 투표 수
- totalVotes: 전체 투표 수
- isSelected: 선택 상태
- onTap: 탭 액션 콜백

**미디어 처리**:
- 단일 이미지: 전체 표시
- 멀티 이미지: 2x2 그리드
- 4개 초과: +N 오버레이
- 비디오/YouTube: 플레이 아이콘

### 3. MediaSelectionBox Widget

**책임**: 미디어 선택 및 미리보기

**주요 기능**:
- 이미지/비디오/YouTube 선택
- 미디어 미리보기
- 편집 액션
- 추가 미디어 선택
- 드래그 앤 드롭 지원

**Props**:
- label: 박스 레이블 ('A'/'B')
- color: 테마 색상
- images: 선택된 이미지 리스트
- video: 선택된 비디오
- youtube: YouTube URL
- onImagesSelected: 이미지 선택 콜백
- onVideoSelected: 비디오 선택 콜백
- onYoutubeSelected: YouTube 입력 콜백
- onRemove: 제거 콜백

**상태**:
- hover 상태 추적
- 미디어 타입 관리
- 편집 모드 상태

### 4. ValidatedTextField Widget

**책임**: 유효성 검사가 포함된 텍스트 입력 필드

**주요 기능**:
- 실시간 유효성 검사
- 문자 수 카운터
- 에러 메시지 표시
- 필수 필드 표시
- 커스텀 검증 규칙

**Props**:
- label: 필드 레이블
- hint: 플레이스홀더 텍스트
- value: 현재 값
- onChanged: 값 변경 콜백
- validator: 검증 함수
- maxLength: 최대 길이
- maxLines: 최대 줄 수
- required: 필수 여부
- errorText: 에러 메시지

### 5. LoadingIndicator Widget

**책임**: 로딩 상태 표시

**유형**:
- Circular: 원형 프로그레스
- Linear: 선형 프로그레스 바
- Skeleton: 스켈레톤 로더
- Shimmer: 쉬머 효과

**Props**:
- type: 인디케이터 타입
- size: 크기 설정
- color: 색상 설정
- value: 진행률 (0.0-1.0)

### 6. EmptyState Widget

**책임**: 빈 상태 UI 표시

**유형**:
- NoContent: 콘텐츠 없음
- NoResults: 검색 결과 없음
- Error: 에러 상태
- Offline: 오프라인 상태

**Props**:
- type: 빈 상태 타입
- title: 제목 텍스트
- description: 설명 텍스트
- action: 액션 버튼
- icon: 아이콘 표시

## 🎨 디자인 시스템

### 색상 체계
- **Primary**: 브랜드 색상
- **Secondary**: 보조 색상
- **Option A**: 파란색 계열
- **Option B**: 빨간색 계열
- **Background**: 검은색/어두운 회색
- **Surface**: 카드 배경색

### 타이포그래피
- **Title**: 18-24px, Bold
- **Body**: 14-16px, Regular
- **Caption**: 12px, Regular
- **Button**: 14-16px, SemiBold

### 간격 시스템
- **xs**: 4px
- **sm**: 8px
- **md**: 16px
- **lg**: 24px
- **xl**: 32px

### 애니메이션
- **Duration**: 200-600ms
- **Curve**: easeInOut
- **Fade**: 150-300ms
- **Slide**: 300ms

## 🔄 마이그레이션 체크리스트

### Phase 1: 핵심 위젯
- [ ] PostCard 위젯 마이그레이션
- [ ] VersusBox 위젯 마이그레이션
- [ ] MediaSelectionBox 위젯 마이그레이션

### Phase 2: 입력 위젯
- [ ] ValidatedTextField 구현
- [ ] CharacterCounter 구현
- [ ] MultiLineInput 구현

### Phase 3: 피드백 위젯
- [ ] LoadingIndicator 구현
- [ ] ErrorWidget 구현
- [ ] EmptyState 구현

### Phase 4: 기타 위젯
- [ ] 버튼 컴포넌트 구현
- [ ] 다이얼로그 구현
- [ ] 네비게이션 위젯 구현

## ⚠️ 주의사항

1. **재사용성**: 모든 위젯은 독립적으로 동작해야 함
2. **접근성**: 적절한 semantics 레이블 추가
3. **반응형**: 다양한 화면 크기 지원
4. **성능**: 애니메이션 및 이미지 로딩 최적화
5. **테스트**: 위젯 테스트 작성 필수

---

*이 문서는 Posts Feature의 Presentation Widgets 레이어 사양입니다.*