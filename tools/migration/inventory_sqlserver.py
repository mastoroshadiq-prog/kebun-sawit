import argparse
import json
from pathlib import Path

import pyodbc


def connect_sqlserver(host: str, port: int, database: str, username: str, password: str, driver: str, trust_server_certificate: str = "yes"):
    conn_str = (
        f"DRIVER={{{driver}}};"
        f"SERVER={host},{port};"
        f"DATABASE={database};"
        f"UID={username};"
        f"PWD={password};"
        f"TrustServerCertificate={trust_server_certificate}"
    )
    return pyodbc.connect(conn_str)


def fetch_inventory(conn):
    cur = conn.cursor()

    cur.execute(
        """
        SELECT s.name AS schema_name, t.name AS table_name
        FROM sys.tables t
        JOIN sys.schemas s ON s.schema_id = t.schema_id
        ORDER BY s.name, t.name
        """
    )
    tables = cur.fetchall()

    inv = {}
    for schema_name, table_name in tables:
        inv.setdefault(schema_name, {})

        cur.execute(
            """
            SELECT
                c.column_id,
                c.name AS column_name,
                ty.name AS data_type,
                c.max_length,
                c.precision,
                c.scale,
                c.is_nullable,
                c.is_identity
            FROM sys.columns c
            JOIN sys.types ty ON c.user_type_id = ty.user_type_id
            JOIN sys.tables t ON c.object_id = t.object_id
            JOIN sys.schemas s ON t.schema_id = s.schema_id
            WHERE s.name = ? AND t.name = ?
            ORDER BY c.column_id
            """,
            schema_name,
            table_name,
        )
        cols = []
        for r in cur.fetchall():
            cols.append(
                {
                    "ordinal": int(r[0]),
                    "name": r[1],
                    "type": r[2],
                    "max_length": int(r[3]) if r[3] is not None else None,
                    "precision": int(r[4]) if r[4] is not None else None,
                    "scale": int(r[5]) if r[5] is not None else None,
                    "nullable": bool(r[6]),
                    "identity": bool(r[7]),
                }
            )

        cur.execute(
            """
            SELECT i.name
            FROM sys.indexes i
            JOIN sys.tables t ON i.object_id = t.object_id
            JOIN sys.schemas s ON t.schema_id = s.schema_id
            WHERE s.name = ? AND t.name = ? AND i.is_primary_key = 1
            """,
            schema_name,
            table_name,
        )
        pk_rows = [x[0] for x in cur.fetchall()]

        cur.execute(
            """
            SELECT c.name
            FROM sys.index_columns ic
            JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
            JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
            JOIN sys.tables t ON i.object_id = t.object_id
            JOIN sys.schemas s ON t.schema_id = s.schema_id
            WHERE s.name = ? AND t.name = ? AND i.is_primary_key = 1
            ORDER BY ic.key_ordinal
            """,
            schema_name,
            table_name,
        )
        pk_cols = [x[0] for x in cur.fetchall()]

        inv[schema_name][table_name] = {
            "primary_key_indexes": pk_rows,
            "primary_key_columns": pk_cols,
            "columns": cols,
        }

    return inv


def render_markdown(inv: dict) -> str:
    lines = ["# SQL Server Inventory", ""]
    total_tables = sum(len(t) for t in inv.values())
    lines.append(f"- Total schema: {len(inv)}")
    lines.append(f"- Total table: {total_tables}")
    lines.append("")

    for schema_name in sorted(inv.keys()):
        lines.append(f"## Schema: {schema_name}")
        lines.append("")
        for table_name in sorted(inv[schema_name].keys()):
            t = inv[schema_name][table_name]
            lines.append(f"### Table: {table_name}")
            lines.append(f"- PK: {', '.join(t['primary_key_columns']) if t['primary_key_columns'] else '-'}")
            lines.append("")
            lines.append("| # | Column | Type | Nullable | Identity |")
            lines.append("|---|--------|------|----------|----------|")
            for c in t["columns"]:
                lines.append(
                    f"| {c['ordinal']} | {c['name']} | {c['type']} | {'YES' if c['nullable'] else 'NO'} | {'YES' if c['identity'] else 'NO'} |"
                )
            lines.append("")
    return "\n".join(lines)


def main():
    p = argparse.ArgumentParser(description="Inventory SQL Server schema/tables")
    p.add_argument("--host", required=True)
    p.add_argument("--port", type=int, default=1433)
    p.add_argument("--database", required=True)
    p.add_argument("--username", required=True)
    p.add_argument("--password", required=True)
    p.add_argument("--driver", default="ODBC Driver 17 for SQL Server")
    p.add_argument("--trust", default="yes")
    p.add_argument("--out-json", default="tools/migration/sqlserver_inventory.json")
    p.add_argument("--out-md", default="tools/migration/sqlserver_inventory.md")
    args = p.parse_args()

    host = args.host.replace("http://", "").replace("https://", "").strip("/")

    conn = connect_sqlserver(
        host=host,
        port=args.port,
        database=args.database,
        username=args.username,
        password=args.password,
        driver=args.driver,
        trust_server_certificate=args.trust,
    )
    try:
        inv = fetch_inventory(conn)
    finally:
        conn.close()

    out_json = Path(args.out_json)
    out_md = Path(args.out_md)
    out_json.parent.mkdir(parents=True, exist_ok=True)
    out_md.parent.mkdir(parents=True, exist_ok=True)

    out_json.write_text(json.dumps(inv, indent=2, ensure_ascii=False), encoding="utf-8")
    out_md.write_text(render_markdown(inv), encoding="utf-8")

    total_tables = sum(len(t) for t in inv.values())
    print(f"Inventory selesai. Schema={len(inv)} Table={total_tables}")
    print(f"JSON: {out_json}")
    print(f"MD:   {out_md}")


if __name__ == "__main__":
    main()

