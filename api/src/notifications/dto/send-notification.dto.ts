import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

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

  @ApiProperty({
    example: 'Salary received',
    description: 'Visible notification title',
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(80)
  title: string;

  @ApiProperty({
    example: '+$500.00 in Savings',
    description: 'Visible notification body',
  })
  @IsString()
  @IsNotEmpty()
  @MaxLength(200)
  body: string;
}
