import { Module } from '@nestjs/common';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { ConfigModule } from '@nestjs/config';
import { QueueModule } from './queue/queue.module.js';
import { EmailModule } from './email/email.module.js';
import { AuthModule } from './auth/auth.module.js';
import { RedisModule } from './redis/redis.module.js';
import { UserModule } from './user/user.module.js';
import { DirectoryModule } from './directory/directory.module.js';
import { CloudinaryModule } from './cloudinary/cloudinary.module.js';
import { NewsModule } from './news/news.module.js';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env', 'backend/.env'],
    }),
    QueueModule,
    EmailModule,
    AuthModule,
    RedisModule,
    UserModule,
    DirectoryModule,
    CloudinaryModule,
    NewsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
