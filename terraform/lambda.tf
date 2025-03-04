resource "null_resource" "create_dependencies_layer" {
  provisioner "local-exec" {
    command = <<EOT
      mkdir -p ${path.module}/lambda-layer/python
      pip3 install boto3==1.26.0 requests==2.28.1 -t ${path.module}/lambda-layer/python
      cd ${path.module}/lambda-layer
      zip -r ../lambda-dependencies.zip python
    EOT
  }

  triggers = {
    requirements_hash = "${filemd5("${path.module}/../lambdas/search-questions/requirements.txt")}-${filemd5("${path.module}/../lambdas/save-answers/requirements.txt")}"
  }
}

resource "aws_lambda_layer_version" "dependencies_layer" {
  layer_name = "mood-check-dependencies"
  
  filename   = "${path.module}/lambda-dependencies.zip"
  source_code_hash = fileexists("${path.module}/lambda-dependencies.zip") ? filebase64sha256("${path.module}/lambda-dependencies.zip") : null
  
  compatible_runtimes = ["python3.9"]
  
  depends_on = [null_resource.create_dependencies_layer]
}

data "archive_file" "search_questions_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/search-questions"
  output_path = "${path.module}/search_questions_lambda.zip"
  
  excludes    = [
    "boto3*", 
    "botocore*", 
    "requests*", 
    "urllib3*", 
    "idna*", 
    "certifi*", 
    "charset_normalizer*",
    "python-dateutil*",
    "six*",
    "jmespath*",
    "s3transfer*",
    "__pycache__",
    "*.pyc"
  ]
}

data "archive_file" "save_answers_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambdas/save-answers"
  output_path = "${path.module}/save_answers_lambda.zip"
  
  excludes    = [
    "boto3*", 
    "botocore*",
    "__pycache__",
    "*.pyc"
  ]
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
  
  layers = [aws_lambda_layer_version.dependencies_layer.arn]

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
  
  layers = [aws_lambda_layer_version.dependencies_layer.arn]

  environment {
    variables = {
      ANSWERS_TABLE = aws_dynamodb_table.mood_answers.name
    }
  }
}