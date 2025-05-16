# Monitor Functions
Functions which model and integrate metadata to provide useful insight on BigQuery resources.

### monitor_tables
The `monitor_tables` function models table metadata into a structure which supports monitoring of table freshness across multiple datasets. It takes an optional `config` JSON array to set specific threshold values for expected freshness at a table level.

Argument | Data Type | Description
--- | --- | ---
**`config`** | **`JSON`** | Array of JSON objects defining table-level thresholds. The schema is outlined below.

#### Configuration
The `config` JSON argument has the following structure:

Path | Data Type | Description
--- | --- | ---
**`table_id`** | **`string`** | Table ID of any table to attach a specific alert threshold.
**`alert_threshold_hrs`** | **`float`** | The alert threshold in hours.

```javascript
  [
    {"table_id": "project_id.dataset_name.table_name", "alert_threshold_hrs": 2.5 },
    {}... 
  ]
```




