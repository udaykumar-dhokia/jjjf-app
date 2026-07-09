import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsEnum, IsBoolean } from 'class-validator';
import { Gender, MaritalStatus, OccupationType } from '@prisma/client';

export class UpdateUserAdminDto {
  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  firstName?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  fatherName?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  motherName?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  gotra?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  spouseName?: string;

  @ApiPropertyOptional({ enum: Gender })
  @IsEnum(Gender)
  @IsOptional()
  gender?: Gender;

  @ApiPropertyOptional({ enum: MaritalStatus })
  @IsEnum(MaritalStatus)
  @IsOptional()
  maritalStatus?: MaritalStatus;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  bloodGroup?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  education?: string;

  @ApiPropertyOptional({ enum: OccupationType })
  @IsEnum(OccupationType)
  @IsOptional()
  occupationType?: OccupationType;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  gaon?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  nativeDistrict?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  nativeState?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  currentCity?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  currentState?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  phoneNumber?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  husbandNameWithSurname?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  sasuralGotra?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  dateOfBirth?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  email?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  currentAddress?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  pinCode?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  whatsappNumber?: string;

  @ApiPropertyOptional()
  @IsBoolean()
  @IsOptional()
  isPhoneNumberVisible?: boolean;
}
