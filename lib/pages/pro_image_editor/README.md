# 🎨 Pro Image Editor - 고급 이미지 편집 페이지

> Versus Space 앱의 고급 이미지 편집 기능을 제공하는 페이지입니다. ProImageEditor 라이브러리를 활용하여 사용자가 이미지를 편집하고 Firebase Storage에 업로드할 수 있습니다.

## 📋 개요

Pro Image Editor는 사용자가 이미지를 전문적으로 편집할 수 있는 강력한 도구를 제공합니다. 그리기, 텍스트 추가, 자르기, 필터 적용 등 다양한 편집 기능을 지원하며, 편집 완료 후 Firebase Storage에 자동으로 업로드됩니다.

### 🎯 주요 목적
- **이미지 편집**: 전문적인 이미지 편집 도구 제공
- **Firebase 통합**: 편집된 이미지 자동 업로드
- **AppState 연동**: 편집 결과 앱 상태 자동 업데이트
- **진행률 표시**: 업로드 과정 실시간 모니터링

## 🏗️ 디렉토리 구조

```
/lib/pages/pro_image_editor/
├── pro_image_editor_page.dart    # 메인 편집기 페이지 (200줄)
├── pro_image_editor_model.dart   # 상태 관리 모델 (19줄)
└── README.md                      # 문서 파일
```

### 📊 코드 통계
- **총 코드 라인**: 219줄
- **파일 수**: 2개
- **주요 컴포넌트**: ProImageEditorPage, ProImageEditorModel
- **의존성**: 9개 (ProImageEditor, Firebase Storage, Auth 등)

## 📐 네이밍 컨벤션

### 파일명
- **패턴**: snake_case (Dart 표준)
- **접미사**: `_page`, `_model`
- **예시**: `pro_image_editor_page.dart`

### 클래스명
- **패턴**: PascalCase
- **접미사**: `Page`, `Model`
- **예시**: `ProImageEditorPage`, `ProImageEditorModel`

### 라우팅
- **routeName**: PascalCase (`'ProImageEditor'`)
- **routePath**: camelCase with slash (`'/proImageEditor/:imagePath/:box'`)

### 변수 및 메서드
- **패턴**: camelCase
- **private**: 언더스코어 접두사 (`_`)
- **예시**: `isUploading`, `uploadProgress`, `_uploadToFirebase`

> 참조: [프로젝트 전체 네이밍 컨벤션](../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소

### 1. ProImageEditorPage - 메인 편집기 페이지 🖼️

**이미지 편집 기능을 제공하는 StatefulWidget입니다.**

#### 라우팅 정보
```dart
static String routeName = 'ProImageEditor';
static String routePath = '/proImageEditor/:imagePath/:box';
```

#### 파라미터
- **imagePath**: 편집할 이미지의 로컬 파일 경로
- **box**: 이미지가 속한 박스 ('A' 또는 'B')

#### 주요 UI 구성
- **ProImageEditor**: 메인 편집기 인터페이스
- **업로드 오버레이**: 업로드 진행률 표시
- **스낵바**: 성공/실패 메시지 표시

### 2. Firebase Storage 업로드 시스템 ☁️

**편집된 이미지를 Firebase Storage에 업로드합니다.**

```dart
Future<String> _uploadToFirebase(Uint8List bytes) async {
  // 파일명 생성
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final fileName = '${timestamp}_${widget.box}.jpg';
  final path = 'users/${user.uid}/posts/images/$fileName';
  
  // Firebase Storage 업로드
  final ref = FirebaseStorage.instance.ref(path);
  final uploadTask = ref.putData(bytes, metadata);
  
  // 진행률 모니터링
  uploadTask.snapshotEvents.listen((snapshot) {
    final progress = snapshot.bytesTransferred / snapshot.totalBytes;
    setState(() {
      _model.uploadProgress = progress;
    });
  });
  
  // URL 반환
  return await ref.getDownloadURL();
}
```

#### 업로드 경로 구조
```
users/
  └── {userId}/
      └── posts/
          └── images/
              └── {timestamp}_{box}.jpg
```

#### 메타데이터
- **contentType**: 'image/jpeg'
- **box**: 이미지가 속한 박스 (A/B)
- **uploadedAt**: 업로드 시간 (ISO 8601)

### 3. ProImageEditor 통합 🎨

**ProImageEditor 라이브러리 설정 및 콜백 처리입니다.**

```dart
ProImageEditor.file(
  File(widget.imagePath),
  callbacks: ProImageEditorCallbacks(
    onImageEditingComplete: (Uint8List bytes) async {
      // 1. Firebase 업로드
      final url = await _uploadToFirebase(bytes);
      
      // 2. AppState 업데이트
      if (widget.box == 'A') {
        appState.addToUploadImageA(url);
      } else {
        appState.addToUploadImageB(url);
      }
      
      // 3. 임시 파일 정리
      ImageDownloadService.cleanupTempFile(widget.imagePath);
      
      // 4. 페이지 닫기
      context.pop();
    },
  ),
)
```

### 4. ProImageEditorModel - 상태 관리 📊

**편집기 페이지의 상태를 관리하는 모델 클래스입니다.**

```dart
class ProImageEditorModel extends AppModel<ProImageEditorPage> {
  // 업로드 상태
  bool isUploading = false;
  
  // 업로드 진행률 (0.0 ~ 1.0)
  double uploadProgress = 0.0;
}
```

#### 상태 필드
- **isUploading**: 업로드 진행 중 여부
- **uploadProgress**: 업로드 진행률 (0~100%)

### 5. 업로드 진행률 UI 📊

**업로드 중 진행 상황을 표시하는 오버레이입니다.**

```dart
Container(
  color: Colors.black54,
  child: Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          value: _model.uploadProgress,
          valueColor: AlwaysStoppedAnimation<Color>(
            AppTheme.of(context).primary,
          ),
        ),
        Text(
          '업로드 중... ${(_model.uploadProgress * 100).toInt()}%',
          style: AppTheme.of(context).bodyMedium,
        ),
      ],
    ),
  ),
)
```

### 6. 에러 처리 시스템 ⚠️

**업로드 실패 시 에러 처리 로직입니다.**

```dart
catch (e) {
  setState(() {
    _model.isUploading = false;
  });
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('이미지 업로드 실패: $e'),
      backgroundColor: AppTheme.of(context).error,
    ),
  );
  rethrow;  // 상위 레벨에서 추가 처리 가능
}
```

## 💡 사용 가이드

### 페이지 진입
```dart
// 이미지 편집기 열기
context.pushNamed(
  ProImageEditorPage.routeName,
  pathParameters: {
    'imagePath': '/path/to/image.jpg',
    'box': 'A',  // 또는 'B'
  },
);
```

### 편집 플로우
1. **이미지 로드**: 로컬 파일 경로로 이미지 로드
2. **편집 작업**: 사용자가 이미지 편집
3. **완료 콜백**: 편집 완료 시 콜백 실행
4. **Firebase 업로드**: 편집된 이미지 업로드
5. **AppState 업데이트**: URL을 앱 상태에 저장
6. **임시 파일 정리**: 원본 임시 파일 삭제
7. **페이지 종료**: 이전 페이지로 복귀

### ImageDownloadService 연동
```dart
// Firebase URL에서 이미지 다운로드
final localPath = await ImageDownloadService.downloadImage(firebaseUrl);

// 편집기 열기
context.pushNamed(
  ProImageEditorPage.routeName,
  pathParameters: {
    'imagePath': localPath,
    'box': 'A',
  },
);

// 편집 완료 후 자동으로 임시 파일 정리됨
```

## 🎨 편집 기능

### 지원되는 편집 도구
- **그리기 (Paint)**: 펜, 화살표, 점선, 원, 이모지
- **텍스트 (Text)**: 텍스트 추가, 폰트, 색상, 정렬
- **자르기 (Crop)**: 자유 비율, 사전 정의 비율, 회전
- **필터 (Filter)**: 다양한 사전 정의 필터
- **실행 취소/재실행**: 편집 이력 관리

### 비활성화된 기능
- **블러 (Blur)**: 완전 비활성화
- **일부 그리기 도구**: Rectangle, Polygon, Pixelate, Line

## 🚀 성능 최적화

### 업로드 최적화
- 진행률 실시간 모니터링
- 청크 단위 업로드
- 네트워크 재시도 로직

### 메모리 관리
- 편집 완료 후 임시 파일 자동 삭제
- 이미지 바이트 효율적 처리
- 메모리 누수 방지

### UI 반응성
- 업로드 중 UI 차단 방지
- 진행률 표시로 사용자 피드백
- 스낵바로 즉각적인 결과 알림

## 📚 의존성

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '/core/app_theme.dart';
import '/core/app_utils.dart';
import '/posts/in_put_post_image/services/image_download_service.dart';
```

## 🔧 개선 사항 (TODO)

### 우선순위 높음
1. **한국어 지원**: ProImageEditor i18n 설정 추가
2. **이미지 압축**: 업로드 전 이미지 크기 최적화
3. **재시도 로직**: 네트워크 오류 시 자동 재시도

### 우선순위 중간
4. **편집 이력 저장**: 임시 저장 기능
5. **배치 업로드**: 여러 이미지 동시 업로드
6. **썸네일 생성**: 자동 썸네일 생성 및 저장

### 우선순위 낮음
7. **고급 필터**: 추가 필터 효과
8. **스티커 라이브러리**: 스티커 추가 기능
9. **협업 편집**: 실시간 공동 편집

## 🐛 알려진 이슈

### 현재 이슈
1. **메모리 사용량**: 대용량 이미지 편집 시 메모리 사용량 높음
   - 이미지 리사이징 필요
   - 점진적 렌더링 구현 필요

2. **네트워크 오류 처리**: 업로드 중 네트워크 끊김 처리 미흡
   - 재시도 로직 필요
   - 오프라인 큐 구현 필요

### 해결 방법
- 이미지 크기 제한 및 자동 리사이징
- 업로드 재시도 및 복구 메커니즘
- 백그라운드 업로드 지원

## 📅 변경 이력

| 날짜 | 버전 | 변경 내용 | 작업자 |
|------|------|----------|--------|
| 2025-08-23 | v1.0.0 | README 문서 작성 완료 | AI Assistant |
| 2025-07 | v0.1.0 | 초기 페이지 생성 | 개발팀 |

## 🔗 관련 문서

- [전체 Pages 구조](../../README.md)
- [In Put Post Image](../../posts/in_put_post_image/README.md)
- [ImageDownloadService](../../posts/in_put_post_image/services/README.md)
- [Firebase Storage 가이드](../../backend/firebase_storage/README.md)
- [AppState 관리](../../app_state.dart)
- [ProImageEditor 공식 문서](https://pub.dev/packages/pro_image_editor)

---

*이 문서는 Versus Space 앱의 고급 이미지 편집 페이지 구현을 상세히 설명합니다.*
*최종 업데이트: 2025-08-23*