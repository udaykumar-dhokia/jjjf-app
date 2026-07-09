import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class ApproveRejectDto {
  @ApiPropertyOptional({ description: 'Optional reason for rejection' })
  @IsString()
  @IsOptional()
  reason?: string;
}
