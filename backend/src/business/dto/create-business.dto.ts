import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsEnum, IsOptional, IsUrl } from 'class-validator';
import { BusinessCategory, ListingStatus } from '@prisma/client';

export class CreateBusinessDto {
  @ApiProperty({ description: 'Name of the business' })
  @IsString()
  @IsNotEmpty()
  businessName!: string;

  @ApiProperty({ enum: BusinessCategory, description: 'Category of the business' })
  @IsEnum(BusinessCategory)
  @IsNotEmpty()
  category!: BusinessCategory;

  @ApiProperty({ required: false, description: 'Business description' })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({ required: false, description: 'Logo URL' })
  @IsUrl()
  @IsOptional()
  logoUrl?: string;

  @ApiProperty({ required: false, description: 'Website URL' })
  @IsUrl()
  @IsOptional()
  website?: string;

  @ApiProperty({ description: 'Contact number' })
  @IsString()
  @IsNotEmpty()
  contactNumber!: string;

  @ApiProperty({ description: 'Business address' })
  @IsString()
  @IsNotEmpty()
  address!: string;

  @ApiProperty({ description: 'City' })
  @IsString()
  @IsNotEmpty()
  city!: string;

  @ApiProperty({ description: 'State' })
  @IsString()
  @IsNotEmpty()
  state!: string;

  @ApiProperty({ required: false, enum: ListingStatus, description: 'Status of the listing' })
  @IsEnum(ListingStatus)
  @IsOptional()
  status?: ListingStatus;
}
