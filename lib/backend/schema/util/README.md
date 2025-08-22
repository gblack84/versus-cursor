# Schema Utilities

Versus Space 앱의 Firestore 데이터 직렬화 및 스키마 유틸리티를 담당하는 모듈입니다.

## 📋 개요

이 디렉토리는 Firestore와 Flutter 앱 간의 데이터 변환을 처리하는 핵심 유틸리티 함수들을 포함합니다. 타입 변환, 중첩 필드 처리, GeoPoint/LatLng 변환, Color 직렬화 등 복잡한 데이터 구조를 안전하게 처리하는 기능을 제공합니다.

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **클래스명**: PascalCase
- **함수명**: camelCase
- **변수명**: camelCase
- **상수명**: camelCase
- 참조: [NAMING_CONVENTION.md](../../../../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
lib/backend/schema/util/
├── README.md               # 이 문서
├── firestore_util.dart     # Firestore 데이터 변환 유틸리티
└── schema_util.dart        # 스키마 타입 변환 및 구조체 유틸리티
```

## 🔧 주요 구성요소

### 1. firestore_util.dart

Firestore 문서와 Flutter 객체 간의 데이터 변환을 담당하는 핵심 유틸리티입니다.

#### 핵심 클래스

**FirestoreRecord (추상 클래스)**
```dart
abstract class FirestoreRecord {
  FirestoreRecord(this.reference, this.snapshotData);
  Map<String, dynamic> snapshotData;
  DocumentReference reference;
}
```
- Firestore 문서의 기본 구조 정의
- 모든 Firestore 모델 클래스의 부모 클래스
- 문서 참조와 스냅샷 데이터 보관

**AppFirebaseStruct (추상 클래스)**
```dart
abstract class AppFirebaseStruct extends BaseStruct {
  AppFirebaseStruct(this.firestoreUtilData);
  FirestoreUtilData firestoreUtilData = FirestoreUtilData();
}
```
- Firebase 구조체의 기본 클래스
- Firestore 업데이트 유틸리티 데이터 포함

**FirestoreUtilData**
```dart
class FirestoreUtilData {
  const FirestoreUtilData({
    this.fieldValues = const {},
    this.clearUnsetFields = true,
    this.create = false,
    this.delete = false,
  });
}
```
- Firestore 문서 업데이트 메타데이터 관리
- 필드 값, 생성/삭제 플래그 관리
- 설정되지 않은 필드 처리 옵션

#### 핵심 함수

**mapFromFirestore()**
```dart
Map<String, dynamic> mapFromFirestore(Map<String, dynamic> data)
```
- Firestore → Flutter 데이터 변환
- 자동 타입 변환:
  - `Timestamp` → `DateTime`
  - `GeoPoint` → `LatLng`
  - 중첩된 Map 재귀 처리
  - List 내부 요소 변환

**mapToFirestore()**
```dart
Map<String, dynamic> mapToFirestore(Map<String, dynamic> data)
```
- Flutter → Firestore 데이터 변환
- 자동 타입 변환:
  - `LatLng` → `GeoPoint`
  - `Color` → CSS 문자열
  - 중첩된 Map 재귀 처리
  - List 내부 요소 변환

**mergeNestedFields()**
```dart
Map<String, dynamic> mergeNestedFields(Map<String, dynamic> data)
```
- 점 표기법 필드를 중첩된 Map으로 변환
- 예: `'user.name'` → `{user: {name: value}}`
- 재귀적으로 모든 레벨 처리

#### Extension 메서드

**GeoPoint ↔ LatLng 변환**
```dart
extension GeoPointExtension on LatLng {
  GeoPoint toGeoPoint() => GeoPoint(latitude, longitude);
}

extension LatLngExtension on GeoPoint {
  LatLng toLatLng() => LatLng(latitude, longitude);
}
```

#### 유틸리티 함수

**safeGet()**
```dart
T? safeGet<T>(T Function() func, [Function(dynamic)? reportError])
```
- 안전한 값 획득 래퍼
- 예외 발생 시 null 반환
- 선택적 에러 리포팅

**toRef()**
```dart
DocumentReference toRef(String ref)
```
- 문자열 경로를 DocumentReference로 변환

### 2. schema_util.dart

스키마 타입 변환과 구조체 빌더 유틸리티를 제공합니다.

#### 핵심 타입 정의

**StructBuilder**
```dart
typedef StructBuilder<T> = T Function(Map<String, dynamic> data);
```
- Map 데이터를 구조체로 변환하는 빌더 함수 타입

**BaseStruct (추상 클래스)**
```dart
abstract class BaseStruct {
  Map<String, dynamic> toSerializableMap();
  String serialize() => json.encode(toSerializableMap());
}
```
- 모든 구조체의 기본 클래스
- 직렬화 인터페이스 제공

#### 핵심 함수

**convertAlgoliaStruct()**
```dart
dynamic convertAlgoliaStruct<T>(
  dynamic data,
  ParamType paramType,
  bool isList, {
  required StructBuilder<T> structBuilder,
})
```
- Algolia 검색 결과를 구조체로 변환
- 단일 객체 및 리스트 처리
- null 안전 처리

**getStructList()**
```dart
List<T>? getStructList<T>(
  dynamic value,
  StructBuilder<T> structBuilder,
)
```
- 동적 값을 구조체 리스트로 변환
- Map 타입 필터링
- null 안전 처리

**getSchemaColor()**
```dart
Color? getSchemaColor(dynamic value)
```
- 다양한 형식의 색상 값 처리
- CSS 색상 문자열 → Color 객체
- 이미 Color 타입인 경우 그대로 반환

**getColorsList()**
```dart
List<Color>? getColorsList(dynamic value)
```
- 색상 리스트 변환
- null 값 필터링
- 타입 안전 보장

**getDataList()**
```dart
List<T>? getDataList<T>(dynamic value)
```
- 제네릭 타입 리스트 변환
- 타입 캐스팅 처리
- null 안전 처리

## 🔍 데이터 변환 플로우

### Firestore → Flutter 변환 과정

```
1. Firestore 문서 읽기
    ↓
2. mapFromFirestore() 호출
    ↓
3. 타입별 자동 변환
    - Timestamp → DateTime
    - GeoPoint → LatLng
    - 중첩 Map 재귀 처리
    ↓
4. mergeNestedFields()로 점 표기법 처리
    ↓
5. Flutter 객체 생성
```

### Flutter → Firestore 변환 과정

```
1. Flutter 객체 준비
    ↓
2. mapToFirestore() 호출
    ↓
3. 타입별 자동 변환
    - LatLng → GeoPoint
    - Color → CSS 문자열
    - DateTime → Timestamp (자동)
    ↓
4. FirestoreUtilData 메타데이터 제거
    ↓
5. Firestore 문서 저장
```

## 🚀 사용 예시

### Firestore 문서 읽기
```dart
// Firestore에서 문서 읽기
DocumentSnapshot snapshot = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .get();

// 데이터 변환
Map<String, dynamic> userData = mapFromFirestore(
    snapshot.data() as Map<String, dynamic>
);

// Timestamp가 DateTime으로 자동 변환됨
DateTime createdAt = userData['createdAt'];
// GeoPoint가 LatLng로 자동 변환됨
LatLng location = userData['location'];
```

### Firestore 문서 저장
```dart
// Flutter 데이터 준비
Map<String, dynamic> postData = {
  'title': 'Sample Post',
  'location': LatLng(37.5665, 126.9780), // 서울
  'backgroundColor': Colors.blue,
  'createdAt': DateTime.now(),
  'tags': ['flutter', 'firebase'],
};

// Firestore용으로 변환
Map<String, dynamic> firestoreData = mapToFirestore(postData);

// Firestore에 저장
await FirebaseFirestore.instance
    .collection('posts')
    .add(firestoreData);
```

### 구조체 리스트 변환
```dart
// 커스텀 구조체 빌더
CommentStruct commentBuilder(Map<String, dynamic> data) {
  return CommentStruct(
    text: data['text'],
    author: data['author'],
    timestamp: data['timestamp'],
  );
}

// 리스트 변환
List<CommentStruct>? comments = getStructList(
  data['comments'],
  commentBuilder,
);
```

### 중첩 필드 처리
```dart
// 점 표기법 데이터
Map<String, dynamic> flatData = {
  'user.name': 'John',
  'user.email': 'john@example.com',
  'user.profile.age': 25,
  'user.profile.city': 'Seoul',
};

// 중첩 구조로 변환
Map<String, dynamic> nestedData = mergeNestedFields(flatData);
// 결과:
// {
//   'user': {
//     'name': 'John',
//     'email': 'john@example.com',
//     'profile': {
//       'age': 25,
//       'city': 'Seoul'
//     }
//   }
// }
```

## ⚡ 성능 최적화

### 타입 변환 최적화
- 타입 체크 후 필요한 경우에만 변환
- 재귀 처리 시 깊이 제한 고려
- 대량 데이터 처리 시 배치 처리

### 메모리 관리
- 큰 리스트 처리 시 스트림 사용 고려
- 불필요한 중간 객체 생성 최소화
- 캐싱 전략 구현

## 🔒 보안 고려사항

### 데이터 검증
- 입력 데이터 타입 검증
- null 안전 처리
- 예외 처리 및 에러 리포팅

### 민감 정보 처리
- 민감한 필드 필터링
- 로그에 민감 정보 노출 방지
- 적절한 필드 레벨 보안

## 🐛 에러 처리

### 일반적인 에러
- **타입 불일치**: 예상 타입과 실제 타입 불일치
- **null 참조**: null 값 처리 누락
- **중첩 깊이 초과**: 너무 깊은 중첩 구조
- **순환 참조**: 객체 간 순환 참조

### 에러 처리 전략
```dart
// safeGet 사용으로 안전한 값 획득
final userName = safeGet(
  () => userData['user']['name'],
  (error) => print('Error getting user name: $error'),
);

// 기본값 제공
final age = userData['age'] ?? 0;

// 타입 체크
if (userData['location'] is GeoPoint) {
  final location = (userData['location'] as GeoPoint).toLatLng();
}
```

## 📊 지원 타입

### 자동 변환 지원 타입
| Firestore 타입 | Flutter 타입 | 변환 방향 |
|---------------|-------------|----------|
| Timestamp | DateTime | 양방향 |
| GeoPoint | LatLng | 양방향 |
| DocumentReference | String Path | 단방향 |
| FieldValue | Dynamic | 단방향 |
| - | Color | Flutter → CSS String |

### 컬렉션 타입 지원
- List<T> 자동 변환
- Map<String, dynamic> 재귀 처리
- 중첩 컬렉션 완전 지원

## 🔗 관련 문서
- [Schema 모듈 전체](../README.md)
- [Backend 모듈](../../README.md)
- [Algolia 통합](../../algolia/README.md)
- [Firebase 초기화](../../firebase/README.md)
- [Firestore 공식 문서](https://firebase.google.com/docs/firestore)

## 📝 변경 이력
- 2025-08-22: 문서 전면 개정 및 상세 분석 추가
- 2025-08-21: snake_case → camelCase 마이그레이션 완료
- 초기: Firestore 스키마 유틸리티 구현

---

*이 문서는 `/lib/backend/schema/util` 디렉토리의 스키마 유틸리티를 설명합니다.*
