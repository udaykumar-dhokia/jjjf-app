import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty, IsString } from 'class-validator';

export class VerifyOtpDto {
  @ApiProperty({ description: 'Email address used for OTP' })
  @IsEmail()
  @IsNotEmpty()
  email!: string;

  @ApiProperty({ description: 'One‑time password received by the user' })
  @IsString()
  @IsNotEmpty()
  otp!: string;
}
