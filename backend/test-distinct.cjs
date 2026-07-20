const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
async function run() {
  try {
    const res = await prisma.user.findMany({
      distinct: ['currentCity'],
      select: { currentCity: true },
      where: { currentCity: { not: null } }
    });
    console.log("Distinct result:", res);
  } catch (e) {
    console.error("Error occurred:", e);
  } finally {
    await prisma.$disconnect();
  }
}
run();
