import mongoose, { Document, Schema } from 'mongoose';

export interface IUser extends Document {
  username: string;
  email?: string;
  phone?: string;
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
    username: { type: String, required: true, unique: true },
    email: { type: String, sparse: true, unique: true },
    phone: { type: String, sparse: true, unique: true },
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
