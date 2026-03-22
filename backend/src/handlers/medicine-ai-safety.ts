import { buildMedicineSafetyPrompt } from '../ai/prompts';
import { callTextModel } from '../ai/doubao-client';
import { findMedicine } from '../db/medicine-repository';
import { expectRecord, readTrimmedString } from '../http/body';
import { toApiFailure } from '../http/errors';
import { ApiEnvelope, fail, success } from '../http/response';
import { MedicineAiTextPayload, MedicineRefInput } from '../types';

function normalizeMedicineRef(value: unknown): MedicineRefInput | null {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return null;
  }

  const input = value as Record<string, unknown>;
  const item: MedicineRefInput = {
    drugCode:
      typeof input.drugCode === 'string' ? input.drugCode.trim() : '',
    approvalNo:
      typeof input.approvalNo === 'string' ? input.approvalNo.trim() : '',
    productName:
      typeof input.productName === 'string' ? input.productName.trim() : '',
  };

  if (!item.drugCode && !item.approvalNo && !item.productName) {
    return null;
  }

  return item;
}

export async function handleMedicineAiSafety(
  body: unknown,
): Promise<ApiEnvelope<MedicineAiTextPayload>> {
  try {
    const data = expectRecord(body);
    const mode = readTrimmedString(data, 'mode', 'single');
    const medicinesRaw = Array.isArray(data.medicines) ? data.medicines : [];
    const medicines = medicinesRaw
      .map(normalizeMedicineRef)
      .filter((item): item is MedicineRefInput => item !== null);

    if (mode !== 'single' && mode !== 'pair') {
      return fail('mode 必须是 single 或 pair');
    }
    if (mode === 'single' && medicines.length !== 1) {
      return fail('single 模式 medicines 必须为 1 个');
    }
    if (mode === 'pair' && medicines.length !== 2) {
      return fail('pair 模式 medicines 必须为 2 个');
    }

    const enrichedMedicines = await Promise.all(
      medicines.map(async (raw) => ({
        raw,
        detail: await findMedicine({
          drugCode: raw.drugCode,
          approvalNo: raw.approvalNo,
        }),
      })),
    );

    const text = await callTextModel(
      buildMedicineSafetyPrompt({
        mode,
        medicines: enrichedMedicines,
      }),
    );

    return success({ text });
  } catch (error) {
    console.error('medicine-ai-safety failed:', error);
    return toApiFailure(error, 'AI 安全分析失败，请稍后重试');
  }
}

