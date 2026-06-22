import {
  Controller,
  Post,
  Delete,
  Body,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { CloudinaryService } from './cloudinary.service.js';
import 'multer';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';

@ApiTags('cloudinary')
@Controller('upload')
export class CloudinaryController {
  constructor(private readonly cloudinaryService: CloudinaryService) {}

  @Post('image')
  @ApiOperation({ summary: 'Upload image to Cloudinary' })
  @ApiResponse({ status: 200, description: 'Image uploaded successfully' })
  @UseInterceptors(FileInterceptor('file'))
  async uploadImage(@UploadedFile() file: Express.Multer.File) {
    if (!file) {
      throw new BadRequestException('File is required');
    }
    
    try {
      const result = await this.cloudinaryService.uploadImage(file);
      return {
        url: result.secure_url,
        publicId: result.public_id,
      };
    } catch (error) {
      throw new BadRequestException('Image upload failed');
    }
  }

  @Delete('image')
  @ApiOperation({ summary: 'Delete image from Cloudinary' })
  @ApiResponse({ status: 200, description: 'Image deleted successfully' })
  async deleteImage(@Body('publicId') publicId: string) {
    if (!publicId) {
      throw new BadRequestException('publicId is required');
    }
    
    try {
      const result = await this.cloudinaryService.deleteImage(publicId);
      return {
        message: 'Deleted successfully',
        result,
      };
    } catch (error) {
      throw new BadRequestException('Image deletion failed');
    }
  }
}
