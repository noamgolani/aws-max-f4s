data "archive_file" "get_by_word_and_pos_zip" {
  type             = "zip"
  source_file      = "${path.module}/../lambdas/getByWordAndPOS.js"
  output_file_mode = "0666"
  output_path      = "${path.module}/getByWordAndPOS.js.zip"
}

resource "aws_lambda_function" "getByWordAndPOS" {
  depends_on = [
    aws_iam_role.iam_for_lambda,
    data.archive_file.get_by_word_zip
  ]
  filename      = "getByWordAndPOS.js.zip"
  function_name = "getByWordAndPOS"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "getByWordAndPOs.handler"

  source_code_hash = filebase64sha256("getByWordAndPOs.js.zip")

  runtime = "nodejs14.x"

  environment {
    variables = {
      table_name = "dictionary"
    }
  }
}
