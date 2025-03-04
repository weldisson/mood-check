// scripts/initialize-questions.js
const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');

// Configure AWS
AWS.config.update({
  region: 'us-east-1'
});

const dynamoDB = new AWS.DynamoDB.DocumentClient();

// Define the questions
const questions = [
  {
    question_id: uuidv4(),
    text: "How would you rate your overall mood today?",
    type: "multiple_choice",
    order: 1,
    options: ["Excellent", "Good", "Neutral", "Not so good", "Terrible"]
  },
  {
    question_id: uuidv4(),
    text: "How stressed do you feel right now?",
    type: "multiple_choice",
    order: 2,
    options: ["Not at all", "A little", "Moderately", "Very", "Extremely"]
  },
  {
    question_id: uuidv4(),
    text: "Which GIF best represents your mood today?",
    type: "gif_selection",
    order: 3,
    options: ["happy", "sad", "tired", "excited", "confused"]
  },
  {
    question_id: uuidv4(),
    text: "Is there anything specific affecting your mood that you'd like to share?",
    type: "free_text",
    order: 4
  }
];

// Insert the questions
const insertQuestions = async () => {
  for (const question of questions) {
    const params = {
      TableName: "MoodQuestions",
      Item: question
    };

    try {
      await dynamoDB.put(params).promise();
      console.log(`Added question: ${question.text}`);
    } catch (error) {
      console.error(`Error adding question: ${error.message}`);
    }
  }
};

insertQuestions()
  .then(() => console.log('Questions initialization complete!'))
  .catch(err => console.error('Initialization failed:', err));