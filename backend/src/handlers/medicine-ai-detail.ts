import { buildMedicineAiDetailPrompt } from '../ai/prompts';
import { callTextModel } from '../ai/doubao-client';
import { findMedicine } from '../db/medicine-repository';
import { expectRecord, readTrimmedString } from '../http/body';
import { toApiFailure } from '../http/errors';
import { ApiEnvelope, fail, success } from '../http/response';
import { MedicineAiTextPayload } from '../types';

export async function handleMedicineAiDetail(
  body: unknown,
): Promise<ApiEnvelope<MedicineAiTextPayload>> {
  try {
    const data = expectRecord(body);
    const drugCode = readTrimmedString(data, 'drugCode');
    const approvalNo = readTrimmedString(data, 'approvalNo');

    if (!drugCode && !approvalNo) {
      return fail('drugCode 或 approvalNo 不能为空');
    }

    const item = await findMedicine({ drugCode, approvalNo });
    if (!item) {
      return fail('未找到该药品信息');
    }

    const text = await callTextModel(buildMedicineAiDetailPrompt(item));
    return success({ text });
  } catch (error) {
    console.error('medicine-ai-detail failed:', error);
    return toApiFailure(error, 'AI 解读生成失败，请稍后重试');
  }
}

