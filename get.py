"""Fetch a LeetCode problem and scaffold it into problems/ for offline drilling.

Fetch only. No auth, no cookies, no tokens, no submission. Invoked by get.ps1.
"""

from __future__ import annotations

import html
import json
import re
import sys
import urllib.error
import urllib.request
from datetime import date
from pathlib import Path

GRAPHQL_URL = "https://leetcode.com/graphql"
PROBLEM_URL = "https://leetcode.com/problems/{slug}/"
QUERY = (
    'query { question(titleSlug: "%s") { questionId questionFrontendId title '
    "titleSlug content difficulty topicTags { name } } }"
)
# LeetCode's edge returns 403 for urllib's default agent. This is a plain browser
# User-Agent and nothing else: no cookies, no tokens, no session of any kind.
HEADERS = {
    "Content-Type": "application/json",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
}
REQUIRED_FIELDS = (
    # questionFrontendId is the number shown on the site; questionId is internal
    # and differs for most problems. Always record the one you can search for.
    "questionFrontendId",
    "title",
    "titleSlug",
    "content",
    "difficulty",
    "topicTags",
)

REPO_ROOT = Path(__file__).resolve().parent
PROBLEMS_DIR = REPO_ROOT / "problems"

PRE_RE = re.compile(r"<pre>(.*?)</pre>", re.S | re.I)
TABLE_DECL_RE = re.compile(r"Table:\s*<code>([A-Za-z_][A-Za-z0-9_]*)</code>", re.I)
# Sample blocks label their table either "Visits table:" or bare "Visits", so the
# suffix is optional. A bare word is only accepted when a pipe table follows it.
SAMPLE_HDR_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*)(?:\s+table)?\s*:?$", re.I)
NUMBERED_RE = re.compile(r"^(\d{3})-")
NUMERIC_TYPES = ("INTEGER", "BIGINT", "SMALLINT", "DOUBLE", "DECIMAL")

TYPE_MAP = {
    "int": "INTEGER",
    "integer": "INTEGER",
    "tinyint": "INTEGER",
    "smallint": "SMALLINT",
    "bigint": "BIGINT",
    "varchar": "VARCHAR",
    "char": "VARCHAR",
    "text": "VARCHAR",
    "string": "VARCHAR",
    "enum": "VARCHAR",
    "date": "DATE",
    "datetime": "TIMESTAMP",
    "timestamp": "TIMESTAMP",
    "time": "TIME",
    "decimal": "DECIMAL(18,2)",
    "numeric": "DECIMAL(18,2)",
    "float": "DOUBLE",
    "double": "DOUBLE",
    "real": "DOUBLE",
    "bool": "BOOLEAN",
    "boolean": "BOOLEAN",
}


def die(message: str) -> None:
    """Print a failure reason and stop. Used for every unexpected response shape."""
    print(f"\nSTOPPED: {message}", file=sys.stderr)
    raise SystemExit(1)


def post_graphql(slug: str) -> tuple[int, str]:
    """POST the question query. Returns (status_code, body_text)."""
    body = json.dumps({"query": QUERY % slug}).encode("utf-8")
    try:
        import requests

        resp = requests.post(GRAPHQL_URL, data=body, headers=HEADERS, timeout=30)
        return resp.status_code, resp.text
    except ImportError:
        pass

    req = urllib.request.Request(GRAPHQL_URL, data=body, headers=HEADERS, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return resp.status, resp.read().decode("utf-8")
    except urllib.error.HTTPError as exc:
        return exc.code, exc.read().decode("utf-8", errors="replace")


def fetch_question(slug: str) -> dict[str, object]:
    """Fetch one question. Stops loudly on 403, non-200, or a changed shape."""
    try:
        status, text = post_graphql(slug)
    except Exception as exc:
        die(f"request to {GRAPHQL_URL} failed: {type(exc).__name__}: {exc}")

    if status == 403:
        die(
            f"leetcode returned 403 for slug {slug!r}. The endpoint is refusing "
            "the request. Not working around it."
        )
    if status != 200:
        die(f"expected HTTP 200 from {GRAPHQL_URL}, got {status}")

    try:
        payload = json.loads(text)
    except json.JSONDecodeError:
        die(f"response was not JSON. First 200 chars: {text[:200]!r}")

    if payload.get("errors"):
        die(f"graphql returned errors: {json.dumps(payload['errors'])[:400]}")

    question = (payload.get("data") or {}).get("question")
    if question is None:
        die(
            f"no question returned for slug {slug!r}. Either the slug is wrong or "
            "the response shape has changed."
        )

    missing = [f for f in REQUIRED_FIELDS if f not in question]
    if missing:
        die(f"response shape has changed. Missing fields: {', '.join(missing)}")
    if not question.get("content"):
        die(
            f"{slug!r} returned empty content. Premium problems are not readable "
            "without auth, and this script does not do auth."
        )
    return question


def html_to_text(fragment: str) -> str:
    """Flatten an HTML fragment to readable plain text."""
    text = fragment.replace("\r\n", "\n")
    text = re.sub(r"(?i)<br\s*/?>", "\n", text)
    text = re.sub(r"(?i)</p\s*>", "\n\n", text)
    text = re.sub(r"(?i)<li\s*>", "  - ", text)
    text = re.sub(r"(?i)</(li|pre|div|ul|ol|table|tr)\s*>", "\n", text)
    text = re.sub(r"<[^>]+>", "", text)
    text = html.unescape(text).replace("\xa0", " ")
    text = re.sub(r"[ \t]+\n", "\n", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def parse_pipe_table(lines: list[str]) -> tuple[list[str], list[list[str]]] | None:
    """Parse a +---+ / | a | b | table. Returns (header, rows) or None."""
    header: list[str] | None = None
    rows: list[list[str]] = []
    started = False
    for line in lines:
        stripped = line.strip()
        if not stripped:
            if started:
                break
            continue
        if stripped.startswith("+") and set(stripped) <= set("+-"):
            started = True
            continue
        if stripped.startswith("|"):
            started = True
            cells = [c.strip() for c in stripped.strip("|").split("|")]
            if header is None:
                header = cells
            else:
                rows.append(cells)
            continue
        if started:
            break
    if header is None:
        return None
    return header, rows


def parse_schemas(content: str) -> dict[str, list[tuple[str, str]]]:
    """Map table name -> [(column, leetcode_type)] from the schema <pre> blocks."""
    pres = [(m.start(), m.group(1)) for m in PRE_RE.finditer(content)]
    schemas: dict[str, list[tuple[str, str]]] = {}
    for decl in TABLE_DECL_RE.finditer(content):
        name = decl.group(1)
        block = next((body for pos, body in pres if pos > decl.end()), None)
        if block is None:
            continue
        parsed = parse_pipe_table(html_to_text(block).split("\n"))
        if parsed is None:
            continue
        header, rows = parsed
        if len(header) < 2 or "column" not in header[0].lower():
            continue
        schemas[name] = [(r[0], r[1]) for r in rows if len(r) >= 2 and r[0]]
    return schemas


def parse_samples(content: str) -> dict[str, tuple[list[str], list[list[str]]]]:
    """Map table name -> (header, rows) from the Input: section of Example 1."""
    for match in PRE_RE.finditer(content):
        text = html_to_text(match.group(1))
        if "Input:" not in text:
            continue
        region = text.split("Input:", 1)[1]
        region = re.split(r"\n\s*Output:", region)[0]
        lines = region.split("\n")
        found: dict[str, tuple[list[str], list[list[str]]]] = {}
        for i, line in enumerate(lines):
            hdr = SAMPLE_HDR_RE.match(line.strip())
            if hdr is None:
                continue
            following = i + 1
            while following < len(lines) and not lines[following].strip():
                following += 1
            if following >= len(lines):
                continue
            # guard against matching stray prose: a real label is followed by a table
            if not lines[following].lstrip().startswith(("+", "|")):
                continue
            parsed = parse_pipe_table(lines[following:])
            if parsed is not None:
                found[hdr.group(1)] = parsed
        if found:
            return found
    return {}


def duckdb_type(leetcode_type: str) -> tuple[str, bool]:
    """Map a LeetCode column type to a DuckDB type. Returns (type, recognised)."""
    raw = leetcode_type.strip().lower()
    sized = re.match(r"(?:decimal|numeric)\s*\(\s*(\d+)\s*,\s*(\d+)\s*\)", raw)
    if sized:
        return f"DECIMAL({sized.group(1)},{sized.group(2)})", True
    base = re.sub(r"\(.*?\)", "", raw).strip()
    if base in TYPE_MAP:
        return TYPE_MAP[base], True
    return "VARCHAR", False


def infer_type_from_values(values: list[str]) -> str:
    """Fallback when a column has sample data but no declared type."""
    seen = [v.strip() for v in values if v.strip().lower() not in ("null", "none", "")]
    if not seen:
        return "VARCHAR"
    if all(re.fullmatch(r"-?\d+", v) for v in seen):
        return "INTEGER"
    if all(re.fullmatch(r"-?\d*\.\d+", v) for v in seen):
        return "DOUBLE"
    if all(re.fullmatch(r"\d{4}-\d{2}-\d{2}", v) for v in seen):
        return "DATE"
    if all(re.fullmatch(r"\d{4}-\d{2}-\d{2}[ T]\d{2}:\d{2}(:\d{2})?", v) for v in seen):
        return "TIMESTAMP"
    return "VARCHAR"


def sql_literal(value: str, column_type: str) -> tuple[str, str | None]:
    """Render one cell as a SQL literal. Returns (literal, warning_or_None)."""
    text = value.strip()
    if text.lower() in ("null", "none", ""):
        return "NULL", None
    if column_type.startswith(NUMERIC_TYPES):
        try:
            float(text)
        except ValueError:
            return (
                "'" + text.replace("'", "''") + "'",
                f"value {text!r} is not numeric but the column is {column_type}, "
                "quoted it as text",
            )
        return text, None
    if column_type == "BOOLEAN":
        if text.lower() in ("true", "1", "y", "yes"):
            return "true", None
        if text.lower() in ("false", "0", "n", "no"):
            return "false", None
    return "'" + text.replace("'", "''") + "'", None


def next_number(problems_dir: Path) -> int:
    """Next free NNN prefix in problems/."""
    numbers = []
    for path in problems_dir.glob("*.sql"):
        match = NUMBERED_RE.match(path.name)
        if match:
            numbers.append(int(match.group(1)))
    return max(numbers) + 1 if numbers else 1


def build_problem_file(question: dict[str, object]) -> str:
    """The drill file: header block, problem text as comments, blank query area."""
    slug = str(question["titleSlug"])
    tags = ", ".join(t["name"] for t in question["topicTags"]) or "none"
    prompt = html_to_text(str(question["content"]))
    commented = "\n".join(("-- " + line).rstrip() for line in prompt.split("\n"))
    return (
        f"-- source: leetcode {question['questionFrontendId']} "
        f"{PROBLEM_URL.format(slug=slug)}\n"
        f"-- problem: {question['title']} ({question['difficulty']}) [{tags}]\n"
        "-- pattern:\n"
        f"-- date: {date.today().isoformat()}\n"
        "-- minutes taken:\n"
        "-- solved unaided (y/n):\n"
        "\n"
        f"{commented}\n"
        "\n"
        "\n"
    )


def build_setup_file(
    question: dict[str, object],
    schemas: dict[str, list[tuple[str, str]]],
    samples: dict[str, tuple[list[str], list[list[str]]]],
) -> tuple[str, list[str], list[str]]:
    """The DuckDB setup file. Returns (sql_text, inferred_lines, warnings)."""
    inferred: list[str] = []
    warnings: list[str] = []
    parts: list[str] = [
        f"-- Sample data for {question['title']} "
        f"(leetcode {question['questionFrontendId']})",
        "-- Generated from the problem statement by get.ps1. Sample rows only,",
        "-- not the judge's full test data. A query that passes here can still fail.",
        "",
    ]

    for name in schemas:
        if name not in samples:
            warnings.append(f"no sample rows parsed for table {name}")
            parts.append(f"-- TODO: no sample rows parsed for {name}.")
            parts.append("-- Copy them out of the problem statement by hand.")
            parts.append("")

    for name, (header, rows) in samples.items():
        declared = dict(schemas.get(name, []))
        if name not in schemas:
            warnings.append(
                f"sample data for {name} has no matching schema block, "
                "types inferred from the values"
            )

        column_types: dict[str, str] = {}
        for column in header:
            if column in declared:
                mapped, recognised = duckdb_type(declared[column])
                column_types[column] = mapped
                flag = "" if recognised else "   (!) not recognised, defaulted"
                inferred.append(
                    f"  {name}.{column}: {declared[column]} -> {mapped}{flag}"
                )
                if not recognised:
                    warnings.append(
                        f"{name}.{column}: unrecognised leetcode type "
                        f"{declared[column]!r}, defaulted to VARCHAR"
                    )
            else:
                index = header.index(column)
                values = [r[index] for r in rows if len(r) == len(header)]
                guessed = infer_type_from_values(values)
                column_types[column] = guessed
                inferred.append(
                    f"  {name}.{column}: (not declared) -> {guessed}"
                    "   (!) inferred from sample values"
                )
                warnings.append(
                    f"{name}.{column} is not in the schema block, inferred "
                    f"{guessed} from sample values"
                )

        parts.append(f"DROP TABLE IF EXISTS {name};")
        columns_sql = ",\n".join(
            f"    {column} {column_types[column]}" for column in header
        )
        parts.append(f"CREATE TABLE {name} (\n{columns_sql}\n);")

        good_rows = [r for r in rows if len(r) == len(header)]
        for bad in [r for r in rows if len(r) != len(header)]:
            warnings.append(
                f"{name}: dropped a row with {len(bad)} cells, expected {len(header)}"
            )
            parts.append(f"-- TODO: unparsed row in {name}: {' | '.join(bad)}")

        if not good_rows:
            parts.append(f"-- TODO: no usable sample rows for {name}.")
            parts.append("")
            continue

        values_sql = []
        for row in good_rows:
            literals = []
            for column, cell in zip(header, row):
                literal, warning = sql_literal(cell, column_types[column])
                if warning:
                    warnings.append(f"{name}.{column}: {warning}")
                literals.append(literal)
            values_sql.append("    (" + ", ".join(literals) + ")")
        parts.append(
            f"INSERT INTO {name} ({', '.join(header)}) VALUES\n"
            + ",\n".join(values_sql)
            + ";"
        )
        parts.append("")

    if not samples:
        parts.append("-- TODO: no sample tables parsed out of this problem at all.")
        parts.append("-- Write the CREATE TABLE and INSERT statements by hand.")
        parts.append("")
        warnings.append("no sample tables parsed, setup file is a stub")

    return "\n".join(parts) + "\n", inferred, warnings


def main(argv: list[str]) -> int:
    if len(argv) != 1:
        print("usage: get.ps1 <problem-slug>", file=sys.stderr)
        return 2

    slug = argv[0].strip().rstrip("/")
    url_match = re.search(r"leetcode\.com/problems/([^/?#]+)", slug)
    if url_match:
        slug = url_match.group(1)

    if not PROBLEMS_DIR.is_dir():
        die(f"{PROBLEMS_DIR} does not exist. Run this from inside the repo.")

    question = fetch_question(slug)
    content = str(question["content"])
    schemas = parse_schemas(content)
    samples = parse_samples(content)

    number = next_number(PROBLEMS_DIR)
    stem = f"{number:03d}-{question['titleSlug']}"
    problem_path = PROBLEMS_DIR / f"{stem}.sql"
    setup_path = PROBLEMS_DIR / f"{stem}-setup.sql"

    if problem_path.exists() or setup_path.exists():
        die(f"{problem_path.name} already exists. Not overwriting.")

    setup_sql, inferred, warnings = build_setup_file(question, schemas, samples)
    problem_path.write_text(build_problem_file(question), encoding="utf-8")
    setup_path.write_text(setup_sql, encoding="utf-8")

    tags = ", ".join(t["name"] for t in question["topicTags"]) or "none"
    rel_problem = problem_path.relative_to(REPO_ROOT).as_posix()
    rel_setup = setup_path.relative_to(REPO_ROOT).as_posix()

    print()
    print(f"  {question['title']}  ({question['difficulty']})")
    print(f"  tags:    {tags}")
    print(f"  problem: {rel_problem}")
    print(f"  setup:   {rel_setup}")
    print()
    if inferred:
        print("  types inferred (leetcode -> duckdb):")
        for line in inferred:
            print(f"  {line}")
        print()
    if warnings:
        print("  warnings:")
        for line in warnings:
            print(f"    (!) {line}")
        print()
    print("  load the sample data:")
    print(
        "  py -c \"import duckdb; duckdb.connect('drill.duckdb')"
        f".execute(open('{rel_setup}').read())\""
    )
    print()
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
