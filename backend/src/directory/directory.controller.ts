import { Controller, Get, Post, Put, Delete, Param, Query, UseGuards, Body } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { DirectoryService } from './directory.service.js';
import { DirectoryFilterDto } from './dto/directory-filter.dto.js';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';

@ApiTags('directory')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('directory')
export class DirectoryController {
  constructor(private readonly directoryService: DirectoryService) {}

  @Get()
  @ApiOperation({ summary: 'Get paginated and filtered contact directory' })
  @ApiResponse({ status: 200, description: 'Returns a list of directory members matching the filters.' })
  async findAll(@Query() filterDto: DirectoryFilterDto) {
    return this.directoryService.findAll(filterDto);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get detailed profile of a directory member' })
  @ApiParam({ name: 'id', description: 'User ID of the member' })
  @ApiResponse({ status: 200, description: 'Returns the redacted user profile.' })
  @ApiResponse({ status: 404, description: 'Member not found.' })
  async findOne(@Param('id') id: string) {
    return this.directoryService.findOne(id);
  }
}
