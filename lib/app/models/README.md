# 📍 App Models 레이어

> Feature-First Architecture의 앱 레벨 데이터 모델  
> 최종 업데이트: 2025-08-27 | 버전: 1.0.0

## 📋 개요

App Models는 위치 관련 데이터 모델을 정의합니다.
현재는 Google Maps/Places API와 관련된 모델들이 포함되어 있지만, 실제로는 거의 사용되지 않고 있습니다.

## 🏗️ 현재 디렉토리 구조

```
lib/app/models/
├── lat_lng.dart       # 위치 좌표 모델 (위도/경도)
├── place.dart         # 장소 정보 모델
└── README.md          # 현재 문서
```

## 🔍 현재 코드 분석

### 1. LatLng 모델 (`lat_lng.dart`)

#### 기능
- 위도(latitude)와 경도(longitude)를 저장하는 불변 데이터 클래스
- Google Maps API와 호환되는 위치 좌표 표현

#### 주요 메서드
```dart
class LatLng {
  const LatLng(this.latitude, this.longitude);
  
  // 좌표를 "latitude,longitude" 형식으로 직렬화
  String serialize() => '$latitude,$longitude';
  
  // 동등성 비교 및 해시 코드 구현
  bool operator ==(other) => ...
}
```

#### 사용 현황
- ❌ 현재 프로젝트에서 실제 사용되지 않음
- 📝 README 문서에서만 예시로 언급됨
- 🔮 Google Maps 통합 시 사용 예정

### 2. AppPlace 모델 (`place.dart`)

#### 기능
- 장소의 상세 정보를 저장하는 불변 데이터 클래스
- Google Places API와 호환되는 장소 정보 표현

#### 속성
```dart
class AppPlace {
  final LatLng latLng;     // 위치 좌표
  final String name;        // 장소명
  final String address;     // 주소
  final String city;        // 도시
  final String state;       // 주/도
  final String country;     // 국가
  final String zipCode;     // 우편번호
}
```

#### 사용 현황
- ❌ 현재 프로젝트에서 실제 사용되지 않음
- 🔮 위치 기반 기능 구현 시 사용 예정

## ⚠️ 현재 문제점

### 1. 미사용 코드
- 두 모델 모두 실제로 사용되지 않고 있음
- 프로젝트에 불필요한 코드가 포함되어 있음

### 2. 잘못된 위치
- `app` 레이어는 앱 설정과 진입점을 위한 곳
- 도메인 모델은 Feature나 Domain 레이어에 있어야 함

### 3. Feature-First Architecture 위반
- 위치 관련 기능이 Feature로 분리되지 않음
- 전역 앱 레이어에 도메인 특화 모델이 존재

## 🛠️ Feature-First Architecture 개선 방안

### 방안 1: Location Feature 생성 (권장) ✅

#### 새로운 구조
```
lib/features/location/
├── data/
│   ├── datasources/
│   │   └── google_maps_datasource.dart
│   └── repositories/
│       └── location_repository_impl.dart
├── domain/
│   ├── models/
│   │   ├── lat_lng.dart      # 현재 파일 이동
│   │   └── place.dart         # 현재 파일 이동
│   ├── repositories/
│   │   └── location_repository.dart
│   └── usecases/
│       ├── get_current_location.dart
│       └── search_places.dart
└── presentation/
    ├── screens/
    │   └── location_picker_screen.dart
    └── widgets/
        └── map_widget.dart
```

#### 장점
- ✅ Feature-First Architecture 준수
- ✅ 위치 관련 기능 중앙화
- ✅ 확장 가능한 구조
- ✅ Clean Architecture 적용

### 방안 2: 코드 삭제 (대안) 🗑️

#### 조건
- 위치 기반 기능이 향후 6개월 내 계획이 없는 경우
- 프로젝트 요구사항에 위치 기능이 없는 경우

#### 절차
1. 코드 사용 여부 최종 확인
2. Git 히스토리 백업
3. 파일 및 디렉토리 삭제

### 방안 3: Backend 레이어로 이동 (비권장) ⚠️

#### 구조
```
lib/backend/models/location/
├── lat_lng.dart
└── place.dart
```

#### 단점
- ❌ Backend는 Firebase/API 모델용
- ❌ 도메인 모델과 데이터 모델 혼재
- ❌ 책임 분리 원칙 위반

## 📊 현재 상태 평가

### 강점
- ✅ 간단하고 명확한 모델 정의
- ✅ 불변 객체 패턴 적용
- ✅ 동등성 비교 구현

### 약점
- ❌ 실제 사용되지 않는 코드
- ❌ 잘못된 레이어에 위치
- ❌ Feature로 분리되지 않음
- ❌ 테스트 코드 없음

### 기회
- 🔄 Location Feature 생성 기회
- 🔄 지도 기능 추가 가능성
- 🔄 위치 기반 검색 구현 가능

### 위협
- ⚠️ 미사용 코드 축적
- ⚠️ 아키텍처 일관성 저해
- ⚠️ 유지보수 부담 증가

## 🎯 액션 플랜

### 즉시 조치 (1일)
1. **사용 여부 확인**
   - [ ] 프로덕트 팀과 위치 기능 로드맵 확인
   - [ ] 6개월 내 위치 기능 계획 확인

2. **결정**
   - [ ] Location Feature 생성 또는
   - [ ] 코드 삭제

### Location Feature 생성 시 (1주)
1. **Feature 구조 생성**
   ```bash
   mkdir -p lib/features/location/{data,domain,presentation}
   mkdir -p lib/features/location/domain/models
   ```

2. **파일 이동**
   ```bash
   mv lib/app/models/*.dart lib/features/location/domain/models/
   ```

3. **Feature 구현**
   - Repository 패턴 적용
   - UseCase 구현
   - Presentation 레이어 구축

### 코드 삭제 시 (즉시)
1. **백업**
   ```bash
   git tag backup/app-models-$(date +%Y%m%d)
   ```

2. **삭제**
   ```bash
   rm -rf lib/app/models
   ```

## 📝 사용 가이드 (향후 Location Feature 구현 시)

### 위치 좌표 사용
```dart
// lib/features/location/domain/usecases/get_current_location.dart
class GetCurrentLocation {
  Future<LatLng> execute() async {
    // GPS 또는 IP 기반 위치 획득
    return LatLng(37.5665, 126.9780); // 서울
  }
}
```

### 장소 검색
```dart
// lib/features/location/domain/usecases/search_places.dart
class SearchPlaces {
  Future<List<AppPlace>> execute(String query) async {
    // Google Places API 검색
    return [
      AppPlace(
        name: 'Versus Space 본사',
        address: '서울특별시 강남구...',
        latLng: LatLng(37.5665, 126.9780),
      ),
    ];
  }
}
```

### UI에서 사용
```dart
// lib/features/location/presentation/screens/location_picker_screen.dart
class LocationPickerScreen extends StatelessWidget {
  void _selectLocation() {
    final location = GetCurrentLocation().execute();
    // 지도에 표시
  }
}
```

## ⚠️ 주의사항

1. **즉시 결정 필요**: 미사용 코드는 기술 부채
2. **Feature 우선**: 새 기능은 반드시 Feature로 생성
3. **아키텍처 준수**: app 레이어에 도메인 모델 금지

## 📚 참고 자료

- [Feature-First Architecture Guide](/FEATURE_ARCHITECTURE.md)
- [Global Layers Documentation](/GLOBAL_LAYERS.md)
- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [Geolocator Package](https://pub.dev/packages/geolocator)

---

*이 문서는 App Models 레이어의 현재 상태와 개선 방안을 담고 있습니다.*
*즉시 Location Feature 생성 또는 코드 삭제 결정이 필요합니다.*