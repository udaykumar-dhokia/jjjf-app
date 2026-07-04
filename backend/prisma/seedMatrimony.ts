import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Seeding Matrimonial Profiles for existing users...');
  
  // Fetch all users
  const users = await prisma.user.findMany();
  console.log(`Found ${users.length} users in the database.`);
  
  let createdCount = 0;
  
  for (const user of users) {
    // Check if profile already exists
    const existing = await prisma.matrimonialProfile.findUnique({
      where: { userId: user.id },
    });
    
    if (!existing) {
      await prisma.matrimonialProfile.create({
        data: {
          userId: user.id,
          height: "5'8\"",
          weight: 70,
          subCaste: user.gotra || "Unknown",
          educationDetails: "Bachelor's Degree",
          monthlyIncome: "50,000",
          aboutMe: `Hello, my name is ${user.firstName}. I am looking for a suitable partner.`,
          expectations: "Looking for a caring and understanding partner.",
          photoGallery: user.photoUrl ? [user.photoUrl] : [],
          status: 'APPROVED', 
        },
      });
      createdCount++;
    }
  }
  
  console.log(`Seeding complete. Created ${createdCount} new profiles.`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
