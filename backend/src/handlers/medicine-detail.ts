import { findMedicine } from '../db/medicine-repository';
import { expectRecord, readTrimmedString } from '../http/body';
import { toApiFailure } from '../http/errors';
import { ApiEnvelope, fail, success } from '../http/response';
import { MedicineItemRecord } from '../types';

export async function handleMedicineDetail(
  body: unknown,
): Promise<ApiEnvelope<MedicineItemRecord>> {
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

    return success(item);
  } catch (error) {
    console.error('medicine-detail failed:', error);
    return toApiFailure(error, '查询失败，请稍后重试');
  }
}

