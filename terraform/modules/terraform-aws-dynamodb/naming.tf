locals {
  
  all_attributes = merge(
    { (var.hash_key) = var.hash_key_type },
    var.range_key != null ? { (var.range_key) = var.range_key_type } : {},
    var.attributes
  )
}