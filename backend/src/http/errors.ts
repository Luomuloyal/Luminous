import { ApiEnvelope, fail } from './response';

export class AppError extends Error {
  constructor(
    message: string,
    readonly code = '0',
    readonly status = 400,
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export function resolveServiceError(
  error: unknown,
  fallback = '服务异常，请稍后重试',
): string {
  if (error instanceof AppError) {
    return error.message;
  }

  const message = String((error as { message?: string } | undefined)?.message || '').trim();
  if (!message) {
    return fallback;
  }

  if (
    message.includes('ECONNREFUSED') ||
    message.includes('ETIMEDOUT') ||
    message.includes('EHOSTUNREACH')
  ) {
    return 'MySQL 连接失败：请检查 MYSQL_HOST/MYSQL_PORT/白名单/网络策略';
  }

  if (message.includes('Cannot find module') && message.includes('mysql2')) {
    return '缺少依赖 mysql2：请先安装依赖再重试';
  }

  if (message.includes('DOUBAO_') || message.includes('缺少环境变量: DOUBAO')) {
    return 'AI 服务配置不完整，请检查豆包环境变量';
  }

  if (message.includes('MYSQL_') || message.includes('缺少环境变量: MYSQL')) {
    return '数据库配置不完整，请检查 MySQL 环境变量';
  }

  return fallback;
}

export function toApiFailure(
  error: unknown,
  fallback = '服务异常，请稍后重试',
): ApiEnvelope<never> {
  return fail(resolveServiceError(error, fallback));
}
