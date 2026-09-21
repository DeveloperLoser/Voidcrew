"""Check a PR diff for Voidcrew placement and upstream edit markers.

Run: python -m tools.ci.check_modularization --base BASE --head HEAD [--github]
BASE must be the comparison tree (normally the merge base locally, or HEAD^1
on GitHub's PR merge commit). Only committed changes are inspected.

New DM, TGUI, map and asset files belong in the existing modular directories.
Upstream source changes need an inline/preceding VOIDCREW EDIT comment, or a
matching START/END block. An unpaired opening never exempts the rest of a file.
Removing marked fork code and moving code into modular files are permitted.
This checks placement/annotation, not whether an override could replace a hook.
"""

import argparse
from collections import Counter
from dataclasses import dataclass
import difflib
import json
from pathlib import Path, PurePosixPath
import re
import subprocess


FRONTEND_SUFFIXES = {".js", ".jsx", ".ts", ".tsx", ".scss", ".css"}
POLICY = "tools/ci/modularization_exceptions.json"
# Vendored TGS API updates retain their upstream layout and source comments.
VENDORED = ("code/modules/tgs/",)
MARKER = re.compile(r"\bVOIDCREW\s+EDIT\b", re.IGNORECASE)
BOUNDARY = re.compile(r"\bVOIDCREW\s+EDIT(?:\s+(?:ADDITION|REPLACEMENT|CHANGE|REMOVAL|DELETION))?\s+(START|BEGIN|END)\b|\b(START|BEGIN|END)\s+VOIDCREW\s+EDIT\b", re.IGNORECASE)


@dataclass(frozen=True)
class Finding:
    path: str
    line: int
    rule: str
    message: str


@dataclass(frozen=True)
class Change:
    status: str
    path: str
    old_path: str


@dataclass
class Source:
    lines: list[str]
    code: list[bool]
    normalized: list[str]
    covered: set[int]
    gaps: set[int]
    problems: list[tuple[int, str, str]]


def git(root: Path, *args: str) -> bytes:
    result = subprocess.run(
        ["git", *args], cwd=root, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        check=False,
    )
    if result.returncode:
        raise ValueError(result.stderr.decode("utf-8", errors="replace").strip())
    return result.stdout


def revision(root: Path, ref: str) -> str:
    return git(root, "rev-parse", "--verify", "--end-of-options", f"{ref}^{{commit}}").decode().strip()


def changes(root: Path, base: str, head: str) -> list[Change]:
    fields = git(root, "diff", "--no-ext-diff", "--name-status", "--find-renames", "-z", base, head, "--").decode("utf-8").split("\0")
    result = []
    cursor = 0
    while cursor < len(fields) - 1:
        status, path = fields[cursor:cursor + 2]
        cursor += 2
        old_path = path
        if status[0] in "RC":
            path = fields[cursor]
            cursor += 1
        result.append(Change(status[0], path, old_path))
    return result


def modular(path: str) -> bool:
    return path.startswith(("voidcrew/", "tgui/packages/voidcrew_tgui/", "_maps/voidcrew/"))


def source_file(path: str) -> bool:
    suffix = PurePosixPath(path).suffix.lower()
    return suffix == ".dm" or (path.startswith("tgui/packages/") and suffix in FRONTEND_SUFFIXES)


def upstream_source(path: str) -> bool:
    return source_file(path) and not modular(path) and path.startswith(("code/", "tgui/packages/")) and not path.startswith(VENDORED)


def placement_destination(path: str) -> str | None:
    if modular(path) or path.startswith(VENDORED):
        return None
    if path.startswith("code/") and path.endswith(".dm"):
        if path.startswith("code/__DEFINES/"):
            return "voidcrew/_DEFINES/"
        if path.startswith("code/modules/unit_tests/"):
            return "voidcrew/modules/unit_tests/"
        return "voidcrew/modules/<feature>/ or voidcrew/edits/"
    if path.startswith("tgui/packages/") and PurePosixPath(path).suffix.lower() in FRONTEND_SUFFIXES:
        return "tgui/packages/voidcrew_tgui/"
    if path.startswith(("icons/", "sound/")):
        return "voidcrew/modules/<feature>/icons/ or sound/"
    if path.startswith("_maps/") and path.endswith(".dmm"):
        return "_maps/voidcrew/"
    return None


def comments_and_code(lines: list[str]) -> tuple[list[str], list[bool], list[str]]:
    """Extract comments without accepting marker text inside quoted strings.

    Retain block-comment, template-string and DM multiline-string state. Ordinary
    quotes reset at line boundaries, including apostrophes in JSX prose.
    """
    comments, has_code, normalized = [], [], []
    block_depth = 0
    quote = None
    multiline = False
    for line in lines:
        parts = []
        code_parts = []
        i = 0
        while i < len(line):
            char, pair = line[i], line[i:i + 2]
            if block_depth:
                if pair == "*/":
                    block_depth -= 1
                    i += 2
                elif pair == "/*":
                    block_depth += 1
                    i += 2
                else:
                    parts.append(char)
                    i += 1
                continue
            if quote:
                if char == "\\":
                    code_parts.append(line[i:i + 2])
                    i += 2
                    continue
                code_parts.append(char)
                if char == quote:
                    quote = None
                    multiline = False
                i += 1
                continue
            if pair == "//":
                parts.append(line[i + 2:])
                break
            if pair == "/*":
                block_depth = 1
                parts.append(" ")
                code_parts.append(" ")
                i += 2
                continue
            if char in "\"'`":
                quote = char
                multiline = char == "`" or (char == '"' and i > 0 and line[i - 1] == "{")
            code_parts.append(char)
            i += 1
        comments.append("".join(parts))
        plain = "".join(code_parts).rstrip()
        # JSX comment delimiters are not an executable statement of their own.
        if parts and re.fullmatch(r"\s*\{\s*\}", plain):
            plain = ""
        normalized.append(plain)
        has_code.append(bool(plain.strip()))
        if not multiline:
            quote = None
    return comments, has_code, normalized


def analyze(text: str) -> Source:
    lines = text.splitlines()
    comments, code, normalized = comments_and_code(lines)
    covered, gaps, problems, pending = set(), set(), [], []
    for i, comment in enumerate(comments):
        if not MARKER.search(comment):
            continue
        boundary = BOUNDARY.search(comment)
        kind = (boundary[1] or boundary[2]).upper() if boundary else None
        signature = comment.strip()
        if kind in ("START", "BEGIN"):
            pending.append((i, signature))
        elif kind == "END":
            if pending:
                start, _ = pending.pop()
                covered.update(range(start, i + 1))
                gaps.update(range(start + 1, i + 1))
            else:
                problems.append((i, signature, "END marker has no matching START/BEGIN."))
        else:
            covered.add(i)
            if not code[i]:
                following = next((j for j in range(i + 1, len(lines)) if code[j]), None)
                if following is not None:
                    covered.add(following)
    problems.extend((i, signature, "START/BEGIN marker has no matching END.") for i, signature in pending)
    return Source(lines, code, normalized, covered, gaps, problems)


def opcodes(old: Source, new: Source):
    return difflib.SequenceMatcher(a=old.lines, b=new.lines, autojunk=False).get_opcodes()


def code_lines(source: Source, start: int, end: int) -> list[str]:
    return [source.normalized[i].strip() for i in range(start, end) if source.code[i]]


def moved_to_module(removed: list[str], additions: list[list[str]]) -> bool:
    # DM type extensions may regroup declarations during a move. Require every
    # removed code line, with its multiplicity, among additions to ONE module.
    # Existing modular code cannot justify an unrelated upstream deletion.
    wanted = Counter(removed)
    return bool(removed) and any(wanted <= Counter(added) for added in additions)


def check_source(path: str, old: Source, new: Source, additions: list[list[str]]) -> list[Finding]:
    findings = []
    existing = Counter((text, message) for _, text, message in old.problems)
    for line, text, message in new.problems:
        key = (text, message)
        if existing[key]:
            existing[key] -= 1
        else:
            findings.append(Finding(path, line + 1, "markers", message))
    for tag, old_start, old_end, new_start, new_end in opcodes(old, new):
        if tag == "equal":
            continue
        old_code = [old.normalized[i] for i in range(old_start, old_end) if old.code[i]]
        new_code = [new.normalized[i] for i in range(new_start, new_end) if new.code[i]]
        if old_code == new_code:
            continue  # Only comments or trailing whitespace changed; DM indentation matters.
        unmarked = [i for i in range(new_start, new_end) if new.code[i] and i not in new.covered]
        if unmarked:
            findings.append(Finding(path, unmarked[0] + 1, "markers", "Upstream code changed without VOIDCREW EDIT coverage. Use an inline/preceding comment for one line or matching START/END markers for a block."))
        # A replacement with new code is checked on its resulting implementation.
        if any(new.code[new_start:new_end]):
            continue
        removed_indices = [i for i in range(old_start, old_end) if old.code[i]]
        if not removed_indices or all(i in old.covered for i in removed_indices):
            continue
        if moved_to_module(code_lines(old, old_start, old_end), additions):
            continue
        # A deletion can leave an inline explanation or an empty marked block.
        if any(MARKER.search(comment) for comment in comments_and_code(new.lines[new_start:new_end])[0]):
            continue
        if new_start in new.gaps:
            continue
        findings.append(Finding(path, min(new_start + 1, max(len(new.lines), 1)), "markers", "Upstream code was removed without an edit marker or an exact move into modular code. Leave a VOIDCREW EDIT explanation at the removal."))
    return findings


def load_exceptions(path: Path) -> dict[str, set[str]]:
    policy = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(policy, dict):
        raise ValueError("Modularization exceptions must be a path-keyed object.")
    result = {}
    for name, entry in policy.items():
        if not isinstance(name, str) or not name or PurePosixPath(name).is_absolute() or any(part in ("", ".", "..") for part in name.split("/")) or any(char in name for char in "\\*?[]\n\r"):
            raise ValueError("Each modularization exception must name one exact repository-relative path.")
        if not isinstance(entry, dict) or set(entry) != {"rules", "reason"}:
            raise ValueError(f"Exception {name} needs only rules and a reason.")
        if not isinstance(entry["reason"], str) or not entry["reason"].strip():
            raise ValueError(f"Exception {name} needs a nonempty reason.")
        rules = entry["rules"]
        if not isinstance(rules, list) or not rules or any(rule not in ("placement", "markers") for rule in rules):
            raise ValueError(f"Exception {name} has invalid rules.")
        result[name] = set(rules)
    return result


def check(root: Path, base: str, head: str, exceptions: dict[str, set[str]] | None = None) -> list[Finding]:
    exceptions = exceptions or {}
    base, head = revision(root, base), revision(root, head)
    changed = changes(root, base, head)
    texts = {}

    def read(ref: str, path: str) -> Source:
        key = (ref, path)
        if key not in texts:
            texts[key] = analyze(git(root, "show", f"{ref}:{path}").decode("utf-8-sig"))
        return texts[key]

    empty = analyze("")
    additions = []
    for change in changed:
        if change.status == "D" or not modular(change.path) or not source_file(change.path):
            continue
        new = read(head, change.path)
        old = empty if change.status == "A" else read(base, change.old_path)
        # Whole-file moves need no deletion annotation in their former location.
        added = []
        for tag, _, _, start, end in opcodes(old, new):
            if tag != "equal":
                added.extend(code_lines(new, start, end))
        additions.append(added)
    findings = []
    for change in changed:
        ignored = exceptions.get(change.path, set())
        if change.status in ("A", "R", "C"):
            destination = placement_destination(change.path)
            if destination and "placement" not in ignored:
                findings.append(Finding(change.path, 1, "placement", f"New fork files belong in {destination} Move this file there; markers do not exempt file placement."))
                continue
        if not upstream_source(change.path) or "markers" in ignored:
            continue
        old = empty if change.status == "A" else read(base, change.old_path)
        new = empty if change.status == "D" else read(head, change.path)
        findings.extend(check_source(change.path, old, new, additions))
    return findings


def escape(value: str, *, property_value=False) -> str:
    value = value.replace("%", "%25").replace("\r", "%0D").replace("\n", "%0A")
    return value.replace(":", "%3A").replace(",", "%2C") if property_value else value


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base", required=True, help="Comparison commit, normally the PR merge commit's first parent")
    parser.add_argument("--head", default="HEAD")
    parser.add_argument("--repo", type=Path, default=Path("."))
    parser.add_argument("--exceptions", type=Path, default=Path(POLICY))
    parser.add_argument("--github", action="store_true", help="Emit GitHub error annotations")
    args = parser.parse_args(argv)
    try:
        policy_path = args.exceptions if args.exceptions.is_absolute() else args.repo / args.exceptions
        exceptions = load_exceptions(policy_path)
        findings = check(args.repo, args.base, args.head, exceptions)
    except (ValueError, OSError, UnicodeError) as error:
        message = f"Cannot check modularization: {error}"
        print(f"::error::{escape(message)}" if args.github else message)
        return 2
    for finding in findings:
        message = f"[{finding.rule}] {finding.message}"
        if args.github:
            print(f"::error file={escape(finding.path, property_value=True)},line={finding.line}::{escape(message)}")
        else:
            print(f"{finding.path}:{finding.line}: {message}")
    print(f"Modularization: {len(findings)} violation(s).")
    return int(bool(findings))


if __name__ == "__main__":
    raise SystemExit(main())
