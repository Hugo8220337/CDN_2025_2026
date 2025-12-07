import mongoose, { Schema, Document } from 'mongoose';

export interface ITicket extends Document {
  eventId: string;
  status: 'WAITING' | 'PROCESSED';
  createdAt: Date;
}

const TicketSchema: Schema = new Schema(
  {
    eventId: { type: String, required: true },
    status: { 
      type: String, 
      enum: ['WAITING', 'PROCESSED'], 
      default: 'WAITING' 
    }
  }, 
  { timestamps: true } // Cria createdAt e updatedAt automagicamente
);

TicketSchema.index({ eventId: 1, createdAt: 1 });

export default mongoose.model<ITicket>('Ticket', TicketSchema);