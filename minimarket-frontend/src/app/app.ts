import { Component, signal, inject, OnInit } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  templateUrl: './app.html',
  styleUrl: './app.scss'
})
export class App implements OnInit {
  protected readonly title = signal('minimarket-frontend');
  private http = inject(HttpClient);
  
  isLogged = signal(false);

  ngOnInit() {
    const token = localStorage.getItem('token');
    if (!token) {
      this.http.post<any>('http://localhost:8080/api/auth/login', {
        username: 'admin',
        password: 'Admin123!'
      }).subscribe({
        next: (res) => {
          if (res.success && res.data && res.data.token) {
            localStorage.setItem('token', res.data.token);
            console.log('Auto-login exitoso');
            this.isLogged.set(true);
          }
        },
        error: (err) => {
          console.error('Auto-login falló', err);
          // Permitir renderizar de todos modos para ver el error
          this.isLogged.set(true); 
        }
      });
    } else {
      this.isLogged.set(true);
    }
  }
}
