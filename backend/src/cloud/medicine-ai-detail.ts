import { handleMedicineAiDetail } from '../handlers/medicine-ai-detail';

export async function main(ctx: { body?: unknown }) {
  return handleMedicineAiDetail(ctx.body);
}

