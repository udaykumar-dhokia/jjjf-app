import { PrismaClient, ProfileStatus, ListingStatus, EventStatus, DemiseStatus, MatrimonialStatus, Gender, MaritalStatus, OccupationType, BusinessCategory, JobType } from '@prisma/client';
const prisma = new PrismaClient();
async function main() {
    console.log('Seeding pending data...');
    // 1. Pending User
    const user = await prisma.user.create({
        data: {
            phoneNumber: '9999999999',
            memberId: 'PENDING_USER_1',
            firstName: 'Pending',
            lastName: 'User',
            email: 'pending@example.com',
            gotra: 'Jain',
            gender: Gender.MALE,
            maritalStatus: MaritalStatus.SINGLE,
            bloodGroup: 'O+',
            nativeVillage: 'Village',
            currentCity: 'City',
            currentState: 'State',
            occupation: OccupationType.BUSINESS,
            status: ProfileStatus.PENDING_APPROVAL,
        },
    });
    console.log('Created pending user');
    // 2. Pending Business
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
            userId: user.id,
        },
    });
    console.log('Created pending business');
    // 3. Pending Job
    await prisma.jobBoard.create({
        data: {
            roleTitle: 'Software Engineer',
            type: JobType.VACANCY_AVAILABLE,
            description: 'We need an engineer',
            industry: 'IT',
            city: 'Pune',
            status: ListingStatus.PENDING,
            userId: user.id,
        },
    });
    console.log('Created pending job');
    // 4. Pending Matrimonial Profile
    await prisma.matrimonialProfile.create({
        data: {
            userId: user.id,
            dateOfBirth: new Date(),
            height: 175,
            subCaste: 'Bisa',
            educationDetails: 'B.Tech',
            occupationDetails: 'Software Engineer',
            annualIncome: '10 LPA',
            fatherName: 'Father',
            motherName: 'Mother',
            nativePlace: 'Village',
            status: MatrimonialStatus.PENDING,
        },
    });
    console.log('Created pending matrimonial');
    // 5. Pending Event
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
    // 6. Pending Shok Sandesh
    await prisma.shokSandesh.create({
        data: {
            deceasedName: 'Late Shok Sandesh',
            age: 85,
            dateDemised: new Date(),
            nativeVillage: 'Village',
            description: 'Sad demise',
            photoUrl: '',
            submittedById: user.id,
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
