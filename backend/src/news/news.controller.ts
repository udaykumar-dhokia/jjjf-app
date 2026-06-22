import {
  Controller,
  Get,
  Post,
  Body,
  Query,
  Param,
  Delete,
  Put,
  UseInterceptors,
  UploadedFiles,
  UseGuards,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { NewsService } from './news.service.js';
import { CreateNewsDto } from './dto/create-news.dto.js';
import { UpdateNewsDto } from './dto/update-news.dto.js';
import { NewsFilterDto } from './dto/news-filter.dto.js';
import { ApiTags, ApiOperation, ApiConsumes, ApiBearerAuth } from '@nestjs/swagger';
import 'multer';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';

@ApiTags('news')
@ApiBearerAuth()
@Controller('news')
export class NewsController {
  constructor(private readonly newsService: NewsService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  @ApiOperation({ summary: 'Create a new news post with up to 3 images' })
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FilesInterceptor('images', 3))
  create(
    @Body() createNewsDto: CreateNewsDto,
    @UploadedFiles() images: Array<Express.Multer.File>,
  ) {
    return this.newsService.create(createNewsDto, images || []);
  }

  @UseGuards(JwtAuthGuard)
  @Get()
  @ApiOperation({ summary: 'Get all news posts' })
  findAll(@Query() filterDto: NewsFilterDto) {
    return this.newsService.findAll(filterDto);
  }

  @UseGuards(JwtAuthGuard)
  @Get(':id')
  @ApiOperation({ summary: 'Get a specific news post by ID' })
  findOne(@Param('id') id: string) {
    return this.newsService.findOne(id);
  }

  @UseGuards(JwtAuthGuard)
  @Put(':id')
  @ApiOperation({ summary: 'Update a news post' })
  @ApiConsumes('multipart/form-data')
  @UseInterceptors(FilesInterceptor('images', 3))
  update(
    @Param('id') id: string,
    @Body() updateNewsDto: UpdateNewsDto,
    @UploadedFiles() images: Array<Express.Multer.File>,
  ) {
    return this.newsService.update(id, updateNewsDto, images || []);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  @ApiOperation({ summary: 'Delete a news post' })
  remove(@Param('id') id: string) {
    return this.newsService.remove(id);
  }
}
