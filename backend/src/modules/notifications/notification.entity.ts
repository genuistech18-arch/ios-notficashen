import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Client } from '../clients/client.entity';

export enum DeliveryStatus {
  SENT = 'sent',
  FAILED = 'failed',
  NO_TOKEN = 'no_token',
}

@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @ManyToOne(() => Client, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: Client;

  @Column({ name: 'user_id' })
  userId: string;

  @Column({ type: 'text' })
  message: string;

  @Column({ name: 'is_read', default: false })
  isRead: boolean;

  @CreateDateColumn({ name: 'sent_at' })
  sentAt: Date;

  @Column({ name: 'read_at', type: 'timestamptz', nullable: true })
  readAt: Date | null;

  @Column({
    name: 'delivery_status',
    type: 'enum',
    enum: DeliveryStatus,
  })
  deliveryStatus: DeliveryStatus;
}
