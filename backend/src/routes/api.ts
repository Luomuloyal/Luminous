import { Express } from 'express';
import {
  handleLogin,
  handleRefreshToken,
  handleRegister,
  handleSendCode,
} from '../handlers/auth';
import { handleMedicineAiDetail } from '../handlers/medicine-ai-detail';
import { handleMedicineAiSafety } from '../handlers/medicine-ai-safety';
import { handleMedicineDetail } from '../handlers/medicine-detail';
import { handleMedicineScan } from '../handlers/medicine-scan';
import { handleMedicineSearch } from '../handlers/medicine-search';
import { createPostHandler } from '../http/express';
import { authMiddleware } from '../http/jwt';

export function registerApiRoutes(app: Express): void {
  // --- Auth endpoints ---
  app.post('/api/auth/codes', createPostHandler(handleSendCode));
  app.post('/api/auth/register', createPostHandler(handleRegister));
  app.post('/api/auth/login', createPostHandler(handleLogin));
  app.post('/api/auth/refresh', createPostHandler(handleRefreshToken));
  
  // Example of a protected endpoint using authMiddleware:
  // app.post('/api/user/test', authMiddleware, createPostHandler(async (body, req) => success(req.user)));

  // --- Medicine endpoints ---
  app.post('/api/medicines/search', createPostHandler(handleMedicineSearch));
  app.post('/api/medicines/detail', createPostHandler(handleMedicineDetail));
  app.post('/api/medicines/ai-detail', createPostHandler(handleMedicineAiDetail));
  app.post('/api/medicines/ai-safety', createPostHandler(handleMedicineAiSafety));
  app.post('/api/medicines/scan', createPostHandler(handleMedicineScan));
}

