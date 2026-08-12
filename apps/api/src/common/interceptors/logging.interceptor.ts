import {
  CallHandler,
  ExecutionContext,
  Injectable,
  Logger,
  NestInterceptor,
} from '@nestjs/common';
import { Observable, tap } from 'rxjs';
import { Request } from 'express';

function sanitizeRequestUrl(url: string): string {
  const queryIndex = url.indexOf('?');
  if (queryIndex === -1) return url;
  const path = url.slice(0, queryIndex);
  const query = url.slice(queryIndex + 1);
  const redacted = query
    .split('&')
    .map((part) => {
      const key = part.split('=')[0]?.toLowerCase() ?? '';
      if (
        key.includes('token') ||
        key.includes('secret') ||
        key.includes('password') ||
        key === 'code'
      ) {
        return `${part.split('=')[0]}=[redacted]`;
      }
      return part;
    })
    .join('&');
  return `${path}?${redacted}`;
}

@Injectable()
export class RequestLoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const http = context.switchToHttp();
    const request = http.getRequest<Request>();
    const { method } = request;
    const url = sanitizeRequestUrl(request.url);
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
