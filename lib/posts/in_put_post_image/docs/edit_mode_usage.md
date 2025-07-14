# 편집 모드에서 이미지 삭제 시 DB 동기화

## 개요
사용자가 게시물 편집 중 이미지를 X 버튼으로 삭제할 때, Firebase Storage와 Firestore DB를 모두 업데이트합니다.

## 사용 방법

### 1. 편집 모드로 InPutPostImageWidget 열기
```dart
// 게시물 편집 페이지에서
context.pushNamed(
  'inPutPostImage',
  queryParameters: {
    'postId': serializeParam(postDoc.reference.id, ParamType.String),
    'postRef': serializeParam(postDoc.reference, ParamType.DocumentReference),
    'isEdit': serializeParam(true, ParamType.bool),
  },
);
```

### 2. InPutPostImageWidget에서 편집 모드 설정
```dart
// initState() 또는 초기화 메서드에서
final postRef = widget.postRef; // 파라미터로 받은 DocumentReference
if (postRef != null) {
  _model.isEditMode = true;
  _model.existingPostRef = postRef;
  _model.existingPostId = postRef.id;
  
  // 기존 게시물 데이터 로드
  // AppState에 기존 이미지 URL들 설정
}
```

## 동작 방식

1. **사용자가 X 버튼 클릭**
   - AppState에서 즉시 이미지 제거 (UI 즉시 업데이트)
   - Firebase Storage에서 비동기로 삭제
   - 편집 모드일 경우 Firestore DB 업데이트

2. **Firestore 업데이트 (편집 모드일 때만)**
   - `posts_record.optionA/B.mediaUrls` 배열 업데이트
   - `poll_details.option_1/2_media_urls` 배열 업데이트
   - 트랜잭션으로 원자성 보장

3. **에러 처리**
   - Storage 삭제 실패 시 로그만 기록
   - DB 업데이트 실패 시 로그만 기록
   - 사용자 경험은 방해받지 않음

## 주의사항
- 새 게시물 작성 시에는 DB 업데이트하지 않음 (아직 저장되지 않았으므로)
- 편집 모드는 명시적으로 설정해야 함
- 백그라운드에서 처리되므로 네트워크 상태에 따라 지연될 수 있음