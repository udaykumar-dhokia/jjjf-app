import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('Starting family cleanup...');

  // Set familyId to null for all users
  const updateUsers = await prisma.user.updateMany({
    data: {
      familyId: null,
      isHeadOfFamily: false,
      relationshipToHead: null,
    },
  });

  console.log(`Updated ${updateUsers.count} users to have no family.`);

  // Delete all families
  const deleteFamilies = await prisma.family.deleteMany({});
  
  console.log(`Deleted ${deleteFamilies.count} families.`);
  
  console.log('Cleanup complete.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
