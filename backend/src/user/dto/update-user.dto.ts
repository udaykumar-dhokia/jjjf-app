import { PartialType } from '@nestjs/swagger';
import { CompleteProfileDto } from './complete-profile.dto.js';

export class UpdateUserDto extends PartialType(CompleteProfileDto) {}
