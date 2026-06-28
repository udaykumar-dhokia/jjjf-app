import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaClient, Prisma } from '@prisma/client';
import { DirectoryFilterDto } from './dto/directory-filter.dto.js';

const prisma = new PrismaClient();

@Injectable()
export class DirectoryService {
  
  /**
   * Retrieves a paginated list of users matching the supplied filter.
   *
   * @param filterDto - DTO containing pagination and search criteria.
   * @returns An object with `data` (array of users) and `meta` (pagination
   *   information).
   */
  async findAll(filterDto: DirectoryFilterDto) {
    const { limit, offset, name, gaon, currentCity, occupationType, bloodGroup, gotra, sortBy, sortOrder } = filterDto;

    const where: Prisma.UserWhereInput = {
      isProfileComplete: true,
    };

    if (name) {
      where.OR = [
        { firstName: { contains: name, mode: 'insensitive' } },
        { fatherName: { contains: name, mode: 'insensitive' } },
        { spouseName: { contains: name, mode: 'insensitive' } },
      ];
    }
    if (gaon) where.gaon = { contains: gaon, mode: 'insensitive' };
    if (currentCity) where.currentCity = { contains: currentCity, mode: 'insensitive' };
    if (occupationType) where.occupationType = occupationType;
    if (bloodGroup) where.bloodGroup = bloodGroup;
    if (gotra) where.gotra = { contains: gotra, mode: 'insensitive' };

    const totalCount = await prisma.user.count({ where });

    const users = await prisma.user.findMany({
      where,
      skip: offset,
      take: limit,
      orderBy: {
        [sortBy || 'firstName']: sortOrder || 'asc',
      },
      select: {
        id: true,
        memberId: true,
        firstName: true,
        fatherName: true,
        gotra: true,
        currentCity: true,
        gaon: true,
        photoUrl: true,
        bloodGroup: true,
        occupationType: true,
        occupationDetails: true,
        phoneNumber: true,
        whatsappNumber: true,
        isPhoneNumberVisible: true,
        gender: true,
        familyId: true,
      }
    });

    const sanitizedUsers = users.map(user => {
      if (!user.isPhoneNumberVisible) {
        user.phoneNumber = null as any;
        user.whatsappNumber = null as any;
      }
      return user;
    });

    return {
      data: sanitizedUsers,
      meta: {
        total: totalCount,
        limit,
        offset,
      }
    };
  }

  /**
   * Retrieves a single user by ID.
   *
   * @param id - User identifier.
   * @returns The user record with selected fields.
   * @throws NotFoundException if the user does not exist.
   */
  async findOne(id: string) {
    const user = await prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        memberId: true,
        firstName: true,
        fatherName: true,
        motherName: true,
        spouseName: true,
        husbandNameWithSurname: true,
        sasuralGotra: true,
        gotra: true,
        gender: true,
        maritalStatus: true,
        dateOfBirth: true,
        bloodGroup: true,
        photoUrl: true,
        education: true,
        occupationType: true,
        occupationDetails: true,
        gaon: true,
        nativeDistrict: true,
        nativeState: true,
        currentAddress: true,
        currentCity: true,
        currentState: true,
        pinCode: true,
        phoneNumber: true,
        whatsappNumber: true,
        isPhoneNumberVisible: true,
        familyId: true,
        isHeadOfFamily: true,
        relationshipToHead: true,
      }
    });

    if (!user) {
      throw new NotFoundException('Member not found in directory');
    }

    if (!user.isPhoneNumberVisible) {
      user.phoneNumber = null as any;
      user.whatsappNumber = null as any;
    }

    return user;
  }
}
