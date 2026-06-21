import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { CompleteProfileDto } from './dto/complete-profile.dto.js';
import { TokenUtilService } from '../auth/utils/token.util.js';

const prisma = new PrismaClient();

@Injectable()
export class UserService {
  constructor(private readonly tokenUtil: TokenUtilService) {}

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

    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        ...dto,
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
    return prisma.user.findMany({
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
        phoneNumber: true,
        isPhoneNumberVisible: true,
        currentCity: true,
        bloodGroup: true,
        occupationType: true,
        occupationDetails: true,
        gaon: true,
        nativeDistrict: true,
      }
    });
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
}
