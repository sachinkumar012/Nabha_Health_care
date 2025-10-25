// Video Consultation Backend Routes for MongoDB
const express = require("express");
const router = express.Router();
const { ObjectId } = require("mongodb");

// Assuming you have a MongoDB connection set up
let db;

// Initialize database connection
function initDB(database) {
  db = database;
}

// Get all available doctors
router.get("/doctors", async (req, res) => {
  try {
    const { specialty } = req.query;

    const query = specialty
      ? { specialty, isAvailable: true }
      : { isAvailable: true };

    const doctors = await db.collection("doctors").find(query).toArray();

    res.status(200).json({
      success: true,
      doctors: doctors,
    });
  } catch (error) {
    console.error("Error fetching doctors:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch doctors",
      error: error.message,
    });
  }
});

// Book a video consultation
router.post("/book", async (req, res) => {
  try {
    const { userId, doctorId, scheduledTime, symptoms, notes } = req.body;

    if (!userId || !doctorId || !scheduledTime) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields",
      });
    }

    // Get doctor details
    const doctor = await db
      .collection("doctors")
      .findOne({ _id: new ObjectId(doctorId) });

    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: "Doctor not found",
      });
    }

    // Create consultation
    const consultation = {
      userId: userId,
      doctorId: doctorId,
      doctorName: doctor.name,
      doctorSpecialty: doctor.specialty,
      doctorImage: doctor.image,
      scheduledTime: new Date(scheduledTime),
      symptoms: symptoms,
      notes: notes,
      status: "scheduled",
      consultationFee: doctor.consultationFee,
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    const result = await db
      .collection("video_consultations")
      .insertOne(consultation);
    consultation._id = result.insertedId;
    consultation.id = result.insertedId.toString();

    res.status(201).json({
      success: true,
      message: "Consultation booked successfully",
      consultation: consultation,
    });
  } catch (error) {
    console.error("Error booking consultation:", error);
    res.status(500).json({
      success: false,
      message: "Failed to book consultation",
      error: error.message,
    });
  }
});

// Get user's consultations
router.get("/my-consultations", async (req, res) => {
  try {
    const { userId, status } = req.query;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    const query = { userId: userId };
    if (status) {
      query.status = status;
    }

    const consultations = await db
      .collection("video_consultations")
      .find(query)
      .sort({ scheduledTime: -1 })
      .toArray();

    // Add id field for Flutter
    consultations.forEach((consultation) => {
      consultation.id = consultation._id.toString();
    });

    res.status(200).json({
      success: true,
      consultations: consultations,
    });
  } catch (error) {
    console.error("Error fetching consultations:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch consultations",
      error: error.message,
    });
  }
});

// Cancel consultation
router.post("/cancel/:consultationId", async (req, res) => {
  try {
    const { consultationId } = req.params;
    const { reason } = req.body;

    const result = await db.collection("video_consultations").updateOne(
      { _id: new ObjectId(consultationId) },
      {
        $set: {
          status: "cancelled",
          cancellationReason: reason,
          cancelledAt: new Date(),
          updatedAt: new Date(),
        },
      }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({
        success: false,
        message: "Consultation not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Consultation cancelled successfully",
    });
  } catch (error) {
    console.error("Error cancelling consultation:", error);
    res.status(500).json({
      success: false,
      message: "Failed to cancel consultation",
      error: error.message,
    });
  }
});

// Reschedule consultation
router.post("/reschedule/:consultationId", async (req, res) => {
  try {
    const { consultationId } = req.params;
    const { newDateTime } = req.body;

    if (!newDateTime) {
      return res.status(400).json({
        success: false,
        message: "New date time is required",
      });
    }

    const result = await db.collection("video_consultations").updateOne(
      { _id: new ObjectId(consultationId) },
      {
        $set: {
          scheduledTime: new Date(newDateTime),
          rescheduled: true,
          rescheduledAt: new Date(),
          updatedAt: new Date(),
        },
      }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({
        success: false,
        message: "Consultation not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Consultation rescheduled successfully",
    });
  } catch (error) {
    console.error("Error rescheduling consultation:", error);
    res.status(500).json({
      success: false,
      message: "Failed to reschedule consultation",
      error: error.message,
    });
  }
});

// Join video call (get token/room details)
router.post("/join/:consultationId", async (req, res) => {
  try {
    const { consultationId } = req.params;

    const consultation = await db.collection("video_consultations").findOne({
      _id: new ObjectId(consultationId),
    });

    if (!consultation) {
      return res.status(404).json({
        success: false,
        message: "Consultation not found",
      });
    }

    // Update consultation status to in-progress
    await db.collection("video_consultations").updateOne(
      { _id: new ObjectId(consultationId) },
      {
        $set: {
          status: "in-progress",
          startedAt: new Date(),
          updatedAt: new Date(),
        },
      }
    );

    // Generate Agora token or room details
    // For now, returning basic call data
    res.status(200).json({
      success: true,
      callData: {
        roomId: consultationId,
        channelName: `consultation_${consultationId}`,
        token: "demo_token_" + consultationId,
        appId: "your_agora_app_id",
      },
    });
  } catch (error) {
    console.error("Error joining call:", error);
    res.status(500).json({
      success: false,
      message: "Failed to join call",
      error: error.message,
    });
  }
});

module.exports = { router, initDB };
