import { ConfigService } from '@nestjs/config';
import { TypeOrmModuleOptions } from '@nestjs/typeorm';

export const buildDatabaseConfig = (
  config: ConfigService,
): TypeOrmModuleOptions => {
  const isProduction =
    config.get<string>('NODE_ENV') === 'production' ||
    config.get<string>('DB_SSL') === 'true';

  const dbHost = config.get<string>('DB_HOST');
  const dbUrl = config.get<string>('DATABASE_URL');

  if (dbUrl) {
    return {
      type: 'postgres',
      url: dbUrl,
      entities: [__dirname + '/../**/*.entity{.ts,.js}'],
      migrations: [__dirname + '/../database/migrations/*{.ts,.js}'],
      synchronize: false,
      ssl: isProduction ? ({ rejectUnauthorized: false } as any) : false,
    };
  }

  return {
    type: 'postgres',
    host: dbHost,
    port: config.get<number>('DB_PORT'),
    username: config.get<string>('DB_USERNAME'),
    password: config.get<string>('DB_PASSWORD'),
    database: config.get<string>('DB_NAME'),
    entities: [__dirname + '/../**/*.entity{.ts,.js}'],
    migrations: [__dirname + '/../database/migrations/*{.ts,.js}'],
    synchronize: false,
    ssl: isProduction ? ({ rejectUnauthorized: false } as any) : false,
  };
};
