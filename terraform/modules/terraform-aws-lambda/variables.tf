variable "function_name" {
  description = "Lambda function name"
  type        = string
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}

variable "handler" {
  description = "Lambda handler"
  type        = string
}


variable "timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 10
}

variable "memory_size" {
  description = "Lambda memory size (MB)"
  type        = number
  default     = 128
}

variable "environment_variables" {
  description = "Environment variables"
  type        = map(string)
  default     = {}
}


variable "architectures" {
  type    = list(string)
  default = ["x86_64"]
}

variable "vpc_config" {
  description = "[optional] vpc config"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

variable "custom_policies" {
  description = "Custom Iam policies to create and attach to lamnda role"
  type = list(object({
    name = string
    statements = list(object({
      effect    = optional(string, "Allow")
      actions   = list(string)
      resources = list(string)
      condition = optional(map(map(list(string))), {})
    }))
  }))

  default = []
}

variable "additional_managed_policy_arns" {
  description = "AWS-managed policies"
  type        = list(string)
  default     = []
}

variable "deployment_package" {
  type = object({
    bucket  = string
    key     = string
    version = optional(string, null)
  })
}
variable "function_url_config" {
  description = "Configuration for the Lambda Function URL"
  type = object({
    enabled   = bool
    auth_type = string
  })
  default = {
    enabled   = false
    auth_type = "NONE"
  }

  validation {
    condition     = contains(["NONE", "AWS_IAM"], var.function_url_config.auth_type)
    error_message = "The auth_type must be either 'NONE' or 'AWS_IAM'."
  }
}

# 🔹 Observability toggles (OFF by default)

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch Logs"
  type        = bool
  default     = false
}

variable "enable_xray_tracing" {
  description = "Enable AWS X-Ray tracing"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
