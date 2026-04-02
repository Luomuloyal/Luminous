import mongoose, { Document, Schema } from 'mongoose';

export interface IReminder extends Document {
  userId: string;
  time: string;
  drugCode: string;
  approvalNo: string;
  productName: string;
  subtitle: string;
  enabled: boolean;
  repeatRule: string;
  method: string;
  startDate: string;
  endDate: string;
  createdAt: number;
  updatedAt: number;
}

const ReminderSchema = new Schema<IReminder>({
  userId: { type: String, required: true, index: true },
  time: { type: String, required: true },
  drugCode: { type: String, default: '' },
  approvalNo: { type: String, default: '' },
  productName: { type: String, required: true },
  subtitle: { type: String, default: '' },
  enabled: { type: Boolean, default: true },
  repeatRule: { type: String, default: 'daily' },
  method: { type: String, default: 'notification' },
  startDate: { type: String, default: '' },
  endDate: { type: String, default: '' },
  createdAt: { type: Number, default: () => Date.now() },
  updatedAt: { type: Number, default: () => Date.now() },
});

ReminderSchema.index({ userId: 1, time: 1 });

export const Reminder = mongoose.model<IReminder>('Reminder', ReminderSchema);