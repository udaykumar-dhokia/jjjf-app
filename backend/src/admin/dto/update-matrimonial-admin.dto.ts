import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber } from 'class-validator';

export class UpdateMatrimonialAdminDto {
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

  @ApiPropertyOptional()
  @IsOptional()
  photoGallery?: string[];

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  biodataPdfUrl?: string;
}
