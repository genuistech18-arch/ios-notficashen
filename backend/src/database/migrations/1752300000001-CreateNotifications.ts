import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateNotifications1752300000001 implements MigrationInterface {
  name = 'CreateNotifications1752300000001';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TYPE "notifications_delivery_status_enum" AS ENUM ('sent', 'failed', 'no_token')`,
    );

    await queryRunner.query(`
      CREATE TABLE "notifications" (
        "id" uuid NOT NULL,
        "user_id" uuid NOT NULL,
        "message" text NOT NULL,
        "is_read" boolean NOT NULL DEFAULT false,
        "sent_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
        "read_at" TIMESTAMPTZ,
        "delivery_status" "notifications_delivery_status_enum" NOT NULL,
        CONSTRAINT "PK_notifications_id" PRIMARY KEY ("id"),
        CONSTRAINT "FK_notifications_user_id" FOREIGN KEY ("user_id")
          REFERENCES "clients"("id") ON DELETE CASCADE
      )
    `);

    await queryRunner.query(
      `CREATE INDEX "IDX_notifications_user_id" ON "notifications" ("user_id")`,
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE "notifications"`);
    await queryRunner.query(`DROP TYPE "notifications_delivery_status_enum"`);
  }
}
