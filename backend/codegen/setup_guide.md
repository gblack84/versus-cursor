# Quicktype 설정 가이드

> **작성일**: 2025-11-02
> **업데이트**: 2025-11-10
> **도구**: Quicktype - TypeScript → Dart 변환
> **목적**: Backend Phase 2 - Single Source of Truth (SSOT)

---

## 📦 Quicktype 소개

**Quicktype**은 JSON Schema/TypeScript를 다양한 언어로 변환하는 도구입니다.

- [GitHub](https://github.com/quicktype/quicktype)
- [Documentation](https://quicktype.io/)

### 지원 기능

- ✅ TypeScript/JSON Schema → Dart
- ✅ Freezed + JSON Serializable 지원
- ✅ Null-safe Dart 생성
- ✅ CLI 및 API 모두 지원

---

## 🚀 설치

### 로컬 설치 (권장)

```bash
cd firebase/functions
npm install --save-dev quicktype
```

### 글로벌 설치

```bash
npm install -g quicktype
```

---

## 🔧 기본 사용법

### CLI 명령어

```bash
quicktype \
  --src firebase/functions/src/schemas/post_schema.ts \
  --lang dart \
  --out lib/features/post/domain/models/post_display.dart \
  --use-freezed \
  --use-json-annotation \
  --final-properties
```

### 옵션 설명

| 옵션 | 설명 |
|------|------|
| `--src` | 입력 TypeScript 파일 경로 |
| `--lang dart` | 출력 언어 (Dart) |
| `--out` | 출력 파일 경로 |
| `--use-freezed` | Freezed 패키지 사용 |
| `--use-json-annotation` | JSON Serializable 사용 |
| `--final-properties` | 모든 필드를 final로 생성 |
| `--no-combine-classes` | 클래스 병합 비활성화 |

---

## 📝 자동화 스크립트

### scripts/generate-dart-models.js

```javascript
const { execSync } = require('child_process');
const path = require('path');

/**
 * Schema Configuration for Code Generation
 *
 * Backend Phase 2 - Single Source of Truth (SSOT)
 * TypeScript Zod schemas → Dart Freezed models
 *
 * @note 완성된 schemas (Phase 2 문서):
 * - user_schema.ts ✅ (UserProfile)
 * - post_schema.ts ✅ (PostDisplay)
 * - chat_schema.ts ✅ (Chat, Message)
 * - voting_schema.ts ✅ (Vote, PostVoting) - 2025-11-10 추가
 * - notification_schema.ts 🔄 (Pending)
 */
const schemas = [
  { name: 'UserProfile', file: 'user_schema.ts', feature: 'profile' },
  { name: 'PostDisplay', file: 'post_schema.ts', feature: 'post' },
  { name: 'Chat', file: 'chat_schema.ts', feature: 'chat' },
  { name: 'Message', file: 'chat_schema.ts', feature: 'chat' },
  { name: 'Vote', file: 'voting_schema.ts', feature: 'voting' },
  { name: 'PostVoting', file: 'voting_schema.ts', feature: 'voting' },
  // { name: 'Notification', file: 'notification_schema.ts', feature: 'notifications' }, // 🔄 Phase 2 완료 후 활성화
];

const rootDir = path.join(__dirname, '../..');

schemas.forEach(({ name, file, feature }) => {
  const schemaPath = path.join('src/schemas', file);
  const outputPath = path.join(
    rootDir,
    'lib/features',
    feature,
    'domain/models',
    `${name.toLowerCase()}.dart`
  );

  console.log(`📝 Generating ${name} from ${file}...`);

  try {
    execSync(`npx quicktype ${schemaPath} \
      --lang dart \
      --out ${outputPath} \
      --use-freezed \
      --use-json-annotation \
      --final-properties \
      --no-combine-classes`, {
      stdio: 'inherit'
    });

    console.log(`✅ Generated ${name}.dart → ${outputPath}`);
  } catch (error) {
    console.error(`❌ Failed to generate ${name}:`, error.message);
    console.error(`   Schema: ${schemaPath}`);
    console.error(`   Output: ${outputPath}`);
    process.exit(1);
  }
});

console.log('\n🎉 All Dart models generated successfully!');
console.log('📌 Next steps:');
console.log('   1. cd ../../ (프로젝트 루트)');
console.log('   2. dart run build_runner build --delete-conflicting-outputs');
console.log('   3. Extension 파일 수동 작성 (fromFirestore/toFirestore)');
```

### package.json scripts

```json
{
  "scripts": {
    "generate:dart": "node scripts/generate-dart-models.js",
    "generate:all": "npm run generate:dart && cd ../.. && dart run build_runner build --delete-conflicting-outputs",
    "generate:single": "npx quicktype src/schemas/$SCHEMA.ts --lang dart --out ../../lib/features/$FEATURE/domain/models/$MODEL.dart --use-freezed --use-json-annotation --final-properties"
  },
  "devDependencies": {
    "quicktype": "^23.0.170"
  }
}
```

**사용 예시**:

```bash
# 모든 모델 생성
cd firebase/functions
npm run generate:dart

# 단일 모델 생성 (환경 변수)
SCHEMA=voting_schema FEATURE=voting MODEL=vote npm run generate:single

# 전체 파이프라인 (Quicktype + Freezed build_runner)
npm run generate:all
```

---

## 🧪 테스트

### 1. 단일 파일 생성 테스트

```bash
cd firebase/functions

# Post schema 생성
npx quicktype src/schemas/post_schema.ts \
  --lang dart \
  --out test_output.dart \
  --use-freezed

# 결과 확인
cat test_output.dart
```

### 2. 전체 파이프라인 테스트

```bash
# 모든 Dart 모델 생성
npm run generate:dart

# Freezed 빌드
cd ../..
dart run build_runner build --delete-conflicting-outputs

# Flutter 빌드 테스트
flutter build apk --debug
```

---

## ⚠️ 알려진 제한사항

### 1. Extension Pattern 미지원

**문제**: Quicktype은 Freezed class만 생성, Extension은 생성하지 않음

**해결책**: Extension 파일을 수동으로 작성하거나 템플릿 사용

```dart
// 수동 작성 필요: post_display_extensions.dart
extension PostDisplayFirestore on PostDisplay {
  static PostDisplay fromFirestore(DocumentSnapshot doc) {
    // ...
  }

  Map<String, dynamic> toFirestore() {
    // ...
  }
}
```

### 2. FlutterFlow Legacy 미지원

**문제**: Quicktype은 Zod schema를 그대로 변환, legacy normalization 미지원

**해결책**: Extension에서 dual-field 지원 구현

```dart
extension PostDisplayFirestore on PostDisplay {
  static PostDisplay fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // FlutterFlow legacy 지원
    return PostDisplay.fromJson({
      'id': doc.id,
      'userId': data['userId'] ?? data['userid'],  // ← 수동 추가
      ...data,
    });
  }
}
```

### 3. Timestamp 변환 미지원

**문제**: Quicktype은 DateTime을 그대로 처리, Firestore Timestamp 변환 미지원

**해결책**: Extension에서 변환 로직 추가

---

## 🛠️ 실전 통합 워크플로

### Phase 2 완료 후 실행 계획

**1. TypeScript Functions Migration (Phase 2.1)**:

```bash
cd firebase/functions

# 1. 의존성 설치
npm install zod firebase-admin

# 2. JavaScript → TypeScript 마이그레이션
# (각 Function 수동 변환)
mv index.js index.ts
mv lib/notifications/*.js lib/notifications/*.ts
mv lib/ai/*.js lib/ai/*.ts

# 3. Zod Schema 통합
# - Import 추가: import { VoteSchema, PostVotingSchema } from './schemas/voting_schema';
# - Validation 추가: const validVote = VoteSchema.parse(data);

# 4. TypeScript 빌드 설정
npm install --save-dev typescript @types/node
npx tsc --init
npm run build

# 5. Deploy
npm run deploy
```

**2. Dart Model Generation (Phase 2.2)**:

```bash
# 1. Quicktype으로 Freezed 모델 생성
cd firebase/functions
npm run generate:dart

# 출력:
# ✅ lib/features/voting/domain/models/vote.dart
# ✅ lib/features/voting/domain/models/post_voting.dart

# 2. Freezed 빌드
cd ../..
dart run build_runner build --delete-conflicting-outputs

# 3. Extension 수동 작성
# lib/features/voting/domain/entities/vote_extensions.dart
```

**3. Extension Pattern 작성 (Phase 2.3)**:

```dart
// lib/features/voting/domain/entities/vote_extensions.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vote.dart';

extension VoteFirestore on Vote {
  /// Firestore → Vote
  static Vote fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) throw Exception('Vote not found');

    return Vote(
      postId: data['postId'] as String,
      userId: doc.id,
      choice: data['choice'] as String,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  /// Vote → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'choice': choice,
      'timestamp': timestamp != null
          ? Timestamp.fromDate(timestamp!)
          : FieldValue.serverTimestamp(),
    };
  }
}
```

**4. 검증 및 테스트 (Phase 2.4)**:

```bash
# 1. 타입 체크
dart analyze

# 2. 단위 테스트
flutter test test/features/voting/domain/entities/vote_test.dart

# 3. 통합 테스트
flutter test integration_test/voting_flow_test.dart

# 4. 앱 빌드
flutter build apk --debug
```

### 완료 체크리스트

- [ ] TypeScript Functions 마이그레이션 완료
- [ ] Zod Schema 통합 및 Validation 추가
- [ ] Quicktype으로 Dart 모델 생성
- [ ] Extension Pattern 수동 작성
- [ ] Freezed + JSON Serializable 빌드
- [ ] 단위 테스트 작성 및 통과
- [ ] 통합 테스트 통과
- [ ] 문서 업데이트 (README.md, MIGRATION_STRATEGY.md)

---

## 🔄 대안: 커스텀 코드 생성기

Phase 3 완료 후, 다음 고려사항:

### 장점
- ✅ Extension Pattern 자동 생성
- ✅ FlutterFlow legacy 자동 처리
- ✅ Timestamp 변환 자동화
- ✅ Repository 코드 자동 생성

### 구현 옵션
1. **TypeScript AST 파싱** (typescript-parser, ts-morph)
2. **Template 기반 생성** (Handlebars, EJS, Mustache)
3. **Dart 코드 생성기** (build_runner custom builder)

### 예상 ROI
- **개발 시간 절감**: 수동 작업 5h → 자동화 0.5h (90% 감소)
- **에러 감소**: 타이핑 에러 0개, 필드 누락 0개
- **유지보수**: Schema 변경 시 자동 재생성 (1분 이내)

---

## 🔗 관련 문서

**Backend Phase 2 관련**:
- `backend/schemas/voting_schema.ts` - Vote/PostVoting Zod 스키마
- `backend/schemas/common_helpers.ts` - 공통 파서 및 헬퍼
- `backend/analysis/entity_analysis.md` - 엔티티 분석 문서
- `backend/README.md` - Backend Phase 2 현황

**External Documentation**:
- [Quicktype GitHub](https://github.com/quicktype/quicktype)
- [Quicktype Documentation](https://quicktype.io/)
- [Zod Documentation](https://zod.dev/)
- [Freezed Documentation](https://pub.dev/packages/freezed)
- [JSON Serializable](https://pub.dev/packages/json_serializable)
- [TypeScript AST (ts-morph)](https://ts-morph.com/)

---

**최종 업데이트**: 2025-11-10
