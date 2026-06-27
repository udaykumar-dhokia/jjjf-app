import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse, ApiParam, ApiBody } from '@nestjs/swagger';
import { FamilyService } from './family.service.js';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';
import { AddFamilyMemberDto } from './dto/add-family-member.dto.js';
import { UpdateFamilyMemberDto } from './dto/update-family-member.dto.js';

@ApiTags('family')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('family')
export class FamilyController {
  constructor(private readonly familyService: FamilyService) {}

  @Get('me')
  @ApiOperation({ summary: 'Get current user family tree' })
  @ApiResponse({ status: 200, description: 'Family details including members' })
  async getMyFamily(@Request() req) {
    return this.familyService.findMyFamily(req.user.userId);
  }

  @Get(':id')
  @ApiParam({ name: 'id', description: 'Family ID' })
  @ApiOperation({ summary: 'Get a specific family tree by ID' })
  @ApiResponse({ status: 200, description: 'Family details including members' })
  async getFamilyById(@Param('id') id: string) {
    return this.familyService.findFamilyById(id);
  }

  @Post('create')
  @ApiOperation({ summary: 'Create a new family' })
  @ApiResponse({ status: 201, description: 'Family created successfully' })
  async createFamily(@Request() req) {
    return this.familyService.createFamily(req.user.userId);
  }

  @Post('members')
  @ApiOperation({ summary: 'Add a new member to the family' })
  @ApiBody({ type: AddFamilyMemberDto })
  @ApiResponse({ status: 201, description: 'Family member created' })
  async addFamilyMember(@Request() req, @Body() body: AddFamilyMemberDto) {
    return this.familyService.addFamilyMember(req.user.userId, body);
  }

  @Put('members/:memberId')
  @ApiParam({ name: 'memberId', description: 'Member User ID' })
  @ApiOperation({ summary: 'Update a family member' })
  @ApiBody({ type: UpdateFamilyMemberDto })
  @ApiResponse({ status: 200, description: 'Family member updated' })
  async updateFamilyMember(@Request() req, @Param('memberId') memberId: string, @Body() body: UpdateFamilyMemberDto) {
    return this.familyService.updateFamilyMember(req.user.userId, memberId, body);
  }

  @Delete('members/:memberId')
  @ApiParam({ name: 'memberId', description: 'Member User ID' })
  @ApiOperation({ summary: 'Remove a family member' })
  @ApiResponse({ status: 200, description: 'Family member removed' })
  async removeFamilyMember(@Request() req, @Param('memberId') memberId: string) {
    return this.familyService.removeFamilyMember(req.user.userId, memberId);
  }
}
