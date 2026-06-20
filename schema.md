# Implementation Plan - Database Schemas

Below is the complete database design for the **Jalore Jain Sangh App**. It includes the expanded User/Member model with additional basic fields, as well as schemas for all modules defined in the PRD (Directory, Religious, Business, Matrimonial, Events, News, Death Notes, and Gallery).

---

## 1. User & Family Schemas (Module A & B)

### `User` Schema
Represents a community member. This includes basic demographic details, location, privacy controls, and admin roles.

| Field Name | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID / ObjectId | Primary Key | Unique ID. |
| `memberId` | String | Unique, Nullable | Format: `JJJF_<UUID_or_Seq>`. Generated upon approval. |
| `firstName` | String | Required | Member's first name. |
| `fatherName` | String | Required | Father's name. |
| `motherName` | String | Optional | Mother's name. |
| `gotra` | String | Required | Surname / Gotra (e.g. Jain, Shah, Bafna). |
| `spouseName` | String | Optional | Name of spouse (if married). |
| `husbandNameWithSurname` | String | Optional | For married sisters (Sister logic). |
| `sasuralGotra` | String | Optional | Spouse's Gotra / Sasural Gotra. |
| `gender` | Enum | Required | `MALE`, `FEMALE`, `OTHER`. |
| `maritalStatus` | Enum | Required | `SINGLE`, `MARRIED`, `DIVORCED`, `WIDOWED`. |
| `dateOfBirth` | Date | Required | Used for Matrimony & Age search/sorting. |
| `bloodGroup` | Enum | Optional | `A+`, `A-`, `B+`, `B-`, `AB+`, `AB-`, `O+`, `O-`. |
| `photoUrl` | String | Optional | Profile image URL. |
| `email` | String | Optional | Email address. |
| `education` | String | Optional | e.g. "B.Com, MBA", "CA", "B.Tech". |
| `occupationType`| Enum | Required | `BUSINESS_OWNER`, `JOB_PROFESSIONAL`, `OTHER`. |
| `occupationDetails`| Object | Optional | (Details schema listed below). |
| `gaon` | String | Required | Native Village (Gaon). |
| `nativeDistrict`| String | Required | Native District. |
| `nativeState` | String | Required | Native State. |
| `currentAddress`| String | Optional | Current residence line. |
| `currentCity` | String | Required | Current city. |
| `currentState` | String | Required | Current state. |
| `pinCode` | String | Optional | Residence PIN code. |
| `phoneNumber` | String | Unique, Required | Firebase OTP phone number. |
| `whatsappNumber`| String | Optional | Defaults to `phoneNumber` if blank. |
| `isPhoneNumberVisible`| Boolean | Required | Default: `true` for males, `false` for females. |
| `familyId` | Reference | Required | Groups family members under a family unit. |
| `isHeadOfFamily`| Boolean | Required, Default: `false` | True if this user is the Head of Family. |
| `relationshipToHead`| Enum | Required | `SELF`, `SPOUSE`, `SON`, `DAUGHTER`, `GRANDSON`, `SISTER`, `BROTHER`, `OTHER`. |
| `role` | Enum | Required, Default: `MEMBER` | `SUPER_ADMIN`, `SUB_ADMIN`, `STATE_ADMIN`, `MEMBER`. |
| `status` | Enum | Required, Default: `PENDING_APPROVAL` | `PENDING_APPROVAL`, `APPROVED`, `REJECTED`, `BLOCKED`. |
| `assignedStates`| Array (Strings) | Optional | States managed (relevant for `STATE_ADMIN`). |
| `createdAt` | Date | Auto | Creation timestamp. |
| `updatedAt` | Date | Auto | Last update timestamp. |

#### **`occupationDetails` Sub-schema**
* For `BUSINESS_OWNER`:
  * `businessName` (String)
  * `category` (String)
  * `address` (String)
  * `contact` (String)
* For `JOB_PROFESSIONAL`:
  * `companyName` (String)
  * `designation` (String)
  * `industry` (String)
  * `city` (String)
* For `OTHER`:
  * `description` (String) - e.g. "Student", "Homemaker", "Retired".

---

### `Family` Schema
Groups family members together under a shared unit name or address context.

| Field Name | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID / ObjectId | Primary Key | Unique ID. |
| `familyName` | String | Required | E.g. "Parivar of Late Shri Lalchandji Bafna". |
| `headOfFamilyId` | Reference | Required | Refers to the `User` who is the head. |
| `familyPhotoUrl` | String | Optional | Group family photo. |
| `addedByUserId` | Reference | Required | User who registered this family unit. |
| `createdAt`/`updatedAt`| Date | Auto | Timestamps. |

---

## 2. Matrimonial Schema (Module D)

### `MatrimonialProfile` Schema
Separate schema linked to an approved user profile. Contains detailed matrimonial bio-data.

| Field Name | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID / ObjectId | Primary Key | Unique ID. |
| `userId` | Reference | Required, Unique | Link to `User` table (opposite gender checks performed via this relation). |
| `height` | String | Optional | Height (e.g. 5'8"). |
| `weight` | Number | Optional | Weight in kg. |
| `subCaste` / `Gotra` | String | Required | Sub-caste / Gotra. |
| `educationDetails`| String | Required | Detailed qualifications. |
| `monthlyIncome` | String | Optional | Income range. |
| `aboutMe` / `hobbies`| String | Optional | Bio details. |
| `expectations` | String | Optional | Partner expectations. |
| `photoGallery` | Array (Strings) | Default: `[]` | Up to 5 matrimonial photographs. |
| `biodataPdfUrl` | String | Optional | PDF resume upload. |
| `status` | Enum | Default: `PENDING` | `PENDING`, `APPROVED`, `REJECTED`. |
| `createdAt`/`updatedAt`| Date | Auto | Timestamps. |

---

## 3. Business & Jobs Schemas (Module D)

### `BusinessListing` Schema
Stores businesses registered by members.

| Field Name | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID / ObjectId | Primary Key | Unique ID. |
| `ownerId` | Reference | Required | Refers to the listing `User`. |
| `businessName` | String | Required | Name of Shop / Business. |
| `category` | String | Required | Category (e.g., Textiles, Electronics, Grocery). |
| `description` | String | Optional | Business description/services. |
| `logoUrl` | String | Optional | Business logo image. |
| `contactNumber` | String | Required | Mobile/WhatsApp for contact. |
| `address` | String | Required | Business address. |
| `city` | String | Required | Residing City. |
| `state` | String | Required | Residing State. |
| `status` | Enum | Default: `PENDING` | `PENDING`, `APPROVED`, `REJECTED`. |
| `createdAt`/`updatedAt`| Date | Auto | Timestamps. |

---

### `JobBoard` Schema
Job listings representing "Vacancy Available" or "Job Required".

| Field Name | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID / ObjectId | Primary Key | Unique ID. |
| `postedBy` | Reference | Required | Refers to the listing `User`. |
| `type` | Enum | Required | `VACANCY_AVAILABLE` or `JOB_REQUIRED`. |
| `roleTitle` | String | Required | Job role designation (e.g., Accountant, Sales). |
| `industry` | String | Required | Industry type. |
| `contactDetails` | String | Required | Contact name and phone number. |
| `city` | String | Required | City location of job. |
| `salaryRange` | String | Optional | Monthly compensation offer/expectation. |
| `description` | String | Required | Detailed job requirement or candidate profile. |
| `status` | Enum | Default: `PENDING` | `PENDING`, `APPROVED`, `REJECTED`. |
| `createdAt`/`updatedAt`| Date | Auto | Timestamps. |

---

## 4. Events, News & RSVP Schemas (Module E)

### `Event` Schema
Contains community meetups, religious functions, or general programs.

| Field Name | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID / ObjectId | Primary Key | Unique ID. |
| `title` | String | Required | Event title. |
| `description` | String | Required | Details of the event. |
| `eventDate` | Date | Required | Scheduled date. |
| `eventTime` | String | Required | Scheduled time. |
| `locationName` | String | Required | Venue name. |
| `locationMapUrl` | String | Optional | Google Maps redirect link. |
| `photoUrls` | Array (Strings) | Default: `[]` | URLs for event banners/flyers (URL only as per PRD). |
| `status` | Enum | Default: `PENDING` | `PENDING`, `APPROVED`, `REJECTED`. |
| `createdBy` | Reference | Required | ID of the Admin/Sub-Admin who posted the event. |
| `createdAt`/`updatedAt`| Date | Auto | Timestamps. |

---

### `RSVP` Schema
Tracks member intentions for food planning and logistics.

| Field Name | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID / ObjectId | Primary Key | Unique ID. |
| `eventId` | Reference | Required | Refers to the `Event` schema. |
| `userId` | Reference | Required | Refers to the responding `User`. |
| `attending` | Enum | Required | `YES` or `NO`. |
| `numberOfAdults` | Number | Default: `1` | Count of adults attending. |
| `numberOfChildren`| Number | Default: `0` | Count of children attending. |
| `waMessageSent` | Boolean | Default: `false` | Tracks if WhatsApp notification was sent to admin. |
| `createdAt`/`updatedAt`| Date | Auto | Timestamps. |

---

### `News` Schema
Represents announcements, festival reminders, or general articles.

| Field Name | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID / ObjectId | Primary Key | Unique ID. |
| `title` | String | Required | Article Title. |
| `content` | String | Required | Detailed post description. |
| `imageUrl` | String | Optional | Main graphic banner URL. |
| `publishedBy` | Reference | Required | Admin author ref. |
| `status` | Enum | Default: `APPROVED` | `DRAFT`, `APPROVED`. |
| `createdAt`/`updatedAt`| Date | Auto | Timestamps. |

---

## 5. Death Notes / Shok Sandesh Schema (Module F)

### `ShokSandesh` Schema
Used for announcements of member demise. Requires WhatsApp admin alert loops every 5 minutes until actioned.

| Field Name | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID / ObjectId | Primary Key | Unique ID. |
| `deceasedName` | String | Required |Demised member's name. |
| `age` | Number | Required | Demised member's age. |
| `nativeVillage` | String | Required | Native Village (Gaon). |
| `deceasedPhotoUrl`| String | Optional | demised member's photograph. |
| `dateDemised` | Date | Required | demised date. |
| `funeralDetails` | String | Required | Besna / Funeral times, dates, and locations. |
| `survivingFamily` | String | Required | Names of relatives (e.g. Sons, Nephews). |
| `contactPerson` | String | Required | Primary coordinator's name. |
| `contactPhone` | String | Required | Primary coordinator's number. |
| `status` | Enum | Default: `PENDING` | `PENDING`, `APPROVED`, `REJECTED`. |
| `approvedBy` | Reference | Nullable | Admin who approved/rejected the post. |
| `createdAt`/`updatedAt`| Date | Auto | Timestamps. |

---

## 6. Gallery & Religious Schemas (Module C, F & G)

### `Gallery` Schema
For displaying community events photos/videos.

| Field Name | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID / ObjectId | Primary Key | Unique ID. |
| `mediaUrl` | String | Required | Photo or video URL. |
| `mediaType` | Enum | Required | `PHOTO` or `VIDEO`. |
| `isLive` | Boolean | Default: `false` | True displays it under the "Live" tab in the gallery. |
| `eventId` | Reference | Optional | Associated event if uploaded from an event. |
| `uploadedBy` | Reference | Required | Admin who uploaded it. |
| `createdAt` | Date | Auto | Upload timestamp. |

---

### `Pachkhan` Schema
Stores Pachkhan list with lyrics and audio.

| Field Name | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID / ObjectId | Primary Key | Unique ID. |
| `title` | String | Required | e.g. "Navkarsi", "Chovihar". |
| `lyricsText` | String | Required | Hindi/Gujarati/English lyrics. |
| `audioUrl` | String | Required | MP3 file storage link. |
| `createdAt` | Date | Auto | Timestamp. |

---

### `TirthGuide` Schema
Holds directories of Jain pilgrim destinations.

| Field Name | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID / ObjectId | Primary Key | Unique ID. |
| `tirthName` | String | Required | Name of the Tirth. |
| `description` | String | Required | History/importance. |
| `mainPhotoUrl` | String | Required | Main display image. |
| `additionalPhotos`| Array (Strings) | Default: `[]` | Extra gallery images. |
| `latitude` | Number | Required | For "Navigate via Maps" action. |
| `longitude` | Number | Required | For "Navigate via Maps" action. |
| `address` | String | Required | Full physical address. |
| `createdAt` | Date | Auto | Timestamp. |

---

### `Panchang` Schema
Stores manual entries for regional Tithis, sunrise, and sunset times.

| Field Name | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | UUID / ObjectId | Primary Key | Unique ID. |
| `date` | Date | Required, Unique | Calendar date. |
| `tithi` | String | Required | Jain calendar Tithi. |
| `sunriseTime` | String | Required | Local Sunrise (e.g. 05:48 AM). |
| `sunsetTime` | String | Required | Local Sunset (e.g. 07:12 PM). |
| `locationName` | String | Required | Target location (or region). |
| `specialOccasion` | String | Optional | Festival name (e.g. Mahavir Janma Kalyanak). |
| `createdAt` | Date | Auto | Timestamp. |

---

## User Review Required

> [!IMPORTANT]
> Please review the additional basic fields in the **`User` Schema** (e.g., `dateOfBirth`, `education`, `motherName`, `sasuralGotra`).
> Also, check the layout of the modular schemas (`MatrimonialProfile`, `BusinessListing`, `JobBoard`, `Event`, `RSVP`, `News`, `ShokSandesh`, `Gallery`, `Pachkhan`, `TirthGuide`, `Panchang`).

## Open Questions

> [!WARNING]
> 1. **Panchang Integration**: The PRD allows "API integration or manual entry". Do you want to build manual admin forms first (using this `Panchang` Schema) or use a specific Panchang API?
> 2. **Verification Logic**: Do you have a list of pre-approved phone numbers or Member IDs we should pre-upload to verify onboarding, or should all sign-ups default to Admin review?
