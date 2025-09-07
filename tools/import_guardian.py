#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Import Guardian - architecture rule checker (+ conservative autofix)
- detect: violations.txt / import_guardian_<scope>.yml 생성
- fix: presentation->data, app->data의 "impl→port" import 치환 패치 생성
  * data/repositories/<name>_repository_impl.dart
    -> domain/repositories/<name>_repository.dart
주의: apply는 기본 False. git apply는 사람이 직접 수행 권장.
"""
import argparse, os, re, sys, json, difflib
from pathlib import Path
from datetime import datetime
from collections import defaultdict, Counter

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"
REPORTS = ROOT / "reports"
PATCHES = ROOT / "patches"
LOGS = ROOT / "logs"
for d in (REPORTS, PATCHES, LOGS): d.mkdir(exist_ok=True)

IMPORT_RE = re.compile(r'^\s*(import|export)\s+[\'"]([^\'"]+)[\'"]', re.M)

def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--scope", default="all", help="all or comma list of features")
    p.add_argument("--mode", choices=["detect","fix"], default="detect")
    p.add_argument("--apply", dest="apply", action="store_true", default=False)
    p.add_argument("--ignore", default="test/,mocks/,*.g.dart,*.freezed.dart,build/,.dart_tool/,coverage/")
    p.add_argument("--plan", default="", help="optional RepoMover plan for backend mapping (not used in this minimal skeleton)")
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
            try:
                idx = p.parts.index("features")
                feat = p.parts[idx+1]
                if feat not in scope_features:
                    continue
            except Exception:
                pass
        files.append(p)
    return files

def classify_violation(src_path: str, target: str):
    sp = src_path.replace("\\","/")
    # presentation -> data (same feature)
    if "/features/" in sp and "/presentation/" in sp and "/features/" in target and "/data/" in target:
        try:
            feat_src = sp.split("/features/")[1].split("/")[0]
            feat_tgt = target.split("features/")[1].split("/")[0]
            if feat_src == feat_tgt:
                return "presentation->data"
        except Exception:
            pass
        return "warn:cross-presentation"
    # app -> data (except di.dart)
    if "/lib/app/" in sp and not sp.endswith("/app/di.dart"):
        if "features/" in target and "/data/" in target:
            return "app->data"
    # core/services -> features
    if "/lib/core/" in sp or "/lib/global_services/" in sp:
        if "features/" in target:
            return "reverse:core/services->features"
    # backend refs
    if "backend/" in target or "/lib/backend/" in sp:
        return "legacy:backend"
    return ""

def fix_import_line(line: str):
    """
    data/repositories/<name>_repository_impl.dart -> domain/repositories/<name>_repository.dart
    반환: (fixed_line or None)
    """
    m = IMPORT_RE.match(line)
    if not m:
        return None
    target = m.group(2)
    if "/data/repositories/" in target and target.endswith("_repository_impl.dart"):
        fixed = target.replace("/data/repositories/", "/domain/repositories/").replace("_repository_impl.dart", "_repository.dart")
        return line.replace(target, fixed)
    return None

def generate_diffs(changes):
    """
    changes: list of (Path file, old_text, new_text)
    출력: patches/import_guardian_fix_presentation_data.diff + patches/import_guardian_fix_app_data.diff
    (간단히 하나 파일로도 충분하지만, 규칙별로 분리하면 리뷰가 쉬움)
    """
    out_path = PATCHES / "import_guardian_fix.diff"
    diffs = []
    for fpath, old, new in changes:
        rel = str(fpath.relative_to(ROOT)).replace("\\","/")
        diffs.extend(difflib.unified_diff(
            old.splitlines(True), new.splitlines(True),
            fromfile=f"a/{rel}", tofile=f"b/{rel}", lineterm=""
        ))
    out_path.write_text("\n".join(diffs), encoding="utf-8")
    return str(out_path)

def main():
    args = parse_args()
    ignore_globs = [g.strip() for g in args.ignore.split(",")]
    scope_features = [] if args.scope == "all" else [s.strip() for s in args.scope.split(",")]

    files = list_dart_files(scope_features, ignore_globs)
    violations = []
    by_rule = Counter()

    # 1) detect
    for f in files:
        try:
            text = f.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        for m in IMPORT_RE.finditer(text):
            target = m.group(2)
            rule = classify_violation(str(f), target)
            if rule:
                violations.append((rule, str(f.relative_to(ROOT)), target))
                by_rule[rule]+=1

    # 보고서
    vio_txt = "\n".join(f"[{r}] {src} -> {tgt}" for r,src,tgt in violations)
    (REPORTS / "violations.txt").write_text(vio_txt, encoding="utf-8")
    summary = {
        "agent": "import-guardian",
        "generated_at": datetime.utcnow().isoformat()+"Z",
        "params": {
            "scope": args.scope, "mode": args.mode, "apply": args.apply, "ignore": ignore_globs
        },
        "counts_by_rule": dict(by_rule),
        "total": sum(by_rule.values()),
        "next_steps": []
    }

    # 2) fix (보수적: import 줄 치환만)
    patch_path = ""
    if args.mode == "fix":
        changes = []
        for f in files:
            old = f.read_text(encoding="utf-8", errors="ignore")
            new_lines = []
            modified = False
            for line in old.splitlines(True):
                fixed = fix_import_line(line)
                if fixed and not str(f).endswith("/app/di.dart"):
                    new_lines.append(fixed)
                    modified = True
                else:
                    new_lines.append(line)
            new = "".join(new_lines)
            if modified and new != old:
                changes.append((f, old, new))
        if changes:
            patch_path = generate_diffs(changes)
            summary["fixes_generated"] = len(changes)
            summary["patch_file"] = patch_path
            summary["next_steps"].append(f"Review and apply patch: git apply {patch_path}")
        else:
            summary["fixes_generated"] = 0

    (REPORTS / f"import_guardian_{args.scope}.yml").write_text(
        json.dumps(summary, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print("Import Guardian done. See reports/ and patches/ .")

if __name__ == "__main__":
    sys.exit(main())
