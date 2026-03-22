export interface ApiEnvelope<T> {
  code: string;
  msg: string;
  result: T | null;
}

export function success<T>(result: T, msg = ''): ApiEnvelope<T> {
  return { code: '1', msg, result };
}

export function fail<T = never>(msg: string, code = '0'): ApiEnvelope<T> {
  return { code, msg, result: null };
}
