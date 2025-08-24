# 🤖 MCP Servers - Model Context Protocol 서버 설정

## ⚡ 디렉토리 상태: CRITICAL (필수 유지)

> **중요**: 이 디렉토리는 SuperClaude와 Claude Code의 핵심 기능을 제공하는 MCP 서버들을 포함하고 있으며, **절대 삭제하면 안 됩니다**.

## 📋 개요

MCP(Model Context Protocol) 서버들을 위한 Node.js 패키지 디렉토리입니다. SuperClaude 프레임워크와 통합되어 Claude Code에 고급 기능을 제공합니다. 이 디렉토리는 claude_desktop_config.json과 연동되어 실시간으로 MCP 서버들을 구동합니다.

### SuperClaude 통합
SuperClaude 프레임워크의 MCP.md에 정의된 대로, 이 서버들은 다음과 같이 활용됩니다:
- **자동 활성화**: 작업 유형에 따라 자동으로 MCP 서버 선택
- **폴백 전략**: 서버 실패 시 대체 솔루션 자동 적용
- **캐싱 최적화**: 문서 조회 및 분석 결과 캐싱

## 🎯 네이밍 컨벤션
- **패키지명**: kebab-case (npm 표준) - `mcp-servers`
- **의존성**: @스코프/패키지명 형식 - `@modelcontextprotocol/server-*`
- **버전**: 날짜 기반 시맨틱 버저닝 - `2025.7.1`
- 참조: [NAMING_CONVENTION.md](../NAMING_CONVENTION.md)

## 🏗️ 구조

```
mcp-servers/
├── package.json           # MCP 서버 의존성 정의
├── package-lock.json      # 의존성 잠금 파일
├── node_modules/          # 설치된 MCP 서버 모듈들
└── README.md             # 이 문서
```

## 🔧 주요 구성요소

### 1. 설치된 MCP 서버들

#### @21st-dev/magic (v0.1.0)
**용도**: UI 컴포넌트 자동 생성
- React, Vue, Angular 컴포넌트 생성
- 디자인 시스템 통합
- SuperClaude의 `/build`, `/design` 명령어와 연동

#### @modelcontextprotocol/server-everything (v2025.7.1)
**용도**: 통합 MCP 서버 (모든 기능 포함)
- 파일시스템, 메모리, 프로세스 관리
- 개발 환경 완전 제어
- SuperClaude의 기본 서버

#### @modelcontextprotocol/server-filesystem (v2025.7.1)
**용도**: 파일시스템 접근 및 조작
- 파일 읽기/쓰기/수정
- 디렉토리 탐색 및 관리
- 권한 제어 및 보안

#### @modelcontextprotocol/server-memory (v2025.4.25)
**용도**: 메모리 상태 관리
- 세션 간 데이터 유지
- 컨텍스트 보존
- 캐시 관리

#### @modelcontextprotocol/server-sequential-thinking (v2025.7.1)
**용도**: 체계적 문제 해결
- 복잡한 문제 단계별 분석
- Chain of Thought 구현
- SuperClaude의 `--think`, `--seq` 플래그와 연동

#### @playwright/mcp (v0.0.31)
**용도**: 브라우저 자동화 및 테스팅
- E2E 테스트 자동화
- 웹 스크래핑
- UI 상호작용 테스트
- SuperClaude의 `--play` 플래그와 연동

#### @upstash/context7-mcp (v1.0.14)
**용도**: 문서 및 컨텍스트 관리
- 라이브러리 문서 조회
- 코드 패턴 검색
- SuperClaude의 `--c7` 플래그와 연동

## 💡 SuperClaude 통합 매핑

### 명령어 → MCP 서버 매핑
```yaml
/build:
  - @21st-dev/magic (UI 컴포넌트)
  - @upstash/context7-mcp (패턴 참조)

/analyze:
  - @modelcontextprotocol/server-sequential-thinking (분석)
  - @upstash/context7-mcp (문서 참조)

/test:
  - @playwright/mcp (E2E 테스팅)
  - @modelcontextprotocol/server-filesystem (파일 접근)

/troubleshoot:
  - @modelcontextprotocol/server-sequential-thinking (문제 분석)
  - @modelcontextprotocol/server-memory (상태 추적)
```

### 플래그 → MCP 서버 매핑
```yaml
--seq: @modelcontextprotocol/server-sequential-thinking
--c7: @upstash/context7-mcp
--play: @playwright/mcp
--magic: @21st-dev/magic
--all-mcp: 모든 서버 동시 활성화
```

## 🚀 사용 방법

### 설치
```bash
cd mcp-servers
npm install
```

### 업데이트
```bash
npm update
```

### 버전 확인
```bash
npm list --depth=0
```

## ⚠️ 주의사항

### 절대 삭제 금지
> **경고**: 이 디렉토리를 삭제하면 SuperClaude와 Claude Code의 핵심 기능이 작동하지 않습니다.

### 필수 요구사항
- Node.js 18.0 이상
- npm 9.0 이상
- claude_desktop_config.json에서 경로 설정 필요

### 보안 고려사항
- MCP 서버는 시스템 리소스에 접근 가능
- 신뢰할 수 있는 서버만 설치
- 정기적인 보안 업데이트 필요

## 🔄 업데이트 전략

### 자동 업데이트 비활성화 권장
```json
// package.json에서 고정 버전 사용
"@playwright/mcp": "0.0.31"  // ^제거로 고정
```

### 수동 업데이트 프로세스
1. 변경 로그 확인
2. 테스트 환경에서 검증
3. 프로덕션 적용

## 🐛 문제 해결

### MCP 서버 연결 실패
```bash
# 서버 재설치
npm ci

# 권한 문제 해결
chmod +x node_modules/.bin/*
```

### 메모리 부족
```bash
# Node.js 메모리 증가
export NODE_OPTIONS="--max-old-space-size=4096"
```

### 버전 충돌
```bash
# 캐시 정리 및 재설치
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
```

## 📊 디렉토리 통계

| 항목 | 수치 | 설명 |
|------|------|------|
| **MCP 서버 수** | 7개 | 각각 특수 기능 제공 |
| **총 의존성** | 100+ | 트랜지티브 의존성 포함 |
| **디스크 사용** | ~200MB | node_modules 포함 |
| **중요도** | ⭐⭐⭐⭐⭐ | 핵심 기능 제공 |

## 🔗 관련 문서

### SuperClaude 문서
- [MCP.md](~/.claude/MCP.md) - MCP 서버 통합 가이드
- [COMMANDS.md](~/.claude/COMMANDS.md) - 명령어-서버 매핑
- [FLAGS.md](~/.claude/FLAGS.md) - 플래그-서버 매핑

### 공식 문서
- [Model Context Protocol](https://modelcontextprotocol.io)
- [Playwright MCP](https://github.com/playwright/mcp)
- [Context7 Documentation](https://context7.dev)

## 📝 변경 이력
- 2025-08-24: README 문서 생성
- 2025-07-01: 초기 MCP 서버 설치
- 2025-06-15: SuperClaude 통합 구성

---

*이 디렉토리는 Versus Space 프로젝트의 개발 생산성을 위한 필수 인프라입니다.*