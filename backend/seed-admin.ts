import { PrismaClient, Gender, MaritalStatus, OccupationType, RelationshipType, Role, ProfileStatus } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding admin user...');
  const email = 'admin@admin.com';
  const passwordHash = await bcrypt.hash('admin@123', 10);
  
  const adminExists = await prisma.user.findUnique({ where: { email } });
  if (!adminExists) {
    // Generate a mock object ID for addedByUserId
    const mockObjectId = '000000000000000000000000';
    
    await prisma.user.create({
      data: {
        email,
        firstName: 'System',
        fatherName: 'Admin',
        gotra: 'Admin',
        gender: Gender.OTHER,
        maritalStatus: MaritalStatus.SINGLE,
        dateOfBirth: new Date('1980-01-01'),
        occupationType: OccupationType.OTHER,
        gaon: 'HQ',
        nativeDistrict: 'HQ',
        nativeState: 'HQ',
        currentCity: 'HQ',
        currentState: 'HQ',
        phoneNumber: '0000000000',
        isPhoneNumberVisible: false,
        relationshipToHead: RelationshipType.SELF,
        status: ProfileStatus.APPROVED,
        isProfileComplete: true,
        memberId: 'ADMIN-001',
        role: Role.SUPER_ADMIN,
        password: passwordHash,
        family: {
          create: {
            addedByUserId: mockObjectId,
          }
        }
      }
    });
    console.log(`Admin user created successfully: ${email}`);
  } else {
    console.log(`Admin user already exists: ${email}`);
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
