# 📸 Thumbnail Selection - 대표 이미지 선택 페이지

> Versus Space 앱의 멀티 이미지 중에서 대표 이미지(썸네일)를 선택하는 전문 페이지입니다. 사용자가 여러 이미지 중에서 게시물을 대표할 메인 이미지를 직관적으로 선택할 수 있는 인터페이스를 제공합니다.

## 📋 개요

Thumbnail Selection 페이지는 멀티 이미지 업로드 플로우에서 핵심적인 역할을 담당합니다. 사용자가 여러 장의 이미지를 선택한 후, 어떤 이미지를 대표 이미지로 보여줄지 결정하는 독립적인 선택 화면입니다. PageView를 활용한 전체화면 미리보기와 하단 썸네일 리스트를 통해 직관적인 선택 경험을 제공합니다.

### 🎯 주요 목적
- **대표 이미지 선택**: 멀티 이미지 중 메인 썸네일 지정
- **이미지 미리보기**: 전체화면으로 이미지 확인 가능
- **순서 재정렬**: 선택된 이미지를 첫 번째로 자동 배치
- **편집 준비**: 선택한 이미지를 바로 편집할 수 있도록 연결

## 🏗️ 디렉토리 구조

```
/lib/pages/thumbnail_selection/
├── thumbnail_selection_page.dart    # 메인 UI 구현 (327줄)
├── thumbnail_selection_model.dart   # 상태 관리 모델 (13줄)
└── README.md                        # 문서 파일
```

### 📊 코드 통계
- **총 코드 라인**: 340줄
- **파일 수**: 2개
- **주요 컴포넌트**: ThumbnailSelectionPage
- **의존성**: 3개 (Flutter, AppTheme, AppUtils)
- **구현 상태**: 완전 구현됨

## 📐 네이밍 컨벤션

### 파일명
- **패턴**: snake_case (Dart 표준)
- **접미사**: `_page`, `_model`
- **예시**: `thumbnail_selection_page.dart`

### 클래스명
- **패턴**: PascalCase
- **접미사**: `Page`, `Model`, `State`
- **예시**: `ThumbnailSelectionPage`, `_ThumbnailSelectionPageState`

### 라우팅
- **routeName**: PascalCase (`'ThumbnailSelection'`)
- **routePath**: camelCase with slash (`'/thumbnailSelection'`)

### 변수 및 메서드
- **패턴**: camelCase
- **private**: 언더스코어 접두사 (`_`)
- **예시**: `_selectedIndex`, `_pageController`, `_buildThumbnailList`

> 참조: [프로젝트 전체 네이밍 컨벤션](../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소

### 1. ThumbnailSelectionPage - 메인 선택 페이지 📸

**멀티 이미지 중 대표 이미지를 선택하는 StatefulWidget입니다.**

#### 라우팅 정보
```dart
static String routeName = 'ThumbnailSelection';
static String routePath = '/thumbnailSelection';
```

#### 입력 파라미터
```dart
final List<File> imagePaths;  // 선택할 이미지 파일 리스트
final String box;              // 'A' 또는 'B' 박스 구분
```

#### 상태 관리
- **_selectedIndex**: 현재 선택된 이미지 인덱스
- **_pageController**: PageView 컨트롤러

### 2. UI 레이아웃 시스템 🎨

**검은색 배경의 전체화면 이미지 뷰어와 하단 썸네일 선택기입니다.**

#### 레이아웃 구조
```dart
Stack(
  children: [
    // 1. 전체화면 이미지 뷰어
    Positioned.fill(child: PageView),
    
    // 2. 상단 네비게이션
    SafeArea(
      child: Stack(
        // 갤러리 버튼 (좌상단)
        // 체크 버튼 (우상단)
      ),
    ),
    
    // 3. 하단 UI
    Positioned(
      bottom: 0,
      child: Column(
        // 안내 문구
        // 썸네일 리스트
      ),
    ),
  ]
)
```

#### 시스템 UI 설정
```dart
SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
)
```

### 3. 이미지 미리보기 시스템 (PageView) 🖼️

**스와이프로 이미지를 넘겨볼 수 있는 전체화면 뷰어입니다.**

```dart
Widget _buildImagePreview() {
  return PageView.builder(
    controller: _pageController,
    itemCount: widget.imagePaths.length,
    onPageChanged: (index) {
      setState(() {
        _selectedIndex = index;
      });
    },
    itemBuilder: (context, index) {
      return Image.file(
        widget.imagePaths[index],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    },
  );
}
```

#### 특징
- **전체화면 표시**: BoxFit.cover로 화면 가득 채움
- **스와이프 네비게이션**: 좌우 스와이프로 이미지 전환
- **인덱스 동기화**: 페이지 변경 시 썸네일 선택 동기화

### 4. 썸네일 리스트 컴포넌트 📱

**하단에 표시되는 이미지 썸네일 선택 리스트입니다.**

```dart
Widget _buildThumbnailList() {
  return Container(
    height: 100,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.imagePaths.length, (index) {
        final isSelected = index == _selectedIndex;
        return GestureDetector(
          onTap: () {
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: Container(
            width: 80,
            height: 80,
            // 선택 표시, 순서 표시, 체크 아이콘
          ),
        );
      }),
    ),
  );
}
```

#### 썸네일 아이템 구성
- **크기**: 80x80 픽셀
- **테두리**: 선택 시 primary 색상 3px
- **체크 표시**: 선택된 아이템 우상단
- **순서 번호**: 좌하단에 인덱스 표시

### 5. 네비게이션 버튼 시스템 🔄

**갤러리 복귀 및 선택 완료 버튼입니다.**

#### 갤러리 버튼 (좌상단)
```dart
InkWell(
  onTap: () => Navigator.pop(context, {'action': 'back_to_picker'}),
  child: Container(
    // "< 갤러리" 텍스트 스타일 버튼
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.5),
      borderRadius: BorderRadius.circular(22),
    ),
  ),
)
```

#### 체크 버튼 (우상단)
```dart
IconButton(
  onPressed: () {
    Navigator.pop(context, {
      'selectedIndex': _selectedIndex,
      'allFiles': widget.imagePaths,
    });
  },
)
```

### 6. 안내 문구 컴포넌트 💬

**사용자에게 기능을 안내하는 텍스트 영역입니다.**

```dart
Widget _buildInfoText() {
  return Container(
    child: Column(
      children: [
        Text('선택한 이미지를 편집할 수 있습니다'),
        Text('나머지 이미지는 나중에 편집할 수 있어요'),
      ],
    ),
  );
}
```

#### 스타일링
- **그라디언트 배경**: 투명 → 반투명 검은색
- **텍스트 그림자**: 가독성 향상
- **색상**: 흰색 (주요), 흰색70% (보조)

## 💡 사용 가이드

### 페이지 진입
```dart
// 직접 호출
final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ThumbnailSelectionPage(
      imagePaths: imageFiles,  // List<File>
      box: 'A',                // 'A' 또는 'B'
    ),
  ),
);

// 결과 처리
if (result != null) {
  final selectedIndex = result['selectedIndex'];
  final allFiles = result['allFiles'];
  // 선택된 이미지 처리
}
```

### 결과 데이터 구조
```dart
// 체크 버튼 클릭 시
{
  'selectedIndex': 2,           // 선택된 인덱스
  'allFiles': [File, File, ...] // 전체 파일 리스트
}

// 갤러리 버튼 클릭 시
{
  'action': 'back_to_picker'    // 피커로 복귀 액션
}
```

### 이미지 순서 재정렬
```dart
// 선택된 이미지를 맨 앞으로 이동
if (selectedIndex > 0) {
  final selected = images.removeAt(selectedIndex);
  images.insert(0, selected);
  
  // AppState 업데이트
  appState.reorderUploadImage(selectedIndex, box);
}
```

## 🎨 디자인 시스템

### 색상 팔레트
- **배경**: `Colors.black` (전체 배경)
- **오버레이**: `Colors.black.withOpacity(0.5-0.9)` (그라디언트)
- **선택 테두리**: `AppTheme.of(context).primary`
- **텍스트**: `Colors.white`, `Colors.white70`
- **버튼 배경**: `Colors.black.withOpacity(0.5)`

### 간격 및 크기
- **썸네일 크기**: 80x80 픽셀
- **썸네일 간격**: 4px (horizontal)
- **썸네일 리스트 높이**: 100px
- **버튼 크기**: 44x44 픽셀
- **테두리 반경**: 12px (썸네일), 22px (버튼)

### 애니메이션
- **페이지 전환**: 300ms, Curves.easeInOut
- **선택 피드백**: 즉시 반영
- **스크롤**: 부드러운 관성 스크롤

### 그라디언트 효과
```dart
// 하단 그라디언트
LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Colors.transparent,
    Colors.black.withOpacity(0.3),
    Colors.black.withOpacity(0.5),
  ],
)
```

## 🚀 성능 최적화

### 이미지 로딩
- **File 직접 로드**: 네트워크 지연 없음
- **메모리 관리**: 보이는 이미지만 메모리에 유지
- **PageView 최적화**: 인접 페이지 미리 로드

### 썸네일 최적화
- **고정 크기**: 80x80으로 메모리 절약
- **BoxFit.cover**: 빠른 렌더링
- **재사용**: 스크롤 시 위젯 재사용

### 상태 관리
- **최소 setState**: 필요한 경우만 UI 업데이트
- **PageController**: 효율적인 페이지 관리
- **단일 상태**: _selectedIndex만 관리

## 📚 의존성

### 현재 의존성
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/core/app_theme.dart';
import '/core/app_utils.dart';
```

### 핵심 의존성
- **Flutter Material**: UI 프레임워크
- **dart:io**: File 클래스
- **SystemChrome**: 시스템 UI 설정
- **AppTheme**: 테마 시스템
- **AppUtils**: 유틸리티 함수

## 🔧 개선 사항 (TODO)

### 우선순위 높음
1. **드래그 앤 드롭**: 썸네일 순서 직접 변경
2. **줌 기능**: 핀치 투 줌으로 상세 보기
3. **디자인 시스템 적용**: VersusDesign System으로 마이그레이션

### 우선순위 중간
4. **애니메이션 개선**: 선택 시 스케일 효과
5. **로딩 표시**: 큰 이미지 로드 시 프로그레스
6. **캐싱**: 이미지 캐싱으로 성능 향상

### 우선순위 낮음
7. **접근성**: 스크린 리더 지원
8. **키보드 네비게이션**: 방향키로 선택
9. **다크모드**: 테마별 스타일 분리

## 🐛 알려진 이슈

### 현재 이슈
1. **AppTheme 사용**: 구형 테마 시스템 사용 중
   - VersusDesign System으로 마이그레이션 필요
   
2. **메모리 사용**: 많은 이미지 시 메모리 증가
   - 이미지 압축 및 썸네일 생성 필요

### 해결 방법
- 디자인 시스템 전면 적용
- 이미지 최적화 라이브러리 도입
- 가상화된 그리드 구현

## 📅 변경 이력

| 날짜 | 버전 | 변경 내용 | 작업자 |
|------|------|----------|--------|
| 2025-08-23 | v1.0.0 | README 문서 작성 완료 | AI Assistant |
| 2025-07-09 | v0.2.0 | 네비게이션 버튼 스타일 개선 | 개발팀 |
| 2025-07-09 | v0.1.0 | 초기 페이지 생성 | 개발팀 |

## 🔗 관련 문서

- [전체 Pages 구조](../../README.md)
- [이미지 작성 페이지](../in_put_post_image/README.md)
- [ProImageEditor](../pro_image_editor/README.md)
- [AppTheme 가이드](../../core/README.md)
- [네이밍 컨벤션](../../NAMING_CONVENTION.md)

## 📌 구현 예제

### 멀티 이미지에서 썸네일 선택
```dart
class ImageUploadFlow extends StatelessWidget {
  Future<void> selectThumbnail(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ThumbnailSelectionPage(
          imagePaths: appState.uploadImageA,
          box: 'A',
        ),
      ),
    );
    
    if (result != null && result['selectedIndex'] != null) {
      final index = result['selectedIndex'] as int;
      
      // 선택된 이미지를 맨 앞으로
      appState.moveToFrontUploadImage(index, 'A');
      
      // 편집 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProImageEditorPage(
            imagePath: appState.uploadImageA.first,
          ),
        ),
      );
    }
  }
}
```

### 커스텀 썸네일 선택기
```dart
class CustomThumbnailSelector extends StatelessWidget {
  final List<String> imageUrls;
  final Function(int) onSelected;
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => onSelected(index),
          child: Image.network(
            imageUrls[index],
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
```

---

*이 문서는 Versus Space 앱의 썸네일 선택 페이지 구현을 상세히 설명합니다.*
*최종 업데이트: 2025-08-23*