import {
  CallHandler,
  ExecutionContext,
  Injectable,
  Logger,
  NestInterceptor,
} from '@nestjs/common';
import { Observable, tap } from 'rxjs';
import { Request } from 'express';

@Injectable()
export class RequestLoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const http = context.switchToHttp();
    const request = http.getRequest<Request>();
    const { method, url } = request;
    const started = Date.now();

    return next.handle().pipe(
      tap({
        next: () => {
          const response = http.getResponse<{ statusCode: number }>();
          this.logger.log(
            `${method} ${url} ${response.statusCode} ${Date.now() - started}ms`,
          );
        },
        error: (error: Error) => {
          this.logger.warn(
            `${method} ${url} failed after ${Date.now() - started}ms: ${error.message}`,
          );
        },
      }),
    );
  }
}
