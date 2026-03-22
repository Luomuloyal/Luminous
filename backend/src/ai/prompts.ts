import { MedicineItemRecord, MedicineRefInput } from '../types';

function medicineSummary(item: MedicineItemRecord): string {
  return [
    `产品名称: ${item.productName}`,
    `剂型: ${item.dosageForm}`,
    `规格: ${item.specification}`,
    `生产单位: ${item.manufacturer}`,
    `上市许可持有人: ${item.marketingAuthorizationHolder}`,
    `批准文号: ${item.approvalNo}`,
    `药品编码: ${item.drugCode}`,
  ].join('\n');
}

export function buildMedicineScanPrompt(): string {
  return [
    '你是一名药品包装识别助手。请读取图片中的药品包装信息，只输出一个 JSON 对象，不要输出任何解释文字。',
    '',
    'JSON 字段固定为：',
    '{',
    '  "productName": "",',
    '  "approvalNo": "",',
    '  "manufacturer": "",',
    '  "dosageForm": "",',
    '  "specification": ""',
    '}',
    '',
    '要求：',
    '1. 字段不存在时返回空字符串',
    '2. 不要补充未看见的信息',
    '3. 不要输出 markdown 代码块',
  ].join('\n');
}

export function buildMedicineAiDetailPrompt(item: MedicineItemRecord): string {
  return [
    '你是一名药品说明书整理助手，请根据以下基础信息补充中文说明。',
    medicineSummary(item),
    '请重点说明：成分、适应症、常见用法用量提示、常见不良反应、禁忌、注意事项、特殊人群提示。',
    '输出纯文本，不要输出 markdown 代码块。',
    '如果信息不确定，请明确写“建议以药品说明书或医生指导为准”，不要伪造来源。',
  ].join('\n');
}

function inputSummary(input: MedicineRefInput): string {
  return JSON.stringify(
    {
      drugCode: String(input.drugCode ?? '').trim(),
      approvalNo: String(input.approvalNo ?? '').trim(),
      productName: String(input.productName ?? '').trim(),
    },
    null,
    2,
  );
}

export function buildMedicineSafetyPrompt(input: {
  mode: 'single' | 'pair';
  medicines: Array<{ raw: MedicineRefInput; detail: MedicineItemRecord | null }>;
}): string {
  if (input.mode === 'pair') {
    const [a, b] = input.medicines;
    return [
      '你是一名联合用药风险提示助手，请评估以下两种药物是否存在相互作用，并给出中文建议。',
      '回答重点：是否存在相互作用、可能风险、联用建议、何时需要咨询医生或药师。',
      '',
      `药品A(前端传入): ${inputSummary(a.raw)}`,
      a.detail ? `药品A(数据库补充):\n${medicineSummary(a.detail)}` : '药品A(数据库补充): 未命中数据库',
      '',
      `药品B(前端传入): ${inputSummary(b.raw)}`,
      b.detail ? `药品B(数据库补充):\n${medicineSummary(b.detail)}` : '药品B(数据库补充): 未命中数据库',
      '',
      '输出纯文本，不要输出 markdown 代码块。',
      '不要替代医生诊断；如果风险不明确，请明确提示用户咨询医生或药师。',
    ].join('\n');
  }

  const [single] = input.medicines;
  return [
    '你是一名用药建议助手，请根据以下药物信息返回中文说明。',
    '回答重点：常见用途、禁忌/慎用人群、注意事项、何时需要咨询医生或药师。',
    '',
    `药品(前端传入): ${inputSummary(single.raw)}`,
    single.detail
        ? `药品(数据库补充):\n${medicineSummary(single.detail)}`
        : '药品(数据库补充): 未命中数据库',
    '',
    '输出纯文本，不要输出 markdown 代码块。',
    '不要替代医生诊断；如果信息不充分，请明确提醒以说明书和医生建议为准。',
  ].join('\n');
}

