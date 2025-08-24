# 🔍 TestAlgoria - Algolia 검색 테스트

## 📋 개요

Algolia 검색 엔진 통합을 테스트하기 위한 페이지입니다. JopsCategory 모델과 연동하여 검색 기능을 구현했으나, 현재는 레거시 테스트 코드입니다.

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **클래스명**: PascalCase (`TestalgoriaWidget`, `TestalgoriaModel`)
- **라우트명**: lowerCamelCase (`routeName = 'testalgoria'`)
- 참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 🏗️ 구조

```
testalgoria/
├── testalgoria_widget.dart    # 검색 UI (327줄)
└── testalgoria_model.dart     # 상태 관리
```

## 📱 기능

### 주요 컴포넌트
- **검색 입력 필드**: 검색어 입력
- **검색 버튼**: Algolia API 호출
- **결과 리스트**: 검색 결과 표시
- **로딩 표시**: SpinKitRing 애니메이션

### 검색 플로우
```dart
// Algolia 검색 호출
JopsCategoryModel.search(
  term: _model.textController.text,
)
.then((r) => _model.algoliaSearchResults = r)
.whenComplete(() => setState(() {}));
```

### 데이터 구조
- `jopName`: 직업 이름
- `categoryRefA`: 카테고리 A 참조
- `categoryRefB`: 카테고리 B 참조

## 💻 코드 분석

### TestalgoriaWidget
```dart
static String routeName = 'testalgoria';
static String routePath = '/testalgoria';

// Algolia 검색 결과 표시
ListView.builder(
  itemCount: searchlist.length,
  itemBuilder: (context, index) {
    // 검색 결과 카드 표시
  }
)
```

### 검색 결과 처리
- null 체크로 초기 로딩 상태 관리
- 빈 결과 처리 (`?? []`)
- 각 결과 항목을 100px 높이 컨테이너로 표시

## 🚫 문제점

### 코드 품질 이슈
1. **하드코딩된 UI**: 
   - 고정 크기: `width: 100.0, height: 100.0`
   - 하드코딩된 색상: `Color(0xFFE7E6E6)`

2. **불완전한 구현**:
   - 에러 처리 미흡
   - 검색 디바운싱 없음
   - 결과 캐싱 없음

3. **레거시 패턴**:
   - FlutterFlow 자동 생성 코드
   - 중복된 font 설정

## 🔄 대체 구현

### 프로덕션 검색
```dart
// 실제 사용 경로
/lib/pages/search/        # 프로덕션 검색
/lib/backend/algolia/     # Algolia 서비스
```

## 📊 통계

- **위젯 파일**: 327줄
- **모델 파일**: 약 30줄
- **상태**: 🔴 미사용 (레거시)
- **의존성**: Algolia SDK

## ⚠️ 주의사항

> **경고**: Algolia API 테스트용 코드입니다.
> 프로덕션에서 사용하지 마세요.

### 권장 사항
- ✅ `/lib/pages/search/` 사용
- ✅ 검색 디바운싱 구현
- ✅ 결과 캐싱 추가
- ✅ 에러 처리 강화

## 🗑️ 제거 계획

- **Phase 1**: 의존성 확인 ✅
- **Phase 2**: Algolia 설정 확인 필요
- **Phase 3**: 다음 정리 작업 시 제거 예정 📅

## 📝 변경 이력
- 2025-08-24: 문서화 완료
- 2025-08-22: 초기 생성

---

*이 디렉토리는 레거시 테스트 코드를 포함하고 있으며, 향후 제거될 예정입니다.*
