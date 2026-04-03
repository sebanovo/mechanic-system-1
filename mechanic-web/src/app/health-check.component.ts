import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';

import {
  DatabaseHealthResponse,
  HealthService,
} from './core/services/health.service';

@Component({
  selector: 'app-health-check',
  standalone: true,
  imports: [CommonModule],
  template: `
    <section style="padding: 24px;">
      <h2>Database connection test</h2>

      <button type="button" (click)="handleCheckDatabase()" [disabled]="loading()">
        {{ loading() ? 'Checking...' : 'Check database connection' }}
      </button>

      @if (response()) {
        <div style="margin-top: 16px;">
          <p><strong>Status:</strong> {{ response()?.status }}</p>
          <p><strong>Database:</strong> {{ response()?.database }}</p>
          <p><strong>Result:</strong> {{ response()?.result }}</p>
        </div>
      }

      @if (error()) {
        <div style="margin-top: 16px;">
          <p><strong>Error:</strong> {{ error() }}</p>
        </div>
      }
    </section>
  `,
})
export class HealthCheckComponent {
  private readonly healthService = inject(HealthService);

  readonly loading = signal(false);
  readonly response = signal<DatabaseHealthResponse | null>(null);
  readonly error = signal<string | null>(null);

  handleCheckDatabase(): void {
    this.loading.set(true);
    this.response.set(null);
    this.error.set(null);

    this.healthService.checkDatabase().subscribe({
      next: (result) => {
        this.response.set(result);
        this.loading.set(false);
      },
      error: (err) => {
        this.error.set(err?.message ?? 'Request failed.');
        this.loading.set(false);
      },
    });
  }
}