import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsNotEmpty } from 'class-validator';

export class SendOtpDto {
  @ApiProperty({ description: 'Email address to send OTP to' })
  @IsEmail()
  @IsNotEmpty()
  email!: string;
}
