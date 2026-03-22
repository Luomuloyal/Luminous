import { searchMedicines } from '../db/medicine-repository';
import { expectRecord, readPage, readTrimmedString } from '../http/body';
import { toApiFailure } from '../http/errors';
import { ApiEnvelope, fail, success } from '../http/response';
import { MedicineSearchPayload } from '../types';

export async function handleMedicineSearch(
  body: unknown,
): Promise<ApiEnvelope<MedicineSearchPayload>> {
  try {
    const data = expectRecord(body);
    const keyword = readTrimmedString(data, 'keyword');
    const page = readPage(data, 'page', 1, 1, Number.MAX_SAFE_INTEGER);
    const pageSize = readPage(data, 'pageSize', 20, 1, 50);

    if (!keyword) {
      return fail('keyword 不能为空');
    }

    const result = await searchMedicines({ keyword, page, pageSize });
    return success(result);
  } catch (error) {
    console.error('medicine-search failed:', error);
    return toApiFailure(error, '查询失败，请稍后重试');
  }
}

