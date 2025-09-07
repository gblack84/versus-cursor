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

    REPORTS/f"di_binder_{args.feature}.yml".write_text(
        f"feature: {args.feature}\nport: {args.port}\nadapter: {args.adapter}\npatch: {patch}\nmode: {args.mode}\n",
        encoding="utf-8"
    )
    print(f"[DIBinder] patch -> {patch} (mode={args.mode})")

if __name__=="__main__":
    sys.exit(main())
