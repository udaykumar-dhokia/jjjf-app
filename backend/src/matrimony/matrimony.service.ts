import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaClient, AccessRequestStatus } from '@prisma/client';
import { CreateMatrimonyProfileDto, UpdateMatrimonyProfileDto, CreateAccessRequestDto, UpdateAccessRequestStatusDto, BrowseMatrimonyQueryDto } from './dto/matrimony.dto.js';

const prisma = new PrismaClient();

@Injectable()
export class MatrimonyService {
  /**
   * Creates a new matrimonial profile for the user.
   *
   * @param userId - The ID of the user creating the profile.
   * @param dto - Data transfer object for the profile.
   * @returns The created matrimonial profile.
   */
  async createProfile(userId: string, dto: CreateMatrimonyProfileDto) {
    const existing = await prisma.matrimonialProfile.findUnique({
      where: { userId },
    });
    if (existing) {
      throw new BadRequestException('Matrimonial profile already exists');
    }

    return prisma.matrimonialProfile.create({
      data: {
        userId,
        ...dto,
      },
      include: {
        user: {
          select: {
            firstName: true,
            gotra: true,
            dateOfBirth: true,
            phoneNumber: true,
            whatsappNumber: true,
          }
        }
      }
    });
  }

  /**
   * Retrieves the current user's matrimonial profile.
   *
   * @param userId - The ID of the user.
   * @returns The user's matrimonial profile.
   */
  async getMyProfile(userId: string) {
    const profile = await prisma.matrimonialProfile.findUnique({
      where: { userId },
      include: {
        user: {
          select: {
            firstName: true,
            gotra: true,
            dateOfBirth: true,
            phoneNumber: true,
            whatsappNumber: true,
          }
        }
      }
    });
    if (!profile) throw new NotFoundException('Profile not found');
    return profile;
  }

  /**
   * Updates the current user's matrimonial profile.
   *
   * @param userId - The ID of the user.
   * @param dto - Data transfer object for the profile updates.
   * @returns The updated matrimonial profile.
   */
  async updateProfile(userId: string, dto: UpdateMatrimonyProfileDto) {
    const existing = await prisma.matrimonialProfile.findUnique({
      where: { userId },
    });
    if (!existing) {
      throw new NotFoundException('Matrimonial profile not found');
    }

    return prisma.matrimonialProfile.update({
      where: { userId },
      data: dto,
      include: {
        user: {
          select: {
            firstName: true,
            gotra: true,
            dateOfBirth: true,
            phoneNumber: true,
            whatsappNumber: true,
          }
        }
      }
    });
  }

  /**
   * Deletes the current user's matrimonial profile.
   *
   * @param userId - The ID of the user.
   */
  async deleteProfile(userId: string) {
    const existing = await prisma.matrimonialProfile.findUnique({
      where: { userId },
    });
    if (!existing) {
      throw new NotFoundException('Matrimonial profile not found');
    }

    await prisma.matrimonialProfile.delete({
      where: { userId },
    });
    return { success: true };
  }

  /**
   * Browses approved matrimonial profiles.
   * Only accessible to users who have an APPROVED profile themselves.
   * Returns limited data (name, age, gotra) unless access is specifically granted.
   *
   * @param userId - The ID of the requesting user.
   * @returns Array of profiles with limited visibility.
   */
  async browseProfiles(userId: string, query?: BrowseMatrimonyQueryDto) {
    const requesterProfile = await prisma.matrimonialProfile.findUnique({
      where: { userId },
    });
    
    if (!requesterProfile || requesterProfile.status !== 'APPROVED') {
      throw new ForbiddenException('You must have an approved matrimonial profile to browse others.');
    }

    const whereClause: any = {
      status: 'APPROVED',
      userId: { not: userId },
      AND: [],
    };

    let userWhere: any = {};

    if (query) {
      if (query.education && query.education.length > 0) {
        whereClause.educationDetails = { in: query.education };
      }
      if (query.heights && query.heights.length > 0) {
        whereClause.height = { in: query.heights };
      }
      
      // Age calculation
      let dateOfBirthWhere: any = {};
      const today = new Date();
      if (query.minAge) {
        const maxDate = new Date(today.getFullYear() - query.minAge, today.getMonth(), today.getDate());
        dateOfBirthWhere.lte = maxDate;
      }
      if (query.maxAge) {
        const minDate = new Date(today.getFullYear() - query.maxAge - 1, today.getMonth(), today.getDate() + 1);
        dateOfBirthWhere.gte = minDate;
      }

      if (Object.keys(dateOfBirthWhere).length > 0) {
        userWhere.dateOfBirth = dateOfBirthWhere;
      }
      
      if (query.cities && query.cities.length > 0) {
        userWhere.currentCity = { in: query.cities };
      }

      if (query.gender) {
        userWhere.gender = query.gender;
      }

      // Gotras (User OR subCaste)
      if (query.gotras && query.gotras.length > 0) {
        whereClause.AND.push({
          OR: [
            { subCaste: { in: query.gotras } },
            { user: { gotra: { in: query.gotras } } },
          ]
        });
      }

      // Search functionality
      if (query.search) {
        const search = query.search;
        whereClause.AND.push({
          OR: [
            { subCaste: { contains: search, mode: 'insensitive' } },
            { user: { firstName: { contains: search, mode: 'insensitive' } } },
            { user: { gotra: { contains: search, mode: 'insensitive' } } },
            { user: { currentCity: { contains: search, mode: 'insensitive' } } },
          ]
        });
      }
    }

    if (Object.keys(userWhere).length > 0) {
      whereClause.user = userWhere;
    }

    if (whereClause.AND.length === 0) {
      delete whereClause.AND;
    }

    const profiles = await prisma.matrimonialProfile.findMany({
      where: whereClause,
      include: {
        user: {
          select: {
            id: true,
            firstName: true,
            gotra: true,
            dateOfBirth: true,
            currentCity: true,
          }
        }
      }
    });

    // Map to limit visibility
    return profiles.map(p => ({
      id: p.id,
      userId: p.userId,
      firstName: p.user.firstName,
      gotra: p.user.gotra,
      currentCity: p.user.currentCity,
      dateOfBirth: p.user.dateOfBirth,
      age: new Date().getFullYear() - new Date(p.user.dateOfBirth).getFullYear(),
      photoGallery: p.photoGallery,
      height: p.height,
      educationDetails: p.educationDetails,
      monthlyIncome: p.monthlyIncome,
    }));
  }

  async getMetadata() {
    const gotras = await prisma.user.findMany({ select: { gotra: true }, distinct: ['gotra'] });
    const cities = await prisma.user.findMany({ select: { currentCity: true }, distinct: ['currentCity'] });
    const education = await prisma.matrimonialProfile.findMany({ select: { educationDetails: true }, distinct: ['educationDetails'] });
    const heights = await prisma.matrimonialProfile.findMany({ select: { height: true }, distinct: ['height'] });

    return {
      gotras: Array.from(new Set(gotras.map(g => g.gotra).filter(Boolean))),
      cities: Array.from(new Set(cities.map(c => c.currentCity).filter(Boolean))),
      education: Array.from(new Set(education.map(e => e.educationDetails).filter(Boolean))),
      heights: Array.from(new Set(heights.map(h => h.height).filter(Boolean))),
    };
  }

  /**
   * Views the full details of a specific profile.
   * Requires an APPROVED MatrimonialAccessRequest from the target user.
   *
   * @param requesterId - The ID of the user requesting to view.
   * @param targetId - The ID of the target user whose profile is being viewed.
   * @returns The full matrimonial profile.
   */
  async viewFullProfile(requesterId: string, targetId: string) {
    const accessRequest = await prisma.matrimonialAccessRequest.findFirst({
      where: {
        OR: [
          { requesterId: requesterId, targetId: targetId },
          { requesterId: targetId, targetId: requesterId },
        ],
        status: 'APPROVED',
      }
    });

    if (!accessRequest && requesterId !== targetId) {
      throw new ForbiddenException('You do not have access to view this full profile. Please request access.');
    }

    const profile = await prisma.matrimonialProfile.findUnique({
      where: { userId: targetId },
      include: {
        user: true,
      }
    });

    if (!profile) throw new NotFoundException('Profile not found');
    return profile;
  }

  /**
   * Creates a request to view someone's full profile.
   *
   * @param requesterId - The ID of the requesting user.
   * @param dto - DTO containing targetId.
   * @returns The created access request.
   */
  async requestAccess(requesterId: string, dto: CreateAccessRequestDto) {
    if (requesterId === dto.targetId) {
      throw new BadRequestException('Cannot request access to your own profile');
    }

    const existingRequest = await prisma.matrimonialAccessRequest.findFirst({
      where: {
        requesterId,
        targetId: dto.targetId,
      }
    });

    if (existingRequest) {
      throw new BadRequestException('Access request already exists');
    }

    return prisma.matrimonialAccessRequest.create({
      data: {
        requesterId,
        targetId: dto.targetId,
      }
    });
  }

  /**
   * Retrieves access requests sent by the user.
   *
   * @param userId - The ID of the user.
   * @returns Array of sent requests.
   */
  async getSentRequests(userId: string) {
    return prisma.matrimonialAccessRequest.findMany({
      where: { requesterId: userId },
      include: {
        target: {
          select: { 
            firstName: true, 
            gotra: true,
            photoUrl: true,
            matrimonialProfile: {
              select: { photoGallery: true }
            }
          }
        }
      }
    });
  }

  /**
   * Retrieves access requests received by the user.
   *
   * @param userId - The ID of the user.
   * @returns Array of received requests.
   */
  async getReceivedRequests(userId: string) {
    return prisma.matrimonialAccessRequest.findMany({
      where: { targetId: userId },
      include: {
        requester: {
          select: { 
            firstName: true, 
            gotra: true,
            photoUrl: true,
            matrimonialProfile: {
              select: { photoGallery: true }
            }
          }
        }
      }
    });
  }

  /**
   * Updates the status of a received access request.
   *
   * @param userId - The ID of the target user (who received the request).
   * @param requestId - The ID of the request to update.
   * @param dto - The new status.
   * @returns The updated request.
   */
  async updateAccessRequestStatus(userId: string, requestId: string, dto: UpdateAccessRequestStatusDto) {
    const request = await prisma.matrimonialAccessRequest.findUnique({
      where: { id: requestId },
    });

    if (!request || request.targetId !== userId) {
      throw new NotFoundException('Request not found or not authorized');
    }

    return prisma.matrimonialAccessRequest.update({
      where: { id: requestId },
      data: {
        status: dto.status as AccessRequestStatus,
      }
    });
  }
}
