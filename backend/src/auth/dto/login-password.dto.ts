import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsString } from 'class-validator';

export class LoginWithPasswordDto {
  @ApiProperty({ required: true, description: 'Email address' })
  @IsEmail()
  @IsNotEmpty()
  email!: string;

  @ApiProperty({ required: true, description: 'Password' })
  @IsString()
  @IsNotEmpty()
  password!: string;
}
