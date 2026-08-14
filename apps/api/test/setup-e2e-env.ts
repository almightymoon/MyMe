import { resolve } from 'path';
import { loadEnvTestFile } from '../src/common/testing/load-env-test';

/**
 * Load apps/api/.env.test into process.env before the Nest app boots.
 * Fail fast if the file is missing — never silently use the development DB.
 * Does not rewrite NODE_ENV.
 */
loadEnvTestFile(resolve(__dirname, '../.env.test'));
