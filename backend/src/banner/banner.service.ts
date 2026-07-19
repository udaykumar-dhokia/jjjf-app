import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { CloudinaryService } from '../cloudinary/cloudinary.service.js';

const prisma = new PrismaClient();

@Injectable()
export class BannerService {
  constructor(private readonly cloudinaryService: CloudinaryService) {}

  /**
   * Retrieves all active banners sorted by order
   */
  async getActiveBanners() {
    return prisma.banner.findMany({
      where: { isActive: true },
      orderBy: { order: 'asc' },
    });
  }

  /**
   * Retrieves all banners (for admin)
   */
  async getAllBanners() {
    return prisma.banner.findMany({
      orderBy: { order: 'asc' },
    });
  }

  /**
   * Creates a new banner
   */
  async createBanner(file: Express.Multer.File, isActive: boolean, order: number) {
    let imageUrl = '';
    
    if (file) {
      const uploadResult = await this.cloudinaryService.uploadImage(file);
      imageUrl = uploadResult.secure_url;
    } else {
      throw new Error('Image file is required');
    }

    // Shift other banners down
    await prisma.banner.updateMany({
      where: { order: { gte: order } },
      data: { order: { increment: 1 } },
    });

    return prisma.banner.create({
      data: {
        imageUrl,
        isActive,
        order,
      },
    });
  }

  /**
   * Deletes a banner
   */
  async deleteBanner(id: string) {
    const banner = await prisma.banner.findUnique({ where: { id } });
    if (!banner) throw new NotFoundException('Banner not found');

    return prisma.banner.delete({
      where: { id },
    });
  }

  /**
   * Updates a banner
   */
  async updateBanner(id: string, data: { isActive?: boolean; order?: number }) {
    const banner = await prisma.banner.findUnique({ where: { id } });
    if (!banner) throw new NotFoundException('Banner not found');

    if (data.order !== undefined && banner.order !== data.order) {
      // Shift other banners down to make room for this banner's new order
      await prisma.banner.updateMany({
        where: { order: { gte: data.order } },
        data: { order: { increment: 1 } },
      });
    }

    return prisma.banner.update({
      where: { id },
      data,
    });
  }
}
