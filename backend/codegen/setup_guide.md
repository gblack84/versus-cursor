# Quicktype 설정 가이드

> **작성일**: 2025-11-02
> **도구**: Quicktype - TypeScript → Dart 변환

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

const schemas = [
  { name: 'PostDisplay', file: 'post_schema.ts', feature: 'post' },
  { name: 'Chat', file: 'chat_schema.ts', feature: 'chat' },
  { name: 'Message', file: 'chat_schema.ts', feature: 'chat' },
  { name: 'Vote', file: 'voting_schema.ts', feature: 'voting' },
  { name: 'PostVoting', file: 'voting_schema.ts', feature: 'voting' },
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

  console.log(`Generating ${name}...`);

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

    console.log(`✅ Generated ${name}.dart`);
  } catch (error) {
    console.error(`❌ Failed to generate ${name}:`, error.message);
    process.exit(1);
  }
});

console.log('\n🎉 All Dart models generated successfully!');
```

### package.json scripts

```json
{
  "scripts": {
    "generate:dart": "node scripts/generate-dart-models.js",
    "generate:all": "npm run generate:dart && cd ../.. && dart run build_runner build --delete-conflicting-outputs"
  }
}
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

## 🔄 대안: 커스텀 코드 생성기

Phase 3 완료 후, 다음 고려사항:

### 장점
- ✅ Extension Pattern 자동 생성
- ✅ FlutterFlow legacy 자동 처리
- ✅ Timestamp 변환 자동화

### 구현 옵션
1. **TypeScript AST 파싱** (typescript-parser)
2. **Template 기반 생성** (Handlebars, EJS)
3. **Dart 코드 생성기** (build_runner custom builder)

---

## 🔗 관련 문서

- [Quicktype GitHub](https://github.com/quicktype/quicktype)
- [Freezed Documentation](https://pub.dev/packages/freezed)
- [JSON Serializable](https://pub.dev/packages/json_serializable)

---

**최종 업데이트**: 2025-11-02
