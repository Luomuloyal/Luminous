# Frontend-Backend Alignment Checklist

Last verified: 2026-03-29

## Global Contract

- [x] Response envelope is unified as `{ code, msg, result }`
- [x] Frontend unified decode entry is `DioRequest._request`
- [x] Business success condition is `code == "1"`
- [x] Business failures are surfaced as `ApiException`
- [x] All frontend API constants in `HttpConstants` have backend route coverage

## Endpoint Mapping (Frontend -> Backend)

### Auth

- [x] `POST /api/auth/codes`
  - Frontend: `AuthApi.sendPhoneCode/sendEmailCode`
  - Decoder: `CodeTicketResult.fromJson`
  - Backend: `handleSendCode`
- [x] `POST /api/auth/register`
  - Frontend: `AuthApi.registerWithPhone/registerWithEmail`
  - Decoder: `RegisterResult.fromJson`
  - Backend: `handleRegister`
- [x] `POST /api/auth/login`
  - Frontend: `AuthApi.loginWithPassword/loginWithCode`
  - Decoder: `LoginResult.fromJson`
  - Backend: `handleLogin`
- [x] `POST /api/auth/refresh`
  - Frontend: `DioRequest` 401 auto-refresh flow
  - Decoder: raw map in `DioRequest.onError`
  - Backend: `handleRefreshToken`

### Medicine

- [x] `POST /api/medicines/search`
  - Frontend: `MedicineApi.search`
  - Decoder: `MedicineSearchResult.fromJson`
  - Backend: `handleMedicineSearch`
- [x] `POST /api/medicines/detail`
  - Frontend: `MedicineApi.fetchDetail`
  - Decoder: `MedicineItem.fromJson`
  - Backend: `handleMedicineDetail`
- [x] `POST /api/medicines/ai-detail`
  - Frontend: `MedicineApi.fetchAiDetail`
  - Decoder: `MedicineAiDetailResult.fromJson`
  - Backend: `handleMedicineAiDetail`
- [x] `POST /api/medicines/ai-safety`
  - Frontend: `SafetyApi.query`
  - Decoder: `MedicineAiSafetyResult.fromJson`
  - Backend: `handleMedicineAiSafety`
  - Note: enrichment now supports `productName` fallback lookup
- [x] `POST /api/medicines/scan`
  - Frontend: `ScanApi.scanMedicine`
  - Decoder: `MedicineScanResult.fromJson`
  - Backend: `handleMedicineScan`

### My Medicines

- [x] `POST /api/medicines/my-upsert`
  - Frontend: `MyMedicineApi.upsert`
  - Decoder: `MyMedicineRecord.fromJson`
  - Backend: `handleMyMedicineUpsert`
- [x] `POST /api/medicines/my-delete`
  - Frontend: `MyMedicineApi.delete`
  - Decoder: bool normalize in `MyMedicineApi.delete`
  - Backend: `handleMyMedicineDelete`
- [x] `POST /api/medicines/my-list`
  - Frontend: `MyMedicineApi.list`
  - Decoder: `MyMedicineListResult.fromJson`
  - Backend: `handleMyMedicineList`

### Reminder

- [x] `POST /api/reminders/upsert`
  - Frontend: `ReminderApi.upsert`
  - Decoder: `ReminderPlan.fromJson`
  - Backend: `handleReminderUpsert`
- [x] `POST /api/reminders/delete`
  - Frontend: `ReminderApi.delete`
  - Decoder: bool normalize in `ReminderApi.delete`
  - Backend: `handleReminderDelete`
- [x] `POST /api/reminders/list`
  - Frontend: `ReminderApi.list`
  - Decoder: `ReminderListResult.fromJson`
  - Backend: `handleReminderList`
- [x] `POST /api/reminders/today`
  - Frontend: `HomeApi.fetchTodayReminders`
  - Decoder: `TodayRemindersResult.fromJson`
  - Backend: `handleTodayReminders`

### Scan Record

- [x] `POST /api/medicines/scan-record-create`
  - Frontend: `ScanApi.createScanRecord`
  - Decoder: `IdResult.fromJson`
  - Backend: `handleScanRecordCreate`
- [ ] `POST /api/medicines/scan-record-list` (backend-only optional)
  - Frontend: not currently consumed by app
  - Backend: `handleScanRecordList`

## Validation Commands

- [x] Backend compile

```bash
cd backend
npm run build
```

- [x] Frontend tests

```bash
flutter test
```

- [x] Route parity check (frontend constants vs backend routes)

```powershell
$constants = Select-String -Path "lib/constants/constants.dart" -Pattern "static const String\s+\w+\s+=\s+'(/api[^']+)'" | ForEach-Object { if($_.Line -match "'(/api[^']+)'"){ $Matches[1] } } | Sort-Object -Unique
$routes = Select-String -Path "backend/src/routes/api.ts" -Pattern "^\s*app\.post\('/api[^']+'" | ForEach-Object { if($_.Line -match "'(/api[^']+)'"){ $Matches[1] } } | Sort-Object -Unique
$constants | Where-Object { $_ -notin $routes }
```

## Current Conclusion

- Frontend-consumed APIs are aligned with backend routes and payload fields.
- One extra backend route exists (`/api/medicines/scan-record-list`) and is safe as optional capability.
