import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaClient, ListingStatus, BusinessCategory } from '@prisma/client';
import { CreateBusinessDto } from './dto/create-business.dto.js';
import { UpdateBusinessDto } from './dto/update-business.dto.js';
import { OccupationDetailsDto } from '../user/dto/complete-profile.dto.js';
import { CloudinaryService } from '../cloudinary/cloudinary.service.js';

const prisma = new PrismaClient();

@Injectable()
export class BusinessService {
  constructor(private readonly cloudinaryService: CloudinaryService) {}
  /**
   * Creates a new business listing.
   *
   * @param ownerId - ID of the user creating the listing.
   * @param createBusinessDto - DTO containing listing details.
   * @returns The created business listing.
   */
  async create(ownerId: string, createBusinessDto: CreateBusinessDto) {
    return prisma.businessListing.create({
      data: {
        ...createBusinessDto,
        ownerId,
      },
    });
  }

  /**
   * Retrieves all business listings.
   * @returns Array of business listings with owner basic info.
   */
  async findAll() {
    return prisma.businessListing.findMany({
      include: { owner: true },
    });
  }

  /**
   * Retrieves approved listings, optionally filtered by city and owner details.
   */
  async findApprovedDirectory(
    cities?: string,
    gaons?: string,
    nativeDistricts?: string,
    nativeStates?: string,
    gotras?: string,
  ) {
    const whereClause: any = { status: ListingStatus.APPROVED };
    
    if (cities) {
      whereClause.city = { in: cities.split(',').map((s) => s.trim()) };
    }

    const ownerFilter: any = {};
    if (gaons) {
      ownerFilter.gaon = { in: gaons.split(',').map((s) => s.trim()) };
    }
    if (nativeDistricts) {
      ownerFilter.nativeDistrict = { in: nativeDistricts.split(',').map((s) => s.trim()) };
    }
    if (nativeStates) {
      ownerFilter.nativeState = { in: nativeStates.split(',').map((s) => s.trim()) };
    }
    if (gotras) {
      ownerFilter.gotra = { in: gotras.split(',').map((s) => s.trim()) };
    }

    if (Object.keys(ownerFilter).length > 0) {
      whereClause.owner = ownerFilter;
    }

    return prisma.businessListing.findMany({
      where: whereClause,
      include: { owner: true },
      orderBy: { businessName: 'asc' },
    });
  }

  /**
   * Retrieves a single listing by ID.
   * @param id - Listing identifier.
   * @returns The business listing.
   * @throws NotFoundException if not found.
   */
  async findOne(id: string) {
    const business = await prisma.businessListing.findUnique({
      where: { id },
      include: { owner: true },
    });
    if (!business) {
      throw new NotFoundException('Business listing not found');
    }
    return business;
  }

  /**
   * Retrieves a listing by owner ID.
   * @param ownerId - Owner identifier.
   * @returns The business listing or null if not found.
   */
  async findByOwnerId(ownerId: string) {
    return prisma.businessListing.findFirst({
      where: { ownerId },
      include: { owner: true },
    });
  }

  /**
   * Updates an existing listing.
   * @param id - Listing identifier.
   * @param updateBusinessDto - DTO with updated fields.
   * @returns Updated listing.
   * @throws NotFoundException if listing does not exist.
   */
  async update(id: string, updateBusinessDto: UpdateBusinessDto) {
    const business = await prisma.businessListing.findUnique({ where: { id } });
    if (!business) {
      throw new NotFoundException('Business listing not found');
    }
    return prisma.businessListing.update({
      where: { id },
      data: updateBusinessDto,
    });
  }

  /**
   * Deletes a listing by ID.
   * @param id - Listing identifier.
   * @returns Deleted listing.
   * @throws NotFoundException if listing does not exist.
   */
  async remove(id: string) {
    const business = await prisma.businessListing.findUnique({ where: { id } });
    if (!business) {
      throw new NotFoundException('Business listing not found');
    }
    return prisma.businessListing.delete({ where: { id } });
  }

  /**
   * Creates or updates a business listing based on a user's profile.
   *
   * @param userId - Owner user ID.
   * @param currentState - Current state for the listing.
   * @param occupationDetails - Occupation details from the profile.
   * @returns void.
   */
  async upsertFromProfile(userId: string, currentState: string, occupationDetails: OccupationDetailsDto) {
    if (!occupationDetails.businessName || !occupationDetails.category) {
      return;
    }

    const existing = await prisma.businessListing.findFirst({
      where: { ownerId: userId },
    });

    const data = {
      businessName: occupationDetails.businessName,
      category: occupationDetails.category as BusinessCategory,
      description: occupationDetails.description,
      logoUrl: occupationDetails.logoUrl,
      website: occupationDetails.website,
      contactNumber: occupationDetails.contact || '',
      address: occupationDetails.address || '',
      city: occupationDetails.city || '',
      state: currentState,
    };

    if (existing) {
      await prisma.businessListing.update({
        where: { id: existing.id },
        data,
      });
    } else {
      await prisma.businessListing.create({
        data: {
          ...data,
          ownerId: userId,
          status: ListingStatus.APPROVED,
        },
      });
    }
  }

  /**
   * Uploads a logo for a business listing. Replaces the existing image if one exists.
   * @param id - The business ID.
   * @param file - The image file to upload.
   * @returns The updated business listing containing the new logoUrl.
   */
  async uploadLogo(id: string, file: Express.Multer.File) {
    const business = await prisma.businessListing.findUnique({ where: { id } });
    if (!business) {
      throw new NotFoundException('Business listing not found');
    }

    if (business.logoUrl) {
      const publicId = this.extractPublicId(business.logoUrl);
      if (publicId) {
        try {
          await this.cloudinaryService.deleteImage(publicId);
        } catch (e) {
          console.error(`Failed to delete old business logo ${publicId} from Cloudinary`, e);
        }
      }
    }

    const result = await this.cloudinaryService.uploadImage(file);
    
    return prisma.businessListing.update({
      where: { id },
      data: { logoUrl: result.secure_url },
    });
  }

  /**
   * Extracts the Cloudinary public ID from a given image URL.
   */
  private extractPublicId(url: string): string | null {
    try {
      const parts = url.split('/');
      const filenameWithExtension = parts.pop();
      if (!filenameWithExtension) return null;
      const filenameParts = filenameWithExtension.split('.');
      filenameParts.pop(); // Remove extension
      const filename = filenameParts.join('.');

      const uploadIndex = parts.findIndex(p => p === 'upload');
      if (uploadIndex === -1 || uploadIndex === parts.length - 1) {
        return filename;
      }
      
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
