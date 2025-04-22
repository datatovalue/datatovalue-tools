// Parse the JSON schema
const schema = JSON.parse(input_schema);

// Function to generate SQL for a specific field
function generateSQLForField(field, jsonPath) {
const fullPath = jsonPath ? jsonPath + '.' + field.name : field.name;
const jsonPathExpr = '$.' + fullPath.replace(/\./g, '.');

// Handle different types
switch (field.type) {
    case 'STRING':
    return `JSON_VALUE(input_json, '${jsonPathExpr}')`;
    case 'INTEGER':
    case 'INT64':
    return `SAFE_CAST(JSON_VALUE(input_json, '${jsonPathExpr}') AS INT64)`;
    case 'FLOAT':
    case 'FLOAT64':
    return `SAFE_CAST(JSON_VALUE(input_json, '${jsonPathExpr}') AS FLOAT64)`;
    case 'BOOLEAN':
    case 'BOOL':
    return `SAFE_CAST(JSON_VALUE(input_json, '${jsonPathExpr}') AS BOOL)`;
    case 'DATE':
    return `SAFE_CAST(JSON_VALUE(input_json, '${jsonPathExpr}') AS DATE)`;
    case 'DATETIME':
    return `SAFE_CAST(JSON_VALUE(input_json, '${jsonPathExpr}') AS DATETIME)`;
    case 'TIMESTAMP':
    return `SAFE_CAST(JSON_VALUE(input_json, '${jsonPathExpr}') AS TIMESTAMP)`;
    case 'NUMERIC':
    return `SAFE_CAST(JSON_VALUE(input_json, '${jsonPathExpr}') AS NUMERIC)`;
    case 'BIGNUMERIC':
    return `SAFE_CAST(JSON_VALUE(input_json, '${jsonPathExpr}') AS BIGNUMERIC)`;
    case 'BYTES':
    return `SAFE_CAST(JSON_VALUE(input_json, '${jsonPathExpr}') AS BYTES)`;
    case 'RECORD':
    case 'STRUCT':
    return generateSQLForStruct(field, fullPath);
    default:
    // Handle ARRAY types
    if (field.type.startsWith('ARRAY<')) {
        const elementType = field.type.substring(6, field.type.length - 1);
        
        // Handle array of primitives vs array of records
        if (['STRING', 'INTEGER', 'INT64', 'FLOAT', 'FLOAT64', 'BOOLEAN', 'BOOL', 'DATE', 'DATETIME', 'TIMESTAMP', 'NUMERIC', 'BIGNUMERIC', 'BYTES'].includes(elementType)) {
        return `JSON_VALUE_ARRAY(input_json, '${jsonPathExpr}')`;
        } else if (elementType === 'RECORD' || elementType === 'STRUCT') {
        return `JSON_QUERY_ARRAY(input_json, '${jsonPathExpr}')`;
        }
    }
    
    // Default to JSON_QUERY for complex types not explicitly handled
    return `JSON_QUERY(input_json, '${jsonPathExpr}')`;
}
}

// Function to generate SQL for a STRUCT field
function generateSQLForStruct(field, jsonPath) {
const structFields = field.fields.map(subField => {
    const sql = generateSQLForField(subField, jsonPath);
    return `${sql} AS \`${subField.name}\``;
}).join(',\n    ');

return `STRUCT(\n    ${structFields}\n  )`;
}

// Start generating the SQL
let sqlParts = [];

// Process each field in the schema
for (const field of schema) {
const sql = generateSQLForField(field, '');
sqlParts.push(`${sql} AS \`${field.name}\``);
}

// Combine all parts into a SELECT statement
const finalSQL = `SELECT STRUCT(\n  ${sqlParts.join(',\n  ')}\n) AS payload`;

return finalSQL;