import cors from 'cors';
import express from 'express';
import { env } from './config/env';
import { errorHandler, notFoundHandler } from './http/express';
import { success } from './http/response';
import { registerApiRoutes } from './routes/api';

function createCorsOptions() {
  const raw = env.corsOrigin.trim();
  if (!raw) {
    return {};
  }

  if (raw === '*') {
    if ((process.env.NODE_ENV ?? '').trim().toLowerCase() === 'production') {
      throw new Error('CORS_ORIGIN=* is not allowed in production');
    }
    return { origin: true };
  }

  const origins = raw
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);

  if (origins.length === 0) {
    return {};
  }

  return { origin: origins };
}

export function createApp() {
  const app = express();

  app.use(cors(createCorsOptions()));
  app.use(express.json({ limit: '12mb' }));

  app.get('/health', (_req, res) => {
    res.json(success({ ok: true }));
  });

  registerApiRoutes(app);
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}

