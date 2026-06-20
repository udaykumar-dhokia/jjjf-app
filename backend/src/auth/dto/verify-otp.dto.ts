import { ApiProperty } from '@nestjs/swagger';

export class VerifyOtpDto {
  @ApiProperty({ description: 'Email address used for OTP' })
  email!: string;

  @ApiProperty({ description: 'One‑time password received by the user' })
  otp!: string;
}
