# 🧪 Models 레이어 테스트 가이드

> 앱 레벨 모델 테스트 전략 및 구현 가이드  
> 작성일: 2025-08-28 | 예상 커버리지: 100%

## 📋 테스트 범위

### 1. 테스트 대상
- **LatLng**: 위치 좌표 모델
- **Place**: 장소 정보 모델
- **직렬화/역직렬화**: JSON 변환
- **유효성 검사**: 데이터 무결성

### 2. 테스트 제외 대상
- Google Maps SDK 타입
- 외부 라이브러리 모델

## 🎯 테스트 전략

### Phase 1: 모델 단위 테스트 (Week 4, Day 3 - 오전)

#### 1.1 LatLng 모델 테스트
```dart
// test/unit/app/models/lat_lng_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/app/models/lat_lng.dart';

void main() {
  group('LatLng 모델 테스트', () {
    test('유효한 좌표로 생성되어야 함', () {
      // Given
      const latitude = 37.5665;
      const longitude = 126.9780;
      
      // When
      final location = LatLng(
        latitude: latitude,
        longitude: longitude,
      );
      
      // Then
      expect(location.latitude, equals(latitude));
      expect(location.longitude, equals(longitude));
    });
    
    test('위도 범위를 검증해야 함', () {
      // Given - 유효하지 않은 위도
      const invalidLatitudes = [-91.0, 91.0, -180.0, 180.0];
      
      // Then
      for (final lat in invalidLatitudes) {
        expect(
          () => LatLng(latitude: lat, longitude: 0),
          throwsA(isA<ArgumentError>()),
        );
      }
    });
    
    test('경도 범위를 검증해야 함', () {
      // Given - 유효하지 않은 경도
      const invalidLongitudes = [-181.0, 181.0, -360.0, 360.0];
      
      // Then
      for (final lng in invalidLongitudes) {
        expect(
          () => LatLng(latitude: 0, longitude: lng),
          throwsA(isA<ArgumentError>()),
        );
      }
    });
    
    test('JSON으로 직렬화되어야 함', () {
      // Given
      final location = LatLng(
        latitude: 37.5665,
        longitude: 126.9780,
      );
      
      // When
      final json = location.toJson();
      
      // Then
      expect(json['latitude'], equals(37.5665));
      expect(json['longitude'], equals(126.9780));
    });
    
    test('JSON에서 역직렬화되어야 함', () {
      // Given
      final json = {
        'latitude': 37.5665,
        'longitude': 126.9780,
      };
      
      // When
      final location = LatLng.fromJson(json);
      
      // Then
      expect(location.latitude, equals(37.5665));
      expect(location.longitude, equals(126.9780));
    });
    
    test('두 위치 간 거리를 계산해야 함', () {
      // Given
      final seoul = LatLng(latitude: 37.5665, longitude: 126.9780);
      final busan = LatLng(latitude: 35.1796, longitude: 129.0756);
      
      // When
      final distance = seoul.distanceTo(busan);
      
      // Then - 약 325km
      expect(distance, greaterThan(320000));
      expect(distance, lessThan(330000));
    });
    
    test('같은 위치는 동일해야 함', () {
      // Given
      final location1 = LatLng(latitude: 37.5665, longitude: 126.9780);
      final location2 = LatLng(latitude: 37.5665, longitude: 126.9780);
      final location3 = LatLng(latitude: 37.5666, longitude: 126.9780);
      
      // Then
      expect(location1, equals(location2));
      expect(location1, isNot(equals(location3)));
      expect(location1.hashCode, equals(location2.hashCode));
    });
  });
}
```

#### 1.2 Place 모델 테스트
```dart
// test/unit/app/models/place_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/app/models/place.dart';
import 'package:versus_space/app/models/lat_lng.dart';

void main() {
  group('Place 모델 테스트', () {
    test('필수 필드로 생성되어야 함', () {
      // Given
      final location = LatLng(latitude: 37.5665, longitude: 126.9780);
      
      // When
      final place = Place(
        id: 'place_123',
        name: 'Seoul City Hall',
        location: location,
      );
      
      // Then
      expect(place.id, equals('place_123'));
      expect(place.name, equals('Seoul City Hall'));
      expect(place.location, equals(location));
      expect(place.address, isNull);
      expect(place.types, isEmpty);
    });
    
    test('모든 필드로 생성되어야 함', () {
      // Given
      final location = LatLng(latitude: 37.5665, longitude: 126.9780);
      final types = ['city_hall', 'government', 'point_of_interest'];
      
      // When
      final place = Place(
        id: 'place_123',
        name: 'Seoul City Hall',
        location: location,
        address: '110 Sejong-daero, Jung-gu, Seoul',
        types: types,
        phoneNumber: '+82-2-120',
        website: 'https://www.seoul.go.kr',
        rating: 4.5,
        userRatingsTotal: 1234,
        photoReferences: ['photo_ref_1', 'photo_ref_2'],
        openingHours: {
          'monday': '09:00-18:00',
          'tuesday': '09:00-18:00',
        },
      );
      
      // Then
      expect(place.address, equals('110 Sejong-daero, Jung-gu, Seoul'));
      expect(place.types, equals(types));
      expect(place.phoneNumber, equals('+82-2-120'));
      expect(place.website, equals('https://www.seoul.go.kr'));
      expect(place.rating, equals(4.5));
      expect(place.userRatingsTotal, equals(1234));
      expect(place.photoReferences?.length, equals(2));
      expect(place.openingHours?['monday'], equals('09:00-18:00'));
    });
    
    test('JSON으로 직렬화되어야 함', () {
      // Given
      final place = Place(
        id: 'place_123',
        name: 'Test Place',
        location: LatLng(latitude: 0, longitude: 0),
        address: 'Test Address',
        types: ['restaurant', 'food'],
        rating: 4.5,
      );
      
      // When
      final json = place.toJson();
      
      // Then
      expect(json['id'], equals('place_123'));
      expect(json['name'], equals('Test Place'));
      expect(json['location'], isNotNull);
      expect(json['address'], equals('Test Address'));
      expect(json['types'], equals(['restaurant', 'food']));
      expect(json['rating'], equals(4.5));
    });
    
    test('JSON에서 역직렬화되어야 함', () {
      // Given
      final json = {
        'id': 'place_123',
        'name': 'Test Place',
        'location': {
          'latitude': 37.5665,
          'longitude': 126.9780,
        },
        'address': 'Test Address',
        'types': ['restaurant'],
        'rating': 4.5,
        'userRatingsTotal': 100,
      };
      
      // When
      final place = Place.fromJson(json);
      
      // Then
      expect(place.id, equals('place_123'));
      expect(place.name, equals('Test Place'));
      expect(place.location.latitude, equals(37.5665));
      expect(place.address, equals('Test Address'));
      expect(place.types, contains('restaurant'));
      expect(place.rating, equals(4.5));
      expect(place.userRatingsTotal, equals(100));
    });
    
    test('null 필드를 올바르게 처리해야 함', () {
      // Given
      final json = {
        'id': 'place_123',
        'name': 'Test Place',
        'location': {
          'latitude': 0.0,
          'longitude': 0.0,
        },
        'address': null,
        'types': null,
        'rating': null,
      };
      
      // When
      final place = Place.fromJson(json);
      
      // Then
      expect(place.address, isNull);
      expect(place.types, isEmpty);
      expect(place.rating, isNull);
    });
    
    test('유효하지 않은 평점을 거부해야 함', () {
      // Given
      final location = LatLng(latitude: 0, longitude: 0);
      
      // Then
      expect(
        () => Place(
          id: '123',
          name: 'Test',
          location: location,
          rating: -1,
        ),
        throwsA(isA<ArgumentError>()),
      );
      
      expect(
        () => Place(
          id: '123',
          name: 'Test',
          location: location,
          rating: 6,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
    
    test('copyWith가 올바르게 작동해야 함', () {
      // Given
      final original = Place(
        id: '123',
        name: 'Original',
        location: LatLng(latitude: 0, longitude: 0),
        rating: 4.0,
      );
      
      // When
      final updated = original.copyWith(
        name: 'Updated',
        rating: 5.0,
      );
      
      // Then
      expect(updated.id, equals('123')); // 변경되지 않음
      expect(updated.name, equals('Updated')); // 변경됨
      expect(updated.rating, equals(5.0)); // 변경됨
      expect(updated.location, equals(original.location)); // 변경되지 않음
    });
  });
}
```

### Phase 2: 통합 테스트 (Week 4, Day 3 - 오후)

#### 2.1 모델 간 상호작용 테스트
```dart
// test/integration/app/models/model_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/app/models/place.dart';
import 'package:versus_space/app/models/lat_lng.dart';

void main() {
  group('모델 통합 테스트', () {
    test('Place 컬렉션이 거리순으로 정렬되어야 함', () {
      // Given
      final userLocation = LatLng(latitude: 37.5665, longitude: 126.9780);
      
      final places = [
        Place(
          id: '1',
          name: 'Far Place',
          location: LatLng(latitude: 35.1796, longitude: 129.0756), // 부산
        ),
        Place(
          id: '2',
          name: 'Near Place',
          location: LatLng(latitude: 37.5666, longitude: 126.9781), // 가까움
        ),
        Place(
          id: '3',
          name: 'Medium Place',
          location: LatLng(latitude: 37.4563, longitude: 126.7052), // 인천
        ),
      ];
      
      // When
      places.sort((a, b) {
        final distanceA = userLocation.distanceTo(a.location);
        final distanceB = userLocation.distanceTo(b.location);
        return distanceA.compareTo(distanceB);
      });
      
      // Then
      expect(places[0].name, equals('Near Place'));
      expect(places[1].name, equals('Medium Place'));
      expect(places[2].name, equals('Far Place'));
    });
    
    test('Place 필터링이 올바르게 작동해야 함', () {
      // Given
      final places = [
        Place(
          id: '1',
          name: 'Restaurant A',
          location: LatLng(latitude: 0, longitude: 0),
          types: ['restaurant', 'food'],
          rating: 4.5,
        ),
        Place(
          id: '2',
          name: 'Cafe B',
          location: LatLng(latitude: 0, longitude: 0),
          types: ['cafe', 'food'],
          rating: 3.5,
        ),
        Place(
          id: '3',
          name: 'Restaurant C',
          location: LatLng(latitude: 0, longitude: 0),
          types: ['restaurant', 'bar'],
          rating: 4.0,
        ),
      ];
      
      // When - 레스토랑만 필터링
      final restaurants = places
          .where((p) => p.types.contains('restaurant'))
          .toList();
      
      // Then
      expect(restaurants.length, equals(2));
      expect(restaurants.every((p) => p.types.contains('restaurant')), isTrue);
      
      // When - 평점 4.0 이상만 필터링
      final highRated = places
          .where((p) => p.rating != null && p.rating! >= 4.0)
          .toList();
      
      // Then
      expect(highRated.length, equals(2));
      expect(highRated.every((p) => p.rating! >= 4.0), isTrue);
    });
  });
}
```

### Phase 3: 성능 테스트 (Week 4, Day 3 - 오후)

```dart
// test/performance/app/models/model_performance_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/app/models/place.dart';
import 'package:versus_space/app/models/lat_lng.dart';

void main() {
  group('모델 성능 테스트', () {
    test('대량 Place 직렬화가 효율적이어야 함', () {
      // Given
      final places = List.generate(1000, (i) => 
        Place(
          id: 'place_$i',
          name: 'Place $i',
          location: LatLng(
            latitude: -90 + (i * 0.18),
            longitude: -180 + (i * 0.36),
          ),
          address: 'Address $i',
          types: ['type_${i % 5}'],
          rating: (i % 5).toDouble(),
        ),
      );
      
      // When
      final stopwatch = Stopwatch()..start();
      
      final jsonList = places.map((p) => p.toJson()).toList();
      
      stopwatch.stop();
      
      // Then
      expect(jsonList.length, equals(1000));
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
    
    test('대량 Place 역직렬화가 효율적이어야 함', () {
      // Given
      final jsonList = List.generate(1000, (i) => {
        'id': 'place_$i',
        'name': 'Place $i',
        'location': {
          'latitude': 0.0,
          'longitude': 0.0,
        },
        'types': ['type_${i % 5}'],
        'rating': (i % 5).toDouble(),
      });
      
      // When
      final stopwatch = Stopwatch()..start();
      
      final places = jsonList.map((json) => Place.fromJson(json)).toList();
      
      stopwatch.stop();
      
      // Then
      expect(places.length, equals(1000));
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
    
    test('거리 계산이 효율적이어야 함', () {
      // Given
      final origin = LatLng(latitude: 37.5665, longitude: 126.9780);
      final destinations = List.generate(1000, (i) =>
        LatLng(
          latitude: 35 + (i * 0.005),
          longitude: 125 + (i * 0.005),
        ),
      );
      
      // When
      final stopwatch = Stopwatch()..start();
      
      final distances = destinations.map((d) => 
        origin.distanceTo(d)
      ).toList();
      
      stopwatch.stop();
      
      // Then
      expect(distances.length, equals(1000));
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });
  });
}
```

## 📝 테스트 작성 가이드라인

### 1. 모델 테스트 패턴
```dart
group('ModelName 테스트', () {
  test('생성자 테스트', () {
    // Given - 입력 데이터
    // When - 모델 생성
    // Then - 필드 검증
  });
  
  test('직렬화 테스트', () {
    // Given - 모델 인스턴스
    // When - toJson()
    // Then - JSON 구조 검증
  });
  
  test('역직렬화 테스트', () {
    // Given - JSON 데이터
    // When - fromJson()
    // Then - 모델 필드 검증
  });
  
  test('유효성 검사', () {
    // Given - 잘못된 데이터
    // When/Then - 예외 발생 검증
  });
});
```

### 2. Equality 테스트
```dart
test('동일성 비교가 올바르게 작동해야 함', () {
  final model1 = MyModel(id: '1', value: 'test');
  final model2 = MyModel(id: '1', value: 'test');
  final model3 = MyModel(id: '2', value: 'test');
  
  expect(model1, equals(model2));
  expect(model1.hashCode, equals(model2.hashCode));
  expect(model1, isNot(equals(model3)));
});
```

### 3. Edge Case 처리
```dart
test('경계값을 올바르게 처리해야 함', () {
  // 최소값
  expect(() => LatLng(latitude: -90, longitude: -180), returnsNormally);
  
  // 최대값
  expect(() => LatLng(latitude: 90, longitude: 180), returnsNormally);
  
  // 경계 초과
  expect(() => LatLng(latitude: 91, longitude: 180), throwsArgumentError);
});
```

## 🔧 테스트 도구 설정

### 필요한 패키지
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  faker: ^2.1.0  # 테스트 데이터 생성
```

### 테스트 데이터 생성
```dart
import 'package:faker/faker.dart';

final faker = Faker();

Place generateTestPlace() {
  return Place(
    id: faker.guid.guid(),
    name: faker.company.name(),
    location: LatLng(
      latitude: faker.randomGenerator.decimal(min: -90, max: 90),
      longitude: faker.randomGenerator.decimal(min: -180, max: 180),
    ),
    address: faker.address.streetAddress(),
    rating: faker.randomGenerator.decimal(min: 1, max: 5, scale: 1),
  );
}
```

## 📊 커버리지 목표

| 구분 | 목표 커버리지 | 우선순위 |
|-----|------------|---------|
| 생성자 | 100% | Critical |
| 직렬화 | 100% | Critical |
| 유효성 검사 | 100% | High |
| 헬퍼 메서드 | 95% | Medium |
| 성능 | 80% | Low |

## ✅ 체크리스트

### 작성 전
- [ ] 모델 스펙 확인
- [ ] 테스트 데이터 준비
- [ ] Edge case 목록 작성

### 작성 중
- [ ] 모든 필드 테스트
- [ ] Null safety 검증
- [ ] 경계값 테스트
- [ ] 성능 측정

### 작성 후
- [ ] 커버리지 100%
- [ ] 문서화
- [ ] 리뷰

## 🚀 실행 명령어

```bash
# 모델 테스트만 실행
flutter test test/app/models/

# 커버리지 측정
flutter test --coverage test/app/models/
lcov --remove coverage/lcov.info '*.g.dart' -o coverage/lcov.info
genhtml coverage/lcov.info -o coverage/html

# 성능 테스트
flutter test test/performance/app/models/
```

## 📚 참고 자료

- [Dart 테스트 가이드](https://dart.dev/guides/testing)
- [Effective Dart](https://dart.dev/effective-dart)
- [JSON 직렬화](https://flutter.dev/docs/development/data-and-backend/json)

---

*이 문서는 Models 레이어의 테스트 전략과 구현 방법을 담고 있습니다.*