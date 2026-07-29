import { AppDataSource } from '../data-source';

// Development-only helper: inserts sample codes with no fcm_token so the
// register endpoint has something to link against locally. Real code
// provisioning is an external-system integration to be defined later
// (see flutter-notification-app-prompt.md, Section 7, item 1).
const SAMPLE_CODES = ['1001', '1002', '1003'];

async function seed() {
  const dataSource = await AppDataSource.initialize();

  for (const code of SAMPLE_CODES) {
    await dataSource.query(
      `INSERT INTO "clients" ("code") VALUES ($1) ON CONFLICT ("code") DO NOTHING`,
      [code],
    );
  }

  console.log(`Seeded ${SAMPLE_CODES.length} sample codes:`, SAMPLE_CODES);
  await dataSource.destroy();
}

seed().catch((error) => {
  console.error('Seeding failed:', error);
  process.exit(1);
});
