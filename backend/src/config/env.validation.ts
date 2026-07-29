import * as Joi from 'joi';

export const envValidationSchema = Joi.object({
  NODE_ENV: Joi.string()
    .valid('development', 'production', 'test')
    .default('development'),
  PORT: Joi.number().default(3000),

  DB_HOST: Joi.string().required(),
  DB_PORT: Joi.number().default(5432),
  DB_USERNAME: Joi.string().required(),
  DB_PASSWORD: Joi.string().required(),
  DB_NAME: Joi.string().required(),

  API_SEND_KEY: Joi.string().min(16).required(),

  FIREBASE_SERVICE_ACCOUNT_PATH: Joi.string().default(
    './firebase-service-account.json',
  ),

  REGISTER_THROTTLE_TTL_MS: Joi.number().default(60000),
  REGISTER_THROTTLE_LIMIT: Joi.number().default(5),
});
