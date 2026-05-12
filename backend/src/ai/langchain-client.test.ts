import assert from 'node:assert/strict';
import test from 'node:test';

import {
  ensureAiApiKey,
  resolveAiBaseUrl,
  resolveTextModel,
  resolveVisionModel,
} from '../config/env';
import {
  extractTextContent,
  invokeTextModel,
  invokeVisionModel,
  parseJsonObject,
} from './langchain-client';

type AiConfigSnapshot = NonNullable<Parameters<typeof resolveTextModel>[0]>;
type TextModel = Parameters<typeof invokeTextModel>[0];
type VisionModel = Parameters<typeof invokeVisionModel>[0];

function buildConfig(
  overrides: {
    ai?: Partial<AiConfigSnapshot['ai']>;
    doubao?: Partial<AiConfigSnapshot['doubao']>;
  } = {},
): AiConfigSnapshot {
  return {
    ai: {
      provider: 'openai-compatible',
      apiKey: '',
      baseUrl: '',
      textModel: '',
      visionModel: '',
      textTemperature: 0.3,
      visionTemperature: 0.2,
      hasGenericConfig: false,
      ...overrides.ai,
    },
    doubao: {
      apiKey: '',
      baseUrl: 'https://ark.cn-beijing.volces.com/api/v3',
      visionEndpointId: '',
      visionModelId: '',
      textEndpointId: '',
      textModelId: '',
      ...overrides.doubao,
    },
  };
}

test('generic AI config takes priority over legacy Doubao config', () => {
  const config = buildConfig({
    ai: {
      apiKey: 'ai-key',
      baseUrl: 'https://ai.example.com/v1',
      textModel: 'text-model',
      visionModel: 'vision-model',
      hasGenericConfig: true,
    },
    doubao: {
      apiKey: 'doubao-key',
      baseUrl: 'https://ark.example.com/api/v3',
      textEndpointId: 'doubao-text',
      visionEndpointId: 'doubao-vision',
    },
  });

  assert.equal(ensureAiApiKey(config), 'ai-key');
  assert.equal(resolveAiBaseUrl(config), 'https://ai.example.com/v1');
  assert.equal(resolveTextModel(config), 'text-model');
  assert.equal(resolveVisionModel(config), 'vision-model');
});

test('legacy Doubao config is used only when generic AI config is empty', () => {
  const config = buildConfig({
    doubao: {
      apiKey: 'doubao-key',
      baseUrl: 'https://ark.example.com/api/v3',
      textEndpointId: 'doubao-text',
      visionEndpointId: 'doubao-vision',
    },
  });

  assert.equal(ensureAiApiKey(config), 'doubao-key');
  assert.equal(resolveAiBaseUrl(config), 'https://ark.example.com/api/v3');
  assert.equal(resolveTextModel(config), 'doubao-text');
  assert.equal(resolveVisionModel(config), 'doubao-vision');
});

test('partial generic AI config does not mix with legacy Doubao values', () => {
  const config = buildConfig({
    ai: {
      apiKey: 'ai-key',
      hasGenericConfig: true,
    },
    doubao: {
      baseUrl: 'https://ark.example.com/api/v3',
      textEndpointId: 'doubao-text',
      visionEndpointId: 'doubao-vision',
    },
  });

  assert.throws(() => resolveAiBaseUrl(config), /AI_BASE_URL/);
  assert.throws(() => resolveTextModel(config), /AI_TEXT_MODEL/);
  assert.throws(() => resolveVisionModel(config), /AI_VISION_MODEL/);
});

test('invokeTextModel forwards a single user message and extracts text', async () => {
  const calls: unknown[] = [];
  const model = {
    invoke: async (input: unknown) => {
      calls.push(input);
      return { content: '  generated text  ' };
    },
  } as unknown as TextModel;

  const result = await invokeTextModel(model, 'detail prompt');

  assert.equal(result, 'generated text');
  assert.deepEqual(calls, [[{ role: 'user', content: 'detail prompt' }]]);
});

test('invokeVisionModel forwards prompt and image data URL', async () => {
  let capturedInput: unknown;
  const model = {
    invoke: async (input: unknown) => {
      capturedInput = input;
      return { content: [{ type: 'text', text: '  vision text  ' }] };
    },
  } as unknown as VisionModel;

  const result = await invokeVisionModel(model, {
    prompt: 'scan prompt',
    dataUrl: 'data:image/png;base64,abc',
  });

  assert.equal(result, 'vision text');
  assert.ok(Array.isArray(capturedInput));
  const [message] = capturedInput as Array<{ content: unknown }>;
  assert.deepEqual(message.content, [
    { type: 'text', text: 'scan prompt' },
    {
      type: 'image_url',
      image_url: { url: 'data:image/png;base64,abc' },
    },
  ]);
});

test('extractTextContent and parseJsonObject keep compatibility with previous output parsing', () => {
  assert.equal(
    extractTextContent([
      { type: 'text', text: ' first ' },
      { type: 'text', text: 'second' },
    ]),
    'first \nsecond',
  );
  assert.deepEqual(parseJsonObject('```json\n{"productName":"药品"}\n```'), {
    productName: '药品',
  });
  assert.equal(parseJsonObject('no json here'), null);
});
