import { PrismaClient, JobType, ListingStatus } from '@prisma/client';

const prisma = new PrismaClient();

const sampleVacancies = [
  {
    roleTitle: 'Senior Software Engineer',
    industry: 'IT',
    description: 'We are looking for an experienced software engineer to join our fast-growing startup. Must have 5+ years of experience with Node.js and React.',
    salaryRange: '₹12,000,00 - ₹18,000,00 / year',
    city: 'Bangalore',
    contactName: 'Rajesh Sharma',
    contactPhone: '9876543210',
    whatsappNumber: '9876543210',
    contactEmail: 'hr@techcorp.com',
    links: ['https://techcorp.com/careers', 'https://linkedin.com/company/techcorp']
  },
  {
    roleTitle: 'Marketing Manager',
    industry: 'Marketing',
    description: 'Seeking a creative marketing manager to lead our digital campaigns. Proven track record in social media growth and SEO is required.',
    salaryRange: '₹8,000,00 - ₹12,000,00 / year',
    city: 'Mumbai',
    contactName: 'Sneha Patel',
    contactPhone: '9876543211',
    whatsappNumber: '9876543211',
    contactEmail: 'careers@marketingpro.in',
    links: ['https://marketingpro.in']
  },
  {
    roleTitle: 'Accountant',
    industry: 'Finance',
    description: 'Urgently hiring a qualified accountant (CA preferred) for managing day-to-day accounts and tax filings.',
    salaryRange: '₹5,000,00 - ₹7,000,00 / year',
    city: 'Delhi',
    contactName: 'Amit Jain',
    contactPhone: '9876543212',
    whatsappNumber: '9876543212',
    contactEmail: 'finance@jainassociates.in',
    links: []
  },
  {
    roleTitle: 'Store Manager',
    industry: 'Retail',
    description: 'Looking for an experienced store manager for our new branch in Surat. Responsible for inventory and staff management.',
    salaryRange: '₹3,000,00 - ₹5,000,00 / year',
    city: 'Surat',
    contactName: 'Dinesh Kumar',
    contactPhone: '9876543213',
    whatsappNumber: '9876543213',
    contactEmail: 'jobs@megamart.com',
    links: []
  },
  {
    roleTitle: 'Graphic Designer',
    industry: 'Design',
    description: 'Creative graphic designer needed for an ad agency. Proficiency in Adobe Creative Suite and Figma required.',
    salaryRange: '₹4,000,00 - ₹6,000,00 / year',
    city: 'Pune',
    contactName: 'Priya Singh',
    contactPhone: '9876543214',
    whatsappNumber: '9876543214',
    contactEmail: 'hello@creativead.com',
    links: ['https://behance.net/creativead']
  }
];

const sampleRequests = [
  {
    roleTitle: 'Frontend Developer Seeking Opportunities',
    industry: 'IT',
    description: 'I am a fresher with strong skills in React, Flutter, and TailwindCSS looking for an entry-level position.',
    salaryRange: 'Negotiable',
    city: 'Bangalore',
    contactName: 'Rahul Verma',
    contactPhone: '9876543215',
    whatsappNumber: '9876543215',
    contactEmail: 'rahul.dev@gmail.com',
    links: ['https://github.com/rahuldev', 'https://rahuldev.com']
  },
  {
    roleTitle: 'Experienced Sales Executive',
    industry: 'Sales',
    description: 'Results-driven sales executive with 8 years of experience in B2B sales seeking a managerial role.',
    salaryRange: '₹10,000,00+ / year',
    city: 'Delhi',
    contactName: 'Vikram Singh',
    contactPhone: '9876543216',
    whatsappNumber: '9876543216',
    contactEmail: 'vikram.sales@yahoo.com',
    links: ['https://linkedin.com/in/vikramsales']
  },
  {
    roleTitle: 'Data Analyst',
    industry: 'Data',
    description: 'Data analyst proficient in Python, SQL, and PowerBI. Available immediately.',
    salaryRange: '₹6,000,00 / year',
    city: 'Mumbai',
    contactName: 'Neha Gupta',
    contactPhone: '9876543217',
    whatsappNumber: '9876543217',
    contactEmail: 'neha.data@gmail.com',
    links: []
  },
  {
    roleTitle: 'Looking for HR Executive Role',
    industry: 'HR',
    description: 'MBA in HR with 2 years of experience in talent acquisition and employee engagement.',
    salaryRange: '₹4,000,00 / year',
    city: 'Pune',
    contactName: 'Anjali Sharma',
    contactPhone: '9876543218',
    whatsappNumber: '9876543218',
    contactEmail: 'anjali.hr@outlook.com',
    links: ['https://linkedin.com/in/anjalisharmahr']
  },
  {
    roleTitle: 'Civil Engineer',
    industry: 'Construction',
    description: 'Experienced civil engineer specialized in residential projects. Looking for contract or full-time roles.',
    salaryRange: '₹7,000,00 / year',
    city: 'Ahmedabad',
    contactName: 'Sanjay Patel',
    contactPhone: '9876543219',
    whatsappNumber: '9876543219',
    contactEmail: 'sanjay.engg@gmail.com',
    links: []
  }
];

async function main() {
  console.log('Starting jobs seed...');

  // Get some existing approved users to be the posters
  const users = await prisma.user.findMany({
    where: { status: 'APPROVED' },
    take: 10,
  });

  if (users.length === 0) {
    console.log('No users found in database. Please run seed.ts first.');
    return;
  }

  // Clear existing jobs to prevent duplicates if run multiple times
  await prisma.jobBoard.deleteMany();

  // Create vacancies
  for (let i = 0; i < sampleVacancies.length; i++) {
    const poster = users[i % users.length];
    await prisma.jobBoard.create({
      data: {
        postedById: poster.id,
        type: JobType.VACANCY_AVAILABLE,
        status: ListingStatus.APPROVED,
        ...sampleVacancies[i],
      }
    });
  }

  // Create job requests
  for (let i = 0; i < sampleRequests.length; i++) {
    const poster = users[(i + 5) % users.length];
    await prisma.jobBoard.create({
      data: {
        postedById: poster.id,
        type: JobType.JOB_REQUIRED,
        status: ListingStatus.APPROVED,
        ...sampleRequests[i],
      }
    });
  }

  console.log(`Seeded ${sampleVacancies.length} vacancies and ${sampleRequests.length} job requests successfully!`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
