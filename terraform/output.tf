output "api_endpoint" {
  value = "${aws_apigatewayv2_api.mood_check_api.api_endpoint}/${aws_apigatewayv2_stage.api_stage.name}"
}

output "questions_table_name" {
  value = aws_dynamodb_table.mood_questions.name
}

output "answers_table_name" {
  value = aws_dynamodb_table.mood_answers.name
}