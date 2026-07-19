import { Module } from '@nestjs/common';
import { BannerService } from './banner.service.js';
import { BannerController } from './banner.controller.js';
import { CloudinaryModule } from '../cloudinary/cloudinary.module.js';

@Module({
  imports: [CloudinaryModule],
  controllers: [BannerController],
  providers: [BannerService],
})
export class BannerModule {}
