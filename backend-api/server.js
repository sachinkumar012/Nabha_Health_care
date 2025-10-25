const express = require("express");
const dotenv = require("dotenv");
const helmet = require("helmet");
const morgan = require("morgan");
const cors = require("cors");
const compression = require("compression");
const rateLimit = require("express-rate-limit");
const mongoSanitize = require("express-mongo-sanitize");
const xss = require("xss-clean");
const hpp = require("hpp");

// Load environment variables
dotenv.config();

// Import database connection
const connectDB = require("./src/config/database");

// Import middleware
const {
  errorHandler,
  notFound,
  requestLogger,
} = require("./src/middleware/auth");

// Import routes
// TODO: Import route files when created
// const authRoutes = require('./routes/auth');
// const userRoutes = require('./routes/users');
// const appointmentRoutes = require('./routes/appointments');
// const pharmacyRoutes = require('./routes/pharmacy');
// const hospitalRoutes = require('./routes/hospitals');
// const medicalRecordRoutes = require('./routes/medicalRecords');
// const chatRoutes = require('./routes/chat');

// Connect to database
connectDB();

// Initialize Express app
const app = express();

// Security middleware
app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com"],
        fontSrc: ["'self'", "https://fonts.gstatic.com"],
        imgSrc: ["'self'", "data:", "https:"],
        scriptSrc: ["'self'"],
        connectSrc: ["'self'", "ws:", "wss:"],
      },
    },
  })
);

// CORS configuration
const corsOptions = {
  origin: function (origin, callback) {
    const allowedOrigins = process.env.ALLOWED_ORIGINS
      ? process.env.ALLOWED_ORIGINS.split(",")
      : [
          "http://localhost:3000",
          "http://localhost:5173",
          "http://localhost:8080",
        ];

    // Allow requests with no origin (mobile apps, Postman, etc.)
    if (!origin) return callback(null, true);

    if (allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error("Not allowed by CORS"));
    }
  },
  credentials: true,
  methods: ["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
  allowedHeaders: [
    "Content-Type",
    "Authorization",
    "X-Requested-With",
    "x-api-key",
  ],
};

app.use(cors(corsOptions));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: process.env.NODE_ENV === "production" ? 100 : 1000, // limit each IP to 100 requests per windowMs in production
  message: {
    success: false,
    message: "Too many requests from this IP, please try again later.",
  },
  standardHeaders: true,
  legacyHeaders: false,
});

app.use(limiter);

// Body parser middleware
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// Data sanitization against NoSQL query injection
app.use(mongoSanitize());

// Data sanitization against XSS
app.use(xss());

// Prevent http param pollution
app.use(
  hpp({
    whitelist: ["tags", "categories", "specialties"], // Allow arrays for these parameters
  })
);

// Compression middleware
app.use(compression());

// Logging middleware
if (process.env.NODE_ENV === "development") {
  app.use(morgan("dev"));
}
app.use(requestLogger);

// Health check endpoint
app.get("/health", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Nabha Healthcare API is running",
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || "development",
    version: process.env.npm_package_version || "1.0.0",
  });
});

// API Routes
app.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Welcome to Nabha Healthcare API",
    documentation: "/api/docs",
    health: "/health",
  });
});

// Mount routes
app.use("/api/auth", require("./src/routes/auth"));
app.use("/api/users", require("./src/routes/users"));
app.use("/api/appointments", require("./src/routes/appointments"));
app.use("/api/pharmacy", require("./src/routes/pharmacy"));
app.use("/api/hospitals", require("./src/routes/hospitals"));

// API documentation placeholder
app.get("/api/docs", (req, res) => {
  res.status(200).json({
    success: true,
    message: "API Documentation",
    endpoints: {
      auth: {
        login: "POST /api/auth/login",
        register: "POST /api/auth/register",
        profile: "GET /api/auth/profile",
        refresh: "POST /api/auth/refresh",
      },
      users: {
        profile: "GET /api/users/profile",
        update: "PUT /api/users/profile",
        avatar: "POST /api/users/avatar",
      },
      appointments: {
        list: "GET /api/appointments",
        create: "POST /api/appointments",
        details: "GET /api/appointments/:id",
        update: "PUT /api/appointments/:id",
        cancel: "DELETE /api/appointments/:id",
      },
      pharmacy: {
        medicines: "GET /api/pharmacy/medicines",
        search: "GET /api/pharmacy/search",
        orders: "GET /api/pharmacy/orders",
        createOrder: "POST /api/pharmacy/orders",
        orderDetails: "GET /api/pharmacy/orders/:id",
      },
      hospitals: {
        list: "GET /api/hospitals",
        search: "GET /api/hospitals/search",
        nearby: "GET /api/hospitals/nearby",
        details: "GET /api/hospitals/:id",
      },
      medicalRecords: {
        list: "GET /api/medical-records",
        create: "POST /api/medical-records",
        details: "GET /api/medical-records/:id",
        update: "PUT /api/medical-records/:id",
      },
      chat: {
        sessions: "GET /api/chat/sessions",
        create: "POST /api/chat/sessions",
        messages: "GET /api/chat/sessions/:id/messages",
        sendMessage: "POST /api/chat/sessions/:id/messages",
      },
    },
  });
});

// Error handling middleware
app.use(notFound);
app.use(errorHandler);

// Graceful shutdown
process.on("SIGTERM", () => {
  console.log("SIGTERM received, shutting down gracefully");
  server.close(() => {
    console.log("Process terminated");
  });
});

process.on("unhandledRejection", (err, promise) => {
  console.log(`Unhandled Rejection: ${err.message}`);
  // Close server & exit process
  server.close(() => {
    process.exit(1);
  });
});

process.on("uncaughtException", (err) => {
  console.log(`Uncaught Exception: ${err.message}`);
  console.log("Shutting down due to uncaught exception");
  process.exit(1);
});

// Start server
const PORT = process.env.PORT || 5000;
const server = app.listen(PORT, () => {
  console.log(
    `
🚀 Nabha Healthcare API Server is running!
📍 Environment: ${process.env.NODE_ENV || "development"}
🌐 Server URL: http://localhost:${PORT}
📊 Health Check: http://localhost:${PORT}/health
📚 API Docs: http://localhost:${PORT}/api/docs
  `.green
  );
});

module.exports = app;
