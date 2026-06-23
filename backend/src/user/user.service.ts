import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { CompleteProfileDto } from './dto/complete-profile.dto.js';
import { TokenUtilService } from '../auth/utils/token.util.js';
import { CloudinaryService } from '../cloudinary/cloudinary.service.js';

const prisma = new PrismaClient();

@Injectable()
export class UserService {
  constructor(
    private readonly tokenUtil: TokenUtilService,
    private readonly cloudinaryService: CloudinaryService,
  ) {}

  /**
   * Completes a user's profile and issues fresh JWT tokens.
   *
   * @param userId - The ID of the user whose profile is being updated.
   * @param dto - Data transfer object containing profile fields.
   * @returns An object containing new access and refresh tokens.
   */
  async completeProfile(userId: string, dto: CompleteProfileDto) {
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const { password, ...profileData } = dto;
    const bcrypt = await import('bcryptjs');
    const hashedPassword = await bcrypt.hash(password, 10);

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        ...profileData,
        password: hashedPassword,
        dateOfBirth: new Date(dto.dateOfBirth),
        isProfileComplete: true,
      },
    });

    await prisma.refreshToken.deleteMany({ where: { userId } });

    return this.tokenUtil.generateTokens(updatedUser.id, updatedUser.email || '', updatedUser.role, updatedUser.isProfileComplete);
  }

  /**
   * Retrieves all users.
   * @returns An array of user records.
   */
  async findAll() {
    return prisma.user.findMany();
  }

  /**
   * Retrieves the contact directory, containing only APPROVED users.
   * Sorted alphabetically by first name.
   */
  async getApprovedDirectory() {
    const users = await prisma.user.findMany({
      where: {
        status: 'APPROVED',
      },
      orderBy: {
        firstName: 'asc',
      },
      select: {
        id: true,
        memberId: true,
        firstName: true,
        fatherName: true,
        gotra: true,
        gender: true,
        maritalStatus: true,
        phoneNumber: true,
        isPhoneNumberVisible: true,
        currentCity: true,
        currentState: true,
        bloodGroup: true,
        occupationType: true,
        occupationDetails: true,
        gaon: true,
        nativeDistrict: true,
        photoUrl: true,
      }
    });

    return users.map(user => {
      if (!user.isPhoneNumberVisible) {
        user.phoneNumber = null as any;
      }
      return user;
    });
  }

  /**
   * Retrieves unique metadata (gotras, cities, states) for filtering the directory.
   */
  async getDirectoryMetadata() {
    const [gotras, cities, states] = await Promise.all([
      prisma.user.findMany({
        where: { status: 'APPROVED', gotra: { not: '' } },
        distinct: ['gotra'],
        select: { gotra: true },
      }),
      prisma.user.findMany({
        where: { status: 'APPROVED', currentCity: { not: '' } },
        distinct: ['currentCity'],
        select: { currentCity: true },
      }),
      prisma.user.findMany({
        where: { status: 'APPROVED', currentState: { not: '' } },
        distinct: ['currentState'],
        select: { currentState: true },
      }),
    ]);

    return {
      gotras: gotras.map(g => g.gotra).sort(),
      cities: cities.map(c => c.currentCity).sort(),
      states: states.map(s => s.currentState).sort(),
    };
  }

  /**
   * Retrieves a single user by ID.
   * @param id - The user ID.
   * @returns The user record.
   */
  async findOne(id: string) {
    const user = await prisma.user.findUnique({ where: { id } });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return user;
  }

  /**
   * Updates a user record.
   * @param id - The user ID.
   * @param data - Partial user data to update.
   * @returns The updated user record.
   */
  async update(id: string, data: any) {
    const user = await prisma.user.findUnique({ where: { id } });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return prisma.user.update({ where: { id }, data });
  }

  /**
   * Deletes a user by ID.
   * @param id - The user ID.
   * @returns The deleted user record.
   */
  async remove(id: string) {
    const user = await prisma.user.findUnique({ where: { id } });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return prisma.user.delete({ where: { id } });
  }

  /**
   * Uploads a profile image for a user. Replaces the existing image if one exists.
   * @param userId - The user ID.
   * @param file - The image file to upload.
   * @returns The updated user record containing the new photoUrl.
   */
  async uploadProfileImage(userId: string, file: Express.Multer.File) {
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (user.photoUrl) {
      const publicId = this.extractPublicId(user.photoUrl);
      if (publicId) {
        try {
          await this.cloudinaryService.deleteImage(publicId);
        } catch (e) {
          console.error(`Failed to delete old profile image ${publicId} from Cloudinary`, e);
        }
      }
    }

    const result = await this.cloudinaryService.uploadImage(file);
    
    return prisma.user.update({
      where: { id: userId },
      data: { photoUrl: result.secure_url },
    });
  }

  /**
   * Removes the profile image for a user.
   * @param userId - The user ID.
   * @returns The updated user record.
   */
  async removeProfileImage(userId: string) {
    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (user.photoUrl) {
      const publicId = this.extractPublicId(user.photoUrl);
      if (publicId) {
        try {
          await this.cloudinaryService.deleteImage(publicId);
        } catch (e) {
          console.error(`Failed to delete profile image ${publicId} from Cloudinary`, e);
        }
      }
    }

    return prisma.user.update({
      where: { id: userId },
      data: { photoUrl: null },
    });
  }

  /**
   * Extracts the Cloudinary public ID from a given image URL.
   * @param url - The full Cloudinary URL of the image.
   * @returns The extracted public ID, or null if not valid.
   */
  private extractPublicId(url: string): string | null {
    try {
      const parts = url.split('/');
      const filenameWithExtension = parts.pop();
      if (!filenameWithExtension) return null;
      const filenameParts = filenameWithExtension.split('.');
      filenameParts.pop(); // Remove extension
      const filename = filenameParts.join('.');

      // If the image is inside folders, we need to extract the folder path too
      const uploadIndex = parts.findIndex(p => p === 'upload');
      if (uploadIndex === -1 || uploadIndex === parts.length - 1) {
        return filename;
      }
      
      // Skip the version part (e.g., v1718018320)
      const folderParts = parts.slice(uploadIndex + 1);
      if (folderParts.length > 0 && folderParts[0].startsWith('v') && !isNaN(parseInt(folderParts[0].substring(1)))) {
        folderParts.shift();
      }

      if (folderParts.length > 0) {
        return `${folderParts.join('/')}/${filename}`;
      }
      return filename;
    } catch (e) {
      return null;
    }
  }
}
