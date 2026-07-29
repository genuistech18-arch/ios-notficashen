import 'dotenv/config';
import { DataSource } from 'typeorm';

const isProduction =
  process.env.NODE_ENV === 'production' || process.env.DB_SSL === 'true';

const dbHost = process.env.DB_HOST;

export const AppDataSource = new DataSource(
  process.env.DATABASE_URL
    ? {
        type: 'postgres',
        url: process.env.DATABASE_URL,
        entities: [__dirname + '/../**/*.entity{.ts,.js}'],
        migrations: [__dirname + '/migrations/*{.ts,.js}'],
        synchronize: false,
        ssl: isProduction ? ({ rejectUnauthorized: false } as any) : false,
      }
    : {
        type: 'postgres',
        host: dbHost,
        port: Number(process.env.DB_PORT ?? 5432),
        username: process.env.DB_USERNAME,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
        entities: [__dirname + '/../**/*.entity{.ts,.js}'],
        migrations: [__dirname + '/migrations/*{.ts,.js}'],
        synchronize: false,
        ssl: isProduction ? ({ rejectUnauthorized: false } as any) : false,
      },
);
