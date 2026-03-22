import { buildMedicineScanPrompt } from '../ai/prompts';
import { callVisionModel, parseJsonObject } from '../ai/doubao-client';
import { findMedicineCandidates } from '../db/medicine-repository';
import { expectRecord, readTrimmedString } from '../http/body';
import { toApiFailure } from '../http/errors';
import { ApiEnvelope, fail, success } from '../http/response';
import { MedicineScanPayload, ScanRecognitionFields } from '../types';

function stripDataUrl(base64: string): string {
  const idx = base64.indexOf('base64,');
  return idx >= 0 ? base64.slice(idx + 7) : base64;
}

function buildDataUrl(imageBase64: string, mimeType: string): string {
  return `data:${mimeType};base64,${stripDataUrl(imageBase64)}`;
}

function normalizeField(value: unknown): string {
  return typeof value === 'string' ? value.trim() : '';
}

function normalizeRecognition(
  parsed: Record<string, unknown> | null,
): ScanRecognitionFields {
  return {
    productName: normalizeField(parsed?.productName),
    approvalNo: normalizeField(parsed?.approvalNo),
    manufacturer: normalizeField(parsed?.manufacturer),
    dosageForm: normalizeField(parsed?.dosageForm),
    specification: normalizeField(parsed?.specification),
  };
}

export async function handleMedicineScan(
  body: unknown,
): Promise<ApiEnvelope<MedicineScanPayload>> {
  try {
    const data = expectRecord(body);
    const imageBase64 = readTrimmedString(data, 'imageBase64');
    const mimeType = readTrimmedString(data, 'mimeType', 'image/jpeg');

    if (!imageBase64) {
      return fail('imageBase64 不能为空');
    }

    const content = await callVisionModel({
      dataUrl: buildDataUrl(imageBase64, mimeType || 'image/jpeg'),
      prompt: buildMedicineScanPrompt(),
    });

    const recognized = normalizeRecognition(parseJsonObject(content));
    const candidates = await findMedicineCandidates({
      approvalNo: recognized.approvalNo,
      productName: recognized.productName,
      manufacturer: recognized.manufacturer,
      limit: 6,
    });

    return success({
      candidates,
      // 这里刻意保持为空，避免服务端引入额外图像处理依赖。
      // Flutter 侧已经有本地缩略图兜底逻辑。
      thumbBase64: '',
    });
  } catch (error) {
    console.error('medicine-scan failed:', error);
    return toApiFailure(error, '药品识别失败，请稍后重试');
  }
}

