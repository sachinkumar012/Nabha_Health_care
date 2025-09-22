const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');

const app = express();
const server = http.createServer(app);

// Enable CORS for your Vercel domain
const io = socketIo(server, {
  cors: {
    origin: ["https://nabha-health-care-two.vercel.app", "http://localhost:3000"],
    methods: ["GET", "POST"],
    credentials: true
  }
});

app.use(cors());
app.use(express.json());

// Store active rooms and users
const activeRooms = new Map();
const activeDoctors = new Map();

// Health check endpoint
app.get('/', (req, res) => {
  res.json({ status: 'WebRTC Signaling Server is running', timestamp: new Date().toISOString() });
});

// WebRTC signaling
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);

  // Doctor comes online
  socket.on('doctor-online', (data) => {
    activeDoctors.set(data.doctorId, { socketId: socket.id, ...data });
    console.log('Doctor online:', data.doctorId);
  });

  // Doctor goes offline
  socket.on('doctor-offline', (data) => {
    activeDoctors.delete(data.doctorId);
    console.log('Doctor offline:', data.doctorId);
  });

  // Join video call room
  socket.on('join-room', (data) => {
    const { roomId, userType, userId } = data;
    socket.join(roomId);
    
    if (!activeRooms.has(roomId)) {
      activeRooms.set(roomId, { users: [], createdAt: new Date() });
    }
    
    const room = activeRooms.get(roomId);
    room.users.push({ socketId: socket.id, userType, userId });
    
    console.log(`User ${userId} joined room ${roomId} as ${userType}`);
    
    // Notify others in the room
    socket.to(roomId).emit('user-joined', { userId, userType });
  });

  // WebRTC signaling messages
  socket.on('offer', (data) => {
    socket.to(data.roomId).emit('offer', data);
  });

  socket.on('answer', (data) => {
    socket.to(data.roomId).emit('answer', data);
  });

  socket.on('ice-candidate', (data) => {
    socket.to(data.roomId).emit('ice-candidate', data);
  });

  // Call management
  socket.on('initiate-call', (data) => {
    const doctor = activeDoctors.get(data.doctorId);
    if (doctor) {
      io.to(doctor.socketId).emit('incoming-call', data);
    } else {
      socket.emit('call-error', { message: 'Doctor is not available' });
    }
  });

  socket.on('accept-call', (data) => {
    socket.to(data.roomId).emit('call-accepted', data);
  });

  socket.on('decline-call', (data) => {
    socket.to(data.roomId).emit('call-declined', data);
  });

  socket.on('end-call', (data) => {
    socket.to(data.roomId).emit('call-ended', data);
    // Clean up room
    if (activeRooms.has(data.roomId)) {
      activeRooms.delete(data.roomId);
    }
  });

  // Handle disconnect
  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
    
    // Remove from active doctors
    for (const [doctorId, doctor] of activeDoctors.entries()) {
      if (doctor.socketId === socket.id) {
        activeDoctors.delete(doctorId);
        break;
      }
    }
    
    // Clean up rooms
    for (const [roomId, room] of activeRooms.entries()) {
      room.users = room.users.filter(user => user.socketId !== socket.id);
      if (room.users.length === 0) {
        activeRooms.delete(roomId);
      }
    }
  });
});

const PORT = process.env.PORT || 3001;
server.listen(PORT, () => {
  console.log(`WebRTC Signaling Server running on port ${PORT}`);
});