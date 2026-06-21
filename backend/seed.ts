import { PrismaClient, Gender, MaritalStatus, OccupationType, RelationshipType } from '@prisma/client';

const prisma = new PrismaClient();

const firstNames = ['Aarav', 'Vivaan', 'Aditya', 'Vihaan', 'Arjun', 'Sai', 'Rayaan', 'Krishna', 'Ishaan', 'Shaurya', 'Diya', 'Ananya', 'Aadhya', 'Saanvi', 'Pari', 'Myra', 'Kriti', 'Navya', 'Isha', 'Riya'];
const fatherNames = ['Rajesh', 'Suresh', 'Ramesh', 'Dinesh', 'Mahesh', 'Kamlesh', 'Mukesh', 'Ganesh', 'Naresh', 'Sanjay', 'Prakash', 'Amit', 'Sunil', 'Anil', 'Ashok', 'Manoj', 'Vijay', 'Ajay', 'Vikas', 'Deepak'];
const gotras = ['Garg', 'Bansal', 'Goyal', 'Jindal', 'Singhal', 'Kansal', 'Bindal', 'Mittal', 'Tingal', 'Tayal', 'Bhal', 'Mangal', 'Aeran', 'Madhukul', 'Nagil'];
const cities = ['Delhi', 'Mumbai', 'Bangalore', 'Pune', 'Jaipur', 'Ahmedabad', 'Surat', 'Indore', 'Bhopal', 'Chandigarh'];

function getRandomItem<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

async function main() {
  console.log('Starting seed...');

  for (let i = 0; i < 20; i++) {
    const isMale = Math.random() > 0.5;
    const fName = getRandomItem(firstNames);
    const mName = getRandomItem(fatherNames);
    const city = getRandomItem(cities);

    await prisma.user.create({
      data: {
        email: `dummy${i}@example.com`,
        firstName: fName,
        fatherName: mName,
        gotra: getRandomItem(gotras),
        gender: isMale ? Gender.MALE : Gender.FEMALE,
        maritalStatus: MaritalStatus.SINGLE,
        dateOfBirth: new Date(1990 + Math.floor(Math.random() * 10), Math.floor(Math.random() * 12), 1),
        occupationType: OccupationType.JOB_PROFESSIONAL,
        gaon: 'Dummy Village',
        nativeDistrict: 'Dummy District',
        nativeState: 'Rajasthan',
        currentCity: city,
        currentState: 'Dummy State',
        phoneNumber: `98765432${i.toString().padStart(2, '0')}`,
        isPhoneNumberVisible: true,
        relationshipToHead: RelationshipType.SELF,
        status: 'APPROVED',
        isProfileComplete: true,
        memberId: `JJJF-2026-${1000 + i}`,
        family: {
          create: {
            addedByUserId: '000000000000000000000000',
          }
        }
      }
    });
  }

  console.log('Seeded 20 dummy users successfully!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
