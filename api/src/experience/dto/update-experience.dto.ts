import { ApiProperty } from '@nestjs/swagger';
import { IsArray, IsInt, IsOptional, Min } from 'class-validator';

export class UpdateExperienceDto {
  @ApiProperty({ example: 2, description: 'New experience version' })
  @IsInt()
  @Min(1)
  version: number;

  @ApiProperty({
    type: [Object],
    description:
      'Ordered list of experience sections. Each item is validated by the service (promotion | quick_action).',
    required: false,
  })
  @IsArray()
  @IsOptional()
  sections?: Record<string, unknown>[];
}
