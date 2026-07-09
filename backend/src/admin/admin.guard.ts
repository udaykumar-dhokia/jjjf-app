import { Injectable, CanActivate, ExecutionContext, UnauthorizedException, ForbiddenException } from '@nestjs/common';
import { Role } from '@prisma/client';

@Injectable()
export class AdminGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      throw new UnauthorizedException('User not authenticated');
    }

    // Check if the user's role is one of the admin roles
    const adminRoles: string[] = [Role.SUPER_ADMIN, Role.SUB_ADMIN, Role.STATE_ADMIN];
    if (!adminRoles.includes(user.role)) {
      throw new ForbiddenException('Access denied: Admins only');
    }

    return true;
  }
}
