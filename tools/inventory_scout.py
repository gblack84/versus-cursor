#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Inventory Scout - read-only scanner
- lib/ 트리 인벤토리
- 큰 파일(기본 300줄) 탐지
- 혼합 책임(여러 심볼 동시 등장) 후보 탐지
- 아키텍처 위반(금지 임포트) 리포트
출력: reports/inventory.json, tree_lib.txt, candidates_decompose.txt, violations.txt, 00_inventory.yml
"""
import argparse, json, os, re, sys
from pathlib import Path
from collections import defaultdict, Counter
from datetime import datetime

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
REPORTS = ROOT / "reports"
REPORTS.mkdir(exist_ok=True)

IMPORT_RE = re.compile(r'^\s*(import|export)\s+[\'"]([^\'"]+)[\'"]', re.M)

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--depth", type=int, default=5)
    p.add_argument("--line-threshold", type=int, default=300)
    p.add_argument("--scope", default="all",
                   help="comma list of features (e.g., posts,chat) or 'all'")
    p.add_argument("--symbols", default="Post,Vote,Moderation")
    p.add_argument("--ignore", default="test/,mocks/,*.g.dart,*.freezed.dart,build/,.dart_tool/,coverage/")
    # NL 한 줄 명령도 허용 (선택)
    p.add_argument("nl", nargs="*", help="optional natural language hint")
    return p.parse_args()

def should_ignore(path: Path, ignore_globs):
    sp = str(path).replace("\\", "/")
    for pat in ignore_globs:
        pat = pat.strip()
        if not pat:
            continue
        if pat.endswith("/"):
            if f"/{pat}" in sp or sp.startswith(pat) or sp.endswith("/"+pat[:-1]):
                return True
        if pat.startswith("*.") and sp.endswith(pat[1:]):
            return True
        if pat in sp:
            return True
    return False

def list_dart_files(scope_features, ignore_globs):
    files = []
    for p in LIB.rglob("*.dart"):
        if should_ignore(p, ignore_globs):
            continue
        if scope_features and "features" in p.parts:
            # scope 필터: features/<name>/ 이하만
            try:
                idx = p.parts.index("features")
                feat = p.parts[idx+1]
                if feat not in scope_features:
                    continue
            except Exception:
                pass
        files.append(p)
    return files

def make_tree(depth):
    out = []
    base_len = len(LIB.parts)
    for p in sorted(LIB.rglob("*")):
        rel = p.relative_to(LIB)
        if len(rel.parts) > depth:
            continue
        indent = "  " * (len(rel.parts)-1)
        out.append(f"{indent}{rel.name}")
    return "\n".join(out)

def scan_import_violations(files):
    """금지 임포트 규칙 검사 (import/export 라인만)"""
    vio = []
    for f in files:
        sp = str(f).replace("\\","/")
        with f.open("r", encoding="utf-8", errors="ignore") as fh:
            src = fh.read()
        for m in IMPORT_RE.finditer(src):
            target = m.group(2)
            # presentation → data (같은 feature)
            if "/features/" in sp and "/presentation/" in sp and "/features/" in target and "/data/" in target:
                # 같은 feature만 강하게 금지 (교차 feature는 별도 경고)
                try:
                    parts = sp.split("/features/")[1].split("/")
                    feat_src = parts[0]
                    feat_tgt = target.split("features/")[1].split("/")[0]
                    if feat_src == feat_tgt:
                        vio.append(("presentation->data", sp, target))
                except Exception:
                    pass
            # cross-feature presentation→presentation (warn)
            if "/features/" in sp and "/presentation/" in sp and "features/" in target and "/presentation/" in target:
                vio.append(("warn:cross-presentation", sp, target))
            # app → features/*/data (예외: app/di.dart)
            if "/lib/app/" in sp and not sp.endswith("/app/di.dart"):
                if "features/" in target and "/data/" in target:
                    vio.append(("app->data", sp, target))
            # core|global_services → features/*
            if "/lib/core/" in sp or "/lib/global_services/" in sp:
                if "features/" in target:
                    vio.append(("reverse:core/services->features", sp, target))
            # backend refs
            if "backend/" in target or "/lib/backend/" in sp:
                vio.append(("legacy:backend", sp, target))
    return vio

def main():
    args = parse_args()
    ignore_globs = [g.strip() for g in args.ignore.split(",")]
    scope_features = [] if args.scope == "all" else [s.strip() for s in args.scope.split(",")]

    files = list_dart_files(scope_features, ignore_globs)
    # 인벤토리 (라인 카운트)
    inventory = []
    big = []
    symbols = [s.strip() for s in args.symbols.split(",") if s.strip()]
    mixed_candidates = []

    for f in files:
        try:
            text = f.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        lines = text.splitlines()
        n = len(lines)
        inventory.append({"path": str(f.relative_to(ROOT)), "lines": n})
        if n >= args.line_threshold:
            big.append({"path": str(f.relative_to(ROOT)), "lines": n})
        found = []
        for sym in symbols:
            if re.search(r'\b' + re.escape(sym) + r'\b', text):
                found.append(sym)
        if len(set(found)) >= 2:
            mixed_candidates.append({"path": str(f.relative_to(ROOT)), "symbols": sorted(set(found))})

    # 위반
    violations = scan_import_violations(files)

    # 출력
    (REPORTS / "inventory.json").write_text(json.dumps({
        "generated_at": datetime.utcnow().isoformat()+"Z",
        "files": inventory,
    }, ensure_ascii=False, indent=2), encoding="utf-8")

    (REPORTS / "tree_lib.txt").write_text(make_tree(args.depth), encoding="utf-8")

    cand = []
    cand.append("# Large files\n")
    for it in sorted(big, key=lambda x: -x["lines"]):
        cand.append(f'{it["lines"]:>6}  {it["path"]}')
    cand.append("\n# Mixed-responsibility suspects\n")
    for it in mixed_candidates:
        cand.append(f'{",".join(it["symbols"]):<24}  {it["path"]}')
    (REPORTS / "candidates_decompose.txt").write_text("\n".join(cand), encoding="utf-8")

    vio_lines = []
    by_rule = Counter()
    for rule, src, tgt in violations:
        by_rule[rule]+=1
        vio_lines.append(f"[{rule}] {src}  ->  {tgt}")
    (REPORTS / "violations.txt").write_text("\n".join(vio_lines), encoding="utf-8")

    summary = {
        "agent": "inventory-scout",
        "parsed_options": {
            "depth": args.depth, "line_threshold": args.line_threshold,
            "scope": "all" if not scope_features else scope_features,
            "symbols": symbols, "ignore": ignore_globs
        },
        "findings": {
            "total_files": len(files),
            "large_files": len(big),
            "mixed_responsibility": len(mixed_candidates),
            "violations": sum(by_rule.values()),
            "violations_by_rule": dict(by_rule)
        },
        "output_files": [
            "reports/inventory.json","reports/tree_lib.txt",
            "reports/candidates_decompose.txt","reports/violations.txt"
        ],
        "next_steps": [
            "Run RepoMover for target features",
            "Run ImportGuardian autofix for violations",
            "Run BuildSentinel (quick) on impacted paths"
        ]
    }
    (REPORTS / "00_inventory.yml").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2),
        encoding="utf-8"
    )
    print("Inventory Scout done. See reports/ .")

if __name__ == "__main__":
    sys.exit(main())
