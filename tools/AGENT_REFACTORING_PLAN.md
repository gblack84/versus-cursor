# Claude-Centric Agent System Refactoring Plan
> 생성일: 2025-01-21 | 버전: 1.1.0
> 목적: 모든 에이전트/도구를 Claude 중심 아키텍처로 전환
> 최종 수정: 2025-01-21 | 실행 가능성 검증 완료

## 📌 실행 상태
- [x] Phase 1: 출력 표준화 (✅ 완료 - 8개 도구 모두 JSON 출력)
- [x] Phase 2: 에이전트 문서 수정 (✅ 완료 - 8개 에이전트 .md 파일 Claude-centric으로 변경)
- [x] Phase 3: 오케스트레이션 패턴 (✅ 완료 - orchestration_utils.py 및 CHAINING_RULES.md 생성)
- [x] Phase 4: 테스트 및 검증 (✅ 완료 - test_outputs.py, test_pipeline.py 생성)
- [x] Phase 5: 점진적 마이그레이션 (✅ 완료 - --output stdout 지원, orchestrator-pipeline 구현)

## 🎯 핵심 목표

### 개념적 전환
- **Before**: User-Centric (사용자를 위한 텍스트 보고서)
- **After**: Claude-Centric (Claude가 파싱할 구조화된 데이터)

### 아키텍처 원칙 (ARCHITECTURE_RULES.md 준수)
1. **비즈니스 트랜잭션 단위**: UseCase는 완전한 트랜잭션 단위로 구성
2. **레이어 분리**: 데이터 처리(도구) → 로직(Claude) → 표현(사용자)
3. **단방향 의존성**: 도구 → Claude → 사용자 (역방향 금지)
4. **구조화된 통신**: 모든 데이터는 JSON/YAML 형식

## 📋 Phase 1: 출력 표준화 (우선순위: 높음)

### 1.1 표준 출력 스키마 정의

#### 공통 출력 구조
```json
{
  "agent": "string",           // 에이전트 이름
  "version": "string",          // 스키마 버전 (1.0.0)
  "timestamp": "ISO-8601",      // 실행 시간
  "status": "enum",             // success|fail|partial|pending
  "data": {},                   // 에이전트별 데이터
  "errors": [],                 // 구조화된 에러 배열
  "metrics": {},                // 성능 메트릭
  "next_action": {              // Claude를 위한 다음 액션
    "recommended_agent": "string",
    "params": {},
    "priority": "high|medium|low",
    "reason": "string"
  },
  "decision_hints": {}          // Claude 판단을 위한 힌트
}
```

### 1.2 각 도구별 수정 태스크

#### Task 1.2.1: build_sentinel.sh 수정 ✅
**파일**: `/tools/build_sentinel.sh`
**상태**: [x] 완료 (2025-01-21)
**문제점**: Bash에서 복잡한 JSON 생성은 오류 발생 위험이 높음

**대안 1 (권장)**: Python 헬퍼 스크립트 사용
```bash
# build_sentinel.sh 끝부분에 추가
python3 tools/build_sentinel_json.py \
  --status "$OVERALL_STATUS" \
  --errors "$TOTAL_ERRORS" \
  --warnings "$TOTAL_WARNINGS" \
  --failures "$TEST_FAILURES" \
  --mode "$MODE" \
  --platform "$PLATFORM"
```

**대안 2**: 간단한 JSON 생성 (heredoc 사용)
```bash
# 단순화된 JSON 출력 (복잡한 중첩 구조 피함)
cat > "$REPORTS/build_sentinel.json" <<EOF
{
  "agent": "build-sentinel",
  "version": "1.0.0",
  "timestamp": "$TIMESTAMP",
  "status": "$OVERALL_STATUS",
  "errors": $TOTAL_ERRORS,
  "warnings": $TOTAL_WARNINGS,
  "test_failures": $TEST_FAILURES,
  "mode": "$MODE",
  "platform": "$PLATFORM"
}
EOF
```

**구현 파일**: `tools/build_sentinel_json.py` (새로 생성)
```python
#!/usr/bin/env python3
"""build_sentinel.sh의 JSON 출력 헬퍼"""
import json
import argparse
from datetime import datetime
from pathlib import Path

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--status', required=True)
    parser.add_argument('--errors', type=int, default=0)
    parser.add_argument('--warnings', type=int, default=0)
    parser.add_argument('--failures', type=int, default=0)
    parser.add_argument('--mode', default='quick')
    parser.add_argument('--platform', default='none')
    args = parser.parse_args()

    # 에러 타입 분석
    analyze_txt = Path('reports/analyze.txt')
    import_errors = 0
    di_errors = 0
    if analyze_txt.exists():
        content = analyze_txt.read_text()
        import_errors = content.count('import')
        di_errors = content.count('GetIt')

    output = {
        "agent": "build-sentinel",
        "version": "1.0.0",
        "timestamp": datetime.now().isoformat(),
        "status": args.status,
        "data": {
            "mode": args.mode,
            "platform": args.platform,
            "errors": args.errors,
            "warnings": args.warnings,
            "test_failures": args.failures
        },
        "next_action": determine_next_action(args.status, import_errors, di_errors),
        "decision_hints": {
            "has_import_errors": import_errors > 0,
            "has_di_errors": di_errors > 0,
            "needs_rollback": args.status == "fail"
        }
    }

    with open('reports/build_sentinel.json', 'w') as f:
        json.dump(output, f, indent=2)

def determine_next_action(status, import_errors, di_errors):
    if status == "fail":
        if import_errors > 0:
            return {
                "recommended_agent": "import-guardian",
                "params": {"mode": "fix"},
                "priority": "high",
                "reason": f"{import_errors} import errors detected"
            }
        if di_errors > 0:
            return {
                "recommended_agent": "di-binder",
                "params": {"mode": "detect"},
                "priority": "high",
                "reason": f"{di_errors} DI errors detected"
            }
    return None

if __name__ == "__main__":
    main()
```

#### Task 1.2.2: inventory_scout.py 수정 ✅
**파일**: `/tools/inventory_scout.py`
**상태**: [x] 완료 (2025-01-21)
**작업**: Claude-centric JSON 출력 추가 완료
```python
# 현재: 이미 inventory.json 생성 중
# 추가 필요: next_action과 decision_hints 필드

# 추가할 함수:
def generate_claude_output(scan_results):
    """Claude를 위한 구조화된 출력 생성"""
    return {
        "agent": "inventory-scout",
        "version": "1.0.0",
        "timestamp": datetime.now().isoformat(),
        "status": "success",
        "data": {
            "total_files": len(scan_results),
            "large_files": [f for f in scan_results if f['lines'] > 300],
            "by_layer": categorize_by_layer(scan_results)
        },
        "next_action": determine_next_action(scan_results),
        "decision_hints": {
            "has_large_files": any(f['lines'] > 300 for f in scan_results),
            "needs_decomposition": any(f['lines'] > 800 for f in scan_results),
            "mixed_responsibilities": detect_mixed_responsibilities(scan_results)
        }
    }
```

#### Task 1.2.3: code_surgeon.py 수정
**파일**: `/tools/code_surgeon.py`
**작업**:
```python
# 출력 변경: 패치 파일 + JSON 메타데이터

def generate_output():
    return {
        "agent": "code-surgeon",
        "version": "1.0.0",
        "status": "success" if patches_created else "no_action",
        "data": {
            "source_file": args.file,
            "extracted_symbols": extracted_list,
            "patches_created": patch_files,
            "analysis_plan": analysis_results  # MultiEdit을 위한 계획
        },
        "next_action": {
            "recommended_agent": "import-guardian" if patches_created else None,
            "params": {"scope": feature_name, "mode": "detect"}
        }
    }
```

#### Task 1.2.4: import_guardian.py 수정
**파일**: `/tools/import_guardian.py`
**작업**:
```python
# JSON 출력 강화
output = {
    "agent": "import-guardian",
    "version": "1.0.0",
    "status": "fail" if violations else "success",
    "data": {
        "violations": categorized_violations,
        "fixes_available": len(auto_fixable),
        "patches_created": patch_files if mode == "fix" else []
    },
    "next_action": {
        "recommended_agent": "build-sentinel" if fixes_applied else None,
        "params": {"mode": "quick"},
        "reason": "Verify fixes" if fixes_applied else None
    }
}
```

#### Task 1.2.5: di_binder.py 수정
**파일**: `/tools/di_binder.py`
**작업**:
```python
# DI 등록 결과를 JSON으로
output = {
    "agent": "di-binder",
    "version": "1.0.0",
    "status": "success" if bindings_added else "no_action",
    "data": {
        "feature": args.feature,
        "bindings_added": bindings_list,
        "file_modified": "app/di.dart" if applied else None
    },
    "next_action": {
        "recommended_agent": "build-sentinel",
        "params": {"mode": "test", "test_path": f"lib/features/{args.feature}/"}
    }
}
```

#### Task 1.2.6: repo_mover.py 수정
**파일**: `/tools/repo_mover.py`
**작업**:
```python
# 이동 계획과 실행 결과를 JSON으로
output = {
    "agent": "repo-mover",
    "version": "1.0.0",
    "status": "success" if files_moved else "dry_run",
    "data": {
        "feature": args.feature,
        "mode": args.mode,
        "files_to_move": movement_plan,
        "files_moved": moved_files if args.mode == "apply" else []
    },
    "next_action": {
        "recommended_agent": "import-guardian" if files_moved else None,
        "params": {"scope": args.feature, "mode": "detect"},
        "reason": "Check for broken imports after movement"
    }
}
```

#### Task 1.2.7: router_splitter.py 수정
**파일**: `/tools/router_splitter.py`
**작업**:
```python
# 라우트 분리 결과를 JSON으로
output = {
    "agent": "router-splitter",
    "version": "1.0.0",
    "status": "success" if routes_split else "no_action",
    "data": {
        "original_file": "app/router.dart",
        "feature_routes": extracted_routes,
        "patches_created": patch_files
    },
    "next_action": {
        "recommended_agent": "build-sentinel",
        "params": {"mode": "quick"},
        "reason": "Verify routing still works"
    }
}
```

#### Task 1.2.8: struct_weaver.py 수정
**파일**: `/tools/struct_weaver.py`
**작업**:
```python
# 구조 분해 결과를 JSON으로
output = {
    "agent": "struct-weaver",
    "version": "1.0.0",
    "status": "success" if structures_decomposed else "no_action",
    "data": {
        "task": args.task,
        "source": args.source or args.file,
        "decomposed_structures": decomposed_list,
        "target_features": target_features
    },
    "next_action": {
        "recommended_agent": "import-guardian",
        "params": {"scope": "all", "mode": "detect"}
    }
}
```

## 📋 Phase 2: 에이전트 문서 수정

### 2.1 에이전트 역할 재정의

#### Task 2.1.1: 모든 .md 파일 공통 수정
**파일들**: `/Users/g_black/versus-cursor/.claude/agents/*.md`
**수정 패턴**:
```markdown
# 기존
"You report to the user..."
"Provide clear next steps for the user..."

# 변경
"You provide structured data to Claude..."
"Return actionable data for Claude's orchestration..."
```

### 2.2 각 에이전트별 구체적 수정

#### Task 2.2.1: inventory-scout.md
**변경사항**:
```markdown
## Output Format 섹션 교체

기존: YAML with user-readable next_steps
신규: JSON with Claude-parseable decision_hints

## Natural Language Examples 수정
기존: "tell the user about large files"
신규: "return structured data about large files"
```

#### Task 2.2.2: code-surgeon.md
**변경사항**:
```markdown
## Execution Strategy 수정

1. Python tool analyzes and creates plan
2. Return plan as JSON to Claude
3. Claude uses MultiEdit based on plan
4. NO direct file modification by Python tool
```

#### Task 2.2.3: import-guardian.md
**변경사항**:
```markdown
## Output Standards 수정

- Remove all print statements
- Return only structured JSON
- Include decision_hints for Claude
- No user-facing messages
```

#### Task 2.2.4: build-sentinel.md
**변경사항**:
```markdown
## Report Generation 수정

- Primary: build_sentinel.json for Claude
- Secondary: build_sentinel.yml for logging (optional)
- Remove "user should..." phrases
```

## 📋 Phase 3: Claude 오케스트레이션 패턴

### 3.1 오케스트레이션 헬퍼 함수

#### Task 3.1.1: 오케스트레이션 유틸리티 생성
**파일**: `/tools/orchestration_utils.py` (새 파일)
```python
#!/usr/bin/env python3
"""Claude 오케스트레이션을 위한 유틸리티"""

import json
import subprocess
from pathlib import Path
from typing import Dict, Any, Optional

class AgentOrchestrator:
    """Claude가 에이전트를 오케스트레이션하기 위한 헬퍼"""

    def __init__(self):
        self.reports_dir = Path("reports")
        self.execution_history = []

    def run_agent(self, agent_name: str, params: Dict[str, Any]) -> Dict:
        """에이전트 실행 및 결과 반환"""
        # 에이전트별 실행 명령 매핑
        commands = {
            "build-sentinel": f"bash tools/build_sentinel.sh {params.get('mode', 'quick')}",
            "inventory-scout": f"python3 tools/inventory_scout.py --scope {params.get('scope', 'all')}",
            "code-surgeon": f"python3 tools/code_surgeon.py --file {params['file']} --map \"{params['map']}\"",
            "import-guardian": f"python3 tools/import_guardian.py --scope {params.get('scope', 'all')} --mode {params.get('mode', 'detect')}",
            "di-binder": f"python3 tools/di_binder.py --feature {params['feature']} --port {params['port']} --adapter {params['adapter']}",
            "repo-mover": f"python3 tools/repo_mover.py --feature {params['feature']} --mode {params.get('mode', 'dry-run')}",
            "router-splitter": f"python3 tools/router_splitter.py --scope {params.get('scope', 'all')} --mode {params.get('mode', 'detect')}",
            "struct-weaver": f"python3 tools/struct_weaver.py --task {params['task']} --source {params['source']} --mode {params.get('mode', 'detect')}"
        }

        cmd = commands.get(agent_name)
        if not cmd:
            return {"error": f"Unknown agent: {agent_name}"}

        # 실행
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)

        # 결과 파일 읽기
        output_file = self.reports_dir / f"{agent_name.replace('-', '_')}.json"
        if output_file.exists():
            with open(output_file) as f:
                return json.load(f)

        return {"error": "No output file generated", "stdout": result.stdout, "stderr": result.stderr}

    def decide_next_agent(self, current_result: Dict) -> Optional[str]:
        """현재 결과를 기반으로 다음 에이전트 결정"""
        if "next_action" in current_result and current_result["next_action"]:
            return current_result["next_action"].get("recommended_agent")

        # 기본 로직
        if current_result["agent"] == "inventory-scout":
            if current_result.get("decision_hints", {}).get("has_large_files"):
                return "code-surgeon"

        if current_result["agent"] == "build-sentinel":
            if current_result["status"] == "fail":
                errors = current_result.get("errors", {}).get("analysis", {}).get("by_type", {})
                if errors.get("import", 0) > 0:
                    return "import-guardian"
                if errors.get("di", 0) > 0:
                    return "di-binder"

        return None

    def create_execution_plan(self, task: str) -> list:
        """태스크를 위한 실행 계획 생성"""
        # C7 파이프라인 예시
        if "c7" in task or "migration" in task:
            return [
                ("inventory-scout", {"scope": "all"}),
                ("repo-mover", {"mode": "dry-run"}),
                ("struct-weaver", {"task": "mapper", "mode": "detect"}),
                ("di-binder", {"mode": "detect"}),
                ("import-guardian", {"mode": "fix", "apply": False}),
                ("build-sentinel", {"mode": "quick"}),
                ("router-splitter", {"mode": "detect"})
            ]

        # 기본 품질 체크
        return [
            ("inventory-scout", {"scope": "all"}),
            ("build-sentinel", {"mode": "quick"})
        ]
```

### 3.2 에이전트 체이닝 규칙

#### Task 3.2.1: 체이닝 규칙 문서화
**파일**: `/tools/CHAINING_RULES.md` (새 파일)
```markdown
# Agent Chaining Rules for Claude Orchestration

## 체이닝 우선순위

### 1. Error-Driven Chaining
- build-sentinel (fail) → import-guardian (import errors)
- build-sentinel (fail) → di-binder (DI errors)
- import-guardian (success) → build-sentinel (verify)

### 2. Migration Pipeline Chaining
- inventory-scout → code-surgeon (if large files)
- code-surgeon → import-guardian (always)
- repo-mover → import-guardian (always)
- struct-weaver → import-guardian (always)
- * → build-sentinel (final validation)

### 3. Conditional Chaining
```json
{
  "if": "inventory-scout.data.large_files.length > 0",
  "then": "code-surgeon",
  "else": "build-sentinel"
}
```

## 자동 파라미터 전달

### From inventory-scout to code-surgeon:
- large_files → file parameter
- feature_name → map parameter

### From import-guardian to build-sentinel:
- affected_features → test_path parameter
```

## 📋 Phase 4: 테스트 및 검증

### 4.1 단위 테스트

#### Task 4.1.1: 각 도구의 JSON 출력 테스트
**파일**: `/tools/test_outputs.py` (새 파일)
```python
#!/usr/bin/env python3
"""도구들의 JSON 출력 검증"""

import json
import subprocess
from pathlib import Path

def validate_json_schema(output_file: Path, agent_name: str):
    """JSON 스키마 검증"""
    with open(output_file) as f:
        data = json.load(f)

    # 필수 필드 검증
    required_fields = ["agent", "version", "timestamp", "status", "data"]
    for field in required_fields:
        assert field in data, f"{agent_name}: Missing required field '{field}'"

    # agent 이름 일치 확인
    assert data["agent"] == agent_name, f"Agent name mismatch"

    # status 값 검증
    assert data["status"] in ["success", "fail", "partial", "pending"], f"Invalid status"

    print(f"✅ {agent_name}: Valid JSON schema")

# 모든 에이전트 테스트
agents = ["build-sentinel", "inventory-scout", "code-surgeon", "import-guardian",
          "di-binder", "repo-mover", "router-splitter", "struct-weaver"]

for agent in agents:
    # 테스트 실행...
    validate_json_schema(Path(f"reports/{agent.replace('-', '_')}.json"), agent)
```

### 4.2 통합 테스트

#### Task 4.2.2: 파이프라인 통합 테스트
**파일**: `/tools/test_pipeline.py` (새 파일)
```python
#!/usr/bin/env python3
"""전체 파이프라인 테스트"""

from orchestration_utils import AgentOrchestrator

def test_c7_pipeline():
    """C7 마이그레이션 파이프라인 테스트"""
    orchestrator = AgentOrchestrator()

    # 파이프라인 실행
    plan = orchestrator.create_execution_plan("c7 migration")

    for agent, params in plan:
        result = orchestrator.run_agent(agent, params)
        print(f"Agent: {agent}, Status: {result['status']}")

        # 다음 에이전트 결정
        next_agent = orchestrator.decide_next_agent(result)
        if next_agent:
            print(f"  → Next: {next_agent}")

    print("✅ Pipeline test completed")

if __name__ == "__main__":
    test_c7_pipeline()
```

## 📋 Phase 5: 점진적 마이그레이션

### 5.1 Backward Compatibility

#### Task 5.1.1: 듀얼 출력 지원 (임시)
```python
# 각 도구에 추가
def save_output(data, agent_name):
    """JSON과 YAML 둘 다 생성 (마이그레이션 기간 동안)"""
    # JSON for Claude
    with open(f"reports/{agent_name}.json", "w") as f:
        json.dump(data, f, indent=2)

    # YAML for backward compatibility (deprecated)
    if BACKWARD_COMPAT_MODE:
        with open(f"reports/{agent_name}.yml", "w") as f:
            yaml.dump(convert_to_user_format(data), f)
```

### 5.2 마이그레이션 순서

1. **Week 1**: build-sentinel, inventory-scout (기본 도구)
2. **Week 2**: import-guardian, di-binder (자주 사용)
3. **Week 3**: code-surgeon, repo-mover (복잡한 도구)
4. **Week 4**: router-splitter, struct-weaver (특수 도구)
5. **Week 5**: 전체 통합 테스트 및 YAML 출력 제거

## 📊 성공 지표

### 정량적 지표
- [ ] 100% JSON 출력 변환 완료
- [ ] 0개의 사용자 대면 메시지
- [ ] 100% 구조화된 에러 처리
- [ ] 90% 이상 자동 체이닝 성공률

### 정성적 지표
- [ ] Claude가 모든 에이전트 결과 파싱 가능
- [ ] 사용자 개입 없이 전체 파이프라인 실행
- [ ] 명확한 에러 추적 및 복구 가능
- [ ] 일관된 데이터 구조로 유지보수 용이

## 🚀 실행 체크리스트

### Phase 1 체크리스트 (출력 표준화) ✅
- [x] Task 1.2.1: build_sentinel.sh JSON 출력 (✅ Python 헬퍼 생성 완료)
- [x] Task 1.2.2: inventory_scout.py JSON 출력 (✅ next_action 필드 추가 완료)
- [x] Task 1.2.3: code_surgeon.py JSON 출력 (✅ 완료)
- [x] Task 1.2.4: import_guardian.py JSON 출력 (✅ 완료)
- [x] Task 1.2.5: di_binder.py JSON 출력 (✅ 완료)
- [x] Task 1.2.6: repo_mover.py JSON 출력 (✅ 완료)
- [x] Task 1.2.7: router_splitter.py JSON 출력 (✅ 완료)
- [x] Task 1.2.8: struct_weaver.py JSON 출력 (✅ 완료)

### Phase 2 체크리스트 (에이전트 문서) ✅
- [x] Task 2.1.1: 공통 문구 수정 (✅ 스크립트로 자동 수정)
- [x] Task 2.2.1: inventory-scout.md 수정 (✅ 완료)
- [x] Task 2.2.2: code-surgeon.md 수정 (✅ 완료)
- [x] Task 2.2.3: import-guardian.md 수정 (✅ 완료)
- [x] Task 2.2.4: build-sentinel.md 수정 (✅ 완료)
- [x] 나머지 에이전트 문서 수정 (✅ di-binder, repo-mover, router-splitter, struct-weaver)

### Phase 3 체크리스트 (오케스트레이션) ✅
- [x] Task 3.1.1: orchestration_utils.py 생성 (✅ 완료)
- [x] Task 3.2.1: CHAINING_RULES.md 생성 (✅ 완료)

### Phase 4 체크리스트 (테스트)
- [ ] Task 4.1.1: test_outputs.py 생성 및 실행
- [ ] Task 4.2.2: test_pipeline.py 생성 및 실행

### Phase 5 체크리스트 (마이그레이션)
- [ ] Task 5.1.1: 듀얼 출력 구현
- [ ] Week 1-5 순차 마이그레이션
- [ ] YAML 출력 완전 제거

## ⚠️ 실행 가능성 이슈 및 해결책

### 1. Bash JSON 생성 문제
**문제**: Bash에서 복잡한 중첩 JSON 생성 시 구문 오류 발생 위험
**해결책**:
- Python 헬퍼 스크립트 사용 (권장)
- jq 도구 활용 (설치 필요)
- 단순화된 JSON 구조 사용

### 2. 정의되지 않은 함수 호출
**문제**: `generate_next_action` 같은 함수가 정의되지 않음
**해결책**: Python 헬퍼에서 로직 구현

### 3. 기존 도구와의 호환성
**문제**: 일부 도구가 이미 다른 형식의 출력 생성
**해결책**:
- 듀얼 출력 지원 (JSON + 기존 형식)
- 점진적 마이그레이션

### 4. 에러 처리
**문제**: JSON 파싱 실패 시 전체 파이프라인 중단
**해결책**:
- try-catch로 감싸서 fallback 처리
- 기본값 제공

## 📝 주의사항

### ARCHITECTURE_RULES.md 준수
1. **비즈니스 트랜잭션 단위**: 각 에이전트는 완전한 작업 단위
2. **레이어 분리**: 도구(데이터) → Claude(로직) → 사용자(표현)
3. **단방향 의존성**: 역방향 참조 금지
4. **테스트 가능성**: 모든 출력은 검증 가능한 구조

### 실수 방지 가이드
1. **JSON 검증**: 모든 JSON 출력은 valid JSON이어야 함
2. **필드 일관성**: 모든 에이전트가 동일한 필드 구조 사용
3. **에러 처리**: 예외 상황도 구조화된 형식으로 반환
4. **버전 관리**: 스키마 버전 명시로 향후 변경 추적
5. **테스트 우선**: 변경 전 테스트 작성, 변경 후 검증

## 🔄 실제 구현 순서 (수정됨)

### Week 1: 기초 작업 ✅
1. [x] build_sentinel_json.py 생성 ✅
2. [x] inventory_scout.py next_action 필드 추가 ✅
3. [x] import_guardian.py 출력 개선 ✅

### Week 2: Python 도구들 ✅
4. [x] code_surgeon.py JSON 출력 추가 ✅
5. [x] di_binder.py JSON 출력 추가 ✅
6. [x] repo_mover.py JSON 출력 추가 ✅

### Week 3: 복잡한 도구들 ✅
7. [x] router_splitter.py JSON 출력 추가 ✅
8. [x] struct_weaver.py JSON 출력 추가 ✅
9. [x] orchestration_utils.py 생성 ✅

### Week 4: 통합 및 테스트
10. [ ] 모든 에이전트 .md 파일 수정
11. [ ] 통합 테스트 실행
12. [ ] 문서화 완료

## 🎯 최종 목표

**"사용자는 최종 결과만, Claude는 모든 과정을 제어"**

- Claude가 모든 에이전트 오케스트레이션
- 구조화된 데이터로 정확한 판단
- 사용자 개입 최소화
- 완전 자동화된 마이그레이션 파이프라인