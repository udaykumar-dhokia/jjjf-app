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

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    QueueModule,
    EmailModule,
    AuthModule,
    RedisModule,
    UserModule,
    DirectoryModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
