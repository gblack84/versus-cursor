# 👥 Chat Search - 친구 검색 및 추천 페이지

> Versus Space 앱의 친구 검색 및 추천 기능을 제공하는 페이지 컴포넌트

## 📋 개요

ChatSearchWidget은 사용자가 다른 사용자를 검색하고 추천받을 수 있는 친구 검색 페이지입니다. 실시간 검색 기능과 함께 인기도 기반 추천 시스템을 제공하며, 향후 팔로우 기능 연동을 준비하고 있습니다.

### 🎯 주요 목적
- **친구 검색**: 실시간 displayName 기반 사용자 검색
- **인기 기반 추천**: totalAPoints 기준 상위 20명 추천
- **프로필 미리보기**: 사용자 정보 및 관심사 표시
- **팔로우 준비**: 향후 소셜 네트워크 기능 확장 대비

## 🏗️ 디렉토리 구조

```
/lib/pages/chat/chat_search/
├── chat_search_widget.dart  # 메인 친구 검색 위젯 (342줄)
└── README.md                # 문서 파일
```

### 📊 코드 통계
- **총 코드 라인**: 342줄
- **파일 수**: 1개
- **주요 위젯**: ChatSearchWidget (StatefulWidget)

## 📐 네이밍 컨벤션

### 파일명
- **패턴**: snake_case (Dart 표준)
- **예시**: `chat_search_widget.dart`

### 클래스명
- **패턴**: PascalCase
- **접미사**: `Widget`
- **예시**: `ChatSearchWidget`

### 라우트명
- **정적 상수**: `routeName`, `routePath`
- **값**: 'chat_search', '/chat/search'

### 메서드명
- **패턴**: camelCase
- **접두사**: 
  - `_build`: UI 빌드 메서드
- **예시**: `_buildRecommendations()`, `_buildSearchResults()`, `_buildUserItem()`

### 변수명
- **패턴**: camelCase
- **예시**: `scaffoldKey`, `_searchController`, `searchQuery`

> 참조: [프로젝트 전체 네이밍 컨벤션](../../../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소

### 1. ChatSearchWidget - 메인 검색 위젯 👥

**친구 검색과 추천을 담당하는 메인 페이지 위젯**입니다.

#### 주요 기능
- **실시간 검색**: TextField 입력값 변경 시 즉시 필터링
- **추천 시스템**: totalAPoints 기준 상위 20명 표시
- **사용자 필터링**: 현재 사용자 제외 (`uid != currentUserUid`)
- **프로필 미리보기**: 이름, 프로필 사진, 관심사 표시

#### 검색 쿼리
```dart
// 추천 쿼리
queryUsersModel(
  queryBuilder: (usersRecord) => usersRecord
    .where('uid', isNotEqualTo: currentUserUid)
    .orderBy('uid')
    .orderBy('totalAPoints', descending: true)
    .limit(20),
)

// 검색 쿼리 (클라이언트 필터링)
.where((user) => 
  user.displayName.toLowerCase().contains(searchQuery)
)
```

#### UI 구성
- **AppBar**: "친구 추천" 타이틀
- **검색 바**: 상단 고정, 둥근 모서리 디자인
- **결과 리스트**: 조건부 렌더링 (추천/검색 결과)
- **빈 상태**: 검색 결과 없음, 추천 없음, 로그인 필요

### 2. 검색 시스템 🔍

#### 검색 모드 전환
```dart
_searchController.text.isEmpty
  ? _buildRecommendations()  // 추천 모드
  : _buildSearchResults()     // 검색 모드
```

#### 검색 특징
- **대소문자 무시**: toLowerCase() 적용
- **부분 일치**: contains() 메서드 사용
- **실시간 업데이트**: onChanged에서 setState 호출
- **클라이언트 필터링**: 모든 사용자 로드 후 필터

### 3. 사용자 아이템 UI 🎨

#### UserItem 구성
| 요소 | 설명 | 스타일 |
|------|------|--------|
| **프로필 이미지** | 56x56 원형 | photoUrl 또는 기본 아이콘 |
| **사용자명** | displayName | buttonMedium 스타일 |
| **관심사** | 최대 2개 표시 | labelSmall, 회색 |
| **팔로우 버튼** | 준비 중 | VersusButton.small |

#### 상호작용
- **탭 액션**: 프로필 페이지 이동 (준비 중)
- **팔로우 버튼**: 팔로우 기능 (준비 중)
- **스낵바 알림**: 미구현 기능 안내

### 4. 상태 처리 🎮

#### 로딩 상태
- **표시**: CircularProgressIndicator
- **색상**: VersusColors.primary
- **크기**: 50x50

#### 빈 상태 타입
1. **로그인 필요**: 자물쇠 아이콘 + "로그인이 필요합니다"
2. **추천 없음**: person_search 아이콘 + "추천할 친구가 없습니다"
3. **검색 결과 없음**: search_off 아이콘 + "검색 결과가 없습니다"

## 💡 사용 가이드

### 라우팅 설정
```dart
// GoRouter 설정
GoRoute(
  name: ChatSearchWidget.routeName,  // 'chat_search'
  path: ChatSearchWidget.routePath,  // '/chat/search'
  builder: (context, state) => const ChatSearchWidget(),
)
```

### 네비게이션
```dart
// 친구 검색으로 이동
context.pushNamed('chat_search');
```

## 🎨 UI/UX 특징

### 디자인 시스템
- **색상**: VersusColors (primary, backgroundPrimary, borderLight 등)
- **타이포그래피**: VersusTextStyles (headingSmall, bodyMedium, labelSmall 등)
- **간격**: VersusSpacing (paddingMD, gapSM, gapXS 등)
- **버튼**: VersusButton 컴포넌트 사용

### 레이아웃
- **배경색**: VersusColors.backgroundPrimary
- **AppBar**: 흰색 배경, 중앙 정렬 타이틀
- **검색 바**: 흰색 컨테이너 + 회색 입력 필드
- **리스트 아이템**: 흰색 배경 + 하단 보더

### 인터랙션
- **실시간 검색**: 입력 즉시 결과 업데이트
- **InkWell 피드백**: 리스트 아이템 탭 리플 효과
- **스낵바 알림**: 미구현 기능 안내

## ⚡ 성능 최적화

### 쿼리 최적화
- **인덱스 필요**: uid + totalAPoints 복합 인덱스
- **제한적 로드**: limit(20)으로 초기 로드 제한
- **스트림 구독**: StreamBuilder로 실시간 업데이트

### 렌더링 최적화
- **ListView.builder**: 대량 사용자 목록 효율적 렌더링
- **조건부 렌더링**: 검색/추천 모드 별도 처리
- **이미지 최적화**: NetworkImage 사용 (캐싱 가능)

## 🔒 보안 고려사항

### 구현된 보안
- **사용자 필터링**: 본인 제외 표시
- **읽기 전용**: 사용자 정보 읽기만 가능
- **Firebase Auth**: currentUserUid 사용

### 권장 개선사항
1. **검색 제한**: Rate limiting 구현
2. **프라이버시**: 차단된 사용자 필터링
3. **이미지 캐싱**: CachedNetworkImage 사용 권장

## 🐛 알려진 이슈 및 개선사항

### 현재 이슈
1. **프로필 페이지**: "준비 중" 스낵바만 표시
2. **팔로우 기능**: 미구현 상태
3. **검색 성능**: 클라이언트 필터링으로 비효율적

### 개선 제안
1. **서버 검색**: Algolia 또는 Firestore 쿼리 개선
2. **무한 스크롤**: 추천 목록 페이지네이션
3. **검색 기록**: 최근 검색어 저장
4. **친구 상태**: 이미 친구인 사용자 표시
5. **온라인 상태**: 활동 상태 표시

## 📊 통계 및 메트릭스

### 성능 지표
| 메트릭 | 목표 | 현재 |
|--------|------|------| 
| 초기 로딩 | <300ms | 측정 필요 |
| 검색 응답 | <100ms | 측정 필요 |
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
| 0.9.0 | 2025-08-22 | ChatSearchWidget 구현 | 개발팀 |

---

*이 문서는 Versus Space 프로젝트의 친구 검색 페이지를 설명합니다.*
*ChatSearchWidget은 사용자 검색과 추천 기능을 제공합니다.*
*마지막 업데이트: 2025-08-23*
