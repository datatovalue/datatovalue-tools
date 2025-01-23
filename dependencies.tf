locals {
  input_data = jsondecode(file("terraform/dataform/dataform_compiled.json"))
  models     = [for table in local.input_data.tables : table if table.disabled != true]
  
  dependency_pairs = flatten([
    for table in local.input_data.tables : [
      for dependency in lookup(table, "dependencyTargets", []) : [
        {
          table_id      = "${table.target.database}.${table.target.schema}.${table.target.name}"
          dependency_id = "${dependency.database}.${dependency.schema}.${dependency.name}"
        }
      ]
    ]
  ])


}

output "local_input_data" {
  value = jsonencode(local.dependency_pairs)
}
