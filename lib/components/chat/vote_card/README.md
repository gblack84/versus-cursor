# Vote Card Components - 채팅 투표 카드 UI 컴포넌트

채팅 내에서 투표 카드 메시지를 표시하는 재사용 가능한 UI 컴포넌트 모음입니다.

## 📋 개요

이 디렉토리는 Versus Space 앱의 채팅 시스템에서 사용되는 투표 카드 메시지를 구성하는 모듈화된 컴포넌트들을 포함합니다. 각 컴포넌트는 투표 카드의 특정 부분을 담당하며, 독립적으로 재사용 가능하도록 설계되었습니다.

### 주요 특징
- **모듈화된 구조**: 헤더, 옵션 박스, 액션 버튼, 결과 표시를 개별 컴포넌트로 분리
- **적응형 UI**: 발신자/수신자 구분, 투표 상태에 따른 동적 표시
- **멀티이미지 지원**: 옵션당 여러 이미지 표시 가능
- **검색 하이라이팅**: 검색어 매칭 시 텍스트 하이라이팅
- **디자인 시스템 통합**: VersusColors, VersusSpacing, VersusTextStyles 일관된 사용

## 🎯 네이밍 컨벤션

### 파일명
- **Dart 파일**: snake_case (`vote_action_button.dart`, `vote_card_header.dart`)
- **README**: 대문자 확장자 (`README.md`)

### 코드 내 명명 규칙
- **클래스명**: PascalCase (`VoteActionButton`, `VoteCardHeader`)
- **변수/메서드**: camelCase (`isMe`, `cardStatus`, `onPressed`)
- **상수**: camelCase 또는 SCREAMING_SNAKE_CASE (용도에 따라)

참조: [NAMING_CONVENTION.md](../../../../NAMING_CONVENTION.md)

## 🔧 주요 구성요소

### 1. VoteActionButton
**파일**: `vote_action_button.dart`  
**용도**: 투표 참여 또는 결과 보기 액션 버튼

#### 주요 속성
| 속성 | 타입 | 설명 |
|------|------|------|
| `isMe` | bool | 내가 만든 투표인지 여부 |
| `cardStatus` | String | 투표 카드 상태 ('votingRequest', 'inProgress', 'completed') |
| `onPressed` | VoidCallback | 버튼 클릭 이벤트 핸들러 |

#### 동작 로직
```dart
// 버튼 텍스트 결정
if (isMe) {
  buttonText = '투표 현황 보기';  // 내가 만든 투표
} else {
  buttonText = cardStatus == 'votingRequest' 
    ? '투표하기'           // 투표 요청 상태
    : '투표 현황 보기';    // 진행중/완료 상태
}
```

### 2. VoteCardHeader
**파일**: `vote_card_header.dart`  
**용도**: 투표 카드 상단 헤더 (프로필, 발신자 정보, 상태 배지)

#### 주요 속성
| 속성 | 타입 | 설명 |
|------|------|------|
| `isMe` | bool | 내가 만든 투표인지 여부 |
| `currentUserName` | String? | 현재 사용자 이름 |
| `senderDisplayName` | String? | 발신자 표시 이름 |
| `senderProfileImageUrl` | String? | 발신자 프로필 이미지 URL |
| `statusInfo` | Map<String, dynamic> | 상태 정보 (icon, color, text) |

#### UI 구성
- **좌측**: 프로필 이미지 (CircleAvatar)
- **중앙**: Pikle 브랜딩 + 발신자 정보
- **우측**: 상태 배지 (진행중/완료)

### 3. VoteOptionBox
**파일**: `vote_option_box.dart`  
**용도**: A/B 투표 옵션을 시각적으로 표현하는 박스

#### 주요 속성
| 속성 | 타입 | 설명 |
|------|------|------|
| `label` | String | 옵션 라벨 ('A' 또는 'B') |
| `text` | String | 옵션 텍스트 내용 |
| `imageUrl` | String? | 단일 이미지 URL |
| `imageUrls` | List<String>? | 멀티 이미지 URL 리스트 |
| `color` | Color | 옵션 색상 (A: 빨강, B: 청록) |
| `aspectRatio` | double? | 이미지 비율 |
| `boxHeight` | double? | 박스 높이 (기본값: 200px) |
| `searchQuery` | String? | 검색어 (하이라이팅용) |

#### 특수 기능
```dart
// 멀티이미지 인디케이터 표시
if (hasMultipleImages) {
  // 우측 상단에 이미지 개수 표시
  Icon(Icons.photo_library) + Text('$count')
}

// 동적 캐시 폭 계산 (성능 최적화)
int _calculateDynamicCacheWidth(BuildContext context) {
  // 화면 크기에 따라 400-1200px 범위로 자동 조정
  return optionWidth.clamp(400, 1200).toInt();
}
```

### 4. VoteResultDisplay
**파일**: `vote_result_display.dart`  
**용도**: 투표 완료 후 결과 확인 유도 메시지

#### 주요 속성
| 속성 | 타입 | 설명 |
|------|------|------|
| `currentUserName` | String? | 현재 사용자 이름 (기본값: '나') |

#### 표시 내용
```dart
'피클! 피클! 피클!'
'$displayName님 결과를 보러오세요!'
```

## 💡 사용 예시

### 기본 사용법
```dart
import 'package:versus_space/components/chat/vote_card/vote_action_button.dart';
import 'package:versus_space/components/chat/vote_card/vote_card_header.dart';
import 'package:versus_space/components/chat/vote_card/vote_option_box.dart';
import 'package:versus_space/components/chat/vote_card/vote_result_display.dart';

// 투표 카드 구성
Column(
  children: [
    // 헤더
    VoteCardHeader(
      isMe: false,
      senderDisplayName: '홍길동',
      senderProfileImageUrl: 'https://...',
      statusInfo: {
        'icon': Icons.timer,
        'color': Colors.blue,
        'text': '진행중',
      },
    ),
    
    // 투표 옵션들
    Row(
      children: [
        Expanded(
          child: VoteOptionBox(
            label: 'A',
            text: '커피',
            imageUrl: 'https://coffee.jpg',
            color: Color(0xFFFF6B6B),
            boxHeight: 150,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: VoteOptionBox(
            label: 'B',
            text: '차',
            imageUrl: 'https://tea.jpg',
            color: Color(0xFF4ECDC4),
            boxHeight: 150,
          ),
        ),
      ],
    ),
    
    // 액션 버튼
    VoteActionButton(
      isMe: false,
      cardStatus: 'votingRequest',
      onPressed: () => handleVoteAction(),
    ),
  ],
)
```

### 멀티이미지 옵션
```dart
VoteOptionBox(
  label: 'A',
  text: '여름 휴가지',
  imageUrls: [
    'https://beach1.jpg',
    'https://beach2.jpg',
    'https://beach3.jpg',
  ],
  color: Color(0xFFFF6B6B),
  boxHeight: 200,
)
```

### 검색 하이라이팅
```dart
VoteOptionBox(
  label: 'B',
  text: '아이스 아메리카노',
  imageUrl: 'https://coffee.jpg',
  color: Color(0xFF4ECDC4),
  searchQuery: '아메리카노',  // '아메리카노' 부분이 하이라이트됨
)
```

### 투표 완료 표시
```dart
// 투표 완료 시 결과 표시
if (voteStatus == 'completed') {
  VoteResultDisplay(
    currentUserName: '김철수',
  )
}
```

## 🎨 디자인 시스템 통합

### 색상 체계
- **옵션 A**: `Color(0xFFFF6B6B)` - 빨강 계열
- **옵션 B**: `Color(0xFF4ECDC4)` - 청록 계열
- **Primary**: `VersusColors.primary` - 메인 브랜드 색상
- **배경**: `VersusColors.backgroundSecondary` - 보조 배경색

### 타이포그래피
- **버튼**: `VersusTextStyles.buttonMedium`
- **라벨**: `VersusTextStyles.labelSmall`, `labelMedium`
- **본문**: `VersusTextStyles.bodySmall`

### 간격 시스템
- `VersusSpacing.xs`: 4px
- `VersusSpacing.sm`: 8px
- `VersusSpacing.md`: 16px

## ⚡ 성능 최적화

### 이미지 캐싱 전략
```dart
// CachedNetworkImage 최적화
CachedNetworkImage(
  memCacheWidth: _calculateDynamicCacheWidth(context),  // 동적 크기
  maxWidthDiskCache: UnifiedImageCacheService.MAX_CACHE_WIDTH,
  fadeInDuration: Duration(milliseconds: 200),  // 부드러운 전환
)
```

### 애니메이션 최적화
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 400),
  curve: Curves.easeInOutCubic,  // 자연스러운 애니메이션
)
```

## 🔗 관련 파일

### 상위 컴포넌트
- `/lib/components/chat/vote_card_message.dart` - 전체 투표 카드 메시지 컴포넌트
- `/lib/components/chat/base_vote_message.dart` - 투표 메시지 기반 클래스

### 서비스
- `/lib/services/unified_image_cache_service.dart` - 이미지 캐싱 서비스
- `/lib/services/vote_timer_service.dart` - 투표 타이머 관리
- `/lib/services/vote_status_service.dart` - 투표 상태 관리

### 디자인 시스템
- `/lib/design_system/design_system.dart` - 통합 디자인 시스템

## 📊 컴포넌트 의존성

```
vote_card/
├── vote_action_button.dart
│   └── design_system (VersusColors, VersusTextStyles, VersusSpacing)
├── vote_card_header.dart
│   ├── cached_network_image
│   └── design_system
├── vote_option_box.dart
│   ├── cached_network_image
│   ├── design_system
│   └── unified_image_cache_service
└── vote_result_display.dart
    └── design_system
```

## 🐛 문제 해결

### 이미지 로딩 실패
```dart
// errorWidget으로 폴백 UI 제공
errorWidget: (context, url, error) => Container(
  color: color.withValues(alpha: 0.05),
  child: Icon(Icons.error_outline),
)
```

### 텍스트 오버플로우
```dart
// maxLines와 overflow 설정
Text(
  text,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

### 프로필 이미지 없음
```dart
// 기본 아이콘 표시
child: !hasProfileImage || isMe
    ? Icon(Icons.person, size: 24)
    : null,
```

## 📝 변경 이력

- **2025-08-22**: 문서 전체 작성 및 컴포넌트 분석 완료
- **2025-08-17**: 멀티이미지 지원 추가
- **2025-08-13**: 검색 하이라이팅 기능 추가
- **2025-08-06**: 초기 컴포넌트 분리 및 생성

---

*이 문서는 `/lib/components/chat/vote_card` 디렉토리의 투표 카드 UI 컴포넌트를 설명합니다.*