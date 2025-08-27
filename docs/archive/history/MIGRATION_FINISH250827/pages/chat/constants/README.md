# 🔧 Chat Constants - 채팅 시스템 상수 관리

> Versus Space 앱의 채팅 시스템에서 사용되는 모든 상수를 중앙 관리하는 모듈

## 📋 개요

ChatConstants는 채팅 시스템 전반에서 사용되는 상수를 중앙에서 관리하는 유틸리티 클래스입니다. 메시지 로딩, 애니메이션, 투표 카드, 캐시, UI 크기 등 다양한 설정값을 체계적으로 관리하여 일관성 있는 사용자 경험을 제공합니다.

### 🎯 주요 목적
- **중앙 집중식 상수 관리**: 모든 채팅 관련 상수를 한 곳에서 관리
- **타입 안전성**: 강타입 정적 상수로 컴파일 시점 오류 방지
- **유지보수성**: 값 변경 시 한 곳에서만 수정
- **일관성**: 전체 채팅 시스템에서 동일한 값 사용 보장

## 🏗️ 디렉토리 구조

```
/lib/pages/chat/constants/
├── chat_constants.dart  # 채팅 시스템 상수 클래스 (119줄)
└── README.md            # 문서 파일
```

### 📊 코드 통계
- **총 코드 라인**: 119줄
- **파일 수**: 1개
- **상수 그룹**: 10개 카테고리
- **정의된 상수**: 42개

## 📐 네이밍 컨벤션

### 파일명
- **패턴**: snake_case (Dart 표준)
- **예시**: `chat_constants.dart`

### 클래스명
- **패턴**: PascalCase
- **접미사**: `Constants`
- **예시**: `ChatConstants`

### 상수명
- **패턴**: lowerCamelCase (Dart const 표준)
- **그룹화**: 주석으로 카테고리 구분
- **예시**: `initialMessageLoadCount`, `voteColorA`

> 참조: [프로젝트 전체 네이밍 컨벤션](../../../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소

### 1. ChatConstants 클래스 - 채팅 상수 관리 🔧

**Private 생성자를 통한 인스턴스화 방지**로 순수 상수 컨테이너 역할을 수행합니다.

```dart
class ChatConstants {
  ChatConstants._();  // 인스턴스 생성 방지
  
  // 모든 상수는 static const로 정의
}
```

### 2. 메시지 로딩 관련 상수 📥

#### 페이지네이션 설정
| 상수명 | 값 | 용도 |
|--------|-----|------|
| `initialMessageLoadCount` | 30 | 초기 메시지 로드 개수 |
| `paginationMessageCount` | 20 | 추가 로드 시 메시지 개수 |
| `loadMoreThreshold` | 100px | 추가 로드 트리거 스크롤 임계값 |
| `fabShowThreshold` | 500px | FAB 표시/숨김 스크롤 임계값 |

### 3. 애니메이션 관련 상수 ⏱️

#### Duration 설정
```dart
static const Duration fabAnimationDuration = Duration(milliseconds: 200);
static const Duration fabScaleAnimationDuration = Duration(milliseconds: 300);
static const Duration autoScrollDelay = Duration(milliseconds: 100);
static const Duration votingStateResetDelay = Duration(milliseconds: 500);
static const Duration scrollAnimationDuration = Duration(milliseconds: 300);
```

### 4. 투표 카드 스타일 상수 🎨

#### 색상 및 크기
| 상수명 | 값 | 설명 |
|--------|-----|------|
| `voteColorA` | 0xFFFF6B6B | A 옵션 색상 (빨간색) |
| `voteColorB` | 0xFF4ECDC4 | B 옵션 색상 (청록색) |
| `voteCardBorderRadius` | 10.0 | 카드 모서리 반경 |
| `voteOptionBorderRadius` | 7.0 | 옵션 박스 반경 |
| `voteCardDefaultHeight` | 200.0 | 기본 카드 높이 |

### 5. 캐시 관련 상수 💾

#### 사용자 캐시 설정
```dart
static const int userCacheKeepCount = 100;  // 캐시 유지 사용자 수
static const int userLoadingTimeoutIterations = 50;  // 타임아웃 반복 횟수
static const Duration userLoadingCheckInterval = Duration(milliseconds: 100);
```

### 6. 메시지 타입 상수 📝

#### 타입 식별자
```dart
static const String messageTypeText = 'text';
static const String messageTypeImage = 'image';
static const String messageTypeVoteRequest = 'voteRequest';
static const String messageTypeVoteCreated = 'voteCreated';
static const String messageTypeSystem = 'system';
```

### 7. 투표 상태 상수 🗳️

#### 카드 상태
```dart
static const String cardStatusVotingRequest = 'votingRequest';
static const String cardStatusVoting = 'voting';
static const String cardStatusCompleted = 'completed';
```

### 8. AI 사용자 정보 🤖

#### AI 피클 설정
| 상수명 | 값 | 용도 |
|--------|-----|------|
| `aiUserId` | 'ai_assistant' | AI 사용자 ID |
| `aiUserName` | 'AI 피클' | AI 표시 이름 |
| `aiUserAvatar` | picsum URL | AI 프로필 이미지 |

### 9. UI 크기 상수 📏

#### 레이아웃 설정
```dart
static const double messageCardWidthRatio = 0.92;  // 화면 대비 92%
static const double profileAvatarRadius = 20.0;    // 프로필 원형 반경
static const double statusBadgeIconSize = 12.0;    // 상태 배지 크기
static const double multiImageIndicatorIconSize = 12.0;  // 멀티이미지 표시
```

### 10. 텍스트 상수 💬

#### UI 문자열
```dart
static const String unreadMessagesText = '읽지 않은 메시지';
static const String voteCompletedText = '피클! 피클! 피클!';
static const String unknownUserText = '알 수 없는 사용자';
static const String defaultUserName = 'User';
```

## 💡 사용 가이드

### 상수 사용 예시
```dart
// 메시지 로딩
final messages = await loadMessages(
  limit: ChatConstants.initialMessageLoadCount,
);

// 애니메이션 적용
AnimatedContainer(
  duration: ChatConstants.fabAnimationDuration,
  // ...
);

// 투표 카드 스타일
Container(
  decoration: BoxDecoration(
    color: isOptionA ? ChatConstants.voteColorA : ChatConstants.voteColorB,
    borderRadius: BorderRadius.circular(ChatConstants.voteCardBorderRadius),
  ),
);

// AI 사용자 체크
if (userId == ChatConstants.aiUserId) {
  return ChatConstants.aiUserName;
}
```

### 상수 추가 가이드
```dart
// 1. 적절한 카테고리 섹션 찾기
// 2. 의미 있는 이름으로 정의
// 3. 주석으로 용도 설명 추가

// ==================== 새 카테고리 ====================

/// 새로운 기능에 대한 설명
static const 타입 새상수명 = 값;
```

## 🎨 디자인 원칙

### 상수 그룹화
- **논리적 그룹화**: 관련 상수끼리 섹션으로 구분
- **주석 구분선**: `====================`로 시각적 구분
- **설명 주석**: 각 상수의 용도 명시

### 타입 안전성
- **강타입 사용**: int, double, Duration, Color 등
- **const 키워드**: 컴파일 타임 상수 보장
- **static 멤버**: 인스턴스 생성 없이 접근

## ⚡ 성능 최적화

### 컴파일 타임 최적화
- **const 생성자**: 컴파일 시점에 값 결정
- **Tree Shaking**: 미사용 상수 자동 제거
- **인라인 최적화**: 컴파일러 최적화 가능

### 메모리 효율성
- **단일 인스턴스**: static const로 메모리 절약
- **불변성 보장**: 런타임 변경 불가능
- **전역 접근**: 중복 정의 방지

## 🔒 보안 고려사항

### 구현된 보안
- **Private 생성자**: 인스턴스화 방지
- **불변 상수**: 런타임 수정 불가능
- **타입 안전성**: 잘못된 타입 할당 방지

## 🐛 알려진 이슈 및 개선사항

### 현재 이슈
1. **AI 아바타 URL**: picsum.photos 하드코딩
2. **그라데이션 설정**: 사용처 불명확

### 개선 제안
1. **환경별 설정**: dev/prod 환경별 상수 분리
2. **동적 설정**: 일부 값 서버에서 관리
3. **테마 지원**: 다크/라이트 모드별 색상
4. **i18n 통합**: 텍스트 상수 다국어 지원

## 📊 통계 및 메트릭스

### 상수 분포
| 카테고리 | 상수 개수 | 비율 |
|----------|-----------|------|
| 메시지 로딩 | 4개 | 10% |
| 애니메이션 | 5개 | 12% |
| 투표 카드 | 5개 | 12% |
| 캐시 | 3개 | 7% |
| 메시지 타입 | 5개 | 12% |
| 투표 상태 | 3개 | 7% |
| AI 정보 | 3개 | 7% |
| UI 크기 | 4개 | 10% |
| 그라데이션 | 2개 | 5% |
| 텍스트 | 4개 | 10% |

### 사용 빈도
- **높음**: initialMessageLoadCount, messageType 계열
- **중간**: 애니메이션 Duration, UI 크기
- **낮음**: 그라데이션 설정

## 📝 변경 이력

| 버전 | 날짜 | 변경사항 | 작성자 |
|------|------|----------|--------|
| 1.0.0 | 2025-08-23 | 초기 문서 작성 | AI Assistant |
| 0.9.0 | 2025-08-22 | ChatConstants 클래스 구현 | 개발팀 |

---

*이 문서는 Versus Space 프로젝트의 채팅 상수 관리 모듈을 설명합니다.*
*ChatConstants는 채팅 시스템의 모든 설정값을 중앙에서 관리합니다.*
*마지막 업데이트: 2025-08-23*
