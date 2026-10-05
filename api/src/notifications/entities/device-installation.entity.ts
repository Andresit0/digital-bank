import { ApiProperty } from '@nestjs/swagger';
import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
  Unique,
  UpdateDateColumn,
} from 'typeorm';
import { User } from '../../auth/entities/user.entity';

@Entity({ name: 'device_installation' })
@Unique('UQ_device_installation_user_token', ['userCode', 'token'])
export class DeviceInstallation {
  @ApiProperty({ example: 'uuid' })
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('int')
  userCode: number;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userCode' })
  user?: User;

  @ApiProperty({ example: 'fcm-registration-token' })
  @Column('varchar')
  token: string;

  @ApiProperty({ example: 'android' })
  @Column('varchar', { default: 'android' })
  platform: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
