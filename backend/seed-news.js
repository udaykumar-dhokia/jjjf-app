import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const dummyPosts = Array.from({ length: 20 }).map((_, i) => ({
  title: `News Update ${i + 1}: Important community announcement`,
  description: `This is a randomly generated description for news post number ${i + 1}. It contains some variable length content to test the UI. ` + "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ".repeat(Math.floor(Math.random() * 5) + 2),
  images: [],
  status: 'APPROVED',
}));

async function main() {
  console.log('Fetching existing users...');
  
  const users = await prisma.user.findMany({
    where: { status: 'APPROVED' }
  });

  if (users.length === 0) {
    throw new Error("No approved users found in the database. Please create some users first.");
  }

  console.log(`Found ${users.length} approved users. Seeding 20 dummy news posts...`);

  let count = 0;
  for (const post of dummyPosts) {
    // Pick a random user
    const user = users[Math.floor(Math.random() * users.length)];
    const userName = user.firstName ? `${user.firstName} ${user.lastName || ''}`.trim() : 'Community Member';

    await prisma.news.create({
      data: {
        ...post,
        userId: user.id,
        userName: userName,
      }
    });
    count++;
  }

  console.log(`Successfully seeded ${count} news posts distributed among existing users!`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
