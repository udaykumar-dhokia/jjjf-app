import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  const result = await prisma.user.updateMany({
    data: { 
      password: '$2b$10$M22AWip9WhljtCIkVeD7yuCXcZb0OUx/VcaIbA6w7XTDegDOHwYYG' 
    }
  });
  console.log(`Updated ${result.count} users with default password.`);
}

main()
  .catch(console.error)
  .finally(() => prisma.$disconnect());
