# 🔥 Firebase 백엔드 레이어

> Versus Space 앱의 Firebase 인프라 및 데이터 관리 레이어  
> 최종 업데이트: 2025-08-28 | 버전: 2.0.0

## 📋 개요

Firebase 백엔드 레이어는 Firebase 서비스의 초기화, Firestore 데이터 처리, Storage 파일 업로드 등의 인프라 기능을 담당합니다. 플랫폼별(웹/모바일) 설정을 관리하고, 데이터 직렬화/역직렬화 유틸리티를 제공합니다.

## 🏗️ 현재 디렉토리 구조

```
/lib/backend/firebase/
├── README.md                           # 이 문서
├── config/
│   └── firebase_config.dart           # 27줄 - Firebase 초기화 설정
├── firestore/
│   └── utils/
│       ├── firestore_util.dart        # 151줄 - Firestore 유틸리티
│       └── schema_util.dart           # 74줄 - 스키마 변환 유틸리티
└── storage/
    └── storage.dart                   # 12줄 - Storage 업로드 기능
```

## 📊 구현 상태 분석

| 컴포넌트 | 파일 | 줄 수 | 상태 | 문제점 |
|---------|------|-------|------|--------|
| **Firebase 초기화** | firebase_config.dart | 27 | 🟡 작동중 | API 키 하드코딩 |
| **Firestore 유틸** | firestore_util.dart | 151 | 🟢 작동중 | 싱글톤 패턴 미사용 |
| **스키마 유틸** | schema_util.dart | 74 | 🟢 작동중 | Feature 의존성 존재 |
| **Storage 업로드** | storage.dart | 12 | 🟢 작동중 | 에러 처리 미흡 |

## 🔍 코드 상세 분석

### 1. firebase_config.dart (Firebase 초기화)

#### 핵심 기능
```dart
Future initFirebase() async {
  if (kIsWeb) {
    // 웹 플랫폼: FirebaseOptions 직접 전달
    await Firebase.initializeApp(options: FirebaseOptions(...));
  } else {
    // 모바일: 네이티브 설정 파일 사용
    await Firebase.initializeApp();
  }
}
```

#### 문제점
- **보안 위험**: API 키가 소스 코드에 하드코딩됨
- **환경 분리 없음**: 개발/스테이징/프로덕션 구분 없음
- **재시도 로직 없음**: 네트워크 실패 시 처리 미흡

### 2. firestore_util.dart (Firestore 유틸리티)

#### 주요 클래스 및 기능

**FirestoreRecord (추상 클래스)**
```dart
abstract class FirestoreRecord {
  Map<String, dynamic> snapshotData;
  DocumentReference reference;
}
```
- Firestore 문서의 기본 구조 정의
- 모든 모델 클래스의 부모 클래스

**AppFirebaseStruct (추상 클래스)**
```dart
abstract class AppFirebaseStruct extends BaseStruct {
  FirestoreUtilData firestoreUtilData = FirestoreUtilData();
}
```
- Firestore 구조체의 기본 클래스
- CRUD 작업을 위한 메타데이터 관리

**mapFromFirestore / mapToFirestore**
```dart
// Firestore → Flutter 변환
Map<String, dynamic> mapFromFirestore(Map<String, dynamic> data)
// - Timestamp → DateTime
// - GeoPoint → LatLng
// - 중첩된 Map 재귀 처리

// Flutter → Firestore 변환
Map<String, dynamic> mapToFirestore(Map<String, dynamic> data)
// - DateTime → Timestamp (자동)
// - LatLng → GeoPoint
// - Color → CSS String
```

#### 타입 변환 매핑
| Firestore 타입 | Flutter 타입 | 변환 방향 |
|---------------|-------------|-----------|
| Timestamp | DateTime | 양방향 자동 |
| GeoPoint | LatLng | 양방향 |
| String (CSS) | Color | 양방향 |
| Map | Map | 재귀 처리 |

### 3. schema_util.dart (스키마 유틸리티)

#### 주요 기능

**BaseStruct (추상 클래스)**
```dart
abstract class BaseStruct {
  Map<String, dynamic> toSerializableMap();
  String serialize() => json.encode(toSerializableMap());
}
```
- 모든 데이터 구조체의 기본 인터페이스
- JSON 직렬화 지원

**Algolia 변환 함수**
```dart
dynamic convertAlgoliaStruct<T>(data, paramType, isList, {structBuilder})
```
- Algolia 검색 결과를 Flutter 객체로 변환
- 제네릭 타입 지원

**유틸리티 함수들**
- `getStructList<T>`: Map 리스트를 구조체 리스트로 변환
- `getSchemaColor`: 문자열/Color를 Color로 변환
- `getColorsList`: Color 리스트 변환
- `getDataList<T>`: 타입 캐스팅된 리스트 생성

#### 문제점
- **Feature 의존성**: `/features/search/data/services/serialization_util.dart` 직접 import
- **타입 안전성 부족**: dynamic 타입 과다 사용

### 4. storage.dart (Storage 업로드)

#### 구현
```dart
Future<String?> uploadData(String path, Uint8List data) async {
  final storageRef = FirebaseStorage.instance.ref().child(path);
  final metadata = SettableMetadata(contentType: mime(path));
  final result = await storageRef.putData(data, metadata);
  return result.state == TaskState.success 
    ? result.ref.getDownloadURL() 
    : null;
}
```

#### 기능
- 바이너리 데이터를 Firebase Storage에 업로드
- MIME 타입 자동 감지
- 업로드 성공 시 다운로드 URL 반환

#### 문제점
- **에러 처리 없음**: try-catch 블록 미사용
- **진행률 추적 없음**: 업로드 진행 상태 미제공
- **재시도 로직 없음**: 네트워크 실패 시 대응 없음

## 🚨 주요 문제점

### 1. 보안 문제 🔴 심각
```dart
// firebase_config.dart
apiKey: "AIzaSyDQTChIlq8kj9PKn7LZJsmDxmW5HTvh0BY"  // 하드코딩!
```
**영향**: API 키 노출로 보안 위험

### 2. 구조적 문제 🟡 중간
```
현재: Backend 레이어에 유틸리티 분산
올바른: Feature별 DataSource에서 활용
```
**영향**: Feature-First Architecture 위반

### 3. 의존성 문제 🟡 중간
```dart
// schema_util.dart
import '/features/search/data/services/serialization_util.dart';
```
**영향**: Backend가 Feature에 의존 (역방향 의존성)

### 4. 테스트 부재 🟡 중간
```
테스트 커버리지: 0%
Mock 구현: 없음
```
**영향**: 리팩토링 위험성 증가

## 📦 사용처 분석

### firebase_config.dart
- **호출**: `main.dart`의 앱 초기화 시점
- **의존**: Firebase Core 패키지

### firestore_util.dart
- **사용처**: 모든 Firestore 모델 클래스
  - `/lib/backend/schema/*.dart` (12개 모델)
  - `/features/*/data/models/*.dart`
- **기능**: 데이터 변환, 타입 매핑

### schema_util.dart
- **사용처**: 
  - Algolia 검색 결과 파싱
  - 구조체 직렬화/역직렬화
- **의존**: BaseStruct를 상속받는 모든 구조체

### storage.dart
- **사용처**:
  - 프로필 이미지 업로드
  - 게시물 미디어 업로드
  - 채팅 파일 첨부
- **의존**: Firebase Storage, mime_type 패키지

## 🎯 Feature-First Architecture 관점

### 현재 구조의 문제점
1. **책임 불명확**: 인프라와 비즈니스 로직 혼재
2. **재사용성 낮음**: Feature별 커스터마이징 어려움
3. **테스트 어려움**: 의존성 주입 미지원
4. **확장성 제한**: 새로운 Firebase 서비스 추가 어려움

### 올바른 구조
```
/lib/backend/firebase/
├── core/                    # 핵심 인프라
│   ├── config/
│   │   ├── firebase_config.dart
│   │   └── environment.dart
│   └── interfaces/
│       ├── i_firebase_service.dart
│       └── i_storage_service.dart
├── services/               # 서비스 구현
│   ├── firestore_service.dart
│   └── storage_service.dart
└── utils/                  # 유틸리티
    ├── converters/
    │   ├── timestamp_converter.dart
    │   └── geopoint_converter.dart
    └── serializers/
        └── base_serializer.dart
```

## 🔧 사용 방법

### Firebase 초기화
```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();  // Firebase 서비스 초기화
  runApp(MyApp());
}
```

### Firestore 데이터 변환
```dart
// 모델 클래스에서 사용
class PostsModel extends FirestoreRecord {
  PostsModel(super.reference, super.snapshotData) {
    // mapFromFirestore 자동 적용됨
  }
  
  // Firestore로 저장 시
  Map<String, dynamic> toFirestore() {
    return mapToFirestore({
      'title': title,
      'createdAt': createdAt,  // DateTime → Timestamp 자동
      'location': location,     // LatLng → GeoPoint 자동
    });
  }
}
```

### Storage 업로드
```dart
// 이미지 업로드 예시
final bytes = await imageFile.readAsBytes();
final url = await uploadData(
  'user_uploads/${userId}/profile.jpg',
  bytes,
);
```

## 📊 메트릭

| 지표 | 현재 | 목표 |
|-----|------|------|
| **코드 라인 수** | 264줄 | 500줄+ |
| **테스트 커버리지** | 0% | 80% |
| **타입 안전성** | 60% | 95% |
| **의존성 역전** | ❌ | ✅ |
| **환경 분리** | ❌ | ✅ |

## 🔗 관련 문서

- [Backend 전체 구조](../README.md)
- [Firestore 스키마](../schema/README.md)
- [API 레이어](../api/README.md)
- [Feature-First Architecture](/FEATURE_ARCHITECTURE.md)
- [마이그레이션 계획](./MIGRATION_Part3.md)
- [테스트 가이드](./TEST.md)

## ⚠️ 주의사항

1. **API 키 관리**: 환경 변수로 이동 필요
2. **초기화 순서**: Firebase → 다른 서비스 순서 준수
3. **타입 변환**: Timestamp ↔ DateTime 자동 변환 주의
4. **메모리 관리**: 대용량 파일 업로드 시 청크 처리 필요

---

*이 문서는 Firebase 백엔드 레이어의 현재 구현 상태와 개선 방향을 설명합니다.*