import { Module } from '@nestjs/common';
import { MatrimonyController } from './matrimony.controller.js';
import { MatrimonyService } from './matrimony.service.js';

@Module({
  controllers: [MatrimonyController],
  providers: [MatrimonyService],
})
export class MatrimonyModule {}
