resource "aws_apigatewayv2_api" "mood_check_api" {
  name          = "mood-check-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
  }
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.mood_check_api.id
  name        = "v1"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "search_questions_integration" {
  api_id             = aws_apigatewayv2_api.mood_check_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.search_questions_lambda.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_integration" "save_answers_integration" {
  api_id             = aws_apigatewayv2_api.mood_check_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.save_answers_lambda.invoke_arn
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "search_questions_route" {
  api_id    = aws_apigatewayv2_api.mood_check_api.id
  route_key = "GET /questions"
  target    = "integrations/${aws_apigatewayv2_integration.search_questions_integration.id}"
}

resource "aws_apigatewayv2_route" "save_answers_route" {
  api_id    = aws_apigatewayv2_api.mood_check_api.id
  route_key = "POST /answers"
  target    = "integrations/${aws_apigatewayv2_integration.save_answers_integration.id}"
}

resource "aws_lambda_permission" "search_questions_api_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.search_questions_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.mood_check_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "save_answers_api_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.save_answers_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.mood_check_api.execution_arn}/*/*"
}

