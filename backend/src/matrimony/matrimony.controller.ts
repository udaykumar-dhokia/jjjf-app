import { Controller, Get, Post, Body, Put, Param, Delete, UseGuards, Req, Query } from '@nestjs/common';
import { MatrimonyService } from './matrimony.service.js';
import { CreateMatrimonyProfileDto, UpdateMatrimonyProfileDto, CreateAccessRequestDto, UpdateAccessRequestStatusDto, BrowseMatrimonyQueryDto } from './dto/matrimony.dto.js';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('Matrimony')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('matrimony')
export class MatrimonyController {
  constructor(private readonly matrimonyService: MatrimonyService) {}

  @Post()
  @ApiOperation({ summary: 'Create a matrimonial profile' })
  createProfile(@Req() req: any, @Body() dto: CreateMatrimonyProfileDto) {
    return this.matrimonyService.createProfile(req.user.userId, dto);
  }

  @Get('me')
  @ApiOperation({ summary: 'Get current user matrimonial profile' })
  getMyProfile(@Req() req: any) {
    return this.matrimonyService.getMyProfile(req.user.userId);
  }

  @Put('me')
  @ApiOperation({ summary: 'Update current user matrimonial profile' })
  updateProfile(@Req() req: any, @Body() dto: UpdateMatrimonyProfileDto) {
    return this.matrimonyService.updateProfile(req.user.userId, dto);
  }

  @Delete('me')
  @ApiOperation({ summary: 'Delete current user matrimonial profile' })
  deleteProfile(@Req() req: any) {
    return this.matrimonyService.deleteProfile(req.user.userId);
  }

  @Get('metadata')
  @ApiOperation({ summary: 'Get available filter options for matrimony profiles' })
  getMetadata() {
    return this.matrimonyService.getMetadata();
  }

  @Get('browse')
  @ApiOperation({ summary: 'Browse approved matrimonial profiles (limited visibility)' })
  browseProfiles(@Req() req: any, @Query() query: BrowseMatrimonyQueryDto) {
    return this.matrimonyService.browseProfiles(req.user.userId, query);
  }

  @Get('profiles/:targetId')
  @ApiOperation({ summary: 'View full matrimonial profile of a specific user (requires access)' })
  viewFullProfile(@Req() req: any, @Param('targetId') targetId: string) {
    return this.matrimonyService.viewFullProfile(req.user.userId, targetId);
  }

  @Post('access-request')
  @ApiOperation({ summary: 'Request access to view a full profile' })
  requestAccess(@Req() req: any, @Body() dto: CreateAccessRequestDto) {
    return this.matrimonyService.requestAccess(req.user.userId, dto);
  }

  @Get('access-request/sent')
  @ApiOperation({ summary: 'Get list of sent access requests' })
  getSentRequests(@Req() req: any) {
    return this.matrimonyService.getSentRequests(req.user.userId);
  }

  @Get('access-request/received')
  @ApiOperation({ summary: 'Get list of received access requests' })
  getReceivedRequests(@Req() req: any) {
    return this.matrimonyService.getReceivedRequests(req.user.userId);
  }

  @Put('access-request/:id')
  @ApiOperation({ summary: 'Approve or reject a received access request' })
  updateAccessRequestStatus(
    @Req() req: any,
    @Param('id') requestId: string,
    @Body() dto: UpdateAccessRequestStatusDto
  ) {
    return this.matrimonyService.updateAccessRequestStatus(req.user.userId, requestId, dto);
  }
}
