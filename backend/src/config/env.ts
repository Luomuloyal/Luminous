import 'dotenv/config';

function readString(name: string, fallback = ''): string {
  const value = process.env[name];
  return typeof value === 'string' ? value.trim() : fallback;
}

function readNumber(name: string, fallback: number): number {
  const value = Number(process.env[name]);
  return Number.isFinite(value) ? value : fallback;
}

function requireEnv(name: string): string {
  const value = readString(name);
  if (!value) {
    throw new Error(`缺少环境变量: ${name}`);
  }
  return value;
}

export const env = {
  port: readNumber('PORT', 8787),
  corsOrigin: readString('CORS_ORIGIN', '*'),
  mysql: {
    host: requireEnv('MYSQL_HOST'),
    port: readNumber('MYSQL_PORT', 3306),
    user: requireEnv('MYSQL_USER'),
    password: readString('MYSQL_PASSWORD'),
    database: requireEnv('MYSQL_DATABASE'),
    table: readString('MYSQL_TABLE', '国产本位码'),
  },
  doubao: {
    apiKey: readString('DOUBAO_API_KEY'),
    baseUrl: readString(
      'DOUBAO_BASE_URL',
      'https://ark.cn-beijing.volces.com/api/v3',
    ),
    visionEndpointId: readString('DOUBAO_VISION_ENDPOINT_ID'),
    visionModelId: readString('DOUBAO_VISION_MODEL_ID'),
    textEndpointId: readString('DOUBAO_TEXT_ENDPOINT_ID'),
    textModelId: readString('DOUBAO_TEXT_MODEL_ID'),
  },
} as const;

export function resolveVisionModel(): string {
  if (env.doubao.visionEndpointId) {
    return env.doubao.visionEndpointId;
  }
  if (env.doubao.visionModelId) {
    return env.doubao.visionModelId;
  }
  throw new Error('缺少 DOUBAO_VISION_ENDPOINT_ID 或 DOUBAO_VISION_MODEL_ID');
}

export function resolveTextModel(): string {
  if (env.doubao.textEndpointId) {
    return env.doubao.textEndpointId;
  }
  if (env.doubao.textModelId) {
    return env.doubao.textModelId;
  }
  throw new Error('缺少 DOUBAO_TEXT_ENDPOINT_ID 或 DOUBAO_TEXT_MODEL_ID');
}

export function ensureDoubaoApiKey(): string {
  if (!env.doubao.apiKey) {
    throw new Error('缺少环境变量: DOUBAO_API_KEY');
  }
  return env.doubao.apiKey;
}

