data "archive_file" "get_random_zip" {
  type             = "zip"
  source_file      = "${path.module}/../lambdas/getRandom.js"
  output_file_mode = "0666"
  output_path      = "${path.module}/getRandom.js.zip"
}

resource "aws_lambda_function" "getRandom" {
  depends_on = [
    aws_iam_role.iam_for_lambda,
    data.archive_file.get_random_zip
  ]
  filename      = "getRandom.js.zip"
  function_name = "getRandom"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "getRandom.handler"

  source_code_hash = filebase64sha256("getRandom.js.zip")

  runtime = "nodejs14.x"

  environment {
    variables = {
      table_name = "dictionary"
    }
  }
}
