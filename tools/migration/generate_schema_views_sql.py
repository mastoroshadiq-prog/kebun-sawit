import argparse
import json
import importlib.util
import re
from pathlib import Path


def extract_refs(sql: str):
    refs = set()
    for m in re.finditer(
        r'\b(?:FROM|JOIN)\s+((?:"[^"]+"|[A-Za-z_][A-Za-z0-9_]*)\.(?:"[^"]+"|[A-Za-z_][A-Za-z0-9_]*))',
        sql,
        flags=re.IGNORECASE,
    ):
        rel = m.group(1)
        parts = rel.split('.')
        if len(parts) != 2:
            continue
        sch = parts[0].strip('"').lower()
        obj = parts[1].strip('"')
        refs.add((sch, obj))
    return refs


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--schema', required=True, help='Source schema view to convert (e.g. dbo, apk)')
    parser.add_argument('--out', default=None, help='Output SQL file path')
    args = parser.parse_args()

    target_schema = args.schema.lower()
    base = Path('tools/migration')
    out_path = Path(args.out) if args.out else base / f'converted_views_{target_schema}_postgres.sql'

    config = json.loads((base / 'config.json').read_text(encoding='utf-8'))

    spec = importlib.util.spec_from_file_location('migr', str(base / 'sqlserver_to_supabase.py'))
    migr = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(migr)

    conn = migr.connect_sqlserver(config)
    try:
        cur = conn.cursor()
        cur.execute(
            """
            SELECT v.name, OBJECT_DEFINITION(v.object_id) AS definition
            FROM sys.views v
            JOIN sys.schemas s ON s.schema_id = v.schema_id
            WHERE s.name = ?
            ORDER BY v.name
            """,
            target_schema,
        )
        rows = cur.fetchall()

        view_defs = {}
        for r in rows:
            view_name = r[0]
            definition = r[1] or ''
            body = migr.rewrite_sqlserver_view_to_postgres(definition)
            # known mismatch from earlier findings
            body = body.replace('c.nama_sub AS nama_task', 'c.nama_sub_tindakan AS nama_task')
            view_defs[view_name] = body

        view_names = set(view_defs.keys())

        # Order only by dependencies within same schema
        dep_graph = {}
        for vname, body in view_defs.items():
            refs = {
                obj for sch, obj in extract_refs(body)
                if sch == target_schema and obj in view_names and obj != vname
            }
            dep_graph[vname] = refs

        ready = sorted([v for v, deps in dep_graph.items() if not deps])
        ordered = []
        deps = {k: set(v) for k, v in dep_graph.items()}

        while ready:
            n = ready.pop(0)
            ordered.append(n)
            for k in sorted(deps.keys()):
                if n in deps[k]:
                    deps[k].remove(n)
                    if not deps[k] and k not in ordered and k not in ready:
                        ready.append(k)
                        ready.sort()

        remaining = [v for v in sorted(view_names) if v not in ordered]
        final_order = ordered + remaining

        out = []
        out.append(f'-- Auto-generated converted PostgreSQL VIEW DDL from SQL Server schema {target_schema}')
        out.append(f'CREATE SCHEMA IF NOT EXISTS {target_schema};')
        out.append('-- Ordered by dependency when possible (within same schema)')
        out.append('')

        for view_name in final_order:
            body = view_defs[view_name]
            out.append(f'-- Source view: {target_schema}.{view_name}')
            out.append(f'CREATE OR REPLACE VIEW {target_schema}.{view_name} AS')
            out.append(body.rstrip(';'))
            out.append(';')
            out.append('')

        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text('\n'.join(out), encoding='utf-8')
        print(f'generated={len(rows)} views -> {out_path.as_posix()}')
    finally:
        conn.close()


if __name__ == '__main__':
    main()

