import { ApiProperty } from '@nestjs/swagger';
import { Column, Entity, JoinColumn, ManyToOne, PrimaryColumn } from 'typeorm';
import { User } from '../../auth/entities/user.entity';

@Entity({ name: 'account' })
export class Account {
  @ApiProperty({ example: 'acc-1' })
  @PrimaryColumn('varchar')
  id: string;

  @ApiProperty({ example: 'savings', enum: ['savings', 'checking'] })
  @Column('varchar')
  type: string;

  @ApiProperty({ example: 'Savings Account' })
  @Column('varchar')
  displayName: string;

  @ApiProperty({ example: '****1234' })
  @Column('varchar')
  maskedNumber: string;

  @ApiProperty({ example: 1500.5 })
  @Column({ type: 'double precision' })
  availableBalance: number;

  @Column('int', { nullable: true, select: false })
  userCode?: number;

  @ManyToOne(() => User, { onDelete: 'CASCADE', nullable: true })
  @JoinColumn({ name: 'userCode' })
  user?: User;
}
