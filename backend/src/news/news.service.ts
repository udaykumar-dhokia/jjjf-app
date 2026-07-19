import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaClient, Prisma } from '@prisma/client';
import { CreateNewsDto } from './dto/create-news.dto.js';
import { UpdateNewsDto } from './dto/update-news.dto.js';
import { NewsFilterDto } from './dto/news-filter.dto.js';
import { CloudinaryService } from '../cloudinary/cloudinary.service.js';
import 'multer';

const prisma = new PrismaClient();

/**
 * Service handling CRUD operations for news posts.
 *
 * Provides methods to create, retrieve, update, and delete news items,
 * as well as handling image uploads via Cloudinary.
 */
@Injectable()
export class NewsService {
  constructor(private readonly cloudinaryService: CloudinaryService) {}

  /**
   * Extracts the Cloudinary public ID from a given image URL.
   *
   * @param url - The full Cloudinary URL of the image.
   * @returns The public ID string or null if it cannot be extracted.
   */
  private extractPublicId(url: string): string | null {
    const parts = url.split('/upload/');
    if (parts.length === 2) {
      const path = parts[1];
      const pathWithoutVersion = path.substring(path.indexOf('/') + 1);
      return pathWithoutVersion.substring(0, pathWithoutVersion.lastIndexOf('.'));
    }
    return null;
  }

  /**
   * Creates a new news post with optional image uploads.
   *
   * @param createNewsDto - DTO containing news fields (title, content, etc.).
   * @param images - Array of image files uploaded via Multer.
   * @returns The created news record.
   */
  async create(createNewsDto: CreateNewsDto, images: Array<Express.Multer.File>) {
    const imageUrls: string[] = [];

    if (images && images.length > 0) {
      if (images.length > 3) {
        throw new BadRequestException('A maximum of 3 images are allowed');
      }
      for (const file of images) {
        const result = await this.cloudinaryService.uploadImage(file);
        imageUrls.push(result.secure_url);
      }
    }

    const passedImages = createNewsDto.images || [];
    const finalImages = [...passedImages, ...imageUrls].slice(0, 3);
    
    delete createNewsDto.images;

    return prisma.news.create({
      data: {
        ...createNewsDto,
        images: finalImages,
      },
    });
  }


  /**
   * Retrieves a paginated list of approved news posts with optional search and sorting.
   *
   * @param filterDto - DTO containing pagination, search, and sorting options.
   * @returns An object containing the news data array and pagination metadata.
   */
  async findAll(filterDto: NewsFilterDto) {
    const { limit = 10, offset = 0, search, sortBy, sortOrder, isShokSandesh } = filterDto;

    const where: Prisma.NewsWhereInput = {
      status: 'APPROVED',
    };

    if (isShokSandesh !== undefined) {
      if (isShokSandesh) {
        where.isShokSandesh = true;
      } else {
        where.OR = [
          ...(where.OR || []),
          { isShokSandesh: false },
          { isShokSandesh: { isSet: false } }
        ];
      }
    }

    if (search) {
      where.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }

    const totalCount = await prisma.news.count({ where });

    const news = await prisma.news.findMany({
      where,
      skip: Number(offset) || 0,
      take: Number(limit) || 10,
      orderBy: {
        [sortBy || 'createdAt']: sortOrder || 'desc',
      },
      include: {
        user: {
          select: { photoUrl: true },
        },
      },
    });

    const mappedNews = news.map(item => {
      const { user, ...rest } = item;
      return {
        ...rest,
        userPhotoUrl: user?.photoUrl || null,
      };
    });

    return {
      data: mappedNews,
      meta: {
        total: totalCount,
        limit: Number(limit) || 10,
        offset: Number(offset) || 0,
      }
    };
  }

  /**
   * Retrieves a paginated list of approved news posts by a specific user.
   *
   * @param userId - The user ID to filter by.
   * @param filterDto - DTO containing pagination, search, and sorting options.
   * @returns An object containing the news data array and pagination metadata.
   */
  async findAllByUser(userId: string, filterDto: NewsFilterDto) {
    const { limit = 10, offset = 0, search, sortBy, sortOrder, isShokSandesh } = filterDto;

    const where: Prisma.NewsWhereInput = {
      userId,
      status: 'APPROVED',
    };

    if (isShokSandesh !== undefined) {
      if (isShokSandesh) {
        where.isShokSandesh = true;
      } else {
        where.OR = [
          ...(where.OR || []),
          { isShokSandesh: false },
          { isShokSandesh: { isSet: false } }
        ];
      }
    }

    if (search) {
      where.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }

    const totalCount = await prisma.news.count({ where });

    const news = await prisma.news.findMany({
      where,
      skip: Number(offset) || 0,
      take: Number(limit) || 10,
      orderBy: {
        [sortBy || 'createdAt']: sortOrder || 'desc',
      },
      include: {
        user: {
          select: { photoUrl: true },
        },
      },
    });

    const mappedNews = news.map(item => {
      const { user, ...rest } = item;
      return {
        ...rest,
        userPhotoUrl: user?.photoUrl || null,
      };
    });

    return {
      data: mappedNews,
      meta: {
        total: totalCount,
        limit: Number(limit) || 10,
        offset: Number(offset) || 0,
      }
    };
  }

  /**
   * Retrieves a single news post by its ID.
   *
   * @param id - The identifier of the news post.
   * @returns The news record.
   * @throws NotFoundException if the news post does not exist.
   */
  async findOne(id: string) {
    const news = await prisma.news.findUnique({ where: { id } });
    if (!news) {
      throw new NotFoundException(`News post with ID ${id} not found`);
    }
    return news;
  }

  /**
   * Updates an existing news post and optionally replaces its images.
   *
   * @param id - The ID of the news post to update.
   * @param updateNewsDto - DTO with fields to update.
   * @param images - New image files to upload (replaces existing images).
   * @returns The updated news record.
   * @throws NotFoundException if the news post does not exist.
   */
  async update(id: string, updateNewsDto: UpdateNewsDto, images: Array<Express.Multer.File>) {
    const news = await prisma.news.findUnique({ where: { id } });
    if (!news) {
      throw new NotFoundException(`News post with ID ${id} not found`);
    }

    let imageUrls = news.images;

    if (images && images.length > 0) {
      for (const url of news.images) {
        const publicId = this.extractPublicId(url);
        if (publicId) {
          try {
            await this.cloudinaryService.deleteImage(publicId);
          } catch (e) {
            console.error('Failed to delete old image', e);
          }
        }
      }

      imageUrls = [];
      if (images.length > 3) {
        throw new BadRequestException('A maximum of 3 images are allowed');
      }
      for (const file of images) {
        const result = await this.cloudinaryService.uploadImage(file);
        imageUrls.push(result.secure_url);
      }
    }

    const passedImages = updateNewsDto.images || [];
    if (passedImages.length > 0) {
      imageUrls = passedImages; 
    }
    
    delete updateNewsDto.images;

    return prisma.news.update({
      where: { id },
      data: {
        ...updateNewsDto,
        images: imageUrls,
      },
    });
  }

  /**
   * Deletes a news post and removes its associated images from Cloudinary.
   *
   * @param id - The ID of the news post to delete.
   * @returns The deleted news record.
   * @throws NotFoundException if the news post does not exist.
   */
  async remove(id: string) {
    const news = await prisma.news.findUnique({ where: { id } });
    if (!news) {
      throw new NotFoundException(`News post with ID ${id} not found`);
    }

    for (const url of news.images) {
      const publicId = this.extractPublicId(url);
      if (publicId) {
        try {
          await this.cloudinaryService.deleteImage(publicId);
        } catch (e) {
          console.error(`Failed to delete image ${publicId} from Cloudinary`, e);
        }
      }
    }

    return prisma.news.delete({ where: { id } });
  }
}
