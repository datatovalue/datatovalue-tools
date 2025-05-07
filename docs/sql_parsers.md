# SQL Parsers
Functions which parse SQL queries and derive the logical structure and dependency graph.

### parse_sql_ctes
The `parse_sql_ctes` parses SQL queries and returns the sequence, name and contents of each common table expression (cte) in the query.

Argument | Data Type | Description
--- | --- | ---
**`sql_query`** | **`STRING`** | The SQL query to be analyzed.

#### Returns

Data Type | Data Structure | Description
--- | --- | ---
**`JSON`** | `ARRAY<STRUCT<cte_index STRING, cte_name STRING, cte_body STRING>>` | Common table expression (cte) code, split by named cte.
