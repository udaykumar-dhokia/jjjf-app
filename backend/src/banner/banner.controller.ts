import { Controller, Get, Post, Delete, Put, Param, Body, UseGuards, UseInterceptors, UploadedFile } from '@nestjs/common';
import { BannerService } from './banner.service.js';
import { AdminGuard } from '../admin/admin.guard.js';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiConsumes, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('banner')
@Controller('banner')
export class BannerController {
  constructor(private readonly bannerService: BannerService) {}

  @Get()
  @ApiOperation({ summary: 'Get active banners' })
  async getActiveBanners() {
    return this.bannerService.getActiveBanners();
  }

  @Get('admin/all')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiOperation({ summary: 'Get all banners (Admin only)' })
  async getAllBanners() {
    return this.bannerService.getAllBanners();
  }

  @Post()
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, AdminGuard)
  @UseInterceptors(FileInterceptor('image'))
  @ApiConsumes('multipart/form-data')
  @ApiOperation({ summary: 'Create a new banner (Admin only)' })
  async createBanner(
    @UploadedFile() file: Express.Multer.File,
    @Body('isActive') isActiveStr?: string,
    @Body('order') orderStr?: string,
  ) {
    const isActive = isActiveStr === 'true' || isActiveStr === '1' || isActiveStr === undefined;
    const order = orderStr ? parseInt(orderStr, 10) : 0;
    return this.bannerService.createBanner(file, isActive, order);
  }

  @Delete(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiOperation({ summary: 'Delete a banner (Admin only)' })
  async deleteBanner(@Param('id') id: string) {
    return this.bannerService.deleteBanner(id);
  }

  @Put(':id')
  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard, AdminGuard)
  @ApiOperation({ summary: 'Update a banner (Admin only)' })
  async updateBanner(
    @Param('id') id: string,
    @Body('isActive') isActive?: boolean,
    @Body('order') order?: number,
  ) {
    return this.bannerService.updateBanner(id, { isActive, order });
  }
}
