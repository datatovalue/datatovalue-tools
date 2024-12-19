((SELECT 
STRING_AGG(
    `datatovalue-tools.eu.unique_combination_query`(table_column_combination.table_id, table_column_combination.column_names)
    ,"\nUNION ALL\n")
    ||"\nORDER BY combination_columns ASC" 
FROM UNNEST(table_column_combinations) AS table_column_combination))