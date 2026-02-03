# Build Lambda Functions
resource "null_resource" "build_ingest_lambda" {
  triggers = {
    # Rebuild when any Go file changes
    go_files = sha256(join("", [
      for f in fileset("${path.module}/../cmd/ingest", "**/*.go") :
      filesha256("${path.module}/../cmd/ingest/${f}")
    ]))
    model_files = sha256(join("", [
      for f in fileset("${path.module}/../internal/models", "**/*.go") :
      filesha256("${path.module}/../internal/models/${f}")
    ]))
    go_mod = filesha256("${path.module}/../go.mod")

  }

  provisioner "local-exec" {
    command = <<-EOT
        cd ${path.module}/..
        make
        aws s3 cp cmd/artifacts/ingest.zip s3://${aws_s3_bucket.artifacts.id}/ingest.zip
    EOT
  }
}

resource "null_resource" "build_read_recent_lambda" {
  triggers = {
    # Rebuild when any Go file changes
    go_files = sha256(join("", [
      for f in fileset("${path.module}/../cmd/read-recent", "**/*.go") :
      filesha256("${path.module}/../cmd/read-recent/${f}")
    ]))
    model_files = sha256(join("", [
      for f in fileset("${path.module}/../internal/models", "**/*.go") :
      filesha256("${path.module}/../internal/models/${f}")
    ]))
    go_mod = filesha256("${path.module}/../go.mod")
  }

  provisioner "local-exec" {
    command = <<-EOT
      cd ${path.module}/..
      make
      aws s3 cp cmd/artifacts/read-recent.zip s3://${aws_s3_bucket.artifacts.id}/read-recent.zip
    EOT
  }
}