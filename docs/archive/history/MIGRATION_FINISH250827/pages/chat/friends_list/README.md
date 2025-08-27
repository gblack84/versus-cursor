# 👫 Friends List - 친구 목록 관리 페이지

> Versus Space 앱의 팔로우/팔로워 관계를 기반으로 한 친구 목록 표시 및 관리 페이지

## 📋 개요

FriendsListWidget은 사용자의 친구 목록을 표시하고 관리하는 페이지입니다. Firestore의 friends_list 서브컬렉션을 활용하여 팔로우/팔로워 관계를 추적하고, 상호 팔로우(맞팔로우) 상태를 시각적으로 표시합니다.

### 🎯 주요 목적
- **친구 목록 표시**: 팔로워 중심의 친구 목록 실시간 표시
- **맞팔로우 상태**: 상호 팔로우 관계 시각적 표시
- **최근 상호작용 정렬**: lastInteraction 기준 정렬
- **프로필 미리보기**: 사용자 정보 및 관심사 표시

## 🏗️ 디렉토리 구조

```
/lib/pages/chat/friends_list/
├── friends_list_widget.dart  # 메인 친구 목록 위젯 (262줄)
└── README.md                 # 문서 파일
```

### 📊 코드 통계
- **총 코드 라인**: 262줄
- **파일 수**: 1개
- **주요 위젯**: FriendsListWidget (StatefulWidget)

## 📐 네이밍 컨벤션

### 파일명
- **패턴**: snake_case (Dart 표준)
- **예시**: `friends_list_widget.dart`

### 클래스명
- **패턴**: PascalCase
- **접미사**: `Widget`
- **예시**: `FriendsListWidget`

### 라우트명
- **정적 상수**: `routeName`, `routePath`
- **값**: 'friends_list', '/chat/friends'

### 메서드명
- **패턴**: camelCase
- **접두사**: 
  - `_build`: UI 빌드 메서드
- **예시**: `_buildEmptyState()`, `_buildFriendItem()`, `_buildNotLoggedIn()`

### 변수명
- **패턴**: camelCase
- **예시**: `scaffoldKey`, `friendItem`, `userData`

> 참조: [프로젝트 전체 네이밍 컨벤션](../../../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소

### 1. FriendsListWidget - 메인 친구 목록 위젯 👫

**친구 목록을 표시하는 메인 페이지 위젯**입니다.

#### 주요 기능
- **실시간 스트림**: Firestore `queryFriendsListModel` 스트림 구독
- **정렬**: `lastInteraction` 기준 내림차순 정렬
- **필터링**: `follower == true`인 관계만 표시
- **사용자 정보 로드**: FutureBuilder로 친구 정보 비동기 로드
- **맞팔로우 표시**: `following` 필드로 상호 팔로우 상태 확인

#### 스트림 쿼리
```dart
queryFriendsListModel(
  parent: currentUserReference,  // 현재 사용자의 서브컬렉션
  queryBuilder: (friendsListRecord) => friendsListRecord
    .where('follower', isEqualTo: true)  // 팔로워만
    .orderBy('lastInteraction', descending: true),  // 최근 상호작용순
)
```

#### UI 구성
- **AppBar**: "친구" 타이틀, 친구 추가 버튼 (준비 중)
- **빈 상태**: 친구가 없을 때 안내 메시지
- **리스트 아이템**: 프로필, 이름, 관심사, 맞팔로우 배지

### 2. 친구 아이템 구성 🎨

#### FriendItem 레이아웃
| 요소 | 설명 | 스타일 |
|------|------|--------|
| **프로필 이미지** | 56x56 원형 | photoUrl 또는 기본 아이콘 |
| **사용자명** | displayName | buttonMedium 스타일 |
| **관심사** | 최대 2개 표시 | labelSmall, 회색 |
| **맞팔로우 배지** | following == true | 파란색 배경, 흰색 텍스트 |

#### 데이터 흐름
```dart
1. FriendsListModel (서브컬렉션)
   ├── friendsId: 친구 사용자 ID
   ├── follower: true (나를 팔로우)
   ├── following: true/false (내가 팔로우)
   └── lastInteraction: 마지막 상호작용 시간

2. UsersModel (users 컬렉션)
   ├── displayName: 표시 이름
   ├── photoUrl: 프로필 사진
   └── interests: 관심사 목록
```

### 3. 상태 처리 🎮

#### 로딩 상태
- **표시**: CircularProgressIndicator
- **색상**: VersusColors.primary
- **크기**: 50x50

#### 빈 상태 타입
1. **로그인 필요**: 자물쇠 아이콘 + "로그인이 필요합니다"
2. **친구 없음**: people_outline 아이콘 + "아직 친구가 없습니다"

#### 에러 처리
- **사용자 정보 없음**: 빈 Container 반환
- **프로필 이미지 없음**: 기본 person 아이콘 표시

## 💡 사용 가이드

### 라우팅 설정
```dart
// GoRouter 설정
GoRoute(
  name: FriendsListWidget.routeName,  // 'friends_list'
  path: FriendsListWidget.routePath,  // '/chat/friends'
  builder: (context, state) => const FriendsListWidget(),
)
```

### 네비게이션
```dart
// 친구 목록으로 이동
context.pushNamed('friends_list');
```

### 데이터 구조
```dart
// FriendsListModel 구조 (서브컬렉션)
users/{userId}/friends_list/{docId}
{
  "friendsId": "user123",        // 친구 사용자 ID
  "follower": true,               // 나를 팔로우하는지
  "following": false,             // 내가 팔로우하는지
  "lastInteraction": Timestamp,  // 마지막 상호작용
  "createdAt": Timestamp         // 관계 생성일
}
```

## 🎨 UI/UX 특징

### 디자인 시스템
- **색상**: VersusColors (primary, backgroundPrimary, borderLight 등)
- **타이포그래피**: VersusTextStyles (headingSmall, bodyMedium, labelSmall 등)
- **간격**: VersusSpacing (paddingMD, gapSM, gapXS 등)

### 레이아웃
- **배경색**: VersusColors.backgroundPrimary
- **AppBar**: 흰색 배경, 중앙 정렬 타이틀
- **리스트 아이템**: 흰색 배경 + 하단 보더
- **맞팔로우 배지**: 둥근 모서리, 파란색 배경

### 인터랙션
- **탭 액션**: 프로필 페이지 이동 (준비 중)
- **친구 추가**: 상단 버튼 (준비 중)
- **InkWell 피드백**: 리스트 아이템 탭 리플 효과

## ⚡ 성능 최적화

### 쿼리 최적화
- **인덱스 필요**: follower + lastInteraction 복합 인덱스
- **서브컬렉션 활용**: 사용자별 독립된 친구 목록
- **필터링**: follower=true로 불필요한 데이터 제외

### 렌더링 최적화
- **ListView.builder**: 대량 친구 목록 효율적 렌더링
- **FutureBuilder**: 각 아이템별 독립적 사용자 정보 로드
- **조건부 렌더링**: 맞팔로우 배지 조건부 표시

## 🔒 보안 고려사항

### 구현된 보안
- **사용자별 서브컬렉션**: 각 사용자의 친구 목록 독립 관리
- **읽기 권한**: currentUserReference 기반 접근 제어
- **Firebase Auth**: 인증된 사용자만 접근

### 권장 개선사항
1. **차단 사용자 필터링**: 차단된 사용자 제외
2. **프라이버시 설정**: 친구 목록 공개 범위 설정
3. **Rate Limiting**: 친구 추가/삭제 횟수 제한

## 🐛 알려진 이슈 및 개선사항

### 현재 이슈
1. **프로필 페이지**: "준비 중" 스낵바만 표시
2. **친구 추가 기능**: 미구현 상태
3. **성능 이슈**: 각 아이템마다 별도 사용자 쿼리

### 개선 제안
1. **배치 로드**: 사용자 정보 일괄 로드
2. **캐싱**: UserCacheService 활용
3. **팔로우 해제**: 스와이프 액션 추가
4. **검색 기능**: 친구 검색 필터
5. **그룹화**: 맞팔로우/단방향 팔로우 그룹 분리

## 📊 통계 및 메트릭스

### 성능 지표
| 메트릭 | 목표 | 현재 |
|--------|------|------| 
| 초기 로딩 | <300ms | 측정 필요 |
| 아이템 렌더링 | <50ms | 측정 필요 |
| 메모리 사용 | <30MB | 측정 필요 |

### 의존성
- Flutter SDK
- firebase_auth: 인증
- cloud_firestore: 데이터베이스
- go_router: 네비게이션

## 📝 변경 이력

| 버전 | 날짜 | 변경사항 | 작성자 |
|------|------|----------|--------|
| 1.0.0 | 2025-08-23 | 초기 문서 작성 | AI Assistant |
| 0.9.0 | 2025-08-22 | FriendsListWidget 구현 | 개발팀 |

---

*이 문서는 Versus Space 프로젝트의 친구 목록 페이지를 설명합니다.*
*FriendsListWidget은 팔로우/팔로워 관계 기반 친구 목록을 관리합니다.*
*마지막 업데이트: 2025-08-23*
