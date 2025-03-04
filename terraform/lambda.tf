resource "null_resource" "install_dependencies_search_questions" {
  provisioner "local-exec" {
    command = "pip install -r ${path.module}/../lambdas/search-questions/requirements.txt -t ${path.module}/../lambdas/search-questions/"
  }

  triggers = {
    requirements_md5 = filemd5("${path.module}/../lambdas/search-questions/requirements.txt")
  }
}

resource "null_resource" "install_dependencies_save_answers" {
  provisioner "local-exec" {
    command = "pip install -r ${path.module}/../lambdas/save-answers/requirements.txt -t ${path.module}/../lambdas/save-answers/"
  }

  triggers = {
    requirements_md5 = filemd5("${path.module}/../lambdas/save-answers/requirements.txt")
  }
}

data "archive_file" "search_questions_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/search-questions"
  output_path = "${path.module}/search_questions_lambda.zip"
  
  depends_on = [null_resource.install_dependencies_search_questions]
}

data "archive_file" "save_answers_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/save-answers"
  output_path = "${path.module}/save_answers_lambda.zip"
  
  depends_on = [null_resource.install_dependencies_save_answers]
}

resource "aws_lambda_function" "search_questions_lambda" {
  function_name    = "search-questions"
  filename         = data.archive_file.search_questions_lambda_zip.output_path
  source_code_hash = data.archive_file.search_questions_lambda_zip.output_base64sha256
  handler          = "app.lambda_handler"
  runtime          = "python3.9"
  role             = aws_iam_role.lambda_role.arn
  timeout          = 10
  memory_size      = 256

  environment {
    variables = {
      QUESTIONS_TABLE = aws_dynamodb_table.mood_questions.name
      GIPHY_API_KEY   = var.giphy_api_key
    }
  }
}

resource "aws_lambda_function" "save_answers_lambda" {
  function_name    = "save-answers"
  filename         = data.archive_file.save_answers_lambda_zip.output_path
  source_code_hash = data.archive_file.save_answers_lambda_zip.output_base64sha256
  handler          = "app.lambda_handler"
  runtime          = "python3.9"
  role             = aws_iam_role.lambda_role.arn
  timeout          = 10
  memory_size      = 256

  environment {
    variables = {
      ANSWERS_TABLE = aws_dynamodb_table.mood_answers.name
    }
  }
}