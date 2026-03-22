import { handleMedicineSearch } from '../handlers/medicine-search';

export async function main(ctx: { body?: unknown }) {
  return handleMedicineSearch(ctx.body);
}

