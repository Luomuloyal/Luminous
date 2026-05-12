import { buildMedicineAiDetailPrompt } from '../ai/prompts';
import {
  buildMedicineAiDetailCacheKey,
  loadAiTextWithCache,
} from '../ai/text-cache';
import { callTextModel } from '../ai/langchain-client';
import { findMedicine } from '../db/medicine-repository';
import { expectRecord, readBoolean, readTrimmedString } from '../http/body';
import { toApiFailure } from '../http/errors';
import { ApiEnvelope, fail, success } from '../http/response';
import { MedicineAiTextPayload } from '../types';

interface MedicineAiDetailDeps {
  findMedicine: typeof findMedicine;
  buildPrompt: typeof buildMedicineAiDetailPrompt;
  callTextModel: typeof callTextModel;
  loadAiTextWithCache: typeof loadAiTextWithCache;
  buildCacheKey: typeof buildMedicineAiDetailCacheKey;
}

export async function handleMedicineAiDetail(
  body: unknown,
  deps: Partial<MedicineAiDetailDeps> = {},
): Promise<ApiEnvelope<MedicineAiTextPayload>> {
  try {
    const resolvedDeps: MedicineAiDetailDeps = {
      findMedicine,
      buildPrompt: buildMedicineAiDetailPrompt,
      callTextModel,
      loadAiTextWithCache,
      buildCacheKey: buildMedicineAiDetailCacheKey,
      ...deps,
    };
    const data = expectRecord(body);
    const drugCode = readTrimmedString(data, 'drugCode');
    const approvalNo = readTrimmedString(data, 'approvalNo');
    const refresh = readBoolean(data, 'refresh', false);

    if (!drugCode && !approvalNo) {
      return fail('drugCode 或 approvalNo 不能为空');
    }

    const item = await resolvedDeps.findMedicine({ drugCode, approvalNo });
    if (!item) {
      return fail('未找到该药品信息');
    }

    const result = await resolvedDeps.loadAiTextWithCache({
      key: resolvedDeps.buildCacheKey(item),
      refresh,
      generate: () => resolvedDeps.callTextModel(resolvedDeps.buildPrompt(item)),
    });
    return success(result);
  } catch (error) {
    console.error('medicine-ai-detail failed:', error);
    return toApiFailure(error, 'AI 解读生成失败，请稍后重试');
  }
}
