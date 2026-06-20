import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AuthController } from './auth.controller.js';
import { AuthService } from './auth.service.js';
import { JwtStrategy } from './jwt.strategy.js';
import { JwtRefreshStrategy } from './jwt-refresh.strategy.js';
import { EmailModule } from '../email/email.module.js';
import { TokenUtilService } from './utils/token.util.js';

@Module({
  imports: [
    PassportModule,
    JwtModule.register({}),
    EmailModule,
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy, JwtRefreshStrategy, TokenUtilService],
})
export class AuthModule {}
