import cors from 'cors';
import express from 'express';
import { env } from './config/env';
import { errorHandler, notFoundHandler } from './http/express';
import { success } from './http/response';
import { registerApiRoutes } from './routes/api';

function createCorsOptions() {
  if (!env.corsOrigin || env.corsOrigin === '*') {
    return {};
  }

  const origins = env.corsOrigin
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);

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

