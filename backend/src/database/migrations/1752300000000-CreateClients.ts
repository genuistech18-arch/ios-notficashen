import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateClients1752300000000 implements MigrationInterface {
  name = 'CreateClients1752300000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`CREATE EXTENSION IF NOT EXISTS "pgcrypto"`);

    await queryRunner.query(`
      CREATE TABLE "clients" (
        "id" uuid NOT NULL DEFAULT gen_random_uuid(),
        "code" varchar NOT NULL,
        "fcm_token" varchar,
        "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        CONSTRAINT "PK_clients_id" PRIMARY KEY ("id"),
        CONSTRAINT "UQ_clients_code" UNIQUE ("code")
      )
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "clients"`);
  }
}
