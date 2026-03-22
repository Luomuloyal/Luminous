import { handleMedicineAiSafety } from '../handlers/medicine-ai-safety';

export async function main(ctx: { body?: unknown }) {
  return handleMedicineAiSafety(ctx.body);
}

