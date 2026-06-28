import { Module } from '@nestjs/common';
import { UserController } from './user.controller.js';
import { UserService } from './user.service.js';
import { TokenUtilService } from '../auth/utils/token.util.js';
import { JwtModule } from '@nestjs/jwt';
import { CloudinaryModule } from '../cloudinary/cloudinary.module.js';
import { BusinessModule } from '../business/business.module.js';

@Module({
  imports: [JwtModule.register({}), CloudinaryModule, BusinessModule],
  controllers: [UserController],
  providers: [UserService, TokenUtilService],
})
export class UserModule {}
