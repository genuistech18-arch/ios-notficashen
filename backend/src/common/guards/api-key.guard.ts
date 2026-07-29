import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Request } from 'express';

@Injectable()
export class ApiKeyGuard implements CanActivate {
  constructor(private readonly config: ConfigService) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<Request>();
    
    // Retrieve key from headers (various casings) or query parameters
    const providedKey = (
      request.headers['x-api-key'] ||
      request.headers['X-Api-Key'] ||
      request.headers['X-API-KEY'] ||
      request.headers['x-api-token'] ||
      request.query['x-api-key'] ||
      request.query['apiKey']
    ) as string | undefined;

    const expectedKey = this.config.get<string>('API_SEND_KEY');

    if (!expectedKey) {
      throw new UnauthorizedException(
        'API_SEND_KEY configuration is missing on the server',
      );
    }

    if (!providedKey || providedKey.trim() !== expectedKey.trim()) {
      throw new UnauthorizedException('Invalid or missing API key');
    }

    return true;
  }
}
