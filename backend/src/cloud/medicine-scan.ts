import { handleMedicineScan } from '../handlers/medicine-scan';

export async function main(ctx: { body?: unknown }) {
  return handleMedicineScan(ctx.body);
}

