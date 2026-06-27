import { PartialType } from '@nestjs/swagger';
import { AddFamilyMemberDto } from './add-family-member.dto.js';

export class UpdateFamilyMemberDto extends PartialType(AddFamilyMemberDto) {}
