data "archive_file" "get_by_word_zip" {
  type             = "zip"
  source_file      = "${path.module}/../lambdas/getByWord.js"
  output_file_mode = "0666"
  output_path      = "${path.module}/getByWord.js.zip"
}

resource "aws_lambda_function" "getByWord" {
  depends_on = [
    aws_iam_role.iam_for_lambda,
    data.archive_file.get_by_word_zip
  ]
  filename      = "getByWord.js.zip"
  function_name = "getByWord"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "getByWord.handler"

  source_code_hash = filebase64sha256("getByWord.js.zip")

  runtime = "nodejs14.x"

  environment {
    variables = {
      table_name = "dictionary"
    }
  }
}
