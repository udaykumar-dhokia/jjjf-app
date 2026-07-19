import { PrismaClient } from '@prisma/client';
const prisma = new PrismaClient();
prisma.user.findMany({ where: { role: 'SUPER_ADMIN' } }).then(users => {
  console.log(JSON.stringify(users, null, 2));
  prisma.$disconnect();
}).catch(e => {
  console.error(e);
  prisma.$disconnect();
});
