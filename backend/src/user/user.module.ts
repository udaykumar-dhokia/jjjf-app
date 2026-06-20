import { Module } from '@nestjs/common';
import { UserController } from './user.controller.js';
import { UserService } from './user.service.js';
import { TokenUtilService } from '../auth/utils/token.util.js';
import { JwtModule } from '@nestjs/jwt';

@Module({
  imports: [JwtModule.register({})],
  controllers: [UserController],
  providers: [UserService, TokenUtilService],
})
export class UserModule {}
