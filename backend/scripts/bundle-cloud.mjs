import { mkdir } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { build } from 'esbuild';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = join(__dirname, '..');
const outDir = join(rootDir, 'dist', 'cloud-bundle');

const entries = [
  'medicine-search',
  'medicine-detail',
  'medicine-ai-detail',
  'medicine-ai-safety',
  'medicine-scan',
];

await mkdir(outDir, { recursive: true });

await Promise.all(
  entries.map((name) =>
    build({
      entryPoints: [join(rootDir, 'src', 'cloud', `${name}.ts`)],
      outfile: join(outDir, `${name}.js`),
      bundle: true,
      platform: 'node',
      format: 'cjs',
      target: 'node18',
      sourcemap: false,
    }),
  ),
);

console.log(`Bundled ${entries.length} cloud functions into ${outDir}`);

