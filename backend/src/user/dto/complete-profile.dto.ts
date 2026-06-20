import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsEnum, IsBoolean, IsDateString, IsOptional, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';
import { Gender, MaritalStatus, OccupationType, RelationshipType } from '@prisma/client';

export class OccupationDetailsDto {
  @ApiProperty({ required: false, description: 'Business name for occupation' })
  @IsString()
  @IsOptional()
  businessName?: string;

  @ApiProperty({ required: false, description: 'Occupation category' })
  @IsString()
  @IsOptional()
  category?: string;

  @ApiProperty({ required: false, description: 'Address of the occupation' })
  @IsString()
  @IsOptional()
  address?: string;

  @ApiProperty({ required: false, description: 'Contact number for occupation' })
  @IsString()
  @IsOptional()
  contact?: string;

  @ApiProperty({ required: false, description: 'Company name' })
  @IsString()
  @IsOptional()
  companyName?: string;

  @ApiProperty({ required: false, description: 'Designation at company' })
  @IsString()
  @IsOptional()
  designation?: string;

  @ApiProperty({ required: false, description: 'Industry type' })
  @IsString()
  @IsOptional()
  industry?: string;

  @ApiProperty({ required: false, description: 'City of occupation' })
  @IsString()
  @IsOptional()
  city?: string;

  @ApiProperty({ required: false, description: 'Description of occupation' })
  @IsString()
  @IsOptional()
  description?: string;
}

export class CompleteProfileDto {
  @ApiProperty({ required: true, description: 'First name' })
  @IsString()
  @IsNotEmpty()
  firstName!: string;

  @ApiProperty({ required: true, description: 'Father name' })
  @IsString()
  @IsNotEmpty()
  fatherName!: string;

  @ApiProperty({ required: false, description: 'Mother name' })
  @IsString()
  @IsOptional()
  motherName?: string;

  @ApiProperty({ required: true, description: 'Gotra' })
  @IsString()
  @IsNotEmpty()
  gotra!: string;

  @ApiProperty({ required: false, description: 'Spouse name' })
  @IsString()
  @IsOptional()
  spouseName?: string;

  @ApiProperty({ required: false, description: 'Husband name with surname' })
  @IsString()
  @IsOptional()
  husbandNameWithSurname?: string;

  @ApiProperty({ required: false, description: 'Sasural gotra' })
  @IsString()
  @IsOptional()
  sasuralGotra?: string;

  @ApiProperty({ required: true, description: 'Gender' })
  @IsEnum(Gender)
  @IsNotEmpty()
  gender!: Gender;

  @ApiProperty({ required: true, description: 'Marital status' })
  @IsEnum(MaritalStatus)
  @IsNotEmpty()
  maritalStatus!: MaritalStatus;

  @ApiProperty({ required: true, description: 'Date of birth' })
  @IsDateString()
  @IsNotEmpty()
  dateOfBirth!: string;

  @ApiProperty({ required: false, description: 'Blood group' })
  @IsString()
  @IsOptional()
  bloodGroup?: string;

  @ApiProperty({ required: false, description: 'Education' })
  @IsString()
  @IsOptional()
  education?: string;

  @ApiProperty({ required: true, description: 'Occupation type' })
  @IsEnum(OccupationType)
  @IsNotEmpty()
  occupationType!: OccupationType;

  @ApiProperty({ required: false, description: 'Occupation details' })
  @ValidateNested()
  @Type(() => OccupationDetailsDto)
  @IsOptional()
  occupationDetails?: OccupationDetailsDto;

  @ApiProperty({ required: true, description: 'Gaon' })
  @IsString()
  @IsNotEmpty()
  gaon!: string;

  @ApiProperty({ required: true, description: 'Native district' })
  @IsString()
  @IsNotEmpty()
  nativeDistrict!: string;

  @ApiProperty({ required: true, description: 'Native state' })
  @IsString()
  @IsNotEmpty()
  nativeState!: string;

  @ApiProperty({ required: false, description: 'Current address' })
  @IsString()
  @IsOptional()
  currentAddress?: string;

  @ApiProperty({ required: true, description: 'Current city' })
  @IsString()
  @IsNotEmpty()
  currentCity!: string;

  @ApiProperty({ required: true, description: 'Current state' })
  @IsString()
  @IsNotEmpty()
  currentState!: string;

  @ApiProperty({ required: false, description: 'Pin code' })
  @IsString()
  @IsOptional()
  pinCode?: string;

  @ApiProperty({ required: true, description: 'Phone number' })
  @IsString()
  @IsNotEmpty()
  phoneNumber!: string;

  @ApiProperty({ required: false, description: 'WhatsApp number' })
  @IsString()
  @IsOptional()
  whatsappNumber?: string;

  @ApiProperty({ required: true, description: 'Is phone number visible' })
  @IsBoolean()
  @IsNotEmpty()
  isPhoneNumberVisible!: boolean;

  @ApiProperty({ required: true, description: 'Relationship to head' })
  @IsEnum(RelationshipType)
  @IsNotEmpty()
  relationshipToHead!: RelationshipType;
}
