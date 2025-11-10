# package.json.example 사용 가이드

> **Backend Phase 2 - npm Scripts Reference**
> **작성일**: 2025-11-10
> **파일**: `firebase/functions/package.json`

---

## 📦 설치 방법

### 1. package.json 복사

```bash
cd firebase/functions
cp ../../backend/codegen/package.json.example package.json
```

### 2. 의존성 설치

```bash
npm install
```

### 3. Firebase 초기화 (최초 1회)

```bash
cd ../..
firebase login
firebase init functions
# → Use existing project 선택
# → TypeScript 선택
# → ESLint 활성화
```

---

## 🚀 주요 스크립트

### Build & Development

| Script | 명령어 | 용도 |
|--------|--------|------|
| `npm run build` | `tsc` | TypeScript 빌드 |
| `npm run watch` | `tsc --watch` | 자동 재빌드 |
| `npm run dev` | `npm run watch` | 개발 모드 |
| `npm run dev:emulator` | 빌드 + Emulator 시작 | 로컬 테스트 |
| `npm run dev:full` | Watch + Serve 동시 실행 | 전체 개발 환경 |

**사용 예시**:

```bash
# 개발 시작
npm run dev:full

# 다른 터미널에서 함수 호출 테스트
firebase functions:shell
```

### Firebase Deploy

| Script | 명령어 | 용도 |
|--------|--------|------|
| `npm run deploy` | Firebase Functions 배포 | 기본 프로젝트 |
| `npm run deploy:prod` | Production 배포 | 프로덕션 환경 |
| `npm run logs` | Functions 로그 조회 | 전체 로그 |
| `npm run logs:tail` | 실시간 로그 | 최근 1분 |

**사용 예시**:

```bash
# 개발 환경 배포
npm run build
npm run deploy

# 프로덕션 배포 (주의!)
npm run build
npm run lint
npm test
npm run deploy:prod
```

### Code Generation (Backend Phase 2)

| Script | 명령어 | 용도 |
|--------|--------|------|
| `npm run generate:dart` | Quicktype 전체 실행 | 모든 Dart 모델 생성 |
| `npm run generate:all` | Dart + Freezed 빌드 | 전체 파이프라인 |
| `npm run generate:validate` | 생성 검증 | 모델 유효성 검사 |

**사용 예시**:

```bash
# 전체 모델 생성 (추천)
npm run generate:all

# 출력:
# ✅ lib/features/voting/domain/models/vote.dart
# ✅ lib/features/voting/domain/models/post_voting.dart
# ✅ Freezed 빌드 완료
```

**단일 모델 생성**:

```bash
# 환경 변수 사용
SCHEMA=voting_schema FEATURE=voting MODEL=vote npm run generate:dart:single

# 결과:
# lib/features/voting/domain/models/vote.dart 생성됨
```

### Code Quality

| Script | 명령어 | 용도 |
|--------|--------|------|
| `npm run lint` | ESLint 검사 | 코드 스타일 검사 |
| `npm run lint:fix` | ESLint 자동 수정 | 수정 가능한 문제 자동 처리 |
| `npm run typecheck` | TypeScript 타입 검사 | 컴파일 없이 타입만 |
| `npm run format` | Prettier 포맷팅 | 코드 포맷팅 |
| `npm run format:check` | 포맷 검사 | CI 용도 |

**사용 예시**:

```bash
# Pre-commit 검사
npm run lint
npm run typecheck
npm test

# 자동 수정
npm run lint:fix
npm run format
```

### Testing

| Script | 명령어 | 용도 |
|--------|--------|------|
| `npm test` | Jest 전체 테스트 | 모든 테스트 실행 |
| `npm run test:watch` | Watch 모드 | 파일 변경 시 자동 실행 |
| `npm run test:coverage` | 커버리지 리포트 | 테스트 커버리지 |
| `npm run test:unit` | 단위 테스트만 | Unit 테스트 |
| `npm run test:integration` | 통합 테스트만 | Integration 테스트 |

**사용 예시**:

```bash
# 개발 중
npm run test:watch

# CI 환경
npm run test:coverage
```

### Migration Scripts

| Script | 명령어 | 용도 |
|--------|--------|------|
| `npm run migrate:add-camelcase` | camelCase 필드 추가 | FlutterFlow 호환 |
| `npm run migrate:remove-legacy` | 레거시 필드 제거 | 정리 작업 |
| `npm run migrate:validate` | 마이그레이션 검증 | 완료 확인 |
| `npm run migrate:dry-run` | 시뮬레이션 | 실제 적용 전 테스트 |

**사용 예시**:

```bash
# Dry-run으로 먼저 확인
npm run migrate:dry-run

# 문제 없으면 실제 실행
npm run migrate:add-camelcase

# 검증
npm run migrate:validate
```

### Validation (Phase 2)

| Script | 명령어 | 용도 |
|--------|--------|------|
| `npm run validate:schemas` | Zod schema 검증 | TypeScript 스키마 |
| `npm run validate:dart` | Dart 검증 | Flutter analyze + test |
| `npm run validate:all` | 전체 검증 | 전체 파이프라인 |

**사용 예시**:

```bash
# Phase 2 완료 전 검증
npm run validate:all

# 출력:
# ✅ All Zod schemas valid
# ✅ dart analyze: no issues found
# ✅ flutter test: 120 passing
```

---

## 🔄 워크플로 예시

### 1. 새로운 기능 개발

```bash
# 1. 개발 환경 시작
npm run dev:full

# 2. Zod schema 작성
# src/schemas/new_feature_schema.ts

# 3. Dart 모델 생성
npm run generate:all

# 4. Extension 수동 작성
# lib/features/new_feature/domain/entities/new_feature_extensions.dart

# 5. 테스트
npm test
flutter test

# 6. 배포
npm run deploy
```

### 2. Phase 2 Migration

```bash
# 1. TypeScript 변환
mv index.js index.ts

# 2. Zod 통합
# import { VoteSchema } from './schemas/voting_schema';

# 3. 빌드 테스트
npm run build

# 4. Dart 모델 생성
npm run generate:all

# 5. 검증
npm run validate:all

# 6. 배포
npm run deploy
```

### 3. CI/CD Pipeline

```bash
# .github/workflows/firebase-deploy.yml
jobs:
  deploy:
    steps:
      - name: Install dependencies
        run: npm install

      - name: Lint & Type check
        run: |
          npm run lint
          npm run typecheck

      - name: Test
        run: npm run test:coverage

      - name: Build
        run: npm run build

      - name: Deploy
        run: npm run deploy
```

---

## 🔗 관련 파일

- `scripts/generate-dart-models.js` - Quicktype 스크립트
- `scripts/validate-zod-schemas.js` - Zod 검증
- `tsconfig.json` - TypeScript 설정
- `.eslintrc.js` - ESLint 설정

---

**최종 업데이트**: 2025-11-10
