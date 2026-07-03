import { Controller, Get, Post, Put, Patch, Delete, Body, Param, UseGuards, Request, Query, UseInterceptors, UploadedFile, ParseFilePipe, MaxFileSizeValidator, FileTypeValidator } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery, ApiConsumes, ApiBody } from '@nestjs/swagger';
import { FileInterceptor } from '@nestjs/platform-express';
import { BusinessService } from './business.service.js';
import { CreateBusinessDto } from './dto/create-business.dto.js';
import { UpdateBusinessDto } from './dto/update-business.dto.js';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';

@ApiTags('business')
@ApiBearerAuth()
@Controller('business')
export class BusinessController {
  constructor(private readonly businessService: BusinessService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  @ApiOperation({ summary: 'Create a new business listing' })
  @ApiResponse({ status: 201, description: 'Business created successfully' })
  create(@Request() req, @Body() createBusinessDto: CreateBusinessDto) {
    return this.businessService.create(req.user.userId, createBusinessDto);
  }

  @UseGuards(JwtAuthGuard)
  @Get('directory/approved')
  @ApiOperation({ summary: 'Get all approved business listings for the directory' })
  @ApiQuery({ name: 'cities', required: false, type: String, description: 'Comma-separated list of cities' })
  @ApiQuery({ name: 'gaons', required: false, type: String, description: 'Comma-separated list of native villages' })
  @ApiQuery({ name: 'nativeDistricts', required: false, type: String, description: 'Comma-separated list of native districts' })
  @ApiQuery({ name: 'nativeStates', required: false, type: String, description: 'Comma-separated list of native states' })
  @ApiQuery({ name: 'gotras', required: false, type: String, description: 'Comma-separated list of gotras' })
  @ApiResponse({ status: 200, description: 'List of approved businesses' })
  findApprovedDirectory(
    @Query('cities') cities?: string,
    @Query('gaons') gaons?: string,
    @Query('nativeDistricts') nativeDistricts?: string,
    @Query('nativeStates') nativeStates?: string,
    @Query('gotras') gotras?: string,
  ) {
    return this.businessService.findApprovedDirectory(cities, gaons, nativeDistricts, nativeStates, gotras);
  }

  @UseGuards(JwtAuthGuard)
  @Get()
  @ApiOperation({ summary: 'Get all business listings' })
  @ApiResponse({ status: 200, description: 'List of all businesses' })
  findAll() {
    return this.businessService.findAll();
  }

  @UseGuards(JwtAuthGuard)
  @Get(':id')
  @ApiOperation({ summary: 'Get a business listing by ID' })
  @ApiResponse({ status: 200, description: 'Business listing details' })
  findOne(@Param('id') id: string) {
    return this.businessService.findOne(id);
  }

  @UseGuards(JwtAuthGuard)
  @Get('user/:userId')
  @ApiOperation({ summary: 'Get a business listing by owner ID' })
  @ApiResponse({ status: 200, description: 'Business listing details for user' })
  findByOwnerId(@Param('userId') userId: string) {
    return this.businessService.findByOwnerId(userId);
  }

  @UseGuards(JwtAuthGuard)
  @Put(':id')
  @ApiOperation({ summary: 'Update a business listing' })
  @ApiResponse({ status: 200, description: 'Business updated successfully' })
  update(@Param('id') id: string, @Body() updateBusinessDto: UpdateBusinessDto) {
    return this.businessService.update(id, updateBusinessDto);
  }

  @UseGuards(JwtAuthGuard)
  @Patch(':id/logo')
  @UseInterceptors(FileInterceptor('logo'))
  @ApiConsumes('multipart/form-data')
  @ApiOperation({ summary: 'Upload business logo' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        logo: {
          type: 'string',
          format: 'binary',
        },
      },
    },
  })
  @ApiResponse({ status: 200, description: 'Business logo uploaded' })
  async uploadLogo(
    @Param('id') id: string,
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
    return this.businessService.uploadLogo(id, file);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  @ApiOperation({ summary: 'Delete a business listing' })
  @ApiResponse({ status: 200, description: 'Business deleted successfully' })
  remove(@Param('id') id: string) {
    return this.businessService.remove(id);
  }
}
