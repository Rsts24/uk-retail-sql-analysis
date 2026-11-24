"""
Run every .sql file in queries/ against data/retail.db and save the
results as markdown tables in results/ (rendered nicely on GitHub).

Usage:
    python run_queries.py
"""

import sqlite3
from pathlib import Path

BASE = Path(__file__).parent
DB = BASE / "data" / "retail.db"
OUT = BASE / "results"


def split_statements(sql: str) -> list[str]:
    """Split a file into statements, ignoring comment-only chunks."""
    stmts = []
    for chunk in sql.split(";"):
        body = "\n".join(l for l in chunk.splitlines() if not l.strip().startswith("--"))
        if body.strip():
            stmts.append(chunk.strip())
    return stmts


def to_markdown(cols, rows) -> str:
    fmt = lambda v: "" if v is None else (f"{v:,.2f}" if isinstance(v, float) else str(v))
    lines = ["| " + " | ".join(cols) + " |", "|" + "---|" * len(cols)]
    lines += ["| " + " | ".join(fmt(v) for v in r) + " |" for r in rows]
    return "\n".join(lines)


def main() -> None:
    OUT.mkdir(exist_ok=True)
    con = sqlite3.connect(DB)
    for path in sorted((BASE / "queries").glob("*.sql")):
        parts = [f"# Results: `{path.name}`\n"]
        for i, stmt in enumerate(split_statements(path.read_text()), 1):
            cur = con.execute(stmt)
            cols = [d[0] for d in cur.description]
            rows = cur.fetchall()
            parts.append(f"### Query {i}\n\n{to_markdown(cols, rows)}\n")
        (OUT / f"{path.stem}.md").write_text("\n".join(parts))
        print(f"OK  {path.name}")
    con.close()


if __name__ == "__main__":
    main()
