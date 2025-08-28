# 📐 Versus Space 통합 개발 규칙

> Feature-First Architecture 기반 개발 가이드라인  
> 최종 업데이트: 2025-08-27 | 버전: 2.0.0

## 🎯 핵심 원칙 (Core Principles)

### 4대 개발 철학
1. **기존 패턴 우선** - Don't reinvent the wheel
2. **문서화 필수** - Code without docs is incomplete  
3. **테스트 가능성** - If you can't test it, don't build it
4. **성능 최적화** - Performance matters from day one

### Feature-First Architecture 원칙
1. **기능별 모듈화** - 각 Feature는 독립적인 모듈로 구성
2. **Clean Architecture** - Data, Domain, Presentation 레이어 분리
3. **전역 레이어 활용** - Core, Backend, Services는 모든 Feature가 공유
4. **의존성 방향** - Features는 전역 레이어에만 의존 (역방향 금지)

## 📝 코드 작성 규칙 (Coding Standards)

### 네이밍 컨벤션

#### ✅ CamelCase 사용
```dart
// Firestore 필드
String? questionTitle;      // ✅ camelCase
DateTime? createdAt;        // ✅ camelCase
List<String>? votedUserIdsA; // ✅ camelCase

// Dart 변수/함수
String userName = 'John';              // ✅ camelCase
Future<void> getUserData() async {}   // ✅ camelCase

// 라우트명
GoRoute(name: 'chatDetail')          // ✅ camelCase
```

#### 🔧 Snake_case 사용
```dart
// 파일명 (Dart 표준)
user_service.dart           // ✅ snake_case
vote_card_message.dart      // ✅ snake_case

// Firebase Storage 경로
'user_uploads/post_images/' // ✅ snake_case
```

#### 🏷️ PascalCase 사용
```dart
// 클래스명
class UserService {}        // ✅ PascalCase
class VoteCardMessage {}    // ✅ PascalCase
```

### 상수 정의
```dart
// 상수
const int MAX_RETRY_COUNT = 3;  // ✅ SCREAMING_SNAKE_CASE
```

## 📁 파일 및 디렉토리 규칙

### Feature-First 디렉토리 구조
```
새 Feature 추가 시:
/lib/features/[feature_name]/
  ├── data/                          # 데이터 레이어
  │   ├── datasources/               # 원격/로컬 데이터 소스
  │   ├── repositories/              # Repository 구현체
  │   └── services/                  # Feature 전용 서비스
  ├── domain/                        # 도메인 레이어
  │   ├── models/                   # 도메인 모델
  │   ├── usecases/                 # 비즈니스 로직
  │   └── repositories/              # Repository 인터페이스
  ├── presentation/                  # 프레젠테이션 레이어
  │   ├── screens/                   # 화면 위젯
  │   ├── widgets/                   # UI 컴포넌트
  │   └── providers/                 # 상태 관리
  └── README.md                      # Feature 문서

전역 서비스 추가 시:
/lib/services/                      # 전역 서비스
  └── [service_name]_service.dart   # 서비스 로직

전역 컴포넌트 추가 시:
/lib/core/widgets/                  # 전역 UI 컴포넌트
  └── [component_name].dart         # 위젯 구현

전역 모델 추가 시:
/lib/backend/models/                # Firestore 모델
  └── [category]/                   # 카테고리별 분류
      └── [model_name]_model.dart   # 모델 정의
```

## 🔄 개발 프로세스

### 1️⃣ 작업 전 확인사항
```bash
# 1. 관련 기존 코드 검색
grep -r "유사기능" lib/

# 2. 네이밍 컨벤션 확인
./scripts/check_naming.sh

# 3. 유사 패턴 파악
# 예: 채팅 기능 추가 시 chat_detail_v2 참조
```

### 2️⃣ 구현 단계

#### 새 페이지 추가
```dart
// 1. 기존 페이지 구조 참조
// lib/pages/home/home_page_widget.dart 패턴 따르기

// 2. GoRouter 등록
// lib/core/nav/nav.dart에 라우트 추가
GoRoute(
  name: 'newFeature',  // camelCase
  path: '/newFeature',
  builder: (context, params) => NewFeatureWidget(),
)

// 3. AppState 연동 (필요시)
// lib/app_state.dart에 상태 추가
```

#### 새 서비스 추가
```dart
// 1. 캐싱 적용
class NewService {
  final UnifiedCacheService _cache = UnifiedCacheService();
  
  Future<Data> getData(String id) async {
    // L1 → L2 → L3 → Network 순서로 확인
    return await _cache.get('key_$id', 
      () => FirebaseFirestore.instance...);
  }
}

// 2. 에러 처리
try {
  // 작업 수행
} catch (e) {
  debugPrint('NewService error: $e');
  // 사용자 친화적 에러 처리
}
```

#### Firebase Functions 작업
```javascript
// 1. Genkit Framework 사용
const { genkit } = require('@genkit-ai/core');

// 2. camelCase 필드명
exports.functionName = onCall(async (request) => {
  const { userId, postId } = request.data;  // camelCase
  
  // 3. 에러 처리
  if (!userId) {
    throw new HttpsError('invalid-argument', 'userId required');
  }
});
```

### 3️⃣ 작업 후 처리

#### 문서 업데이트
```bash
# 1. 해당 디렉토리 README 업데이트
echo "## 변경 이력
- $(date +%Y-%m-%d): 기능 추가" >> README.md

# 2. CLAUDE.md Migration History 추가
# ### 2025-08-XX: [기능명] 구현
# - **작업 내용**: ...
# - **결과**: ...
# - **커밋**: xxxxx

# 3. 문서 동기화
./scripts/sync_docs.sh update
```

## ✅ 검증 및 테스트

### 필수 검증 스크립트
```bash
# 1. 네이밍 컨벤션 검사
./scripts/check_naming.sh

# 2. 문서 완성도 검사
./scripts/validate_docs.sh

# 3. 코드-문서 동기화 확인
./scripts/sync_docs.sh check
```

### 테스트 작성
```dart
// 단위 테스트 예시
test('새 기능 테스트', () async {
  // Given
  final service = NewService();
  
  // When
  final result = await service.getData('test');
  
  // Then
  expect(result, isNotNull);
});
```

## 💾 캐싱 전략

### 3-Layer 캐싱 시스템
```dart
// 새 서비스는 반드시 UnifiedCacheService 활용
class MyService {
  final UnifiedCacheService _cache = UnifiedCacheService();
  
  // 캐시 키 규칙: [prefix]_[identifier]
  // 예: user_123, post_456, chat_messages_789
  
  Future<T> getCachedData<T>(String key) async {
    return await _cache.get(key, () async {
      // Network fetch logic
    });
  }
}
```

### 캐시 무효화
```dart
// 데이터 업데이트 시 캐시 무효화
await _cache.remove('key');
// 또는 패턴 기반 무효화
await _cache.clearPattern('user_*');
```

## 🎨 UI/UX 개발 규칙

### 디자인 시스템 활용
```dart
import 'package:versus_space/design_system/design_system.dart';

// 색상 사용
color: VersusColors.primary,
backgroundColor: VersusColors.backgroundSecondary,

// 간격 사용
padding: EdgeInsets.all(VersusSpacing.md),
margin: EdgeInsets.symmetric(horizontal: VersusSpacing.lg),

// 텍스트 스타일
style: VersusTextStyles.headlineMedium,
```

### 이미지 처리
```dart
// ProImageEditor 패턴 따르기
// 참조: lib/pages/pro_image_editor/

// 이미지 업로드 시
final MediaUploadService _uploadService = MediaUploadService();
final urls = await _uploadService.uploadImages(files);

// 이미지 캐싱
CachedNetworkImage(
  imageUrl: url,
  memCacheWidth: 800,  // 성능 최적화
)
```

## 🚀 Firebase 작업 규칙

### Firestore 데이터 모델
```dart
// lib/backend/schema/에 모델 추가
class NewModel {
  // 필수 필드
  String? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  
  // JSON 직렬화 필수
  Map<String, dynamic> toJson() { ... }
  factory NewModel.fromJson(Map<String, dynamic> json) { ... }
}
```

### Security Rules 업데이트
```javascript
// firestore.rules 수정 시
match /newCollection/{doc} {
  allow read: if request.auth != null;
  allow create: if request.auth != null 
    && request.auth.uid == request.resource.data.userId;
}
```

## 🔀 Git 및 협업 규칙

### 브랜치 전략
```bash
# 기능 개발
git checkout -b feature/기능명-날짜

# 버그 수정
git checkout -b fix/이슈명-날짜
```

### 커밋 메시지
```bash
# 형식: [타입]: 설명

feat: 새로운 기능 추가
fix: 버그 수정
docs: 문서 수정
style: 코드 포맷팅
refactor: 코드 리팩토링
test: 테스트 추가
chore: 빌드 업무 수정
```

## ⚡ 성능 최적화 체크리스트

### 필수 확인사항
- [ ] 이미지 최적화 (memCacheWidth 설정)
- [ ] 리스트 가상화 (큰 목록의 경우)
- [ ] 캐싱 적용 (UnifiedCacheService)
- [ ] 불필요한 rebuild 방지 (const 위젯)
- [ ] 병렬 처리 (Future.wait 활용)

### 성능 목표
- 페이지 로드: < 500ms
- 캐시 히트율: > 60%
- 프레임률: 60fps 유지
- 메모리 사용: < 200MB

## 📋 AI 작업 체크리스트

작업 시작 전:
- [ ] 관련 기존 코드 확인
- [ ] 네이밍 컨벤션 숙지
- [ ] 디렉토리 구조 확인

구현 중:
- [ ] 기존 패턴 재사용
- [ ] 캐싱 시스템 적용
- [ ] 에러 처리 구현
- [ ] 디자인 시스템 활용

작업 완료 후:
- [ ] README.md 업데이트
- [ ] 검증 스크립트 실행
- [ ] CLAUDE.md 업데이트
- [ ] 테스트 작성

## 🔗 참조 문서

- [네이밍 컨벤션](./docs/guides/NAMING_CONVENTION.md)
- [시스템 아키텍처](./ARCHITECTURE.md)
- [기술 상세](./CLAUDE.md)
- [문서 가이드](./docs/DOCUMENTATION_GUIDE.md)

---

*이 문서는 Versus Space 프로젝트의 모든 개발 작업에 적용되는 통합 규칙입니다.*