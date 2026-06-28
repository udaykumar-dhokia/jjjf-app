import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaClient } from '@prisma/client';
import * as crypto from 'crypto';

const prisma = new PrismaClient();

@Injectable()
export class TokenUtilService {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}


  /**
   * Generates an access token and a refresh token for a user.
   *
   * @param userId - The unique identifier of the user.
   * @param email - The user's email address.
   * @param role - The role assigned to the user (e.g., "admin", "user").
   * @param isProfileComplete - Indicates if the user has completed their profile.
   * @returns An object containing the signed `accessToken` (short‑lived) and
   *   `refreshToken` (long‑lived). The refresh token is also persisted in
   *   the database with an expiry of seven days.
   */
  async generateTokens(userId: string, email: string, role: string, isProfileComplete: boolean) {
    const payload = { sub: userId, email, role, isProfileComplete };

    const accessToken = this.jwtService.sign(payload, {
      secret: this.configService.get<string>('JWT_SECRET') || 'defaultSecret',
      expiresIn: '15m',
    });

    const refreshTokenString = this.jwtService.sign(
      { ...payload, jti: crypto.randomUUID() },
      {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET') || 'defaultRefreshSecret',
        expiresIn: '7d',
      }
    );

    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    // Clean up expired tokens for this user
    await prisma.refreshToken.deleteMany({
      where: {
        userId,
        expiresAt: { lt: new Date() },
      },
    });

    await prisma.refreshToken.create({
      data: {
        token: refreshTokenString,
        userId,
        expiresAt,
      }
    });

    return {
      accessToken,
      refreshToken: refreshTokenString,
    };
  }
}
