import { ApiProperty } from '@nestjs/swagger';

export class SendOtpDto {
  @ApiProperty({ description: 'Email address to send OTP to' })
  email!: string;
}
