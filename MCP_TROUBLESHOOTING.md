# MCP 서버 문제 해결 가이드

## 현재 상황 요약 (2025-07-24)

### 완료된 작업
1. ✅ SuperClaude 3.0.0 설치됨 (default 프로필)
2. ✅ Magic 서버 패키지 설치 완료 (@21st-dev/magic@0.1.0)
3. ✅ 모든 MCP 서버 패키지 확인:
   - @21st-dev/magic@0.1.0
   - @modelcontextprotocol/server-everything@2025.7.1
   - @modelcontextprotocol/server-filesystem@2025.7.1
   - @modelcontextprotocol/server-memory@2025.4.25
   - @modelcontextprotocol/server-sequential-thinking@2025.7.1
   - @playwright/mcp@0.0.31
   - @upstash/context7-mcp@1.0.14
4. ✅ MCP 서버 경로를 절대 경로로 변경 완료

### 문제 증상
- MCP 서버들이 UI에서 "failed"로 표시됨
- 실제로는 일부 서버가 작동 중 (로그 확인 결과)
- EPIPE 에러 발생 후 연결 끊김

## 재시작 후에도 문제가 지속될 경우

### 1. 로그 실시간 모니터링
```bash
# 새 터미널에서 MCP 서버 로그 실시간 확인
tail -f /Users/g_black/Library/Logs/Claude/mcp-server-*.log
```

### 2. MCP 서버 개별 테스트
```bash
# 각 서버를 직접 실행해서 테스트
cd /Users/g_black/versus-cursor/mcp-servers

# Context7 테스트
npx @upstash/context7-mcp

# Sequential Thinking 테스트
npx @modelcontextprotocol/server-sequential-thinking

# Magic 테스트
npx @21st-dev/magic

# Playwright 테스트
npx @modelcontextprotocol/server-playwright
```

### 3. Node.js 버전 문제 해결
현재 Node.js v24.3.0은 매우 최신 버전입니다. LTS 버전으로 다운그레이드:
```bash
# nvm이 설치되어 있다면
nvm install 20
nvm use 20

# 또는 Node.js LTS 직접 설치
# https://nodejs.org/en/download/
```

### 4. MCP 서버 전체 재설치
```bash
cd /Users/g_black/versus-cursor/mcp-servers
rm -rf node_modules package-lock.json
npm install
```

### 5. Claude Code 설정 확인
```bash
# .claude.json 백업
cp /Users/g_black/.claude.json /Users/g_black/.claude.json.backup

# MCP 서버 설정 확인
cat /Users/g_black/.claude.json | jq '.mcpServers'
```

### 6. 수동으로 MCP 서버 경로 수정
`/Users/g_black/.claude.json`에서 (이미 절대 경로로 설정된 예시):
```json
"mcpServers": {
  "sequential-thinking": {
    "type": "stdio",
    "command": "/Users/g_black/versus-cursor/mcp-servers/node_modules/.bin/mcp-server-sequential-thinking",
    "args": [],
    "env": {}
  },
  "context7": {
    "type": "stdio",
    "command": "/Users/g_black/versus-cursor/mcp-servers/node_modules/.bin/context7-mcp",
    "args": [],
    "env": {}
  },
  "playwright": {
    "type": "stdio",
    "command": "/Users/g_black/versus-cursor/mcp-servers/node_modules/.bin/mcp-server-playwright",
    "args": [],
    "env": {}
  },
  "magic": {
    "type": "stdio",
    "command": "/Users/g_black/versus-cursor/mcp-servers/node_modules/.bin/magic",
    "args": [],
    "env": {}
  }
}
```

### 7. SuperClaude Developer 프로필로 재설치
```bash
# 현재 SuperClaude 실행 파일 위치
/Users/g_black/versus-cursor/superclaude-env/SuperClaude_Framework/.venv/bin/SuperClaude

# 업데이트 시도
SuperClaude update --components mcp --verbose

# 또는 완전 재설치
SuperClaude uninstall
SuperClaude install --profile developer --verbose
```

### 8. 권한 문제 확인
```bash
# MCP 서버 디렉토리 권한 확인
ls -la /Users/g_black/versus-cursor/mcp-servers/
ls -la /Users/g_black/.claude/

# 필요시 권한 수정
chmod -R 755 /Users/g_black/versus-cursor/mcp-servers/
```

### 9. 프로세스 충돌 확인
```bash
# 기존 MCP 프로세스 확인
ps aux | grep -E "(mcp|context7|magic|playwright|sequential)"

# 필요시 프로세스 종료
pkill -f "mcp-server"
```

### 10. 최후의 수단: 수동 MCP 비활성화
`/Users/g_black/.claude.json`에서 문제가 되는 서버만 임시 제거:
```json
{
  "mcpServers": {
    // "magic": { ... },  // 주석 처리
    "sequential-thinking": { ... },
    "context7": { ... },
    "playwright": { ... }
  }
}
```

## 절대 경로 설정 후에도 문제가 지속될 경우

### 1. Claude Code 완전 재시작
```bash
# 모든 Claude 관련 프로세스 종료
pkill -f "claude"
pkill -f "mcp"

# 터미널 완전히 닫고 새로 열기
# versus-cursor 디렉토리에서 다시 시작
cd /Users/g_black/versus-cursor
claude
```

### 2. MCP 서버 상태 직접 확인
```bash
# Claude Code 내에서 MCP 서버 상태 확인
# /status 명령어 입력 또는
# MCP 서버 아이콘 클릭해서 상태 확인
```

### 3. 로그에서 특정 에러 패턴 확인
```bash
# EPIPE 에러 확인
grep -n "EPIPE" ~/Library/Logs/Claude/mcp-server-*.log

# Connection refused 에러 확인
grep -n "ECONNREFUSED" ~/Library/Logs/Claude/mcp-server-*.log

# Timeout 에러 확인
grep -n "timeout" ~/Library/Logs/Claude/mcp-server-*.log
```

### 4. Claude Code 캐시 및 설정 초기화
```bash
# Claude Code 캐시 삭제
rm -rf ~/Library/Caches/com.anthropic.claude-code
rm -rf ~/.cache/claude-code

# 세션 데이터 초기화 (주의: 대화 기록이 삭제됨)
rm -rf ~/.claude/sessions
```

### 5. 환경 변수 확인
```bash
# MCP 관련 환경 변수 확인
echo $MCP_TIMEOUT
echo $MCP_TOOL_TIMEOUT

# 필요시 설정 (30초 타임아웃)
export MCP_TIMEOUT=30000
export MCP_TOOL_TIMEOUT=30000
```

### 6. 네트워크 및 방화벽 체크
```bash
# 로컬 포트 사용 확인
lsof -i :3000-4000

# 방화벽 상태 확인 (macOS)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
```

### 7. Claude Code 버전 확인
```bash
# Claude Code 버전 확인
claude --version

# 최신 버전으로 업데이트
# https://claude.ai/download 에서 최신 버전 다운로드
```

### 8. Node.js 실행 환경 재설정
```bash
# Node.js 캐시 정리
npm cache clean --force

# Global 패키지 정리
npm list -g --depth=0

# Node.js 재설치 (Homebrew)
brew reinstall node@20
brew link --overwrite --force node@20
```

## 디버깅 정보 수집
문제가 지속되면 다음 정보 수집:
1. `npm list --depth=0` 출력
2. `node --version` 및 `npm --version`
3. `/Users/g_black/Library/Logs/Claude/mcp-server-*.log` 마지막 50줄
4. `ps aux | grep mcp` 출력

## 자주 발생하는 문제와 해결책

### EPIPE 에러
**증상**: 로그에 "EPIPE" 에러 표시, MCP 서버가 갑자기 연결 끊김
**해결책**:
```bash
# 1. Node.js 버전 확인 (v20 LTS 권장)
node --version

# 2. MCP 서버 재설치
cd /Users/g_black/versus-cursor/mcp-servers
rm -rf node_modules package-lock.json
npm install

# 3. 환경 변수 설정
export NODE_OPTIONS="--max-old-space-size=4096"
```

### 서버 시작 타임아웃
**증상**: MCP 서버가 시작되지 않고 timeout 발생
**해결책**:
```bash
# 타임아웃 시간 늘리기
export MCP_TIMEOUT=60000  # 60초
export MCP_TOOL_TIMEOUT=60000
```

### 권한 문제
**증상**: Permission denied 에러
**해결책**:
```bash
# 실행 권한 부여
chmod +x /Users/g_black/versus-cursor/mcp-servers/node_modules/.bin/*
```

### Node.js 버전 충돌
**증상**: Module version mismatch 에러
**해결책**:
```bash
# Node.js LTS 버전 사용
brew install node@20
brew link --overwrite --force node@20

# npm rebuild
cd /Users/g_black/versus-cursor/mcp-servers
npm rebuild
```

## SuperClaude 가상환경 FAQ

### Q: SuperClaude를 프로젝트 가상환경에 설치했는데 문제가 되나요?
**A: 아니요, 전혀 문제없습니다.**
- SuperClaude는 단순히 설정 파일을 관리하는 도구입니다
- 실제 설정은 `~/.claude/` 디렉토리에 전역으로 저장됩니다
- MCP 서버 연결과는 무관합니다

### Q: MCP 서버도 프로젝트 디렉토리에 설치했는데 괜찮나요?
**A: 네, 오히려 권장되는 방법입니다.**
- 프로젝트별로 필요한 MCP 서버만 설치 가능
- 버전 관리가 용이함
- 절대 경로로 설정하면 안정적으로 작동

### Q: 가상환경을 삭제하면 SuperClaude 설정도 사라지나요?
**A: 아니요, 설정은 유지됩니다.**
- SuperClaude 설정은 `~/.claude/` 디렉토리에 저장
- 가상환경은 SuperClaude 실행 파일만 포함
- 설정 파일은 별도로 백업/관리 가능

## 주요 파일 위치
- MCP 서버 설치: `/Users/g_black/versus-cursor/mcp-servers/`
- Claude 설정: `/Users/g_black/.claude.json`
- SuperClaude: `/Users/g_black/versus-cursor/superclaude-env/SuperClaude_Framework/`
- 로그 파일: `/Users/g_black/Library/Logs/Claude/`

---
마지막 업데이트: 2025-07-24
문제: MCP 서버 연결 실패 (UI에 "failed" 표시)