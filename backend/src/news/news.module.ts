import { Module } from '@nestjs/common';
import { NewsController } from './news.controller.js';
import { NewsService } from './news.service.js';
import { CloudinaryModule } from '../cloudinary/cloudinary.module.js';

@Module({
  imports: [CloudinaryModule],
  controllers: [NewsController],
  providers: [NewsService]
})
export class NewsModule {}
