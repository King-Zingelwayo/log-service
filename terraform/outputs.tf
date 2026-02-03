output "ingest_url" {
  description = "The URL to send logs to"
  value       = module.ingest_lambda.function_url
}

output "read_recent_url" {
  description = "The URL to retrieve the 100 most recent logs"
  value       = module.read_lambda.function_url
}