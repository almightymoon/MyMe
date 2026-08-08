import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';
import { ErrorCodes } from '../errors/error-codes';

type ErrorBody = {
  statusCode: number;
  code: string;
  message: string;
  details: Record<string, unknown>;
  timestamp: string;
  path: string;
};

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    const isProd = process.env.NODE_ENV === 'production';
    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let code: string = ErrorCodes.INTERNAL;
    let message = 'An unexpected error occurred';
    let details: Record<string, unknown> = {};

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const payload = exception.getResponse();
      if (typeof payload === 'string') {
        message = payload;
      } else if (typeof payload === 'object' && payload !== null) {
        const obj = payload as Record<string, unknown>;
        message = String(obj.message ?? exception.message);
        code = String(obj.code ?? this.codeForStatus(status));
        if (Array.isArray(obj.message)) {
          message = 'Validation failed';
          details = { messages: obj.message };
          code = ErrorCodes.VALIDATION_ERROR;
        } else if (obj.details && typeof obj.details === 'object') {
          details = obj.details as Record<string, unknown>;
        }
        if (obj.error && !obj.code) {
          // Nest default validation shape
          code = ErrorCodes.VALIDATION_ERROR;
        }
      }
    } else if (exception instanceof Error) {
      message = isProd ? 'An unexpected error occurred' : exception.message;
      this.logger.error(exception.message, exception.stack);
    } else {
      this.logger.error(`Unknown exception: ${String(exception)}`);
    }

    if (!(exception instanceof Error) || exception instanceof HttpException) {
      if (status >= 500) {
        this.logger.error(
          `${request.method} ${request.url} -> ${status}`,
          exception instanceof Error ? exception.stack : undefined,
        );
      }
    }

    const body: ErrorBody = {
      statusCode: status,
      code,
      message: Array.isArray(message) ? message.join(', ') : message,
      details,
      timestamp: new Date().toISOString(),
      path: request.url,
    };

    response.status(status).json(body);
  }

  private codeForStatus(status: number): string {
    if (status === 401) return ErrorCodes.UNAUTHORIZED;
    if (status === 403) return ErrorCodes.FORBIDDEN;
    if (status === 404) return ErrorCodes.NOT_FOUND;
    if (status === 409) return ErrorCodes.CONFLICT;
    if (status === 400) return ErrorCodes.VALIDATION_ERROR;
    return ErrorCodes.INTERNAL;
  }
}
