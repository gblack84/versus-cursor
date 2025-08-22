# Utility Functions

Versus Space 앱 전반에서 사용되는 유틸리티 함수 및 헬퍼 클래스들입니다.

## 📋 파일 목록

### 1. app_logger.dart
앱 전체 로깅 시스템을 관리합니다.

```dart
// 사용 예제
AppLogger.info('사용자 로그인 성공', userId: user.uid);
AppLogger.error('API 호출 실패', error: e, stackTrace: st);
AppLogger.debug('캐시 히트', data: {'key': cacheKey});
```

**주요 기능:**
- 로그 레벨 관리 (debug, info, warning, error)
- 태그 기반 필터링
- 프로덕션 환경 자동 감지
- 구조화된 로그 출력

### 2. chat_message_converter.dart
Firestore 메시지와 flutter_chat_types 간 변환을 담당합니다.

```dart
// Firestore → Chat UI
final chatMessage = ChatMessageConverter.fromFirestore(
  doc: messageDoc,
  currentUserId: currentUser.uid,
);

// Chat UI → Firestore
final firestoreData = ChatMessageConverter.toFirestore(
  message: chatMessage,
  chatId: chatId,
);
```

**지원 메시지 타입:**
- 텍스트 메시지
- 이미지 메시지 (멀티이미지 지원)
- 비디오 메시지
- 투표 요청 메시지 (커스텀 타입)

**투표 메시지 구조:**
```dart
{
  'messageType': 'voteRequest',
  'votePostId': 'post123',
  'voteOptionATitle': 'A 옵션',
  'voteOptionBTitle': 'B 옵션',
  'voteOptionAImages': ['url1', 'url2'],
  'voteOptionBImages': ['url3', 'url4'],
  'cardStatus': 'votingRequest',
  'voteEndTime': Timestamp,
}
```

### 3. content_filter.dart
텍스트 콘텐츠 필터링 및 검증을 담당합니다.

```dart
// 텍스트 검증
final validation = ContentFilter.validateText(
  text: userInput,
  minLength: 10,
  maxLength: 500,
  checkProfanity: true,
);

if (!validation.isValid) {
  showError(validation.error);
}
```

**검증 항목:**
- 길이 제한 (최소/최대)
- 금지어 필터링
- 특수문자 검증
- URL/이메일 감지
- 반복 문자 제한

**내장 필터:**
```dart
// 금지어 목록 (일부)
static const prohibitedWords = [
  // 욕설, 비속어
  // 혐오 표현
  // 스팸 키워드
];

// 허용 패턴
static final allowedPattern = RegExp(
  r'^[가-힣a-zA-Z0-9\s.,!?()-]+$'
);
```

### 4. file_logger.dart
파일 기반 로깅 시스템으로 디버깅 및 분석용입니다.

```dart
// 파일 로거 초기화
await FileLogger.initialize();

// 로그 작성
FileLogger.log(
  level: LogLevel.error,
  message: '결제 실패',
  data: {
    'userId': user.uid,
    'amount': 10000,
    'error': errorMessage,
  },
);

// 로그 내보내기
final logs = await FileLogger.exportLogs(
  startDate: DateTime.now().subtract(Duration(days: 7)),
  endDate: DateTime.now(),
);
```

**특징:**
- 날짜별 로그 파일 분리
- 자동 로테이션 (30일)
- CSV/JSON 내보내기
- 압축 저장

### 5. responsive_breakpoints.dart
반응형 디자인을 위한 브레이크포인트 및 유틸리티입니다.

```dart
// 현재 디바이스 타입 확인
if (ResponsiveBreakpoints.isMobile(context)) {
  return MobileLayout();
} else if (ResponsiveBreakpoints.isTablet(context)) {
  return TabletLayout();
} else {
  return DesktopLayout();
}

// 반응형 값 계산
final padding = ResponsiveBreakpoints.value(
  context,
  mobile: 16.0,
  tablet: 24.0,
  desktop: 32.0,
);

// 반응형 그리드
ResponsiveGrid(
  crossAxisCount: ResponsiveBreakpoints.gridColumns(context),
  children: items,
)
```

**브레이크포인트:**
- Mobile: < 600px
- Tablet: 600px - 1024px
- Desktop: > 1024px

**유틸리티 메서드:**
```dart
// 화면 크기 정보
ResponsiveBreakpoints.screenWidth(context)
ResponsiveBreakpoints.screenHeight(context)
ResponsiveBreakpoints.aspectRatio(context)

// 조건부 렌더링
ResponsiveBreakpoints.when(
  context,
  mobile: () => MobileWidget(),
  tablet: () => TabletWidget(),
  desktop: () => DesktopWidget(),
)
```

## 공통 유틸리티 함수

### 날짜/시간 처리
```dart
// lib/core/app_utils.dart
String formatTimestamp(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);
  
  if (difference.inDays > 7) {
    return DateFormat('yyyy.MM.dd').format(timestamp);
  } else if (difference.inDays > 0) {
    return '${difference.inDays}일 전';
  } else if (difference.inHours > 0) {
    return '${difference.inHours}시간 전';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes}분 전';
  } else {
    return '방금 전';
  }
}
```

### 이미지 처리
```dart
// 이미지 압축
Future<File> compressImage(File file) async {
  final result = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    quality: 85,
    minWidth: 800,
    minHeight: 800,
  );
  // ...
}

// 썸네일 생성
Future<String> generateThumbnail(String videoPath) async {
  final thumbnail = await VideoThumbnail.thumbnailFile(
    video: videoPath,
    thumbnailPath: (await getTemporaryDirectory()).path,
    imageFormat: ImageFormat.JPEG,
    quality: 75,
  );
  return thumbnail!;
}
```

### 검증 헬퍼
```dart
// 이메일 검증
bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

// 전화번호 검증
bool isValidPhoneNumber(String phone) {
  return RegExp(r'^01[0-9]{8,9}$').hasMatch(phone);
}

// URL 검증
bool isValidUrl(String url) {
  try {
    final uri = Uri.parse(url);
    return uri.hasScheme && uri.hasAuthority;
  } catch (e) {
    return false;
  }
}
```

## 사용 가이드

### 1. 로깅 베스트 프랙티스
```dart
// ✅ 좋은 예
AppLogger.info('결제 성공', data: {
  'userId': userId,
  'amount': amount,
  'orderId': orderId,
});

// ❌ 나쁜 예
print('결제 성공: $userId, $amount');
```

### 2. 에러 처리
```dart
try {
  final result = await riskyOperation();
} catch (e, st) {
  AppLogger.error(
    '위험한 작업 실패',
    error: e,
    stackTrace: st,
    data: {'operation': 'riskyOperation'},
  );
  
  // 사용자에게 친화적인 메시지 표시
  showToast('작업 중 오류가 발생했습니다');
}
```

### 3. 성능 고려사항
- 로깅은 프로덕션에서 자동으로 최소화
- 파일 로거는 백그라운드 스레드에서 실행
- 콘텐츠 필터는 캐싱으로 성능 최적화

## 테스트

```dart
// 유틸리티 함수 테스트
test('이메일 검증', () {
  expect(isValidEmail('test@example.com'), true);
  expect(isValidEmail('invalid.email'), false);
});

test('콘텐츠 필터', () {
  final result = ContentFilter.validateText(
    text: '안녕하세요',
    minLength: 2,
    maxLength: 10,
  );
  expect(result.isValid, true);
});
```

## 향후 추가 예정

1. **암호화 유틸리티**
   - 민감 데이터 암호화
   - 해시 생성

2. **네트워크 유틸리티**
   - 연결 상태 확인
   - 재시도 로직

3. **캐싱 유틸리티**
   - 메모리 캐시
   - 디스크 캐시

4. **분석 유틸리티**
   - 이벤트 추적
   - 사용자 행동 분석