import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaClient, ListingStatus, JobType } from '@prisma/client';
import { CreateJobDto } from './dto/create-job.dto.js';
import { UpdateJobDto } from './dto/update-job.dto.js';
import { FilterJobsDto } from './dto/filter-jobs.dto.js';

const prisma = new PrismaClient();

@Injectable()
export class JobsService {
  /**
   * Creates a new job posting or request.
   *
   * @param postedById - ID of the user creating the job post.
   * @param createJobDto - DTO containing job details.
   * @returns The created job board entry.
   */
  async create(postedById: string, createJobDto: CreateJobDto) {
    return prisma.jobBoard.create({
      data: {
        ...createJobDto,
        postedById,
        status: ListingStatus.APPROVED, // Defaulting to APPROVED for testing as requested
      },
    });
  }

  /**
   * Retrieves all job board entries, with optional filtering.
   * 
   * @param filters - DTO containing optional filters like type, city, industry, status, and search.
   * @returns Array of job board entries with poster's basic info.
   */
  async findAll(filters: FilterJobsDto) {
    const whereClause: any = {
      status: filters.status || ListingStatus.APPROVED,
    };

    if (filters.type) {
      whereClause.type = filters.type;
    }
    
    if (filters.city) {
      const cities = filters.city.split(',').map(s => s.trim()).filter(Boolean);
      if (cities.length > 0) {
        whereClause.city = { in: cities };
      }
    }

    if (filters.industry) {
      const industries = filters.industry.split(',').map(s => s.trim()).filter(Boolean);
      if (industries.length > 0) {
        whereClause.industry = { in: industries };
      }
    }

    if (filters.jobRole) {
      const roles = filters.jobRole.split(',').map(s => s.trim()).filter(Boolean);
      if (roles.length > 0) {
        whereClause.roleTitle = { in: roles };
      }
    }

    if (filters.search) {
      whereClause.OR = [
        { roleTitle: { contains: filters.search, mode: 'insensitive' } },
        { description: { contains: filters.search, mode: 'insensitive' } },
      ];
    }

    return prisma.jobBoard.findMany({
      where: whereClause,
      include: {
        postedBy: {
          select: {
            id: true,
            firstName: true,
            fatherName: true,
            gotra: true,
            photoUrl: true,
          }
        }
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  /**
   * Retrieves unique cities and industries for the filter dropdowns.
   * @returns An object containing arrays of cities and industries.
   */
  async getMetadata() {
    const jobs = await prisma.jobBoard.findMany({
      where: { status: ListingStatus.APPROVED },
      select: { city: true, industry: true, roleTitle: true },
    });

    const cities = [...new Set(jobs.map(j => j.city))].filter(Boolean).sort();
    const industries = [...new Set(jobs.map(j => j.industry))].filter(Boolean).sort();
    const jobRoles = [...new Set(jobs.map(j => j.roleTitle))].filter(Boolean).sort();

    return { cities, industries, jobRoles };
  }

  /**
   * Retrieves a single job board entry by ID.
   * 
   * @param id - Job board entry identifier.
   * @returns The job board entry.
   * @throws NotFoundException if not found.
   */
  async findOne(id: string) {
    const job = await prisma.jobBoard.findUnique({
      where: { id },
      include: {
        postedBy: {
          select: {
            id: true,
            firstName: true,
            fatherName: true,
            gotra: true,
            phoneNumber: true,
            photoUrl: true,
          }
        }
      },
    });

    if (!job) {
      throw new NotFoundException('Job board entry not found');
    }
    return job;
  }

  /**
   * Updates an existing job board entry.
   * 
   * @param id - Job board entry identifier.
   * @param updateJobDto - DTO with updated fields.
   * @returns Updated job board entry.
   * @throws NotFoundException if entry does not exist.
   */
  async update(id: string, updateJobDto: UpdateJobDto) {
    const job = await prisma.jobBoard.findUnique({ where: { id } });
    if (!job) {
      throw new NotFoundException('Job board entry not found');
    }
    return prisma.jobBoard.update({
      where: { id },
      data: updateJobDto,
    });
  }

  /**
   * Deletes a job board entry by ID.
   * 
   * @param id - Job board entry identifier.
   * @returns Deleted job board entry.
   * @throws NotFoundException if entry does not exist.
   */
  async remove(id: string) {
    const job = await prisma.jobBoard.findUnique({ where: { id } });
    if (!job) {
      throw new NotFoundException('Job board entry not found');
    }
    return prisma.jobBoard.delete({ where: { id } });
  }
}
