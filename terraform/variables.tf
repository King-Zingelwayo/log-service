variable "region" {
  type        = string
  description = "AWS Region for the environment"
  default     = "eu-west-1"
}

variable "application" {
  type        = string
  description = "Name of application deployed"
  default     = ""
}

variable "environment" {
  type        = string
  description = "the deployment environment"
  default     = "dev"
}

variable "database_config" {
  description = "Unified configuration for the DynamoDB table"
  type = object({
    name                   = string
    billing_mode           = optional(string, "PAY_PER_REQUEST")
    hash_key               = string
    hash_key_type          = optional(string, "S")
    range_key              = optional(string)
    range_key_type         = optional(string, "S")
    ttl_attribute          = optional(string)
    point_in_time_recovery = optional(bool, false)
    stream_enabled         = optional(bool, false)
    attributes             = optional(map(string), {})
    global_secondary_indexes = optional(list(object({
      name            = string
      hash_key        = string
      range_key       = optional(string)
      projection_type = string
      read_capacity   = optional(number)
      write_capacity  = optional(number)
    })), [])
  })
}

variable "lambda_config" {
  description = "Configuration map for the log service lambdas"
  type = map(object({
    handler       = string
    runtime       = optional(string, "nodejs18.x")
    architectures = optional(list(string), ["x86_64"])
    memory_size   = optional(number, 128)
    timeout       = optional(number, 5)
    s3_key        = string

    function_url_config = optional(object({
      enabled   = optional(bool, false)
      auth_type = optional(string, "NONE")
    }))
  }))
}

variable "tags" {
  type        = map(any)
  description = "Resources tags"
  default     = {}
}
