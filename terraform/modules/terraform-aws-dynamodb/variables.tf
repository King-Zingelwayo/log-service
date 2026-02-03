variable "name" {
  description = "DynamoDB table name"
  type        = string
}

variable "billing_mode" {
  description = "DynamoDB billing mode: PAY_PER_REQUEST (on-demand) or PROVISIONED"
  type        = string
  default     = "PAY_PER_REQUEST"
  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], upper(var.billing_mode))
    error_message = "billing_mode must be either PAY_PER_REQUEST or PROVISIONED"
  }
}

variable "read_capacity" {
  description = "Read capacity units (only used if billing_mode = PROVISIONED)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units (only used if billing_mode = PROVISIONED)"
  type        = number
  default     = 5
}

variable "hash_key" {
  description = "Primary key (partition key) attribute name"
  type        = string
}

variable "hash_key_type" {
  description = "Attribute type for the primary key (S, N, B)"
  type        = string
  default     = "S"
}

variable "range_key" {
  description = "Optional sort key attribute name"
  type        = string
  default     = null
}

variable "range_key_type" {
  description = "Attribute type for the sort key (S, N, B)"
  type        = string
  default     = "S"
}

variable "attributes" {
  description = "Additional attributes for secondary indexes"
  type        = map(string)
  default     = {}
}

variable "global_secondary_indexes" {
  description = "Optional GSI definitions"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = string
    projection_type    = string
    non_key_attributes = optional(list(string))
    read_capacity      = optional(number)
    write_capacity     = optional(number)
  }))
  default = []
}

variable "ttl_attribute" {
  description = "Optional TTL attribute for automatic expiration"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the table"
  type        = map(string)
  default     = {}
}

variable "stream_enabled" {
  description = "Enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "point_in_time_recovery" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = true
}
