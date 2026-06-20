import { Controller, Get, Put, Delete, Body, UseGuards, Request, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBody, ApiResponse, ApiParam, ApiBearerAuth } from '@nestjs/swagger';
import { UserService } from './user.service.js';
import { CompleteProfileDto } from './dto/complete-profile.dto.js';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';

@ApiTags('user')
@ApiBearerAuth()
@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) {}

  @UseGuards(JwtAuthGuard)
  @Put('profile')
  @ApiOperation({ summary: 'Complete user profile' })
  @ApiBody({ type: CompleteProfileDto })
  @ApiResponse({ status: 200, description: 'Profile updated and new tokens returned' })
  async completeProfile(@Request() req, @Body() completeProfileDto: CompleteProfileDto) {
    return this.userService.completeProfile(req.user.userId, completeProfileDto);
  }

  @UseGuards(JwtAuthGuard)
  @Get()
  @ApiOperation({ summary: 'Retrieve all users' })
  @ApiResponse({ status: 200, description: 'List of users' })
  async findAll() {
    return this.userService.findAll();
  }

  @UseGuards(JwtAuthGuard)
  @Get(':id')
  @ApiParam({ name: 'id', description: 'User ID' })
  @ApiOperation({ summary: 'Get user by ID' })
  @ApiResponse({ status: 200, description: 'User details' })
  async findOne(@Param('id') id: string) {
    return this.userService.findOne(id);
  }

  @UseGuards(JwtAuthGuard)
  @Put(':id')
  @ApiParam({ name: 'id', description: 'User ID' })
  @ApiBody({ description: 'Partial user data to update' })
  @ApiOperation({ summary: 'Update user' })
  @ApiResponse({ status: 200, description: 'Updated user' })
  async update(@Param('id') id: string, @Body() updateData: any) {
    return this.userService.update(id, updateData);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  @ApiParam({ name: 'id', description: 'User ID' })
  @ApiOperation({ summary: 'Delete user' })
  @ApiResponse({ status: 200, description: 'User deleted' })
  async remove(@Param('id') id: string) {
    return this.userService.remove(id);
  }
}
