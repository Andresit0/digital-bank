import { ApiProperty } from '@nestjs/swagger';
import { Column, Entity, JoinColumn, ManyToOne, PrimaryColumn } from 'typeorm';
import { Account } from '../../accounts/entities/account.entity';

@Entity({ name: 'movement' })
export class Movement {
  @ApiProperty({ example: 'mov-1' })
  @PrimaryColumn('varchar')
  id: string;

  @ApiProperty({ example: 'acc-1' })
  @Column('varchar')
  accountId: string;

  @ApiProperty({ example: 'credit', enum: ['credit', 'debit'] })
  @Column('varchar')
  type: string;

  @ApiProperty({ example: 500.0 })
  @Column({ type: 'double precision' })
  amount: number;

  @ApiProperty({ example: 'USD' })
  @Column('varchar')
  currency: string;

  @ApiProperty({ example: 'Salary' })
  @Column('varchar')
  description: string;

  @ApiProperty({ example: '2026-10-01T09:30:00.000Z' })
  @Column({ type: 'timestamptz' })
  occurredAt: Date;

  @ManyToOne(() => Account, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'accountId' })
  account?: Account;
}
