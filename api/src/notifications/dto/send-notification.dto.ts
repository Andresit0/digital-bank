import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString } from 'class-validator';

export class SendNotificationDto {
  @ApiProperty({ example: '1', description: 'Target user code' })
  @IsString()
  @IsNotEmpty()
  userId: string;

  @ApiProperty({ example: 'movement' })
  @IsString()
  @IsNotEmpty()
  type: string;

  @ApiProperty({ example: 'mov-1' })
  @IsString()
  @IsNotEmpty()
  movementId: string;
}
