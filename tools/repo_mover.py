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
    print(f"[RepoMover] wrote {plan} ({len(moves)} files). mode={args.mode}")

if __name__=="__main__":
    sys.exit(main())
