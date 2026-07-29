import { Global, Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { cert, initializeApp, type App } from 'firebase-admin/app';
import * as path from 'path';
import * as fs from 'fs';

export const FIREBASE_ADMIN = 'FIREBASE_ADMIN';

@Global()
@Module({
  imports: [ConfigModule],
  providers: [
    {
      provide: FIREBASE_ADMIN,
      inject: [ConfigService],
      useFactory: (config: ConfigService): App | null => {
        // 1. Check if raw JSON string is provided in env var
        const rawJson = config.get<string>('FIREBASE_SERVICE_ACCOUNT_JSON');
        if (rawJson) {
          try {
            const serviceAccount = JSON.parse(rawJson);
            return initializeApp({
              credential: cert(serviceAccount),
            });
          } catch (e) {
            console.error('Failed to parse FIREBASE_SERVICE_ACCOUNT_JSON', e);
          }
        }

        // 2. Check path
        const relativePath =
          config.get<string>('FIREBASE_SERVICE_ACCOUNT_PATH') ??
          './firebase-service-account.json';

        const possiblePaths = [
          path.isAbsolute(relativePath)
            ? relativePath
            : path.join(process.cwd(), relativePath),
          path.join(process.cwd(), '../firebase-service-account.json'),
          path.join(__dirname, '../../../firebase-service-account.json'),
          path.join(__dirname, '../../../../firebase-service-account.json'),
        ];

        for (const filePath of possiblePaths) {
          if (fs.existsSync(filePath)) {
            try {
              const serviceAccount = JSON.parse(
                fs.readFileSync(filePath, 'utf-8'),
              );
              return initializeApp({
                credential: cert(serviceAccount),
              });
            } catch (e) {
              console.error(
                `Failed to load Firebase credentials from ${filePath}`,
                e,
              );
            }
          }
        }

        return null;
      },
    },
  ],
  exports: [FIREBASE_ADMIN],
})
export class FirebaseModule {}
