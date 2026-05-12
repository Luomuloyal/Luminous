import { buildMedicineSafetyPrompt } from '../ai/prompts';
import {
  buildMedicineAiSafetyCacheKey,
  loadAiTextWithCache,
} from '../ai/text-cache';
import { callTextModel } from '../ai/langchain-client';
import { findMedicine } from '../db/medicine-repository';
import { expectRecord, readBoolean, readTrimmedString } from '../http/body';
import { toApiFailure } from '../http/errors';
import { ApiEnvelope, fail, success } from '../http/response';
import { MedicineAiTextPayload, MedicineRefInput } from '../types';

interface MedicineAiSafetyDeps {
  findMedicine: typeof findMedicine;
  buildPrompt: typeof buildMedicineSafetyPrompt;
  callTextModel: typeof callTextModel;
  loadAiTextWithCache: typeof loadAiTextWithCache;
  buildCacheKey: typeof buildMedicineAiSafetyCacheKey;
}

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
  deps: Partial<MedicineAiSafetyDeps> = {},
): Promise<ApiEnvelope<MedicineAiTextPayload>> {
  try {
    const resolvedDeps: MedicineAiSafetyDeps = {
      findMedicine,
      buildPrompt: buildMedicineSafetyPrompt,
      callTextModel,
      loadAiTextWithCache,
      buildCacheKey: buildMedicineAiSafetyCacheKey,
      ...deps,
    };
    const data = expectRecord(body);
    const mode = readTrimmedString(data, 'mode', 'single');
    const refresh = readBoolean(data, 'refresh', false);
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
        detail: await resolvedDeps.findMedicine({
          drugCode: raw.drugCode,
          approvalNo: raw.approvalNo,
          productName: raw.productName,
        }),
      })),
    );

    const result = await resolvedDeps.loadAiTextWithCache({
      key: resolvedDeps.buildCacheKey({
        mode,
        medicines: enrichedMedicines.map(({ raw, detail }) => ({
          drugCode: detail?.drugCode ?? raw.drugCode,
          approvalNo: detail?.approvalNo ?? raw.approvalNo,
          productName: detail?.productName ?? raw.productName,
        })),
      }),
      refresh,
      generate: () =>
        resolvedDeps.callTextModel(
          resolvedDeps.buildPrompt({
            mode,
            medicines: enrichedMedicines,
          }),
        ),
    });

    return success(result);
  } catch (error) {
    console.error('medicine-ai-safety failed:', error);
    return toApiFailure(error, 'AI 安全分析失败，请稍后重试');
  }
}
