#!/usr/bin/env python3
"""
Claude 오케스트레이션을 위한 유틸리티
Agent orchestration helpers for Claude-centric architecture
"""

import json
import subprocess
from pathlib import Path
from typing import Dict, Any, Optional, List, Tuple
from datetime import datetime

class AgentOrchestrator:
    """Claude가 에이전트를 오케스트레이션하기 위한 헬퍼"""

    def __init__(self):
        self.root_dir = Path(__file__).resolve().parents[1]
        self.reports_dir = self.root_dir / "reports"
        self.patches_dir = self.root_dir / "patches"
        self.execution_history = []
        self.agent_results = {}

    def run_agent(self, agent_name: str, params: Dict[str, Any]) -> Dict:
        """
        에이전트 실행 및 결과 반환

        Args:
            agent_name: 에이전트 이름 (e.g., 'build-sentinel', 'inventory-scout')
            params: 에이전트 파라미터 딕셔너리

        Returns:
            JSON 결과 딕셔너리 또는 에러
        """

        # 에이전트별 실행 명령 매핑
        commands = {
            "build-sentinel": self._build_sentinel_cmd,
            "inventory-scout": self._inventory_scout_cmd,
            "code-surgeon": self._code_surgeon_cmd,
            "import-guardian": self._import_guardian_cmd,
            "di-binder": self._di_binder_cmd,
            "repo-mover": self._repo_mover_cmd,
            "router-splitter": self._router_splitter_cmd,
            "struct-weaver": self._struct_weaver_cmd,
            "orchestrator-pipeline": self._orchestrator_pipeline_cmd
        }

        cmd_builder = commands.get(agent_name)
        if not cmd_builder:
            return {
                "agent": agent_name,
                "status": "fail",
                "error": f"Unknown agent: {agent_name}",
                "timestamp": datetime.now().isoformat()
            }

        # 명령 생성 및 실행
        cmd = cmd_builder(params)
        result = self._execute_command(cmd)

        # 결과 파일 읽기
        output_file = self.reports_dir / f"{agent_name.replace('-', '_')}.json"
        if output_file.exists():
            try:
                with open(output_file) as f:
                    agent_result = json.load(f)

                # 실행 히스토리에 추가
                self.execution_history.append({
                    "agent": agent_name,
                    "params": params,
                    "timestamp": agent_result.get("timestamp"),
                    "status": agent_result.get("status")
                })

                # 결과 캐싱
                self.agent_results[agent_name] = agent_result

                return agent_result

            except json.JSONDecodeError as e:
                return {
                    "agent": agent_name,
                    "status": "fail",
                    "error": f"Invalid JSON output: {e}",
                    "stdout": result.stdout,
                    "stderr": result.stderr
                }

        return {
            "agent": agent_name,
            "status": "fail",
            "error": "No output file generated",
            "stdout": result.stdout,
            "stderr": result.stderr
        }

    def decide_next_agent(self, current_result: Dict) -> Optional[Dict]:
        """
        현재 결과를 기반으로 다음 에이전트 결정

        Args:
            current_result: 현재 에이전트의 JSON 결과

        Returns:
            다음 에이전트 정보 또는 None
        """

        # next_action 필드가 있으면 우선 사용
        if "next_action" in current_result and current_result["next_action"]:
            return current_result["next_action"]

        # 기본 체이닝 로직 (fallback)
        agent = current_result.get("agent")
        status = current_result.get("status")
        decision_hints = current_result.get("decision_hints", {})

        # Inventory Scout → Code Surgeon (if large files)
        if agent == "inventory-scout":
            if decision_hints.get("has_large_files"):
                return {
                    "recommended_agent": "code-surgeon",
                    "priority": "high",
                    "reason": "Large files detected that need decomposition"
                }
            elif decision_hints.get("has_violations"):
                return {
                    "recommended_agent": "import-guardian",
                    "priority": "high",
                    "reason": "Architecture violations detected"
                }

        # Build Sentinel → Error-specific agent
        if agent == "build-sentinel" and status == "fail":
            if decision_hints.get("has_import_errors"):
                return {
                    "recommended_agent": "import-guardian",
                    "params": {"mode": "fix"},
                    "priority": "high",
                    "reason": "Import errors need fixing"
                }
            elif decision_hints.get("has_di_errors"):
                return {
                    "recommended_agent": "di-binder",
                    "params": {"mode": "detect"},
                    "priority": "high",
                    "reason": "DI errors detected"
                }

        # After fixes → Verify with Build Sentinel
        if agent in ["import-guardian", "di-binder", "code-surgeon"] and status == "success":
            return {
                "recommended_agent": "build-sentinel",
                "params": {"mode": "quick"},
                "priority": "medium",
                "reason": "Verify fixes"
            }

        return None

    def create_execution_plan(self, task: str) -> List[Tuple[str, Dict]]:
        """
        태스크를 위한 실행 계획 생성

        Args:
            task: 태스크 설명 (e.g., "c7 migration", "auth feature refactoring")

        Returns:
            (agent_name, params) 튜플 리스트
        """

        # C7 파이프라인 (완전 마이그레이션)
        if "c7" in task.lower() or "complete migration" in task.lower():
            return [
                ("inventory-scout", {"scope": "all", "layer_aware": True}),
                ("repo-mover", {"feature": "all", "mode": "dry-run"}),
                ("struct-weaver", {"task": "mapper", "mode": "detect"}),
                ("struct-weaver", {"task": "state", "mode": "detect"}),
                ("di-binder", {"mode": "detect"}),
                ("import-guardian", {"mode": "detect", "scope": "all"}),
                ("router-splitter", {"mode": "detect"}),
                ("build-sentinel", {"mode": "quick"})
            ]

        # 품질 체크 파이프라인
        if "quality" in task.lower() or "check" in task.lower():
            return [
                ("inventory-scout", {"scope": "all"}),
                ("import-guardian", {"mode": "detect"}),
                ("build-sentinel", {"mode": "full"})
            ]

        # 특정 feature 마이그레이션
        for feature in ["auth", "posts", "chat", "profile", "notifications", "search"]:
            if feature in task.lower():
                return [
                    ("inventory-scout", {"scope": feature}),
                    ("repo-mover", {"feature": feature, "mode": "dry-run"}),
                    ("di-binder", {"feature": feature, "mode": "detect"}),
                    ("import-guardian", {"scope": feature, "mode": "detect"}),
                    ("build-sentinel", {"mode": "test", "test_path": f"lib/features/{feature}/"})
                ]

        # 기본 파이프라인
        return [
            ("inventory-scout", {"scope": "all"}),
            ("build-sentinel", {"mode": "quick"})
        ]

    def get_execution_summary(self) -> Dict:
        """실행 요약 정보 반환"""
        return {
            "total_executions": len(self.execution_history),
            "agents_run": list(set(h["agent"] for h in self.execution_history)),
            "success_count": sum(1 for h in self.execution_history if h.get("status") == "success"),
            "fail_count": sum(1 for h in self.execution_history if h.get("status") == "fail"),
            "history": self.execution_history
        }

    # Private command builders
    def _build_sentinel_cmd(self, params: Dict) -> str:
        mode = params.get("mode", "quick")
        platform = params.get("platform", "")
        test_path = params.get("test_path", "")

        cmd = f"bash {self.root_dir}/tools/build_sentinel.sh {mode}"
        if platform:
            cmd += f" --platform {platform}"
        if test_path:
            cmd += f" --test-path {test_path}"
        return cmd

    def _inventory_scout_cmd(self, params: Dict) -> str:
        scope = params.get("scope", "all")
        depth = params.get("depth", 5)
        layer_aware = params.get("layer_aware", True)

        cmd = f"python3 {self.root_dir}/tools/inventory_scout.py"
        cmd += f" --scope {scope} --depth {depth}"
        if layer_aware:
            cmd += " --layer-aware"
        return cmd

    def _code_surgeon_cmd(self, params: Dict) -> str:
        file = params.get("file", "")
        map_str = params.get("map", "")
        mode = params.get("mode", "detect")
        bridge = params.get("bridge", True)

        if not file:
            raise ValueError("code-surgeon requires 'file' parameter")

        cmd = f"python3 {self.root_dir}/tools/code_surgeon.py"
        cmd += f" --file {file} --mode {mode}"
        if map_str:
            cmd += f' --map "{map_str}"'
        if bridge:
            cmd += " --bridge"
        return cmd

    def _import_guardian_cmd(self, params: Dict) -> str:
        scope = params.get("scope", "all")
        mode = params.get("mode", "detect")
        apply_flag = params.get("apply", False)

        cmd = f"python3 {self.root_dir}/tools/import_guardian.py"
        cmd += f" --scope {scope} --mode {mode}"
        if apply_flag:
            cmd += " --apply"
        return cmd

    def _di_binder_cmd(self, params: Dict) -> str:
        feature = params.get("feature", "")
        port = params.get("port", "")
        adapter = params.get("adapter", "")
        mode = params.get("mode", "detect")

        if not all([feature, port, adapter]) and mode != "detect":
            # detect mode에서는 feature만 필요할 수 있음
            if not feature:
                raise ValueError("di-binder requires at least 'feature' parameter")

        cmd = f"python3 {self.root_dir}/tools/di_binder.py"
        cmd += f" --feature {feature}"
        if port:
            cmd += f" --port {port}"
        if adapter:
            cmd += f" --adapter {adapter}"
        cmd += f" --mode {mode}"
        return cmd

    def _repo_mover_cmd(self, params: Dict) -> str:
        feature = params.get("feature", "")
        mode = params.get("mode", "dry-run")
        include = params.get("include", "repositories,mappers")

        if not feature:
            raise ValueError("repo-mover requires 'feature' parameter")

        cmd = f"python3 {self.root_dir}/tools/repo_mover.py"
        cmd += f" --feature {feature} --mode {mode} --include {include}"
        return cmd

    def _router_splitter_cmd(self, params: Dict) -> str:
        scope = params.get("scope", "all")
        mode = params.get("mode", "detect")
        features = params.get("features", "")

        cmd = f"python3 {self.root_dir}/tools/router_splitter.py"
        cmd += f" --scope {scope} --mode {mode}"
        if features:
            cmd += f" --features {features}"
        return cmd

    def _struct_weaver_cmd(self, params: Dict) -> str:
        task = params.get("task", "")
        source = params.get("source", "")
        mode = params.get("mode", "detect")
        map_str = params.get("map", "")

        if not task:
            raise ValueError("struct-weaver requires 'task' parameter")

        cmd = f"python3 {self.root_dir}/tools/struct_weaver.py"
        cmd += f" --task {task} --mode {mode}"
        if source:
            cmd += f" --source {source}"
        if map_str:
            cmd += f' --map "{map_str}"'
        return cmd

    def _orchestrator_pipeline_cmd(self, params: Dict) -> str:
        pipeline = params.get("pipeline", "quality")
        feature = params.get("feature", "")
        flags = params.get("flags", [])

        if pipeline not in ["c7", "quality", "feature", "safe"]:
            raise ValueError(f"Invalid pipeline type: {pipeline}")

        if pipeline == "feature" and not feature:
            raise ValueError("Feature pipeline requires 'feature' parameter")

        cmd = f"python3 {self.root_dir}/tools/orchestrator_pipeline.py"
        cmd += f" {pipeline}"
        if feature:
            cmd += f" --feature {feature}"
        for flag in flags:
            cmd += f" --{flag}"
        return cmd

    def _execute_command(self, cmd: str) -> subprocess.CompletedProcess:
        """명령 실행"""
        print(f"🔧 Executing: {cmd}")
        return subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            cwd=self.root_dir
        )


def main():
    """테스트 및 예시"""
    orchestrator = AgentOrchestrator()

    # 예시: inventory scout 실행
    result = orchestrator.run_agent("inventory-scout", {"scope": "all"})
    print(json.dumps(result, indent=2))

    # 다음 에이전트 결정
    next_agent = orchestrator.decide_next_agent(result)
    if next_agent:
        print(f"\n다음 추천 에이전트: {next_agent['recommended_agent']}")

    # 실행 요약
    summary = orchestrator.get_execution_summary()
    print(f"\n실행 요약: {json.dumps(summary, indent=2)}")


if __name__ == "__main__":
    main()