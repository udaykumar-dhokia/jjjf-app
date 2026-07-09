import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty, IsEmail } from 'class-validator';

/**
 * DTO for creating an admin
 */
export class CreateAdminDto {
  @ApiProperty({ description: 'The name of the admin', example: 'John Doe' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({ description: 'The email of the admin', example: 'admin@example.com' })
  @IsEmail()
  email: string;
}
