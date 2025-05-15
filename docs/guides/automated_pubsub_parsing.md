# Implementation Guides
## Automatic PubSub Payload Parsing
The ability to send PubSub messages directly into BigQuery is an immensely powerful and scalable serverless capability. However, building the right process to ingest, segregate, filter and parse the messages for subsequent data transformation is non-trivial. When inserting PubSub messages directly into a BigQuery table through a BigQuery Subscription you have two options:

1. Define the precise expected JSON schema in advance, non-compliant messages will fail, or
2. Accept all messages in JSON form into a single column, no messages will fail.

Notwithstanding the significantly simpler setup process and infrastructure for the second, single JSON column option, this option also results in a considerably more flexible architecture. It can reliably accept messages, even when the message structure is not reliably known in advance.

In order to segregate, filter and parse this potentially unpredictable data into BigQuery data types and structures in a scalable and predictable manner, the `datatovalue-tools` JSON functions have been developed to support operation and automation at scale.

### Basic Example: Single Event Type
In this real-world example, the PubSub messages are contained in the `data` column of the `project_id.sgtm_monitor.sgtm_monitor_logs` date-partitioned table. This initial query builds the merged schema for all observed JSON values where `event_name` = `call_booked`, and assigns it to the `schema` JSON string variable.

```sql
DECLARE single_event_name, schema, deployed_parser_dataset_id, deployment_script STRING;

SET single_event_name = "call_booked";

SET schema = (
  WITH
    sgtm_monitor_logs AS (
      SELECT 
      JSON_VALUE (data, "$.event_name") AS event_name, * 
      FROM `project_id.sgtm_monitor.sgtm_monitor_logs` 
      WHERE DATE(_PARTITIONTIME) >= CURRENT_DATE - 90),

    generate_event_schema AS (
      SELECT 
      `datatovalue-tools`.eu.generate_merged_json_schema(data) AS schema
      FROM sgtm_monitor_logs
      WHERE event_name = single_event_name)

    SELECT schema
    FROM generate_event_schema
  );
```
The subsequent code builds the deployment script, and executes the script in order to deploy the custom parser function to the defined dataset.

```sql
SET deployment_script = (
 SELECT `datatovalue-tools.eu.deploy_json_parser_tvf_query`(
  schema, 
  deployed_parser_dataset_id||'.'||single_event_name,
  source_table_id,
  json_column_name
  )
);

EXECUTE IMMEDIATE (deployment_script);
```

### Complex Example: Multiple Event Types
In this, more complex real-world code example, five different event types with different schemas are being sent to the same PubSub topic. We need to build the mechanism to separate them into different streams for different downstream use cases. This script creates a Table-Valued Function (TVF) for each event name in the `event_names` list, which parses the different observed data structures (over the past 90 days) into BigQuery data types and structures.

```sql
DECLARE source_table_id, json_column_name, parsed_event_name, deployed_parser_id, schema, deployment_script STRING;
DECLARE event_names ARRAY<STRING>;

SET event_names = ["generate_lead", "call_booked", "generate_lead_gads_request", "staffing_request.created", "organization.created"];
SET deployed_parser_dataset_id = "project_id.sgtm_monitor";
SET source_table_id = "project_id.sgtm_monitor.sgtm_monitor_logs";
SET json_column_name = "data";

FOR event IN (SELECT value FROM UNNEST(event_names) AS value)
DO
  SET schema = (
    WITH
    sgtm_monitor_logs AS (
      SELECT 
      JSON_VALUE (data, "$.event_name") AS event_name, * 
      FROM `project_id.sgtm_monitor.sgtm_monitor_logs` 
      WHERE DATE(_PARTITIONTIME) >= CURRENT_DATE - 90),

    generate_event_schema AS (
      SELECT 
      `datatovalue-tools`.eu.generate_merged_json_schema(data) AS schema
      FROM sgtm_monitor_logs
      WHERE event_name = event.value)

    SELECT schema
    FROM generate_event_schema);

  SET deployment_script = (
   SELECT `datatovalue-tools.eu.deploy_json_parser_tvf_query`(
    schema, 
    deployed_parser_dataset_id||'.'||event.value,
    source_table_id,
    json_column_name
    )
  );

  EXECUTE IMMEDIATE (deployment_script);

END FOR;
```
