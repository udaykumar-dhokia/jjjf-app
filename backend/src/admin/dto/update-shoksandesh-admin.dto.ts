import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsDateString } from 'class-validator';

export class UpdateShokSandeshAdminDto {
  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  deceasedName?: string;

  @ApiPropertyOptional()
  @IsNumber()
  @IsOptional()
  age?: number;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  nativeVillage?: string;

  @ApiPropertyOptional()
  @IsDateString()
  @IsOptional()
  dateDemised?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  funeralDetails?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  survivingFamily?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  contactPerson?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  contactPhone?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  deceasedPhotoUrl?: string;
}
