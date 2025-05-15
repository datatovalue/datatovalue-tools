((
    WITH
      input_query_cte AS (
      SELECT
        sql_query AS sql_string ),
      raw_cte_definitions AS (
      SELECT
        sql_string,
        REGEXP_EXTRACT_ALL( sql_string, r'(?i)(\b[a-zA-Z_][a-zA-Z0-9_]*\s+AS\s*\(\s*(?:.|\n)*?\s*\))' ) AS extracted_blocks
      FROM
        input_query_cte ),
      unnested_cte_blocks_with_offset AS (
      SELECT
        block_text,
        original_offset
      FROM
        raw_cte_definitions,
        UNNEST(extracted_blocks) AS block_text
      WITH
      OFFSET
        AS original_offset
      WHERE
        block_text IS NOT NULL ),
      parsed_cte_components AS (
      SELECT
        original_offset + 1 AS cte_index,
        REGEXP_EXTRACT(block_text, r'(?i)^\s*([a-zA-Z_][a-zA-Z0-9_]*)') AS cte_name,
        REGEXP_EXTRACT(block_text, r'(?i)\bAS\s*\(\s*((?:.|\n)*)\s*\)\s*$') AS cte_body,
        original_offset
      FROM
        unnested_cte_blocks_with_offset )
    SELECT
      TO_JSON( ARRAY_AGG( STRUCT(p.cte_index,
            p.cte_name,
            p.cte_body)
        ORDER BY
          p.original_offset ))
    FROM
      parsed_cte_components AS p 
))