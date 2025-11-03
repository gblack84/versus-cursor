# 코드 생성 파이프라인 가이드

> **작성일**: 2025-11-02
> **목적**: TypeScript → Dart Freezed 자동 변환 파이프라인 구축

---

## 🎯 개요

TypeScript Zod 스키마를 Single Source of Truth로 사용하여, Dart Freezed 모델과 Extension을 자동 생성하는 파이프라인입니다.

### 워크플로우

```
TypeScript Zod Schema (SSOT)
    ↓ (npm run generate:dart)
Dart Freezed Models (*.dart)
    ↓ (dart run build_runner)
Generated Files (*.freezed.dart, *.g.dart)
    ↓ (Extension Pattern)
Firestore Converters (fromFirestore, toFirestore)
```

---

## 📁 파일 구조

```
backend/codegen/
├── README.md                 # 이 문서 (개요)
├── setup_guide.md            # Quicktype 설치 및 설정
└── package.json.example      # npm scripts 예시
```

---

## 🚀 빠른 시작

### 1. Quicktype 설치

```bash
cd firebase/functions
npm install --save-dev quicktype
```

### 2. package.json scripts 추가

```json
{
  "scripts": {
    "generate:dart": "node scripts/generate-dart-models.js",
    "generate:all": "npm run generate:dart && cd ../.. && dart run build_runner build --delete-conflicting-outputs"
  }
}
```

### 3. 코드 생성 실행

```bash
# TypeScript 스키마 변경 후
npm run generate:all

# 결과:
# ✅ lib/features/post/domain/models/post_display.dart (자동 생성)
# ✅ lib/features/chat/domain/models/chat.dart (자동 생성)
# ✅ .freezed.dart, .g.dart 파일 생성
```

---

## 🔧 도구 옵션

### Option A: Quicktype (권장 ⭐)

**장점**:
- ✅ TypeScript/JSON Schema → Dart 자동 변환
- ✅ Freezed + JSON Serializable 지원
- ✅ 널리 사용되는 도구 (커뮤니티 지원)

**단점**:
- ⚠️ Extension Pattern 미지원 (수동 추가 필요)
- ⚠️ Customization 제한적

**사용법**: [setup_guide.md](./setup_guide.md) 참조

### Option B: 커스텀 스크립트

**장점**:
- ✅ Extension Pattern 자동 생성 가능
- ✅ 프로젝트 특화 customization

**단점**:
- ⚠️ 개발 및 유지보수 비용
- ⚠️ TypeScript 파싱 복잡도

**추천**: Phase 3 완료 후 고려

---

## 📋 생성 파일 예시

### Input: TypeScript Zod Schema

```typescript
// firebase/functions/src/schemas/post_schema.ts
export const PostDisplaySchema = baseSchema.extend({
  userId: z.string(),
  questionTitle: z.string(),
  votesA: z.number().default(0),
  // ... 30 fields
});
```

### Output: Dart Freezed Model

```dart
// lib/features/post/domain/models/post_display.dart
@freezed
sealed class PostDisplay with _$PostDisplay {
  const factory PostDisplay({
    required String id,
    required String userId,
    required String questionTitle,
    @Default(0) int votesA,
    // ... 30 fields
  }) = _PostDisplay;

  factory PostDisplay.fromJson(Map<String, dynamic> json) =>
      _$PostDisplayFromJson(json);
}
```

### 수동 추가: Extension Pattern

```dart
// lib/features/post/domain/models/post_display_extensions.dart
extension PostDisplayFirestore on PostDisplay {
  static PostDisplay fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PostDisplay.fromJson({'id': doc.id, ...data});
  }

  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }
}
```

---

## 🔄 CI/CD 통합

### GitHub Actions Workflow

```yaml
# .github/workflows/codegen.yml
name: Code Generation

on:
  push:
    paths:
      - 'firebase/functions/src/schemas/**'

jobs:
  generate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
      - name: Setup Flutter
        uses: subosito/flutter-action@v2

      - name: Generate Dart models
        run: |
          cd firebase/functions
          npm install
          npm run generate:dart

      - name: Run build_runner
        run: |
          flutter pub get
          dart run build_runner build --delete-conflicting-outputs

      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v5
        with:
          title: '🤖 Auto-generated Dart models'
```

---

## 📚 관련 문서

- [Setup Guide](./setup_guide.md) - Quicktype 설정
- [package.json Example](./package.json.example) - npm scripts
- [Migration Strategy](/backend/MIGRATION_STRATEGY.md) - Phase 3

---

**최종 업데이트**: 2025-11-02
