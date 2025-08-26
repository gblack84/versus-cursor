# Common Presentation Widgets

## 📋 개요
모든 Feature에서 공통으로 사용되는 재사용 가능한 UI 위젯들을 관리합니다.

## 🎯 역할
- **재사용 가능한 UI 컴포넌트**: 여러 Feature에서 공통으로 사용되는 위젯
- **일관된 UI/UX**: 앱 전체에서 통일된 사용자 경험 제공
- **컴포지션 패턴**: 작은 위젯들을 조합하여 복잡한 UI 구성
- **성능 최적화**: 자주 사용되는 위젯의 효율적인 렌더링

## 📁 파일 구조
```
presentation/
└── widgets/
    # 실제 마이그레이션 대상
    ├── highlighted_text_field.dart  # from /widgets/
    ├── unified_video_player.dart    # from /components/
    ├── youtube_player_widget.dart   # from /components/
    ├── alertempty_widget.dart       # from /components/
    ├── editviedo_widget.dart        # from /components/
    ├── videoplay_widget.dart        # from /components/
    
    # Core에서 이동할 위젯
    ├── app_widgets.dart            # from /lib/core/
    ├── app_icon_button.dart        # from /lib/core/
    └── app_toggle_icon.dart        # from /lib/core/
```

## 🚀 마이그레이션 대상

### 실제 이동할 파일
```bash
# 현재 위치에서 이동 (6개)
git mv lib/widgets/highlighted_text_field.dart \
       lib/features/common/presentation/widgets/

git mv lib/components/unified_video_player.dart \
       lib/features/common/presentation/widgets/

git mv lib/components/youtube_player_widget.dart \
       lib/features/common/presentation/widgets/

git mv lib/components/alertempty_widget.dart \
       lib/features/common/presentation/widgets/

git mv lib/components/editviedo_widget.dart \
       lib/features/common/presentation/widgets/

git mv lib/components/videoplay_widget.dart \
       lib/features/common/presentation/widgets/

# Core에서 이동 (3개)
git mv lib/core/app_widgets.dart \
       lib/features/common/presentation/widgets/

git mv lib/core/app_icon_button.dart \
       lib/features/common/presentation/widgets/

git mv lib/core/app_toggle_icon.dart \
       lib/features/common/presentation/widgets/
```

## 💻 위젯 사양

### 1. 버튼 위젯 (Buttons)

#### VersusButton
**역할**: 앱 전체에서 사용되는 주요 버튼 컴포넌트

**Props**:
- `text`: 버튼 텍스트
- `onPressed`: 클릭 핸들러
- `variant`: ButtonVariant (primary, secondary, outlined, text)
- `size`: ButtonSize (small, medium, large)
- `isLoading`: 로딩 상태
- `icon`: 선택적 아이콘

**사용 예시**: 로그인, 제출, 액션 버튼 등

### 2. 다이얼로그 위젯 (Dialogs)

#### VersusDialog
**역할**: 통일된 다이얼로그 컴포넌트

**Props**:
- `title`: 다이얼로그 제목
- `message`: 메시지 텍스트
- `content`: 커스텀 콘텐츠
- `actions`: DialogAction 리스트
- `barrierDismissible`: 바깥 터치로 닫기

**정적 메서드**:
- `show()`: 다이얼로그 표시

### 3. 로딩 인디케이터 (Loading)

#### LoadingIndicator
**역할**: 로딩 상태 표시

**Props**:
- `size`: 인디케이터 크기
- `color`: 색상
- `message`: 로딩 메시지

#### SkeletonLoader
**역할**: 콘텐츠 로딩 중 스켈레톤 표시

**Props**:
- `width`: 너비
- `height`: 높이
- `borderRadius`: 모서리 둥글기

**Factory Constructors**:
- `SkeletonLoader.text()`: 텍스트 스켈레톤
- `SkeletonLoader.circular()`: 원형 스켈레톤
- `SkeletonLoader.card()`: 카드 스켈레톤

### 4. 빈 상태 위젯 (Empty States)

#### EmptyStateWidget
**역할**: 데이터가 없을 때 표시

**Props**:
- `title`: 제목
- `message`: 설명 메시지
- `icon`: 아이콘
- `action`: 액션 위젯

### 5. 입력 필드 위젯 (Inputs)

#### HighlightedTextField
**역할**: 포커스 시 하이라이트되는 텍스트 필드

**Props**:
- `controller`: TextEditingController
- `hintText`: 힌트 텍스트
- `labelText`: 레이블
- `maxLength`: 최대 길이
- `maxLines`: 최대 줄 수
- `keyboardType`: 키보드 타입
- `onChanged`: 변경 콜백
- `validator`: 유효성 검사
- `showCounter`: 글자 수 표시

**특징**:
- 포커스 시 테두리 하이라이트
- 실시간 유효성 검사
- 애니메이션 효과

### 6. 미디어 플레이어 위젯 (Media)

#### UnifiedVideoPlayer
**역할**: 통합 비디오 플레이어

**Props**:
- `videoUrl`: 비디오 URL
- `autoPlay`: 자동 재생
- `showControls`: 컨트롤 표시
- `aspectRatio`: 비율

**기능**:
- 네트워크 비디오 재생
- 재생/일시정지 컨트롤
- 커스터마이징 가능한 UI

#### YouTubePlayerWidget
**역할**: YouTube 비디오 플레이어

**마이그레이션 커맨드**:
```bash
git mv lib/components/youtube_player_widget.dart \
       lib/features/common/presentation/widgets/media/
```

### 7. 배지 위젯 (Badges)

#### NotificationBadge
**역할**: 알림 카운트 배지

**Props**:
- `count`: 알림 개수
- `child`: 배지가 붙을 위젯
- `badgeColor`: 배지 색상
- `textColor`: 텍스트 색상

**특징**:
- 99+ 표시 지원
- 카운트 0일 때 자동 숨김
- 위치 커스터마이징

## 🧪 테스트 전략

### 위젯 테스트
- 렌더링 테스트
- 사용자 인터랙션 테스트
- 상태 변경 테스트
- 접근성 테스트

### 골든 테스트
- 시각적 회귀 테스트
- 다양한 테마 테스트
- 반응형 레이아웃 테스트

## ✅ 마이그레이션 체크리스트

### Phase 1: 버튼 및 다이얼로그
- [ ] VersusButton 마이그레이션
- [ ] IconButtonWidget 마이그레이션
- [ ] ActionButton 마이그레이션
- [ ] VersusDialog 마이그레이션
- [ ] AlertDialogWidget 마이그레이션
- [ ] ConfirmationDialog 마이그레이션

### Phase 2: 로딩 및 빈 상태
- [ ] LoadingIndicator 구현
- [ ] SkeletonLoader 구현
- [ ] ShimmerEffect 구현
- [ ] EmptyStateWidget 마이그레이션
- [ ] NoDataWidget 구현
- [ ] ErrorStateWidget 구현

### Phase 3: 입력 필드
- [ ] TextFieldWidget 구현
- [ ] HighlightedTextField 마이그레이션
- [ ] SearchInputWidget 구현

### Phase 4: 미디어 플레이어
- [ ] UnifiedVideoPlayer 마이그레이션
- [ ] YouTubePlayerWidget 마이그레이션
- [ ] ImageViewerWidget 구현

### Phase 5: 배지 및 기타
- [ ] NotificationBadge 마이그레이션
- [ ] CountBadge 구현

### Phase 6: 테스트
- [ ] 위젯 테스트 작성
- [ ] 골든 테스트 설정
- [ ] 접근성 테스트 추가

## 📝 사용 가이드

### 버튼 사용 예시
```dart
// Primary 버튼
VersusButton(
  text: '시작하기',
  onPressed: () => _handleStart(),
  variant: ButtonVariant.primary,
  size: ButtonSize.large,
);

// 아이콘 버튼
VersusButton(
  text: '좋아요',
  icon: Icon(Icons.favorite),
  onPressed: () => _handleLike(),
);

// 로딩 버튼
VersusButton(
  text: '저장 중...',
  isLoading: true,
);
```

### 다이얼로그 사용 예시
```dart
// 확인 다이얼로그
VersusDialog.show(
  context: context,
  title: '삭제 확인',
  message: '정말로 삭제하시겠습니까?',
  actions: [
    DialogAction(
      label: '취소',
      onPressed: (context) => Navigator.pop(context),
    ),
    DialogAction(
      label: '삭제',
      isDestructive: true,
      onPressed: (context) {
        _deleteItem();
        Navigator.pop(context);
      },
    ),
  ],
);
```

### 빈 상태 사용 예시
```dart
// 데이터가 없을 때
EmptyStateWidget(
  title: '아직 게시물이 없습니다',
  message: '첫 번째 게시물을 작성해보세요!',
  icon: Icon(Icons.post_add, size: 64),
  action: VersusButton(
    text: '게시물 작성',
    onPressed: () => _navigateToCreatePost(),
  ),
);
```

## 🔗 관련 문서
- [Design System Documentation](../../design_system/README.md)
- [Common Feature Architecture](../../README.md)
- [Widget Testing Guide](../../../testing/widget_testing_guide.md)