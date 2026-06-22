import { Controller, Get, Put, Patch, Delete, Body, UseGuards, Request, Param, UseInterceptors, UploadedFile, ParseFilePipe, MaxFileSizeValidator, FileTypeValidator } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiBody, ApiResponse, ApiParam, ApiBearerAuth, ApiConsumes } from '@nestjs/swagger';
import { UserService } from './user.service.js';
import { CompleteProfileDto } from './dto/complete-profile.dto.js';
import { UpdateUserDto } from './dto/update-user.dto.js';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';

@ApiTags('user')
@ApiBearerAuth()
@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) { }

  @UseGuards(JwtAuthGuard)
  @Put('profile')
  @ApiOperation({ summary: 'Complete user profile' })
  @ApiBody({ type: CompleteProfileDto })
  @ApiResponse({ status: 200, description: 'Profile updated and new tokens returned' })
  async completeProfile(@Request() req, @Body() completeProfileDto: CompleteProfileDto) {
    return this.userService.completeProfile(req.user.userId, completeProfileDto);
  }

  @UseGuards(JwtAuthGuard)
  @Get('profile/me')
  @ApiOperation({ summary: 'Get current user profile' })
  @ApiResponse({ status: 200, description: 'Current user details' })
  async getMyProfile(@Request() req) {
    return this.userService.findOne(req.user.userId);
  }

  @UseGuards(JwtAuthGuard)
  @Put('profile/me')
  @ApiOperation({ summary: 'Update current user profile' })
  @ApiBody({ type: UpdateUserDto })
  @ApiResponse({ status: 200, description: 'Current user updated' })
  async updateMyProfile(@Request() req, @Body() updateData: UpdateUserDto) {
    return this.userService.update(req.user.userId, updateData);
  }

  @UseGuards(JwtAuthGuard)
  @Patch('profile/image')
  @UseInterceptors(FileInterceptor('image'))
  @ApiConsumes('multipart/form-data')
  @ApiOperation({ summary: 'Upload profile image' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        image: {
          type: 'string',
          format: 'binary',
        },
      },
    },
  })
  @ApiResponse({ status: 200, description: 'Profile image uploaded' })
  async uploadProfileImage(
    @Request() req,
    @UploadedFile(
      new ParseFilePipe({
        validators: [
          new MaxFileSizeValidator({ maxSize: 5 * 1024 * 1024 }),
          new FileTypeValidator({ fileType: '.(png|jpeg|jpg|webp)' }),
        ],
      }),
    )
    file: Express.Multer.File,
  ) {
    return this.userService.uploadProfileImage(req.user.userId, file);
  }

  @UseGuards(JwtAuthGuard)
  @Delete('profile/image')
  @ApiOperation({ summary: 'Remove profile image' })
  @ApiResponse({ status: 200, description: 'Profile image removed' })
  async removeProfileImage(@Request() req) {
    return this.userService.removeProfileImage(req.user.userId);
  }

  @UseGuards(JwtAuthGuard)
  @Get()
  @ApiOperation({ summary: 'Retrieve all users' })
  @ApiResponse({ status: 200, description: 'List of users' })
  async findAll() {
    return this.userService.findAll();
  }

  @UseGuards(JwtAuthGuard)
  @Get('directory/approved')
  @ApiOperation({ summary: 'Retrieve the approved contact directory' })
  @ApiResponse({ status: 200, description: 'List of approved users' })
  async getDirectory() {
    return this.userService.getApprovedDirectory();
  }

  @UseGuards(JwtAuthGuard)
  @Get('directory/metadata')
  @ApiOperation({ summary: 'Retrieve unique available filter fields' })
  @ApiResponse({ status: 200, description: 'Metadata for filtering directory' })
  async getDirectoryMetadata() {
    return this.userService.getDirectoryMetadata();
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
  @ApiBody({ type: UpdateUserDto })
  @ApiOperation({ summary: 'Update user' })
  @ApiResponse({ status: 200, description: 'Updated user' })
  async update(@Param('id') id: string, @Body() updateData: UpdateUserDto) {
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
