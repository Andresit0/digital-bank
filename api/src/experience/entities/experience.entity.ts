import { ApiProperty } from '@nestjs/swagger';
import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'experience' })
export class Experience {
  @PrimaryGeneratedColumn('increment')
  id: number;

  @ApiProperty({ example: 'account_home' })
  @Column('varchar', { unique: true })
  experience: string;

  @ApiProperty({ example: 1 })
  @Column('int')
  version: number;

  @ApiProperty({ type: [Object] })
  @Column('jsonb', { default: [] })
  sections: Record<string, unknown>[];
}
