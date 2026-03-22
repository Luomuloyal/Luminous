import { Express } from 'express';
import { handleMedicineAiDetail } from '../handlers/medicine-ai-detail';
import { handleMedicineAiSafety } from '../handlers/medicine-ai-safety';
import { handleMedicineDetail } from '../handlers/medicine-detail';
import { handleMedicineScan } from '../handlers/medicine-scan';
import { handleMedicineSearch } from '../handlers/medicine-search';
import { createPostHandler } from '../http/express';

export function registerApiRoutes(app: Express): void {
  app.post('/medicine-search', createPostHandler(handleMedicineSearch));
  app.post('/medicine-detail', createPostHandler(handleMedicineDetail));
  app.post('/medicine-ai-detail', createPostHandler(handleMedicineAiDetail));
  app.post('/medicine-ai-safety', createPostHandler(handleMedicineAiSafety));
  app.post('/medicine-scan', createPostHandler(handleMedicineScan));
}

