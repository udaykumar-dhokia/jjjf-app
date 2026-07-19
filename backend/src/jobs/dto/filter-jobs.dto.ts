import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsEnum, IsOptional, IsString } from 'class-validator';
import { JobType, ListingStatus } from '@prisma/client';

export class FilterJobsDto {
  @ApiPropertyOptional({ enum: JobType, description: 'Filter by job type (VACANCY_AVAILABLE or JOB_REQUIRED)' })
  @IsEnum(JobType)
  @IsOptional()
  type?: JobType;

  @ApiPropertyOptional({ description: 'Filter by industry' })
  @IsString()
  @IsOptional()
  industry?: string;

  @ApiPropertyOptional({ description: 'Filter by city' })
  @IsString()
  @IsOptional()
  city?: string;

  @ApiPropertyOptional({ description: 'Filter by job role' })
  @IsString()
  @IsOptional()
  jobRole?: string;

  @ApiPropertyOptional({ enum: ListingStatus, description: 'Filter by approval status (default is APPROVED)' })
  @IsEnum(ListingStatus)
  @IsOptional()
  status?: ListingStatus;

  @ApiPropertyOptional({ description: 'Search term for role title or description' })
  @IsString()
  @IsOptional()
  search?: string;
}
