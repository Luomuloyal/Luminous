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

