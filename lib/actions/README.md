# Actions

Versus Space 앱의 비즈니스 로직 액션을 관리하는 디렉토리입니다.

## 📋 개요

Actions는 UI와 비즈니스 로직을 분리하여 재사용 가능한 기능 단위로 구성된 함수들입니다. 현재 이 디렉토리에는 최소한의 구현만 포함되어 있습니다.

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **함수명**: camelCase
- **필드명**: camelCase
- 참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
lib/actions/
├── README.md         # 이 문서
└── actions.dart      # 액션 구현 파일
```

## 현재 구현된 액션

### 1. selectedLanguage

사용자의 언어 설정을 업데이트하는 액션입니다.

**파일**: `actions.dart`

**함수 시그니처**:
```dart
Future selectedLanguage(
  BuildContext context, {
  String? language,
}) async
```

**기능**:
- 현재 로그인한 사용자의 언어 설정을 Firestore에 업데이트
- `currentUserDocument`에서 기존 언어 설정을 가져와 업데이트

**구현 코드**:
```dart
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/core/app_utils.dart';
import 'package:flutter/material.dart';

Future selectedLanguage(
  BuildContext context, {
  String? language,
}) async {
  await currentUserReference!.update(createUsersModelData(
    language: valueOrDefault(currentUserDocument?.language, ''),
  ));
}
```

**사용 예시**:
```dart
// 언어를 한국어로 변경
await selectedLanguage(context, language: 'ko');

// 언어를 영어로 변경
await selectedLanguage(context, language: 'en');
```

**주의사항**:
- `currentUserReference`가 null이 아닌지 확인 필요
- 사용자가 로그인한 상태에서만 호출 가능

## ⚠️ 현재 상태

### 구현된 액션
- ✅ `selectedLanguage` - 언어 설정 업데이트

### 미구현 액션 (계획 또는 다른 위치에 구현)
다음 액션들은 현재 이 디렉토리에 구현되어 있지 않습니다:
- ❌ 로그아웃 액션
- ❌ 계정 삭제 액션
- ❌ 이미지 업로드 액션
- ❌ 게시물 생성 액션
- ❌ 친구 추가 액션
- ❌ 투표 액션
- ❌ 네비게이션 액션
- ❌ 클립보드 복사 액션
- ❌ 공유 액션

**Note**: 이러한 기능들은 다른 디렉토리나 컴포넌트에 구현되어 있을 수 있습니다.

## 액션 작성 가이드

새로운 액션을 추가할 때는 다음 패턴을 따르세요:

### 기본 구조
```dart
Future<T?> myAction(
  BuildContext context, {
  // 필수 파라미터
  required String param1,
  // 선택적 파라미터
  String? param2,
}) async {
  try {
    // 유효성 검사
    if (param1.isEmpty) {
      throw Exception('Invalid parameter');
    }
    
    // 비즈니스 로직
    final result = await performBusinessLogic();
    
    // 성공 처리
    return result;
    
  } catch (e) {
    // 에러 처리
    print('Error in myAction: $e');
    return null;
  }
}
```

### 네이밍 규칙
- 함수명: camelCase 사용 (예: `selectedLanguage`, `createPost`)
- 파라미터명: camelCase 사용 (예: `userId`, `postId`)
- 설명적이고 명확한 이름 사용

### Firebase 통합
```dart
// Firestore 업데이트 예시
await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .update({
    'fieldName': value,  // camelCase 필드명
    'updatedAt': FieldValue.serverTimestamp(),
  });
```

## 의존성

현재 actions.dart가 사용하는 의존성:
- `/auth/firebase_auth/auth_util.dart` - Firebase 인증 유틸리티
- `/backend/backend.dart` - 백엔드 모델 및 서비스
- `/core/app_utils.dart` - 앱 공통 유틸리티
- `flutter/material.dart` - Flutter Material 라이브러리

## 테스트

액션 테스트 예시:
```dart
testWidgets('selectedLanguage updates user language', (tester) async {
  // Mock 설정
  final mockUser = MockUserReference();
  
  // 테스트 실행
  await selectedLanguage(
    TestContext(),
    language: 'ko',
  );
  
  // 검증
  verify(mockUser.update(any)).called(1);
});
```

## 향후 개선 사항

1. **액션 확장**: 계획된 액션들의 실제 구현
2. **에러 처리**: 더 robust한 에러 처리 메커니즘
3. **로딩 상태**: 비동기 작업 중 로딩 표시
4. **테스트 커버리지**: 단위 테스트 추가
5. **타입 안정성**: 더 엄격한 타입 정의

## 관련 문서

- [프로젝트 아키텍처](../../ARCHITECTURE.md)
- [네이밍 컨벤션](../../NAMING_CONVENTION.md)
- [백엔드 스키마](../backend/schema/README.md)

---

최종 업데이트: 2025-08-22