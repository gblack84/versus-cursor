# lib/ - Flutter 애플리케이션 메인 디렉토리

## 개요
이 디렉토리는 Versus Space Flutter 애플리케이션의 핵심 코드를 포함합니다. FlutterFlow에서 네이티브 Flutter로 완전히 마이그레이션된 코드베이스입니다.

## 디렉토리 구조

### 핵심 디렉토리
- **`auth/`** - 인증 관련 페이지 및 로직
- **`backend/`** - Firebase 백엔드 통합 (스키마, API, Algolia)
- **`core/`** - 핵심 유틸리티 (이전 flutter_flow 디렉토리)
- **`pages/`** - 앱의 모든 화면/페이지
- **`components/`** - 재사용 가능한 UI 컴포넌트
- **`services/`** - 비즈니스 로직 서비스
- **`providers/`** - 상태 관리 프로바이더
- **`models/`** - 데이터 모델
- **`widgets/`** - 커스텀 위젯

### 주요 파일
- **`main.dart`** - 애플리케이션 진입점
- **`app_state.dart`** - 전역 상태 관리 (이전 FFAppState)
- **`index.dart`** - 위젯 export 파일

## 최근 변경사항 (2025-08-03)

### Firebase 모델 필드 불일치 해결
- **Posts Model**: 13개 투표 관련 필드 추가
  - `vote_start_time`, `vote_end_time` - 투표 시간 관리
  - `votes_a`, `votes_b` - 각 옵션의 투표 수
  - `votedUserIDsA`, `votedUserIDsB` - 투표자 ID 추적
  - `total_votes`, `vote_status` - 투표 상태 관리

- **Messages Model**: 9개 투표 카드 필드 추가
  - `receiver_id` - 메시지 수신자
  - `vote_option_a_images[]`, `vote_option_b_images[]` - 멀티이미지 지원
  - `card_status` - 카드 상태 (voting_request, in_progress, completed)

- **Notifications Model**: 9개 필드 추가
  - JSON 파싱 로직 구현
  - 구조화된 알림 데이터 지원

### AI 채팅 시스템 통합
- AI 어시스턴트 채팅방 생성 로직
- 투표 요청/생성 메시지 자동 생성
- 실시간 투표 상태 업데이트

## 아키텍처 특징

### 상태 관리
- **Provider 패턴** 사용
- **AppState**로 전역 상태 관리
- **NavigationProvider**로 듀얼 모드 네비게이션 구현

### 디자인 시스템
- **VersusColors** - 일관된 색상 팔레트
- **VersusSpacing** - 표준화된 간격
- **VersusTextStyles** - 타이포그래피 시스템

### 국제화
- 영어(en) 완전 번역
- 독일어(de) 번역 키 준비

## 개발 가이드

### 네이밍 컨벤션
- 파일명: snake_case (예: `chat_list_widget.dart`)
- 클래스명: PascalCase (예: `ChatListWidget`)
- 변수명: camelCase (예: `currentUserId`)

### 코드 스타일
- Flutter 공식 스타일 가이드 준수
- `analysis_options.yaml` 설정 따름
- 커스텀 코드는 `custom_code/` 디렉토리에 배치

### 테스트
```bash
flutter test
flutter analyze
```

## 주요 기능별 위치

### 인증
- `/auth/` - 로그인, 회원가입, 비밀번호 재설정
- `/createaccount/` - 계정 생성 플로우

### 콘텐츠 관리
- `/posts/` - 게시물 생성, 수정, 표시
- `/components/` - 재사용 가능한 UI 컴포넌트

### 채팅
- `/pages/chat_list/` - 채팅 목록
- `/pages/chat_page/` - 개별 채팅방

### 알림
- `/components/notifications/` - 알림 UI 컴포넌트
- `/services/notification_service.dart` - 알림 로직

## 디버깅 팁

### AI 채팅 메시지가 보이지 않을 때
1. Firestore에서 `chats` 컬렉션 확인
2. `ai_assistant_사용자ID` 형식의 문서 존재 여부 확인
3. Flutter 쿼리에서 `participantIds` 필드 사용 확인

### 투표 권한 오류
- Firebase Security Rules에서 `votedUserIDsA/B` 필드 존재 여부 체크
- 필드가 없을 때도 투표 가능하도록 규칙 수정됨

## 빌드 및 배포

### 개발 빌드
```bash
flutter run
```

### 프로덕션 빌드
```bash
flutter build ios
flutter build android
flutter build web
```

## 관련 문서
- [프로젝트 개요](/CLAUDE.md)
- [Firebase 백엔드](/firebase/README.md)
- [API 문서](/lib/backend/README.md)