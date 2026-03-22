import { AppError } from './errors';

export type JsonRecord = Record<string, unknown>;

export function expectRecord(body: unknown): JsonRecord {
  if (!body || typeof body !== 'object' || Array.isArray(body)) {
    throw new AppError('请求参数格式错误');
  }
  return body as JsonRecord;
}

export function readTrimmedString(
  body: JsonRecord,
  key: string,
  fallback = '',
): string {
  const value = body[key];
  return typeof value === 'string' ? value.trim() : fallback;
}

export function readPage(
  body: JsonRecord,
  key: string,
  fallback: number,
  min: number,
  max: number,
): number {
  const raw = Number(body[key]);
  if (!Number.isFinite(raw)) {
    return fallback;
  }
  return Math.min(max, Math.max(min, Math.trunc(raw)));
}

