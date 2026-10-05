import { ApiProperty } from '@nestjs/swagger';
import { IsIn, IsNotEmpty, IsString } from 'class-validator';

export class RegisterDeviceDto {
  @ApiProperty({ example: 'fcm-registration-token' })
  @IsString()
  @IsNotEmpty()
  token: string;

  @ApiProperty({ example: 'android', enum: ['android'] })
  @IsString()
  @IsIn(['android'])
  platform: string;
}
