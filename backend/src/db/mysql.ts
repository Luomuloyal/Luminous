import mysql from 'mysql2/promise.js';
import { env } from '../config/env';

let pool: mysql.Pool | null = null;

function escapeIdentifier(name: string): string {
  return `\`${String(name).replace(/`/g, '``')}\``;
}

export function tableRef(): string {
  return `${escapeIdentifier(env.mysql.database)}.${escapeIdentifier(env.mysql.table)}`;
}

export function getMysqlPool(): mysql.Pool {
  if (pool) {
    return pool;
  }

  pool = mysql.createPool({
    host: env.mysql.host,
    port: env.mysql.port,
    user: env.mysql.user,
    password: env.mysql.password,
    database: env.mysql.database,
    charset: 'utf8mb4',
    waitForConnections: true,
    connectionLimit: 8,
    namedPlaceholders: false,
  });

  return pool;
}

export function escapeLike(input: string): string {
  return input.replace(/[\\%_]/g, '\\$&');
}

