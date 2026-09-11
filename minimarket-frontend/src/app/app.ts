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
    // Ya no auto-iniciamos sesión, de eso se encarga la vista Login.
    // Simplemente marcamos la app como "lista" para renderizar las rutas.
    this.isLogged.set(true);
  }
}
