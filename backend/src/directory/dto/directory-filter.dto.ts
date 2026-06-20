import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsOptional, IsString, IsInt, Min, IsEnum } from 'class-validator';
import { OccupationType } from '@prisma/client';

export class DirectoryFilterDto {
  @ApiPropertyOptional({ description: 'Number of results to return', default: 10 })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @IsOptional()
  limit?: number = 10;

  @ApiPropertyOptional({ description: 'Number of results to skip', default: 0 })
  @Type(() => Number)
  @IsInt()
  @Min(0)
  @IsOptional()
  offset?: number = 0;

  @ApiPropertyOptional({ description: 'Search by exact or partial name' })
  @IsString()
  @IsOptional()
  name?: string;

  @ApiPropertyOptional({ description: 'Filter by Gaon (Village)' })
  @IsString()
  @IsOptional()
  gaon?: string;

  @ApiPropertyOptional({ description: 'Filter by current city' })
  @IsString()
  @IsOptional()
  currentCity?: string;

  @ApiPropertyOptional({ description: 'Filter by professional field (OccupationType)', enum: OccupationType })
  @IsEnum(OccupationType)
  @IsOptional()
  occupationType?: OccupationType;

  @ApiPropertyOptional({ description: 'Filter by blood group' })
  @IsString()
  @IsOptional()
  bloodGroup?: string;

  @ApiPropertyOptional({ description: 'Filter by gotra (surname)' })
  @IsString()
  @IsOptional()
  gotra?: string;

  @ApiPropertyOptional({ description: 'Field to sort by', default: 'firstName' })
  @IsString()
  @IsOptional()
  sortBy?: string = 'firstName';

  @ApiPropertyOptional({ description: 'Sort order (asc or desc)', default: 'asc' })
  @IsString()
  @IsOptional()
  sortOrder?: 'asc' | 'desc' = 'asc';
}
