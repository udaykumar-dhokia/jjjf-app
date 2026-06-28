import { PrismaClient, OccupationType, BusinessCategory, ListingStatus } from '@prisma/client';

const prisma = new PrismaClient();

const sampleBusinesses = [
  { name: 'Tech Solutions Pvt Ltd', category: BusinessCategory.IT, description: 'Leading provider of enterprise software solutions.' },
  { name: 'Global Finance Advisors', category: BusinessCategory.FINANCE, description: 'Expert financial planning and investment consulting.' },
  { name: 'Fresh Retail Mart', category: BusinessCategory.RETAIL, description: 'Your everyday grocery and essentials store.' },
  { name: 'Elite Manufacturing Hub', category: BusinessCategory.MANUFACTURING, description: 'High-quality industrial parts and machinery.' },
  { name: 'City Hospital & Clinic', category: BusinessCategory.HEALTHCARE, description: 'Comprehensive medical and health services.' },
  { name: 'Prime Real Estate', category: BusinessCategory.REAL_ESTATE, description: 'Premium commercial and residential properties.' },
  { name: 'Modern Education Group', category: BusinessCategory.EDUCATION, description: 'Transforming education for the next generation.' },
  { name: 'Speed Logistics', category: BusinessCategory.LOGISTICS, description: 'Fast and reliable supply chain management.' },
  { name: 'Star Hospitality', category: BusinessCategory.HOSPITALITY, description: 'Luxury hotels and premium catering services.' },
  { name: 'Agri-Growth Farms', category: BusinessCategory.AGRICULTURE, description: 'Sustainable farming and agricultural produce.' }
];

const sampleLogos = [
  'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg',
  'https://res.cloudinary.com/demo/image/upload/c_fill,h_150,w_150/v1/sample',
];

function getRandomItem<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

async function main() {
  console.log('Starting businesses seed...');

  // Get 10 existing approved users
  const users = await prisma.user.findMany({
    where: { status: 'APPROVED' },
    take: 10,
  });

  if (users.length === 0) {
    console.log('No dummy users found to convert to businesses.');
    return;
  }

  for (let i = 0; i < users.length; i++) {
    const user = users[i];
    const bizInfo = sampleBusinesses[i % sampleBusinesses.length];

    // Update user occupation to BUSINESS_OWNER
    await prisma.user.update({
      where: { id: user.id },
      data: {
        occupationType: OccupationType.BUSINESS_OWNER,
        occupationDetails: {
          businessName: bizInfo.name,
          category: bizInfo.category,
          description: bizInfo.description,
          city: user.currentCity,
        }
      }
    });

    // Create a business listing for the user
    await prisma.businessListing.create({
      data: {
        ownerId: user.id,
        businessName: bizInfo.name,
        category: bizInfo.category,
        description: bizInfo.description,
        logoUrl: getRandomItem(sampleLogos),
        website: `https://www.${bizInfo.name.toLowerCase().replace(/[^a-z0-9]/g, '')}.com`,
        contactNumber: user.phoneNumber || '1234567890',
        address: `${Math.floor(Math.random() * 100) + 1}, Business Park, Sector ${Math.floor(Math.random() * 50)}`,
        city: user.currentCity,
        state: user.currentState,
        status: ListingStatus.APPROVED,
      }
    });
  }

  console.log(`Seeded ${users.length} dummy businesses successfully!`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
