# 🖼️ Image Viewer - 이미지 뷰어 페이지

> Versus Space 앱의 전체화면 이미지 뷰어로, 갤러리 스타일의 이미지 보기와 상호작용을 제공하는 독립적인 페이지입니다.

## 📋 개요

Image Viewer는 사용자가 이미지를 전체화면으로 보고 상호작용할 수 있는 몰입형 뷰어 페이지입니다. 핀치 줌, 스와이프, 팬 등의 제스처를 지원하며, 로컬 파일과 원격 URL 이미지를 모두 표시할 수 있습니다.

### 🎯 주요 목적
- **전체화면 보기**: 몰입형 이미지 viewing 경험
- **멀티 이미지 지원**: 여러 이미지 간 스와이프 전환
- **상호작용**: 줌, 팬 등 직관적인 제스처
- **유연한 데이터 소스**: File 경로와 URL 모두 지원

## 🏗️ 디렉토리 구조

```
/lib/pages/image_viewer/
├── image_viewer_page.dart      # 메인 뷰어 UI (335줄)
├── image_viewer_model.dart     # 상태 관리 모델 (11줄)
└── README.md                  # 문서 파일
```

### 📊 코드 통계
- **총 코드 라인**: 346줄
- **파일 수**: 2개
- **주요 컴포넌트**: ImageViewerPage, ImageViewerModel
- **의존성**: 5개 (Flutter, CachedNetworkImage, Core)

## 📐 네이밍 컨벤션

### 파일명
- **패턴**: snake_case (Dart 표준)
- **접미사**: `_page`, `_model`
- **예시**: `image_viewer_page.dart`

### 클래스명
- **패턴**: PascalCase
- **접미사**: `Page`, `Model`
- **예시**: `ImageViewerPage`, `ImageViewerModel`

### 라우팅
- **routeName**: PascalCase (`'ImageViewer'`)
- **routePath**: kebab-case (`'/imageViewer'`)

### 변수 및 메서드
- **패턴**: camelCase
- **private**: 언더스코어 접두사 (`_`)
- **예시**: `currentIndex`, `_buildImageWidget()`

> 참조: [프로젝트 전체 네이밍 컨벤션](../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소

### 1. ImageViewerPage - 메인 뷰어 UI 🖼️

**전체화면 이미지 뷰어의 메인 StatefulWidget입니다.**

#### 라우팅 정보
```dart
static String routeName = 'ImageViewer';
static String routePath = '/imageViewer';
```

#### 생성자 파라미터
```dart
const ImageViewerPage({
  this.imageUrls = const [],      // URL 이미지 리스트
  this.imagePaths = const [],     // 로컬 파일 경로 리스트  
  this.initialIndex = 0,          // 시작 인덱스
  this.box,                       // 박스 라벨 (A/B)
});
```

#### 주요 기능
- **PageView 기반**: 좌우 스와이프로 이미지 전환
- **InteractiveViewer**: 핀치 줌 (1.0x ~ 4.0x)
- **듀얼 소스 지원**: File 경로와 URL 동시 처리
- **에러 핸들링**: 로드 실패 시 에러 UI 표시

### 2. 이미지 렌더링 시스템 🎨

**로컬 파일과 URL 이미지를 효율적으로 렌더링합니다.**

#### 이미지 소스 처리
```dart
Widget _buildImageWidget(int index) {
  // 1. File 경로 우선 확인
  if (widget.imagePaths.isNotEmpty && index < widget.imagePaths.length) {
    final file = File(widget.imagePaths[index]);
    return Image.file(
      file,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }
  
  // 2. URL 처리
  if (widget.imageUrls.isNotEmpty && index < widget.imageUrls.length) {
    return CachedNetworkImage(
      imageUrl: widget.imageUrls[index],
      fit: BoxFit.contain,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
    );
  }
}
```

#### 지원 형식
| 소스 타입 | 위젯 | 캐싱 | 에러 처리 |
|----------|------|------|----------|
| **File** | Image.file | ❌ | errorBuilder |
| **URL** | CachedNetworkImage | ✅ | errorWidget |

### 3. UI 레이아웃 구조 📐

**Stack 기반의 레이어드 UI 구조입니다.**

#### 레이어 구성
1. **베이스 레이어**: PageView.builder (이미지 컨테이너)
2. **상단 오버레이**: 네비게이션 바 + 페이지 인디케이터
3. **하단 오버레이**: 액션 버튼 (다운로드, 공유, 삭제)

#### 상단 바 구성
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    IconButton(icon: Icons.arrow_back_ios),  // 뒤로가기
    Text('${widget.box} 이미지'),            // 제목
    Text('${currentIndex + 1} / $total'),    // 페이지 표시
  ],
)
```

#### 하단 액션 버튼
| 버튼 | 아이콘 | 기능 | 상태 |
|------|--------|------|------|
| **다운로드** | Icons.download | 이미지 저장 | 준비 중 |
| **공유** | Icons.share | 이미지 공유 | 준비 중 |
| **삭제** | Icons.delete_outline | 이미지 삭제 | 준비 중 |

### 4. InteractiveViewer 설정 🔍

**제스처 기반 상호작용을 제공합니다.**

```dart
InteractiveViewer(
  minScale: 1.0,    // 최소 배율
  maxScale: 4.0,    // 최대 배율
  child: Center(
    child: _buildImageWidget(index),
  ),
)
```

#### 지원 제스처
- **핀치**: 두 손가락으로 확대/축소
- **더블 탭**: 빠른 줌 (구현 예정)
- **팬**: 확대된 상태에서 이미지 이동
- **스와이프**: 좌우로 이미지 전환

### 5. ImageViewerModel - 상태 관리 📊

**최소한의 상태 관리를 담당하는 모델 클래스입니다.**

```dart
class ImageViewerModel extends AppModel {
  int currentIndex = 0;  // 현재 이미지 인덱스
  
  void initState(BuildContext context) {}
  void dispose() {}
}
```

#### 확장 가능성
- UI 표시/숨김 토글
- 줌 레벨 추적
- 다운로드 진행 상태
- 공유 기능 상태

## 💡 사용 가이드

### 기본 사용법
```dart
// 로컬 파일 이미지
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ImageViewerPage(
      imagePaths: ['/path/to/image1.jpg', '/path/to/image2.jpg'],
      initialIndex: 0,
      box: 'A',  // 선택적: 박스 라벨
    ),
  ),
);

// URL 이미지
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ImageViewerPage(
      imageUrls: ['https://example.com/image1.jpg'],
      initialIndex: 0,
    ),
  ),
);
```

### InPutPostImage 통합
```dart
// MediaSelectionBox에서 이미지 탭 시
onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ImageViewerPage(
        imagePaths: appState.uploadImageA,
        initialIndex: currentImageIndex,
        box: 'A',
      ),
    ),
  );
}
```

## 🎨 디자인 시스템

### 색상 스킴
| 요소 | 색상 | 용도 |
|------|------|------|
| **배경** | Colors.black | 몰입형 경험 |
| **오버레이** | black.withAlpha(0.7) | 그라디언트 |
| **텍스트** | Colors.white | 높은 대비 |
| **인디케이터** | black.withAlpha(0.5) | 반투명 배경 |

### 그라디언트 효과
```dart
LinearGradient(
  colors: [
    Colors.black.withAlpha(0.7),  // 진한 부분
    Colors.transparent,            // 투명 부분
  ],
)
```

### 간격 및 패딩
| 용도 | 값 | 적용 위치 |
|------|-----|----------|
| **상단 바 패딩** | 16px horizontal, 8px vertical | SafeArea 내부 |
| **하단 바 패딩** | 16px all | 액션 버튼 영역 |
| **버튼 패딩** | 20px horizontal, 12px vertical | 개별 액션 버튼 |

## 🚀 성능 최적화

### 이미지 로딩 전략
1. **CachedNetworkImage**: URL 이미지 자동 캐싱
2. **Image.file**: 로컬 파일 직접 로드
3. **에러 빌더**: 로드 실패 시 즉시 대체 UI

### 메모리 관리
- **PageView.builder**: 필요한 이미지만 로드
- **InteractiveViewer**: GPU 가속 활용
- **dispose**: 컨트롤러 정리

### 제스처 성능
- **60fps 유지**: 부드러운 애니메이션
- **제스처 충돌 방지**: 단일 InteractiveViewer
- **하드웨어 가속**: Transform 위젯 활용

## 📚 의존성

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/core/app_theme.dart';
import '/core/app_utils.dart';
```

## 🔧 개선 사항 (TODO)

### 우선순위 높음
1. **다운로드 기능**: 이미지 저장 구현
2. **공유 기능**: Share 플러그인 통합

### 우선순위 중간
3. **삭제 기능**: 실제 삭제 로직 구현
4. **더블 탭 줌**: 빠른 확대/축소

### 우선순위 낮음
5. **썸네일 스트립**: 하단 미리보기
6. **스와이프 다운 닫기**: 제스처로 닫기
7. **비디오 지원**: 비디오 플레이어 통합

## 🐛 알려진 이슈

### 현재 이슈
1. **액션 버튼 미구현**: 다운로드, 공유, 삭제 기능 준비 중
2. **더블 탭 줌 없음**: InteractiveViewer 기본 기능만 사용

### 해결 방법
- 액션 버튼: 실제 기능 구현 필요
- 더블 탭: GestureDetector 추가 구현

## 📅 변경 이력

| 날짜 | 버전 | 변경 내용 | 작업자 |
|------|------|----------|--------|
| 2025-08-23 | v2.0.0 | README 문서 전체 개편 (services 형식 적용) | AI Assistant |
| 2025-07-08 | v1.1.0 | InteractiveViewer 적용, 줌 기능 추가 | 개발팀 |
| 2025-07-07 | v1.0.0 | 초기 이미지 뷰어 구현 | 개발팀 |

## 🔗 관련 문서

- [전체 Pages 구조](../README.md)
- [InPutPostImage 통합](../../posts/in_put_post_image/README.md)
- [Core 유틸리티](../../core/README.md)
- [디자인 시스템](../../design_system/README.md)

---

*이 문서는 Versus Space 앱의 이미지 뷰어 구현을 상세히 설명합니다.*
*최종 업데이트: 2025-08-23*