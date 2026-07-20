import { Injectable, UnauthorizedException, NotFoundException } from '@nestjs/common';
import { PrismaClient, ProfileStatus, ListingStatus, EventStatus, DemiseStatus, MatrimonialStatus, Role, Gender, MaritalStatus, OccupationType, RelationshipType } from '@prisma/client';
import * as bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { AdminLoginDto } from './dto/admin-login.dto.js';
import { ApproveRejectDto } from './dto/approve-reject.dto.js';
import { UpdateEventAdminDto } from './dto/update-event-admin.dto.js';
import { UpdateBusinessAdminDto } from './dto/update-business-admin.dto.js';
import { UpdateJobAdminDto } from './dto/update-job-admin.dto.js';
import { UpdateMatrimonialAdminDto } from './dto/update-matrimonial-admin.dto.js';
import { UpdateShokSandeshAdminDto } from './dto/update-shoksandesh-admin.dto.js';
import { UpdateUserAdminDto } from './dto/update-user-admin.dto.js';
import { UpdateNewsAdminDto } from './dto/update-news-admin.dto.js';
import { CreateJobAdminDto } from './dto/create-job-admin.dto.js';
import { CreateNewsAdminDto } from './dto/create-news-admin.dto.js';
import { BulkCreateUsersDto, CsvUserDto } from './dto/bulk-create-users.dto.js';

const prisma = new PrismaClient();

function getPagination(pageStr?: string, limitStr?: string) {
  const limit = limitStr ? parseInt(limitStr, 10) : 10;
  const page = pageStr ? parseInt(pageStr, 10) : 1;
  const skip = (page - 1) * limit;
  return { skip, take: limit, page, limit };
}

function buildWhereClause(status: any, search?: string, filtersStr?: string, searchFields: string[] = []) {
  const where: any = status ? { status } : {};

  if (search && searchFields.length > 0) {
    where.OR = searchFields.map(field => ({
      [field]: { contains: search, mode: 'insensitive' }
    }));
  }

  if (filtersStr) {
    try {
      const filters = JSON.parse(filtersStr);
      for (const [key, value] of Object.entries(filters)) {
        if (value !== undefined && value !== null && value !== '') {
          if (value === 'true') where[key] = true;
          else if (value === 'false') where[key] = false;
          else where[key] = value; // Exact match for filters to support enums/numbers/dates safely
        }
      }
    } catch (e) {
      console.error('Error parsing filters', e);
    }
  }
  return where;
}

async function fetchPaginatedData(prismaDelegate: any, where: any, skip: number, take: number, include?: any) {
  try {
    const [data, total] = await Promise.all([
      prismaDelegate.findMany({ where, skip, take, include, orderBy: { createdAt: 'desc' } }),
      prismaDelegate.count({ where })
    ]);
    return { data, total };
  } catch (e: any) {
    if (e.name === 'PrismaClientValidationError') {
      return { data: [], total: 0 };
    }
    throw e;
  }
}

@Injectable()
export class AdminService {
  
  // ==========================================
  // AUTHENTICATION
  // ==========================================

  async login(adminLoginDto: AdminLoginDto) {
    const { email, password } = adminLoginDto;

    const admin = await prisma.user.findUnique({ where: { email } });
    if (!admin) throw new UnauthorizedException('Invalid credentials');

    const adminRoles: Role[] = [Role.SUPER_ADMIN, Role.SUB_ADMIN, Role.STATE_ADMIN];
    if (!adminRoles.includes(admin.role)) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isMatch = await bcrypt.compare(password, admin.password);
    if (!isMatch) throw new UnauthorizedException('Invalid credentials');

    const token = jwt.sign(
      { sub: admin.id, email: admin.email, role: admin.role, userId: admin.id },
      process.env.JWT_SECRET || '1234',
      { expiresIn: '24h' },
    );

    return { access_token: token, user: { id: admin.id, email: admin.email, role: admin.role, firstName: admin.firstName, gotra: admin.gotra } };
  }

  // ==========================================
  // DASHBOARD STATS
  // ==========================================

  async getDashboardStats() {
    const [
      totalUsers, pendingUsers,
      totalBusinesses, pendingBusinesses,
      totalJobs, pendingJobs,
      totalMatrimonials, pendingMatrimonials,
      totalNews, pendingNews
    ] = await Promise.all([
      prisma.user.count(),
      prisma.user.count({ where: { status: ProfileStatus.PENDING_APPROVAL } }),
      
      prisma.businessListing.count(),
      prisma.businessListing.count({ where: { status: ListingStatus.PENDING } }),
      
      prisma.jobBoard.count(),
      prisma.jobBoard.count({ where: { status: ListingStatus.PENDING } }),
      
      prisma.matrimonialProfile.count(),
      prisma.matrimonialProfile.count({ where: { status: MatrimonialStatus.PENDING } }),
      
      prisma.news.count(),
      prisma.news.count({ where: { status: 'DRAFT' } }),
    ]);

    return {
      users: { total: totalUsers, pending: pendingUsers },
      businesses: { total: totalBusinesses, pending: pendingBusinesses },
      jobs: { total: totalJobs, pending: pendingJobs },
      matrimonials: { total: totalMatrimonials, pending: pendingMatrimonials },
      news: { total: totalNews, pending: pendingNews },
      totalPending: pendingUsers + pendingBusinesses + pendingJobs + pendingMatrimonials + pendingNews,
    };
  }

  // ==========================================
  // DISTINCT VALUES
  // ==========================================

  async getDistinctValues(entity: string, field: string) {
    const modelMap: Record<string, any> = {
      'users': prisma.user,
      'businesses': prisma.businessListing,
      'jobs': prisma.jobBoard,
      'events': prisma.event,
      'matrimonials': prisma.matrimonialProfile,
      'shok-sandesh': prisma.shokSandesh,
      'news': prisma.news,
      'banners': prisma.banner,
    };

    const delegate = modelMap[entity];
    if (!delegate) {
      throw new Error('Invalid entity');
    }

    try {
      const distinct = await delegate.findMany({
        distinct: [field],
        select: { [field]: true }
      });
      const values = distinct
        .map((d: any) => d[field])
        .filter((val: any) => val !== '' && val !== null && val !== undefined);
      
      // Sort strings
      if (values.length > 0 && typeof values[0] === 'string') {
        values.sort();
      }
      return values;
    } catch (e) {
      // Return empty array if field is invalid or some error occurs
      return [];
    }
  }

  // ==========================================
  // USER APPROVALS
  // ==========================================

  async bulkCreateUsers(adminId: string, dto: BulkCreateUsersDto) {
    let createdCount = 0;
    let skippedCount = 0;

    const groupedUsers: Record<string, CsvUserDto[]> = {};
    for (const u of dto.users) {
      if (!groupedUsers[u.familyGroupIdentifier]) {
        groupedUsers[u.familyGroupIdentifier] = [];
      }
      groupedUsers[u.familyGroupIdentifier].push(u);
    }

    for (const [groupId, group] of Object.entries(groupedUsers)) {
      const newFamily = await prisma.family.create({
        data: { addedByUserId: adminId },
      });
      let headUserId: string | null = null;

      for (const u of group) {
        const exists = await prisma.user.findFirst({
          where: { OR: [{ email: u.email }, { phoneNumber: u.phoneNumber }] },
        });

        if (exists) {
          skippedCount++;
          continue;
        }

        const isHead = (u.relationshipToHead === 'SELF') || (!headUserId);

        const newUser = await prisma.user.create({
          data: {
            familyId: newFamily.id,
            isHeadOfFamily: isHead,
            firstName: u.firstName,
            fatherName: u.fatherName,
            motherName: u.motherName,
            gotra: u.gotra,
            spouseName: u.spouseName,
            husbandNameWithSurname: u.husbandNameWithSurname,
            sasuralGotra: u.sasuralGotra,
            gender: u.gender as Gender,
            maritalStatus: u.maritalStatus as MaritalStatus,
            dateOfBirth: new Date(u.dateOfBirth),
            bloodGroup: u.bloodGroup,
            email: u.email,
            education: u.education,
            occupationType: u.occupationType as OccupationType,
            gaon: u.gaon,
            nativeDistrict: u.nativeDistrict,
            nativeState: u.nativeState,
            currentAddress: u.currentAddress,
            currentCity: u.currentCity,
            currentState: u.currentState,
            pinCode: u.pinCode,
            phoneNumber: u.phoneNumber,
            whatsappNumber: u.whatsappNumber,
            isPhoneNumberVisible: String(u.isPhoneNumberVisible).toLowerCase() === 'true',
            relationshipToHead: u.relationshipToHead as RelationshipType,
            status: ProfileStatus.APPROVED,
          },
        });

        if (isHead && !headUserId) {
          headUserId = newUser.id;
          await prisma.family.update({
            where: { id: newFamily.id },
            data: { headOfFamilyId: headUserId },
          });
        }
        createdCount++;
      }
    }

    return { message: `Successfully created ${createdCount} users. Skipped ${skippedCount} duplicates.` };
  }

  async getUsers(status?: ProfileStatus, pageStr?: string, limitStr?: string, search?: string, filtersStr?: string) {
    const { skip, take, page, limit } = getPagination(pageStr, limitStr);
    const searchFields = ['firstName', 'fatherName', 'gotra', 'email', 'phoneNumber', 'gaon', 'currentCity'];
    const where = buildWhereClause(status, search, filtersStr, searchFields);

    const { data, total } = await fetchPaginatedData(prisma.user, where, skip, take);
    return { data, total, page, totalPages: Math.ceil(total / limit) };
  }

  async updateUser(id: string, dto: UpdateUserAdminDto) {
    const user = await prisma.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundException('User not found');
    return prisma.user.update({
      where: { id },
      data: dto,
    });
  }

  async approveUser(id: string) {
    const user = await prisma.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundException('User not found');

    const count = await prisma.user.count({ where: { status: ProfileStatus.APPROVED } });
    const memberId = `JJJF_${String(count + 1000).padStart(4, '0')}`; // Simple incremental ID generation

    return prisma.user.update({
      where: { id },
      data: { status: ProfileStatus.APPROVED, memberId },
    });
  }

  async rejectUser(id: string, dto: ApproveRejectDto) {
    const user = await prisma.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundException('User not found');
    return prisma.user.update({
      where: { id },
      data: { status: ProfileStatus.REJECTED }, // We might want to save reason in a separate table/field later if needed
    });
  }

  async blockUser(id: string) {
    const user = await prisma.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundException('User not found');
    return prisma.user.update({
      where: { id },
      data: { status: ProfileStatus.BLOCKED },
    });
  }

  // ==========================================
  // BUSINESS APPROVALS
  // ==========================================

  async getBusinesses(status?: ListingStatus, pageStr?: string, limitStr?: string, search?: string, filtersStr?: string) {
    const { skip, take, page, limit } = getPagination(pageStr, limitStr);
    const searchFields = ['businessName', 'description', 'contactNumber', 'city', 'state'];
    const where = buildWhereClause(status, search, filtersStr, searchFields);

    const { data, total } = await fetchPaginatedData(prisma.businessListing, where, skip, take, { owner: { select: { firstName: true, gotra: true, memberId: true } } });
    return { data, total, page, totalPages: Math.ceil(total / limit) };
  }

  async updateBusiness(id: string, dto: UpdateBusinessAdminDto) {
    const business = await prisma.businessListing.findUnique({ where: { id } });
    if (!business) throw new NotFoundException('Business not found');
    return prisma.businessListing.update({
      where: { id },
      data: dto,
    });
  }

  async approveBusiness(id: string) {
    const business = await prisma.businessListing.findUnique({ where: { id } });
    if (!business) throw new NotFoundException('Business not found');
    return prisma.businessListing.update({
      where: { id },
      data: { status: ListingStatus.APPROVED },
    });
  }

  async rejectBusiness(id: string, dto: ApproveRejectDto) {
    const business = await prisma.businessListing.findUnique({ where: { id } });
    if (!business) throw new NotFoundException('Business not found');
    return prisma.businessListing.update({
      where: { id },
      data: { status: ListingStatus.REJECTED },
    });
  }

  // ==========================================
  // JOB APPROVALS
  // ==========================================

  async createJob(adminId: string, dto: CreateJobAdminDto) {
    return prisma.jobBoard.create({
      data: {
        ...dto,
        postedById: adminId,
        status: ListingStatus.APPROVED,
      },
    });
  }

  async getJobs(status?: ListingStatus, pageStr?: string, limitStr?: string, search?: string, filtersStr?: string) {
    const { skip, take, page, limit } = getPagination(pageStr, limitStr);
    const searchFields = ['roleTitle', 'industry', 'city', 'description', 'contactName'];
    const where = buildWhereClause(status, search, filtersStr, searchFields);

    const { data, total } = await fetchPaginatedData(prisma.jobBoard, where, skip, take, { postedBy: { select: { firstName: true, gotra: true, memberId: true } } });
    return { data, total, page, totalPages: Math.ceil(total / limit) };
  }

  async updateJob(id: string, dto: UpdateJobAdminDto) {
    const job = await prisma.jobBoard.findUnique({ where: { id } });
    if (!job) throw new NotFoundException('Job not found');
    return prisma.jobBoard.update({
      where: { id },
      data: dto,
    });
  }

  async approveJob(id: string) {
    const job = await prisma.jobBoard.findUnique({ where: { id } });
    if (!job) throw new NotFoundException('Job not found');
    return prisma.jobBoard.update({
      where: { id },
      data: { status: ListingStatus.APPROVED },
    });
  }

  async rejectJob(id: string, dto: ApproveRejectDto) {
    const job = await prisma.jobBoard.findUnique({ where: { id } });
    if (!job) throw new NotFoundException('Job not found');
    return prisma.jobBoard.update({
      where: { id },
      data: { status: ListingStatus.REJECTED },
    });
  }

  async deleteJob(id: string) {
    const job = await prisma.jobBoard.findUnique({ where: { id } });
    if (!job) throw new NotFoundException('Job not found');
    return prisma.jobBoard.delete({
      where: { id }
    });
  }

  // ==========================================
  // MATRIMONIAL APPROVALS
  // ==========================================

  async getMatrimonials(status?: MatrimonialStatus, pageStr?: string, limitStr?: string, search?: string, filtersStr?: string) {
    const { skip, take, page, limit } = getPagination(pageStr, limitStr);
    const searchFields = ['subCaste', 'educationDetails', 'aboutMe'];
    const where = buildWhereClause(status, search, filtersStr, searchFields);

    const { data, total } = await fetchPaginatedData(prisma.matrimonialProfile, where, skip, take, { user: { select: { firstName: true, gotra: true, memberId: true, gender: true } } });
    return { data, total, page, totalPages: Math.ceil(total / limit) };
  }

  async updateMatrimonial(id: string, dto: UpdateMatrimonialAdminDto) {
    const profile = await prisma.matrimonialProfile.findUnique({ where: { id } });
    if (!profile) throw new NotFoundException('Matrimonial profile not found');
    return prisma.matrimonialProfile.update({
      where: { id },
      data: dto,
    });
  }

  async approveMatrimonial(id: string) {
    const profile = await prisma.matrimonialProfile.findUnique({ where: { id } });
    if (!profile) throw new NotFoundException('Matrimonial profile not found');
    return prisma.matrimonialProfile.update({
      where: { id },
      data: { status: MatrimonialStatus.APPROVED },
    });
  }

  async rejectMatrimonial(id: string, dto: ApproveRejectDto) {
    const profile = await prisma.matrimonialProfile.findUnique({ where: { id } });
    if (!profile) throw new NotFoundException('Matrimonial profile not found');
    return prisma.matrimonialProfile.update({
      where: { id },
      data: { status: MatrimonialStatus.REJECTED },
    });
  }

  // ==========================================
  // EVENT APPROVALS
  // ==========================================

  async getEvents(status?: EventStatus, pageStr?: string, limitStr?: string, search?: string, filtersStr?: string) {
    const { skip, take, page, limit } = getPagination(pageStr, limitStr);
    const searchFields = ['title', 'description', 'locationName'];
    const where = buildWhereClause(status, search, filtersStr, searchFields);

    const { data, total } = await fetchPaginatedData(prisma.event, where, skip, take);
    return { data, total, page, totalPages: Math.ceil(total / limit) };
  }

  async updateEvent(id: string, dto: UpdateEventAdminDto) {
    const event = await prisma.event.findUnique({ where: { id } });
    if (!event) throw new NotFoundException('Event not found');
    return prisma.event.update({
      where: { id },
      data: {
        title: dto.title,
        description: dto.description,
        eventDate: dto.eventDate ? new Date(dto.eventDate) : undefined,
        eventTime: dto.eventTime,
        locationName: dto.locationName,
        locationMapUrl: dto.locationMapUrl,
        photoUrls: dto.photoUrls,
      },
    });
  }

  async approveEvent(id: string) {
    const event = await prisma.event.findUnique({ where: { id } });
    if (!event) throw new NotFoundException('Event not found');
    return prisma.event.update({
      where: { id },
      data: { status: EventStatus.APPROVED },
    });
  }

  async rejectEvent(id: string, dto: ApproveRejectDto) {
    const event = await prisma.event.findUnique({ where: { id } });
    if (!event) throw new NotFoundException('Event not found');
    return prisma.event.update({
      where: { id },
      data: { status: EventStatus.REJECTED },
    });
  }

  // ==========================================
  // SHOK SANDESH APPROVALS
  // ==========================================

  async getShokSandesh(status?: DemiseStatus, pageStr?: string, limitStr?: string, search?: string, filtersStr?: string) {
    const { skip, take, page, limit } = getPagination(pageStr, limitStr);
    const searchFields = ['deceasedName', 'nativeVillage', 'funeralDetails', 'survivingFamily', 'contactPerson'];
    const where = buildWhereClause(status, search, filtersStr, searchFields);

    const { data, total } = await fetchPaginatedData(prisma.shokSandesh, where, skip, take);
    return { data, total, page, totalPages: Math.ceil(total / limit) };
  }

  async updateShokSandesh(id: string, dto: UpdateShokSandeshAdminDto) {
    const shok = await prisma.shokSandesh.findUnique({ where: { id } });
    if (!shok) throw new NotFoundException('Shok Sandesh not found');
    
    const updateData: any = { ...dto };
    if (dto.dateDemised) {
      updateData.dateDemised = new Date(dto.dateDemised);
    }

    return prisma.shokSandesh.update({
      where: { id },
      data: updateData,
    });
  }

  async approveShokSandesh(id: string, adminId: string) {
    const shok = await prisma.shokSandesh.findUnique({ where: { id } });
    if (!shok) throw new NotFoundException('Shok Sandesh not found');
    return prisma.shokSandesh.update({
      where: { id },
      data: { status: DemiseStatus.APPROVED, approvedById: adminId },
    });
  }

  async rejectShokSandesh(id: string, dto: ApproveRejectDto, adminId: string) {
    const shok = await prisma.shokSandesh.findUnique({ where: { id } });
    if (!shok) throw new NotFoundException('Shok Sandesh not found');
    return prisma.shokSandesh.update({
      where: { id },
      data: { status: DemiseStatus.REJECTED, approvedById: adminId },
    });
  }

  // ==========================================
  // NEWS APPROVALS
  // ==========================================

  async createNews(adminId: string, dto: CreateNewsAdminDto) {
    const admin = await prisma.user.findUnique({ where: { id: adminId } });
    if (!admin) throw new NotFoundException('Admin user not found');
    const userName = `${admin.firstName} ${admin.gotra || ''}`.trim();
    return prisma.news.create({
      data: {
        ...dto,
        userId: adminId,
        userName,
        status: 'APPROVED',
      },
    });
  }

  async getNews(status?: string, pageStr?: string, limitStr?: string, search?: string, filtersStr?: string) {
    const { skip, take, page, limit } = getPagination(pageStr, limitStr);
    const searchFields = ['title', 'description', 'userName'];
    const where = buildWhereClause(status, search, filtersStr, searchFields);

    const { data, total } = await fetchPaginatedData(prisma.news, where, skip, take);
    return { data, total, page, totalPages: Math.ceil(total / limit) };
  }

  async updateNews(id: string, dto: UpdateNewsAdminDto) {
    const news = await prisma.news.findUnique({ where: { id } });
    if (!news) throw new NotFoundException('News not found');
    return prisma.news.update({
      where: { id },
      data: dto,
    });
  }

  async approveNews(id: string) {
    const news = await prisma.news.findUnique({ where: { id } });
    if (!news) throw new NotFoundException('News not found');
    return prisma.news.update({
      where: { id },
      data: { status: 'APPROVED' },
    });
  }

  async rejectNews(id: string) {
    const news = await prisma.news.findUnique({ where: { id } });
    if (!news) throw new NotFoundException('News not found');
    // News only has DRAFT and APPROVED in prisma, so we can either delete it or leave it as DRAFT.
    // For now, we will leave it as DRAFT but could also delete.
    // Or if they change the schema, it will set to REJECTED.
    // Given the constraints, let's delete it if rejected.
    return prisma.news.delete({
      where: { id }
    });
  }

  async deleteNews(id: string) {
    const news = await prisma.news.findUnique({ where: { id } });
    if (!news) throw new NotFoundException('News not found');
    return prisma.news.delete({
      where: { id }
    });
  }

  // ==========================================
  // STATE ADMINS
  // ==========================================

  async getStateAdmins() {
    return prisma.stateAdmin.findMany({
      include: {
        admin: {
          select: {
            id: true,
            firstName: true,
            email: true,
            phoneNumber: true,
          }
        }
      },
      orderBy: { stateName: 'asc' }
    });
  }

  async assignStateAdmin(stateAdminId: string, userId: string | null) {
    const stateAdmin = await prisma.stateAdmin.findUnique({ where: { id: stateAdminId } });
    if (!stateAdmin) throw new NotFoundException('State not found');

    if (userId) {
      const user = await prisma.user.findUnique({ where: { id: userId } });
      if (!user) throw new NotFoundException('User not found');
      
      // Update the user's role to STATE_ADMIN if they aren't already
      if (user.role === Role.MEMBER) {
        await prisma.user.update({
          where: { id: userId },
          data: { role: Role.STATE_ADMIN }
        });
      }
    }

    return prisma.stateAdmin.update({
      where: { id: stateAdminId },
      data: { adminId: userId },
      include: {
        admin: {
          select: {
            id: true,
            firstName: true,
            email: true,
          }
        }
      }
    });
  }
}
