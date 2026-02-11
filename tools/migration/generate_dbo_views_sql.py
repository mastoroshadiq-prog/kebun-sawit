import json
import importlib.util
from pathlib import Path
import re


def extract_dbo_view_refs(sql: str):
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
        if sch == 'dbo':
            refs.add(obj)
    return refs


def main():
    base = Path('tools/migration')
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
            'dbo',
        )
        rows = cur.fetchall()

        view_defs = {}
        for r in rows:
            view_name = r[0]
            definition = r[1] or ''
            body = migr.rewrite_sqlserver_view_to_postgres(definition)
            body = body.replace('c.nama_sub AS nama_task', 'c.nama_sub_tindakan AS nama_task')
            view_defs[view_name] = body

        view_names = set(view_defs.keys())

        # Build dependency graph only for dbo view->view references
        dep_graph = {}
        for vname, body in view_defs.items():
            refs = {r for r in extract_dbo_view_refs(body) if r in view_names and r != vname}
            dep_graph[vname] = refs

        # Kahn topo sort (stable by name)
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

        # Any remaining (cycle/unresolved) appended after ordered section
        remaining = [v for v in sorted(view_names) if v not in ordered]
        final_order = ordered + remaining

        out = []
        out.append('-- Auto-generated converted PostgreSQL VIEW DDL from SQL Server schema dbo')
        out.append('CREATE SCHEMA IF NOT EXISTS dbo;')
        out.append('')

        out.append('-- Ordered by dependency when possible (dbo view-to-view refs)')
        out.append('')

        for view_name in final_order:
            body = view_defs[view_name]
            out.append(f'-- Source view: dbo.{view_name}')
            out.append(f'CREATE OR REPLACE VIEW dbo.{view_name} AS')
            out.append(body.rstrip(';'))
            out.append(';')
            out.append('')

        (base / 'converted_views_postgres.sql').write_text('\n'.join(out), encoding='utf-8')
        print(f'generated={len(rows)} views -> tools/migration/converted_views_postgres.sql')
    finally:
        conn.close()


if __name__ == '__main__':
    main()

