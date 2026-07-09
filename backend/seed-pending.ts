import { PrismaClient, ProfileStatus, ListingStatus, EventStatus, DemiseStatus, MatrimonialStatus, Gender, MaritalStatus, OccupationType, RelationshipType, BusinessCategory, JobType } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding pending data...');

  const family = await prisma.family.create({
    data: {
      addedByUserId: '65f1a2b3c4d5e6f7a8b9c0d1' // dummy objectid
    }
  });

  const uniqueId = Date.now().toString();
  const user = await prisma.user.create({
    data: {
      phoneNumber: `99${uniqueId.substring(4)}`,
      memberId: `PENDING_USER_${uniqueId}`,
      firstName: 'Pending',
      fatherName: 'Father',
      gotra: 'Jain',
      gender: Gender.MALE,
      maritalStatus: MaritalStatus.SINGLE,
      dateOfBirth: new Date('1990-01-01'),
      bloodGroup: 'O+',
      gaon: 'Village',
      nativeDistrict: 'District',
      nativeState: 'State',
      currentCity: 'City',
      currentState: 'State',
      occupationType: OccupationType.BUSINESS_OWNER,
      isPhoneNumberVisible: true,
      relationshipToHead: RelationshipType.SELF,
      familyId: family.id,
      email: `pending_${uniqueId}@example.com`,
      status: ProfileStatus.PENDING_APPROVAL,
    },
  });
  console.log('Created pending user');

  await prisma.businessListing.create({
    data: {
      businessName: 'Pending Business',
      category: BusinessCategory.RETAIL,
      description: 'A pending business listing',
      contactNumber: '8888888888',
      address: '123 Business St',
      city: 'Mumbai',
      state: 'Maharashtra',
      status: ListingStatus.PENDING,
      ownerId: user.id,
    },
  });
  console.log('Created pending business');

  await prisma.jobBoard.create({
    data: {
      roleTitle: 'Software Engineer',
      type: JobType.VACANCY_AVAILABLE,
      description: 'We need an engineer',
      industry: 'IT',
      city: 'Pune',
      contactName: 'HR',
      status: ListingStatus.PENDING,
      postedById: user.id,
    },
  });
  console.log('Created pending job');

  await prisma.matrimonialProfile.create({
    data: {
      userId: user.id,
      subCaste: 'Bisa',
      educationDetails: 'B.Tech',
      monthlyIncome: '10 LPA',
      status: MatrimonialStatus.PENDING,
    },
  });
  console.log('Created pending matrimonial');

  await prisma.event.create({
    data: {
      title: 'Pending Community Event',
      description: 'An event waiting for approval',
      eventDate: new Date(),
      eventTime: '10:00 AM',
      locationName: 'Community Hall',
      status: EventStatus.PENDING,
      createdBy: user.id,
    },
  });
  console.log('Created pending event');

  await prisma.shokSandesh.create({
    data: {
      deceasedName: 'Late Shok Sandesh',
      age: 85,
      dateDemised: new Date(),
      nativeVillage: 'Village',
      funeralDetails: 'At local ground',
      survivingFamily: 'Sons and Daughters',
      contactPerson: 'Son',
      contactPhone: '9999999999',
      status: DemiseStatus.PENDING,
    },
  });
  console.log('Created pending shok sandesh');

  console.log('Seed completed successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
