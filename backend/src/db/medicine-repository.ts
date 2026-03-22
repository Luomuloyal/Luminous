import { RowDataPacket } from 'mysql2';
import {
  MedicineItemRecord,
  MedicineSearchPayload,
  ScanCandidateRecord,
} from '../types';
import { escapeLike, getMysqlPool, tableRef } from './mysql';

type MedicineRow = RowDataPacket & {
  serialNo?: string | number;
  approvalNo?: string;
  productName?: string;
  dosageForm?: string;
  specification?: string;
  marketingAuthorizationHolder?: string;
  manufacturer?: string;
  drugCode?: string;
  drugCodeRemark?: string;
};

function baseSelectSql(): string {
  return `SELECT
    \`序号\` AS serialNo,
    \`批准文号\` AS approvalNo,
    \`产品名称\` AS productName,
    \`剂型\` AS dosageForm,
    \`规格\` AS specification,
    \`上市许可持有人\` AS marketingAuthorizationHolder,
    \`生产单位\` AS manufacturer,
    \`药品编码\` AS drugCode,
    \`药品编码备注\` AS drugCodeRemark
  FROM ${tableRef()}`;
}

function mapMedicineRow(row: MedicineRow): MedicineItemRecord {
  return {
    serialNo: String(row.serialNo ?? '').trim(),
    approvalNo: String(row.approvalNo ?? '').trim(),
    productName: String(row.productName ?? '').trim(),
    dosageForm: String(row.dosageForm ?? '').trim(),
    specification: String(row.specification ?? '').trim(),
    marketingAuthorizationHolder: String(
      row.marketingAuthorizationHolder ?? '',
    ).trim(),
    manufacturer: String(row.manufacturer ?? '').trim(),
    drugCode: String(row.drugCode ?? '').trim(),
    drugCodeRemark: String(row.drugCodeRemark ?? '').trim(),
  };
}

function buildIdentityKey(item: MedicineItemRecord): string {
  return [
    item.drugCode.trim(),
    item.approvalNo.trim(),
    item.productName.trim(),
  ].join('|');
}

export async function searchMedicines(input: {
  keyword: string;
  page: number;
  pageSize: number;
}): Promise<MedicineSearchPayload> {
  const pool = getMysqlPool();
  const like = `%${escapeLike(input.keyword)}%`;
  const where =
    'WHERE `产品名称` LIKE ? ESCAPE \'\\\\\' OR `批准文号` LIKE ? ESCAPE \'\\\\\' OR `生产单位` LIKE ? ESCAPE \'\\\\\' OR `上市许可持有人` LIKE ? ESCAPE \'\\\\\' OR `药品编码` LIKE ? ESCAPE \'\\\\\'';
  const params = [like, like, like, like, like];
  const offset = (input.page - 1) * input.pageSize;

  const [rows] = await pool.query<MedicineRow[]>(
    `${baseSelectSql()}
    ${where}
    ORDER BY \`序号\` ASC
    LIMIT ? OFFSET ?`,
    [...params, input.pageSize, offset],
  );

  const [countRows] = await pool.query<RowDataPacket[]>(
    `SELECT COUNT(1) AS total FROM ${tableRef()} ${where}`,
    params,
  );

  return {
    items: rows.map(mapMedicineRow),
    total: Number(countRows[0]?.total ?? 0),
    page: input.page,
    pageSize: input.pageSize,
  };
}

export async function findMedicine(input: {
  drugCode?: string;
  approvalNo?: string;
}): Promise<MedicineItemRecord | null> {
  const drugCode = String(input.drugCode ?? '').trim();
  const approvalNo = String(input.approvalNo ?? '').trim();
  if (!drugCode && !approvalNo) {
    return null;
  }

  const where = drugCode ? '`药品编码` = ?' : '`批准文号` = ?';
  const value = drugCode || approvalNo;
  const [rows] = await getMysqlPool().query<MedicineRow[]>(
    `${baseSelectSql()} WHERE ${where} LIMIT 1`,
    [value],
  );

  return rows.length > 0 ? mapMedicineRow(rows[0]) : null;
}

async function queryCandidatesByApprovalNo(
  approvalNo: string,
  limit: number,
): Promise<ScanCandidateRecord[]> {
  const [rows] = await getMysqlPool().query<MedicineRow[]>(
    `${baseSelectSql()} WHERE \`批准文号\` = ? ORDER BY \`序号\` ASC LIMIT ?`,
    [approvalNo, limit],
  );

  return rows.map((row) => ({ ...mapMedicineRow(row), score: 0.98 }));
}

async function queryCandidatesByProductName(
  productName: string,
  limit: number,
): Promise<ScanCandidateRecord[]> {
  const like = `%${escapeLike(productName)}%`;
  const [rows] = await getMysqlPool().query<MedicineRow[]>(
    `${baseSelectSql()}
    WHERE \`产品名称\` LIKE ? ESCAPE '\\\\'
    ORDER BY CASE WHEN \`产品名称\` = ? THEN 0 ELSE 1 END, \`序号\` ASC
    LIMIT ?`,
    [like, productName, limit],
  );

  return rows.map((row) => {
    const item = mapMedicineRow(row);
    const exact = item.productName === productName;
    return { ...item, score: exact ? 0.9 : 0.82 };
  });
}

async function queryCandidatesByManufacturer(
  manufacturer: string,
  limit: number,
): Promise<ScanCandidateRecord[]> {
  const like = `%${escapeLike(manufacturer)}%`;
  const [rows] = await getMysqlPool().query<MedicineRow[]>(
    `${baseSelectSql()}
    WHERE \`生产单位\` LIKE ? ESCAPE '\\\\'
    ORDER BY CASE WHEN \`生产单位\` = ? THEN 0 ELSE 1 END, \`序号\` ASC
    LIMIT ?`,
    [like, manufacturer, limit],
  );

  return rows.map((row) => {
    const item = mapMedicineRow(row);
    const exact = item.manufacturer === manufacturer;
    return { ...item, score: exact ? 0.78 : 0.72 };
  });
}

export async function findMedicineCandidates(input: {
  approvalNo?: string;
  productName?: string;
  manufacturer?: string;
  limit?: number;
}): Promise<ScanCandidateRecord[]> {
  const limit = Math.max(1, Math.min(8, input.limit ?? 6));
  const merged = new Map<string, ScanCandidateRecord>();

  const addResults = (items: ScanCandidateRecord[]) => {
    for (const item of items) {
      const key = buildIdentityKey(item);
      const current = merged.get(key);
      if (!current || item.score > current.score) {
        merged.set(key, item);
      }
      if (merged.size >= limit) {
        break;
      }
    }
  };

  const approvalNo = String(input.approvalNo ?? '').trim();
  const productName = String(input.productName ?? '').trim();
  const manufacturer = String(input.manufacturer ?? '').trim();

  if (approvalNo) {
    addResults(await queryCandidatesByApprovalNo(approvalNo, limit));
  }
  if (merged.size < limit && productName) {
    addResults(await queryCandidatesByProductName(productName, limit));
  }
  if (merged.size < limit && manufacturer) {
    addResults(await queryCandidatesByManufacturer(manufacturer, limit));
  }

  return Array.from(merged.values()).slice(0, limit);
}

