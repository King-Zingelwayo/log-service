data "aws_iam_policy_document" "this" {
  for_each = {
    for policy in var.custom_policies :
    policy.name => policy
  }

  dynamic "statement" {
    for_each = each.value.statements
    content {
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
      # Flattening the map(map(string)) into a list for the dynamic block
      dynamic "condition" {
        for_each = statement.value.condition != null ? flatten([
          for test, condition_map in statement.value.condition : [
            for variable, values in condition_map : {
              test     = test
              variable = variable
              # Ensure values is always a list even if a single string is passed
              values = flatten([values])
            }
          ]
        ]) : []

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}
