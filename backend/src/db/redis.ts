import { createClient } from 'redis';
import { env } from '../config/env';

type AppRedisClient = ReturnType<typeof createClient>;

let redisClient: AppRedisClient | null = null;

export async function connectRedis(): Promise<void> {
  if (redisClient?.isOpen) {
    return;
  }

  const client = createClient({
    url: env.redis.url,
  });

  client.on('error', (error) => {
    console.error('Redis connection error:', error);
  });

  await client.connect();
  redisClient = client;
  console.log('Redis connected successfully');
}

export function getRedisClient(): AppRedisClient {
  if (!redisClient || !redisClient.isOpen) {
    throw new Error('Redis client is not connected');
  }
  return redisClient;
}

export async function closeRedis(): Promise<void> {
  if (!redisClient) {
    return;
  }
  if (redisClient.isOpen) {
    await redisClient.quit();
  }
  redisClient = null;
}
