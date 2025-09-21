#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CodeSurgeon - Feature-first Architecture 분해 도구
큰 파일에서 클래스, 함수, 상수를 추출하여 새 파일로 이동
"""
import argparse
import re
import sys
import os
import json
from pathlib import Path
from typing import Dict, List, Set, Tuple, Optional
import difflib

# 프로젝트 루트 경로
ROOT = Path(__file__).resolve().parents[1]
PATCHES = ROOT / "patches"
REPORTS = ROOT / "reports"
BRIDGE = ROOT / "lib" / "bridge"

# 디렉토리 생성
for d in (PATCHES, REPORTS, BRIDGE):
    d.mkdir(exist_ok=True)

# 정규식 패턴들
CLASS_PATTERN = re.compile(
    r'^(abstract\s+)?(class|mixin|extension)\s+(\w+).*?\{',
    re.MULTILINE | re.DOTALL
)
FUNCTION_PATTERN = re.compile(
    r'^(?:Future<[^>]+>|Stream<[^>]+>|[A-Z]\w*(?:<[^>]+>)?|\w+)\s+(\w+)\s*\([^)]*\)\s*(?:async\s*)?\{',
    re.MULTILINE
)
IMPORT_PATTERN = re.compile(r'^import\s+[\'"]([^\'"]+)[\'"];?', re.MULTILINE)
PACKAGE_IMPORT_PATTERN = re.compile(r'^import\s+[\'"]package:([^/]+)/.*[\'"];?', re.MULTILINE)

class CodeExtractor:
    """코드 추출 및 분해를 담당하는 클래스"""

    def __init__(self, file_path: Path):
        self.file_path = file_path
        self.content = file_path.read_text(encoding='utf-8')
        self.lines = self.content.splitlines(keepends=True)

    def find_symbol_boundaries(self, symbol_name: str) -> Optional[Tuple[int, int]]:
        """심볼의 시작과 끝 라인을 찾음"""
        # 클래스/mixin/extension 찾기
        for match in CLASS_PATTERN.finditer(self.content):
            if match.group(3) == symbol_name:
                start_pos = match.start()
                start_line = self.content[:start_pos].count('\n')

                # 중괄호 매칭으로 끝 찾기
                brace_count = 0
                in_class = False
                for i, line in enumerate(self.lines[start_line:], start=start_line):
                    for char in line:
                        if char == '{':
                            brace_count += 1
                            in_class = True
                        elif char == '}':
                            brace_count -= 1
                            if in_class and brace_count == 0:
                                return (start_line, i + 1)
                break

        # 함수 찾기
        for match in FUNCTION_PATTERN.finditer(self.content):
            if match.group(1) == symbol_name:
                start_pos = match.start()
                start_line = self.content[:start_pos].count('\n')

                # 함수 끝 찾기
                brace_count = 0
                in_function = False
                for i, line in enumerate(self.lines[start_line:], start=start_line):
                    for char in line:
                        if char == '{':
                            brace_count += 1
                            in_function = True
                        elif char == '}':
                            brace_count -= 1
                            if in_function and brace_count == 0:
                                return (start_line, i + 1)
                break

        return None

    def extract_symbol(self, symbol_name: str) -> Optional[str]:
        """심볼 코드 추출"""
        boundaries = self.find_symbol_boundaries(symbol_name)
        if not boundaries:
            return None

        start, end = boundaries
        return ''.join(self.lines[start:end])

    def get_required_imports(self, symbol_code: str) -> List[str]:
        """심볼에 필요한 import 추출"""
        imports = []

        # 현재 파일의 모든 import 수집
        for match in IMPORT_PATTERN.finditer(self.content):
            import_line = match.group(0)
            import_path = match.group(1)

            # 심볼 코드에서 사용되는 타입/클래스 확인
            # 간단한 휴리스틱: import의 마지막 부분이 코드에 있는지 확인
            if 'package:' in import_path:
                package_match = PACKAGE_IMPORT_PATTERN.match(import_line)
                if package_match:
                    package_name = package_match.group(1)
                    # 주요 패키지들 확인
                    if package_name in ['flutter', 'firebase_auth', 'cloud_firestore', 'get_it']:
                        imports.append(import_line)
            elif any(part in symbol_code for part in import_path.split('/')[-1:]):
                imports.append(import_line)

        # 기본 import 추가
        if 'FirebaseAuth' in symbol_code and "import 'package:firebase_auth/firebase_auth.dart';" not in imports:
            imports.append("import 'package:firebase_auth/firebase_auth.dart';")
        if 'FirebaseFirestore' in symbol_code and "import 'package:cloud_firestore/cloud_firestore.dart';" not in imports:
            imports.append("import 'package:cloud_firestore/cloud_firestore.dart';")
        if 'GetIt' in symbol_code and "import 'package:get_it/get_it.dart';" not in imports:
            imports.append("import 'package:get_it/get_it.dart';")

        return imports

def create_new_file_content(symbol_name: str, symbol_code: str, imports: List[str],
                           original_file: str) -> str:
    """새 파일 내용 생성"""
    content = []

    # 헤더 주석
    content.append("// GENERATED BY CodeSurgeon")
    content.append(f"// Extracted from: {original_file}")
    content.append("")

    # import 문
    for imp in imports:
        content.append(imp)
    if imports:
        content.append("")

    # 심볼 코드
    content.append(symbol_code)

    return '\n'.join(content)

def remove_symbol_from_original(content: str, symbol_name: str, boundaries: Tuple[int, int]) -> str:
    """원본 파일에서 심볼 제거"""
    lines = content.splitlines(keepends=True)
    start, end = boundaries

    # 심볼 앞의 주석도 함께 제거
    comment_start = start
    for i in range(start - 1, -1, -1):
        line = lines[i].strip()
        if line.startswith('//') or line.startswith('/*') or line.startswith('*') or not line:
            comment_start = i
        else:
            break

    # 제거
    del lines[comment_start:end]

    return ''.join(lines)

def create_bridge_file(symbols: Dict[str, Path]) -> str:
    """브릿지 파일 생성 (이전 호환성)"""
    content = []
    content.append("// GENERATED BY CodeSurgeon - Bridge file for backward compatibility")
    content.append("// This file will be removed after migration is complete")
    content.append("")

    for symbol, path in symbols.items():
        relative_path = path.relative_to(ROOT / 'lib')
        import_path = str(relative_path).replace('\\', '/').replace('.dart', '')
        content.append(f"export '/{import_path}.dart';")

    return '\n'.join(content)

def generate_patch(changes: List[Tuple[Path, str, str]]) -> str:
    """git diff 형식의 패치 생성"""
    patch_lines = []

    for file_path, old_content, new_content in changes:
        relative_path = file_path.relative_to(ROOT)

        # 파일별 diff 헤더
        patch_lines.append(f"diff --git a/{relative_path} b/{relative_path}")

        if not old_content:  # 새 파일
            patch_lines.append("new file mode 100644")
            patch_lines.append("index 0000000..1234567")
            patch_lines.append("--- /dev/null")
        else:  # 기존 파일 수정
            patch_lines.append("index 1234567..8901234 100644")
            patch_lines.append(f"--- a/{relative_path}")

        patch_lines.append(f"+++ b/{relative_path}")

        # diff 생성
        old_lines = old_content.splitlines(keepends=True) if old_content else []
        new_lines = new_content.splitlines(keepends=True) if new_content else []

        diff = list(difflib.unified_diff(
            old_lines, new_lines,
            lineterm='',
            n=3
        ))

        # @@ 헤더 추가
        if not old_content:
            patch_lines.append(f"@@ -0,0 +1,{len(new_lines)} @@")
        elif not new_content:
            patch_lines.append(f"@@ -1,{len(old_lines)} +0,0 @@")
        else:
            # 간단한 헤더 (전체 파일 변경으로 가정)
            patch_lines.append(f"@@ -1,{len(old_lines)} +1,{len(new_lines)} @@")

        # diff 내용 추가
        for line in diff[2:]:  # 헤더 2줄 건너뛰기
            if not line.startswith('---') and not line.startswith('+++'):
                patch_lines.append(line.rstrip())

    return '\n'.join(patch_lines)

def main():
    parser = argparse.ArgumentParser(description='CodeSurgeon - 코드 추출 도구')
    parser.add_argument('--file', required=True, help='소스 파일 경로')
    parser.add_argument('--map', required=True,
                       help='심볼 매핑 (예: "SignInUseCase->lib/features/auth/domain/usecases/sign_in.dart")')
    parser.add_argument('--mode', choices=['detect', 'apply'], default='detect',
                       help='실행 모드')
    parser.add_argument('--bridge', action='store_true', default=True,
                       help='브릿지 파일 생성')
    parser.add_argument('--output', choices=['file', 'stdout', 'both'], default='file',
                       help='Output destination: file (default), stdout, or both')

    args = parser.parse_args()

    # 경로 처리
    source_path = ROOT / args.file
    if not source_path.exists():
        print(f"[CodeSurgeon] 오류: 파일을 찾을 수 없음: {source_path}")
        return 1

    # 심볼 매핑 파싱
    symbols = {}
    for mapping in args.map.split(';'):
        if '->' in mapping:
            symbol, target = mapping.split('->')
            symbols[symbol.strip()] = ROOT / target.strip()

    if not symbols:
        print("[CodeSurgeon] 오류: 유효한 심볼 매핑이 없음")
        return 1

    print(f"[CodeSurgeon] 파일 분석 중: {source_path.name}", file=sys.stderr)

    # 추출기 생성
    extractor = CodeExtractor(source_path)
    changes = []

    # 각 심볼 추출
    for symbol_name, target_path in symbols.items():
        print(f"[CodeSurgeon] 심볼 추출 중: {symbol_name}", file=sys.stderr)

        # 심볼 경계 찾기
        boundaries = extractor.find_symbol_boundaries(symbol_name)
        if not boundaries:
            print(f"[CodeSurgeon] 경고: 심볼을 찾을 수 없음: {symbol_name}", file=sys.stderr)
            continue

        # 심볼 코드 추출
        symbol_code = extractor.extract_symbol(symbol_name)
        if not symbol_code:
            continue

        # 필요한 import 추출
        imports = extractor.get_required_imports(symbol_code)

        # 새 파일 내용 생성
        new_content = create_new_file_content(
            symbol_name, symbol_code, imports,
            str(source_path.relative_to(ROOT))
        )

        # 기존 파일 내용 (있다면)
        old_content = target_path.read_text(encoding='utf-8') if target_path.exists() else ""

        changes.append((target_path, old_content, new_content))

        # 원본에서 제거 (나중에 구현)
        # extractor.content = remove_symbol_from_original(extractor.content, symbol_name, boundaries)

    # 원본 파일 변경 추가 (필요시)
    # changes.append((source_path, source_path.read_text(), extractor.content))

    # 패치 생성
    patch_path = PATCHES / f"code_surgeon_{source_path.stem}.diff"
    patch_content = generate_patch(changes)
    patch_path.write_text(patch_content, encoding='utf-8')

    print(f"[CodeSurgeon] 패치 생성됨: {patch_path}", file=sys.stderr)

    # Claude-centric JSON output
    import json
    from datetime import datetime

    next_action = None
    if len(changes) > 0:
        if args.mode == 'detect':
            next_action = {
                "recommended_agent": "code-surgeon",
                "params": {"file": args.file, "map": args.map, "mode": "apply"},
                "priority": "medium",
                "reason": f"Apply patches for {len(changes)} extracted symbols"
            }
        else:
            next_action = {
                "recommended_agent": "import-guardian",
                "params": {"mode": "detect", "scope": "all"},
                "priority": "high",
                "reason": "Check for import violations after extraction"
            }

    claude_output = {
        "agent": "code-surgeon",
        "version": "1.0.0",
        "timestamp": datetime.now().isoformat(),
        "status": "success" if len(changes) > 0 else "no_action",
        "data": {
            "source_file": str(args.file),
            "mode": args.mode,
            "extracted_symbols": list(symbols.keys()),
            "target_mappings": {k: str(v) for k, v in symbols.items()},
            "patches_created": 1 if len(changes) > 0 else 0,
            "patch_file": str(patch_path) if len(changes) > 0 else None,
            "files_modified": len(changes),
            "bridge_created": args.bridge and len(symbols) > 0
        },
        "next_action": next_action,
        "decision_hints": {
            "extraction_needed": len(symbols) > 0,
            "patches_ready": len(changes) > 0,
            "needs_apply": args.mode == "detect" and len(changes) > 0,
            "needs_import_check": args.mode == "apply"
        }
    }

    # Save or output Claude-centric JSON based on args
    json_output = json.dumps(claude_output, ensure_ascii=False, indent=2)

    if args.output in ["file", "both"]:
        json_path = REPORTS / "code_surgeon.json"
        json_path.write_text(json_output, encoding='utf-8')

    if args.output in ["stdout", "both"]:
        print(json_output)
        sys.stdout.flush()

    # Keep legacy YAML format
    report_path = REPORTS / f"code_surgeon_{source_path.stem}.yml"
    report = f"""file: {args.file}
patch: {patch_path}
mode: {args.mode}
extracted: {len(changes)}
symbols:
{chr(10).join(f'  - {s}: {p}' for s, p in symbols.items())}
"""
    report_path.write_text(report, encoding='utf-8')

    # apply 모드에서 실제 파일 생성
    if args.mode == 'apply':
        for path, _, content in changes:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(content, encoding='utf-8')
            print(f"[CodeSurgeon] 파일 생성됨: {path}", file=sys.stderr)

    # 브릿지 파일 생성
    if args.bridge and symbols:
        try:
            bridge_path = BRIDGE / f"{source_path.stem}_bridge.dart"
            bridge_content = create_bridge_file(symbols)
            if args.mode == 'apply':
                bridge_path.write_text(bridge_content, encoding='utf-8')
                print(f"[CodeSurgeon] 브릿지 파일 생성됨: {bridge_path}", file=sys.stderr)
        except Exception as e:
            print(f"[CodeSurgeon] 브릿지 파일 생성 실패: {e}", file=sys.stderr)

    print(f"[CodeSurgeon] 완료! (mode={args.mode})", file=sys.stderr)
    return 0

if __name__ == "__main__":
    sys.exit(main())