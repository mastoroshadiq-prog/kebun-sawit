import json
import importlib.util
from pathlib import Path


TYPE_MAP = {
    'int': 'INTEGER',
    'bigint': 'BIGINT',
    'smallint': 'SMALLINT',
    'tinyint': 'SMALLINT',
    'bit': 'BOOLEAN',
    'float': 'DOUBLE PRECISION',
    'real': 'REAL',
    'decimal': 'NUMERIC',
    'numeric': 'NUMERIC',
    'money': 'NUMERIC(19,4)',
    'smallmoney': 'NUMERIC(10,4)',
    'datetime': 'TIMESTAMP',
    'datetime2': 'TIMESTAMP',
    'smalldatetime': 'TIMESTAMP',
    'date': 'DATE',
    'time': 'TIME',
    'nvarchar': 'TEXT',
    'varchar': 'TEXT',
    'nchar': 'TEXT',
    'char': 'TEXT',
    'text': 'TEXT',
    'ntext': 'TEXT',
    'uniqueidentifier': 'UUID',
}


def to_pg_type(sql_type: str, precision: int | None, scale: int | None):
    t = (sql_type or '').lower()
    if t in ('decimal', 'numeric') and precision and scale is not None:
        return f'NUMERIC({precision},{scale})'
    return TYPE_MAP.get(t, 'TEXT')


def main():
    base = Path('tools/migration')
    config = json.loads((base / 'config.json').read_text(encoding='utf-8'))
    missing = json.loads((base / 'view_missing_dependencies.json').read_text(encoding='utf-8'))

    needed_tables = set()
    for deps in missing.values():
        for dep in deps:
            parts = dep.split('.')
            if len(parts) == 2:
                sch, obj = parts
                # if dep is likely table (not view), we will introspect source tables
                needed_tables.add((sch, obj))

    spec = importlib.util.spec_from_file_location('migr', str(base / 'sqlserver_to_supabase.py'))
    migr = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(migr)

    src = migr.connect_sqlserver(config)
    dst = migr.connect_postgres(config)
    try:
        src_cur = src.cursor()
        dst_rel = migr.fetch_relations_postgres(dst)

        lines = []
        lines.append('-- Auto-generated stubs for missing base tables used by view dependencies')
        lines.append('-- Review before running in production')
        lines.append('')

        for sch, tbl in sorted(needed_tables):
            if (sch, tbl) in dst_rel:
                continue

            src_cur.execute(
                """
                SELECT c.name AS column_name,
                       t.name AS data_type,
                       c.is_nullable,
                       c.precision,
                       c.scale
                FROM sys.columns c
                JOIN sys.types t ON t.user_type_id = c.user_type_id
                JOIN sys.tables tb ON tb.object_id = c.object_id
                JOIN sys.schemas s ON s.schema_id = tb.schema_id
                WHERE s.name = ? AND tb.name = ?
                ORDER BY c.column_id
                """,
                sch,
                tbl,
            )
            cols = src_cur.fetchall()
            if not cols:
                continue

            lines.append(f'CREATE SCHEMA IF NOT EXISTS {sch};')
            lines.append(f'CREATE TABLE IF NOT EXISTS {sch}.{tbl} (')
            col_lines = []
            for c in cols:
                name = c[0]
                pg_type = to_pg_type(c[1], c[3], c[4])
                nullable = '' if c[2] else ' NOT NULL'
                col_lines.append(f'  {name} {pg_type}{nullable}')
            lines.append(',\n'.join(col_lines))
            lines.append(');')
            lines.append('')

        (base / 'missing_base_tables_stub.sql').write_text('\n'.join(lines), encoding='utf-8')
        print('generated -> tools/migration/missing_base_tables_stub.sql')
    finally:
        src.close()
        dst.close()


if __name__ == '__main__':
    main()

