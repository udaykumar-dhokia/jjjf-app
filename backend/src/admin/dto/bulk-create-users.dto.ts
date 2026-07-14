import { IsArray, IsString, IsOptional, ValidateNested, IsEmail, IsBoolean } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CsvUserDto {
  @ApiProperty()
  @IsString()
  familyGroupIdentifier: string;

  @ApiProperty()
  @IsString()
  firstName: string;

  @ApiProperty()
  @IsString()
  fatherName: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  motherName?: string;

  @ApiProperty()
  @IsString()
  gotra: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  spouseName?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  husbandNameWithSurname?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  sasuralGotra?: string;

  @ApiProperty()
  @IsString()
  gender: string;

  @ApiProperty()
  @IsString()
  maritalStatus: string;

  @ApiProperty()
  @IsString()
  dateOfBirth: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  bloodGroup?: string;

  @ApiProperty()
  @IsEmail()
  email: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  education?: string;

  @ApiProperty()
  @IsString()
  occupationType: string;

  @ApiProperty()
  @IsString()
  gaon: string;

  @ApiProperty()
  @IsString()
  nativeDistrict: string;

  @ApiProperty()
  @IsString()
  nativeState: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  currentAddress?: string;

  @ApiProperty()
  @IsString()
  currentCity: string;

  @ApiProperty()
  @IsString()
  currentState: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  pinCode?: string;

  @ApiProperty()
  @IsString()
  phoneNumber: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  whatsappNumber?: string;

  @ApiProperty()
  @IsString()
  isPhoneNumberVisible: string;

  @ApiProperty()
  @IsString()
  relationshipToHead: string;
}

export class BulkCreateUsersDto {
  @ApiProperty({ type: [CsvUserDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CsvUserDto)
  users: CsvUserDto[];
}
