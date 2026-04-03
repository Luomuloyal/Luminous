import mongoose, { Document, Schema } from 'mongoose';

export interface IUser extends Document {
  account?: string;
  username: string;
  email?: string;
  phone?: string;
  avatar?: string;
  birthday?: string;
  cityCode?: string;
  gender?: string;
  nickname?: string;
  profession?: string;
  provinceCode?: string;
  name?: string;
  type?: number;
  lock?: number;
  lastLoginTime?: number;
  passwordHash: string;
  createdAt: Date;
  updatedAt: Date;
}

const UserSchema: Schema = new Schema(
  {
    account: { type: String, default: '' },
    username: { type: String, required: true, unique: true },
    email: { type: String, sparse: true, unique: true },
    phone: { type: String, sparse: true, unique: true },
    avatar: { type: String, default: '' },
    birthday: { type: String, default: '' },
    cityCode: { type: String, default: '' },
    gender: { type: String, default: '' },
    nickname: { type: String, default: '' },
    profession: { type: String, default: '' },
    provinceCode: { type: String, default: '' },
    name: { type: String, default: '' },
    type: { type: Number, default: 0 },
    lock: { type: Number, default: 0 },
    lastLoginTime: { type: Number, default: 0 },
    passwordHash: { type: String, required: true },
  },
  {
    timestamps: true,
  }
);

export const User = mongoose.model<IUser>('User', UserSchema);
