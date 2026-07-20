import { Controller, Get, Post, Body, Patch, Put, Param, UseGuards, Request, Query, Delete } from '@nestjs/common';
import { AdminService } from './admin.service.js';
import { AdminLoginDto } from './dto/admin-login.dto.js';
import { ApproveRejectDto } from './dto/approve-reject.dto.js';
import { UpdateEventAdminDto } from './dto/update-event-admin.dto.js';
import { UpdateBusinessAdminDto } from './dto/update-business-admin.dto.js';
import { UpdateJobAdminDto } from './dto/update-job-admin.dto.js';
import { UpdateMatrimonialAdminDto } from './dto/update-matrimonial-admin.dto.js';
import { UpdateShokSandeshAdminDto } from './dto/update-shoksandesh-admin.dto.js';
import { UpdateUserAdminDto } from './dto/update-user-admin.dto.js';
import { UpdateNewsAdminDto } from './dto/update-news-admin.dto.js';
import { CreateJobAdminDto } from './dto/create-job-admin.dto.js';
import { CreateNewsAdminDto } from './dto/create-news-admin.dto.js';
import { BulkCreateUsersDto } from './dto/bulk-create-users.dto.js';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';
import { AdminGuard } from './admin.guard.js';
import { ProfileStatus, ListingStatus, EventStatus, DemiseStatus, MatrimonialStatus } from '@prisma/client';

@ApiTags('Admin')
@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Post('login')
  @ApiOperation({ summary: 'Admin login' })
  @ApiResponse({ status: 200, description: 'JWT token and user info.' })
  async login(@Body() adminLoginDto: AdminLoginDto) {
    return this.adminService.login(adminLoginDto);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Get('dashboard/stats')
  @ApiOperation({ summary: 'Get dashboard statistics' })
  async getDashboardStats() {
    return this.adminService.getDashboardStats();
  }

  // ==========================================
  // USER APPROVALS
  // ==========================================
  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Post('users/bulk')
  @ApiOperation({ summary: 'Bulk upload users via CSV' })
  async bulkCreateUsers(@Request() req, @Body() dto: BulkCreateUsersDto) {
    return this.adminService.bulkCreateUsers(req.user.userId, dto);
  }
  // ==========================================
  // DISTINCT VALUES (DYNAMIC DROPDOWNS)
  // ==========================================
  
  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Get(':entity/distinct/:field')
  @ApiOperation({ summary: 'Get distinct values for a field in an entity' })
  async getDistinctValues(
    @Param('entity') entity: string,
    @Param('field') field: string,
  ) {
    return this.adminService.getDistinctValues(entity, field);
  }

  // ==========================================
  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Get('users')
  @ApiQuery({ name: 'status', enum: ProfileStatus, required: false })
  @ApiOperation({ summary: 'Get users' })
  async getUsers(
    @Query('status') status?: ProfileStatus,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('search') search?: string,
    @Query('filters') filters?: string,
  ) {
    return this.adminService.getUsers(status, page, limit, search, filters);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Put('users/:id')
  @ApiOperation({ summary: 'Edit a user before approval' })
  async updateUser(@Param('id') id: string, @Body() dto: UpdateUserAdminDto) {
    return this.adminService.updateUser(id, dto);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Patch('users/:id/approve')
  @ApiOperation({ summary: 'Approve a user' })
  async approveUser(@Param('id') id: string) {
    return this.adminService.approveUser(id);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Patch('users/:id/reject')
  @ApiOperation({ summary: 'Reject a user' })
  async rejectUser(@Param('id') id: string, @Body() dto: ApproveRejectDto) {
    return this.adminService.rejectUser(id, dto);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Patch('users/:id/block')
  @ApiOperation({ summary: 'Block a user' })
  async blockUser(@Param('id') id: string) {
    return this.adminService.blockUser(id);
  }

  // ==========================================
  // BUSINESS APPROVALS
  // ==========================================
  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Get('businesses')
  @ApiQuery({ name: 'status', enum: ListingStatus, required: false })
  @ApiOperation({ summary: 'Get businesses' })
  async getBusinesses(
    @Query('status') status?: ListingStatus,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('search') search?: string,
    @Query('filters') filters?: string,
  ) {
    return this.adminService.getBusinesses(status, page, limit, search, filters);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Put('businesses/:id')
  @ApiOperation({ summary: 'Edit a business before approval' })
  async updateBusiness(@Param('id') id: string, @Body() dto: UpdateBusinessAdminDto) {
    return this.adminService.updateBusiness(id, dto);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Patch('businesses/:id/approve')
  @ApiOperation({ summary: 'Approve a business' })
  async approveBusiness(@Param('id') id: string) {
    return this.adminService.approveBusiness(id);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Patch('businesses/:id/reject')
  @ApiOperation({ summary: 'Reject a business' })
  async rejectBusiness(@Param('id') id: string, @Body() dto: ApproveRejectDto) {
    return this.adminService.rejectBusiness(id, dto);
  }

  // ==========================================
  // JOB APPROVALS
  // ==========================================
  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Post('jobs')
  @ApiOperation({ summary: 'Create a new job as admin' })
  async createJob(@Request() req, @Body() dto: CreateJobAdminDto) {
    return this.adminService.createJob(req.user.userId, dto);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Get('jobs')
  @ApiQuery({ name: 'status', enum: ListingStatus, required: false })
  @ApiOperation({ summary: 'Get jobs' })
  async getJobs(
    @Query('status') status?: ListingStatus,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('search') search?: string,
    @Query('filters') filters?: string,
  ) {
    return this.adminService.getJobs(status, page, limit, search, filters);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Put('jobs/:id')
  @ApiOperation({ summary: 'Edit a job before approval' })
  async updateJob(@Param('id') id: string, @Body() dto: UpdateJobAdminDto) {
    return this.adminService.updateJob(id, dto);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Patch('jobs/:id/approve')
  @ApiOperation({ summary: 'Approve a job' })
  async approveJob(@Param('id') id: string) {
    return this.adminService.approveJob(id);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Patch('jobs/:id/reject')
  @ApiOperation({ summary: 'Reject a job' })
  async rejectJob(@Param('id') id: string, @Body() dto: ApproveRejectDto) {
    return this.adminService.rejectJob(id, dto);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Delete('jobs/:id')
  @ApiOperation({ summary: 'Delete a job' })
  async deleteJob(@Param('id') id: string) {
    return this.adminService.deleteJob(id);
  }

  // ==========================================
  // MATRIMONIAL APPROVALS
  // ==========================================
  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Get('matrimonials')
  @ApiQuery({ name: 'status', enum: MatrimonialStatus, required: false })
  @ApiOperation({ summary: 'Get matrimonial profiles' })
  async getMatrimonials(
    @Query('status') status?: MatrimonialStatus,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('search') search?: string,
    @Query('filters') filters?: string,
  ) {
    return this.adminService.getMatrimonials(status, page, limit, search, filters);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Put('matrimonials/:id')
  @ApiOperation({ summary: 'Edit a matrimonial profile before approval' })
  async updateMatrimonial(@Param('id') id: string, @Body() dto: UpdateMatrimonialAdminDto) {
    return this.adminService.updateMatrimonial(id, dto);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Patch('matrimonials/:id/approve')
  @ApiOperation({ summary: 'Approve a matrimonial profile' })
  async approveMatrimonial(@Param('id') id: string) {
    return this.adminService.approveMatrimonial(id);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Patch('matrimonials/:id/reject')
  @ApiOperation({ summary: 'Reject a matrimonial profile' })
  async rejectMatrimonial(@Param('id') id: string, @Body() dto: ApproveRejectDto) {
    return this.adminService.rejectMatrimonial(id, dto);
  }

  // ==========================================
  // EVENT APPROVALS
  // ==========================================
  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Get('events')
  @ApiQuery({ name: 'status', enum: EventStatus, required: false })
  @ApiOperation({ summary: 'Get events' })
  async getEvents(
    @Query('status') status?: EventStatus,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('search') search?: string,
    @Query('filters') filters?: string,
  ) {
    return this.adminService.getEvents(status, page, limit, search, filters);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Put('events/:id')
  @ApiOperation({ summary: 'Edit an event before approval' })
  async updateEvent(@Param('id') id: string, @Body() dto: UpdateEventAdminDto) {
    return this.adminService.updateEvent(id, dto);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Patch('events/:id/approve')
  @ApiOperation({ summary: 'Approve an event' })
  async approveEvent(@Param('id') id: string) {
    return this.adminService.approveEvent(id);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Patch('events/:id/reject')
  @ApiOperation({ summary: 'Reject an event' })
  async rejectEvent(@Param('id') id: string, @Body() dto: ApproveRejectDto) {
    return this.adminService.rejectEvent(id, dto);
  }

  // ==========================================
  // SHOK SANDESH APPROVALS
  // ==========================================
  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Get('shok-sandesh')
  @ApiQuery({ name: 'status', enum: DemiseStatus, required: false })
  @ApiOperation({ summary: 'Get shok sandesh entries' })
  async getShokSandesh(
    @Query('status') status?: DemiseStatus,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('search') search?: string,
    @Query('filters') filters?: string,
  ) {
    return this.adminService.getShokSandesh(status, page, limit, search, filters);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Put('shok-sandesh/:id')
  @ApiOperation({ summary: 'Edit a shok sandesh entry before approval' })
  async updateShokSandesh(@Param('id') id: string, @Body() dto: UpdateShokSandeshAdminDto) {
    return this.adminService.updateShokSandesh(id, dto);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Patch('shok-sandesh/:id/approve')
  @ApiOperation({ summary: 'Approve a shok sandesh entry' })
  async approveShokSandesh(@Param('id') id: string, @Request() req) {
    return this.adminService.approveShokSandesh(id, req.user.userId);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Patch('shok-sandesh/:id/reject')
  @ApiOperation({ summary: 'Reject a shok sandesh entry' })
  async rejectShokSandesh(@Param('id') id: string, @Body() dto: ApproveRejectDto, @Request() req) {
    return this.adminService.rejectShokSandesh(id, dto, req.user.userId);
  }

  // ==========================================
  // NEWS APPROVALS
  // ==========================================
  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Post('news')
  @ApiOperation({ summary: 'Create a new news entry as admin' })
  async createNews(@Request() req, @Body() dto: CreateNewsAdminDto) {
    return this.adminService.createNews(req.user.userId, dto);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Get('news')
  @ApiQuery({ name: 'status', required: false })
  @ApiOperation({ summary: 'Get news entries' })
  async getNews(
    @Query('status') status?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('search') search?: string,
    @Query('filters') filters?: string,
  ) {
    return this.adminService.getNews(status, page, limit, search, filters);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Put('news/:id')
  @ApiOperation({ summary: 'Edit a news entry before approval' })
  async updateNews(@Param('id') id: string, @Body() dto: UpdateNewsAdminDto) {
    return this.adminService.updateNews(id, dto);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Patch('news/:id/approve')
  @ApiOperation({ summary: 'Approve a news entry' })
  async approveNews(@Param('id') id: string) {
    return this.adminService.approveNews(id);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Patch('news/:id/reject')
  @ApiOperation({ summary: 'Reject a news entry' })
  async rejectNews(@Param('id') id: string) {
    return this.adminService.rejectNews(id);
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Delete('news/:id')
  @ApiOperation({ summary: 'Delete a news entry' })
  async deleteNews(@Param('id') id: string) {
    return this.adminService.deleteNews(id);
  }

  // ==========================================
  // STATE ADMINS
  // ==========================================

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Get('state-admins')
  @ApiOperation({ summary: 'Get all state admins' })
  async getStateAdmins() {
    return this.adminService.getStateAdmins();
  }

  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiBearerAuth()
  @Put('state-admins/:id/assign')
  @ApiOperation({ summary: 'Assign a state admin' })
  async assignStateAdmin(@Param('id') id: string, @Body() body: { userId: string }) {
    return this.adminService.assignStateAdmin(id, body.userId);
  }
}
