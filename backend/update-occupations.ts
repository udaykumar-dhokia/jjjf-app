import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const users = await prisma.user.findMany();
  for (const user of users) {
    if (!user.occupationDetails) {
      await prisma.user.update({
        where: { id: user.id },
        data: {
          occupationDetails: {
            companyName: "Tech Corp Innovations",
            designation: "Senior Developer",
            industry: "Information Technology",
            city: user.currentCity,
          }
        }
      });
    }
  }
  console.log('Updated users with dummy occupation details!');
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
