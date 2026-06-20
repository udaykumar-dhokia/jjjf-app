# Project Requirements Document

**Project Requirements Document** 

### **Project Name: Jalore Jain Sangh App**

Objective: To build a mobile application (Android & iOS) for the Jain community to facilitate communication, religious observance, directory management, and resource sharing.

Target Audience: Members of the specific Jain Sangh/Community (Families, Youth, Seniors).

### **2\. Technical Stack Recommendations**

Developers may propose alternatives, but these are preferred for scalability:

• Mobile App: Flutter or React Native (Cross-platform for Android & iOS).

• Backend: Node.js with Express OR Python Django.

• Database: MongoDB (good for flexible profile data) or PostgreSQL.

• Admin Panel: React.js or Vue.js (Web-based).

• Authentication: Phone Number OTP (Firebase Auth).

### **3\. User Roles**

1\. Super Admin: Full access to all data, approvals, and user management.

2\. Sub admins \- Members approvals across states

3\. State Admin: Can manage state wise data of all sections and approve members based on states (e.g., Event Manager, Matrimonial Manager, business section).

4\. Member: Verified user who can view data and edit their own profile, except phone number ( phone number needs to be updated on admin approval)

### **Detailed Feature Specifications**

### **Module A: Onboarding & Authentication**

• Phone Login: Login via OTP.

• Approval System: New registrations must be approved by Admin (or verified via a pre-uploaded database of Member IDs) to ensure community privacy.

MEMBER ID FORMAT (JJJF\_)

• Profile Creation: Head of Family creates a profile and adds family members (Spouse, Children, grandson, sister).

Sister filed logic : if the person is female and married, add husband name filed with surname.  ID should not be clickable. 

All the added family members should have a profile page which they can update or the head of the family can update

### **Module B: Member Directory** 

• Listing: Card view of person with photo ( clickable and opens profile)

• Filters: Search by Name, Native Place (Gaam), City, Professional Field, Blood Group, Gotra (surname).

• Privacy: Users can choose to hide phone numbers from the public directory (Hidden for females by default, visible for males by default) 

- have a button on edit profile page to show phone number / hide phone number.  
- Have a button on profile view to request  phone number for hidden numbers.  
  • Interaction: "Click to Call" and "Click to WhatsApp" buttons. ( only for the numbers visible)

### **Module C: Religious Features (Dharmik)**

• Panchang: API integration or manual entry for Tithis, Sunrise/Sunset times based on location.

• Pachkhan: Audio player with text lyrics for standard Pachkhans (Navkarsi, Chovihar, etc.).

• Tirth Guide: Static pages with information, images, and "Navigate via Maps" button for key Jain Tirths.

### **Module D: Business & Matrimonial**

• Business Listing: Members can list their business (Shop name, Category, Contact). \- subject to approvals

• Job Board: Simple posting form for "Vacancy Available" and "Job Required". \- subject to approvals. Role and contact details and city.

• Matrimonial: create a form to apply for matrimony and photo gallery. (Access restricted to approved users only). \- More to be brainstormed 

- Show profiles of opposite genders only for marriage 

### **Module E: Events & News**

• Event Calendar: List of upcoming events with Date, Time, Location,maps, photos via URL only. \- also subject to approval ( admins can also edit the entry before approval)

• RSVP/Polls: "Will you attend?" Yes/No buttons for food planning. ( send WA message to admin On each click before event starts)   
For the once marked yes \- we send them details on WA.

• Notifications: Push notifications for important news ( Festival reminders).

### **Module F ( Death notes / Shok Sandesh)**

- Entry is subject to approvals   
- All Admins to receive notifications every 5 mins Untill approved or Rejected.  
  • Gallery: Grid view of photos/videos from past events.   
  Live tab in gallery

### **Module F: Admin Panel (Web Dashboard)**

• User Management: Approve/Block users.

• Content Management: Add Events, upload Gallery photos, approve content.

• Export Data: Download Member directory as Excel/PDF. ( only super admin with Otp verification)

• Push Notifications: Interface to send custom alerts to all users.

5\. Non-Functional Requirements

• Language Support: App must support English and Regional Language (e.g., Gujarati/Hindi) toggle.

• Offline Mode: Directory and Panchang should work without internet (cached data).

• Data Security: All personal data (phone numbers, family details) must be encrypted. 

• Performance: App load time under 3 seconds

### **6\. Deliverables Required from developer team**

1\. UI/UX Design (Figma) for approval.

2\. Android App (APK & Play Store submission).

3\. iOS App (TestFlight & App Store submission).

4\. Web Admin Panel.

5\. Source Code ownership.

6\. 6 months of bug support after launch.

7\. Whatsapp Integrations \- 

For all notifications with clickable url to app.

- For Shok sandesh approvals for admins \- full message to be sent to admins on WA with Buttons to take action ( approve and reject ) which reflect directly on app. 

# Hindi Translation

**प्रोजेक्ट की ज़रूरी बातें (ज़रूरी डॉक्यूमेंट)**

**प्रोजेक्ट का नाम: जालोर जैन संघ ऐप**

मकसद (Objective): जैन समुदाय के लिए एक मोबाइल ऐप (एंड्रॉइड और आईओएस) बनाना। इस ऐप से लोगों को आपस में बात करने, धर्म से जुड़ी बातों को जानने, सदस्यों की लिस्ट मैनेज करने और चीज़ें शेयर करने में आसानी होगी।

किनके लिए है (Target Audience): जालोर जैन संघ/समाज के सदस्य (परिवार, युवा, बुज़ुर्ग)।

**2\. ज़रूरी टेक्नोलॉजी (टेक्निकल स्टैक)**

डेवलपर दूसरे विकल्प भी दे सकते हैं, पर हम इन चीज़ों को बेहतर मानते हैं ताकि ऐप भविष्य में भी अच्छे से चल सके:

* **मोबाइल ऐप:** फ़्लटर या रिएक्ट नेटिव (यह दोनों, एंड्रॉइड और आईओएस के लिए काम करेगा)।  
* **बैकएंड (सर्वर):** नोड.जेएस एक्सप्रेस के साथ या पायथन जैंगो।  
* **डेटाबेस (डेटा रखने की जगह):** मोंगोडीबी (अलग-अलग तरह की प्रोफ़ाइल जानकारी के लिए अच्छा) या पोस्टग्रेएसक्यूएल।  
* **एडमिन पैनल (वेबसाइट):** रिएक्ट.जेएस या वू.जेएस (वेब पर चलेगा)।  
* **लॉगिन का तरीका (Authentication):** फ़ोन नंबर पर आए ओटीपी (वन टाइम पासवर्ड) से (फ़ायरबेस ऑथ इस्तेमाल करके)।

**3\. यूज़र के रोल (कौन क्या कर पाएगा)**

1. **सुपर एडमिन:** सब कुछ मैनेज करने का पूरा हक़ (पूरी जानकारी, मंज़ूरी देना और यूज़र को संभालना)।  
2. **सब-एडमिन:** अलग-अलग राज्यों के सदस्यों को मंज़ूरी देगा।  
3. **राज्य एडमिन:** अपने राज्य की जानकारी (जैसे इवेंट, शादी-ब्याह, बिज़नेस) को मैनेज करेगा और राज्य के सदस्यों को मंज़ूरी देगा।  
4. **सदस्य:** जो यूज़र वेरिफाई (सत्यापित) हो चुका है, वह जानकारी देख सकेगा और अपनी प्रोफ़ाइल बदल सकेगा। पर फ़ोन नंबर बदलने के लिए एडमिन की मंज़ूरी लेनी होगी।

\-----**फ़ीचर की पूरी जानकारी**

**मॉड्यूल A: ऐप में आना और लॉगिन (Onboarding & Authentication)**

* **फ़ोन से लॉगिन:** ओटीपी डालकर लॉगिन करना।  
* **मंज़ूरी (Approval) सिस्टम:** समाज की प्राइवेसी के लिए, नए यूज़र को एडमिन की मंज़ूरी के बाद ही एंट्री मिलेगी (या पहले से अपलोड किए गए सदस्य आईडी से वेरिफाई किया जाएगा)।

सदस्य आईडी इस तरह दिखेगी (JJJF\_)

* **प्रोफ़ाइल बनाना:** परिवार का मुखिया अपनी प्रोफ़ाइल बनाएगा और अपने परिवार के सदस्यों (पति/पत्नी, बच्चे, पोते-पोती, बहन) को जोड़ सकेगा।  
  * परिवार के हर सदस्य की अपनी प्रोफ़ाइल होगी जिसे वे खुद या परिवार का मुखिया अपडेट कर सकेगा।

**मॉड्यूल B: सदस्यों की लिस्ट (Member Directory)**

* **लिस्ट देखना:** सदस्य की फोटो के साथ कार्ड दिखेगा (इस पर क्लिक करके प्रोफ़ाइल खुलेगी)।  
* **ढूंढने के विकल्प (Filters):** नाम, पैतृक स्थान (गाँव), शहर, काम/प्रोफेशन, ब्लड ग्रुप, गोत्र (सरनेम) से खोजा जा सकेगा।  
* **प्राइवेसी:** यूज़र अपनी मर्ज़ी से फ़ोन नंबर को पब्लिक लिस्ट से छिपा सकते हैं (महिलाओं के लिए यह डिफ़ॉल्ट रूप से छिपा रहेगा, पुरुषों के लिए दिखेगा)।  
  * प्रोफ़ाइल एडिट करते समय नंबर दिखाने/छिपाने का बटन होगा।  
  * अगर किसी का नंबर छिपा है, तो उसे देखने के लिए अनुरोध (रिक्वेस्ट) भेजने का बटन होगा।  
* **बातचीत:** "कॉल करने के लिए क्लिक करें" और "व्हाट्सएप करने के लिए क्लिक करें" बटन होंगे (सिर्फ़ उन नंबरों के लिए जो दिख रहे हैं)।

**मॉड्यूल C: धार्मिक जानकारी (Dharmik)**

* **पंचांग:** लोकेशन के हिसाब से तिथियाँ, सूर्योदय/सूर्यास्त का समय एपीआई से या मैन्युअल एंट्री से मिलेगा।  
* **पचखान:** ऑडियो प्लेयर होगा जिसमें ज़रूरी पचखान (नवकारसी, चौविहार, आदि) के लिए टेक्स्ट और ऑडियो होगा।  
* **तीर्थ गाइड:** ज़रूरी जैन तीर्थों की जानकारी, फोटो और "मैप्स से रास्ता देखें" बटन के साथ पेज होंगे।

**मॉड्यूल D: बिज़नेस और शादी-ब्याह (Business & Matrimonial)**

* **बिज़नेस लिस्टिंग:** सदस्य अपने बिज़नेस की जानकारी डाल सकते हैं (दुकान का नाम, कैटेगरी, संपर्क, क्या देते हैं)। \- यह एडमिन की मंज़ूरी पर निर्भर करेगा।  
* **जॉब बोर्ड:** "नौकरी खाली है" और "नौकरी चाहिए" के लिए आसान फॉर्म। \- यह भी एडमिन की मंज़ूरी पर निर्भर करेगा।  
* **वैवाहिक:** बायो-डेटा पीडीएफ अपलोड करने और फोटो गैलरी के लिए एक सुरक्षित हिस्सा होगा (इस तक पहुँच केवल मंज़ूरी पाए यूज़र की होगी)। \- इस पर और विचार करना है।  
  * शादी के लिए केवल विपरीत लिंग की प्रोफ़ाइल दिखाएँ।

**मॉड्यूल E: इवेंट और ख़बरें (Events & News)**

* **इवेंट कैलेंडर:** आने वाले इवेंट्स की लिस्ट, जिसमें तारीख, समय, जगह, मैप्स, और केवल यूआरएल से फोटो दिखेंगी। \- यह भी एडमिन की मंज़ूरी पर निर्भर करेगा (एडमिन मंज़ूरी से पहले एंट्री को एडिट भी कर सकते हैं)।  
* **आरएसवीपी/पोल:** खाना प्लान करने के लिए "क्या आप आएंगे?" हाँ/नहीं बटन होंगे। (इवेंट शुरू होने से पहले हर क्लिक पर एडमिन को व्हाट्सएप मैसेज जाएगा)।  
* **सूचनाएँ (Notifications):** ज़रूरी ख़बरों (जैसे त्योहारों के रिमाइंडर) के लिए पुश नोटिफिकेशन।

**मॉड्यूल F (मृत्यु सूचना/शोक संदेश)**

* इसकी एंट्री भी एडमिन की मंज़ूरी पर निर्भर करेगी।  
* मंज़ूरी मिलने या न मिलने तक, सभी एडमिन को हर 5 मिनट में नोटिफिकेशन मिलते रहेंगे।  
* **गैलरी:** पुराने इवेंट्स की फोटो/वीडियो ग्रिड स्टाइल में दिखेंगी।

**मॉड्यूल F: एडमिन पैनल (वेब डैशबोर्ड)**

* **यूज़र मैनेजमेंट:** यूज़र को मंज़ूरी देना/ब्लॉक करना।  
* **कंटेंट मैनेजमेंट:** इवेंट जोड़ना, गैलरी फोटो अपलोड करना, जानकारी को मंज़ूरी देना।  
* **डेटा एक्सपोर्ट:** सदस्य की लिस्ट को एक्सेल/पीडीएफ के रूप में डाउनलोड करना। (केवल सुपर एडमिन ओटीपी वेरिफाई करने के बाद ही कर पाएगा)।  
* **पुश नोटिफिकेशन:** सभी यूज़र को मैसेज भेजने के लिए एक जगह होगी।

**5\. दूसरी ज़रूरी बातें (Non-Functional Requirements)**

* **भाषा का सपोर्ट:** ऐप में अंग्रेजी और क्षेत्रीय भाषा (जैसे गुजराती/हिंदी) को बदलने का ऑप्शन होना चाहिए।  
* **ऑफ़लाइन मोड:** इंटरनेट न होने पर भी सदस्यों की लिस्ट और पंचांग दिखना चाहिए (डेटा फ़ोन में सेव रहेगा)।  
* **डेटा सुरक्षा (Security):** सभी निजी जानकारी (फ़ोन नंबर, परिवार का विवरण) एन्क्रिप्टेड (सुरक्षित) होनी चाहिए।  
* **परफॉर्मेंस (Speed):** ऐप को 3 सेकंड से कम समय में खुल जाना चाहिए।

**6\. डेवलपर टीम से ज़रूरी काम (Deliverables)**

1. UI/UX डिज़ाइन (फ़िग्मा फ़ाइल) मंज़ूरी के लिए।  
2. एंड्रॉइड ऐप (एपीके फ़ाइल और प्ले स्टोर पर डालना)।  
3. आईओएस ऐप (टेस्टफ़्लाइट और ऐप स्टोर पर डालना)।  
4. वेब एडमिन पैनल।  
5. स्रोत कोड (Source Code) का मालिकाना हक़।  
6. ऐप लॉन्च होने के बाद 6 महीने तक बग (ग़लतियाँ) ठीक करने का सपोर्ट।

# Chnages in the App

# **App Issues & Feature Requests (Structured)**

## **1\. 🧑 Profile & User Flow**

### **Missing User Segmentation**

* Add **“Others” option** under *Business*  
* Current flow assumes all users are business owners  
* Introduce **separate onboarding flow for job professionals**

### **Profile Fields to Add**

* **Gaon (Village)**  
  * With: District \+ State  
* **Current City** (separate from Gaon)  
* **Marital Status**

---

## **2\. 📰 News Section**

### **Bug**

* Clicking on a news item does **not open detailed view**

### **Fix Required**

* Enable:  
  * Click → Open full news  
  * Show:  
    * Title  
    * Description/content  
    * Any media (if applicable)

---

## 

## **3\. 📇 Contacts Module**

### **UI & Feature Additions**

* Add **WhatsApp icon** for each contact  
  * Action: Redirect to WhatsApp chat using phone number

### **Data Visibility Improvements**

* Show **Father’s Name**  
  * On:  
    * Main contacts list  
    * Contact detail view  
* Add fields in contact detail view:  
  * Current City  
  * Gaon (Village)

### **Bugs**

* **Filters not working**  
  * Needs debugging (likely frontend logic or API issue)

---

## **4\. 💼 Business Section**

### **Current Issue**

* Page is **empty / non-functional**

### **Features to Add**

* **Post Job**  
  * Submission goes for **admin approval**  
* **Find Job**  
  * View approved job listings

---

## **5\. 🏠 Home Dashboard**

### **Issue**

* Most of the tabs are not working on dashboard


