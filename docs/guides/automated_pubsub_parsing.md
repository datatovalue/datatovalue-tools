# Advanced Guide
## Automatic PubSub Payload Parsing

In this real-world code example, five different event types of interest in are being sent to the same PubSub topic. We need to build the mechanism to separate them into different 'streams' for different downstream use cases. This creates a User-Defined Function (UDF) for each `event.value` in the `event_names` list, which parses the different observed data structures (over the past 90 days) into BigQuery columns.

```sql
DECLARE schema, deployed_parser_dataset_id, deployment_script STRING;
DECLARE event_names ARRAY<STRING>;

SET event_names = ["call_booked", "form_complete", "purchase", "account_created"];
SET deployed_parser_dataset_id = "project_id.sgtm_monitor";

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
    SELECT `datatovalue-tools.europe_north1.deploy_json_parser_query`(
      schema, 
      deployed_parser_dataset_id||".parse_"||REPLACE(event.value, ".", "_")
      ));

  EXECUTE IMMEDIATE (deployment_script);

END FOR;
```

These dan then be called as part of downstream modelling or built into resources such as table-valued functions.
