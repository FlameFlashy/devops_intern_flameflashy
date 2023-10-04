import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';

interface IHealthCheck {
  status: number;
  date: Date;
  message: string;
}

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss'],
})
export class AppComponent implements OnInit {
  healthCheckResult!: IHealthCheck;

  constructor(private readonly _http: HttpClient) {}

  ngOnInit(): void {
    this._http
      .get<IHealthCheck>(`http://${window.location.host}/api/health`)
      .subscribe((r) => (this.healthCheckResult = r));
  }
}
