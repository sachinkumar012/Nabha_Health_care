const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
require("dotenv").config();

// Import all models
const User = require("../src/models/User");
const Medicine = require("../src/models/Medicine");
const Hospital = require("../src/models/Hospital");
const PharmacyOrder = require("../src/models/PharmacyOrder");
const Appointment = require("../src/models/Appointment");
const MedicalRecord = require("../src/models/MedicalRecord");
const ChatSession = require("../src/models/ChatSession");

// Connect to MongoDB
const connectDB = require("../src/config/database");

// Sample Users Data
const usersData = [
  {
    name: "Sachin Kumar Raj",
    email: "sachinyadav887780@gmail.com",
    phone: "9318496221",
    password: "password123",
    emailVerified: true,
    phoneVerified: true,
    dateOfBirth: new Date("1995-01-15"),
    gender: "Male",
    bloodGroup: "B+",
    address: {
      street: "Satnampura, Main Road",
      city: "Phagwara",
      state: "Punjab",
      pincode: "144401",
      country: "India",
    },
    language: "en",
    isActive: true,
  },
  {
    name: "Dr. Sachin Kumar",
    email: "dr.sachinkumar@nabhahealthcare.com",
    phone: "9876543210",
    password: "doctor123",
    emailVerified: true,
    phoneVerified: true,
    dateOfBirth: new Date("1980-06-20"),
    gender: "Male",
    bloodGroup: "O+",
    address: {
      street: "Medical Complex",
      city: "Nabha",
      state: "Punjab",
      pincode: "147201",
      country: "India",
    },
    language: "en",
    isActive: true,
  },
  {
    name: "Priya Sharma",
    email: "priya.sharma@example.com",
    phone: "9123456789",
    password: "password123",
    emailVerified: true,
    phoneVerified: true,
    dateOfBirth: new Date("1992-03-10"),
    gender: "Female",
    bloodGroup: "A+",
    address: {
      street: "Model Town",
      city: "Nabha",
      state: "Punjab",
      pincode: "147201",
      country: "India",
    },
    language: "hi",
    isActive: true,
  },
];

// Sample Medicines Data (from your Flutter app)
const medicinesData = [
  {
    name: "Ecosprin 75 Tablet",
    genericName: "Aspirin",
    brand: "Ecosprin",
    manufacturer: "USV PVT LTD",
    composition: "Aspirin (75mg)",
    strength: "75mg",
    category: "tablet",
    therapeuticClass: "Antiplatelet",
    requiresPrescription: false,
    scheduleType: "G",
    packaging: {
      packSize: 14,
      unit: "piece",
      packType: "strip",
    },
    pricing: {
      mrp: 5.15,
      sellingPrice: 4.02,
      discount: 22,
      currency: "INR",
      gst: 12,
    },
    inventory: {
      currentStock: 150,
      minStock: 20,
      maxStock: 500,
    },
    batches: [
      {
        batchNumber: "ESP001",
        manufactureDate: new Date("2024-01-15"),
        expiryDate: new Date("2026-01-15"),
        quantity: 150,
        sellingPrice: 4.02,
      },
    ],
    indications: ["Cardiovascular protection", "Blood clot prevention"],
    dosage: {
      adult: "One tablet daily after food",
      instructions: "Take with water after meals",
    },
    description: "Low-dose aspirin for cardiovascular protection",
    images: [
      {
        url: "https://via.placeholder.com/300x200/blue/white?text=Ecosprin",
        alt: "Ecosprin 75 Tablet",
        isPrimary: true,
      },
    ],
    isActive: true,
    isAvailable: true,
    keywords: ["aspirin", "heart", "cardio", "blood thinner"],
  },
  {
    name: "Paracetamol 500mg",
    genericName: "Paracetamol",
    brand: "Crocin",
    manufacturer: "GlaxoSmithKline",
    composition: "Paracetamol (500mg)",
    strength: "500mg",
    category: "tablet",
    therapeuticClass: "Analgesic/Antipyretic",
    requiresPrescription: false,
    scheduleType: "G",
    packaging: {
      packSize: 10,
      unit: "piece",
      packType: "strip",
    },
    pricing: {
      mrp: 18.0,
      sellingPrice: 15.0,
      discount: 17,
      currency: "INR",
      gst: 12,
    },
    inventory: {
      currentStock: 200,
      minStock: 30,
      maxStock: 800,
    },
    batches: [
      {
        batchNumber: "PCM001",
        manufactureDate: new Date("2024-02-01"),
        expiryDate: new Date("2027-02-01"),
        quantity: 200,
        sellingPrice: 15.0,
      },
    ],
    indications: ["Fever", "Headache", "Body pain"],
    dosage: {
      adult: "1-2 tablets every 4-6 hours",
      child: "250mg every 6 hours",
      instructions: "Do not exceed 4g in 24 hours",
    },
    description: "Pain relief and fever reducer",
    images: [
      {
        url: "https://via.placeholder.com/300x200/green/white?text=Paracetamol",
        alt: "Paracetamol 500mg",
        isPrimary: true,
      },
    ],
    isActive: true,
    isAvailable: true,
    keywords: ["paracetamol", "fever", "pain", "headache"],
  },
  {
    name: "Amoxicillin 250mg",
    genericName: "Amoxicillin",
    brand: "Novamox",
    manufacturer: "Cipla Ltd",
    composition: "Amoxicillin (250mg)",
    strength: "250mg",
    category: "capsule",
    therapeuticClass: "Antibiotic",
    requiresPrescription: true,
    scheduleType: "H",
    packaging: {
      packSize: 10,
      unit: "piece",
      packType: "strip",
    },
    pricing: {
      mrp: 140.0,
      sellingPrice: 120.0,
      discount: 14,
      currency: "INR",
      gst: 12,
    },
    inventory: {
      currentStock: 80,
      minStock: 15,
      maxStock: 300,
    },
    batches: [
      {
        batchNumber: "AMX001",
        manufactureDate: new Date("2024-03-01"),
        expiryDate: new Date("2027-03-01"),
        quantity: 80,
        sellingPrice: 120.0,
      },
    ],
    indications: ["Bacterial infections", "Respiratory tract infections"],
    dosage: {
      adult: "250-500mg every 8 hours",
      child: "125-250mg every 8 hours",
      instructions: "Complete the full course as prescribed",
    },
    description: "Antibiotic for bacterial infections",
    images: [
      {
        url: "https://via.placeholder.com/300x200/red/white?text=Amoxicillin",
        alt: "Amoxicillin 250mg",
        isPrimary: true,
      },
    ],
    isActive: true,
    isAvailable: true,
    keywords: ["amoxicillin", "antibiotic", "infection", "bacterial"],
  },
  {
    name: "Omeprazole 20mg",
    genericName: "Omeprazole",
    brand: "Omez",
    manufacturer: "Dr. Reddy's",
    composition: "Omeprazole (20mg)",
    strength: "20mg",
    category: "capsule",
    therapeuticClass: "Proton Pump Inhibitor",
    requiresPrescription: false,
    scheduleType: "G",
    packaging: {
      packSize: 10,
      unit: "piece",
      packType: "strip",
    },
    pricing: {
      mrp: 95.0,
      sellingPrice: 80.0,
      discount: 16,
      currency: "INR",
      gst: 12,
    },
    inventory: {
      currentStock: 120,
      minStock: 25,
      maxStock: 400,
    },
    batches: [
      {
        batchNumber: "OME001",
        manufactureDate: new Date("2024-01-20"),
        expiryDate: new Date("2026-01-20"),
        quantity: 120,
        sellingPrice: 80.0,
      },
    ],
    indications: ["Acid reflux", "GERD", "Peptic ulcers"],
    dosage: {
      adult: "One capsule daily before breakfast",
      instructions: "Take on empty stomach",
    },
    description: "Acid reflux and heartburn relief",
    images: [
      {
        url: "https://via.placeholder.com/300x200/purple/white?text=Omeprazole",
        alt: "Omeprazole 20mg",
        isPrimary: true,
      },
    ],
    isActive: true,
    isAvailable: true,
    keywords: ["omeprazole", "acidity", "gastric", "reflux"],
  },
  {
    name: "Cetirizine 10mg",
    genericName: "Cetirizine",
    brand: "Zyrtec",
    manufacturer: "UCB India",
    composition: "Cetirizine Hydrochloride (10mg)",
    strength: "10mg",
    category: "tablet",
    therapeuticClass: "Antihistamine",
    requiresPrescription: false,
    scheduleType: "G",
    packaging: {
      packSize: 10,
      unit: "piece",
      packType: "strip",
    },
    pricing: {
      mrp: 42.0,
      sellingPrice: 35.0,
      discount: 17,
      currency: "INR",
      gst: 12,
    },
    inventory: {
      currentStock: 150,
      minStock: 20,
      maxStock: 500,
    },
    batches: [
      {
        batchNumber: "CET001",
        manufactureDate: new Date("2024-02-15"),
        expiryDate: new Date("2027-02-15"),
        quantity: 150,
        sellingPrice: 35.0,
      },
    ],
    indications: ["Allergic rhinitis", "Urticaria", "Skin allergies"],
    dosage: {
      adult: "One tablet daily",
      child: "Half tablet daily (>6 years)",
      instructions: "Can be taken with or without food",
    },
    description: "Antihistamine for allergies",
    images: [
      {
        url: "https://via.placeholder.com/300x200/orange/white?text=Cetirizine",
        alt: "Cetirizine 10mg",
        isPrimary: true,
      },
    ],
    isActive: true,
    isAvailable: true,
    keywords: ["cetirizine", "allergy", "antihistamine", "rash"],
  },
  {
    name: "Vitamin D3 60K IU",
    genericName: "Cholecalciferol",
    brand: "Uprise D3",
    manufacturer: "Alkem Laboratories",
    composition: "Cholecalciferol (60,000 IU)",
    strength: "60,000 IU",
    category: "capsule",
    therapeuticClass: "Vitamin Supplement",
    requiresPrescription: false,
    scheduleType: "G",
    packaging: {
      packSize: 4,
      unit: "piece",
      packType: "strip",
    },
    pricing: {
      mrp: 52.0,
      sellingPrice: 45.0,
      discount: 13,
      currency: "INR",
      gst: 12,
    },
    inventory: {
      currentStock: 100,
      minStock: 15,
      maxStock: 300,
    },
    batches: [
      {
        batchNumber: "VIT001",
        manufactureDate: new Date("2024-01-01"),
        expiryDate: new Date("2026-01-01"),
        quantity: 100,
        sellingPrice: 45.0,
      },
    ],
    indications: ["Vitamin D deficiency", "Bone health", "Immunity"],
    dosage: {
      adult: "One capsule weekly for 8 weeks",
      instructions: "Take with fatty meal for better absorption",
    },
    description: "Vitamin D supplement",
    images: [
      {
        url: "https://via.placeholder.com/300x200/yellow/black?text=Vitamin+D3",
        alt: "Vitamin D3 60K IU",
        isPrimary: true,
      },
    ],
    isActive: true,
    isAvailable: true,
    keywords: ["vitamin d3", "bones", "immunity", "deficiency"],
  },
];

// Sample Hospitals Data (from your Flutter app)
const hospitalsData = [
  {
    name: "Sawhney Hospital & Maternity Home",
    registrationNumber: "PB-HOSP-001",
    contact: {
      phone: "9814229611",
      email: "info@sawhneyhosp.com",
      emergencyContact: "9814220652",
    },
    address: {
      street: "Ripudaman Pura, Patiala Gate",
      landmark: "Near Gurdwara Akalgarh",
      city: "Nabha",
      state: "Punjab",
      pincode: "147201",
      country: "India",
      coordinates: {
        latitude: 30.37669,
        longitude: 76.16144,
      },
    },
    type: "private",
    category: "secondary",
    accreditation: {
      nabh: {
        certified: true,
        grade: "B",
      },
    },
    facilities: {
      totalBeds: 50,
      icuBeds: 8,
      emergencyBeds: 10,
      operationTheaters: 3,
      ambulanceCount: 2,
      parkingSpaces: 30,
    },
    specialties: [
      {
        name: "Obstetrics & Gynecology",
        department: "Maternity",
        headOfDepartment: "Dr. Sawhney",
        doctors: [
          {
            name: "Dr. Sawhney",
            qualification: "MBBS, MD (OBG)",
            experience: 20,
            specialization: "Obstetrics & Gynecology",
            consultationFee: 600,
            availableDays: [
              "Monday",
              "Tuesday",
              "Wednesday",
              "Thursday",
              "Friday",
              "Saturday",
            ],
            availableTime: "09:00 AM - 06:00 PM",
          },
        ],
        services: [
          "Normal Delivery",
          "C-Section",
          "Prenatal Care",
          "Postnatal Care",
        ],
      },
      {
        name: "General Medicine",
        department: "Internal Medicine",
        doctors: [
          {
            name: "Dr. Kumar",
            qualification: "MBBS, MD",
            experience: 15,
            specialization: "General Medicine",
            consultationFee: 500,
            availableDays: [
              "Monday",
              "Tuesday",
              "Wednesday",
              "Thursday",
              "Friday",
            ],
            availableTime: "10:00 AM - 05:00 PM",
          },
        ],
        services: [
          "General Consultation",
          "Health Checkups",
          "Chronic Disease Management",
        ],
      },
    ],
    services: {
      emergency: {
        available: true,
        hours: "24x7",
      },
      pharmacy: {
        available: true,
        hours: "24x7",
      },
      laboratory: {
        available: true,
        services: ["Blood Tests", "Urine Tests", "X-Ray"],
        hours: "24x7",
      },
      ambulance: {
        available: true,
        types: ["Basic Life Support", "Advanced Life Support"],
        coverage: "Within 50km radius",
      },
    },
    insurance: {
      accepted: [
        {
          provider: "CGHS",
          types: ["Cashless"],
          coverage: "All treatments",
        },
      ],
      governmentSchemes: [
        {
          name: "Ayushman Bharat",
          empanelmentNumber: "AB-PB-001",
          validUntil: new Date("2025-12-31"),
        },
      ],
    },
    operatingHours: {
      monday: { is24Hours: true },
      tuesday: { is24Hours: true },
      wednesday: { is24Hours: true },
      thursday: { is24Hours: true },
      friday: { is24Hours: true },
      saturday: { is24Hours: true },
      sunday: { is24Hours: true },
    },
    ratings: {
      overall: 4.2,
      cleanliness: 4.0,
      staff: 4.3,
      facilities: 4.1,
      cost: 4.5,
      totalReviews: 156,
    },
    verification: {
      isVerified: true,
      verifiedBy: "Health Department Punjab",
      verifiedAt: new Date("2024-01-15"),
    },
    isActive: true,
    isOperational: true,
    statistics: {
      establishedYear: 1995,
      totalPatients: 25000,
      monthlyPatients: 1200,
    },
  },
  {
    name: "Goyal Health Care Hospital",
    registrationNumber: "PB-HOSP-002",
    contact: {
      phone: "9876543210",
      email: "info@goyalhealthcare.com",
    },
    address: {
      street: "Hospital Road",
      city: "Nabha",
      state: "Punjab",
      pincode: "147201",
      country: "India",
      coordinates: {
        latitude: 30.37669,
        longitude: 76.16144,
      },
    },
    type: "private",
    category: "secondary",
    facilities: {
      totalBeds: 30,
      icuBeds: 4,
      emergencyBeds: 6,
      operationTheaters: 2,
      ambulanceCount: 1,
      parkingSpaces: 20,
    },
    specialties: [
      {
        name: "General Medicine",
        department: "Internal Medicine",
        doctors: [
          {
            name: "Dr. Goyal",
            qualification: "MBBS, MD",
            experience: 18,
            specialization: "General Medicine",
            consultationFee: 450,
            availableDays: [
              "Monday",
              "Tuesday",
              "Wednesday",
              "Thursday",
              "Friday",
              "Saturday",
            ],
            availableTime: "09:00 AM - 07:00 PM",
          },
        ],
        services: ["General Consultation", "Emergency Care"],
      },
    ],
    services: {
      emergency: {
        available: true,
        hours: "24x7",
      },
      pharmacy: {
        available: true,
        hours: "08:00 AM - 10:00 PM",
      },
      laboratory: {
        available: true,
        services: ["Basic Tests"],
        hours: "08:00 AM - 08:00 PM",
      },
    },
    operatingHours: {
      monday: { open: "08:00", close: "20:00" },
      tuesday: { open: "08:00", close: "20:00" },
      wednesday: { open: "08:00", close: "20:00" },
      thursday: { open: "08:00", close: "20:00" },
      friday: { open: "08:00", close: "20:00" },
      saturday: { open: "08:00", close: "20:00" },
      sunday: { open: "10:00", close: "18:00" },
    },
    ratings: {
      overall: 3.8,
      cleanliness: 3.5,
      staff: 4.0,
      facilities: 3.8,
      cost: 4.2,
      totalReviews: 89,
    },
    verification: {
      isVerified: true,
      verifiedBy: "Health Department Punjab",
      verifiedAt: new Date("2024-02-01"),
    },
    isActive: true,
    isOperational: true,
    statistics: {
      establishedYear: 2005,
      totalPatients: 15000,
      monthlyPatients: 800,
    },
  },
  {
    name: "Nabha Healthcare (Main Branch)",
    registrationNumber: "PB-HOSP-003",
    contact: {
      phone: "9876543212",
      email: "contact@nabhahealthcare.com",
      website: "https://nabhahealthcare.com",
    },
    address: {
      street: "Medical Complex, Civil Lines",
      city: "Nabha",
      state: "Punjab",
      pincode: "147201",
      country: "India",
      coordinates: {
        latitude: 30.375,
        longitude: 76.16,
      },
    },
    type: "private",
    category: "tertiary",
    accreditation: {
      nabh: {
        certified: true,
        grade: "A",
      },
      iso: {
        certified: true,
        standard: "ISO 9001:2015",
      },
    },
    facilities: {
      totalBeds: 100,
      icuBeds: 15,
      emergencyBeds: 20,
      operationTheaters: 6,
      ambulanceCount: 4,
      parkingSpaces: 80,
    },
    specialties: [
      {
        name: "General Medicine",
        department: "Internal Medicine",
        headOfDepartment: "Dr. Sachin Kumar",
        doctors: [
          {
            name: "Dr. Sachin Kumar",
            qualification: "MBBS, MD",
            experience: 15,
            specialization: "General Physician",
            consultationFee: 500,
            availableDays: [
              "Monday",
              "Tuesday",
              "Wednesday",
              "Thursday",
              "Friday",
            ],
            availableTime: "09:00 AM - 05:00 PM",
          },
        ],
        services: [
          "General Consultation",
          "Preventive Medicine",
          "Health Checkups",
        ],
      },
      {
        name: "Pediatrics",
        department: "Child Care",
        doctors: [
          {
            name: "Dr. Tarun Thakur",
            qualification: "MBBS, DCH",
            experience: 12,
            specialization: "Pediatrician",
            consultationFee: 600,
            availableDays: [
              "Monday",
              "Tuesday",
              "Wednesday",
              "Thursday",
              "Friday",
              "Saturday",
            ],
            availableTime: "10:00 AM - 06:00 PM",
          },
        ],
        services: ["Child Care", "Vaccination", "Growth Monitoring"],
      },
    ],
    services: {
      emergency: {
        available: true,
        hours: "24x7",
      },
      pharmacy: {
        available: true,
        hours: "24x7",
      },
      laboratory: {
        available: true,
        services: [
          "Complete Blood Count",
          "Biochemistry",
          "Microbiology",
          "Pathology",
        ],
        hours: "24x7",
      },
      radiology: {
        available: true,
        equipment: ["X-Ray", "Ultrasound", "CT Scan"],
        hours: "24x7",
      },
      telemedicine: {
        available: true,
        platforms: ["Nabha Health App", "Video Call"],
      },
    },
    insurance: {
      accepted: [
        {
          provider: "CGHS",
          types: ["Cashless", "Reimbursement"],
        },
        {
          provider: "ECHS",
          types: ["Cashless"],
        },
      ],
      governmentSchemes: [
        {
          name: "Ayushman Bharat",
          empanelmentNumber: "AB-PB-003",
          validUntil: new Date("2025-12-31"),
        },
      ],
    },
    operatingHours: {
      monday: { is24Hours: true },
      tuesday: { is24Hours: true },
      wednesday: { is24Hours: true },
      thursday: { is24Hours: true },
      friday: { is24Hours: true },
      saturday: { is24Hours: true },
      sunday: { is24Hours: true },
    },
    ratings: {
      overall: 4.6,
      cleanliness: 4.5,
      staff: 4.7,
      facilities: 4.6,
      cost: 4.3,
      totalReviews: 324,
    },
    verification: {
      isVerified: true,
      verifiedBy: "Health Department Punjab",
      verifiedAt: new Date("2024-01-01"),
    },
    isActive: true,
    isOperational: true,
    statistics: {
      establishedYear: 2020,
      totalPatients: 45000,
      monthlyPatients: 2500,
      successfulSurgeries: 1200,
    },
  },
];

// Function to seed the database
async function seedDatabase() {
  try {
    console.log("🌱 Starting database seeding...");

    // Connect to database
    await connectDB();

    // Clear existing data (optional - comment out in production)
    console.log("🗑️  Clearing existing data...");
    await User.deleteMany({});
    await Medicine.deleteMany({});
    await Hospital.deleteMany({});
    await PharmacyOrder.deleteMany({});
    await Appointment.deleteMany({});
    await MedicalRecord.deleteMany({});
    await ChatSession.deleteMany({});

    console.log("✅ Existing data cleared");

    // Seed Users
    console.log("👥 Seeding users...");
    const users = await User.insertMany(usersData);
    console.log(`✅ Created ${users.length} users`);

    // Seed Medicines
    console.log("💊 Seeding medicines...");
    const medicines = await Medicine.insertMany(medicinesData);
    console.log(`✅ Created ${medicines.length} medicines`);

    // Seed Hospitals
    console.log("🏥 Seeding hospitals...");
    const hospitals = await Hospital.insertMany(hospitalsData);
    console.log(`✅ Created ${hospitals.length} hospitals`);

    // Create sample appointments
    console.log("📅 Creating sample appointments...");
    const sampleAppointments = [
      {
        patient: users[0]._id, // Sachin Kumar Raj
        doctor: {
          name: "Dr. Sachin Kumar",
          specialization: "General Physician",
          hospital: "Nabha Healthcare",
          hospitalId: hospitals[2]._id.toString(),
          experience: 15,
          rating: 4.8,
          fees: {
            consultation: 500,
            currency: "INR",
          },
          avatar:
            "https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=400",
          languages: ["English", "Hindi", "Punjabi"],
        },
        appointmentDate: new Date("2025-10-25"),
        appointmentTime: "10:00",
        duration: 30,
        type: "video_call",
        symptoms: "Fever and headache for 2 days",
        payment: {
          amount: 500,
          status: "completed",
          method: "razorpay",
        },
        status: "confirmed",
      },
      {
        patient: users[2]._id, // Priya Sharma
        doctor: {
          name: "Dr. Tarun Thakur",
          specialization: "Pediatrician",
          hospital: "Nabha Healthcare",
          hospitalId: hospitals[2]._id.toString(),
          experience: 12,
          rating: 4.9,
          fees: {
            consultation: 600,
            currency: "INR",
          },
          avatar:
            "https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=400",
          languages: ["English", "Hindi"],
        },
        appointmentDate: new Date("2025-10-26"),
        appointmentTime: "11:00",
        duration: 30,
        type: "in_person",
        symptoms: "Child vaccination consultation",
        payment: {
          amount: 600,
          status: "pending",
          method: "razorpay",
        },
        status: "scheduled",
      },
    ];

    const appointments = await Appointment.insertMany(sampleAppointments);
    console.log(`✅ Created ${appointments.length} appointments`);

    // Create sample pharmacy orders
    console.log("🛒 Creating sample pharmacy orders...");
    const sampleOrders = [
      {
        orderId: "PH-001-2025",
        customer: users[0]._id,
        items: [
          {
            medicine: medicines[0]._id, // Ecosprin
            name: medicines[0].name,
            manufacturer: medicines[0].manufacturer,
            category: medicines[0].category,
            quantity: 2,
            pricePerUnit: medicines[0].pricing.sellingPrice,
            totalPrice: medicines[0].pricing.sellingPrice * 2,
            availability: "in_stock",
          },
          {
            medicine: medicines[1]._id, // Paracetamol
            name: medicines[1].name,
            manufacturer: medicines[1].manufacturer,
            category: medicines[1].category,
            quantity: 1,
            pricePerUnit: medicines[1].pricing.sellingPrice,
            totalPrice: medicines[1].pricing.sellingPrice * 1,
            availability: "in_stock",
          },
        ],
        summary: {
          subtotal:
            medicines[0].pricing.sellingPrice * 2 +
            medicines[1].pricing.sellingPrice,
          deliveryCharges: 0,
          tax: 0,
          total:
            medicines[0].pricing.sellingPrice * 2 +
            medicines[1].pricing.sellingPrice,
        },
        delivery: {
          type: "home_delivery",
          address: {
            name: users[0].name,
            phone: users[0].phone,
            street: users[0].address.street,
            city: users[0].address.city,
            state: users[0].address.state,
            pincode: users[0].address.pincode,
            country: users[0].address.country,
          },
          estimatedDeliveryDate: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000), // 2 days from now
        },
        payment: {
          method: "razorpay",
          status: "completed",
          amount:
            medicines[0].pricing.sellingPrice * 2 +
            medicines[1].pricing.sellingPrice,
        },
        pharmacy: {
          name: "Nabha Healthcare Pharmacy",
          licenseNumber: "PH-PB-001",
        },
        status: "confirmed",
      },
    ];

    const orders = await PharmacyOrder.insertMany(sampleOrders);
    console.log(`✅ Created ${orders.length} pharmacy orders`);

    // Create sample medical records
    console.log("📋 Creating sample medical records...");
    const sampleRecords = [
      {
        recordId: "MR-001-2025",
        patient: users[0]._id,
        recordType: "consultation",
        provider: {
          doctorName: "Dr. Sachin Kumar",
          doctorSpecialization: "General Physician",
          hospitalName: "Nabha Healthcare",
          hospitalId: hospitals[2]._id.toString(),
        },
        visitDate: new Date("2024-10-20"),
        visitType: "scheduled",
        chiefComplaint: "Fever and headache",
        presentIllness:
          "Patient complains of fever (101°F) and headache for the past 2 days",
        vitalSigns: {
          temperature: { value: 101, unit: "F" },
          bloodPressure: { systolic: 120, diastolic: 80, unit: "mmHg" },
          heartRate: { value: 80, unit: "bpm" },
          weight: { value: 70, unit: "kg" },
          height: { value: 175, unit: "cm" },
        },
        diagnosis: {
          primary: "Viral fever",
          severity: "mild",
        },
        treatment: {
          medications: [
            {
              name: "Paracetamol 500mg",
              dosage: "500mg",
              frequency: "Every 6 hours",
              duration: "3 days",
              instructions: "Take after food",
            },
          ],
        },
        status: "final",
      },
    ];

    const medicalRecords = await MedicalRecord.insertMany(sampleRecords);
    console.log(`✅ Created ${medicalRecords.length} medical records`);

    console.log("🎉 Database seeding completed successfully!");
    console.log(`
📊 Summary:
- Users: ${users.length}
- Medicines: ${medicines.length}
- Hospitals: ${hospitals.length}
- Appointments: ${appointments.length}
- Pharmacy Orders: ${orders.length}
- Medical Records: ${medicalRecords.length}
    `);

    process.exit(0);
  } catch (error) {
    console.error("❌ Error seeding database:", error);
    process.exit(1);
  }
}

// Run the seeding
if (require.main === module) {
  seedDatabase();
}

module.exports = { seedDatabase };
