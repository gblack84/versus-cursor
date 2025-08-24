# 📚 Versus Space 문서 관리 가이드

## 🎯 목적
이 가이드는 Versus Space 프로젝트의 문서를 일관되고 효과적으로 관리하기 위한 지침을 제공합니다.

## 📋 문서 구조

### 루트 문서
```
/
├── README.md                 # 프로젝트 소개 및 시작 가이드
├── CLAUDE.md                 # 프로젝트 상세 기술 문서
├── ARCHITECTURE.md           # 시스템 아키텍처
├── CHANGELOG.md              # 변경 이력
└── CLAUDE.md                 # 프로젝트 상세 기술 문서
```

### 디렉토리별 README
각 주요 디렉토리는 자체 README.md를 포함해야 합니다:
- `/lib/[directory]/README.md` - 각 기능 디렉토리
- `/firebase/[directory]/README.md` - Firebase 관련
- `/docs/[topic]/README.md` - 상세 문서

## 🔧 문서 관리 도구

### 1. 네이밍 컨벤션 검사
```bash
# 전체 프로젝트 네이밍 컨벤션 검사
./scripts/check_naming.sh

# 특정 디렉토리만 검사
./scripts/check_naming.sh lib/services
```

### 2. 문서 검증
```bash
# 문서 완성도 및 일관성 검사
./scripts/validate_docs.sh
```

### 3. 코드-문서 동기화
```bash
# 동기화 상태 확인
./scripts/sync_docs.sh check

# 자동 업데이트
./scripts/sync_docs.sh update
```

## 📝 문서 작성 가이드

### README 템플릿 사용
새 디렉토리 생성 시 템플릿 사용:
```bash
cp docs/README_TEMPLATE.md lib/new_feature/README.md
```

### 필수 섹션
모든 README는 다음 섹션을 포함해야 합니다:
1. **개요** - 목적과 기능 설명
2. **네이밍 컨벤션** - docs/guides/NAMING_CONVENTION.md 참조
3. **주요 구성요소** - 파일 및 클래스 목록
4. **사용 예시** - 코드 샘플
5. **변경 이력** - 주요 업데이트 날짜

### 네이밍 규칙
- **파일명**: snake_case (예: `user_service.dart`)
- **Firestore 필드**: camelCase (예: `userId`, `createdAt`)
- **클래스명**: PascalCase (예: `UserService`)
- **상수**: SCREAMING_SNAKE_CASE (예: `MAX_RETRY_COUNT`)

## 🔄 문서 업데이트 프로세스

### 1. 코드 변경 시
- 관련 README 업데이트
- CHANGELOG.md에 변경사항 기록
- Breaking change인 경우 CHANGELOG.md에 Breaking Changes 섹션 추가

### 2. 새 기능 추가 시
1. 해당 디렉토리에 README.md 생성
2. 템플릿 기반으로 내용 작성
3. 상위 README에 링크 추가

### 3. 리팩토링 시
1. 리팩토링 계획 수립
2. 완료 후 문서 업데이트
3. 영향받는 모든 README 수정

## 🚀 CI/CD 통합

### Pre-commit Hook 설정
```bash
# .git/hooks/pre-commit 파일 생성
#!/bin/bash
./scripts/check_naming.sh
./scripts/validate_docs.sh
```

### GitHub Actions (권장)
```yaml
# .github/workflows/docs-check.yml
name: Documentation Check
on: [push, pull_request]
jobs:
  check-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Check Naming Convention
        run: ./scripts/check_naming.sh
      - name: Validate Documentation
        run: ./scripts/validate_docs.sh
      - name: Check Sync Status
        run: ./scripts/sync_docs.sh check
```

## 📊 문서 품질 지표

### 완성도 체크리스트
- [ ] 모든 디렉토리에 README 존재
- [ ] 네이밍 컨벤션 100% 준수
- [ ] 코드와 문서 동기화
- [ ] 링크 유효성 확인
- [ ] 3개월 이내 업데이트

### 자동 검사 결과
```bash
# 전체 문서 상태 확인
./scripts/validate_docs.sh && ./scripts/check_naming.sh && ./scripts/sync_docs.sh check
```

## 🗂️ 아카이브 정책

### 구식 문서 처리
1. 3개월 이상 미수정 문서 검토
2. 더 이상 유효하지 않은 문서는 `/docs/archive/`로 이동
3. 마이그레이션 완료 문서는 참조용으로만 유지

### 삭제 기준
- 중복 문서
- 임시 문서 (FIXED, TEMP 등)
- 완료된 마이그레이션 세부 문서

## 💡 베스트 프랙티스

### DO ✅
- 코드 변경 즉시 문서 업데이트
- 템플릿 사용으로 일관성 유지
- 명확하고 간결한 설명
- 실제 코드 예시 포함
- 정기적인 문서 검증

### DON'T ❌
- 오래된 정보 방치
- 중복 문서 생성
- 코드와 문서 불일치
- 네이밍 컨벤션 무시
- 빈 README 방치

## 📅 정기 점검

### 주간
- 새로 생성된 디렉토리 README 확인
- 최근 변경 코드의 문서 동기화

### 월간
- 전체 문서 검증 (`./scripts/validate_docs.sh`)
- 오래된 문서 업데이트 또는 아카이브
- 깨진 링크 수정

### 분기별
- 문서 구조 전체 검토
- 기술 부채 발생 시 문서화
- 아카이브 정리

## 🆘 문제 해결

### 문서 불일치 발견 시
1. `./scripts/sync_docs.sh check`로 확인
2. `./scripts/sync_docs.sh update`로 자동 수정
3. 수동으로 세부 내용 업데이트

### 네이밍 컨벤션 위반 시
1. `./scripts/check_naming.sh`로 위반 사항 확인
2. docs/guides/NAMING_CONVENTION.md 참조하여 수정
3. 관련 문서 업데이트

## 📞 지원

문서 관련 질문이나 개선 제안은 다음을 참조:
- 기술 문서: [CLAUDE.md](../CLAUDE.md)
- 네이밍 표준: [NAMING_CONVENTION.md](./guides/NAMING_CONVENTION.md)
- 아키텍처: [ARCHITECTURE.md](../ARCHITECTURE.md)

---
*최종 업데이트: 2025-08-22*