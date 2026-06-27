import { Module } from '@nestjs/common';
import { FamilyService } from './family.service.js';
import { FamilyController } from './family.controller.js';

@Module({
  controllers: [FamilyController],
  providers: [FamilyService],
  exports: [FamilyService],
})
export class FamilyModule { }
