import OpenAI from 'openai';
import {
  ensureDoubaoApiKey,
  env,
  resolveTextModel,
  resolveVisionModel,
} from '../config/env';

let client: OpenAI | null = null;

function getClient(): OpenAI {
  if (client) {
    return client;
  }

  client = new OpenAI({
    apiKey: ensureDoubaoApiKey(),
    baseURL: env.doubao.baseUrl,
  });

  return client;
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

export async function callTextModel(prompt: string): Promise<string> {
  const response = await getClient().chat.completions.create({
    model: resolveTextModel(),
    temperature: 0.3,
    messages: [{ role: 'user', content: prompt }],
  });

  return extractTextContent(response.choices?.[0]?.message?.content);
}

export async function callVisionModel(input: {
  dataUrl: string;
  prompt: string;
}): Promise<string> {
  const response = await getClient().chat.completions.create({
    model: resolveVisionModel(),
    temperature: 0.2,
    messages: [
      {
        role: 'user',
        content: [
          { type: 'text', text: input.prompt },
          {
            type: 'image_url',
            image_url: { url: input.dataUrl },
          },
        ],
      },
    ],
  });

  return extractTextContent(response.choices?.[0]?.message?.content);
}

