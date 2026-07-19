import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log("Updating news posts...");
  const result = await prisma.news.updateMany({
    where: {
      isShokSandesh: {
        isSet: false
      }
    },
    data: {
      isShokSandesh: false
    }
  });
  console.log("Updated news posts:", result.count);
}

main()
  .catch(e => console.error(e))
  .finally(() => prisma.$disconnect());
