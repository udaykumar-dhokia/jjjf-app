import { Controller, Get, Post, Body, Patch, Param, Delete, Put, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { JobsService } from './jobs.service.js';
import { CreateJobDto } from './dto/create-job.dto.js';
import { UpdateJobDto } from './dto/update-job.dto.js';
import { FilterJobsDto } from './dto/filter-jobs.dto.js';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';

@ApiTags('Jobs')
@Controller('jobs')
export class JobsController {
  constructor(private readonly jobsService: JobsService) {}

  /**
   * Creates a new job posting or request.
   *
   * @param req - The HTTP request containing the authenticated user.
   * @param createJobDto - The job details.
   * @returns The created job board entry.
   */
  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a new job posting or request' })
  @ApiResponse({ status: 201, description: 'The job posting has been successfully created.' })
  create(@Request() req, @Body() createJobDto: CreateJobDto) {
    return this.jobsService.create(req.user.id, createJobDto);
  }

  /**
   * Retrieves all job postings and requests with optional filtering.
   *
   * @param filters - The filtering parameters (type, city, industry, search).
   * @returns Array of job board entries.
   */
  @Get()
  @ApiOperation({ summary: 'Get all job postings and requests' })
  @ApiResponse({ status: 200, description: 'Return all job postings.' })
  findAll(@Query() filters: FilterJobsDto) {
    return this.jobsService.findAll(filters);
  }

  /**
   * Retrieves unique cities and industries for filter dropdowns.
   *
   * @returns Object with arrays of cities and industries.
   */
  @Get('metadata')
  @ApiOperation({ summary: 'Get unique cities and industries for filtering' })
  @ApiResponse({ status: 200, description: 'Return metadata.' })
  getMetadata() {
    return this.jobsService.getMetadata();
  }

  /**
   * Retrieves a specific job posting by its ID.
   *
   * @param id - The ID of the job posting.
   * @returns The job board entry.
   */
  @Get(':id')
  @ApiOperation({ summary: 'Get a specific job posting by id' })
  @ApiResponse({ status: 200, description: 'Return the job posting.' })
  @ApiResponse({ status: 404, description: 'Job posting not found.' })
  findOne(@Param('id') id: string) {
    return this.jobsService.findOne(id);
  }

  /**
   * Updates a job posting by its ID.
   *
   * @param id - The ID of the job posting.
   * @param updateJobDto - The fields to update.
   * @returns The updated job board entry.
   */
  @Put(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update a job posting' })
  @ApiResponse({ status: 200, description: 'The job posting has been successfully updated.' })
  @ApiResponse({ status: 404, description: 'Job posting not found.' })
  update(@Param('id') id: string, @Body() updateJobDto: UpdateJobDto) {
    return this.jobsService.update(id, updateJobDto);
  }

  /**
   * Deletes a job posting by its ID.
   *
   * @param id - The ID of the job posting.
   * @returns The deleted job board entry.
   */
  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Delete a job posting' })
  @ApiResponse({ status: 200, description: 'The job posting has been successfully deleted.' })
  @ApiResponse({ status: 404, description: 'Job posting not found.' })
  remove(@Param('id') id: string) {
    return this.jobsService.remove(id);
  }
}
