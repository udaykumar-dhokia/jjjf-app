import { PartialType } from '@nestjs/swagger';
import { CreateAdminDto } from './create-admin.dto.js';

/**
 * DTO for updating an admin
 */
export class UpdateAdminDto extends PartialType(CreateAdminDto) {}
