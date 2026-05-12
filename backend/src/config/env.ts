import { config as loadEnv } from 'dotenv';

function readEnvFileFromArgv(): string {
  const inlineArgPrefix = '--env-file=';
  const inlineArg = process.argv.find((arg) => arg.startsWith(inlineArgPrefix));
  if (inlineArg) {
    return inlineArg.slice(inlineArgPrefix.length).trim();
  }

  const envFileFlagIndex = process.argv.indexOf('--env-file');
  if (envFileFlagIndex !== -1) {
    return (process.argv[envFileFlagIndex + 1] ?? '').trim();
  }

  return '';
}

const envFile = readEnvFileFromArgv();
if (envFile) {
  const loaded = loadEnv({ path: envFile });
  if (loaded.error) {
    throw new Error(`加载环境变量文件失败: ${envFile}`);
  }
} else {
  loadEnv();
}

function readString(name: string, fallback = ''): string {
  const value = process.env[name];
  return typeof value === 'string' ? value.trim() : fallback;
}

function readNumber(name: string, fallback: number): number {
  const value = Number(process.env[name]);
  return Number.isFinite(value) ? value : fallback;
}

function readBoolean(name: string, fallback: boolean): boolean {
  const raw = readString(name);
  if (!raw) {
    return fallback;
  }
  const value = raw.toLowerCase();
  if (['1', 'true', 'yes', 'on'].includes(value)) {
    return true;
  }
  if (['0', 'false', 'no', 'off'].includes(value)) {
    return false;
  }
  return fallback;
}

function requireEnv(name: string): string {
  const value = readString(name);
  if (!value) {
    throw new Error(`缺少环境变量: ${name}`);
  }
  return value;
}

const DEFAULT_DOUBAO_BASE_URL = 'https://ark.cn-beijing.volces.com/api/v3';
const GENERIC_AI_ENV_NAMES = [
  'AI_PROVIDER',
  'AI_API_KEY',
  'AI_BASE_URL',
  'AI_TEXT_MODEL',
  'AI_VISION_MODEL',
  'AI_TEXT_TEMPERATURE',
  'AI_VISION_TEMPERATURE',
] as const;

function hasGenericAiConfig(): boolean {
  return GENERIC_AI_ENV_NAMES.some((name) => readString(name) !== '');
}

export const env = {
  host: readString('HOST', '0.0.0.0'),
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
  mongoUri: readString('MONGODB_URI', 'mongodb://localhost:27017/luminous'),
  redis: {
    url: readString('REDIS_URL', 'redis://127.0.0.1:6379'),
  },
  authCode: {
    ttlSeconds: readNumber('AUTH_CODE_TTL_SECONDS', 300),
    deliveryMode: readString('AUTH_CODE_DELIVERY_MODE', 'log'),
    smsWebhookUrl: readString('AUTH_CODE_SMS_WEBHOOK_URL'),
    email: {
      host: readString('AUTH_CODE_EMAIL_HOST'),
      port: readNumber('AUTH_CODE_EMAIL_PORT', 465),
      secure: readBoolean('AUTH_CODE_EMAIL_SECURE', true),
      user: readString('AUTH_CODE_EMAIL_USER'),
      pass: readString('AUTH_CODE_EMAIL_PASS'),
      from: readString('AUTH_CODE_EMAIL_FROM'),
    },
  },
  jwtSecret: requireEnv('JWT_SECRET'),
  jwtRefreshSecret: requireEnv('JWT_REFRESH_SECRET'),
  ai: {
    provider: readString('AI_PROVIDER', 'openai-compatible'),
    apiKey: readString('AI_API_KEY'),
    baseUrl: readString('AI_BASE_URL'),
    textModel: readString('AI_TEXT_MODEL'),
    visionModel: readString('AI_VISION_MODEL'),
    textTemperature: readNumber('AI_TEXT_TEMPERATURE', 0.3),
    visionTemperature: readNumber('AI_VISION_TEMPERATURE', 0.2),
    hasGenericConfig: hasGenericAiConfig(),
  },
  doubao: {
    apiKey: readString('DOUBAO_API_KEY'),
    baseUrl: readString('DOUBAO_BASE_URL', DEFAULT_DOUBAO_BASE_URL),
    visionEndpointId: readString('DOUBAO_VISION_ENDPOINT_ID'),
    visionModelId: readString('DOUBAO_VISION_MODEL_ID'),
    textEndpointId: readString('DOUBAO_TEXT_ENDPOINT_ID'),
    textModelId: readString('DOUBAO_TEXT_MODEL_ID'),
  },
} as const;

type AiConfigSnapshot = Pick<typeof env, 'ai' | 'doubao'>;

export function ensureOpenAiCompatibleProvider(
  config: AiConfigSnapshot = env,
): void {
  if (config.ai.provider !== 'openai-compatible') {
    throw new Error(`暂不支持 AI_PROVIDER=${config.ai.provider}`);
  }
}

export function ensureAiApiKey(config: AiConfigSnapshot = env): string {
  ensureOpenAiCompatibleProvider(config);
  if (config.ai.apiKey) {
    return config.ai.apiKey;
  }
  if (config.ai.hasGenericConfig) {
    throw new Error('缺少环境变量: AI_API_KEY');
  }
  if (config.doubao.apiKey) {
    return config.doubao.apiKey;
  }
  throw new Error('缺少环境变量: AI_API_KEY 或 DOUBAO_API_KEY');
}

export function resolveAiBaseUrl(config: AiConfigSnapshot = env): string {
  ensureOpenAiCompatibleProvider(config);
  if (config.ai.baseUrl) {
    return config.ai.baseUrl;
  }
  if (config.ai.hasGenericConfig) {
    throw new Error('缺少环境变量: AI_BASE_URL');
  }
  return config.doubao.baseUrl;
}

export function resolveTextModel(config: AiConfigSnapshot = env): string {
  ensureOpenAiCompatibleProvider(config);
  if (config.ai.textModel) {
    return config.ai.textModel;
  }
  if (config.ai.hasGenericConfig) {
    throw new Error('缺少环境变量: AI_TEXT_MODEL');
  }
  if (config.doubao.textEndpointId) {
    return config.doubao.textEndpointId;
  }
  if (config.doubao.textModelId) {
    return config.doubao.textModelId;
  }
  throw new Error(
    '缺少 AI_TEXT_MODEL 或 DOUBAO_TEXT_ENDPOINT_ID 或 DOUBAO_TEXT_MODEL_ID',
  );
}

export function resolveVisionModel(config: AiConfigSnapshot = env): string {
  ensureOpenAiCompatibleProvider(config);
  if (config.ai.visionModel) {
    return config.ai.visionModel;
  }
  if (config.ai.hasGenericConfig) {
    throw new Error('缺少环境变量: AI_VISION_MODEL');
  }
  if (config.doubao.visionEndpointId) {
    return config.doubao.visionEndpointId;
  }
  if (config.doubao.visionModelId) {
    return config.doubao.visionModelId;
  }
  throw new Error(
    '缺少 AI_VISION_MODEL 或 DOUBAO_VISION_ENDPOINT_ID 或 DOUBAO_VISION_MODEL_ID',
  );
}
