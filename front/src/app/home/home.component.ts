// home.component.ts
import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { FormBuilder, FormGroup, Validators, ReactiveFormsModule } from '@angular/forms';
import { MatSnackBar } from '@angular/material/snack-bar';
import { CommonModule } from '@angular/common';

// Material Imports
import { MatCardModule } from '@angular/material/card';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MoodService } from '../mood.service';

interface GifOption {
  text: string;
  gifs: string[];
}

interface Question {
  question_id: string;
  text: string;
  type: string;
  order: number;
  options?: (string[] | GifOption[]);
}

interface Answer {
  question_id: string;
  answer: string;
}

@Component({
  selector: 'app-home',
  templateUrl: './home.component.html',
  styleUrls: ['./home.component.scss'],
  standalone: true,
  imports: [
    CommonModule, 
    ReactiveFormsModule,
    MatCardModule,
    MatButtonModule,
    MatIconModule,
    MatInputModule,
    MatSelectModule,
    MatProgressSpinnerModule,
    MatFormFieldModule
  ]
})
export class HomeComponent implements OnInit {
  questions: Question[] = [];
  form: FormGroup;
  loading = false;
  submitted = false;
  formStarted = false;
  
  selectedGifIndices: { [questionId: string]: { optionIndex: number, gifIndex: number } } = {};

  constructor(
    private http: HttpClient,
    private fb: FormBuilder,
    private snackBar: MatSnackBar,
    private moodService: MoodService 
  ) {
    this.form = this.fb.group({});
  }

  ngOnInit(): void {
  }

  isMultipleChoice(question: Question): boolean {
    return question.type === 'multiple_choice' && 
           question.options !== undefined && 
           typeof question.options[0] === 'string';
  }

  isGifSelection(question: Question): boolean {
    return question.type === 'gif_selection' && 
           question.options !== undefined && 
           typeof question.options[0] !== 'string';
  }

  getStringOptions(question: Question): string[] {
    if (question.options && typeof question.options[0] === 'string') {
      return question.options as string[];
    }
    return [];
  }

  getGifOptions(question: Question): GifOption[] {
    if (question.options && typeof question.options[0] !== 'string') {
      return question.options as GifOption[];
    }
    return [];
  }

  fetchQuestions(): void {
    this.loading = true;
    this.formStarted = true;
    
    this.moodService.getQuestions().subscribe({
      next: (data) => {
        this.questions = data.sort((a, b) => a.order - b.order);
        
        const formControls: any = {};
        
        this.questions.forEach(question => {
          formControls[question.question_id] = ['', Validators.required];
        });
        
        this.form = this.fb.group(formControls);
        this.loading = false;
      },
      error: (error) => {
        console.error('Erro ao buscar perguntas:', error);
        this.snackBar.open('Erro ao carregar as perguntas. Tente novamente mais tarde.', 'Fechar', {
          duration: 5000,
          panelClass: ['error-snackbar']
        });
        this.loading = false;
      }
    });
  }

  selectGif(questionId: string, optionIndex: number, gifIndex: number): void {
    const question = this.questions.find(q => q.question_id === questionId);
    if (question && this.isGifSelection(question)) {
      const options = this.getGifOptions(question);
      const optionText = options[optionIndex].text;
      
      this.selectedGifIndices[questionId] = { optionIndex, gifIndex };
      
      this.form.get(questionId)?.setValue(optionText);
    }
  }

  isGifSelected(questionId: string, optionIndex: number, gifIndex: number): boolean {
    return this.selectedGifIndices[questionId]?.optionIndex === optionIndex && 
           this.selectedGifIndices[questionId]?.gifIndex === gifIndex;
  }

  submitForm(): void {
    if (this.form.invalid) {
      // Marcar todos os campos como touched para mostrar os erros
      Object.keys(this.form.controls).forEach(key => {
        this.form.get(key)?.markAsTouched();
      });
      
      this.snackBar.open('Por favor, responda todas as perguntas.', 'Fechar', {
        duration: 3000
      });
      return;
    }
  
    this.loading = true;
    
    const formValues = this.form.value;
    const answers: Answer[] = Object.keys(formValues).map(questionId => ({
      question_id: questionId,
      answer: formValues[questionId]
    }));
  
    this.moodService.saveAnswers({ answers }).subscribe({
      next: () => {
        this.loading = false;
        this.submitted = true;
        this.snackBar.open('Obrigado por compartilhar seu humor hoje!', 'Fechar', {
          duration: 5000
        });
      },
      error: (error) => {
        console.error('Erro ao enviar respostas:', error);
        this.loading = false;
        this.snackBar.open('Erro ao enviar suas respostas. Tente novamente.', 'Fechar', {
          duration: 5000,
          panelClass: ['error-snackbar']
        });
      }
    });
  }

  resetForm(): void {
    this.formStarted = false;
    this.submitted = false;
    this.form = this.fb.group({});
    this.questions = [];
    this.selectedGifIndices = {};
  }
}