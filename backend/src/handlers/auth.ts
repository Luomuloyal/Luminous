import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import nodemailer from 'nodemailer';
import { env } from '../config/env';
import { MyMedicine } from '../models/my-medicine';
import { Reminder } from '../models/reminder';
import { ScanRecord } from '../models/scan-record';
import { getRedisClient } from '../db/redis';
import { fail, success } from '../http/response';
import { IUser, User } from '../models/user';

type IdentifierType = 'email' | 'phone';
type LoginMode = 'password' | 'code';
type AuthCodeScene = 'register' | 'login';

interface VerificationCodePayload {
  channel: IdentifierType;
  target: string;
  scene: AuthCodeScene;
  code: string;
  createdAt: number;
}

const sendCodeCooldownSeconds = 60;
const emailRegExp = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const phoneRegExp = /^1[3-9]\d{9}$/;
const passwordRegExp = /^[A-Za-z0-9]{6,12}$/;
const birthdayRegExp = /^\d{4}-\d{2}-\d{2}$/;

function normalizeUsername(raw: unknown): string {
  return String(raw || '').trim();
}

function verifyUsernameFormat(username: string): string | null {
  if (!username) {
    return null;
  }
  if (username.length < 2 || username.length > 30) {
    return '用户名长度需为2-30个字符';
  }
  if (/\s/.test(username)) {
    return '用户名不能包含空格';
  }
  return null;
}

function hasOwnKey(data: Record<string, unknown>, key: string): boolean {
  return Object.prototype.hasOwnProperty.call(data, key);
}

function readProfileText(
  data: Record<string, unknown>,
  key: string,
  maxLength: number,
): string {
  const value = String(data[key] ?? '').trim();
  if (value.length <= maxLength) {
    return value;
  }
  return value.slice(0, maxLength);
}

function normalizeGender(raw: unknown): string | null {
  const normalized = String(raw ?? '').trim().toLowerCase();
  if (!normalized) {
    return '';
  }
  if (['male', 'm', 'man', '男'].includes(normalized)) {
    return 'male';
  }
  if (['female', 'f', 'woman', '女'].includes(normalized)) {
    return 'female';
  }
  if (['other', 'unknown', 'u', '未设置', '未知'].includes(normalized)) {
    return 'other';
  }
  return null;
}

function generateTokens(user: { _id: unknown; username: string }) {
  const accessToken = jwt.sign({ id: user._id, username: user.username }, env.jwtSecret, {
    expiresIn: '1d',
  });
  const refreshToken = jwt.sign({ id: user._id, username: user.username }, env.jwtRefreshSecret, {
    expiresIn: '14d',
  });
  return { accessToken, refreshToken };
}

function parseBody(body: unknown): Record<string, unknown> {
  if (!body || typeof body !== 'object') {
    return {};
  }
  return body as Record<string, unknown>;
}

function parseIdentifierType(raw: unknown): IdentifierType | null {
  const value = String(raw || '').trim().toLowerCase();
  if (value === 'email' || value === 'phone') {
    return value;
  }
  return null;
}

function parseLoginMode(raw: unknown): LoginMode | null {
  const value = String(raw || '').trim().toLowerCase();
  if (value === 'password' || value === 'code') {
    return value;
  }
  return null;
}

function resolveIdentifier(type: IdentifierType, body: Record<string, unknown>): string {
  if (type === 'email') {
    return String(body.email || body.identifier || '').trim().toLowerCase();
  }
  return String(body.phone || body.identifier || '').trim();
}

function buildIdentifierQuery(type: IdentifierType, identifier: string) {
  if (type === 'email') {
    return { $or: [{ email: identifier }, { username: identifier }] };
  }
  return { $or: [{ phone: identifier }, { username: identifier }] };
}

function buildVerificationCodeKey(target: string): string {
  return `auth:code:${target}`;
}

function buildSendCooldownKey(target: string): string {
  return `auth:code:cooldown:${target}`;
}

function generateVerificationCode(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

async function dispatchVerificationCode({
  channel,
  scene,
  target,
  code,
}: {
  channel: IdentifierType;
  scene: AuthCodeScene;
  target: string;
  code: string;
}): Promise<void> {
  const mode = env.authCode.deliveryMode.trim().toLowerCase();
  if (mode === 'log') {
    console.log(`[auth-code][${channel}][${scene}] target=${target} code=${code}`);
    return;
  }

  if (channel === 'email') {
    await dispatchEmailCode({ target, scene, code });
    return;
  }

  await dispatchPhoneCode({ target, scene, code });
}

async function dispatchEmailCode({
  target,
  scene,
  code,
}: {
  target: string;
  scene: AuthCodeScene;
  code: string;
}): Promise<void> {
  if (
    !env.authCode.email.host ||
    !env.authCode.email.user ||
    !env.authCode.email.pass ||
    !env.authCode.email.from
  ) {
    throw new Error('缺少邮箱验证码发送配置');
  }

  const transporter = nodemailer.createTransport({
    host: env.authCode.email.host,
    port: env.authCode.email.port,
    secure: env.authCode.email.secure,
    auth: {
      user: env.authCode.email.user,
      pass: env.authCode.email.pass,
    },
  });

  await transporter.sendMail({
    from: env.authCode.email.from,
    to: target,
    subject: scene === 'register' ? 'Luminous 注册验证码' : 'Luminous 登录验证码',
    html: `
      <div style="font-family: 'Segoe UI', Tahoma, Verdana, sans-serif; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
        <div style="font-size: 14px; color: #777;">Luminous 帐户</div>
        <h1 style="color: #2b579a; font-size: 36px; margin-top: 10px; font-weight: normal; font-style: italic;">验证码</h1>
        
        <p style="font-size: 15px; margin-top: 30px; line-height: 1.6;">
          请对 Luminous 帐户 <a href="mailto:${target}" style="color: #2b579a; text-decoration: none;">${target}</a> 使用以下${scene === 'register' ? '注册' : '登录'}验证码。
        </p>
        
        <p style="font-size: 18px; margin: 30px 0;">
          验证码: <strong style="font-size: 20px;">${code}</strong> 
          <span style="font-size: 14px; color: #777; margin-left: 10px;">(5分钟内有效)</span>
        </p>
        
        <p style="font-size: 15px; line-height: 1.6; color: #555;">
          如果你无法识别 Luminous 帐户 <a href="mailto:${target}" style="color: #2b579a; text-decoration: none;">${target}</a> 操作，请忽略此电子邮件。
        </p>
        
        <p style="font-size: 15px; margin-top: 40px; color: #333;">
          谢谢!<br>
          Luminous 团队
        </p>
        
        <hr style="border: none; border-top: 1px solid #eee; margin-top: 40px; margin-bottom: 20px;">
        
        <div style="font-size: 12px; color: #999;">
          <strong style="color: #2b579a;">隐私声明</strong><br><br>
          Luminous Corporation
        </div>
      </div>
    `,
  });
}

async function dispatchPhoneCode({
  target,
  scene,
  code,
}: {
  target: string;
  scene: AuthCodeScene;
  code: string;
}): Promise<void> {
  const webhookUrl = env.authCode.smsWebhookUrl;
  if (!webhookUrl) {
    throw new Error('缺少短信验证码发送配置');
  }

  const response = await fetch(webhookUrl, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      target,
      scene,
      code,
      ttlSeconds: env.authCode.ttlSeconds,
    }),
  });

  if (!response.ok) {
    throw new Error(`短信网关调用失败: ${response.status}`);
  }
}

function verifyIdentifierFormat(type: IdentifierType, identifier: string): string | null {
  if (!identifier) {
    return type === 'email' ? '邮箱不能为空' : '手机号不能为空';
  }

  if (type === 'email' && !emailRegExp.test(identifier)) {
    return '邮箱地址格式错误';
  }

  if (type === 'phone' && !phoneRegExp.test(identifier)) {
    return '手机号格式不正确';
  }

  return null;
}

function toSafeUser(user: IUser) {
  return {
    id: user._id.toString(),
    account: user.account || user.username,
    username: user.username,
    email: user.email || '',
    mobile: user.phone || '',
    phone: user.phone || '',
    avatar: user.avatar || '',
    birthday: user.birthday || '',
    cityCode: user.cityCode || '',
    gender: user.gender || '',
    nickname: user.nickname || '',
    profession: user.profession || '',
    provinceCode: user.provinceCode || '',
    name: user.name || '',
    type: user.type || 0,
  };
}

function maskName(name: string): string {
  if (!name) {
    return '';
  }
  if (name.length > 10) {
    return `${name.substring(0, 3)}****${name.substring(7)}`;
  }
  if (name.length > 6) {
    return `${name.substring(0, 2)}***${name.substring(name.length - 2)}`;
  }
  return name;
}

async function readVerificationCode(target: string): Promise<VerificationCodePayload | null> {
  const redis = getRedisClient();
  const key = buildVerificationCodeKey(target);
  const raw = await redis.get(key);
  if (!raw) {
    return null;
  }

  try {
    const payload = JSON.parse(raw) as VerificationCodePayload;
    if (!payload || typeof payload !== 'object') {
      return null;
    }
    return payload;
  } catch {
    return null;
  }
}

async function consumeVerificationCode(target: string): Promise<void> {
  const redis = getRedisClient();
  const key = buildVerificationCodeKey(target);
  await redis.del(key);
}

export async function handleSendCode(body: unknown) {
  const data = parseBody(body);
  const channel = parseIdentifierType(data.channel);
  const sceneRaw = String(data.scene || 'login').trim().toLowerCase();
  const scene = sceneRaw === 'register' || sceneRaw === 'login' ? sceneRaw : null;

  if (!channel) {
    return fail('channel 无效', 'INVALID_CHANNEL');
  }
  if (!scene) {
    return fail('scene 无效', 'INVALID_SCENE');
  }

  const target = channel === 'email'
    ? String(data.target || '').trim().toLowerCase()
    : String(data.target || '').trim();
  const identifierError = verifyIdentifierFormat(channel, target);
  if (identifierError != null) {
    return fail(identifierError, 'INVALID_TARGET');
  }

  const code = generateVerificationCode();
  const key = buildVerificationCodeKey(target);
  const cooldownKey = buildSendCooldownKey(target);
  const redis = getRedisClient();

  const cooldownSet = await redis.set(cooldownKey, Date.now().toString(), {
    EX: sendCodeCooldownSeconds,
    NX: true,
  });
  if (cooldownSet !== 'OK') {
    const remainSeconds = await redis.ttl(cooldownKey);
    const waitSeconds = remainSeconds > 0 ? remainSeconds : sendCodeCooldownSeconds;
    return fail(`发送过于频繁，请 ${waitSeconds} 秒后重试`, 'CODE_SEND_TOO_FREQUENT');
  }

  await redis.setEx(
    key,
    env.authCode.ttlSeconds,
    JSON.stringify({
      channel,
      target,
      scene,
      code,
      createdAt: Date.now(),
    } satisfies VerificationCodePayload),
  );

  try {
    await dispatchVerificationCode({
      channel,
      scene,
      target,
      code,
    });
  } catch (error) {
    await redis.del(key);
    await redis.del(cooldownKey);
    const message = String((error as { message?: string })?.message || '').trim();
    return fail(message || '验证码发送失败，请稍后重试', 'CODE_SEND_FAILED');
  }

  return success(
    {
      id: target,
      target,
      expiresInSeconds: env.authCode.ttlSeconds,
    },
    channel === 'email' ? '验证码已发送到邮箱，请注意查收' : '验证码已发送到手机，请注意查收',
  );
}

function verifyCodePayload({
  payload,
  code,
  scene,
  channel,
}: {
  payload: VerificationCodePayload | null;
  code: string;
  scene: AuthCodeScene;
  channel: IdentifierType;
}) {
  if (!code) {
    return fail('验证码不能为空', 'CODE_REQUIRED');
  }
  if (!payload) {
    return fail('验证码已过期，请重新获取', 'CODE_EXPIRED');
  }
  if (payload.channel !== channel || payload.scene !== scene) {
    return fail('验证码场景不匹配，请重新获取', 'CODE_INVALID');
  }
  if (payload.code !== code) {
    return fail('验证码错误', 'CODE_INVALID');
  }
  return null;
}

export async function handleRegister(body: unknown) {
  const data = parseBody(body);

  const identifierType = parseIdentifierType(data.identifierType);
  if (!identifierType) {
    return fail('identifierType 无效', 'INVALID_IDENTIFIER_TYPE');
  }

  const identifier = resolveIdentifier(identifierType, data);
  const identifierError = verifyIdentifierFormat(identifierType, identifier);
  if (identifierError != null) {
    return fail(identifierError, 'INVALID_IDENTIFIER');
  }

  const password = String(data.password || '');
  if (!passwordRegExp.test(password)) {
    return fail('密码需为6-12位字母或数字', 'PASSWORD_INVALID');
  }

  const requestedUsername = normalizeUsername(data.username);
  const usernameFormatError = verifyUsernameFormat(requestedUsername);
  if (usernameFormatError != null) {
    return fail(usernameFormatError, 'USERNAME_INVALID');
  }

  const username = requestedUsername || identifier;

  const code = String(data.code || '').trim();
  const codePayload = await readVerificationCode(identifier);
  const codeError = verifyCodePayload({
    payload: codePayload,
    code,
    scene: 'register',
    channel: identifierType,
  });
  if (codeError) {
    return codeError;
  }

  const existing = await User.findOne(buildIdentifierQuery(identifierType, identifier));
  if (existing) {
    return fail(identifierType === 'email' ? '邮箱已经注册' : '手机号已经注册', 'IDENTIFIER_EXISTS');
  }

  if (username !== identifier) {
    const usernameExists = await User.findOne({ username });
    if (usernameExists) {
      return fail('用户名已被占用', 'USERNAME_EXISTS');
    }
  }

  const salt = await bcrypt.genSalt(10);
  const passwordHash = await bcrypt.hash(password, salt);
  const profileName = requestedUsername || maskName(identifier);
  const user = new User({
    account: identifier,
    username,
    passwordHash,
    email: identifierType === 'email' ? identifier : undefined,
    phone: identifierType === 'phone' ? identifier : undefined,
    nickname: requestedUsername,
    type: identifierType === 'email' ? 2 : 3,
    name: profileName,
    lock: 0,
    lastLoginTime: Date.now(),
  });

  try {
    await user.save();
  } catch (error) {
    const message = String((error as { message?: string })?.message || '');
    if (message.includes('E11000')) {
      if (message.includes('username')) {
        return fail('用户名已被占用', 'USERNAME_EXISTS');
      }
      return fail(identifierType === 'email' ? '邮箱已经注册' : '手机号已经注册', 'IDENTIFIER_EXISTS');
    }
    throw error;
  }

  await consumeVerificationCode(identifier);
  const tokens = generateTokens(user);

  return success(
    {
      id: user._id.toString(),
      ...tokens,
      user: toSafeUser(user),
    },
    '注册成功',
  );
}

export async function handleLogin(body: unknown) {
  const data = parseBody(body);

  const identifierType = parseIdentifierType(data.identifierType);
  if (!identifierType) {
    return fail('identifierType 无效', 'INVALID_IDENTIFIER_TYPE');
  }

  const loginMode = parseLoginMode(data.loginMode);
  if (!loginMode) {
    return fail('loginMode 无效', 'INVALID_LOGIN_MODE');
  }

  const identifier = resolveIdentifier(identifierType, data);
  const identifierError = verifyIdentifierFormat(identifierType, identifier);
  if (identifierError != null) {
    return fail(identifierError, 'INVALID_IDENTIFIER');
  }

  if (loginMode === 'password') {
    const password = String(data.password || '');
    if (!password) {
      return fail('密码不能为空', 'PASSWORD_REQUIRED');
    }

    const user = await User.findOne(buildIdentifierQuery(identifierType, identifier));
    if (!user) {
      return fail('账号或密码错误', 'LOGIN_FAILED');
    }

    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) {
      return fail('账号或密码错误', 'LOGIN_FAILED');
    }

    if (user.lock === 1) {
      return fail('用户已被锁定，请联系管理员', 'ACCOUNT_LOCKED');
    }

    user.lastLoginTime = Date.now();
    await user.save();
    const tokens = generateTokens(user);

    return success(
      {
        ...tokens,
        user: toSafeUser(user),
      },
      '登录成功',
    );
  }

  const code = String(data.code || '').trim();
  const payload = await readVerificationCode(identifier);
  const codeError = verifyCodePayload({
    payload,
    code,
    scene: 'login',
    channel: identifierType,
  });
  if (codeError) {
    return codeError;
  }

  const user = await User.findOne(buildIdentifierQuery(identifierType, identifier));
  if (!user) {
    return fail('该账号尚未注册，是否前往注册？', 'NOT_REGISTERED');
  }

  if (user.lock === 1) {
    return fail('用户已被锁定，请联系管理员', 'ACCOUNT_LOCKED');
  }

  await consumeVerificationCode(identifier);

  user.lastLoginTime = Date.now();
  await user.save();
  const tokens = generateTokens(user);

  return success(
    {
      ...tokens,
      user: toSafeUser(user),
    },
    '登录成功',
  );
}

export async function handleGetUserProfile(body: unknown) {
  const data = parseBody(body);
  const userId = String(data.userId || data.id || '').trim();
  if (!userId) {
    return fail('userId 不能为空', 'USER_ID_REQUIRED');
  }

  try {
    const user = await User.findById(userId);
    if (!user) {
      return fail('用户不存在', 'USER_NOT_FOUND');
    }
    return success(toSafeUser(user));
  } catch (error) {
    console.error('get-user-profile failed:', error);
    return fail('查询个人资料失败，请稍后重试', 'PROFILE_GET_FAILED');
  }
}

export async function handleUpdateUserProfile(body: unknown) {
  const data = parseBody(body);
  const userId = String(data.userId || data.id || '').trim();
  if (!userId) {
    return fail('userId 不能为空', 'USER_ID_REQUIRED');
  }

  const gender = normalizeGender(data.gender);
  if (gender == null) {
    return fail('gender 无效', 'PROFILE_INVALID');
  }

  const birthday = readProfileText(data, 'birthday', 10);
  if (birthday && !birthdayRegExp.test(birthday)) {
    return fail('birthday 格式错误，应为 YYYY-MM-DD', 'PROFILE_INVALID');
  }

  const nickname = readProfileText(data, 'nickname', 30);
  const avatar = readProfileText(data, 'avatar', 200000);
  const profession = readProfileText(data, 'profession', 60);
  const provinceCode = readProfileText(data, 'provinceCode', 20);
  const cityCode = readProfileText(data, 'cityCode', 20);

  try {
    const user = await User.findById(userId);
    if (!user) {
      return fail('用户不存在', 'USER_NOT_FOUND');
    }

    if (hasOwnKey(data, 'nickname')) {
      user.nickname = nickname;
      user.name = nickname;
    }
    if (hasOwnKey(data, 'avatar')) {
      user.avatar = avatar;
    }
    if (hasOwnKey(data, 'gender')) {
      user.gender = gender;
    }
    if (hasOwnKey(data, 'birthday')) {
      user.birthday = birthday;
    }
    if (hasOwnKey(data, 'profession')) {
      user.profession = profession;
    }
    if (hasOwnKey(data, 'provinceCode')) {
      user.provinceCode = provinceCode;
    }
    if (hasOwnKey(data, 'cityCode')) {
      user.cityCode = cityCode;
    }

    await user.save();
    return success(toSafeUser(user), '个人资料已更新');
  } catch (error) {
    console.error('update-user-profile failed:', error);
    return fail('保存个人资料失败，请稍后重试', 'PROFILE_UPDATE_FAILED');
  }
}

export async function handleDeleteAccount(body: unknown) {
  const data = parseBody(body);
  const userId = String(data.userId || data.id || '').trim();
  if (!userId) {
    return fail('userId 不能为空', 'USER_ID_REQUIRED');
  }

  try {
    const user = await User.findById(userId);
    if (!user) {
      return fail('用户不存在', 'USER_NOT_FOUND');
    }

    await Promise.all([
      Reminder.deleteMany({ userId }),
      MyMedicine.deleteMany({ userId }),
      ScanRecord.deleteMany({ userId }),
      User.deleteOne({ _id: userId }),
    ]);

    return success(
      {
        id: userId,
      },
      '账户已注销',
    );
  } catch (error) {
    console.error('delete-account failed:', error);
    return fail('注销账户失败，请稍后重试', 'ACCOUNT_DELETE_FAILED');
  }
}

export async function handleRefreshToken(body: unknown) {
  const data = parseBody(body);
  const refreshToken = String(data.refreshToken || '').trim();
  if (!refreshToken) {
    return fail('缺少 Refresh Token', 'MISSING_REFRESH_TOKEN');
  }

  try {
    const decoded = jwt.verify(refreshToken, env.jwtRefreshSecret) as {
      id: string;
      username: string;
    };
    const tokens = generateTokens({ _id: decoded.id, username: decoded.username });

    return success({
      ...tokens,
    });
  } catch {
    return fail('Refresh Token 无效或已过期', 'REFRESH_TOKEN_INVALID');
  }
}
