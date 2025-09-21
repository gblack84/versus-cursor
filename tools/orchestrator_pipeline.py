#!/usr/bin/env python3
"""
OrchestratorPipeline - 복잡한 파이프라인 실행을 위한 메타 오케스트레이터
Manages complex multi-agent pipelines with monitoring and coordination
"""

import json
import sys
import argparse
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple, Any, Optional

# Add parent directory for imports
sys.path.append(str(Path(__file__).resolve().parent))

from orchestration_utils import AgentOrchestrator


class OrchestratorPipeline:
    """Advanced pipeline orchestrator for complex workflows"""

    def __init__(self):
        self.orchestrator = AgentOrchestrator()
        self.pipeline_history = []
        self.checkpoints = {}
        self.flags = set()

    def execute_pipeline(
        self,
        pipeline_type: str,
        feature: Optional[str] = None,
        flags: Optional[List[str]] = None
    ) -> Dict[str, Any]:
        """
        Execute a predefined pipeline with monitoring and coordination

        Args:
            pipeline_type: Type of pipeline (c7, quality, feature, safe)
            feature: Feature name for feature-specific pipelines
            flags: Additional flags (--quality, --safe, --seq, --c7)

        Returns:
            Pipeline execution results
        """

        # Set flags
        if flags:
            self.flags = set(flags)

        # Select pipeline based on type
        if pipeline_type == "c7":
            pipeline = self._get_c7_pipeline(feature)
        elif pipeline_type == "quality":
            pipeline = self._get_quality_pipeline(feature)
        elif pipeline_type == "feature":
            if not feature:
                raise ValueError("Feature name required for feature pipeline")
            pipeline = self._get_feature_pipeline(feature)
        elif pipeline_type == "safe":
            pipeline = self._get_safe_pipeline(feature)
        else:
            raise ValueError(f"Unknown pipeline type: {pipeline_type}")

        # Execute pipeline with monitoring
        return self._execute_with_monitoring(pipeline, pipeline_type)

    def _get_c7_pipeline(self, feature: Optional[str] = None) -> List[Tuple[str, Dict]]:
        """Get C7 complete migration pipeline"""
        scope = feature if feature else "all"

        pipeline = [
            ("inventory-scout", {"scope": scope, "depth": 5}),
            ("code-surgeon", {"mode": "detect"}) if "quality" in self.flags else None,
            ("struct-weaver", {"task": "mapper", "mode": "detect"}),
            ("struct-weaver", {"task": "state", "mode": "detect"}),
            ("repo-mover", {"feature": scope, "mode": "dry-run"}),
            ("di-binder", {"mode": "detect"}),
            ("import-guardian", {"mode": "fix" if "safe" not in self.flags else "detect"}),
            ("router-splitter", {"mode": "detect"}),
            ("build-sentinel", {"mode": "full"})
        ]

        # Filter out None entries
        return [step for step in pipeline if step is not None]

    def _get_quality_pipeline(self, feature: Optional[str] = None) -> List[Tuple[str, Dict]]:
        """Get quality check pipeline"""
        scope = feature if feature else "all"

        return [
            ("inventory-scout", {"scope": scope, "layer_aware": True}),
            ("import-guardian", {"mode": "detect", "scope": scope}),
            ("build-sentinel", {"mode": "full" if "safe" not in self.flags else "quick"})
        ]

    def _get_feature_pipeline(self, feature: str) -> List[Tuple[str, Dict]]:
        """Get feature-specific migration pipeline"""
        return [
            ("inventory-scout", {"scope": feature, "depth": 3}),
            ("repo-mover", {"feature": feature, "mode": "dry-run"}),
            ("di-binder", {"feature": feature, "mode": "detect"}),
            ("import-guardian", {"scope": feature, "mode": "detect"}),
            ("build-sentinel", {"mode": "test", "test_path": f"lib/features/{feature}/"})
        ]

    def _get_safe_pipeline(self, feature: Optional[str] = None) -> List[Tuple[str, Dict]]:
        """Get safe mode pipeline with extra validation"""
        scope = feature if feature else "all"

        return [
            ("inventory-scout", {"scope": scope, "depth": 3}),
            ("build-sentinel", {"mode": "quick"}),  # Pre-check
            ("import-guardian", {"mode": "detect"}),
            ("build-sentinel", {"mode": "quick"})   # Post-check
        ]

    def _execute_with_monitoring(
        self,
        pipeline: List[Tuple[str, Dict]],
        pipeline_type: str
    ) -> Dict[str, Any]:
        """Execute pipeline with monitoring and checkpointing"""

        start_time = datetime.now()
        results = []
        failed = False

        print(f"\n{'='*60}")
        print(f" ORCHESTRATOR PIPELINE: {pipeline_type.upper()}")
        print(f" Flags: {self.flags if self.flags else 'none'}")
        print(f" Steps: {len(pipeline)}")
        print(f"{'='*60}\n")

        for i, (agent, params) in enumerate(pipeline, 1):
            print(f"\n[Step {i}/{len(pipeline)}] Running {agent}...")
            print(f"  Params: {params}")

            # Execute agent
            result = self.orchestrator.run_agent(agent, params)

            # Store result
            results.append({
                "step": i,
                "agent": agent,
                "params": params,
                "status": result.get("status"),
                "timestamp": result.get("timestamp")
            })

            # Check for failures
            if result.get("status") == "fail":
                print(f"  ❌ {agent} failed!")
                if "safe" in self.flags:
                    print("  🛑 Safe mode: Stopping pipeline")
                    failed = True
                    break
                else:
                    print("  ⚠️  Continuing despite failure...")
            else:
                print(f"  ✅ {agent} completed")

            # Save checkpoint if sequential flag is set
            if "seq" in self.flags:
                self._save_checkpoint(i, agent, result)

            # Check for next action override
            if result.get("next_action") and "seq" not in self.flags:
                next_agent = result["next_action"].get("recommended_agent")
                if next_agent and next_agent not in [a for a, _ in pipeline[i:]]:
                    print(f"  💡 Recommended next: {next_agent}")

        # Calculate execution time
        execution_time = (datetime.now() - start_time).total_seconds()

        # Prepare final output
        output = {
            "agent": "orchestrator-pipeline",
            "version": "1.0.0",
            "timestamp": datetime.now().isoformat(),
            "status": "fail" if failed else "success",
            "data": {
                "pipeline_type": pipeline_type,
                "steps_total": len(pipeline),
                "steps_completed": len(results),
                "execution_time_seconds": execution_time,
                "flags": list(self.flags),
                "results": results
            },
            "metrics": {
                "success_rate": sum(1 for r in results if r["status"] == "success") / len(results) if results else 0,
                "execution_time_ms": int(execution_time * 1000)
            }
        }

        # Determine next action
        if not failed:
            output["next_action"] = {
                "recommended_agent": "build-sentinel",
                "params": {"mode": "quick"},
                "priority": "low",
                "reason": "Final validation after pipeline completion"
            }
        else:
            # Find the failed agent and suggest recovery
            failed_agent = results[-1]["agent"] if results else None
            if failed_agent == "build-sentinel":
                output["next_action"] = {
                    "recommended_agent": "import-guardian",
                    "params": {"mode": "fix"},
                    "priority": "high",
                    "reason": "Fix issues detected by build sentinel"
                }

        # Print summary
        self._print_summary(output)

        return output

    def _save_checkpoint(self, step: int, agent: str, result: Dict):
        """Save checkpoint for recovery"""
        checkpoint_key = f"{datetime.now().isoformat()}_{step}_{agent}"
        self.checkpoints[checkpoint_key] = result
        print(f"  💾 Checkpoint saved: {checkpoint_key}")

    def _print_summary(self, output: Dict):
        """Print execution summary"""
        print(f"\n{'='*60}")
        print(" PIPELINE EXECUTION SUMMARY")
        print(f"{'='*60}")

        data = output["data"]
        print(f"Type: {data['pipeline_type']}")
        print(f"Status: {output['status']}")
        print(f"Steps: {data['steps_completed']}/{data['steps_total']}")
        print(f"Time: {data['execution_time_seconds']:.2f}s")

        if output["status"] == "success":
            print("\n🎉 Pipeline completed successfully!")
        else:
            print("\n⚠️  Pipeline failed or was interrupted")

        if output.get("next_action"):
            next_action = output["next_action"]
            print(f"\nRecommended next: {next_action['recommended_agent']}")
            print(f"Reason: {next_action['reason']}")


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description="Orchestrate complex multi-agent pipelines"
    )

    parser.add_argument(
        "pipeline",
        choices=["c7", "quality", "feature", "safe"],
        help="Pipeline type to execute"
    )

    parser.add_argument(
        "--feature",
        help="Feature name for feature-specific pipelines"
    )

    parser.add_argument(
        "--quality",
        action="store_true",
        help="Enable quality checks"
    )

    parser.add_argument(
        "--safe",
        action="store_true",
        help="Safe mode - stop on errors"
    )

    parser.add_argument(
        "--seq",
        action="store_true",
        help="Sequential mode with checkpoints"
    )

    parser.add_argument(
        "--c7",
        action="store_true",
        help="Full C7 migration mode"
    )

    args = parser.parse_args()

    # Collect flags
    flags = []
    if args.quality:
        flags.append("quality")
    if args.safe:
        flags.append("safe")
    if args.seq:
        flags.append("seq")
    if args.c7:
        flags.append("c7")

    # Create pipeline orchestrator
    orchestrator = OrchestratorPipeline()

    # Execute pipeline
    try:
        result = orchestrator.execute_pipeline(
            pipeline_type=args.pipeline,
            feature=args.feature,
            flags=flags
        )

        # Save JSON output
        output_file = Path("reports") / "orchestrator_pipeline.json"
        output_file.parent.mkdir(exist_ok=True)
        output_file.write_text(
            json.dumps(result, ensure_ascii=False, indent=2),
            encoding="utf-8"
        )

        # Also print JSON to stdout for Claude
        print("\n" + "="*60)
        print(" JSON OUTPUT FOR CLAUDE")
        print("="*60)
        print(json.dumps(result, ensure_ascii=False, indent=2))

        # Exit with appropriate code
        sys.exit(0 if result["status"] == "success" else 1)

    except Exception as e:
        error_output = {
            "agent": "orchestrator-pipeline",
            "version": "1.0.0",
            "timestamp": datetime.now().isoformat(),
            "status": "fail",
            "error": str(e)
        }
        print(json.dumps(error_output, ensure_ascii=False, indent=2))
        sys.exit(1)


if __name__ == "__main__":
    main()