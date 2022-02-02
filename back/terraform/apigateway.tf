resource "aws_api_gateway_rest_api" "dictionaryAPI" {
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "dictionary api"
      version = "1.0"
    }
  })

  name = "dictionaryAPI"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "api" {
  path_part   = "api"
  parent_id   = aws_api_gateway_rest_api.dictionaryAPI.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.dictionaryAPI.id
}

resource "aws_api_gateway_method" "getRandom" {
  rest_api_id   = aws_api_gateway_rest_api.dictionaryAPI.id
  resource_id   = aws_api_gateway_resource.api.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  depends_on              = [aws_api_gateway_method.getRandom]
  rest_api_id             = aws_api_gateway_rest_api.dictionaryAPI.id
  resource_id             = aws_api_gateway_resource.api.id
  http_method             = aws_api_gateway_method.getRandom.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.getRandom.invoke_arn
}

resource "aws_lambda_permission" "api_trigger" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.getRandom.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.dictionaryAPI.execution_arn}/*/*"
}

resource "aws_api_gateway_resource" "word" {
  path_part   = "{word}"
  parent_id   = aws_api_gateway_rest_api.dictionaryAPI.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.dictionaryAPI.id
}

resource "aws_api_gateway_resource" "pos" {
  path_part   = "{pos}"
  parent_id   = aws_api_gateway_resource.word.id
  rest_api_id = aws_api_gateway_rest_api.dictionaryAPI.id
}

resource "aws_api_gateway_deployment" "dictionaryAPI" {
  depends_on  = [aws_api_gateway_integration.integration]
  rest_api_id = aws_api_gateway_rest_api.dictionaryAPI.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.dictionaryAPI.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dictionaryAPI" {
  deployment_id = aws_api_gateway_deployment.dictionaryAPI.id
  rest_api_id   = aws_api_gateway_rest_api.dictionaryAPI.id
  stage_name    = "api"
}
