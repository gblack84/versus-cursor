#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
DIBinder - app/di.dart에 Port↔Adapter 등록 라인/임포트 패치 생성 또는 적용
"""
import argparse, re, sys
from pathlib import Path
from datetime import datetime
import difflib

ROOT = Path(__file__).resolve().parents[1]
APP_DI = ROOT/"lib/app/di/injection.dart"  # 필요시 경로 조정
PATCHES = ROOT/"patches"; REPORTS = ROOT/"reports"
for d in (PATCHES, REPORTS): d.mkdir(exist_ok=True)

MARK_BEGIN = "// <DIBINDER BEGIN>"
MARK_END = "// <DIBINDER END>"

def ensure_markers(text):
    if MARK_BEGIN in text and MARK_END in text: return text
    return text + f"\n\n{MARK_BEGIN}\n{MARK_END}\n"

def insert_binding(text, port_imp, impl_imp, port_sym, impl_sym, ctor_args):
    text = ensure_markers(text)
    lines = text.splitlines(True)
    # imports
    if port_imp not in text: lines.insert(0, f"import '{port_imp}';\n")
    if impl_imp not in text: lines.insert(0, f"import '{impl_imp}';\n")
    # binding
    bind = f"  sl.registerLazySingleton<{port_sym}>(() => {impl_sym}({ctor_args}));\n"
    out = []
    inside=False
    for L in lines:
        out.append(L)
        if L.strip()==MARK_BEGIN.strip():
            inside=True
            out.append(bind)
        if L.strip()==MARK_END.strip():
            inside=False
    return "".join(out)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--feature", required=True)
    ap.add_argument("--port", required=True)      # package:.../features/x/domain/repositories/foo_repository.dart
    ap.add_argument("--adapter", required=True)   # package:.../features/x/data/repositories/foo_repository_impl.dart
    ap.add_argument("--port-sym", required=False) # FooRepository
    ap.add_argument("--impl-sym", required=False) # FooRepositoryImpl
    ap.add_argument("--deps", default="")         # firestore,dio,...
    ap.add_argument("--mode", choices=["detect","apply"], default="detect")
    ap.add_argument("--output", choices=["file", "stdout", "both"], default="file",
                    help="Output destination: file (default), stdout, or both")
    args = ap.parse_args()

    port_sym = args.port_sym or Path(args.port).stem.replace(".dart","").split("_")[-2].capitalize()+"Repository"
    impl_sym = args.impl_sym or Path(args.adapter).stem.replace(".dart","").split("_")[-3].capitalize()+"RepositoryImpl"
    ctor = ", ".join([f"sl<{d.strip().capitalize()}>()" for d in args.deps.split(",") if d.strip()])

    src = APP_DI.read_text(encoding="utf-8") if APP_DI.exists() else f"// created {datetime.utcnow().isoformat()}Z\n"
    new = insert_binding(src, args.port, args.adapter, port_sym, impl_sym, ctor)

    diff = "\n".join(difflib.unified_diff(src.splitlines(True), new.splitlines(True),
                                          fromfile=f"a/{APP_DI}", tofile=f"b/{APP_DI}", lineterm=""))
    patch = PATCHES/f"di_{args.feature}.diff"
    patch.write_text(diff, encoding="utf-8")

    if args.mode=="apply":
        APP_DI.parent.mkdir(parents=True, exist_ok=True)
        APP_DI.write_text(new, encoding="utf-8")

    # Claude-centric JSON output
    import json
    from datetime import datetime as dt

    bindings_added = 1 if new != src else 0
    next_action = None

    if bindings_added > 0 and args.mode == "apply":
        next_action = {
            "recommended_agent": "build-sentinel",
            "params": {"mode": "test", "test_path": f"lib/features/{args.feature}/"},
            "priority": "high",
            "reason": f"Test DI bindings for {args.feature} feature"
        }
    elif bindings_added > 0 and args.mode == "detect":
        next_action = {
            "recommended_agent": "di-binder",
            "params": {"feature": args.feature, "port": args.port, "adapter": args.adapter, "mode": "apply"},
            "priority": "medium",
            "reason": "Apply DI bindings"
        }

    claude_output = {
        "agent": "di-binder",
        "version": "1.0.0",
        "timestamp": dt.now().isoformat(),
        "status": "success" if bindings_added > 0 else "no_action",
        "data": {
            "feature": args.feature,
            "port": args.port,
            "adapter": args.adapter,
            "mode": args.mode,
            "bindings_added": bindings_added,
            "patch_file": str(patch) if bindings_added > 0 else None,
            "file_modified": str(APP_DI) if args.mode == "apply" and bindings_added > 0 else None
        },
        "next_action": next_action,
        "decision_hints": {
            "binding_needed": bindings_added > 0,
            "ready_to_apply": args.mode == "detect" and bindings_added > 0,
            "applied_successfully": args.mode == "apply" and bindings_added > 0
        }
    }

    # Save or output Claude-centric JSON based on args
    json_output = json.dumps(claude_output, ensure_ascii=False, indent=2)

    if args.output in ["file", "both"]:
        (REPORTS / "di_binder.json").write_text(
            json_output,
            encoding="utf-8"
        )

    if args.output in ["stdout", "both"]:
        print(json_output)
        sys.stdout.flush()

    # Keep legacy format
    (REPORTS / f"di_binder_{args.feature}.yml").write_text(
        f"feature: {args.feature}\nport: {args.port}\nadapter: {args.adapter}\npatch: {patch}\nmode: {args.mode}\n",
        encoding="utf-8"
    )
    print(f"[DIBinder] patch -> {patch} (mode={args.mode})")

if __name__=="__main__":
    sys.exit(main())
