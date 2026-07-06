import { IsString, IsOptional, IsNumber, IsArray, IsEnum } from 'class-validator';
import { Type, Transform } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateMatrimonyProfileDto {
  @ApiPropertyOptional({ description: 'Height of the person' })
  @IsString()
  @IsOptional()
  height?: string;

  @ApiPropertyOptional({ description: 'Weight in kg' })
  @IsNumber()
  @IsOptional()
  weight?: number;

  @ApiProperty({ description: 'Sub Caste / Gotra' })
  @IsString()
  subCaste: string;

  @ApiProperty({ description: 'Education Details' })
  @IsString()
  educationDetails: string;

  @ApiPropertyOptional({ description: 'Monthly Income Range' })
  @IsString()
  @IsOptional()
  monthlyIncome?: string;

  @ApiPropertyOptional({ description: 'About Me / Bio' })
  @IsString()
  @IsOptional()
  aboutMe?: string;

  @ApiPropertyOptional({ description: 'Expectations from partner' })
  @IsString()
  @IsOptional()
  expectations?: string;

  @ApiPropertyOptional({ description: 'Array of photo URLs', type: [String] })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  photoGallery?: string[];

  @ApiPropertyOptional({ description: 'URL to bio-data PDF' })
  @IsString()
  @IsOptional()
  biodataPdfUrl?: string;
}

export class UpdateMatrimonyProfileDto {
  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  height?: string;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  weight?: number;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  subCaste?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  educationDetails?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  monthlyIncome?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  aboutMe?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  expectations?: string;

  @ApiPropertyOptional({ type: [String] })
  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  photoGallery?: string[];

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  biodataPdfUrl?: string;
}

export enum AccessRequestStatusDto {
  PENDING = 'PENDING',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
}

export class CreateAccessRequestDto {
  @ApiProperty({ description: 'User ID of the profile to request access to' })
  @IsString()
  targetId: string;
}

export class UpdateAccessRequestStatusDto {
  @ApiProperty({ enum: AccessRequestStatusDto })
  @IsEnum(AccessRequestStatusDto)
  status: AccessRequestStatusDto;
}

export class BrowseMatrimonyQueryDto {
  @ApiPropertyOptional({ description: 'Search by Name, Gotra, or Location' })
  @IsString()
  @IsOptional()
  search?: string;

  @ApiPropertyOptional({ description: 'Minimum age filter' })
  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  minAge?: number;

  @ApiPropertyOptional({ description: 'Maximum age filter' })
  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  maxAge?: number;

  @ApiPropertyOptional({ description: 'Filter by Gotra/Subcaste', type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @Transform(({ value }) => (Array.isArray(value) ? value : value ? [value] : undefined))
  gotras?: string[];

  @ApiPropertyOptional({ description: 'Filter by Education', type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @Transform(({ value }) => (Array.isArray(value) ? value : value ? [value] : undefined))
  education?: string[];

  @ApiPropertyOptional({ description: 'Filter by Height', type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @Transform(({ value }) => (Array.isArray(value) ? value : value ? [value] : undefined))
  heights?: string[];

  @ApiPropertyOptional({ description: 'Filter by Location/City', type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @Transform(({ value }) => (Array.isArray(value) ? value : value ? [value] : undefined))
  cities?: string[];

  @ApiPropertyOptional({ description: 'Filter by Gender' })
  @IsString()
  @IsOptional()
  gender?: string;
}
