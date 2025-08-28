# 📦 Core Widgets Layer - Migration Part 3

> 최종 업데이트: 2025-08-28 | 버전: 1.0.0

## 📋 개요

Core Widgets 레이어는 전체 애플리케이션에서 재사용되는 공통 UI 컴포넌트들을 관리합니다. 현재 18개 파일이 산재되어 있으며, 체계적인 구조 개선이 필요합니다.

## 🎯 마이그레이션 목표

1. **체계적인 디렉토리 구조** - 카테고리별 위젯 정리
2. **명명 규칙 통일** - App* → Versus* 접두사 변경
3. **의존성 정리** - 순환 의존성 제거 및 계층 분리
4. **코드 품질 개선** - 중복 제거, 성능 최적화
5. **테스트 커버리지** - 90% 이상 달성

## 📊 현재 상태 분석

### 1. 파일 분석 (18개 파일)

| 파일명 | 줄 수 | 용도 | 문제점 |
|--------|-------|------|--------|
| app_widgets.dart | 305 | 버튼 위젯 | 복잡한 상태 관리 |
| app_icon_button.dart | 169 | 아이콘 버튼 | hover 상태 처리 복잡 |
| app_toggle_icon.dart | 84 | 토글 아이콘 | 애니메이션 미흡 |
| app_choice_chips.dart | 156 | 선택 칩 | 스타일 하드코딩 |
| app_media_display.dart | 182 | 미디어 표시 | 타입별 처리 혼재 |
| app_video_player.dart | 376 | 비디오 플레이어 | 복잡한 컨트롤러 관리 |
| app_web_view.dart | 124 | 웹뷰 | 플랫폼별 처리 부재 |
| highlighted_text_field.dart | 186 | 하이라이트 필드 | 독성 검증 로직 혼재 |
| unified_video_player.dart | 64 | 통합 플레이어 | YouTube 의존성 |
| youtube_player_widget.dart | 98 | YouTube 플레이어 | 외부 패키지 의존 |
| alertempty_widget.dart | 147 | 빈 상태 위젯 | 스타일 하드코딩 |
| editviedo_widget.dart | 234 | 비디오 편집 | 철자 오류 (viedo) |
| videoplay_widget.dart | 189 | 비디오 재생 | 중복 기능 |
| pickle_mark_widget.dart | 112 | 피클 마크 | 특화 컴포넌트 |

### 2. 주요 문제점

#### 구조적 문제
- **네이밍 불일치**: App*, 일반 이름 혼재
- **디렉토리 구조 부재**: 모든 위젯이 한 디렉토리에
- **계층 위반**: Core가 Services 직접 참조

#### 코드 품질 문제
- **철자 오류**: viedo → video
- **중복 코드**: 비디오 플레이어 3개 존재
- **상태 관리**: loading 상태 각자 구현
- **스타일 하드코딩**: 디자인 시스템 미사용

#### 유지보수 문제
- **테스트 부재**: 위젯 테스트 0%
- **문서화 부족**: 사용법 불명확
- **의존성 혼재**: 외부 패키지 직접 사용

## 🏗️ 목표 아키텍처

```
lib/core/widgets/
├── buttons/                    # 버튼 관련 위젯
│   ├── versus_button.dart      # 메인 버튼
│   ├── versus_icon_button.dart # 아이콘 버튼
│   └── versus_toggle_icon.dart # 토글 아이콘
├── inputs/                      # 입력 관련 위젯
│   ├── versus_text_field.dart  # 기본 텍스트 필드
│   ├── highlighted_text_field.dart # 하이라이트 필드
│   └── versus_choice_chips.dart # 선택 칩
├── media/                       # 미디어 관련 위젯
│   ├── versus_media_display.dart # 미디어 표시
│   ├── versus_video_player.dart  # 비디오 플레이어
│   ├── youtube_player_widget.dart # YouTube 플레이어
│   └── unified_video_player.dart # 통합 플레이어
├── feedback/                    # 피드백 관련 위젯
│   ├── versus_loading.dart     # 로딩 인디케이터
│   ├── versus_empty_state.dart # 빈 상태
│   └── versus_error_state.dart # 에러 상태
├── layout/                      # 레이아웃 관련 위젯
│   ├── versus_container.dart   # 컨테이너
│   ├── versus_card.dart        # 카드
│   └── versus_divider.dart     # 구분선
└── specialized/                # 특화 위젯
    ├── pickle_mark.dart         # 피클 마크
    └── versus_web_view.dart     # 웹뷰
```

## 📅 5일 마이그레이션 계획

### Day 1: 준비 및 버튼 위젯 (8시간)

#### 오전 (4시간): 준비 작업
```bash
# 1. 브랜치 생성
git checkout -b refactor/core-widgets-migration

# 2. 디렉토리 구조 생성
mkdir -p lib/core/widgets/{buttons,inputs,media,feedback,layout,specialized}

# 3. 테스트 디렉토리 생성
mkdir -p test/core/widgets/{buttons,inputs,media,feedback,layout,specialized}

# 4. 헬퍼 스크립트 생성
cat > scripts/migrate_widgets.sh << 'EOF'
#!/bin/bash
# Widget migration helper script
OLD_PREFIX="App"
NEW_PREFIX="Versus"

for file in $(find lib -name "${OLD_PREFIX}*.dart"); do
  newfile=$(echo $file | sed "s/${OLD_PREFIX}/${NEW_PREFIX}/g")
  echo "Renaming $file to $newfile"
done
EOF
```

#### 오후 (4시간): 버튼 위젯 마이그레이션
```dart
// lib/core/widgets/buttons/versus_button.dart
import 'package:flutter/material.dart';
import '/core/theme/versus_theme.dart';

class VersusButton extends StatefulWidget {
  const VersusButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final Widget? icon;
  final bool isLoading;
  final bool isDisabled;

  @override
  State<VersusButton> createState() => _VersusButtonState();
}

enum ButtonVariant { primary, secondary, outlined, text, danger }
enum ButtonSize { small, medium, large }

class _VersusButtonState extends State<VersusButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = VersusTheme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      transform: Matrix4.identity()
        ..scale(_isPressed ? 0.95 : 1.0),
      child: _buildButton(theme),
    );
  }

  Widget _buildButton(VersusTheme theme) {
    if (widget.isLoading) {
      return _buildLoadingButton(theme);
    }
    
    if (widget.icon != null) {
      return _buildIconButton(theme);
    }
    
    return _buildTextButton(theme);
  }
}
```

### Day 2: 입력 위젯 및 피드백 위젯 (8시간)

#### 오전 (4시간): 입력 위젯
```dart
// lib/core/widgets/inputs/versus_text_field.dart
import 'package:flutter/material.dart';
import '/core/theme/versus_theme.dart';

class VersusTextField extends StatefulWidget {
  const VersusTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.errorText,
    this.onChanged,
    this.validator,
    this.maxLength,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final int? maxLength;
  final int maxLines;

  @override
  State<VersusTextField> createState() => _VersusTextFieldState();
}

class _VersusTextFieldState extends State<VersusTextField> {
  late FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = VersusTheme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getBorderColor(theme),
          width: _hasFocus ? 2 : 1,
        ),
      ),
      child: TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        validator: widget.validator,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        decoration: _buildDecoration(theme),
      ),
    );
  }
}
```

#### 오후 (4시간): 피드백 위젯
```dart
// lib/core/widgets/feedback/versus_loading.dart
class VersusLoading extends StatelessWidget {
  const VersusLoading({
    super.key,
    this.size = LoadingSize.medium,
    this.message,
  });

  final LoadingSize size;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: _getSize(),
          height: _getSize(),
          child: CircularProgressIndicator(
            strokeWidth: _getStrokeWidth(),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(message!),
        ],
      ],
    );
  }
}

// lib/core/widgets/feedback/versus_empty_state.dart
class VersusEmptyState extends StatelessWidget {
  const VersusEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.action,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(icon, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message!, textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
```

### Day 3: 미디어 위젯 통합 (8시간)

#### 오전 (4시간): 비디오 플레이어 통합
```dart
// lib/core/widgets/media/versus_video_player.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VersusVideoPlayer extends StatefulWidget {
  const VersusVideoPlayer({
    super.key,
    required this.url,
    this.autoPlay = false,
    this.looping = false,
    this.showControls = true,
    this.aspectRatio,
  });

  final String url;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final double? aspectRatio;

  @override
  State<VersusVideoPlayer> createState() => _VersusVideoPlayerState();
}

class _VersusVideoPlayerState extends State<VersusVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _controller = VideoPlayerController.network(widget.url);
    await _controller.initialize();
    
    setState(() {
      _isInitialized = true;
    });

    if (widget.autoPlay) {
      _controller.play();
      setState(() {
        _isPlaying = true;
      });
    }

    _controller.setLooping(widget.looping);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return AspectRatio(
      aspectRatio: widget.aspectRatio ?? _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller),
          if (widget.showControls)
            _buildControls(),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      color: Colors.black26,
      child: IconButton(
        icon: Icon(
          _isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
          size: 50,
        ),
        onPressed: _togglePlay,
      ),
    );
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
      _isPlaying ? _controller.play() : _controller.pause();
    });
  }
}
```

#### 오후 (4시간): 이미지 및 미디어 표시
```dart
// lib/core/widgets/media/versus_media_display.dart
class VersusMediaDisplay extends StatelessWidget {
  const VersusMediaDisplay({
    super.key,
    required this.mediaUrl,
    required this.mediaType,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  final String mediaUrl;
  final MediaType mediaType;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    switch (mediaType) {
      case MediaType.image:
        return _buildImage();
      case MediaType.video:
        return _buildVideo();
      case MediaType.youtube:
        return _buildYouTube();
      default:
        return _buildError();
    }
  }

  Widget _buildImage() {
    return CachedNetworkImage(
      imageUrl: mediaUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => 
        placeholder ?? const CircularProgressIndicator(),
      errorWidget: (context, url, error) => 
        errorWidget ?? const Icon(Icons.error),
    );
  }
}
```

### Day 4: 레이아웃 및 특화 위젯 (8시간)

#### 오전 (4시간): 레이아웃 위젯
```dart
// lib/core/widgets/layout/versus_container.dart
class VersusContainer extends StatelessWidget {
  const VersusContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.decoration,
    this.width,
    this.height,
    this.constraints,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    final theme = VersusTheme.of(context);
    
    return Container(
      padding: padding ?? theme.spacing.medium,
      margin: margin,
      decoration: decoration ?? BoxDecoration(
        color: theme.colors.surface,
        borderRadius: BorderRadius.circular(theme.borderRadius.medium),
        boxShadow: [theme.shadows.small],
      ),
      width: width,
      height: height,
      constraints: constraints,
      child: child,
    );
  }
}

// lib/core/widgets/layout/versus_card.dart
class VersusCard extends StatelessWidget {
  const VersusCard({
    super.key,
    required this.child,
    this.onTap,
    this.elevation = 1,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double elevation;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = VersusTheme.of(context);
    
    return Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(theme.borderRadius.medium),
      color: theme.colors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(theme.borderRadius.medium),
        child: Padding(
          padding: padding ?? theme.spacing.medium,
          child: child,
        ),
      ),
    );
  }
}
```

#### 오후 (4시간): 특화 위젯
```dart
// lib/core/widgets/specialized/versus_web_view.dart
import 'package:webview_flutter/webview_flutter.dart';

class VersusWebView extends StatefulWidget {
  const VersusWebView({
    super.key,
    required this.url,
    this.onPageFinished,
    this.onProgress,
    this.javascriptMode = JavascriptMode.unrestricted,
  });

  final String url;
  final ValueChanged<String>? onPageFinished;
  final ValueChanged<int>? onProgress;
  final JavascriptMode javascriptMode;

  @override
  State<VersusWebView> createState() => _VersusWebViewState();
}

class _VersusWebViewState extends State<VersusWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(widget.javascriptMode)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            widget.onProgress?.call(progress);
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            widget.onPageFinished?.call(url);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
```

### Day 5: 테스트 및 문서화 (8시간)

#### 오전 (4시간): 위젯 테스트
```dart
// test/core/widgets/buttons/versus_button_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/core/widgets/buttons/versus_button.dart';

void main() {
  group('VersusButton', () {
    testWidgets('renders text correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersusButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading is true', 
      (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VersusButton(
              text: 'Loading',
              onPressed: null,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('handles onPressed callback', (tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersusButton(
              text: 'Press Me',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Press Me'));
      await tester.pump();

      expect(pressed, isTrue);
    });
  });
}
```

#### 오후 (4시간): 통합 및 문서화
```dart
// lib/core/widgets/widgets.dart
// Central export file for all widgets

export 'buttons/versus_button.dart';
export 'buttons/versus_icon_button.dart';
export 'buttons/versus_toggle_icon.dart';

export 'inputs/versus_text_field.dart';
export 'inputs/highlighted_text_field.dart';
export 'inputs/versus_choice_chips.dart';

export 'media/versus_media_display.dart';
export 'media/versus_video_player.dart';
export 'media/youtube_player_widget.dart';
export 'media/unified_video_player.dart';

export 'feedback/versus_loading.dart';
export 'feedback/versus_empty_state.dart';
export 'feedback/versus_error_state.dart';

export 'layout/versus_container.dart';
export 'layout/versus_card.dart';
export 'layout/versus_divider.dart';

export 'specialized/pickle_mark.dart';
export 'specialized/versus_web_view.dart';
```

## 🔄 Import 경로 업데이트

### 자동 업데이트 스크립트
```bash
#!/bin/bash
# update_widget_imports.sh

echo "Updating widget imports..."

# Old imports to new imports mapping
declare -A import_map=(
  ["'/core/app_widgets.dart'"]="'/core/widgets/buttons/versus_button.dart'"
  ["'/core/app_icon_button.dart'"]="'/core/widgets/buttons/versus_icon_button.dart'"
  ["'/core/app_toggle_icon.dart'"]="'/core/widgets/buttons/versus_toggle_icon.dart'"
  ["'/widgets/highlighted_text_field.dart'"]="'/core/widgets/inputs/highlighted_text_field.dart'"
  ["'/components/unified_video_player.dart'"]="'/core/widgets/media/unified_video_player.dart'"
  ["'/components/youtube_player_widget.dart'"]="'/core/widgets/media/youtube_player_widget.dart'"
)

# Update imports
for old_import in "${!import_map[@]}"; do
  new_import="${import_map[$old_import]}"
  find lib -name "*.dart" -exec sed -i "s|$old_import|$new_import|g" {} \;
done

# Update class names
find lib -name "*.dart" -exec sed -i 's/AppButtonWidget/VersusButton/g' {} \;
find lib -name "*.dart" -exec sed -i 's/AppIconButton/VersusIconButton/g' {} \;
find lib -name "*.dart" -exec sed -i 's/AppToggleIcon/VersusToggleIcon/g' {} \;

echo "Import update complete!"
```

## ⚠️ Breaking Changes

### 클래스명 변경
- `AppButtonWidget` → `VersusButton`
- `AppIconButton` → `VersusIconButton`
- `AppToggleIcon` → `VersusToggleIcon`
- `AppChoiceChips` → `VersusChoiceChips`
- `AppMediaDisplay` → `VersusMediaDisplay`
- `AppVideoPlayer` → `VersusVideoPlayer`

### 파라미터 변경
```dart
// Before
AppButtonWidget(
  text: 'Button',
  onPressed: () {},
  options: AppButtonOptions(...),
)

// After
VersusButton(
  text: 'Button',
  onPressed: () {},
  variant: ButtonVariant.primary,
  size: ButtonSize.medium,
)
```

### Import 경로 변경
```dart
// Before
import '/core/app_widgets.dart';
import '/widgets/highlighted_text_field.dart';

// After
import '/core/widgets/buttons/versus_button.dart';
import '/core/widgets/inputs/highlighted_text_field.dart';
```

## 🎯 성공 지표

### 정량적 지표
- ✅ 테스트 커버리지 90% 이상
- ✅ 빌드 시간 10% 단축
- ✅ 번들 크기 5% 감소
- ✅ 위젯 렌더링 성능 20% 향상

### 정성적 지표
- ✅ 명확한 디렉토리 구조
- ✅ 일관된 네이밍 규칙
- ✅ 디자인 시스템 완전 통합
- ✅ 개발자 경험 개선

## ✅ 체크리스트

### 마이그레이션 전
- [ ] 현재 코드 백업
- [ ] 의존성 분석 완료
- [ ] 테스트 환경 준비
- [ ] 팀 공유 및 일정 조정

### 마이그레이션 중
- [ ] Day 1: 버튼 위젯 완료
- [ ] Day 2: 입력/피드백 위젯 완료
- [ ] Day 3: 미디어 위젯 완료
- [ ] Day 4: 레이아웃/특화 위젯 완료
- [ ] Day 5: 테스트 및 문서화 완료

### 마이그레이션 후
- [ ] 전체 빌드 테스트
- [ ] Import 경로 검증
- [ ] 성능 테스트
- [ ] 문서 업데이트
- [ ] PR 리뷰 및 머지

## 📝 롤백 계획

문제 발생 시 롤백 절차:
```bash
# 1. 현재 작업 저장
git stash

# 2. 마이그레이션 전 커밋으로 롤백
git reset --hard <pre-migration-commit>

# 3. 원격 저장소 동기화 (팀 작업 시)
git push --force-with-lease

# 4. 의존성 복구
flutter clean
flutter pub get
```

## 🔍 모니터링

### 성능 모니터링
```dart
// lib/core/widgets/performance_monitor.dart
class WidgetPerformanceMonitor {
  static final _renderTimes = <String, Duration>{};
  
  static void recordRenderTime(String widget, Duration time) {
    _renderTimes[widget] = time;
    
    if (time > const Duration(milliseconds: 16)) {
      debugPrint('⚠️ Slow widget render: $widget (${time.inMilliseconds}ms)');
    }
  }
}
```

### 에러 트래킹
```dart
// lib/core/widgets/error_tracker.dart
class WidgetErrorTracker {
  static void reportError(String widget, Object error, StackTrace? stack) {
    debugPrint('Widget Error: $widget');
    debugPrint('Error: $error');
    if (stack != null) debugPrint('Stack: $stack');
    
    // Send to error reporting service
    FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      reason: 'Widget Error: $widget',
    );
  }
}
```

## 🚀 다음 단계

### 단기 (1주)
- 위젯 카탈로그 페이지 구현
- Storybook 통합
- 골든 테스트 추가

### 중기 (1개월)
- 접근성 개선
- 다크 모드 최적화
- 애니메이션 개선

### 장기 (3개월)
- 위젯 성능 최적화
- 커스텀 페인터 위젯 추가
- 플랫폼별 최적화

---

*이 문서는 Core Widgets 레이어의 마이그레이션 계획을 담고 있습니다.*
*질문이나 제안사항은 팀 채널로 공유해주세요.*