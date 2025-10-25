const jwt = require("jsonwebtoken");
const User = require("../models/User");

// Async handler middleware
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// Protect routes
const protect = async (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith("Bearer")
  ) {
    try {
      // Get token from header
      token = req.headers.authorization.split(" ")[1];

      // Verify token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // Get user from the token
      req.user = await User.findById(decoded.id).select(
        "-password -refreshTokens"
      );

      if (!req.user) {
        return res.status(401).json({
          success: false,
          message: "User not found",
        });
      }

      if (!req.user.isActive) {
        return res.status(401).json({
          success: false,
          message: "Account is deactivated",
        });
      }

      next();
    } catch (error) {
      console.error("JWT Error:", error);
      return res.status(401).json({
        success: false,
        message: "Not authorized, token failed",
      });
    }
  }

  if (!token) {
    return res.status(401).json({
      success: false,
      message: "Not authorized, no token",
    });
  }
};

// Admin middleware
const admin = (req, res, next) => {
  if (req.user && req.user.role === "admin") {
    next();
  } else {
    res.status(403).json({
      success: false,
      message: "Not authorized as admin",
    });
  }
};

// Doctor middleware
const doctor = (req, res, next) => {
  if (req.user && (req.user.role === "doctor" || req.user.role === "admin")) {
    next();
  } else {
    res.status(403).json({
      success: false,
      message: "Not authorized as doctor",
    });
  }
};

// Grant access to specific roles
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: "Access denied",
      });
    }

    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: "User role is not authorized to access this route",
      });
    }

    next();
  };
};

// Verify email middleware
const verifyEmail = (req, res, next) => {
  if (req.user && req.user.emailVerified) {
    next();
  } else {
    res.status(403).json({
      success: false,
      message: "Email verification required",
    });
  }
};

// Rate limiting middleware
const createRateLimiter = (windowMs, max, message) => {
  const requests = new Map();

  return (req, res, next) => {
    const key = req.ip || req.connection.remoteAddress;
    const now = Date.now();
    const windowStart = now - windowMs;

    // Clean old requests
    if (requests.has(key)) {
      const userRequests = requests
        .get(key)
        .filter((time) => time > windowStart);
      requests.set(key, userRequests);
    }

    const userRequests = requests.get(key) || [];

    if (userRequests.length >= max) {
      return res.status(429).json({
        success: false,
        message: message || "Too many requests, please try again later",
      });
    }

    userRequests.push(now);
    requests.set(key, userRequests);
    next();
  };
};

// API key middleware (for third-party integrations)
const apiKey = (req, res, next) => {
  const apiKey = req.headers["x-api-key"];

  if (!apiKey) {
    return res.status(401).json({
      success: false,
      message: "API key required",
    });
  }

  // Validate API key (you would store these in database)
  const validApiKeys = process.env.VALID_API_KEYS
    ? process.env.VALID_API_KEYS.split(",")
    : [];

  if (!validApiKeys.includes(apiKey)) {
    return res.status(401).json({
      success: false,
      message: "Invalid API key",
    });
  }

  next();
};

// CORS middleware
const cors = (req, res, next) => {
  const allowedOrigins = process.env.ALLOWED_ORIGINS
    ? process.env.ALLOWED_ORIGINS.split(",")
    : ["http://localhost:3000", "http://localhost:5173"];

  const origin = req.headers.origin;

  if (allowedOrigins.includes(origin)) {
    res.setHeader("Access-Control-Allow-Origin", origin);
  }

  res.setHeader(
    "Access-Control-Allow-Methods",
    "GET, POST, PUT, DELETE, OPTIONS"
  );
  res.setHeader(
    "Access-Control-Allow-Headers",
    "Content-Type, Authorization, x-api-key"
  );
  res.setHeader("Access-Control-Allow-Credentials", "true");

  if (req.method === "OPTIONS") {
    res.status(200).end();
    return;
  }

  next();
};

// Request logger middleware
const requestLogger = (req, res, next) => {
  const timestamp = new Date().toISOString();
  const method = req.method;
  const url = req.url;
  const ip = req.ip || req.connection.remoteAddress;
  const userAgent = req.headers["user-agent"];

  console.log(`[${timestamp}] ${method} ${url} - ${ip} - ${userAgent}`);

  // Log response time
  const start = Date.now();
  res.on("finish", () => {
    const duration = Date.now() - start;
    console.log(
      `[${timestamp}] ${method} ${url} - ${res.statusCode} - ${duration}ms`
    );
  });

  next();
};

// Error handler middleware
const errorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;

  // Log error
  console.error(err);

  // Mongoose bad ObjectId
  if (err.name === "CastError") {
    const message = "Resource not found";
    error = { message, statusCode: 404 };
  }

  // Mongoose duplicate key
  if (err.code === 11000) {
    const message = "Duplicate field value entered";
    error = { message, statusCode: 400 };
  }

  // Mongoose validation error
  if (err.name === "ValidationError") {
    const message = Object.values(err.errors)
      .map((val) => val.message)
      .join(", ");
    error = { message, statusCode: 400 };
  }

  // JWT errors
  if (err.name === "JsonWebTokenError") {
    const message = "Invalid token";
    error = { message, statusCode: 401 };
  }

  if (err.name === "TokenExpiredError") {
    const message = "Token expired";
    error = { message, statusCode: 401 };
  }

  res.status(error.statusCode || 500).json({
    success: false,
    message: error.message || "Server Error",
    ...(process.env.NODE_ENV === "development" && { stack: err.stack }),
  });
};

// Not found middleware
const notFound = (req, res, next) => {
  const error = new Error(`Not Found - ${req.originalUrl}`);
  res.status(404);
  next(error);
};

module.exports = {
  protect,
  authorize,
  asyncHandler,
  admin,
  doctor,
  verifyEmail,
  createRateLimiter,
  apiKey,
  cors,
  requestLogger,
  errorHandler,
  notFound,
};
