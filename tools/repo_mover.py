#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
RepoMover - backend → features 경로 이동 계획/실행
- mode=dry-run: 계획서/로그만 생성
- mode=apply: git mv(불가하면 os.rename) 수행
"""
import argparse, os, sys, json, subprocess
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
REPORTS = ROOT/"reports"; LOGS = ROOT/"logs"
for d in (REPORTS, LOGS): d.mkdir(exist_ok=True)

MAPS = {
  "repositories": ("lib/backend/repositories", "lib/features/{f}/data/repositories"),
  "mappers": ("lib/backend/repositories/mappers", "lib/features/{f}/data/mappers"),
  "firebase": ("lib/backend/firebase", "lib/core/infrastructure/firebase"),
  "api": ("lib/backend/api", "lib/global_services/http"),
  "exceptions": ("lib/backend/repositories/exceptions", "lib/core/errors"),
}

def pick(feature, include):
    targets = []
    for key in include:
        src_base, dst_tmpl = MAPS[key]
        sdir = ROOT/src_base
        if not sdir.exists(): continue
        for p in sdir.rglob("*.dart"):
            sp = str(p).replace("\\","/")
            if key in ("repositories","mappers"):
                if f"{feature}" in sp:
                    targets.append((p, ROOT/dst_tmpl.format(f=feature)/p.name))
            else:
                targets.append((p, ROOT/dst_tmpl.format(f=feature)/p.name))
    return targets

def git_mv(src, dst):
    dst.parent.mkdir(parents=True, exist_ok=True)
    try:
        subprocess.run(["git","mv",str(src),str(dst)], check=True, cwd=ROOT)
        return True
    except Exception:
        # fallback
        os.makedirs(dst.parent, exist_ok=True)
        os.replace(src, dst)
        return False

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--feature", required=True)
    ap.add_argument("--mode", choices=["dry-run","apply"], default="dry-run")
    ap.add_argument("--include", default="repositories,mappers,firebase,api")
    ap.add_argument("--output", choices=["file", "stdout", "both"], default="file",
                    help="Output destination: file (default), stdout, or both")
    args = ap.parse_args()
    include = [s.strip() for s in args.include.split(",") if s.strip()]
    moves = pick(args.feature, include)

    plan = REPORTS/f"plan_{args.feature}.md"
    with plan.open("w", encoding="utf-8") as w:
        w.write(f"# RepoMover plan: {args.feature}\n\n|from|to|\n|---|---|\n")
        for s,d in moves:
            w.write(f"|{s.relative_to(ROOT)}|{d.relative_to(ROOT)}|\n")

    if args.mode=="apply":
        logf = LOGS/f"move_{args.feature}.log"
        with logf.open("w", encoding="utf-8") as log:
            for s,d in moves:
                d.parent.mkdir(parents=True, exist_ok=True)
                ok = git_mv(s,d)
                log.write(f"{'git mv' if ok else 'mv'} {s} -> {d}\n")

    # Claude-centric JSON output
    from datetime import datetime

    next_action = None
    if len(moves) > 0:
        if args.mode == "dry-run":
            next_action = {
                "recommended_agent": "repo-mover",
                "params": {"feature": args.feature, "mode": "apply", "include": args.include},
                "priority": "medium",
                "reason": f"Apply movement plan for {len(moves)} files"
            }
        else:
            next_action = {
                "recommended_agent": "import-guardian",
                "params": {"mode": "detect", "scope": args.feature},
                "priority": "high",
                "reason": f"Check imports after moving {len(moves)} files"
            }

    claude_output = {
        "agent": "repo-mover",
        "version": "1.0.0",
        "timestamp": datetime.now().isoformat(),
        "status": "success" if len(moves) > 0 else "no_action",
        "data": {
            "feature": args.feature,
            "mode": args.mode,
            "included_types": include,
            "files_to_move": len(moves),
            "plan_file": str(plan) if len(moves) > 0 else None,
            "log_file": str(LOGS/f"move_{args.feature}.log") if args.mode == "apply" else None,
            "movements": [
                {"from": str(s.relative_to(ROOT)), "to": str(d.relative_to(ROOT))}
                for s, d in moves[:5]  # First 5 for preview
            ] if len(moves) > 0 else []
        },
        "next_action": next_action,
        "decision_hints": {
            "has_movements": len(moves) > 0,
            "ready_to_apply": args.mode == "dry-run" and len(moves) > 0,
            "needs_import_check": args.mode == "apply" and len(moves) > 0,
            "feature_isolated": args.feature in include
        }
    }

    # Save or output Claude-centric JSON based on args
    json_output = json.dumps(claude_output, ensure_ascii=False, indent=2)

    if args.output in ["file", "both"]:
        (REPORTS / "repo_mover.json").write_text(json_output, encoding="utf-8")

    if args.output in ["stdout", "both"]:
        print(json_output)
        sys.stdout.flush()

    # Keep legacy output
    print(f"[RepoMover] wrote {plan} ({len(moves)} files). mode={args.mode}")

if __name__=="__main__":
    sys.exit(main())
