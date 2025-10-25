const mongoose = require("mongoose");
const colors = require("colors");

const connectDB = async () => {
  try {
    const mongoURI =
      process.env.MONGODB_URI || "mongodb://localhost:27017/nabha_healthcare";

    const conn = await mongoose.connect(mongoURI, {
      // Mongoose 6+ doesn't need these deprecated options
      // useNewUrlParser: true,
      // useUnifiedTopology: true,
    });

    console.log(
      `MongoDB Connected: ${conn.connection.host}`.cyan.underline.bold
    );

    // Handle connection events
    mongoose.connection.on("connected", () => {
      console.log("Mongoose connected to MongoDB".green);
    });

    mongoose.connection.on("error", (err) => {
      console.error(`Mongoose connection error: ${err}`.red.bold);
    });

    mongoose.connection.on("disconnected", () => {
      console.log("Mongoose disconnected from MongoDB".yellow);
    });

    // Graceful shutdown
    process.on("SIGINT", async () => {
      try {
        await mongoose.connection.close();
        console.log("MongoDB connection closed through app termination".cyan);
        process.exit(0);
      } catch (error) {
        console.error("Error during graceful shutdown:", error);
        process.exit(1);
      }
    });

    return conn;
  } catch (error) {
    console.error(`MongoDB connection error: ${error.message}`.red.bold);
    process.exit(1);
  }
};

module.exports = connectDB;
