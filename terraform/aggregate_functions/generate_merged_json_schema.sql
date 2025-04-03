# manually deployed as UDAFs not available in Terraform

SET @@location = "africa-south1";

DECLARE set_region, script STRING;
DECLARE regions ARRAY<STRING>;

SET regions = [
  "eu",
  "us",
  "us-east5",
  "us-south1",
  "us-central1",
  "us-west4",
  "us-west2",
  "northamerica-northeast1",
  "us-east4",
  "us-west1",
  "us-west3",
  "southamerica-east1",
  "southamerica-west1",
  "us-east1",
  "asia-south2",
  "asia-east2",
  "asia-southeast2",
  "australia-southeast2",
  "asia-south1",
  "asia-northeast2",
  "asia-northeast3",
  "asia-southeast1",
  "australia-southeast1",
  "asia-east1",
  "asia-northeast1",
  "europe-west1",
  "europe-west10",
  "europe-north1",
  "europe-west3",
  "europe-west2",
  "europe-southwest1",
  "europe-west8",
  "europe-west4",
  "europe-west9",
  "europe-west12",
  "europe-central2",
  "europe-west6",
  "me-west1",
  "africa-south1"];

FOR region IN (SELECT value FROM UNNEST(regions) AS value)
DO
SET set_region = "BEGIN SET @@location = '"||region.value||"'; END;";

SELECT set_region; 

SET script = 
'''
CREATE OR REPLACE AGGREGATE FUNCTION `datatovalue-tools.'''||REPLACE(region.value, '-', '_')||'''.generate_merged_json_schema`(json_value STRING)
RETURNS STRING
LANGUAGE js
AS """
  export function initialState() {
    return {
      // Store raw schemas as strings to avoid deep nesting in state
      schemaStrings: []
    };
  }
  
  export function aggregate(state, jsonString) {
    if (!jsonString) return;
    
    try {
      const jsonValue = JSON.parse(jsonString);
      if (typeof jsonValue === 'object' && jsonValue !== null) {
        // Extract schema from this JSON value
        const schema = extractSchema(jsonValue);
        // Store as string to avoid deep nesting in state
        state.schemaStrings.push(JSON.stringify(schema));
      }
    } catch (e) {
      // Skip invalid JSON
    }
  }
  
  export function merge(state, partialState) {
    state.schemaStrings = state.schemaStrings.concat(partialState.schemaStrings);
  }
  
  export function finalize(state) {
    // Parse stored schema strings back to objects for merging
    const schemas = state.schemaStrings.map(str => JSON.parse(str));
    // Merge all accumulated schemas
    const mergedSchema = mergeSchemas(schemas);
    return JSON.stringify(mergedSchema, null, 2);
  }
  
  // Utility function to determine field type from JavaScript type
  function determineBQType(value) {
    if (value === null || value === undefined) return null;
    
    const type = typeof value;
    
    if (Array.isArray(value)) {
      if (value.length === 0) return 'ARRAY<STRING>'; // Default to STRING for empty arrays
      
      // Sample the array to determine its type
      const sampleValue = value.find(item => item !== null && item !== undefined);
      if (sampleValue === undefined) return 'ARRAY<STRING>';
      
      if (typeof sampleValue === 'object' && sampleValue !== null) {
        return `ARRAY<RECORD>`;
      } else {
        return `ARRAY<${determineBQType(sampleValue)}>`;
      }
    }
    
    if (type === 'object') return 'RECORD';
    if (type === 'string') return 'STRING';
    if (type === 'number') {
      // Check if it's an integer
      return Number.isInteger(value) ? 'INT64' : 'FLOAT64';
    }
    if (type === 'boolean') return 'BOOLEAN';
    
    return 'STRING'; // Default
  }
  
  // Recursively extract schema from an object
  function extractSchema(obj) {
    if (obj === null || obj === undefined) return [];
    
    let schema = [];
    
    Object.keys(obj).forEach(key => {
      const value = obj[key];
      
      if (value === null || value === undefined) {
        schema.push({
          name: key,
          type: 'STRING',  // Default for null values
          mode: 'NULLABLE'
        });
        return;
      }
      
      const type = determineBQType(value);
      
      if (type === 'RECORD') {
        schema.push({
          name: key,
          type: 'RECORD',
          mode: 'NULLABLE',
          fields: extractSchema(value)
        });
      } else if (type && type.startsWith('ARRAY<')) {
        if (type === 'ARRAY<RECORD>') {
          // For an array of records, we need to extract the schema of the first non-null item
          const sampleValue = value.find(item => item !== null && item !== undefined);
          if (sampleValue) {
            schema.push({
              name: key,
              type: 'RECORD',
              mode: 'REPEATED',
              fields: extractSchema(sampleValue)
            });
          } else {
            // Empty array of records
            schema.push({
              name: key,
              type: 'RECORD',
              mode: 'REPEATED',
              fields: []
            });
          }
        } else {
          // For primitive arrays
          const baseType = type.substring(6, type.length - 1);
          schema.push({
            name: key,
            type: baseType,
            mode: 'REPEATED'
          });
        }
      } else {
        schema.push({
          name: key,
          type: type,
          mode: 'NULLABLE'
        });
      }
    });
    
    return schema;
  }

  // Recursively merge schemas together
  function mergeSchemas(schemas) {
    if (!schemas || schemas.length === 0) return [];
    
    // Create a map to store the merged fields
    const fieldMap = new Map();
    
    // Process each schema
    schemas.forEach(schema => {
      if (!schema) return;
      
      schema.forEach(field => {
        const existingField = fieldMap.get(field.name);
        
        if (!existingField) {
          // If field doesn't exist yet, add it
          fieldMap.set(field.name, { ...field });
        } else {
          // If field exists, merge properties
          
          // Handle type conflicts (prefer more specific types)
          if (existingField.type !== field.type) {
            // If one is RECORD and the other is not, prefer RECORD
            if (existingField.type === 'RECORD' || field.type === 'RECORD') {
              existingField.type = 'RECORD';
              
              // Merge the fields
              if (field.type === 'RECORD' && field.fields) {
                if (!existingField.fields) existingField.fields = [];
                existingField.fields = mergeSchemas([existingField.fields, field.fields]);
              }
            } else if (existingField.type === 'FLOAT64' || field.type === 'FLOAT64') {
              // If one is FLOAT64, prefer FLOAT64 over INT64
              existingField.type = 'FLOAT64';
            } else {
              // For other conflicts, default to STRING
              existingField.type = 'STRING';
            }
          }
          
          // For RECORD types, recursively merge their fields
          if (existingField.type === 'RECORD' && field.type === 'RECORD') {
            existingField.fields = mergeSchemas([existingField.fields || [], field.fields || []]);
          }
          
          // Handle mode conflicts (NULLABLE > REQUIRED)
          if (existingField.mode === 'REQUIRED' && field.mode === 'NULLABLE') {
            existingField.mode = 'NULLABLE';
          }
          
          // Handle REPEATED mode
          if (existingField.mode === 'REPEATED' || field.mode === 'REPEATED') {
            existingField.mode = 'REPEATED';
          }
        }
      });
    });
    
    // Convert map back to array
    return Array.from(fieldMap.values());
  }
""";
''';

SELECT script;
EXECUTE IMMEDIATE (script);

END FOR

