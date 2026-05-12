import { HumanMessage } from '@langchain/core/messages';
import { ChatOpenAI } from '@langchain/openai';
import {
  ensureAiApiKey,
  env,
  resolveAiBaseUrl,
  resolveTextModel,
  resolveVisionModel,
} from '../config/env';

type ChatModel = Pick<ChatOpenAI, 'invoke'>;

let textModel: ChatModel | null = null;
let visionModel: ChatModel | null = null;

function createChatModel(input: {
  model: string;
  temperature: number;
}): ChatModel {
  return new ChatOpenAI({
    apiKey: ensureAiApiKey(),
    model: input.model,
    temperature: input.temperature,
    streamUsage: false,
    configuration: {
      baseURL: resolveAiBaseUrl(),
    },
  });
}

function getTextModel(): ChatModel {
  if (!textModel) {
    textModel = createChatModel({
      model: resolveTextModel(),
      temperature: env.ai.textTemperature,
    });
  }
  return textModel;
}

function getVisionModel(): ChatModel {
  if (!visionModel) {
    visionModel = createChatModel({
      model: resolveVisionModel(),
      temperature: env.ai.visionTemperature,
    });
  }
  return visionModel;
}

export function extractTextContent(content: unknown): string {
  if (typeof content === 'string') {
    return content.trim();
  }
  if (Array.isArray(content)) {
    return content
      .map((item) => {
        if (typeof item === 'string') {
          return item;
        }
        if (
          item &&
          typeof item === 'object' &&
          'text' in item &&
          typeof item.text === 'string'
        ) {
          return item.text;
        }
        return '';
      })
      .join('\n')
      .trim();
  }
  return '';
}

export function parseJsonObject<T extends Record<string, unknown>>(
  text: string,
): T | null {
  const raw = String(text || '').trim();
  if (!raw) {
    return null;
  }

  try {
    return JSON.parse(raw) as T;
  } catch (_) {
    const match = raw.match(/\{[\s\S]*\}/);
    if (!match) {
      return null;
    }
    try {
      return JSON.parse(match[0]) as T;
    } catch (_) {
      return null;
    }
  }
}

export async function invokeTextModel(
  model: ChatModel,
  prompt: string,
): Promise<string> {
  const response = await model.invoke([{ role: 'user', content: prompt }]);
  return extractTextContent(response.content);
}

export async function invokeVisionModel(
  model: ChatModel,
  input: {
    dataUrl: string;
    prompt: string;
  },
): Promise<string> {
  const response = await model.invoke([
    new HumanMessage({
      content: [
        { type: 'text', text: input.prompt },
        {
          type: 'image_url',
          image_url: { url: input.dataUrl },
        },
      ],
    }),
  ]);

  return extractTextContent(response.content);
}

export async function callTextModel(prompt: string): Promise<string> {
  return invokeTextModel(getTextModel(), prompt);
}

export async function callVisionModel(input: {
  dataUrl: string;
  prompt: string;
}): Promise<string> {
  return invokeVisionModel(getVisionModel(), input);
}
