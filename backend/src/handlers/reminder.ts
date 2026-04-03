import { isValidObjectId } from 'mongoose';
import { expectRecord, readTrimmedString } from '../http/body';
import { toApiFailure } from '../http/errors';
import { ApiEnvelope, fail, success } from '../http/response';
import { Reminder } from '../models/reminder';
import {
  ReminderListPayload,
  ReminderPlanRecord,
  TodayReminderItemRecord,
  TodayRemindersPayload,
} from '../types';

type ReminderMedicineRefLike = {
  drugCode: string;
  approvalNo: string;
  productName: string;
};

type ReminderDocLike = {
  _id: unknown;
  userId?: string;
  time?: string;
  drugCode?: string;
  approvalNo?: string;
  productName?: string;
  medicines?: unknown;
  dosage?: string;
  subtitle?: string;
  enabled?: boolean;
  repeatRule?: string;
  method?: string;
  startDate?: string;
  endDate?: string;
};

const timeRegExp = /^\d{2}:\d{2}$/;
const dateRegExp = /^\d{4}-\d{2}-\d{2}$/;

function readBooleanLoose(
  data: Record<string, unknown>,
  key: string,
  fallback: boolean,
): boolean {
  const value = data[key];
  if (typeof value === 'boolean') {
    return value;
  }
  if (typeof value === 'number') {
    return value !== 0;
  }
  if (typeof value === 'string') {
    const normalized = value.trim().toLowerCase();
    if (['1', 'true', 'yes', 'on'].includes(normalized)) {
      return true;
    }
    if (['0', 'false', 'no', 'off'].includes(normalized)) {
      return false;
    }
  }
  return fallback;
}

function isValidTime(value: string): boolean {
  if (!timeRegExp.test(value)) {
    return false;
  }
  const hour = Number(value.slice(0, 2));
  const minute = Number(value.slice(3, 5));
  return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
}

function resolveDate(raw: string): string {
  if (raw) {
    return raw;
  }
  return new Date().toISOString().slice(0, 10);
}

function toTrimmedString(value: unknown): string {
  return String(value ?? '').trim();
}

function normalizeMedicineRefs(raw: unknown): ReminderMedicineRefLike[] {
  if (!Array.isArray(raw)) {
    return [];
  }

  const normalized: ReminderMedicineRefLike[] = [];
  const dedupe = new Set<string>();
  for (const item of raw) {
    if (!item || typeof item !== 'object') {
      continue;
    }
    const record = item as Record<string, unknown>;
    const productName = toTrimmedString(record.productName);
    if (!productName) {
      continue;
    }
    const drugCode = toTrimmedString(record.drugCode);
    const approvalNo = toTrimmedString(record.approvalNo);
    const key = `${drugCode}|${approvalNo}|${productName}`;
    if (dedupe.has(key)) {
      continue;
    }
    dedupe.add(key);
    normalized.push({ drugCode, approvalNo, productName });
  }
  return normalized;
}

function deriveMedicinesFromLegacy(
  drugCode: string,
  approvalNo: string,
  productName: string,
): ReminderMedicineRefLike[] {
  const name = productName.trim();
  if (!name) {
    return [];
  }
  return [
    {
      drugCode: drugCode.trim(),
      approvalNo: approvalNo.trim(),
      productName: name,
    },
  ];
}

function composeProductName(
  medicines: ReminderMedicineRefLike[],
  fallback: string,
): string {
  const names = medicines
    .map(item => item.productName.trim())
    .filter(Boolean);
  const uniqueNames = [...new Set(names)];
  if (uniqueNames.length > 0) {
    return uniqueNames.join('、');
  }
  return fallback.trim();
}

function normalizeMedicinesFromDoc(doc: ReminderDocLike): ReminderMedicineRefLike[] {
  const medicines = normalizeMedicineRefs(doc.medicines);
  if (medicines.length > 0) {
    return medicines;
  }
  return deriveMedicinesFromLegacy(
    String(doc.drugCode ?? '').trim(),
    String(doc.approvalNo ?? '').trim(),
    String(doc.productName ?? '').trim(),
  );
}

function pickPrimaryIdentity(
  medicines: ReminderMedicineRefLike[],
  fallbackDrugCode: string,
  fallbackApprovalNo: string,
): { drugCode: string; approvalNo: string } {
  let primary: ReminderMedicineRefLike | null = null;
  for (const item of medicines) {
    if (item.drugCode.trim() || item.approvalNo.trim()) {
      primary = item;
      break;
    }
  }
  primary ??= medicines.length > 0
    ? medicines[0]
    : {
        drugCode: fallbackDrugCode,
        approvalNo: fallbackApprovalNo,
        productName: '',
      };

  return {
    drugCode: primary.drugCode.trim().length > 0
        ? primary.drugCode.trim()
        : fallbackDrugCode,
    approvalNo: primary.approvalNo.trim().length > 0
        ? primary.approvalNo.trim()
        : fallbackApprovalNo,
  };
}

function isPlanActiveOnDate(doc: ReminderDocLike, date: string): boolean {
  const startDate = String(doc.startDate ?? '').trim();
  const endDate = String(doc.endDate ?? '').trim();
  if (startDate && date < startDate) {
    return false;
  }
  if (endDate && date > endDate) {
    return false;
  }
  return true;
}

function toPlanRecord(doc: ReminderDocLike): ReminderPlanRecord {
  const medicines = normalizeMedicinesFromDoc(doc);
  const legacyDrugCode = String(doc.drugCode ?? '').trim();
  const legacyApprovalNo = String(doc.approvalNo ?? '').trim();
  const primaryIdentity = pickPrimaryIdentity(
    medicines,
    legacyDrugCode,
    legacyApprovalNo,
  );
  const productName = composeProductName(
    medicines,
    String(doc.productName ?? '').trim(),
  );
  return {
    id: String(doc._id ?? '').trim(),
    userId: String(doc.userId ?? '').trim(),
    time: String(doc.time ?? '').trim(),
    drugCode: primaryIdentity.drugCode,
    approvalNo: primaryIdentity.approvalNo,
    productName,
    medicines,
    dosage: String(doc.dosage ?? '').trim(),
    subtitle: String(doc.subtitle ?? '').trim(),
    enabled: doc.enabled !== false,
    repeatRule: String(doc.repeatRule ?? 'daily').trim() || 'daily',
    method: String(doc.method ?? 'notification').trim() || 'notification',
    startDate: String(doc.startDate ?? '').trim(),
    endDate: String(doc.endDate ?? '').trim(),
  };
}

function toTodayItem(doc: ReminderDocLike): TodayReminderItemRecord {
  const plan = toPlanRecord(doc);
  return {
    id: String(doc._id ?? '').trim(),
    time: String(doc.time ?? '').trim(),
    title: plan.productName || '用药提醒',
    dosage: String(doc.dosage ?? '').trim(),
    subtitle: String(doc.subtitle ?? '').trim(),
    done: false,
  };
}

export async function handleReminderUpsert(
  body: unknown,
): Promise<ApiEnvelope<ReminderPlanRecord>> {
  try {
    const data = expectRecord(body);
    const userId = readTrimmedString(data, 'userId');
    const id = readTrimmedString(data, 'id');
    const time = readTrimmedString(data, 'time');
    const legacyProductName = readTrimmedString(data, 'productName');
    const legacyDrugCode = readTrimmedString(data, 'drugCode');
    const legacyApprovalNo = readTrimmedString(data, 'approvalNo');
    const medicinesFromBody = normalizeMedicineRefs(data['medicines']);
    const medicines = medicinesFromBody.length > 0
        ? medicinesFromBody
        : deriveMedicinesFromLegacy(
            legacyDrugCode,
            legacyApprovalNo,
            legacyProductName,
          );
    const productName = composeProductName(medicines, legacyProductName);
    const primaryIdentity = pickPrimaryIdentity(
      medicines,
      legacyDrugCode,
      legacyApprovalNo,
    );

    if (!userId) {
      return fail('userId 不能为空');
    }
    if (!time || !isValidTime(time)) {
      return fail('time 格式错误，应为 HH:mm');
    }
    if (!productName) {
      return fail('productName 不能为空');
    }

    const drugCode = primaryIdentity.drugCode;
    const approvalNo = primaryIdentity.approvalNo;
    const dosage = readTrimmedString(data, 'dosage');
    const subtitle = readTrimmedString(data, 'subtitle');
    const enabled = readBooleanLoose(data, 'enabled', true);
    const repeatRule = readTrimmedString(data, 'repeatRule', 'daily') || 'daily';
    const method =
      readTrimmedString(data, 'method', 'notification') || 'notification';
    const startDate = readTrimmedString(data, 'startDate');
    const endDate = readTrimmedString(data, 'endDate');

    if (startDate && !dateRegExp.test(startDate)) {
      return fail('startDate 格式错误，应为 YYYY-MM-DD');
    }
    if (endDate && !dateRegExp.test(endDate)) {
      return fail('endDate 格式错误，应为 YYYY-MM-DD');
    }
    if (startDate && endDate && startDate > endDate) {
      return fail('startDate 不能晚于 endDate');
    }

    const now = Date.now();

    if (id) {
      if (!isValidObjectId(id)) {
        return fail('id 格式错误');
      }

      const existing = await Reminder.findOne({ _id: id, userId }).lean();
      if (!existing) {
        return fail('提醒不存在');
      }

      await Reminder.updateOne(
        { _id: id, userId },
        {
          $set: {
            time,
            drugCode,
            approvalNo,
            productName,
            medicines,
            dosage,
            subtitle,
            enabled,
            repeatRule,
            method,
            startDate,
            endDate,
            updatedAt: now,
          },
        },
      );

      return success(
        toPlanRecord({
          ...existing,
          time,
          drugCode,
          approvalNo,
          productName,
          medicines,
          dosage,
          subtitle,
          enabled,
          repeatRule,
          method,
          startDate,
          endDate,
        }),
      );
    }

    const created = await Reminder.create({
      userId,
      time,
      drugCode,
      approvalNo,
      productName,
      medicines,
      dosage,
      subtitle,
      enabled,
      repeatRule,
      method,
      startDate,
      endDate,
      createdAt: now,
      updatedAt: now,
    });

    return success(toPlanRecord(created.toObject()));
  } catch (error) {
    console.error('reminder-upsert failed:', error);
    return toApiFailure(error, '保存提醒失败，请稍后重试');
  }
}

export async function handleReminderDelete(
  body: unknown,
): Promise<ApiEnvelope<boolean>> {
  try {
    const data = expectRecord(body);
    const userId = readTrimmedString(data, 'userId');
    const id = readTrimmedString(data, 'id');

    if (!userId) {
      return fail('userId 不能为空');
    }
    if (!id) {
      return fail('id 不能为空');
    }
    if (!isValidObjectId(id)) {
      return fail('id 格式错误');
    }

    const result = await Reminder.deleteOne({ _id: id, userId });
    return success(result.deletedCount === 1);
  } catch (error) {
    console.error('reminder-delete failed:', error);
    return toApiFailure(error, '删除提醒失败，请稍后重试');
  }
}

export async function handleReminderList(
  body: unknown,
): Promise<ApiEnvelope<ReminderListPayload>> {
  try {
    const data = expectRecord(body);
    const userId = readTrimmedString(data, 'userId');
    if (!userId) {
      return fail('userId 不能为空');
    }

    const rows = await Reminder.find({ userId })
      .sort({ time: 1, createdAt: 1 })
      .lean();

    return success({ items: rows.map(item => toPlanRecord(item)) });
  } catch (error) {
    console.error('reminder-list failed:', error);
    return toApiFailure(error, '查询提醒列表失败，请稍后重试');
  }
}

export async function handleTodayReminders(
  body: unknown,
): Promise<ApiEnvelope<TodayRemindersPayload>> {
  try {
    const data = expectRecord(body);
    const dateInput = readTrimmedString(data, 'date');
    if (dateInput && !dateRegExp.test(dateInput)) {
      return fail('date 格式错误，应为 YYYY-MM-DD');
    }

    const date = resolveDate(dateInput);
    const userId = readTrimmedString(data, 'userId');
    if (!userId) {
      return success({ date, items: [] });
    }

    const rows = await Reminder.find({
      userId,
      enabled: { $ne: false },
    })
      .sort({ time: 1, createdAt: 1 })
      .lean();

    return success({
      date,
      items: rows.filter(item => isPlanActiveOnDate(item, date)).map(item => toTodayItem(item)),
    });
  } catch (error) {
    console.error('today-reminders failed:', error);
    return toApiFailure(error, '查询今日提醒失败，请稍后重试');
  }
}
