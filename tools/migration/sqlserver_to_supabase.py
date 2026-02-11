import argparse
import json
import re
from pathlib import Path
from datetime import datetime, timezone
from urllib.parse import urlparse

import pyodbc
import psycopg2
from psycopg2.extras import execute_values


def qident(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def load_config(path: str) -> dict:
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)


def load_checkpoint(path: str) -> dict:
    p = Path(path)
    if not p.exists():
        return {"tables": {}}
    with p.open('r', encoding='utf-8') as f:
        data = json.load(f)
    if 'tables' not in data or not isinstance(data['tables'], dict):
        data['tables'] = {}
    return data


def save_checkpoint(path: str, data: dict):
    p = Path(path)
    p.parent.mkdir(parents=True, exist_ok=True)
    with p.open('w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


def table_key(table_cfg: dict) -> str:
    src_schema = table_cfg.get('source_schema', 'dbo')
    src_table = table_cfg['source_table']
    dst_schema = table_cfg.get('target_schema', 'public')
    dst_table = table_cfg['target_table']
    return f"{src_schema}.{src_table}->{dst_schema}.{dst_table}"


def connect_sqlserver(cfg: dict):
    c = cfg['sqlserver']
    available_drivers = pyodbc.drivers()
    requested_driver = c.get('driver', '').strip()

    driver = requested_driver
    if requested_driver and requested_driver not in available_drivers:
        lowered = {d.lower(): d for d in available_drivers}
        match = lowered.get(requested_driver.lower())
        if match:
            driver = match
        else:
            preferred = [
                'ODBC Driver 18 for SQL Server',
                'ODBC Driver 17 for SQL Server',
                'SQL Server',
            ]
            driver = next((d for d in preferred if d in available_drivers), None)
            if not driver and available_drivers:
                driver = available_drivers[-1]

    if not driver:
        raise RuntimeError(
            'No ODBC SQL Server driver found. Install one (e.g., ODBC Driver 17/18) '
            'or set sqlserver.driver to an installed driver name.'
        )

    if requested_driver and driver != requested_driver:
        print(f"[SQLSERVER] Driver '{requested_driver}' not found, using '{driver}'")

    host_raw = str(c.get('host', '')).strip()
    if '://' in host_raw:
        parsed = urlparse(host_raw)
        host = parsed.hostname or host_raw
    else:
        host = host_raw

    conn_str = (
        f"DRIVER={{{driver}}};"
        f"SERVER={host},{c['port']};"
        f"DATABASE={c['database']};"
        f"UID={c['username']};"
        f"PWD={c['password']};"
        f"TrustServerCertificate={c.get('trust_server_certificate', 'yes')}"
    )
    return pyodbc.connect(conn_str)


def connect_postgres(cfg: dict):
    c = cfg['supabase_postgres']
    host_raw = str(c.get('host', '')).strip()
    if '://' in host_raw:
        parsed = urlparse(host_raw)
        host = parsed.hostname or host_raw
    else:
        host = host_raw

    # Common config mistake: using project URL host (<ref>.supabase.co)
    # instead of direct DB host (db.<ref>.supabase.co)
    if host.endswith('.supabase.co') and not host.startswith('db.'):
        parts = host.split('.')
        if len(parts) >= 3 and parts[1] == 'supabase' and parts[2] == 'co':
            host = f"db.{host}"
            print(f"[POSTGRES] Host auto-corrected to '{host}'")

    return psycopg2.connect(
        host=host,
        port=c['port'],
        dbname=c['database'],
        user=c['username'],
        password=c['password'],
        sslmode=c.get('sslmode', 'require'),
    )


def fetch_columns_sqlserver(src_conn, schema: str, table: str):
    cur = src_conn.cursor()
    cur.execute(
        """
        SELECT COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?
        ORDER BY ORDINAL_POSITION
        """,
        schema,
        table,
    )
    rows = cur.fetchall()
    return [r[0] for r in rows]


def fetch_tables_sqlserver(src_conn, schemas: list[str] | None = None):
    cur = src_conn.cursor()
    if schemas:
        placeholders = ','.join('?' for _ in schemas)
        cur.execute(
            f"""
            SELECT s.name AS schema_name, t.name AS table_name
            FROM sys.tables t
            JOIN sys.schemas s ON s.schema_id = t.schema_id
            WHERE s.name IN ({placeholders})
            ORDER BY s.name, t.name
            """,
            *schemas,
        )
    else:
        cur.execute(
            """
            SELECT s.name AS schema_name, t.name AS table_name
            FROM sys.tables t
            JOIN sys.schemas s ON s.schema_id = t.schema_id
            ORDER BY s.name, t.name
            """
        )
    return [(r[0], r[1]) for r in cur.fetchall()]


def fetch_tables_postgres(dst_conn):
    cur = dst_conn.cursor()
    cur.execute(
        """
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_type = 'BASE TABLE'
          AND table_schema NOT IN ('pg_catalog', 'information_schema')
        ORDER BY table_schema, table_name
        """
    )
    return {(r[0], r[1]) for r in cur.fetchall()}


def fetch_relations_postgres(dst_conn):
    cur = dst_conn.cursor()
    cur.execute(
        """
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_type IN ('BASE TABLE', 'VIEW')
          AND table_schema NOT IN ('pg_catalog', 'information_schema')
        """
    )
    return {(r[0], r[1]) for r in cur.fetchall()}


def fetch_columns_postgres(dst_conn, schema: str, table: str):
    cur = dst_conn.cursor()
    cur.execute(
        """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = %s AND table_name = %s
        ORDER BY ordinal_position
        """,
        (schema, table),
    )
    return [r[0] for r in cur.fetchall()]


def fetch_notnull_text_columns_postgres(dst_conn, schema: str, table: str):
    cur = dst_conn.cursor()
    cur.execute(
        """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = %s
          AND table_name = %s
          AND is_nullable = 'NO'
          AND data_type IN ('character varying', 'character', 'text')
        """,
        (schema, table),
    )
    return [r[0] for r in cur.fetchall()]


def fetch_pk_columns_postgres(dst_conn, schema: str, table: str):
    cur = dst_conn.cursor()
    cur.execute(
        """
        SELECT kcu.column_name
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kcu
          ON tc.constraint_name = kcu.constraint_name
         AND tc.table_schema = kcu.table_schema
         AND tc.table_name = kcu.table_name
        WHERE tc.constraint_type = 'PRIMARY KEY'
          AND tc.table_schema = %s
          AND tc.table_name = %s
        ORDER BY kcu.ordinal_position
        """,
        (schema, table),
    )
    return [r[0] for r in cur.fetchall()]


def fetch_required_no_default_columns_postgres(dst_conn, schema: str, table: str):
    cur = dst_conn.cursor()
    cur.execute(
        """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = %s
          AND table_name = %s
          AND is_nullable = 'NO'
          AND column_default IS NULL
          AND COALESCE(is_identity, 'NO') = 'NO'
          AND COALESCE(is_generated, 'NEVER') = 'NEVER'
        ORDER BY ordinal_position
        """,
        (schema, table),
    )
    return [r[0] for r in cur.fetchall()]


def normalize_col(name: str) -> str:
    return ''.join(ch for ch in str(name).lower() if ch.isalnum())


def fetch_views_sqlserver(src_conn, schemas: list[str] | None = None):
    cur = src_conn.cursor()
    if schemas:
        placeholders = ','.join('?' for _ in schemas)
        cur.execute(
            f"""
            SELECT s.name AS schema_name,
                   v.name AS view_name,
                   OBJECT_DEFINITION(v.object_id) AS definition
            FROM sys.views v
            JOIN sys.schemas s ON s.schema_id = v.schema_id
            WHERE s.name IN ({placeholders})
            ORDER BY s.name, v.name
            """,
            *schemas,
        )
    else:
        cur.execute(
            """
            SELECT s.name AS schema_name,
                   v.name AS view_name,
                   OBJECT_DEFINITION(v.object_id) AS definition
            FROM sys.views v
            JOIN sys.schemas s ON s.schema_id = v.schema_id
            ORDER BY s.name, v.name
            """
        )

    views = []
    for r in cur.fetchall():
        views.append(
            {
                'source_schema': r[0],
                'source_view': r[1],
                'definition': r[2] or '',
            }
        )
    return views


def rewrite_sqlserver_view_to_postgres(definition: str):
    sql = definition.strip().rstrip(';')

    # Remove batch/session directives often present around view scripts
    sql = re.sub(r'^\s*SET\s+ANSI_NULLS\s+ON\s*;?\s*$', '', sql, flags=re.IGNORECASE | re.MULTILINE)
    sql = re.sub(r'^\s*SET\s+QUOTED_IDENTIFIER\s+ON\s*;?\s*$', '', sql, flags=re.IGNORECASE | re.MULTILINE)
    sql = re.sub(r'^\s*GO\s*$', '', sql, flags=re.IGNORECASE | re.MULTILINE)

    # Keep only SELECT body after CREATE/ALTER VIEW ... AS
    m = re.search(r'\b(?:CREATE|ALTER)\s+VIEW\b', sql, flags=re.IGNORECASE)
    if m:
        tail = sql[m.start():]
        m_as = re.search(r'\bAS\b', tail, flags=re.IGNORECASE)
        if m_as:
            sql = tail[m_as.end():]

    # Normalize bracket identifiers first
    # [db].[schema].[object] -> [schema].[object] (Postgres has no cross-database reference)
    sql = re.sub(
        r'\[([^\]]+)\]\.\[([^\]]+)\]\.\[([^\]]+)\]',
        r'[\2].[\3]',
        sql,
        flags=re.IGNORECASE,
    )

    # Common translations
    sql = sql.replace('[', '"').replace(']', '"')
    sql = re.sub(r'\bGETDATE\s*\(\s*\)', 'NOW()', sql, flags=re.IGNORECASE)
    sql = re.sub(r'\bNEWID\s*\(\s*\)', 'gen_random_uuid()', sql, flags=re.IGNORECASE)
    sql = re.sub(r'\bISNULL\s*\(', 'COALESCE(', sql, flags=re.IGNORECASE)

    # SQL Server CONVERT(...) basic rewrite (common cases)
    sql = re.sub(
        r'\bCONVERT\s*\(\s*N?VAR?CHAR\s*\(\s*\d+\s*\)\s*,\s*([^\),]+(?:\([^\)]*\))?)\s*(?:,\s*[^\)]*)?\)',
        r'CAST(\1 AS TEXT)',
        sql,
        flags=re.IGNORECASE,
    )

    # APPLY rewrite (basic compatibility)
    sql = re.sub(r'\bCROSS\s+APPLY\b', 'CROSS JOIN LATERAL', sql, flags=re.IGNORECASE)
    sql = re.sub(r'\bOUTER\s+APPLY\b', 'LEFT JOIN LATERAL', sql, flags=re.IGNORECASE)

    # quoted 3-part name -> 2-part name (drop database)
    sql = re.sub(r'"([^"]+)"\."([^"]+)"\."([^"]+)"', r'"\2"."\3"', sql)

    # unquoted 3-part name -> 2-part name (drop database)
    sql = re.sub(
        r'\b([A-Za-z_][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)\b',
        r'\2.\3',
        sql,
    )

    # Safety: if definition still contains CREATE/ALTER VIEW, strip again conservatively
    sql = re.sub(r'\b(?:CREATE|ALTER)\s+VIEW\b.+?\bAS\b', '', sql, flags=re.IGNORECASE | re.DOTALL)

    return sql.strip()


def extract_relation_refs(sql: str):
    refs = set()
    # captures FROM schema.object and JOIN schema.object (quoted/unquoted)
    for m in re.finditer(
        r'\b(?:FROM|JOIN)\s+((?:"[^"]+"|[A-Za-z_][A-Za-z0-9_]*)\.(?:"[^"]+"|[A-Za-z_][A-Za-z0-9_]*))',
        sql,
        flags=re.IGNORECASE,
    ):
        rel = m.group(1)
        parts = rel.split('.')
        if len(parts) != 2:
            continue
        sch = parts[0].strip('"')
        obj = parts[1].strip('"')
        refs.add((sch, obj))
    return refs


def migrate_views(src_conn, dst_conn, cfg: dict, ckpt: dict, checkpoint_path: str):
    views_cfg = cfg.get('views', {})
    include_schemas = views_cfg.get('include_schemas')
    strict_dep_check = bool(views_cfg.get('strict_dependency_check', True))
    sql_replacements = views_cfg.get('sql_replacements', [])
    missing_dep_report = views_cfg.get('missing_dependency_report', 'tools/migration/view_missing_dependencies.json')

    schema_mapping = {}
    schema_mapping.update(cfg.get('auto_tables', {}).get('schema_mapping', {}))
    schema_mapping.update(views_cfg.get('schema_mapping', {}))

    if 'views' not in ckpt or not isinstance(ckpt['views'], dict):
        ckpt['views'] = {}

    raw_views = fetch_views_sqlserver(src_conn, include_schemas)
    print(f"VIEWS PLAN => selected={len(raw_views)}")

    # Build pending list (exclude already-success from checkpoint)
    pending = []
    for v in raw_views:
        src_schema = v['source_schema']
        src_view = v['source_view']
        target_schema = schema_mapping.get(src_schema, src_schema)
        key = f"{src_schema}.{src_view}->{target_schema}.{src_view}"
        record = ckpt['views'].get(key, {})
        if record.get('status') == 'success':
            print(f"SKIP VIEW (checkpoint success): {key}")
            continue
        pending.append((v, target_schema, key))

    if not pending:
        print('VIEWS DONE => success=0 failed=0 (nothing to do)')
        return

    success = 0
    failed_map = {}
    missing_dep_map = {}
    max_passes = max(2, len(pending) + 1)

    for p in range(1, max_passes + 1):
        if not pending:
            break

        print(f"VIEWS PASS {p}: pending={len(pending)}")
        next_pending = []
        pass_success = 0

        for v, target_schema, key in pending:
            src_view = v['source_view']
            started_at = datetime.now(timezone.utc).isoformat()
            ckpt['views'][key] = {
                'status': 'running',
                'started_at': started_at,
                'finished_at': None,
                'error': None,
            }
            save_checkpoint(checkpoint_path, ckpt)

            try:
                view_sql = rewrite_sqlserver_view_to_postgres(v['definition'])

                # optional manual rewrite hooks from config for edge-case views
                # format: [{"from": "old", "to": "new"}, ...]
                if isinstance(sql_replacements, list):
                    for rep in sql_replacements:
                        if not isinstance(rep, dict):
                            continue
                        old = rep.get('from')
                        new = rep.get('to')
                        if isinstance(old, str) and isinstance(new, str) and old:
                            view_sql = view_sql.replace(old, new)

                if strict_dep_check:
                    existing_rel = fetch_relations_postgres(dst_conn)
                    refs = extract_relation_refs(view_sql)
                    missing = [(s, o) for s, o in refs if (s, o) not in existing_rel]
                    if missing:
                        msg = 'missing dependencies: ' + ', '.join(f'{s}.{o}' for s, o in sorted(missing))
                        failed_map[key] = msg
                        missing_dep_map[key] = sorted(f'{s}.{o}' for s, o in missing)
                        if p < max_passes:
                            next_pending.append((v, target_schema, key))
                            print(f"VIEW RETRY [{key}] => {msg}")
                            continue
                        raise RuntimeError(msg)

                dst_cur = dst_conn.cursor()
                dst_cur.execute(f"CREATE SCHEMA IF NOT EXISTS {qident(target_schema)}")
                dst_cur.execute(
                    f"CREATE OR REPLACE VIEW {qident(target_schema)}.{qident(src_view)} AS {view_sql}"
                )
                dst_conn.commit()

                success += 1
                pass_success += 1
                failed_map.pop(key, None)
                missing_dep_map.pop(key, None)

                ckpt['views'][key] = {
                    'status': 'success',
                    'started_at': started_at,
                    'finished_at': datetime.now(timezone.utc).isoformat(),
                    'error': None,
                }
                save_checkpoint(checkpoint_path, ckpt)
                print(f"VIEW DONE [{key}]")
            except Exception as e:
                dst_conn.rollback()
                msg = str(e)
                failed_map[key] = msg

                # dependency-not-ready view gets retried in next pass
                dep_not_ready = 'does not exist' in msg.lower() and 'relation' in msg.lower()
                if dep_not_ready and p < max_passes:
                    next_pending.append((v, target_schema, key))
                    print(f"VIEW RETRY [{key}] => dependency not ready")
                    continue

                ckpt['views'][key] = {
                    'status': 'failed',
                    'started_at': started_at,
                    'finished_at': datetime.now(timezone.utc).isoformat(),
                    'error': msg,
                }
                save_checkpoint(checkpoint_path, ckpt)
                print(f"VIEW FAIL [{key}] => {msg}")

        pending = next_pending
        if pass_success == 0 and pending:
            # no progress; avoid infinite retry loop
            print('VIEWS: no progress in this pass, stopping retries')
            break

    # Mark remaining pending as failed after retry exhaustion
    for v, target_schema, key in pending:
        msg = failed_map.get(key, 'unresolved view dependency')
        ckpt['views'][key] = {
            'status': 'failed',
            'started_at': ckpt['views'].get(key, {}).get('started_at'),
            'finished_at': datetime.now(timezone.utc).isoformat(),
            'error': msg,
        }
        save_checkpoint(checkpoint_path, ckpt)
        print(f"VIEW FAIL [{key}] => {msg}")

    failed = len(pending) + sum(
        1 for k, v in ckpt['views'].items() if v.get('status') == 'failed' and k in failed_map
    )

    # write structured report for unresolved dependencies (for quick DDL checklist)
    if missing_dep_map:
        p = Path(missing_dep_report)
        p.parent.mkdir(parents=True, exist_ok=True)
        with p.open('w', encoding='utf-8') as f:
            json.dump(missing_dep_map, f, indent=2, ensure_ascii=False)
        print(f"VIEWS MISSING DEP REPORT => {missing_dep_report}")

    print(f"VIEWS DONE => success={success} failed={failed}")


def build_auto_tables_plan(src_conn, dst_conn, cfg: dict):
    auto_cfg = cfg.get('auto_tables', {})
    enabled = bool(auto_cfg.get('enabled', False))
    if not enabled:
        return None

    include_schemas = auto_cfg.get('include_schemas')
    schema_mapping = auto_cfg.get('schema_mapping', {})
    truncate_first = bool(auto_cfg.get('truncate_first', False))

    src_tables = fetch_tables_sqlserver(src_conn, include_schemas)
    dst_tables = fetch_tables_postgres(dst_conn)

    auto_tables = []
    skipped = []

    for src_schema, src_table in src_tables:
        dst_schema = schema_mapping.get(src_schema, src_schema)
        dst_key = (dst_schema, src_table)

        if dst_key not in dst_tables:
            skipped.append((src_schema, src_table, 'target_table_not_found'))
            continue

        src_cols = fetch_columns_sqlserver(src_conn, src_schema, src_table)
        dst_cols = fetch_columns_postgres(dst_conn, dst_schema, src_table)

        src_lc = {c.lower(): c for c in src_cols}
        dst_lc = {c.lower(): c for c in dst_cols}

        # exact name matches first
        common_pairs = []
        used_src = set()
        for d_lc, d in dst_lc.items():
            if d_lc in src_lc:
                s = src_lc[d_lc]
                common_pairs.append((s, d))
                used_src.add(s.lower())

        # infer simple alias for required target columns (ex: nama_sub -> nama_sub_tindakan)
        required_cols = fetch_required_no_default_columns_postgres(dst_conn, dst_schema, src_table)
        mapped_targets = {d.lower() for _, d in common_pairs}
        missing_required = [c for c in required_cols if c.lower() not in mapped_targets]

        inferred_pairs = []
        for target_col in missing_required:
            tnorm = normalize_col(target_col)
            candidates = []
            for s in src_cols:
                if s.lower() in used_src:
                    continue
                snorm = normalize_col(s)
                if not snorm:
                    continue
                if tnorm.startswith(snorm) or snorm.startswith(tnorm):
                    score = min(len(snorm), len(tnorm))
                    candidates.append((score, s))
            if candidates:
                candidates.sort(reverse=True)
                best_src = candidates[0][1]
                inferred_pairs.append((best_src, target_col))
                used_src.add(best_src.lower())

        all_pairs = common_pairs + inferred_pairs

        # validate required target columns are covered
        mapped_targets = {d.lower() for _, d in all_pairs}
        uncovered_required = [c for c in required_cols if c.lower() not in mapped_targets]

        if uncovered_required:
            skipped.append(
                (src_schema, src_table, f"missing_required_target_columns:{','.join(uncovered_required)}")
            )
            continue

        if not all_pairs:
            skipped.append((src_schema, src_table, 'no_common_columns'))
            continue

        # produce either source_columns (same-name) or explicit column_mapping
        has_renamed = any(s.lower() != d.lower() for s, d in all_pairs)
        if has_renamed:
            col_mapping = {s: d for s, d in all_pairs}
        else:
            col_mapping = None
        source_columns = [s for s, _ in all_pairs]

        auto_tables.append(
            {
                'source_schema': src_schema,
                'source_table': src_table,
                'target_schema': dst_schema,
                'target_table': src_table,
                'truncate_first': truncate_first,
                'source_columns': source_columns,
                **({'column_mapping': col_mapping} if col_mapping else {}),
            }
        )

    print(f"AUTO PLAN => selected={len(auto_tables)} skipped={len(skipped)}")
    for s in skipped[:20]:
        print(f"SKIP {s[0]}.{s[1]} ({s[2]})")
    if len(skipped) > 20:
        print(f"... and {len(skipped)-20} more skipped tables")

    return auto_tables


def migrate_table(src_conn, dst_conn, table_cfg: dict, batch_size: int = 1000):
    src_schema = table_cfg.get('source_schema', 'dbo')
    src_table = table_cfg['source_table']
    dst_schema = table_cfg.get('target_schema', 'public')
    dst_table = table_cfg['target_table']
    truncate_first = table_cfg.get('truncate_first', False)

    source_columns = table_cfg.get('source_columns')
    col_map = table_cfg.get('column_mapping')
    if col_map:
        src_cols = list(col_map.keys())
        dst_cols = [col_map[c] for c in src_cols]
    elif source_columns:
        src_cols = list(source_columns)
        dst_cols = list(source_columns)
    else:
        src_cols = fetch_columns_sqlserver(src_conn, src_schema, src_table)
        dst_cols = src_cols

    src_sel = ', '.join(f'[{c}]' for c in src_cols)
    src_from = f'[{src_schema}].[{src_table}]'

    dst_table_qualified = f"{qident(dst_schema)}.{qident(dst_table)}"
    dst_cols_quoted = ', '.join(qident(c) for c in dst_cols)
    insert_sql = f"INSERT INTO {dst_table_qualified} ({dst_cols_quoted}) VALUES %s"

    # Prevent common NotNullViolation on text columns by defaulting None -> ''
    # for NOT NULL text/varchar/char columns on target table.
    notnull_text_cols = set(fetch_notnull_text_columns_postgres(dst_conn, dst_schema, dst_table))
    dst_index = {c: i for i, c in enumerate(dst_cols)}
    dst_index_lc = {str(c).lower(): i for i, c in enumerate(dst_cols)}
    auto_text_fill_indexes = [
        dst_index_lc[c.lower()] for c in notnull_text_cols if c.lower() in dst_index_lc
    ]

    # Optional explicit replacement from config per target column
    # Example: "null_replacements": {"nama_sub_tindakan": "(unknown)"}
    null_replacements = table_cfg.get('null_replacements', {})
    explicit_fill = {
        dst_index_lc[str(col).lower()]: val
        for col, val in null_replacements.items()
        if str(col).lower() in dst_index_lc
    }

    # Duplicate handling (for resume/retry or pre-existing rows)
    # Default: ignore duplicate primary-key conflicts.
    conflict_mode = table_cfg.get('conflict_mode', 'ignore')
    if conflict_mode == 'ignore':
        pk_cols = fetch_pk_columns_postgres(dst_conn, dst_schema, dst_table)
        if pk_cols:
            pk_quoted = ', '.join(qident(c) for c in pk_cols)
            insert_sql += f" ON CONFLICT ({pk_quoted}) DO NOTHING"
        else:
            print(
                f"WARN [{dst_schema}.{dst_table}] conflict_mode=ignore but PK not found; "
                "insert will run without ON CONFLICT"
            )

    src_cur = src_conn.cursor()
    dst_cur = dst_conn.cursor()

    if truncate_first:
        dst_cur.execute(f"TRUNCATE TABLE {dst_table_qualified} RESTART IDENTITY CASCADE")
        dst_conn.commit()

    src_cur.execute(f"SELECT {src_sel} FROM {src_from}")

    total = 0
    while True:
        rows = src_cur.fetchmany(batch_size)
        if not rows:
            break

        payload = []
        for r in rows:
            vals = list(r)

            # explicit replacements have higher priority
            for idx, val in explicit_fill.items():
                if vals[idx] is None:
                    vals[idx] = val

            # fallback replacement for NOT NULL text columns
            for idx in auto_text_fill_indexes:
                if vals[idx] is None:
                    vals[idx] = ''

            payload.append(tuple(vals))

        try:
            execute_values(dst_cur, insert_sql, payload, page_size=batch_size)
            dst_conn.commit()
        except psycopg2.errors.NotNullViolation as e:
            # Fallback self-healing: if DB reports a specific NOT NULL column,
            # patch NULL -> '' for that target column and retry this batch once.
            dst_conn.rollback()
            col = None
            if hasattr(e, 'diag') and e.diag is not None:
                col = getattr(e.diag, 'column_name', None)

            if col and str(col).lower() in dst_index_lc:
                idx = dst_index_lc[str(col).lower()]
                repaired = 0
                repaired_payload = []
                for row in payload:
                    vals = list(row)
                    if vals[idx] is None:
                        vals[idx] = ''
                        repaired += 1
                    repaired_payload.append(tuple(vals))

                if repaired > 0:
                    print(
                        f"WARN [{dst_schema}.{dst_table}] repaired {repaired} NULL value(s) "
                        f"for NOT NULL column '{col}' and retrying batch"
                    )
                    execute_values(dst_cur, insert_sql, repaired_payload, page_size=batch_size)
                    dst_conn.commit()
                    payload = repaired_payload
                else:
                    raise
            else:
                raise

        total += len(payload)
        print(f"[{src_schema}.{src_table} -> {dst_schema}.{dst_table}] migrated: {total}")

    print(f"DONE [{src_schema}.{src_table}] total migrated: {total}")
    return total


def main():
    parser = argparse.ArgumentParser(description='Migrate SQL Server tables to Supabase Postgres')
    parser.add_argument('--config', required=True, help='Path to JSON config file')
    parser.add_argument('--batch-size', type=int, default=1000)
    parser.add_argument('--checkpoint', default='tools/migration/migration_checkpoint.json')
    parser.add_argument('--no-resume', action='store_true', help='Ignore checkpoint and run all tables')
    parser.add_argument('--reset-checkpoint', action='store_true', help='Clear checkpoint before running')
    parser.add_argument('--migrate-views', action='store_true', help='Also migrate SQL Server views')
    parser.add_argument('--views-only', action='store_true', help='Migrate only views, skip table data migration')
    args = parser.parse_args()

    cfg = load_config(args.config)

    src_conn = connect_sqlserver(cfg)
    dst_conn = connect_postgres(cfg)
    try:
        ckpt = load_checkpoint(args.checkpoint)
        if args.reset_checkpoint:
            ckpt = {"tables": {}}
            save_checkpoint(args.checkpoint, ckpt)

        if not args.views_only:
            tables = build_auto_tables_plan(src_conn, dst_conn, cfg)
            if tables is None:
                tables = cfg.get('tables', [])

            if not tables:
                raise ValueError(
                    'No tables to migrate. Isi config.tables atau aktifkan auto_tables.enabled=true'
                )

            for t in tables:
                key = table_key(t)
                record = ckpt['tables'].get(key, {})
                if not args.no_resume and record.get('status') == 'success':
                    print(f"SKIP (checkpoint success): {key}")
                    continue

                started_at = datetime.now(timezone.utc).isoformat()
                ckpt['tables'][key] = {
                    'status': 'running',
                    'started_at': started_at,
                    'finished_at': None,
                    'rows': 0,
                    'error': None,
                }
                save_checkpoint(args.checkpoint, ckpt)

                try:
                    rows = migrate_table(src_conn, dst_conn, t, batch_size=args.batch_size)
                    ckpt['tables'][key] = {
                        'status': 'success',
                        'started_at': started_at,
                        'finished_at': datetime.now(timezone.utc).isoformat(),
                        'rows': rows,
                        'error': None,
                    }
                    save_checkpoint(args.checkpoint, ckpt)
                except Exception as e:
                    ckpt['tables'][key] = {
                        'status': 'failed',
                        'started_at': started_at,
                        'finished_at': datetime.now(timezone.utc).isoformat(),
                        'rows': 0,
                        'error': str(e),
                    }
                    save_checkpoint(args.checkpoint, ckpt)
                    raise

        if args.migrate_views or bool(cfg.get('views', {}).get('enabled', False)):
            migrate_views(src_conn, dst_conn, cfg, ckpt, args.checkpoint)
    finally:
        src_conn.close()
        dst_conn.close()


if __name__ == '__main__':
    main()

