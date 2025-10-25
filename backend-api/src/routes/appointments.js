const express = require("express");
const Appointment = require("../models/Appointment");
const User = require("../models/User");
const { protect, authorize, asyncHandler } = require("../middleware/auth");

const router = express.Router();

// @desc    Get user's appointments
// @route   GET /api/appointments
// @access  Private
router.get(
  "/",
  protect,
  asyncHandler(async (req, res) => {
    const { status, type, fromDate, toDate, page = 1, limit = 10 } = req.query;

    let filter = {
      $or: [{ patient: req.user.id }, { doctor: req.user.id }],
    };

    // Add status filter
    if (status) {
      filter.status = status;
    }

    // Add type filter
    if (type) {
      filter.type = type;
    }

    // Add date range filter
    if (fromDate || toDate) {
      filter.appointmentDate = {};
      if (fromDate) {
        filter.appointmentDate.$gte = new Date(fromDate);
      }
      if (toDate) {
        filter.appointmentDate.$lte = new Date(toDate);
      }
    }

    const appointments = await Appointment.find(filter)
      .populate("patient", "name email phone profileImage")
      .populate("doctor", "name specialization experience ratings profileImage")
      .populate("hospital", "name address phone")
      .sort({ appointmentDate: -1 })
      .limit(parseInt(limit))
      .skip((parseInt(page) - 1) * parseInt(limit));

    const total = await Appointment.countDocuments(filter);

    res.status(200).json({
      success: true,
      count: appointments.length,
      total,
      page: parseInt(page),
      totalPages: Math.ceil(total / parseInt(limit)),
      data: appointments,
    });
  })
);

// @desc    Get appointment by ID
// @route   GET /api/appointments/:id
// @access  Private
router.get(
  "/:id",
  protect,
  asyncHandler(async (req, res) => {
    const appointment = await Appointment.findById(req.params.id)
      .populate("patient", "name email phone profileImage abhaNumber")
      .populate("doctor", "name specialization experience ratings profileImage")
      .populate("hospital", "name address phone facilities services");

    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: "Appointment not found",
      });
    }

    // Check if user is either the patient or doctor for this appointment
    if (
      appointment.patient._id.toString() !== req.user.id &&
      appointment.doctor._id.toString() !== req.user.id
    ) {
      return res.status(403).json({
        success: false,
        message: "Not authorized to access this appointment",
      });
    }

    res.status(200).json({
      success: true,
      data: appointment,
    });
  })
);

// @desc    Create new appointment
// @route   POST /api/appointments
// @access  Private
router.post(
  "/",
  protect,
  asyncHandler(async (req, res) => {
    const {
      doctor,
      hospital,
      appointmentDate,
      appointmentTime,
      type = "general",
      reasonForVisit,
      consultationFee,
    } = req.body;

    // Check if doctor exists
    const doctorUser = await User.findById(doctor);
    if (!doctorUser || doctorUser.role !== "doctor") {
      return res.status(404).json({
        success: false,
        message: "Doctor not found",
      });
    }

    // Check for conflicting appointments
    const existingAppointment = await Appointment.findOne({
      doctor,
      appointmentDate: new Date(appointmentDate),
      appointmentTime,
      status: { $in: ["scheduled", "confirmed"] },
    });

    if (existingAppointment) {
      return res.status(400).json({
        success: false,
        message: "Doctor is not available at this time",
      });
    }

    const appointment = await Appointment.create({
      patient: req.user.id,
      doctor,
      hospital,
      appointmentDate: new Date(appointmentDate),
      appointmentTime,
      type,
      reasonForVisit,
      consultationFee: consultationFee || 500,
      status: "pending",
    });

    const populatedAppointment = await Appointment.findById(appointment._id)
      .populate("patient", "name email phone")
      .populate("doctor", "name specialization")
      .populate("hospital", "name address");

    res.status(201).json({
      success: true,
      data: populatedAppointment,
    });
  })
);

// @desc    Update appointment status
// @route   PUT /api/appointments/:id/status
// @access  Private
router.put(
  "/:id/status",
  protect,
  asyncHandler(async (req, res) => {
    const { status, notes } = req.body;

    const appointment = await Appointment.findById(req.params.id);

    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: "Appointment not found",
      });
    }

    // Only doctor can confirm/complete appointments, patient can cancel
    if (status === "confirmed" || status === "completed") {
      if (appointment.doctor.toString() !== req.user.id) {
        return res.status(403).json({
          success: false,
          message: "Only the assigned doctor can update this status",
        });
      }
    } else if (status === "cancelled") {
      if (
        appointment.patient.toString() !== req.user.id &&
        appointment.doctor.toString() !== req.user.id
      ) {
        return res.status(403).json({
          success: false,
          message: "Not authorized to cancel this appointment",
        });
      }
    }

    appointment.status = status;
    if (notes) {
      appointment.notes = notes;
    }

    if (status === "completed") {
      appointment.completedAt = new Date();
    }

    await appointment.save();

    const updatedAppointment = await Appointment.findById(appointment._id)
      .populate("patient", "name email phone")
      .populate("doctor", "name specialization")
      .populate("hospital", "name address");

    res.status(200).json({
      success: true,
      data: updatedAppointment,
    });
  })
);

// @desc    Reschedule appointment
// @route   PUT /api/appointments/:id/reschedule
// @access  Private
router.put(
  "/:id/reschedule",
  protect,
  asyncHandler(async (req, res) => {
    const { appointmentDate, appointmentTime } = req.body;

    const appointment = await Appointment.findById(req.params.id);

    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: "Appointment not found",
      });
    }

    // Only patient can reschedule
    if (appointment.patient.toString() !== req.user.id) {
      return res.status(403).json({
        success: false,
        message: "Only the patient can reschedule this appointment",
      });
    }

    // Check if new time slot is available
    const conflictingAppointment = await Appointment.findOne({
      doctor: appointment.doctor,
      appointmentDate: new Date(appointmentDate),
      appointmentTime,
      status: { $in: ["scheduled", "confirmed"] },
      _id: { $ne: appointment._id },
    });

    if (conflictingAppointment) {
      return res.status(400).json({
        success: false,
        message: "Doctor is not available at this time",
      });
    }

    appointment.appointmentDate = new Date(appointmentDate);
    appointment.appointmentTime = appointmentTime;
    appointment.status = "rescheduled";

    await appointment.save();

    const updatedAppointment = await Appointment.findById(appointment._id)
      .populate("patient", "name email phone")
      .populate("doctor", "name specialization")
      .populate("hospital", "name address");

    res.status(200).json({
      success: true,
      data: updatedAppointment,
    });
  })
);

// @desc    Get available time slots for a doctor
// @route   GET /api/appointments/available-slots
// @access  Public
router.get(
  "/available-slots",
  asyncHandler(async (req, res) => {
    const { doctorId, date } = req.query;

    if (!doctorId || !date) {
      return res.status(400).json({
        success: false,
        message: "Doctor ID and date are required",
      });
    }

    const appointmentDate = new Date(date);
    const startOfDay = new Date(appointmentDate);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(appointmentDate);
    endOfDay.setHours(23, 59, 59, 999);

    // Get all booked appointments for the doctor on this date
    const bookedAppointments = await Appointment.find({
      doctor: doctorId,
      appointmentDate: {
        $gte: startOfDay,
        $lte: endOfDay,
      },
      status: { $in: ["scheduled", "confirmed", "pending"] },
    }).select("appointmentTime");

    const bookedSlots = bookedAppointments.map((apt) => apt.appointmentTime);

    // Define available time slots (9 AM to 6 PM)
    const allSlots = [
      "09:00",
      "09:30",
      "10:00",
      "10:30",
      "11:00",
      "11:30",
      "12:00",
      "12:30",
      "14:00",
      "14:30",
      "15:00",
      "15:30",
      "16:00",
      "16:30",
      "17:00",
      "17:30",
      "18:00",
    ];

    const availableSlots = allSlots.filter(
      (slot) => !bookedSlots.includes(slot)
    );

    res.status(200).json({
      success: true,
      date: appointmentDate,
      availableSlots,
      bookedSlots,
    });
  })
);

module.exports = router;
