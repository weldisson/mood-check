resource "aws_dynamodb_table" "mood_questions" {
  name           = "MoodQuestions"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "question_id"

  attribute {
    name = "question_id"
    type = "S"
  }

  tags = {
    Name        = "mood-questions"
    Environment = "production"
  }
}

resource "aws_dynamodb_table" "mood_answers" {
  name           = "MoodAnswers"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "answer_id"
  range_key      = "timestamp"

  attribute {
    name = "answer_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  global_secondary_index {
    name               = "UserAnswersIndex"
    hash_key           = "user_id"
    range_key          = "timestamp"
    projection_type    = "ALL"
  }

  tags = {
    Name        = "mood-answers"
    Environment = "production"
  }
}