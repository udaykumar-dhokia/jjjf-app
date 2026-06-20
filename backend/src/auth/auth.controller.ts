import { Controller, Post, Body, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBody, ApiResponse } from '@nestjs/swagger';
import { AuthService } from './auth.service.js';
import { AuthGuard } from '@nestjs/passport';
import { SendOtpDto } from './dto/send-otp.dto.js';
import { VerifyOtpDto } from './dto/verify-otp.dto.js';
import { RefreshTokenDto } from './dto/refresh-token.dto.js';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('send-otp')
  @ApiOperation({ summary: 'Send OTP to user email' })
  @ApiBody({ type: SendOtpDto })
  @ApiResponse({ status: 200, description: 'OTP sent successfully' })
  async sendOtp(@Body() body: SendOtpDto) {
    return this.authService.sendOtp(body.email);
  }

  @Post('verify-otp')
  @ApiOperation({ summary: 'Verify OTP and login' })
  @ApiBody({ type: VerifyOtpDto })
  @ApiResponse({ status: 200, description: 'Tokens returned on successful verification' })
  async verifyOtp(@Body() body: VerifyOtpDto) {
    return this.authService.verifyOtp(body.email, body.otp);
  }

  @UseGuards(AuthGuard('jwt-refresh'))
  @Post('refresh')
  @ApiOperation({ summary: 'Refresh JWT tokens' })
  @ApiBody({ type: RefreshTokenDto })
  @ApiResponse({ status: 200, description: 'New tokens issued' })
  async refreshTokens(@Request() req, @Body() body: RefreshTokenDto) {
    return this.authService.refreshTokens(req.user.userId, body.refreshToken);
  }

  @UseGuards(AuthGuard('jwt-refresh'))
  @Post('logout')
  @ApiOperation({ summary: 'Logout and invalidate refresh token' })
  @ApiBody({ type: RefreshTokenDto })
  @ApiResponse({ status: 200, description: 'Logged out successfully' })
  async logout(@Body() body: RefreshTokenDto) {
    return this.authService.logout(body.refreshToken);
  }
}
