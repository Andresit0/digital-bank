import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsString, MinLength } from 'class-validator';

export class LoginDto {
  @ApiProperty({
    example: 'customer@example.com',
    description: 'Customer email',
    uniqueItems: true,
  })
  @IsString()
  @IsEmail()
  email: string;

  @ApiProperty({
    example: 'secret',
    description: 'Customer password',
  })
  @IsString()
  @MinLength(1)
  password: string;
}
