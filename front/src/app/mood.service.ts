// mood.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface GifOption {
  text: string;
  gifs: string[];
}

export interface Question {
  question_id: string;
  text: string;
  type: string;
  order: number;
  options?: string[] | GifOption[];
}

export interface Answer {
  question_id: string;
  answer: string;
}

export interface AnswersRequest {
  answers: Answer[];
}

@Injectable({
  providedIn: 'root'
})
export class MoodService {
  private apiUrl = 'https://zzxezf540i.execute-api.us-east-1.amazonaws.com/v1';

  constructor(private http: HttpClient) { }

  getQuestions(): Observable<Question[]> {
    return this.http.get<Question[]>(`${this.apiUrl}/questions`);
  }

  saveAnswers(answers: AnswersRequest): Observable<any> {
    return this.http.post(`${this.apiUrl}/answers`, answers);
  }
}