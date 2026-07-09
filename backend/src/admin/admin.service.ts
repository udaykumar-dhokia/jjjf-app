import { Injectable, UnauthorizedException, NotFoundException } from '@nestjs/common';
import { PrismaClient, ProfileStatus, ListingStatus, EventStatus, DemiseStatus, MatrimonialStatus, Role } from '@prisma/client';
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

const prisma = new PrismaClient();

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
    const [pendingUsers, pendingBusinesses, pendingJobs, pendingEvents, pendingMatrimonials, pendingShokSandesh, pendingNews] = await Promise.all([
      prisma.user.count({ where: { status: ProfileStatus.PENDING_APPROVAL } }),
      prisma.businessListing.count({ where: { status: ListingStatus.PENDING } }),
      prisma.jobBoard.count({ where: { status: ListingStatus.PENDING } }),
      prisma.event.count({ where: { status: EventStatus.PENDING } }),
      prisma.matrimonialProfile.count({ where: { status: MatrimonialStatus.PENDING } }),
      prisma.shokSandesh.count({ where: { status: DemiseStatus.PENDING } }),
      prisma.news.count({ where: { status: 'DRAFT' } }),
    ]);

    return {
      pendingUsers,
      pendingBusinesses,
      pendingJobs,
      pendingEvents,
      pendingMatrimonials,
      pendingShokSandesh,
      pendingNews,
      totalPending: pendingUsers + pendingBusinesses + pendingJobs + pendingEvents + pendingMatrimonials + pendingShokSandesh + pendingNews,
    };
  }

  // ==========================================
  // USER APPROVALS
  // ==========================================

  async getUsers(status?: ProfileStatus) {
    return prisma.user.findMany({
      where: status ? { status } : undefined,
      orderBy: { createdAt: 'desc' },
    });
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

  async getBusinesses(status?: ListingStatus) {
    return prisma.businessListing.findMany({
      where: status ? { status } : undefined,
      include: { owner: { select: { firstName: true, gotra: true, memberId: true } } },
      orderBy: { createdAt: 'desc' },
    });
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

  async getJobs(status?: ListingStatus) {
    return prisma.jobBoard.findMany({
      where: status ? { status } : undefined,
      include: { postedBy: { select: { firstName: true, gotra: true, memberId: true } } },
      orderBy: { createdAt: 'desc' },
    });
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

  // ==========================================
  // MATRIMONIAL APPROVALS
  // ==========================================

  async getMatrimonials(status?: MatrimonialStatus) {
    return prisma.matrimonialProfile.findMany({
      where: status ? { status } : undefined,
      include: { user: { select: { firstName: true, gotra: true, memberId: true, gender: true } } },
      orderBy: { createdAt: 'desc' },
    });
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

  async getEvents(status?: EventStatus) {
    return prisma.event.findMany({
      where: status ? { status } : undefined,
      orderBy: { createdAt: 'desc' },
    });
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

  async getShokSandesh(status?: DemiseStatus) {
    return prisma.shokSandesh.findMany({
      where: status ? { status } : undefined,
      orderBy: { createdAt: 'desc' },
    });
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

  async getNews(status?: any) {
    return prisma.news.findMany({
      where: status ? { status } : undefined,
      orderBy: { createdAt: 'desc' },
    });
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
}
