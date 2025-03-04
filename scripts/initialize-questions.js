const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');

AWS.config.update({
  region: 'us-east-1'
});

const dynamoDB = new AWS.DynamoDB.DocumentClient();

const questions = [
  {
    question_id: uuidv4(),
    text: "Como você classificaria seu humor hoje?",
    type: "multiple_choice",
    order: 1,
    options: ["Excelente", "Bom", "Neutro", "Não muito bom", "Terrível"]
  },
  {
    question_id: uuidv4(),
    text: "Quão estressado você está se sentindo agora?",
    type: "multiple_choice",
    order: 2,
    options: ["Nada", "Um pouco", "Moderadamente", "Muito", "Extremamente"]
  },
  {
    question_id: uuidv4(),
    text: "Qual GIF melhor representa seu humor hoje?",
    type: "gif_selection",
    order: 3,
    options: ["feliz", "triste", "cansado", "animado", "confuso"]
  },
  {
    question_id: uuidv4(),
    text: "Há algo específico afetando seu humor que você gostaria de compartilhar?",
    type: "free_text",
    order: 4
  }
];

const insertQuestions = async () => {
  console.log('Iniciando inserção de perguntas...');
  
  for (const question of questions) {
    const params = {
      TableName: "MoodQuestions",
      Item: question
    };

    try {
      await dynamoDB.put(params).promise();
      console.log(`Pergunta adicionada: ${question.text}`);
    } catch (error) {
      console.error(`Erro ao adicionar pergunta: ${error.message}`);
    }
  }
};

insertQuestions()
  .then(() => console.log('Inicialização de perguntas concluída!'))
  .catch(err => console.error('Inicialização falhou:', err));