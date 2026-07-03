import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsArray, IsEmail, IsEnum, IsNotEmpty, IsOptional, IsString, IsUrl } from 'class-validator';
import { JobType } from '@prisma/client';

export class CreateJobDto {
  @ApiProperty({ enum: JobType, description: 'Type of job posting' })
  @IsEnum(JobType)
  type!: JobType;

  @ApiProperty({ description: 'Title of the job role' })
  @IsString()
  @IsNotEmpty()
  roleTitle!: string;

  @ApiProperty({ description: 'Industry of the job' })
  @IsString()
  @IsNotEmpty()
  industry!: string;

  @ApiProperty({ description: 'Contact person name for the job' })
  @IsString()
  @IsNotEmpty()
  contactName!: string;

  @ApiPropertyOptional({ description: 'Contact phone number' })
  @IsString()
  @IsOptional()
  contactPhone?: string;

  @ApiPropertyOptional({ description: 'WhatsApp contact number' })
  @IsString()
  @IsOptional()
  whatsappNumber?: string;

  @ApiPropertyOptional({ description: 'Contact email address' })
  @IsEmail()
  @IsOptional()
  contactEmail?: string;

  @ApiProperty({ description: 'City where the job is located' })
  @IsString()
  @IsNotEmpty()
  city!: string;

  @ApiPropertyOptional({ description: 'Salary range offered or expected' })
  @IsString()
  @IsOptional()
  salaryRange?: string;

  @ApiProperty({ description: 'Detailed description of the job or requirements' })
  @IsString()
  @IsNotEmpty()
  description!: string;

  @ApiPropertyOptional({ description: 'Links for portfolio, resume, etc.', type: [String] })
  @IsArray()
  @IsString({ each: true })
  @IsUrl({}, { each: true })
  @IsOptional()
  links?: string[];
}
