import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsEnum, IsOptional, IsDateString, IsBoolean } from 'class-validator';
import { Gender, MaritalStatus, OccupationType, RelationshipType } from '@prisma/client';

export class AddFamilyMemberDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  firstName: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  fatherName: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  motherName?: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  gotra: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  spouseName?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  husbandNameWithSurname?: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  sasuralGotra?: string;

  @ApiProperty({ enum: Gender })
  @IsEnum(Gender)
  gender: Gender;

  @ApiProperty({ enum: MaritalStatus })
  @IsEnum(MaritalStatus)
  maritalStatus: MaritalStatus;

  @ApiProperty()
  @IsDateString()
  dateOfBirth: Date;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  bloodGroup?: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  email: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  education?: string;

  @ApiProperty({ enum: OccupationType })
  @IsEnum(OccupationType)
  occupationType: OccupationType;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  gaon: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  nativeDistrict: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  nativeState: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  currentAddress?: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  currentCity: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  currentState: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  pinCode?: string;

  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  phoneNumber: string;

  @ApiPropertyOptional()
  @IsString()
  @IsOptional()
  whatsappNumber?: string;

  @ApiProperty({ enum: RelationshipType })
  @IsEnum(RelationshipType)
  relationshipToHead: RelationshipType;
}
