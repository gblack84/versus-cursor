# 🏠 Home Page - 메인 피드 화면

> Versus Space 앱의 중심이 되는 메인 피드 화면으로, 사용자들이 작성한 A vs B 형식의 투표 게시물을 실시간으로 보여주는 홈 화면입니다.

## 📋 개요

Home Page는 Versus Space 앱의 메인 진입점으로, 최신 투표 게시물들을 실시간 스트림으로 표시하는 핵심 화면입니다. Firebase Firestore와 연동하여 실시간 업데이트를 제공하며, 3-Layer 캐싱 시스템을 통해 최적화된 성능을 보장합니다.

### 🎯 주요 목적
- **실시간 피드**: 최신 게시물 실시간 업데이트
- **사용자 참여**: A vs B 형식의 투표 콘텐츠 제공
- **성능 최적화**: 캐싱 및 프리로드 전략
- **직관적 UI**: 디자인 시스템 적용

## 🏗️ 디렉토리 구조

```
/lib/pages/home/
├── home_page_widget.dart         # 메인 홈 화면 위젯 (343줄)
├── home_page_widget_model.dart    # 홈 페이지 모델 (11줄)
└── README.md                     # 문서 파일
```

### 📊 코드 통계
- **총 코드 라인**: 354줄
- **파일 수**: 2개
- **주요 컴포넌트**: HomePageWidget, HomePageModel
- **의존성**: 6개 (Flutter, Core, Components, Backend, Design System, Services)

## 📐 네이밍 컨벤션

### 파일명
- **패턴**: snake_case (Dart 표준)
- **접미사**: `_widget`, `_model`
- **예시**: `home_page_widget.dart`

### 클래스명
- **패턴**: PascalCase
- **접미사**: `Widget`, `Model`
- **예시**: `HomePageWidget`, `HomePageModel`

### 라우팅
- **routeName**: camelCase (`'homePage'`)
- **routePath**: kebab-case (`'/home'`)

### 변수 및 메서드
- **패턴**: camelCase
- **예시**: `scaffoldKey`, `_buildVersusCard()`

> 참조: [프로젝트 전체 네이밍 컨벤션](../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소

### 1. HomePageWidget - 메인 위젯 🏠

**앱의 메인 피드를 표시하는 StatefulWidget입니다.**

#### 라우팅 정보
```dart
static String routeName = 'homePage';
static String routePath = '/home';
```

#### 주요 기능
- **실시간 스트림**: Firebase Firestore 연동
- **캐싱 통합**: UnifiedCacheService 활용
- **알림 배지**: NotificationBadgeProvider 연동
- **게시물 카드**: A vs B 투표 카드 렌더링

#### 초기화 프로세스
```dart
@override
void initState() {
  super.initState();
  
  // 백그라운드에서 인기 게시물 프리로드
  Future.microtask(() async {
    try {
      await UnifiedCacheService.instance.preloadPopularPosts();
      debugPrint('[HomePage] Popular posts preloaded successfully');
    } catch (e) {
      debugPrint('[HomePage] Failed to preload popular posts: $e');
    }
  });
}
```

### 2. Firebase 실시간 피드 시스템 🔥

**Firestore 스트림을 통해 실시간 게시물 업데이트를 제공합니다.**

#### 스트림 구성
```dart
StreamBuilder<List<PostsModel>>(
  stream: FirebaseFirestore.instance
      .collection('posts')
      .orderBy('createdAt', descending: true)  // 최신순 정렬
      .limit(20)                               // 성능 최적화
      .snapshots()
      .map((snapshot) => 
          snapshot.docs.map((doc) => PostsModel.fromSnapshot(doc)).toList()),
  builder: (context, snapshot) { ... }
)
```

#### 데이터 구조
| 속성 | 타입 | 설명 |
|------|------|------|
| `collection` | String | `'posts'` 컬렉션 |
| `orderBy` | Field | `createdAt` 내림차순 |
| `limit` | int | 최대 20개 |
| `model` | Class | `PostsModel` |

### 3. 게시물 카드 디자인 시스템 🎨

**디자인 토큰을 활용한 일관된 UI 구성입니다.**

#### 카드 구조
1. **사용자 정보 섹션**
   - `CircleAvatar`: 프로필 이미지 (20px radius)
   - `displayName`: 사용자명 (익명 지원)
   - `dateTimeFormat`: 상대 시간 표시

2. **콘텐츠 섹션**
   - `questionTitle`: 질문 제목 (최대 2줄)
   - `optionA/optionB`: A vs B 옵션 박스

3. **상호작용 섹션**
   - `participantcount`: 투표 참여자 수
   - `commentcount`: 댓글 수
   - `likecount`: 좋아요 수

#### 디자인 토큰 적용
```dart
Container(
  decoration: BoxDecoration(
    color: VersusColors.backgroundSecondary,
    borderRadius: VersusRadius.card,
    boxShadow: [
      BoxShadow(
        color: VersusColors.blackWithAlpha(0.05),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Padding(
    padding: VersusSpacing.paddingMD,
    child: // 카드 콘텐츠
  ),
)
```

### 4. 빈 상태 UI 처리 📭

**게시물이 없을 때 사용자 친화적인 안내를 제공합니다.**

```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.post_add, size: 64, color: VersusColors.textSecondary),
      SizedBox(height: 16),
      Text('아직 게시물이 없습니다', style: VersusTextStyles.headingMedium),
      Text('첫 번째 질문을 작성해보세요!', style: VersusTextStyles.bodyMedium),
    ],
  ),
)
```

### 5. HomePageModel - 상태 관리 🔄

**AppModel을 상속받는 기본 상태 관리 클래스입니다.**

```dart
class HomePageModel extends AppModel<HomePageWidget> {
  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
```

#### 확장 가능성
- 필터링 상태 관리
- 검색 기능 추가
- 페이지네이션 상태
- 사용자 설정 관리

## 💡 사용 가이드

### 네비게이션
```dart
// 홈 페이지로 이동
context.pushNamed('homePage');

// 알림 목록으로 이동
context.pushNamed('notificationsList');
```

### 캐싱 전략
```dart
// 1. 앱 시작 시 프리로드
await UnifiedCacheService.instance.preloadPopularPosts();

// 2. 실시간 스트림 데이터
StreamBuilder로 자동 업데이트

// 3. 이미지 캐싱
NetworkImage 자동 캐싱 활용
```

## 🎨 디자인 시스템

### 색상 팔레트
| 요소 | 토큰 | 값 |
|------|------|-----|
| **배경** | `VersusColors.backgroundPrimary` | 베이지 |
| **카드** | `VersusColors.backgroundSecondary` | 연한 베이지 |
| **A 옵션** | `VersusColors.primary` | 빨간색 |
| **B 옵션** | `VersusColors.secondary` | 초록색 |
| **텍스트** | `VersusColors.textPrimary/Secondary` | 검정/회색 |

### 간격 시스템
| 용도 | 토큰 | 값 |
|------|------|-----|
| **카드 패딩** | `VersusSpacing.paddingMD` | 16px |
| **카드 간격** | `VersusSpacing.sm` | 8px |
| **내부 간격** | `VersusSpacing.gapMD` | 16px |
| **작은 간격** | `VersusSpacing.xs` | 4px |

### 텍스트 스타일
| 용도 | 스타일 | 특징 |
|------|--------|------|
| **제목** | `VersusTextStyles.headingMedium` | 볼드, 18px |
| **본문** | `VersusTextStyles.bodyMedium` | 일반, 14px |
| **레이블** | `VersusTextStyles.bodySmall` | 작은, 12px |

## 🚀 성능 최적화

### 데이터 로딩 전략
1. **제한적 로딩**: 최대 20개 게시물만 로드
2. **스트림 빌더**: 효율적인 실시간 업데이트
3. **백그라운드 프리로드**: 인기 게시물 사전 캐싱

### 이미지 최적화
- **NetworkImage**: 자동 메모리 캐싱
- **CircleAvatar**: 효율적인 원형 이미지 렌더링
- **기본 아이콘**: 이미지 없을 시 아이콘 대체

### 메모리 관리
- **ListView.builder**: 화면에 보이는 항목만 렌더링
- **제한된 아이템 수**: 메모리 사용량 제한
- **캐시 전략**: 3-Layer 캐싱 시스템 활용

### 성능 지표
| 지표 | 목표 | 현재 |
|------|------|------|
| **초기 로드** | <500ms | ✅ 캐시 히트 시 <10ms |
| **스크롤 성능** | 60fps | ✅ ListView.builder 최적화 |
| **메모리 사용** | <50MB | ✅ 제한된 아이템 수 |

## 📚 의존성

```dart
import 'package:flutter/material.dart';
import '/core/app_utils.dart';
import '/components/notifications/notification_badge_provider.dart';
import '/backend/backend.dart';
import '/design_system/design_system.dart';
import '/services/cache/unified_cache_service.dart';
```

## 🔧 개선 사항 (TODO)

### 우선순위 높음
1. **무한 스크롤**: 페이지네이션 구현
2. **게시물 상세**: 클릭 시 상세 페이지 이동

### 우선순위 중간
3. **필터링**: 카테고리별, 인기순 정렬
4. **검색**: 게시물 검색 기능

### 우선순위 낮음
5. **풀 투 리프레시**: 수동 새로고침
6. **캐시 전략**: 더 정교한 캐싱 로직

## 📅 변경 이력

| 날짜 | 버전 | 변경 내용 | 작업자 |
|------|------|----------|--------|
| 2025-08-23 | v2.0.0 | README 문서 전체 개편 (services 형식 적용) | AI Assistant |
| 2025-08-13 | v1.2.0 | 3-Layer 캐싱 시스템 통합 | 개발팀 |
| 2025-07-25 | v1.1.0 | 디자인 시스템 적용 완료 | 개발팀 |
| 2025-07-25 | v1.0.0 | Firebase Firestore 실시간 피드 구현 | 개발팀 |

## 🔗 관련 문서

- [전체 Pages 구조](../README.md)
- [PostsModel 문서](../../backend/schema/README.md)
- [디자인 시스템](../../design_system/README.md)
- [캐싱 서비스](../../services/cache/README.md)
- [알림 시스템](../../components/notifications/README.md)

---

*이 문서는 Versus Space 앱의 홈 페이지 구현을 상세히 설명합니다.*
*최종 업데이트: 2025-08-23*