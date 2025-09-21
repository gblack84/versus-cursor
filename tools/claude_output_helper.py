#!/usr/bin/env python3
"""
Claude-Centric 출력을 위한 공통 헬퍼 모듈
모든 도구에서 표준화된 JSON 출력을 생성하도록 도움
"""
import json
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, Optional, List

class ClaudeOutputGenerator:
    """Claude-centric JSON 출력 생성기"""

    def __init__(self, agent_name: str, version: str = "1.0.0"):
        self.agent_name = agent_name
        self.version = version
        self.reports_dir = Path("reports")
        self.reports_dir.mkdir(exist_ok=True)

    def generate(
        self,
        status: str,
        data: Dict[str, Any],
        next_action: Optional[Dict[str, Any]] = None,
        decision_hints: Optional[Dict[str, Any]] = None,
        metrics: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """표준화된 Claude-centric 출력 생성"""
        output = {
            "agent": self.agent_name,
            "version": self.version,
            "timestamp": datetime.now().isoformat(),
            "status": status,  # success | fail | partial | no_action
            "data": data,
            "next_action": next_action,
            "decision_hints": decision_hints or {},
            "metrics": metrics or {}
        }
        return output

    def save(self, output: Dict[str, Any], filename: Optional[str] = None) -> Path:
        """JSON 파일로 저장"""
        if filename is None:
            filename = f"{self.agent_name.replace('-', '_')}.json"

        output_path = self.reports_dir / filename
        output_path.write_text(
            json.dumps(output, ensure_ascii=False, indent=2),
            encoding="utf-8"
        )
        return output_path

    def determine_next_action(
        self,
        condition_map: List[tuple]
    ) -> Optional[Dict[str, Any]]:
        """조건에 따른 다음 액션 결정

        condition_map: [(condition, action_dict), ...]
        """
        for condition, action in condition_map:
            if condition:
                return action
        return None

    @staticmethod
    def create_action(
        agent: str,
        params: Dict[str, Any],
        priority: str = "medium",
        reason: str = ""
    ) -> Dict[str, Any]:
        """액션 딕셔너리 생성"""
        return {
            "recommended_agent": agent,
            "params": params,
            "priority": priority,
            "reason": reason
        }

# 각 에이전트별 특화 함수들
def get_di_binder_next_action(bindings_added: int, feature: str, mode: str) -> Optional[Dict[str, Any]]:
    """DIBinder 전용 next_action 결정"""
    if bindings_added > 0:
        return ClaudeOutputGenerator.create_action(
            "build-sentinel",
            {"mode": "test", "test_path": f"lib/features/{feature}/"},
            "high",
            f"Test DI bindings for {feature} feature"
        )
    elif mode == "detect":
        return ClaudeOutputGenerator.create_action(
            "di-binder",
            {"feature": feature, "mode": "apply"},
            "medium",
            "Apply DI bindings"
        )
    return None

def get_repo_mover_next_action(files_moved: int, feature: str, mode: str) -> Optional[Dict[str, Any]]:
    """RepoMover 전용 next_action 결정"""
    if files_moved > 0:
        return ClaudeOutputGenerator.create_action(
            "import-guardian",
            {"mode": "detect", "scope": feature},
            "high",
            f"Check imports after moving {files_moved} files"
        )
    elif mode == "dry-run":
        return ClaudeOutputGenerator.create_action(
            "repo-mover",
            {"feature": feature, "mode": "apply"},
            "medium",
            "Apply movement plan"
        )
    return None

def get_router_splitter_next_action(routes_split: int, mode: str) -> Optional[Dict[str, Any]]:
    """RouterSplitter 전용 next_action 결정"""
    if routes_split > 0:
        return ClaudeOutputGenerator.create_action(
            "build-sentinel",
            {"mode": "quick"},
            "medium",
            f"Verify routing after splitting {routes_split} routes"
        )
    return None

def get_struct_weaver_next_action(structures_decomposed: int, task: str) -> Optional[Dict[str, Any]]:
    """StructWeaver 전용 next_action 결정"""
    if structures_decomposed > 0:
        return ClaudeOutputGenerator.create_action(
            "import-guardian",
            {"mode": "detect", "scope": "all"},
            "high",
            f"Check imports after decomposing {structures_decomposed} structures"
        )
    return None