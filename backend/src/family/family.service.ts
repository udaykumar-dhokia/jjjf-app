import { Injectable, NotFoundException, ForbiddenException, ConflictException } from '@nestjs/common';
import { PrismaClient, Prisma } from '@prisma/client';
import { AddFamilyMemberDto } from './dto/add-family-member.dto.js';
import { UpdateFamilyMemberDto } from './dto/update-family-member.dto.js';

const prisma = new PrismaClient();

@Injectable()
export class FamilyService {
  /**
   * Retrieves the family of the given user including all members.
   * @param userId The ID of the current user
   * @returns Family object with headOfFamily and members included, or null if no family.
   */
  async findMyFamily(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { familyId: true },
    });

    if (!user || !user.familyId) {
      return null;
    }

    return prisma.family.findUnique({
      where: { id: user.familyId },
      include: {
        headOfFamily: true,
        members: true,
      },
    });
  }

  /**
   * Creates a new family with the current user as the head.
   * @param userId The ID of the current user
   * @returns The created family object
   */
  async createFamily(userId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (user.familyId) {
      throw new ConflictException('User is already part of a family');
    }

    const randomSuffix = Math.floor(100000 + Math.random() * 900000).toString();
    const memberId = user.memberId || `MEM_${Date.now()}_${randomSuffix}`;

    // Create the family and update the user in a transaction
    return prisma.$transaction(async (tx) => {
      const family = await tx.family.create({
        data: {
          headOfFamilyId: userId,
          addedByUserId: userId,
        },
      });

      await tx.user.update({
        where: { id: userId },
        data: {
          familyId: family.id,
          isHeadOfFamily: true,
          relationshipToHead: 'SELF',
          memberId,
        },
      });

      return family;
    });
  }

  /**
   * Retrieves a specific family by its ID including all members.
   * @param familyId The ID of the family to retrieve
   * @returns Family object with headOfFamily and members included
   */
  async findFamilyById(familyId: string) {
    const family = await prisma.family.findUnique({
      where: { id: familyId },
      include: {
        headOfFamily: true,
        members: true,
      },
    });

    if (!family) {
      throw new NotFoundException('Family not found');
    }

    return family;
  }

  /**
   * Adds a new member to the current user's family.
   * @param userId The ID of the current user
   * @param data The data of the new family member
   * @returns The created user (family member)
   */
  async addFamilyMember(userId: string, data: AddFamilyMemberDto) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user || !user.isHeadOfFamily) {
      throw new ForbiddenException('Only the Head of Family can add members');
    }

    const randomSuffix = Math.floor(100000 + Math.random() * 900000).toString();
    const memberId = `MEM_${Date.now()}_${randomSuffix}`;

    try {
      const newMember = await prisma.user.create({
        data: {
          ...data,
          memberId,
          isPhoneNumberVisible: false,
          family: {
            connect: { id: user.familyId },
          },
          status: 'APPROVED',
        },
      });
      return newMember;
    } catch (error) {
      if (error instanceof Prisma.PrismaClientKnownRequestError) {
        if (error.code === 'P2002') {
          throw new ConflictException('Phone number or email is already in use by another member');
        }
      }
      throw error;
    }
  }

  /**
   * Updates a family member's details.
   * @param userId The ID of the current user (Head of Family)
   * @param memberId The ID of the member to update
   * @param data The update data
   * @returns The updated member
   */
  async updateFamilyMember(userId: string, memberId: string, data: UpdateFamilyMemberDto) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user || !user.isHeadOfFamily) {
      throw new ForbiddenException('Only the Head of Family can update members');
    }

    const member = await prisma.user.findUnique({
      where: { id: memberId },
    });

    if (!member || member.familyId !== user.familyId) {
      throw new NotFoundException('Member not found in your family');
    }

    try {
      return await prisma.user.update({
        where: { id: memberId },
        data,
      });
    } catch (error) {
      if (error instanceof Prisma.PrismaClientKnownRequestError) {
        if (error.code === 'P2002') {
          throw new ConflictException('Phone number or email is already in use by another member');
        }
      }
      throw error;
    }
  }

  /**
   * Removes a family member.
   * @param userId The ID of the current user (Head of Family)
   * @param memberId The ID of the member to remove
   * @returns The deleted member
   */
  async removeFamilyMember(userId: string, memberId: string) {
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user || !user.isHeadOfFamily) {
      throw new ForbiddenException('Only the Head of Family can remove members');
    }

    const member = await prisma.user.findUnique({
      where: { id: memberId },
    });

    if (!member || member.familyId !== user.familyId) {
      throw new NotFoundException('Member not found in your family');
    }

    if (member.isHeadOfFamily) {
      throw new ForbiddenException('Cannot remove the Head of Family');
    }

    return prisma.user.delete({
      where: { id: memberId },
    });
  }
}
