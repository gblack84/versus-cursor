# 📄 Blankppp - 로그인 페이지 템플릿

## 📋 개요

FlutterFlow에서 생성한 기본 로그인 페이지 템플릿입니다. 이메일/비밀번호 인증을 위한 UI를 제공하지만, 현재는 프로덕션에서 사용되지 않는 레거시 코드입니다.

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **클래스명**: PascalCase (`BlankpppWidget`, `BlankpppModel`)
- **라우트명**: lowerCamelCase (`routeName = 'blankppp'`)
- 참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 🏗️ 구조

```
blankppp/
├── blankppp_widget.dart    # 로그인 UI 위젯 (518줄)
└── blankppp_model.dart     # 상태 관리 모델 (34줄)
```

## 📱 기능

### 주요 컴포넌트
- **이메일 입력 필드**: 이메일 주소 입력 및 검증
- **비밀번호 입력 필드**: 비밀번호 입력 (토글 가시성)
- **로그인 버튼**: Firebase Auth 연동 준비
- **비밀번호 재설정 링크**: 비밀번호 찾기 기능
- **소셜 로그인 버튼**: Apple, Google 로그인 (UI만 구현)

### 애니메이션
- 페이지 로드 시 fade-in 애니메이션
- 각 요소별 순차적 애니메이션 (100ms 간격)

## 💻 코드 분석

### BlankpppWidget
```dart
class BlankpppWidget extends StatefulWidget {
  static String routeName = 'blankppp';
  static String routePath = '/blankppp';
  
  // 기본 FlutterFlow 페이지 구조
  // AnimationController 2개 사용
  // 하드코딩된 스타일 값
}
```

### BlankpppModel
```dart
class BlankpppModel extends AppModel<BlankpppWidget> {
  // 이메일/비밀번호 텍스트 컨트롤러
  // FocusNode 관리
  // 비밀번호 가시성 상태
}
```

## 🚫 문제점

### 코드 품질 이슈
1. **하드코딩된 스타일**
   - 색상: `Color(0xFF0EA7E7)`, `Color(0xFFECECEC)`
   - 크기: 직접 입력된 픽셀 값
   - 패딩: 하드코딩된 EdgeInsets

2. **레거시 패턴**
   - FlutterFlow 자동 생성 코드
   - 과도한 Builder 패턴 사용
   - 불필요한 중첩 위젯

3. **미완성 기능**
   - Firebase Auth 연동 미구현
   - 소셜 로그인 실제 동작 없음
   - 에러 처리 로직 부재

## 🔄 대체 구현

### 프로덕션 로그인
```dart
// 실제 사용 경로
/lib/login/               # 프로덕션 로그인 페이지
/lib/auth/                # 인증 서비스
/lib/createaccount/       # 계정 생성 플로우
```

### 권장 사항
- ❌ 이 템플릿 사용 금지
- ✅ `/lib/login/` 디렉토리 사용
- ✅ 디자인 시스템 적용
- ✅ 적절한 에러 처리 구현

## 📊 통계

- **총 코드**: 552줄
- **위젯 파일**: 518줄
- **모델 파일**: 34줄
- **상태**: 🔴 미사용 (레거시)
- **마지막 수정**: FlutterFlow 마이그레이션 시

## ⚠️ 주의사항

> **경고**: 이 코드는 FlutterFlow 초기 개발 단계의 잔여물입니다.
> 프로덕션에서 사용하지 마세요.

### 마이그레이션 가이드
1. `/lib/login/` 디렉토리의 프로덕션 코드 사용
2. `VersusColors` 디자인 시스템 적용
3. `AuthService` 통합
4. 적절한 유효성 검사 구현

## 🗑️ 제거 계획

- **Phase 1**: 의존성 확인 ✅
- **Phase 2**: 프로덕션 영향 없음 확인 ✅
- **Phase 3**: 다음 정리 작업 시 제거 예정 📅

## 📝 변경 이력
- 2025-08-24: 문서화 완료
- 2025-08-22: 초기 생성

---

*이 디렉토리는 레거시 테스트 코드를 포함하고 있으며, 향후 제거될 예정입니다.*
