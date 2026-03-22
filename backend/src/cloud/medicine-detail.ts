import { handleMedicineDetail } from '../handlers/medicine-detail';

export async function main(ctx: { body?: unknown }) {
  return handleMedicineDetail(ctx.body);
}

