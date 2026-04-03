export interface MedicineItemRecord {
  serialNo: string;
  approvalNo: string;
  productName: string;
  dosageForm: string;
  specification: string;
  marketingAuthorizationHolder: string;
  manufacturer: string;
  drugCode: string;
  drugCodeRemark: string;
}

export interface ScanCandidateRecord extends MedicineItemRecord {
  score: number;
}

export interface MedicineRefInput {
  drugCode?: string;
  approvalNo?: string;
  productName?: string;
}

export interface MedicineSearchPayload {
  items: MedicineItemRecord[];
  total: number;
  page: number;
  pageSize: number;
}

export interface MedicineAiTextPayload {
  text: string;
}

export interface MedicineScanPayload {
  candidates: ScanCandidateRecord[];
  thumbBase64: string;
}

export interface ScanRecognitionFields {
  productName: string;
  approvalNo: string;
  manufacturer: string;
  dosageForm: string;
  specification: string;
}

export interface MyMedicineRecordPayload {
  id: string;
  userId: string;
  identityKey: string;
  drugCode: string;
  approvalNo: string;
  productName: string;
  dosageForm: string;
  specification: string;
  manufacturer: string;
  source: string;
  createdAt: number;
}

export interface MyMedicineListPayload {
  items: MyMedicineRecordPayload[];
}

export interface ReminderPlanRecord {
  id: string;
  userId: string;
  time: string;
  drugCode: string;
  approvalNo: string;
  productName: string;
  medicines: MedicineRefInput[];
  dosage: string;
  subtitle: string;
  enabled: boolean;
  repeatRule: string;
  method: string;
  startDate?: string;
  endDate?: string;
}

export interface ReminderListPayload {
  items: ReminderPlanRecord[];
}

export interface TodayReminderItemRecord {
  id: string;
  time: string;
  title: string;
  dosage: string;
  subtitle: string;
  done: boolean;
}

export interface TodayRemindersPayload {
  date: string;
  items: TodayReminderItemRecord[];
}

export interface ScanRecordCreatePayload {
  id: string;
}

export interface ScanRecordItemRecord {
  id: string;
  thumbBase64: string;
  drugCode: string;
  approvalNo: string;
  productName: string;
  takenAt: number;
}

export interface ScanRecordListPayload {
  items: ScanRecordItemRecord[];
  total: number;
  page: number;
  pageSize: number;
}

