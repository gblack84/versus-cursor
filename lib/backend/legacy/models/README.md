# 📊 Backend Models 레이어

> Versus Space 앱의 데이터 모델 레이어  
> 최종 업데이트: 2025-08-28 | 버전: 2.0.0

## 📋 개요

Backend Models 레이어는 Firestore 스키마를 Dart 모델로 매핑하는 데이터 모델 계층입니다. FirestoreRecord를 상속받아 CRUD 작업을 지원하고, 타입 안전성과 직렬화/역직렬화 기능을 제공합니다.

## 🏗️ 현재 디렉토리 구조

```
/lib/backend/models/
├── README.md                           # 이 문서
├── index.dart                          # 4줄 - Export 파일
├── chat/
│   └── messages_model.dart            # 650줄 - 채팅 메시지 모델
├── transaction/
│   ├── point_model.dart               # (미분석) - 포인트 트랜잭션
│   └── transactions_model.dart        # (미분석) - 일반 트랜잭션
├── post/
│   ├── posts_model.dart               # 700줄 - 게시물 모델
│   ├── comments_model.dart            # (미분석) - 댓글 모델
│   ├── likes_model.dart               # (미분석) - 좋아요 모델
│   └── shares_model.dart              # (미분석) - 공유 모델
├── user/
│   ├── users_model.dart               # 485줄 - 사용자 모델
│   └── settings_model.dart            # (미분석) - 설정 모델
├── shared/
│   ├── client_model.dart              # (미분석) - 클라이언트 정보
│   └── contents_interests_model.dart  # (미분석) - 콘텐츠 관심사
├── feed/
│   ├── feed_details_model.dart        # (미분석) - 피드 상세
│   └── poll_details_model.dart        # (미분석) - 투표 상세
└── media/
    ├── image_moderation_model.dart    # (미분석) - 이미지 검열
    ├── images_model.dart               # (미분석) - 이미지 정보
    └── video_model.dart                # (미분석) - 비디오 정보
```

## 📊 구현 상태 분석

| 컴포넌트 | 파일 | 줄 수 | 상태 | 문제점 |
|---------|------|-------|------|--------|
| **사용자 모델** | users_model.dart | 485 | 🟢 작동중 | Backward compatibility 코드 잔재 |
| **게시물 모델** | posts_model.dart | 700 | 🟢 작동중 | 필드 과다 (60+개), 투표 시스템 복잡 |
| **메시지 모델** | messages_model.dart | 650 | 🟢 작동중 | JSON 직렬화 혼재, 투표 카드 복잡성 |
| **Export 인덱스** | index.dart | 4 | 🔴 불완전 | 모델 export 누락 |

## 🔍 코드 상세 분석

### 1. index.dart (Export 관리)

#### 현재 구현
```dart
export 'package:cloud_firestore/cloud_firestore.dart' hide Order;
export 'package:flutter/material.dart' show Color, Colors;
export '/app/models/lat_lng.dart';
```

#### 문제점
- **모델 Export 누락**: 실제 모델 파일들이 export되지 않음
- **패키지 Export**: 이곳이 아닌 별도 파일에서 관리해야 함
- **불명확한 책임**: Export 파일의 역할 모호

### 2. users_model.dart (사용자 모델)

#### 핵심 구조
```dart
class UsersModel extends FirestoreRecord {
  // 기본 정보
  String get uid => _uid ?? '';
  String get email => _email ?? '';
  String get displayName => _displayName ?? '';
  
  // 포인트 시스템
  int get pointsA => _pointsA ?? 0;  // 답변 포인트
  int get pointsQ => _pointsQ ?? 0;  // 질문 포인트
  
  // 관심사
  List<String> get interests => _interests ?? const [];
  List<String> get expertise => _expertise ?? const [];
  
  // 랭킹 시스템
  String get currentRank => _currentRank ?? '';
  String get currentTitle => _currentTitle ?? '';
  
  // 소셜 기능
  List<String> get friends => _friends ?? const [];
  List<String> get activeChats => _activeChats ?? const [];
}
```

#### 특징
- **필드 수**: 40개의 필드 (너무 많음)
- **Null 안전성**: 모든 필드에 기본값 제공
- **타입 변환**: castToType 사용으로 안전한 타입 캐스팅
- **Backward Compatibility**: `@Deprecated` 어노테이션 사용

#### 문제점
```dart
// Deprecated 코드가 여전히 존재
@Deprecated('Use isPremiumUser instead')
bool get isPrmiumUser => isPremiumUser;  // 오타 수정용 호환성

@Deprecated('Use friends instead')
List<String> get frinds => friends;  // 오타 수정용 호환성
```

### 3. posts_model.dart (게시물 모델)

#### 복잡한 구조
```dart
class PostsModel extends FirestoreRecord {
  // 기본 정보 (10개 필드)
  String get userid => _userid ?? '';
  String get content => _content ?? '';
  
  // 상호작용 카운트 (7개 필드)
  int get likecount => _likecount ?? 0;
  int get commentcount => _commentcount ?? 0;
  
  // 투표 시스템 (28개 필드!)
  DateTime? get voteStartTime => _voteStartTime;
  DateTime? get voteEndTime => _voteEndTime;
  String get voteStatus => _voteStatus ?? '';
  bool get voteCompleted => _voteCompleted ?? false;
  
  // 중첩 구조 (Map 타입)
  Map<String, dynamic> get optionA => _optionA ?? const {};
  Map<String, dynamic> get optionB => _optionB ?? const {};
  Map<String, dynamic> get targetAudience => _targetAudience ?? const {};
}
```

#### 문제점
- **과도한 필드**: 60개 이상의 필드 (단일 책임 원칙 위반)
- **중첩 Map**: 타입 안전성 부족
- **투표 시스템 복잡도**: 28개의 투표 관련 필드
- **네이밍 불일치**: `userid` vs `uid` 혼재

### 4. messages_model.dart (메시지 모델)

#### 특수 기능
```dart
class MessagesModel extends FirestoreRecord {
  // JSON 직렬화 지원 (캐싱용)
  Map<String, dynamic> toJson() { ... }
  factory MessagesModel.fromJson(Map<String, dynamic> json) { ... }
  
  // 투표 카드 시스템
  Map<String, dynamic> get userVotes => _userVotes ?? const {};
  
  // 헬퍼 메서드
  bool checkUserVoted(String userId) {
    return _userVotes?.containsKey(userId) ?? false;
  }
  
  String? getUserVoteChoice(String userId) {
    final vote = getUserVote(userId);
    return vote?['option'] as String?;
  }
}
```

#### 특징
- **JSON 직렬화**: 캐싱 시스템 지원
- **DateTime 파싱**: 다양한 형식 지원 (int, Timestamp, String, DateTime)
- **투표 시스템**: 개별 사용자별 투표 추적
- **Deprecated 필드**: 호환성 유지

## 🚨 주요 문제점

### 1. 구조적 문제 🔴 심각
```dart
// 60개 이상의 필드를 가진 단일 모델
class PostsModel extends FirestoreRecord {
  // 너무 많은 책임...
}
```
**영향**: 유지보수 어려움, 테스트 복잡도 증가

### 2. Feature-First Architecture 위반 🔴 심각
```
현재: /lib/backend/models/ (중앙집중식)
올바른: /lib/features/*/domain/models/ (Feature별)
```
**영향**: Feature 간 불필요한 의존성

### 3. 타입 안전성 부족 🟡 중간
```dart
// Map<String, dynamic> 사용
Map<String, dynamic> get optionA => _optionA ?? const {};
Map<String, dynamic> get stats => _stats ?? const {};
```
**영향**: 런타임 에러 가능성

### 4. 중복 코드 🟡 중간
```dart
// 모든 모델에 반복되는 패턴
bool hasUid() => _uid != null;
String get uid => _uid ?? '';
```
**영향**: 코드 중복, DRY 원칙 위반

### 5. Export 관리 실패 🟡 중간
```dart
// index.dart가 모델을 export하지 않음
export 'package:cloud_firestore/cloud_firestore.dart';
// 모델 export 누락
```
**영향**: 사용처에서 직접 import 필요

## 📦 사용처 분석

### users_model.dart
- **사용처**: 
  - `/lib/features/auth/` - 인증 및 프로필
  - `/lib/features/profile/` - 사용자 프로필 표시
  - `/lib/services/user_cache_service.dart` - 캐싱
- **의존성**: FirestoreRecord, LatLng

### posts_model.dart
- **사용처**:
  - `/lib/features/posts/` - 게시물 CRUD
  - `/lib/features/voting/` - 투표 시스템
  - `/lib/features/feed/` - 피드 표시
- **의존성**: FirestoreRecord, 투표 시스템

### messages_model.dart
- **사용처**:
  - `/lib/features/chat/` - 채팅 기능
  - `/lib/services/cache/` - 메시지 캐싱
  - `/lib/components/chat/` - 채팅 UI
- **의존성**: JSON 직렬화, FirestoreRecord

## 🎯 Feature-First Architecture 관점

### 현재 구조의 문제점
1. **중앙집중식 모델**: 모든 Feature가 하나의 모델 디렉토리에 의존
2. **과도한 결합**: Feature 간 불필요한 의존성 발생
3. **확장성 제한**: 새 Feature 추가 시 기존 모델 수정 필요
4. **테스트 어려움**: 모델이 너무 크고 복잡

### 올바른 구조
```
/lib/features/
├── auth/
│   └── domain/
│       └── models/
│           └── user_model.dart      # 인증 관련 필드만
├── profile/
│   └── domain/
│       └── models/
│           └── profile_model.dart   # 프로필 표시용
├── posts/
│   └── domain/
│       └── models/
│           ├── post_model.dart      # 기본 게시물
│           └── post_stats.dart      # 통계 분리
└── voting/
    └── domain/
        └── models/
            └── vote_model.dart       # 투표 전용
```

## 🔧 사용 방법

### 모델 생성
```dart
// Firestore 문서에서 모델 생성
final userDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .get();
final user = UsersModel.fromSnapshot(userDoc);
```

### 모델 사용
```dart
// 필드 접근
print(user.displayName);
print(user.pointsA);

// null 체크
if (user.hasPhotoUrl()) {
  showImage(user.photoUrl);
}
```

### JSON 직렬화 (메시지만)
```dart
// 캐싱용 직렬화
final json = message.toJson();
await cache.save('message_$id', json);

// 역직렬화
final cached = await cache.get('message_$id');
final message = MessagesModel.fromJson(cached);
```

## 📊 메트릭

| 지표 | 현재 | 목표 |
|-----|------|------|
| **코드 라인 수** | ~2,500줄 | 3,000줄+ |
| **테스트 커버리지** | 0% | 80% |
| **타입 안전성** | 60% | 95% |
| **Feature 분리** | ❌ | ✅ |
| **코드 중복** | 30% | <5% |

## 🔗 관련 문서

- [Backend 전체 구조](../README.md)
- [Firebase 설정](../firebase/README.md)
- [Feature-First Architecture](/FEATURE_ARCHITECTURE.md)
- [마이그레이션 계획](./MIGRATION_Part3.md)
- [테스트 가이드](./TEST.md)

## ⚠️ 주의사항

1. **모델 크기**: PostsModel처럼 60개 이상 필드 지양
2. **타입 안전성**: Map<String, dynamic> 대신 구체적 타입 사용
3. **Feature 분리**: 각 Feature에 필요한 필드만 포함
4. **버전 관리**: Deprecated 코드는 다음 메이저 버전에서 제거

---

*이 문서는 Backend Models 레이어의 현재 구현 상태와 개선 방향을 설명합니다.*