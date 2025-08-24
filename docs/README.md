# 📚 Versus Space 문서 센터

## 📋 개요

Versus Space 프로젝트의 모든 기술 문서, 가이드, 템플릿을 중앙 집중식으로 관리하는 문서 센터입니다. 개발 가이드, 시스템 아키텍처, 마이그레이션 기록 등 프로젝트의 지식 베이스 역할을 합니다.

### 디렉토리 상태
- **상태**: ✅ **활성 관리중**
- **중요도**: ⭐⭐⭐⭐⭐
- **용도**: 프로젝트 문서화 및 지식 관리
- **권장사항**: 지속적인 업데이트 필요

## 🎯 네이밍 컨벤션

문서 파일명은 다음 규칙을 따릅니다:

| 구분 | 컨벤션 | 예시 | 설명 |
|------|--------|------|------|
| **가이드 문서** | UPPER_SNAKE_CASE.md | `DOCUMENTATION_GUIDE.md` | 주요 가이드 |
| **템플릿** | UPPER_SNAKE_CASE_TEMPLATE.md | `README_TEMPLATE.md` | 템플릿 파일 |
| **시스템 문서** | UPPER_SNAKE_CASE_SYSTEM.md | `VOTE_NOTIFICATION_SYSTEM.md` | 시스템 설명 |
| **아카이브** | archive/ | `archive/field_mappings.json` | 과거 자료 |

참조: [NAMING_CONVENTION.md](./guides/NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
docs/
├── 📄 README.md                         # 이 파일 (문서 센터 안내)
│
├── 📚 개발 가이드 (Development Guides)
│   ├── TMUX_FLUTTER_GUIDE.md           # iTerm2 + tmux 멀티 디바이스 개발
│   ├── TMUX_QUICK_START.md             # tmux 빠른 시작 가이드
│   └── INTEGRATION_TEST_GUIDE.md       # 통합 테스트 가이드
│
├── 📖 시스템 문서 (System Documentation)
│   ├── VOTE_NOTIFICATION_SYSTEM.md     # 투표 알림 시스템 (핵심)
│   └── testing_notification_system.md  # 알림 시스템 테스트 가이드
│
├── 📝 문서화 도구 (Documentation Tools)
│   ├── DOCUMENTATION_GUIDE.md          # 문서 관리 가이드
│   └── README_TEMPLATE.md              # README 템플릿
│
└── 📦 archive/                         # 마이그레이션 아카이브
    ├── field_mappings.json              # snake_case → camelCase 매핑 (765개)
    ├── migrate_fields.js                # JavaScript 마이그레이션 스크립트
    ├── migrate_fields.dart              # Dart 마이그레이션 스크립트
    ├── migration_analysis.json          # 마이그레이션 분석 결과
    ├── js_patterns.txt                  # JavaScript 패턴 분석
    ├── dart_patterns.txt                # Dart 패턴 분석
    ├── all_dart_patterns.txt            # 전체 Dart 패턴
    ├── rules_patterns.txt               # Rules 패턴 분석
    ├── json_patterns.txt                # JSON 패턴 분석
    ├── unique_snake_fields.txt          # 고유 snake_case 필드 목록
    ├── field_mappings.txt               # 텍스트 형식 매핑
    ├── frequency_analysis.txt           # 빈도 분석
    └── location_report.txt              # 위치 보고서
```

## 🔧 주요 문서 상세

### 1. TMUX_FLUTTER_GUIDE.md ⭐⭐⭐⭐⭐
**멀티 디바이스 개발 환경 구축 가이드**

- **목적**: iTerm2 + tmux를 활용한 효율적인 Flutter 개발 환경
- **주요 내용**:
  - 멀티 디바이스 동시 실행 (`fdev` 명령)
  - tmux 세션 관리 및 단축키
  - Flutter 개발 명령어 모음
  - 프로젝트 바로가기 설정

**핵심 명령어**:
```bash
# 모든 디바이스에서 앱 실행
fdev

# Versus Space 개발 세션
tmux-versus

# 프로젝트 이동
versus           # 루트로 이동
versus-func      # Functions로 이동
```

### 2. VOTE_NOTIFICATION_SYSTEM.md ⭐⭐⭐⭐⭐
**AI 기반 투표 알림 시스템 완전 가이드**

- **목적**: 핵심 비즈니스 로직인 투표 알림 시스템 문서화
- **주요 내용**:
  - 시스템 아키텍처
  - AI 타겟팅 알고리즘
  - 데이터 플로우
  - 성능 최적화 전략
  - 모니터링 및 테스트

**시스템 구성**:
```
Flutter App → Firebase Functions → Gemini AI
     ↓              ↓                  ↓
Firestore    Target Matching    Notifications
```

### 3. DOCUMENTATION_GUIDE.md ⭐⭐⭐⭐⭐
**프로젝트 문서 관리 표준**

- **목적**: 일관된 문서화를 위한 가이드라인
- **주요 내용**:
  - 문서 구조 표준
  - README 작성 규칙
  - 검증 도구 사용법
  - 자동화 스크립트

**검증 명령어**:
```bash
# 네이밍 컨벤션 검사
./scripts/check_naming.sh

# 문서 품질 검증
./scripts/validate_docs.sh
```

### 4. README_TEMPLATE.md ⭐⭐⭐⭐
**표준 README 템플릿**

- **목적**: 모든 디렉토리 README의 일관성 유지
- **구성 요소**:
  - 개요 섹션
  - 네이밍 컨벤션
  - 디렉토리 구조
  - 주요 구성요소
  - 사용 예시
  - 변경 이력

## 📦 아카이브 분류

### ✅ 보관 필요 (역사적 가치)
**마이그레이션 기록으로 보관**

| 파일 | 설명 | 이유 |
|------|------|------|
| `field_mappings.json` | 765개 필드 매핑 데이터 | 완전한 매핑 기록 |
| `migration_analysis.json` | 마이그레이션 분석 결과 | 프로젝트 진화 기록 |
| `migrate_fields.js/dart` | 마이그레이션 스크립트 | 참조용 코드 |

### ⚠️ 검토 필요
**6개월 후 삭제 검토**

| 파일 | 설명 | 검토 시기 |
|------|------|----------|
| `*_patterns.txt` | 패턴 분석 파일들 | 2026-02 |
| `frequency_analysis.txt` | 빈도 분석 | 2026-02 |
| `location_report.txt` | 위치 보고서 | 2026-02 |

## 💡 사용 가이드

### 새 문서 작성 시
1. `README_TEMPLATE.md` 복사
2. 해당 디렉토리에 맞게 수정
3. 네이밍 컨벤션 준수
4. 검증 스크립트 실행

### 문서 업데이트 시
1. 변경 이력 섹션 업데이트
2. 날짜 및 버전 명시
3. 관련 문서 링크 확인
4. index_document.md 반영

## 🔍 문서 검색 가이드

### 주제별 검색
- **개발 환경**: TMUX_*.md
- **시스템 설계**: *_SYSTEM.md
- **가이드**: *_GUIDE.md
- **템플릿**: *_TEMPLATE.md

### 우선순위별
1. **필수 읽기**: DOCUMENTATION_GUIDE.md
2. **개발 시작**: TMUX_FLUTTER_GUIDE.md
3. **시스템 이해**: VOTE_NOTIFICATION_SYSTEM.md
4. **테스트**: INTEGRATION_TEST_GUIDE.md

## 📊 문서 현황

| 카테고리 | 문서 수 | 상태 | 최신 업데이트 |
|----------|---------|------|---------------|
| **개발 가이드** | 3개 | ✅ 활성 | 2025-08-21 |
| **시스템 문서** | 2개 | ✅ 활성 | 2025-08-20 |
| **문서화 도구** | 2개 | ✅ 활성 | 2025-08-21 |
| **아카이브** | 13개 | 📦 보관 | 2025-08-21 |

## 📝 변경 이력

### 2025-08-21: 문서 센터 구축
- docs 디렉토리 통합 문서화
- 문서 분류 및 정리
- 아카이브 평가 완료

### 2025-08-20: 알림 시스템 문서화
- VOTE_NOTIFICATION_SYSTEM.md 작성
- 테스트 가이드 추가

### 2025-08-19: 개발 환경 가이드
- TMUX_FLUTTER_GUIDE.md 작성
- 멀티 디바이스 개발 지원

## 🎯 향후 계획

### 단기 (1개월)
1. **API 문서 자동화** - OpenAPI 스펙 생성
2. **다이어그램 추가** - 시스템 아키텍처 시각화
3. **검색 기능** - 문서 내 검색 도구

### 중기 (3개월)
1. **다국어 지원** - 영어/한국어 병행
2. **버전 관리** - 문서 버저닝 시스템
3. **자동 동기화** - 코드-문서 동기화

### 장기 (6개월)
1. **문서 사이트** - 정적 사이트 생성
2. **인터랙티브 가이드** - 실습형 튜토리얼
3. **AI 문서 생성** - 자동 문서화 도구

## 🔗 관련 링크

### 내부 문서
- [프로젝트 개요](../README.md)
- [기술 상세](../CLAUDE.md)
- [네이밍 컨벤션](./guides/NAMING_CONVENTION.md)
- [시스템 아키텍처](../ARCHITECTURE.md)

### 검증 도구
- [네이밍 검사](../scripts/check_naming.sh)
- [문서 검증](../scripts/validate_docs.sh)
- [문서화 인덱스](../index_document.md)

---

*이 문서 센터는 Versus Space 프로젝트의 지식 관리 허브입니다.*

**마지막 업데이트**: 2025-08-21  
**문서 버전**: 1.0.0  
**관리자**: Versus Space Documentation Team