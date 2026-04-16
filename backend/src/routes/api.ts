import { Express } from 'express';
import {
  handleDeleteAccount,
  handleGetUserProfile,
  handleLogin,
  handleRefreshToken,
  handleRegister,
  handleSendCode,
  handleUpdateUserProfile,
} from '../handlers/auth';
import { handleMedicineAiDetail } from '../handlers/medicine-ai-detail';
import { handleMedicineAiSafety } from '../handlers/medicine-ai-safety';
import { handleMedicineDetail } from '../handlers/medicine-detail';
import { handleMedicineScan } from '../handlers/medicine-scan';
import { handleMedicineSearch } from '../handlers/medicine-search';
import {
  handleMyMedicineDelete,
  handleMyMedicineList,
  handleMyMedicineUpsert,
} from '../handlers/my-medicine';
import {
  handleReminderDelete,
  handleReminderList,
  handleReminderUpsert,
  handleTodayReminders,
} from '../handlers/reminder';
import {
  handleScanRecordCreate,
  handleScanRecordList,
} from '../handlers/scan-record';
import { createPostHandler } from '../http/express';
import { authMiddleware } from '../http/jwt';

export function registerApiRoutes(app: Express): void {
  // --- Auth endpoints ---
  app.post('/api/auth/codes', createPostHandler(handleSendCode));
  app.post('/api/auth/register', createPostHandler(handleRegister));
  app.post('/api/auth/login', createPostHandler(handleLogin));
  app.post('/api/auth/refresh', createPostHandler(handleRefreshToken));
  app.post('/api/user/profile', createPostHandler(handleGetUserProfile));
  app.post('/api/user/profile-update', createPostHandler(handleUpdateUserProfile));
  app.post('/api/user/delete', createPostHandler(handleDeleteAccount));
  
  // Example of a protected endpoint using authMiddleware:
  // app.post('/api/user/test', authMiddleware, createPostHandler(async (body, req) => success(req.user)));

  // --- Medicine endpoints ---
  app.post('/api/medicines/search', createPostHandler(handleMedicineSearch));
  app.post('/api/medicines/detail', createPostHandler(handleMedicineDetail));
  app.post('/api/medicines/ai-detail', createPostHandler(handleMedicineAiDetail));
  app.post('/api/medicines/ai-safety', createPostHandler(handleMedicineAiSafety));
  app.post('/api/medicines/scan', createPostHandler(handleMedicineScan));

  // --- My medicine endpoints ---
  app.post('/api/medicines/my-upsert', createPostHandler(handleMyMedicineUpsert));
  app.post('/api/medicines/my-delete', createPostHandler(handleMyMedicineDelete));
  app.post('/api/medicines/my-list', createPostHandler(handleMyMedicineList));

  // --- Reminder endpoints ---
  app.post('/api/reminders/upsert', createPostHandler(handleReminderUpsert));
  app.post('/api/reminders/delete', createPostHandler(handleReminderDelete));
  app.post('/api/reminders/list', createPostHandler(handleReminderList));
  app.post('/api/reminders/today', createPostHandler(handleTodayReminders));

  // --- Scan record endpoints ---
  app.post('/api/medicines/scan-record-create', createPostHandler(handleScanRecordCreate));
  app.post('/api/medicines/scan-record-list', createPostHandler(handleScanRecordList));
}
