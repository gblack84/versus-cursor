# Backend 마이그레이션 문서

> **작성일**: 2025-11-02
> **목적**: Firebase-Centric v2.0 아키텍처의 Backend 인프라 마이그레이션 전략 및 가이드

---

## 📋 목차

- [개요](#-개요)
- [문서 구조](#-문서-구조)
- [빠른 시작](#-빠른-시작)
- [현재 상태](#-현재-상태)
- [마이그레이션 로드맵](#-마이그레이션-로드맵)

---

## 🎯 개요

이 디렉토리는 **Backend 인프라 마이그레이션**을 위한 전략, 분석, 설계 문서를 포함합니다.

### 마이그레이션 목표

1. **TypeScript + Zod 스키마 도입** - Cloud Functions 타입 안전성 확보
2. **코드 생성 자동화** - TypeScript → Dart Freezed 자동 변환
3. **FlutterFlow 레거시 정리** - lowercase 필드명 표준화 (userid → userId)
4. **Single Source of Truth** - TypeScript 스키마를 중심으로 통일

### 왜 필요한가?

**현재 문제점**:
- ❌ Cloud Functions가 JavaScript로 작성되어 타입 안전성 없음
- ❌ Flutter Freezed 모델과 수동 동기화 필요 (7개 파일 수정)
- ❌ FlutterFlow 레거시 필드명 혼재 (userid vs userId)
- ❌ 스키마 변경 시 휴먼 에러 발생 가능

**마이그레이션 후**:
- ✅ TypeScript + Zod로 런타임 타입 검증
- ✅ 스키마 변경 시 Dart 코드 자동 생성
- ✅ 표준 camelCase 필드명 통일
- ✅ 휴먼 에러 최소화

---

## 📁 문서 구조

```
backend/
├── README.md                           # 📘 이 문서 (마스터 인덱스)
├── MIGRATION_STRATEGY.md               # 🎯 마이그레이션 전략 (큰 틀)
├── analysis/                           # 📊 현재 상태 분석
│   ├── entity_analysis.md              #    엔티티 패턴 분석 결과
│   ├── common_patterns.md              #    공통 패턴 추출
│   └── flutterflow_legacy.md           #    FlutterFlow 레거시 매핑
├── schemas/                            # 🎨 Zod 스키마 설계
│   ├── README.md                       #    Zod 스키마 가이드
│   ├── post_schema.ts                  #    Post/PostDisplay 스키마 예시
│   ├── chat_schema.ts                  #    Chat/Message 스키마 예시
│   ├── voting_schema.ts                #    Vote/PostVoting 스키마 예시
│   └── common_helpers.ts               #    공통 Helper 함수
└── codegen/                            # 🏗️ 코드 생성 파이프라인
    ├── README.md                       #    코드 생성 가이드
    ├── setup_guide.md                  #    Quicktype 설정 가이드
    └── package.json.example            #    npm scripts 예시
```

### 문서 읽는 순서

1. **현재 상태 파악** → `analysis/entity_analysis.md`
2. **전략 이해** → `MIGRATION_STRATEGY.md`
3. **스키마 설계** → `schemas/README.md`
4. **코드 생성 준비** → `codegen/README.md`

---

## 🚀 빠른 시작

### 1. 분석 결과 확인

완성된 Feature(Post, Chat, Voting)의 패턴 분석:

```bash
# 엔티티 비교 테이블 확인
cat backend/analysis/entity_analysis.md

# 공통 패턴 확인
cat backend/analysis/common_patterns.md

# FlutterFlow 레거시 확인
cat backend/analysis/flutterflow_legacy.md
```

### 2. 마이그레이션 전략 검토

```bash
# 3단계 실행 로드맵 확인
cat backend/MIGRATION_STRATEGY.md
```

### 3. Zod 스키마 예시 확인

```bash
# Post Feature 스키마 예시
cat backend/schemas/post_schema.ts

# Chat Feature 스키마 예시
cat backend/schemas/chat_schema.ts

# Voting Feature 스키마 예시
cat backend/schemas/voting_schema.ts
```

### 4. 코드 생성 파이프라인 준비

```bash
# Quicktype 설치 가이드
cat backend/codegen/setup_guide.md

# npm scripts 예시
cat backend/codegen/package.json.example
```

---

## 📊 현재 상태

### 완료된 Feature 분석 (Phase 1-5 완성)

| Feature | Entity | 필드 수 | FlutterFlow Legacy | 분석 완료 |
|---------|--------|--------|-------------------|----------|
| **Post** | PostDisplay | 30 | ✅ 5개 (userid, username, commentcount, likecount, sharecount) | ✅ |
| **Chat** | Chat | 17 | ❌ 없음 (Pure camelCase) | ✅ |
| **Chat** | Message | 45 | ❌ 없음 | ✅ |
| **Voting** | Vote | 4 | ❌ 없음 | ✅ |
| **Voting** | PostVoting | 23 | ❌ 없음 | ✅ |

**총 5개 엔티티, 119개 필드 분석 완료**

### 미완료 Feature (분석 대기 중)

- 🔄 **Creation** - 콘텐츠 생성 Feature
- 🔄 **Search** - 검색 Feature (Algolia 연동)
- 🔄 **Voting** - 투표 Feature (일부 엔티티만 완성)

### FlutterFlow 레거시 현황

**Critical Priority** (사용자 대면 필드):
- `userid` → `userId` (Post Feature)
- `username` → `userName` (Post Feature)

**Medium Priority** (메트릭 필드):
- `commentcount` → `commentCount` (Post Feature)
- `likecount` → `likeCount` (Post Feature)
- `sharecount` → `shareCount` (Post Feature)

**총 5개 레거시 필드 정리 필요**

---

## 🗺️ 마이그레이션 로드맵

### Phase 1: 나머지 Feature 마이그레이션 완성 (현재 진행 중)

**목표**: 모든 Feature를 Clean Architecture v4.0로 통일

- 🔄 Creation Feature Phase 1-5 (1주)
- 🔄 Search Feature Phase 1-5 (1주)
- 🔄 Voting Feature 완성 (1주)

**완료 조건**: 8개 Feature 모두 Phase 5 완료

### Phase 2: Backend 인프라 마이그레이션 (이 문서 적용)

**Step 1**: Cloud Functions TypeScript 전환 (1주)
- `firebase/functions/` JavaScript → TypeScript
- `tsconfig.json` 설정
- 기존 Functions 타입 추가

**Step 2**: Zod 스키마 정의 (2주)
- `firebase/functions/src/schemas/` 디렉토리 생성
- 8개 Feature의 모든 엔티티 Zod 스키마 작성
- 런타임 타입 검증 적용
- FlutterFlow 호환성 레이어

**Step 3**: Dart 코드 생성 파이프라인 구축 (1주)
- Quicktype 또는 커스텀 스크립트 설정
- TypeScript → Dart Freezed 자동 변환
- Extension Pattern 자동 생성
- CI/CD 통합

**Step 4**: FlutterFlow 레거시 정리 (1개월)
- Firestore 데이터 마이그레이션 (userid → userId)
- Extension dual-field 제거
- Cloud Functions 업데이트
- 점진적 배포 및 검증

**총 예상 기간**: 6-8주

### Phase 3: 검증 및 최적화 (1주)

- 전체 시스템 통합 테스트
- 성능 벤치마크
- 문서 업데이트
- 팀 교육 및 인수인계

---

## 📚 주요 개념

### Single Source of Truth (SSOT)

**Before** (현재):
```
Flutter Freezed Models (암묵적 스키마)
    ↕ (수동 동기화)
Cloud Functions (JavaScript, 타입 없음)
```

**After** (마이그레이션 후):
```
TypeScript + Zod Schema (명시적 스키마, SSOT)
    ↓ (자동 생성)
Flutter Freezed Models
    ↓ (자동 생성)
Extension Pattern (fromFirestore, toFirestore)
```

### 코드 생성 워크플로우

```bash
# 1. TypeScript 스키마 수정 (Single Source of Truth)
vim firebase/functions/src/schemas/post.schema.ts

# 2. Dart 코드 자동 생성
npm run generate:dart

# 3. Freezed 빌드
dart run build_runner build --delete-conflicting-outputs

# 4. 배포
firebase deploy --only functions
flutter run
```

### FlutterFlow 호환성

**이중 필드 지원 전략**:
```typescript
// TypeScript Schema
const postSchema = z.object({
  userId: z.string(),  // 표준 필드
  // Legacy support layer
  userid: z.string().optional(),  // FlutterFlow legacy
});

// Runtime normalization
function normalizePost(data: any) {
  return {
    userId: data.userId || data.userid,  // ← 자동 변환
    ...data,
  };
}
```

---

## 🔗 관련 문서

### 프로젝트 전체 문서
- [CLAUDE.md](/CLAUDE.md) - 프로젝트 전체 개요
- [Feature README](/lib/features/) - 각 Feature 문서

### Firebase 문서
- [Cloud Functions README](/firebase/functions/README.md)
- [Firestore Rules](/firebase/firestore.rules)
- [Firestore Indexes](/firebase/firestore.indexes.json)

### Feature Phase 문서
- [Post Feature Phase 5](/lib/features/post/PHASE_5_EXTENSION_PATTERN.md)
- [Chat Feature Phase 5](/lib/features/chat/PHASE_5_EXTENSION_PATTERN.md)

---

## ❓ FAQ

### Q1. 언제 이 문서를 사용하나요?

**A**: 나머지 Feature(Creation, Search, Voting) 마이그레이션이 완료된 후, Backend 인프라 마이그레이션을 시작할 때 사용합니다.

### Q2. 왜 지금 작성하나요?

**A**: 현재 완성된 Feature(Post, Chat, Voting)의 패턴을 분석하여, 나머지 Feature 마이그레이션 시 참조할 수 있도록 미리 설계합니다.

### Q3. FlutterFlow 레거시는 왜 남아있나요?

**A**: 프로젝트가 FlutterFlow로 시작했고, 기존 Firestore 데이터가 lowercase 필드명을 사용합니다. 하위 호환성을 위해 이중 필드 지원을 유지합니다.

### Q4. TypeScript로 전환하면 Dart와 동기화가 자동화되나요?

**A**: 네! TypeScript Zod 스키마를 정의하면, 코드 생성 파이프라인이 자동으로 Dart Freezed 모델과 Extension을 생성합니다.

### Q5. 마이그레이션 기간은 얼마나 걸리나요?

**A**: Backend 인프라 마이그레이션만 4주, FlutterFlow 레거시 정리까지 포함하면 총 6-8주 예상됩니다.

---

## 📝 기여 가이드

이 문서는 **읽기 전용(Read-only)** 참조 자료입니다.

### 문서 업데이트가 필요한 경우

1. 새로운 Feature 패턴 발견 시 → `analysis/` 업데이트
2. 스키마 설계 변경 시 → `schemas/` 업데이트
3. 코드 생성 프로세스 개선 시 → `codegen/` 업데이트
4. 마이그레이션 전략 수정 시 → `MIGRATION_STRATEGY.md` 업데이트

### 업데이트 프로세스

```bash
# 1. 문서 수정
vim backend/analysis/entity_analysis.md

# 2. Git commit
git add backend/
git commit -m "docs: Update entity analysis with new patterns"

# 3. Pull Request 생성
git push origin feature/update-backend-docs
```

---

**최종 업데이트**: 2025-11-02
**다음 업데이트 예정**: Phase 1 완료 후 (Creation/Search/Voting Feature 마이그레이션 완성)
