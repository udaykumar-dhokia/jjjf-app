import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaClient } from '@prisma/client';
import { EmailService } from '../email/email.service.js';
import { RedisService } from '../redis/redis.service.js';
import { TokenUtilService } from './utils/token.util.js';

const prisma = new PrismaClient();

@Injectable()
export class AuthService {
  constructor(
    private readonly emailService: EmailService,
    private readonly redisService: RedisService,
    private readonly tokenUtil: TokenUtilService,
  ) {}

  /**
   * Sends a one‑time password (OTP) to the specified email address.
   *
   * @param email - Recipient email address.
   * @returns An object containing a success message.
   */
  async sendOtp(email: string) {
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    
    await this.redisService.set(`otp:${email}`, otp, 300);

    await this.emailService.sendOtpEmail(email, otp);

    return { message: 'OTP sent successfully' };
  }

  /**
   * Verifies the OTP supplied by the user and creates a new user if one does not
   * already exist.
   *
   * @param email - The email address used to send the OTP.
   * @param otp - The OTP entered by the user.
   * @returns An object containing JWT tokens and a flag indicating whether a
   *   new user was created.
   */
  async verifyOtp(email: string, otp: string) {
    const storedOtp = await this.redisService.get(`otp:${email}`);
    if (!storedOtp || storedOtp !== otp) {
      throw new UnauthorizedException('Invalid or expired OTP');
    }

    await this.redisService.del(`otp:${email}`);

    let user = await prisma.user.findUnique({ where: { email } });
    let isNewUser = false;
    
    if (!user) {
      isNewUser = true;

      user = await prisma.user.create({
        data: {
          email,
          memberId: `TEMP_${Date.now()}_${Math.floor(Math.random() * 10000)}`,
          firstName: 'New',
          fatherName: 'User',
          gotra: 'Unknown',
          gender: 'OTHER',
          maritalStatus: 'SINGLE',
          dateOfBirth: new Date(),
          occupationType: 'OTHER',
          gaon: 'Unknown',
          nativeDistrict: 'Unknown',
          nativeState: 'Unknown',
          currentCity: 'Unknown',
          currentState: 'Unknown',
          phoneNumber: `temp_${Date.now()}`,
          isPhoneNumberVisible: false,
          relationshipToHead: 'SELF',
          family: {
            create: {
              addedByUserId: '000000000000000000000000', 
            }
          }
        }
      });
      
      const family = await prisma.family.findFirst({ where: { members: { some: { id: user.id } } } });
      if (family) {
          await prisma.family.update({
              where: { id: family.id },
              data: { headOfFamilyId: user.id, addedByUserId: user.id }
          });
      }
    }

    const tokens = await this.tokenUtil.generateTokens(user.id, user.email || '', user.role, user.isProfileComplete);
    return { ...tokens, isNewUser, isProfileComplete: user.isProfileComplete };
  }

  /**
   * Generates a new pair of access and refresh tokens using a valid refresh
   * token.
   *
   * @param userId - The ID of the user requesting new tokens.
   * @param refreshToken - The refresh token previously issued to the user.
   * @returns A new set of JWT tokens.
   */
  async refreshTokens(userId: string, refreshToken: string) {
    const tokenRecord = await prisma.refreshToken.findUnique({
      where: { token: refreshToken }
    });

    if (!tokenRecord || tokenRecord.userId !== userId) {
      throw new UnauthorizedException('Invalid refresh token');
    }

    if (new Date() > tokenRecord.expiresAt) {
      await prisma.refreshToken.deleteMany({ where: { token: refreshToken } });
      throw new UnauthorizedException('Refresh token expired');
    }

    const user = await prisma.user.findUnique({ where: { id: userId } });
    if (!user) throw new UnauthorizedException('User not found');

    await prisma.refreshToken.deleteMany({ where: { token: refreshToken } });

    return this.tokenUtil.generateTokens(user.id, user.email || '', user.role, user.isProfileComplete);
  }

  /**
   * Invalidates the provided refresh token, effectively logging the user out.
   *
   * @param refreshToken - The refresh token to delete.
   * @returns An object containing a success message.
   */
  async logout(refreshToken: string) {
    if (refreshToken) {
      await prisma.refreshToken.deleteMany({
        where: { token: refreshToken }
      });
    }
    return { message: 'Logged out successfully' };
  }

  /**
   * Verifies the password supplied by the user.
   *
   * @param email - The email address.
   * @param password - The password entered by the user.
   * @returns An object containing JWT tokens.
   */
  async loginWithPassword(email: string, password: string) {
    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) {
      throw new UnauthorizedException('Invalid email or password');
    }

    const bcrypt = await import('bcryptjs');
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid email or password');
    }

    const tokens = await this.tokenUtil.generateTokens(user.id, user.email || '', user.role, user.isProfileComplete);
    
    return {
      ...tokens,
      isNewUser: false,
      isProfileComplete: user.isProfileComplete,
    };
  }
}
