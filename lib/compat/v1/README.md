# Chat V1 to V2 Compatibility Adapters

이 디렉토리는 레거시 채팅 시스템(V1)에서 flutter_chat_ui v2.9.0(V2)로의 마이그레이션을 지원하는 어댑터 클래스들을 포함합니다.

## 📦 포함된 어댑터

### 1. ChatMessageAdapter (`chat_message_adapter.dart`)
레거시 메시지 형식과 flutter_chat_core 메시지 형식 간의 변환을 처리합니다.

**주요 기능:**
- `fromLegacyMessage()`: 레거시 → core.Message 변환
- `toLegacyFormat()`: core.Message → 레거시 변환
- `batchConvertFromLegacy()`: 대량 변환
- `needsMigration()`: 마이그레이션 필요 여부 확인

**사용 예시:**
```dart
// 레거시 메시지를 V2 형식으로 변환
final coreMessage = await ChatMessageAdapter.fromLegacyMessage(legacyData);

// V2 메시지를 레거시 형식으로 변환
final legacyData = ChatMessageAdapter.toLegacyFormat(coreMessage);
```

### 2. ChatControllerAdapter (`chat_controller_adapter.dart`)
레거시 컨트롤러 메서드를 V2 ChatDetailControllerV2로 브릿지합니다.

**주요 메서드 매핑:**
- `scrollToBottom()` → `scrollToMessage(lastMessageId)`
- `loadMessages()` → `setMessages()`
- `sendMessage()` → `insertMessage()`
- `searchLegacyMessages()` → `searchMessages()`

**사용 예시:**
```dart
final v2Controller = ChatDetailControllerV2();
final adapter = ChatControllerAdapter(v2Controller);

// 레거시 스타일 호출
adapter.scrollToBottom();
adapter.sendMessage('Hello', currentUserId);
```

### 3. ChatUIAdapter (`chat_ui_adapter.dart`)
레거시 UI 패턴을 flutter_chat_ui 컴포넌트로 매핑합니다.

**제공 기능:**
- 레거시 스타일 채팅 테마
- 메시지 버블 스타일링
- 아바타 렌더링
- 타이핑 인디케이터
- 날짜 구분선
- 빈 채팅 플레이스홀더

**사용 예시:**
```dart
// 레거시 스타일 테마 적용
final theme = ChatUIAdapter.getLegacyChatTheme(
  isDarkMode: true,
  primaryColor: VersusColors.primary,
);

// 레거시 스타일 메시지 버블
final bubble = ChatUIAdapter.buildLegacyMessageBubble(
  child: Text('Hello'),
  isMe: true,
  timestamp: DateTime.now(),
);
```

## 🔄 마이그레이션 가이드

### 단계별 마이그레이션

#### 1단계: 의존성 업데이트
```yaml
dependencies:
  flutter_chat_ui: ^2.9.0
  flutter_chat_core: ^2.8.0
```

#### 2단계: 어댑터 임포트
```dart
import '/lib/compat/v1/chat_message_adapter.dart';
import '/lib/compat/v1/chat_controller_adapter.dart';
import '/lib/compat/v1/chat_ui_adapter.dart';
```

#### 3단계: 점진적 마이그레이션
```dart
// 기존 레거시 코드
class LegacyChatWidget extends StatefulWidget {
  // ... 레거시 구현
}

// 어댑터를 사용한 브릿지
class BridgedChatWidget extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    // V2 컨트롤러 사용
    final controller = ChatDetailControllerV2();
    final adapter = ChatControllerAdapter(controller);
    
    // 레거시 메서드 호출 가능
    adapter.scrollToBottom();
    
    // V2 Chat 위젯 사용
    return Chat(
      chatController: controller,
      theme: ChatUIAdapter.getLegacyChatTheme(),
      // ...
    );
  }
}
```

## ✅ 해결된 문제들

### 1. 검색 기능 (카카오톡 스타일)
- ✅ 검색 UI 구현 완료
- ✅ "1/3" 형식의 카운터 표시
- ✅ 화살표 네비게이션 (순환)
- ✅ 자동 스크롤 기능

### 2. 채팅 버블 정렬
- ✅ `isMe` 속성 기반 좌/우 정렬
- ✅ 내 메시지: 오른쪽 정렬
- ✅ 상대 메시지: 왼쪽 정렬

### 3. AspectRatio 파라미터
- ✅ VoteCardMessage에 aspectRatio 전달
- ✅ 타입 안전성 보장 (double 변환)
- ✅ 기본값 처리 (1.0)

## 🔍 테스트 체크리스트

- [ ] 텍스트 메시지 송/수신
- [ ] 이미지 메시지 업로드/표시
- [ ] 투표 카드 메시지 정상 표시
- [ ] 검색 기능 작동 (AI 채팅)
- [ ] 채팅 버블 정렬 (좌/우)
- [ ] 스크롤 점프 없음
- [ ] 멀티이미지 투표 카드
- [ ] 실시간 메시지 업데이트

## 📝 주의사항

1. **점진적 마이그레이션**: 모든 채팅을 한 번에 마이그레이션하지 말고, 새로운 채팅부터 V2를 사용하세요.

2. **테스트 우선**: 각 어댑터를 개별적으로 테스트한 후 통합하세요.

3. **백업 유지**: 레거시 코드를 즉시 삭제하지 말고, 안정화 후 제거하세요.

4. **성능 모니터링**: 어댑터 레이어가 추가 오버헤드를 발생시킬 수 있으므로 성능을 모니터링하세요.

## 🚀 다음 단계

1. **완전한 V2 마이그레이션**: 어댑터 없이 직접 V2 API 사용
2. **레거시 코드 제거**: 모든 채팅이 V2로 마이그레이션된 후
3. **성능 최적화**: 어댑터 레이어 제거로 성능 향상

---

마지막 업데이트: 2025-08-10
버전: 1.0.0